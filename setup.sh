#!/bin/bash

DIR=$1
CHROOT=/opt/ltsp/$DIR
if [ -z $DIR ]; then
        echo "Please specify an LTSP chroot name (ex: ./setup.sh test)"
        exit 1;
fi

CLIENT=`ls VMware-Horizon-Client*.bundle 2> /dev/null`

if [ -z $CLIENT ]; then
        echo "VMware-Horizon-Client bundle file not Found"
        echo "please visit http://www.vmware.com/go/viewclients and download last release for Linux"
        exit 1;
fi

echo "Building LTSP CHROOT $DIR"
echo "---------------------------------------------------------------------------------------------"
ltsp-build-client --arch amd64 --chroot $DIR --dist precise --late-package libxss1 libtheora0 libspeex1 openbox

echo "Installing other items needed in chroot"
echo "---------------------------------------------------------------------------------------------"
ltsp-chroot -ma $DIR apt-get update && apt-get upgrade
ltsp-chroot -ma $DIR apt-get install openbox linux-generic-lts-trusty libxss1 libtheora0 libspeex1 --yes

if [ ! -f $CHROOT/$CLIENT ]; then
        echo "Install VMWare View Client in CHROOT $DIR"
        echo "---------------------------------------------------------------------------------------------"
        cp $CLIENT $CHROOT/
        chmod a+x $CHROOT/$CLIENT
        ltsp-chroot -ma $DIR ./$CLIENT --console \
        --eulas-agreed \
        --set-setting vmware-horizon-usb usbEnable yes \
        --set-setting vmware-horizon-virtual-printing tpEnable no \
        --set-setting vmware-horizon-smartcard smartcardEnable no\
        --set-setting vmware-horizon-rtav rtavEnable yes \
        --set-setting vmware-horizon-tsdr tsdrEnable no
else
        echo "$CLIENT already installed in chroot"
fi

echo "Placing needed files"
echo "---------------------------------------------------------------------------------------------"
cp launch_vmview $CHROOT/root/
cp -r .config/ $CHROOT/root/
cp vmview $CHROOT/usr/share/ltsp/screen.d/
cp view-mandatory-config $CHROOT/etc/vmware/
cp fixes $CHROOT/etc/init.d/

echo "Fixing Sound"
echo "---------------------------------------------------------------------------------------------"
echo "options snd-hda-intel model=auto" >> $CHROOT/etc/modprobe.d/alsa-base.conf
echo "blacklist snd_hda_codec_hdmi" >> $CHROOT/etc/modprobe.d/blacklist.conf


echo "Updating LTSP image"
echo "---------------------------------------------------------------------------------------------"
ltsp-update-image $DIR
cp lts.conf /var/lib/tftpboot/ltsp/$DIR

echo "Fixing TFTPBoot"
echo "---------------------------------------------------------------------------------------------"
DEFAULTFILE=/var/lib/tftpboot/ltsp/$DIR/pxelinux.cfg/default
IP="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
sed -i -e "s/splash plymouth:force-splash vt.handoff=7/nbdroot=$IP:\/opt\/ltsp\/$DIR/" $DEFAULTFILE

echo "Finished, try booting"
