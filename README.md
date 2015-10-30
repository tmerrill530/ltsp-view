# ltsp-view
Ubuntu 14.04, LTSP, PXE Boot VMWare View Client 3.5

Disclaimer: I am by now means a Linux Guru. I know just enough to be dangerous. This setup worked for me, your results may vary. I really hope someone with more Linux knowledge than myself can improve on this.

I found these resources invaluable while muddling my way through this
https://github.com/leschartreux/ltsp-vmview
https://help.ubuntu.com/community/UbuntuLTSP/VMWareViewVDI
http://wiki.ltsp.org/wiki/LTSPedia
https://www.vmware.com/pdf/horizon-view/horizon-client-linux-document.pdf

# Requirements
* Ubuntu Server 14.04 LTS 
* Static IP set
* OpenSSH installed for remote access to server
* Windows DHCP Server - I used a Windows DHCP server because that is what I already have setup in my environment.

# Setup
All commands run as root (`sudo bash`)

1. Install the LTSP Server package
 ```
# apt-get install ltsp-server-standalone
```

