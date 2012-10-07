#!/bin/bash

# Script for building full AgiliaLinux ISO images
# 
# Available environment options:
# ARCH: target architecture (x86_64 or x86, default: host arch)
# ISOBUILD: isobuild used to build image (default: openbox)
# USE_TESTING: enables testing packages. Values: 1, 0; default: not set


set -e
# Getting current directory, date and host arch
CWD=`pwd`
date=`date -u +%Y%m%d`
hostarch=${ARCH:-`uname -m`}
ISOBUILD=${ISOBUILD:-openbox}

if [ "$hostarch" = "x86_64" ] ; then
	arch=x86_64
	bits=64
else
	arch=x86
	bits=32
fi

TREE=$CWD/RSYNC/$arch
TESTING_TREE=$CWD/RSYNC/${arch}-testing
LIVECONT=$CWD/BUILD
NAME=agilia_live
LIVEROOT=$LIVECONT/$NAME-$arch
ISODIR=$CWD/iso

ISONAME=AgiliaLinux-core-$arch-$date.iso
if [ "$USE_TESTING" = "1" ] ; then
	ISONAME=AgiliaLinux-testing-$arch-$date.iso
fi

REPO=file:///$TREE/repository/

if [ "$USE_TESTING" = "1" ] ; then
	REPO="$REPO file:///$TESTING_TREE/repository"
fi

# First of all, rsync please
# Check if directory exists, if not - create it and download rsync script
if [ ! -f $TREE/rsync-update.sh ] ; then
	echo "No RSYNC script, creating it"
	mkdir -p $TREE
	( cd $TREE && wget http://packages.agilialinux.ru/core/8.0/$arch/rsync-update.sh )
fi

if [ "$USE_TESTING" = "1" ] ; then
	echo "RSyncing testing repo, wait please"
	if [ ! -f $TESTING_TREE/rsync-update.sh ] ; then
		mkdir -p $TESTING_TREE
		( cd $TESTING_TREE && wget http://packages.agilialinux.ru/testing/8.0/$arch/rsync-update.sh )
	fi
fi



# Do the sync
( cd $TREE && sh ./rsync-update.sh )

if [ "$USE_TESTING" = "1" ] ; then
	( cd $TESTING_TREE && sh ./rsync-update.sh)
fi


# Clean previous builds
echo "Cleaning previous build directory: $LIVEROOT"
rm -rf $LIVEROOT


# Now, build rootfs
echo "Building live system"
( cd ISOBUILDS/${ISOBUILD}
	iso_name=$NAME arch=$arch REPO="$REPO" mklivecd -l $LIVECONT -a
)

# Copy new files to original tree
rm -f $TREE/boot/initrd${bits}.img
rm -f $TREE/boot/vmlinuz${bits}
rm -f $TREE/fs${bits}/rootfs.sfs

cp -v $LIVEROOT/boot/initrd${bits}.img $TREE/boot/
cp -v $LIVEROOT/boot/vmlinuz${bits} $TREE/boot/
cp -v $LIVEROOT/fs${bits}/rootfs.sfs $TREE/fs${bits}/

# If testing is used, copy testing package tree and re-generate index
if [ "$USE_TESTING" = "1" ] ; then
	mkdir -p $TREE/repository/_testing
	rsync -arvh --progress $TESTING_TREE/repository $TREE/repository/_testing
	( cd $TREE ; mpkg-index )
fi


# Create final ISO
mkdir -p $ISODIR
( cd $TREE ; ISO_FILE=$ISODIR/$ISONAME ./makeiso.sh )

set +e
