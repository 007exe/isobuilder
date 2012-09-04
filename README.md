
AgiliaLinux ISO image builder
=============================


This script builds an ISO images with AgiliaLinux, which contains fresh LiveCD environment and core repository.

So, it's structure is identical to release ISO images.

In near future, this script will be used to automatically build daily ISO images for AgiliaLinux.



Current limitations
--------------------

1. Almost everything is hardcoded, including server name and ISOBUILD config path
2. No documentation, except this readme file
3. No command-line options
4. Output is always inside current directory


Fundamental restrictions
------------------------
1. root permissions required to build x86 images using x86_64 build environment
2. Cannot build x86_64 images using x86 build environment


Usage
------
1. Get script with ISOBUILDS directory
2. Edit script and ISOBUILD to match your needs
3. Run it from directory where you want to build ISO.
4. If you need to update your ISO, just re-run script (ISO will be named by current date, and package tree will be automatically updated).


How it works
-------------
1. Creates directory structure for building process
2. Downloads rsync-update.sh script from the server
3. Do an rsync of core repository using rsync-update.sh script
4. Cleans up previous build files, if any
5. Executes mklivecd to build Live filesystem images
6. Copies resulting images to rsync tree
7. Runs makeiso.sh and creates ISO image


