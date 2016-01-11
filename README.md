vhost-generator
===============

Shell Script to create Apache virtual hosts on Ubuntu 12.04. This script sets up vhosts based on the domain and document root you pass to it. It will automatically enable/disable sites and restart Apache. 

## Install ##

Place the `vhost.sh` file in your home directory on the server. From here you should ensure that the script has execute permissions.

    $ chmod +x vhost.sh

## Usage ##

Run the script and pass along the domain that you want to create, and the document root for that domain.

    $ sudo ./vhost.sh create example.com example.com/public_html

You can also remove a vhost by passing along a delete parameter, and the domain and document root.

    $ sudo ./vhost.sh delete example.com example.com/public_html 
