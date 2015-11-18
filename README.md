# ltsp-view
Ubuntu 14.04, LTSP, PXE Boot VMWare View Client 3.5

Disclaimer: I am by no means a Linux Guru. I know just enough to be dangerous. This setup worked for me, your results may vary. I really hope someone with more Linux knowledge than myself can improve on this.

I needed a non-destructive and cheap way to turn old PCs or any PC into a VMWare View client. I also wanted all the fluff gone so that the user was just presented with the View client. What is the point of launching Windows, launching the View client... and logging back in to a Windows VDI session?

I found these resources invaluable while muddling my way through this

https://github.com/leschartreux/ltsp-vmview

https://help.ubuntu.com/community/UbuntuLTSP/VMWareViewVDI

http://wiki.ltsp.org/wiki/LTSPedia

https://www.vmware.com/pdf/horizon-view/horizon-client-linux-document.pdf

# Requirements
* Ubuntu Server 14.04 LTS 
* Static IP set
* OpenSSH installed for remote access to server
* VMware-Horizon-Client-3.5.xx client .bundle
* Windows DHCP Server - I used a Windows DHCP server because that is what I already have setup in my environment.
* Windows DHCP Scope Option 66 set to the IP or hostname of your LTSP server
* Windows DHCP Scope Option 67 set to `/ltsp/view/pxelinux.0`

# Ubuntu Setup
All commands run as root (`sudo bash`)

* Install the LTSP Server package
 ```
# apt-get install ltsp-server-standalone
```
* Remove the DHCP service from auto starting. As I mentioned previously I have a Windows DHCP server in my environment
```
# update-rc.d -f isc-dhcp-server remove
```
* Disable the firewall
```
# ufw disable
```
* Grab my files to make this work.
```
# apt-get install git
# git clone https://github.com/tmerrill530/ltsp-view.git
```
* Build the chroot that your clients will PXE boot. This will create a Precise (Ubuntu 12.04) 64 bit chroot. Precise is the offically supported 64 bit version of Linux for the View client. This command also installs some things needed by VMWare View to run.
```
# ltsp-build-client --arch amd64 --chroot view --kiosk --dist precise --late-package libxss1 libtheora0 libspeex1 openbox
```

# Client Setup
* Copy the VMWare.bundle to your newly created chroot
```
# cp VMware-Horizon-Client-3.5.0-2999900.x64.bundle  /opt/ltsp/view/
```
* Install the client
```
# ltsp-chroot -ma view
# chmod +x VMware-Horizon-Client-3.5.0-2999900.x64.bundle
# ./ VMware-Horizon-Client-3.5.0-2999900.x64.bundle
```
Accept the EULA. I answered yes to USB redirection, webcam sharing, and no to everything else. When you are asked about auto starting the service say yes. Answer yes to having VMWare scan your system for dependiencies. If you have any errors now would be a good time to fix them.

* Set a password for the root user. I used this for troubleshooting.
```
# passwd
# exit
```

Now it is time to put all the files where they need to be to make this all work. At some point I will write a script but for now:
```
# cd ltsp-view
# chown root:root *
# chown -R root:root openbox/
# chmod +x launch_vmview
# chmod +x vmview
# cp ltsp-update-image.excludes /etc/ltsp/
# cp vmview /opt/ltsp/view/usr/share/ltsp/screen.d/
# cp launch_vmview /opt/ltsp/view/root/
# nano view-mandatory-config
```
Enter the IP address or hostname of your ViewConnection Server where indicated
```
# cp view-mandatory-config /opt/ltsp/view/etc/vmware/
# mkdir /opt/ltsp/view/root/.config
# cp -r openbox /opt/ltsp/view/root/.config/
# ltsp-update-image
```

Running `ltsp-update-image` will take a minute or five.

After `ltsp-update-image` finishes,
```
# nano /var/lib/tftpboot/view/pxelinux.cfg/default
```
remove the boot arguments until "quiet" and then add `nbdroot=<IP of ltsp server>:/opt/ltsp/view`. You can look at my example `default` file.

```
# cp ltsp-view/lts.conf /var/lib/tftp/ltsp/view/
```

Now PXE boot a client
