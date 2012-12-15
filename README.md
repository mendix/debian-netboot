debian-netboot
==============

Track our serial console configuration and bnx2 patches to the debian netboot
files.

This README describes how our netboot setup at Mendix is configured. This
repository is simply cloned on all tftp server locations at /srv/tftp.

## Debian Installer ##

Get the netboot.tar.gz of your preferred Debian release, e.g. wheezy:

```
wget http://ftp.nl.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/netboot.tar.gz
```

From this archive, we actually only need the initrd.gz and linux files.  Keeping
version.info is also nice, by the way... Put the three files somewhere in your
tftp server location, e.g:

```
example.mendix.net:/srv/tftp 3-$ tree wheezy/
wheezy/
├── initrd.gz
├── linux
└── version.info

0 directories, 3 files
example.mendix.net:/srv/tftp 3-$ cat wheezy/version.info
Debian version:  7.0 (wheezy)
Installer build: 20121114
```

## syslinux ##

apt-get install syslinux and then copy pxelinux.0, menu.c32 and reboot.c32 from
/usr/lib/syslinux/ to the tftp server location.

## bnx2 ##

To add the bnx2 firmware, needed to install machines using Broadcom NetXtreme II
network chips, start by getting the latest firmware-bnx2 deb. Then, extract the
binary firmware and apppend it to the installer initrd. This has of course to be
done at least every time we sync installer files with upstream.

Example:

```
cd wheezy
mkdir tmp
cd tmp/
wget http://ftp.nl.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-bnx2_0.36_all.deb
ar -p firmware-bnx2* data.tar.gz | tar -zxf -
pax -x sv4cpio -s '%lib%/lib%' -w lib | gzip -c >> ../initrd.gz
cd ..
rm -rf tmp
cowsay yay
```

As seen on: http://wiki.debian.org/DebianInstaller/NetbootFirmware

## dhcp ##

When booting a machine over the network, the first thing it does is getting a
DHCP lease, looking at the options sent for instructions.

Instead of using a dynamic pool of addresses, only static leases are defined, so
each server get its own assigned ip address.

```
allow booting;
allow bootp;

subnet 10.10.5.0 netmask 255.255.255.0 {
    option broadcast-address 10.10.5.255;
    option routers 10.10.5.1;
    option domain-name-servers 10.10.5.2, 10.10.5.3;
    option domain-name "example.mendix.net";
}

group {
	next-server 10.10.5.16;
	host beta {
		hardware ethernet 00:25:90:38:b7:84;
		fixed-address 10.10.5.26;
		filename "pxelinux.0";
	}
}
```

When installing a new server, it fails to get an address because it's not in the
configuration yet. Using the mac address from syslog and the newly assigned ip
address this can be fixed easily. :)

## syslinux configuration ##

We use two configuration variants. The ttyS0-9600 config variant uses the first
serial port and speed 9600. We use it for installing old supermicro servers that
are connected to an Avocent ACS.

The ttyS1-115200 config uses the second serial port and speed 115200. We use it
for installing new HP servers using the virtual serial port (vsp) which can be
used over an ssh connection to the ILO management port.

Inside, there's only a few options in a basic menu. I don't care about colors or
menu items I don't use anyway, so it's just the Debian Installer expert mode,
the System Rescue cd and a reboot option.

Using symlinks based on server mac address, we can control the config file that
will be fetched by a netbooted server:

```
example.mendix.net:/srv/tftp 0-$ tree pxelinux.cfg/
pxelinux.cfg/
├── 01-00-25-90-38-b7-84 -> ttyS0-9600
├── default -> ttyS1-115200
├── ttyS0-9600
└── ttyS1-115200

0 directories, 4 files
```

## System Rescue cd ##

System Rescue cd: http://www.sysresccd.org/

For documentation, also see:
 * http://www.sysresccd.org/Sysresccd-manual-en\_PXE\_network\_booting
 * http://www.sysresccd.org/Sysresccd-manual-en\_Booting\_the\_CD-ROM#Network\_auto-configuration\_and\_remote\_access

So, dowload a system rescue cd and mount the iso using e.g. `mount -o loop
systemrescuecd-x86-x.y.z.iso /mnt/iso/`. Now, copy sysrcd.dat and sysrcd.md5
onto a web server location, but rescue64 and initram.igz to the tftp server
directory. Add a pxelinux menu item that points to these files, and voila!

Don't forget to set `keepalive_timeout 0;` on the location you serve sysrcd on
in your nginx configuration, or you'll see weird errors about stalled transfers.

Oh, and don't forget to enable nf\_conntrack\_tftp!
