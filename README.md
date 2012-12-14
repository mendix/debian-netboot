debian-netboot
==============

Track our serial console / bnx2 patches to the debian netboot files

See http://bugs.debian.org/309223 about why there is no serial console
support in the installer by default.

Most of the work is done in branches.
 - upstream contains the debian netboot.tar.gz files
 - serial-9600 contains the ttyS0,9600 config
 - bnx2-vsp-115200 contains the ttyS1,115200 config, plus bnx2 firmware

The serial-9600 branches contains the config variant that uses the first serial
port and speed 9600. We use it for installing old supermicro servers that are
connected to an Avocent ACS.

The bnx2-vsp-115200 branches contains the config variant that uses the second
serial port and speed 115200. We use it for installing new HP servers using the
virtual serial port (vsp) which can be used over an ssh connection to the ILO
management port.

## upstream ##

```
wget http://ftp.nl.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/netboot.tar.gz
```

review changes, commit and merge to other branches...

## bnx2 ##

To add the bnx2 firmware, start by getting the latest firmware-bnx2 deb. This
has to be done at least every time we sync with upstream.

Example:

```
cd debian-installer/amd64
mkdir tmp
cd tmp/
ar -p firmware-bnx2_0.28+squeeze1_all.deb data.tar.gz | tar -zxf -
pax -x sv4cpio -s '%lib%/lib%' -w lib | gzip -c >bnx2-fw.cpio.gz
cat bnx2-fw.cpio.gz >> ../initrd.gz
cd ..
rm -rf tmp
cowsay yay
```

As seen on: http://wiki.debian.org/DebianInstaller/NetbootFirmware

## sysrcd ##

Also, each config branch includes settings to load the systemrescuecd over http

System Rescue CD: http://www.sysresccd.org/

For documentation, also see:

```
http://www.sysresccd.org/Sysresccd-manual-en_PXE_network_booting
http://www.sysresccd.org/Sysresccd-manual-en_Booting_the_CD-ROM#Network_auto-configuration_and_remote_access
```

Howto: dowload a system rescue cd, mount the iso and copy some files...

```
# mount -o loop systemrescuecd-x86-x.y.z.iso /mnt/iso/

$ cd sysrcd
$ cp /mnt/iso/sysrcd.md5 .
$ cp /mnt/iso/sysrcd.dat .
$ cp /mnt/iso/isolinux/rescue64 .
$ cp /mnt/iso/isolinux/initram.igz .
```

voila! (don't forget to enable `nf_conntrack_tftp`)

