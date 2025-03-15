# wpiahn2-hyperv-scripts

These scripts relate to `wpia-hn2.hpc.dide.ic.ac.uk` - a Windows 2022 
server mainly hosting a large amount of storage, and also a small 
number of VMs, designed to support cluster use. 

This is not primarily a VM host; but we can run some, 
especially those needing considerable storage, but not
too much CPU and RAM.

## The Host Machine Specs

* SuperMicro SYS-221H-TN24R (Motherboard X13DEM)
* Dual Intel Xeon Golf 5415+, 8 cores at 2.90GHz, multi-threaded to 16 each.
* 256Gb of 4800MHz RAM
* Intel X710 10Gb network card
* Mellanox infiniband to cluster (10.0.2.253)
* 800Gb dual SSD for the OS (RAID 1)
* D: 132Tb of NVMe RAID 6 storage for VIMC-CC
* E: 132Tb of NVMe RAID 6 storage for cluster use
* NVMe RAIDs are done through Intel VRoC on hardware.

## Operating System Config

* The system runs Windows Server 2022 with Hyper-V. The `C:` is for Operating System
only, whereas `D:` and `E:` are NVMe space.
* This repo will be sitting in `E:\wpiahn2-hyperv-scripts` and disk images within
`.vagrant` folders of each VM.
* NotePad++ is installed for slightly less painful editing of files - use `edit` from the command-line.
* And the command prompt is rigged up with most of the GNU tools.
* For disaster/diagnostics, the IPMI for wpia-hn2 is `https://wpia-hn2-ipmi.dide.ic.ac.uk/`

## Current VMs

We will statically decide what the MAC addresses is for each virtual machine - all
the MAC addresses will be in the form `00:15:5d:b1:1e:xx`.  existing so far:-

| Machine                 | Cores | RAM | Disk | MAC | IP        |
|-------------------------|-------|-----|------|-----|-----------|
| wpia-hn2b               |   4   | 16  | 16Tb | 01  | dide      |

## Usage of whole machine:

|                      | Total     | VM allocated | Spare |
|----------------------|-----------|--------------|-------|
| Cores (logical)      |    32     | 4            | 28    |
| RAM (Gb)             |   256     | 16           | 240   |
| DISK (E: SSD) (Tb)   |   132     | 16           | 116   |

Note:

* Hyperthreading is turned on, as recommended for Hyper-V. So this
  machine has 16 physical cores, 32 logical ones. 
* Figures represent allocated resources; looking at task manager
  will give smaller usage figures, as Hyper-V will only allocate
  real resources when they are demanded. Disk usage will grow as
  the VM fills it.
* Note that RAM is also shared with operating system - hard to
  estimate how much the OS really needs. 16Gb perhaps?
* DISK is not shared with OS though - the E: is separate. Remember
  to allocate for the disk-space for the VM, and also its RAM, since
  the VM swap/hibernation files are also written to the disk.

### Creating VMs that need a DIDE IP address

* The VM  should be named `wpia-something`. Create a PR on this repo, updating
  the table above with a MAC address. Contact Chris in IT and ask for an IP address,
  providing him with the MAC address, the `wpia-something` name, and letting him
  know this will be a VM running on wpia-reside1. You may also want to request that
  he creates an alias for `wpia-something` called just `something`. This may take
  15 or 30 minutes - wait until you can ping `wpia-something.dide.ic.ac.uk` before
  continuing.

* Remote Desktop to `wpia-hn2.hpc.dide.ic.ac.uk` with DIDE details; there should be
  a `Command Prompt` icon on the desktop, which has been made as linux-compatible
  as possible. You can also use `edit` to fire up `Notepad++` for a reasonably
  sane editing experience.

* Make a new directory for the new machine, copying the defaults from an
  existing one (`wpia-hn2b` is the only so far).
  
 
* Edit the Vagrantfile. The resources required are at the top, and scripts to
  provision the VM a bit lower.

* `vagrant up` from that folder.

* Then you should be able to connect to the new VM from ssh or putty. Usually
  we automatically fetch github public keys - see `common/setup-ssh-keys.sh`
  
* Username for login will be `vagrant` - for logging directly into the VM
  without ssh, use Hyper-V, right click and "Connect" with password vagrant.
 

## Disk sizes

* Vagrant does not seem able to manage default disk size with Hyper-V.
* After building a VM, power it off, and use Hyper-V manager to edit
the disk size:- Right click on the VM, Settings, find IDE Controller 0
and Hard-Drive. Edit button, Next, Expand, Next, choose the size.
Next. Finish!

### For Ubuntu 22:-

Ubuntu 22 changed something about logical volumes, and an extra
step might be needed. 

* Restart the VM, then `sudo lsblk`.

If you see something like this:

```
sda                         8:0    0   500G  0 disk
├─sda1                      8:1    0     1M  0 part
├─sda2                      8:2    0     2G  0 part /boot
└─sda3                      8:3    0   126G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0    63G  0 lvm  /
```

then you first have to make `sda3` as big as `sda`. 

``` 
sudo growpart /dev/sda 3
sudo lsblk
```

and hopefully you now see something like 

```
sda                         8:0    0   500G  0 disk
├─sda1                      8:1    0     1M  0 part
├─sda2                      8:2    0     2G  0 part /boot
└─sda3                      8:3    0   498G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0    63G  0 lvm  /
```

Now, we need to make the ubuntu--vg as big as sda3. 

```
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
sudo lsblk
```

and hopefully the partition has now grown:-

```
sda                         8:0    0   500G  0 disk
├─sda1                      8:1    0     1M  0 part
├─sda2                      8:2    0     2G  0 part /boot
└─sda3                      8:3    0   498G  0 part
  └─ubuntu--vg-ubuntu--lv 253:0    0   498G  0 lvm  /
```
