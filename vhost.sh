#!/bin/bash
TEXTDOMAIN=virtualhost

action=$1
domain=$2
rootDir=$3
owner=$(who am i | awk '{print $1}')
email='webmaster@localhost'
sitesEnable='/etc/apache2/sites-enabled/'
sitesAvailable='/etc/apache2/sites-available/'
userDir='/var/www/'
sitesAvailabledomain=$sitesAvailable$domain

if [ "$(whoami)" != 'root' ]; then
	echo $"No permissions to run $0 as non-root user. Use sudo"
		exit 1;
fi

if [ "$action" != 'create' ] && [ "$action" != 'delete' ]
	then
		echo $"Add create or delete parameter"
		exit 1;
fi

while [ "$domain" == "" ]
do
	echo -e $"Please enter domain."
	read domain
done

if [ "$rootDir" == "" ]; then
	rootDir=${domain//./}
fi

if [[ "$rootDir" =~ ^/ ]]; then
	userDir=''
fi

rootDir=$userDir$rootDir

if [ "$action" == 'create' ]
	then
		if [ -e $sitesAvailabledomain ]; then
			echo -e $"This domain already exists."
			exit;
		fi

		if ! [ -d $rootDir ]; then

			mkdir -p $rootDir

			chmod 755 $rootDir

			if ! echo "<?php echo phpinfo(); ?>" > $rootDir/phpinfo.php
			then
				echo $"ERROR: Not able to write in file $userDir/$rootDir/phpinfo.php. Please check permissions"
				exit;
			else
				echo $"Added content to $rootDir/phpinfo.php"
			fi
		fi

		if ! echo "
		<VirtualHost *:80>
			ServerAdmin $email
			ServerName $domain
			ServerAlias www.$domain
			DocumentRoot $rootDir
			ErrorLog /var/log/apache2/$domain-error.log
			CustomLog /var/log/apache2/$domain-access.log combined
		</VirtualHost>" > $sitesAvailabledomain
		then
			echo -e $"There is an ERROR creating $domain file"
			exit;
		else
			echo -e $"\nNew Virtual Host Created\n"
		fi

		if ! echo "127.0.0.1	$domain" >> /etc/hosts
		then
			echo $"ERROR: Not able to write /etc/hosts"
			exit;
		else
			echo -e $"Host added \n"
		fi

		if [ "$owner" == "" ]; then
			chown -R $(whoami):$(whoami) $rootDir
		else
			chown -R $owner:$owner $rootDir
		fi

		a2ensite $domain

		/etc/init.d/apache2 reload

		echo -e $"Complete! \nYou now have a new Virtual Host \nYour new host is: http://$domain \nAnd its located at $rootDir"
		exit;
	else
		if ! [ -e $sitesAvailabledomain ]; then
			echo -e $"This domain does not exist.\nPlease try another one"
			exit;
		else
			newhost=${domain//./\\.}
			sed -i "/$newhost/d" /etc/hosts

			a2dissite $domain

			/etc/init.d/apache2 reload

			rm $sitesAvailabledomain
		fi

		if [ -d $rootDir ]; then
			echo -e $"Delete the host root directory ? (y/n)"
			read deldir

			if [ "$deldir" == 'y' -o "$deldir" == 'Y' ]; then
				rm -rf $rootDir
				echo -e $"Host Directory deleted"
			else
				echo -e $"Host Directory not deleted"
			fi
		else
			echo -e $"Host directory not found. Ignored"
		fi

		echo -e $"Complete!\nYou just removed Virtual Host $domain"
		exit 0;
fi
