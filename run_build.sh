#!/bin/bash
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
LIVECONT=$CWD/BUILD
NAME=agilia_live
LIVEROOT=$LIVECONT/$NAME-$arch
ISODIR=$CWD/iso
ISONAME=AgiliaLinux-$arch-$date.iso


# First of all, rsync please
# Check if directory exists, if not - create it and download rsync script
if [ ! -f $TREE/rsync-update.sh ] ; then
	echo "No RSYNC script, creating it"
	mkdir -p $TREE
	( cd $TREE ; wget http://packages.agilialinux.ru/core/8.0/$arch/rsync-update.sh )
fi

# Do the sync
( cd $TREE && sh ./rsync-update.sh )

# Clean previous builds
echo "Cleaning previous build directory: $LIVEROOT"
rm -rf $LIVEROOT


# Now, build rootfs
echo "Building live system"
( cd ISOBUILDS/${ISOBUILD}
	iso_name=$NAME arch=$arch REPO=file:///$TREE/repository/ mklivecd -l $LIVECONT -a
)

# Copy new files to original tree
cp -v $LIVEROOT/boot/initrd${bits}.img $TREE/boot/
cp -v $LIVEROOT/boot/vmlinuz${bits} $TREE/boot/
cp -v $LIVEROOT/fs${bits}/rootfs.sfs $TREE/fs${bits}/



# Create final ISO
mkdir -p $ISODIR
( cd $TREE ; ISO_FILE=$ISODIR/$ISONAME ./makeiso.sh )

set +e
