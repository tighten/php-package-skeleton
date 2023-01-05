#!/bin/bash

git_name=`git config user.name`;
git_email=`git config user.email`;

read -p "Author name ($git_name): " author_name
author_name=${author_name:-$git_name}

read -p "Author email ($git_email): " author_email
author_email=${author_email:-$git_email}

username_guess=${author_name//[[:blank:]]/}
username_guess="$(echo $username_guess | tr '[A-Z]' '[a-z]')"
read -p "Author GitHub username ($username_guess): " author_username
author_username=${author_username:-$username_guess}

current_directory=`pwd`
current_directory=`basename $current_directory`
read -p "Package Composer name ($current_directory): " package_name
package_name=${package_name:-$current_directory}

fullname_guess="$(echo $package_name | perl -pe 's/(^|-)./uc($&)/ge;s/-/ /g')"
read -p "Package full name ($fullname_guess): " package_fullname
package_fullname=${package_fullname:-$fullname_guess}

namespace_guess="$(echo $package_name | perl -pe 's/(^|-)./uc($&)/ge;s/-//g')"
read -p "Package PHP namespace ($namespace_guess): " package_php_namespace
package_php_namespace=${package_php_namespace:-$namespace_guess}

read -p "Package description: " package_description

echo
echo    "----------------------------------------------------------------------"
echo -e "Author:      $author_name ($author_email)"
echo -e "             github.com/$author_username"
echo
echo -e "Name:        $package_fullname"
echo -e "Description: $package_description"
echo -e "PHP:         Tighten\\$package_php_namespace"
echo -e "Packagist:   tightenco/$package_name"
echo    "----------------------------------------------------------------------"

echo
echo "This script will replace the above values in all files in the project."
read -p "Are you sure you wish to continue? (Y/n) " -n 1 -r

echo
if [[ $REPLY =~ ^[Nn]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

echo

find . -type f -exec sed -i '' -e "s/:author_name/$author_name/g" {} \;
find . -type f -exec sed -i '' -e "s/:author_username/$author_username/g" {} \;
find . -type f -exec sed -i '' -e "s/:author_email/$author_email/g" {} \;
find . -type f -exec sed -i '' -e "s/:package_name/$package_name/g" {} \;
find . -type f -exec sed -i '' -e "s/:package_fullname/$package_name/g" {} \;
find . -type f -exec sed -i '' -e "s/:package_description/$package_description/g" {} \;
find . -type f -exec sed -i '' -e "s/:package_php_namespace/$package_php_namespace/g" {} \;

mv src/Skeleton.php "src/${package_php_namespace}.php"
mv src/SkeletonFacade.php "src/${package_php_namespace}Facade.php"
mv src/SkeletonServiceProvider.php "src/${package_php_namespace}ServiceProvider.php"

sed -i '' -e "/^\*\*Note:\*\* Replace/d" README.md

echo "Replaced all values and reset git directory, self destructing in 3... 2... 1..."

rm -- "$0"
