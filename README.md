# Distributed control of wheeled robots platoons using the middlware PolyORB

This github repository is an Ada implementation of the distributed speed controller for platoons of connected wheeled robot. The software design and protyping approaches are presented in [\[Ref\]](https://hal.archives-ouvertes.fr/hal-01592739).

See animations in these Youtube videos:<br/>
https://www.youtube.com/watch?v=2WHyy5Z7nv4<br/>
https://www.youtube.com/watch?v=vIlWZUfYKIY<br/>
https://www.youtube.com/watch?v=Cl-vGISxBe4

Robots are directly controlled by Romeo All-in-One V1.3 boards enslaved by Raspberry Pi (RPi) 3 cards on which a distributed software application of platooning control is deployed and executed under real-time (Preempt_RT) Linux kernels. The control software  is implemented in Ada and based on the object-oriented component-based design approach presented in [\[Ref\]](https://hal.archives-ouvertes.fr/hal-01592739). Distribution is managed by the middleware PolyORB (maintained by AdaCore).

## Wheeled robots

Robots should be mounted according the architecture provided in [\[Ref\]](https://hal.archives-ouvertes.fr/hal-01592739); the first settings are the following:
* flash the Arduino code `arduino/sketch_romeo.ino` under the low-level Romeo controllers of robots:
  - the Romeo board should be connected by USB to your host;
  - use the tool `arduino` to flash the code from your host ; 
* use preferably a real-time kernel under the high level RPi controllers;
* be sure that GCC and GNAT are installed on RPi cards.

## PolyORB 2014 Compilation 
### Patching

Sources (old) can be found under the folder `polyorb-src/` of the repository; the patch `polyorb-src/polyorb_2014_arm_enabled.patch` should be applied before to enable error-free ARM compilation 

```
cp polyorb_2014_arm_enabled.patch <polyorb_sources>/
cd <polyorb_sources>/
cat polyorb_2014_arm_enabled.patch | patch -p1
```

Compatibility issues are to be checked and fixed if a [newer version](https://github.com/AdaCore/PolyORB) of PolyORB should be used. 

### Native/ARM-cross compilation

For native/ARM(`arm-linux-gnueabihf`)-cross) compilation, the following dependencies (version 5 or higher) are required under Debian distributions:
```
gnat
gcc
g++
cpp
```

The apt installation process of the GNAT compiler build automatically the package `gprbuild`, be sure to remove it later.

Being under `<polyorb_sources>/` run the follwoing commands to ARM-cross compile (read `INSTALL` for more details):
```
# export RANLIB=/usr/bin/arm-linux-gnueabihf-ranlib
# ./configure --target=arm-linux-gnueabihf --prefix=/usr/local/arm-linux-gnueabihf --with-appli-perso="corba moma dsa" --with-corba-services="event ir naming notification time"`
# make
# make install
```

If `make install`does not finish properly and displays an error message about the absence of a binary `arm-linux-gnueabihf-gcc-*-*` where `*` is a version equal to (or higher than) 5, create a copy of `arm-linux-gnueabihf-gcc-*` with the name `arm-linux-gnueabihf-gcc-*-*` under `/usr/bin` and redo `make install` again.

After the installation process, the binaries `po_gnatdist` and `po_cos_naming` and other required libraries and tools will be generated and copied in the `/usr/local/arm-linux-gnueabihf` folder tree `bin  include  lib  share`. Be sure that tools and libraries are distributed correctly in the tree.

Finally, export `/usr/local/arm-linux-gnueabihf/bin` in your `PATH`.

For native compilation, the above compilation steps are adapted:

```
# ./configure --with-appli-perso="corba moma dsa" --with-corba-services="event ir naming notification time"`
# make
# make install
```

## Platoon application 

### Compilation

The [BlueZ](http://www.bluez.org/download/) library (5.44 or higher) should be ARM-cross compiled before; I remember adapting the steps described in this [tutorial](https://wiki.beyondlogic.org/index.php?title=Cross_Compiling_BlueZ_Bluetooth_tools_for_ARM) (the stepborn part was to cross-compile dependencies).   

**ARM**: `export TARGET=arm; make clean; make all`<br/>
**Native**: `export TARGET=; make clean; make all`

### Deployment and running
Robots object refrences are to be stored in a base station (runnable `base`) that should be launched before running the wheeled robots platoon (runnbales `lead`, `foll_1` and `foll_2`). 

The runnbale `base` could be compiled natively on your host machine, and each of the runnables `lead`, `foll_1` and `foll_2` are to be ARM-cross compiled and deployed on the high level RPi controller of teh corresponding robot. Be sure to provide the good MAC bluetooth addresses respectively in `leader.adb`, `follower_1.adb` and `follower_2.adb`. 

On your host, you should do the following (see [PolyORB User's Guide](http://docs.adacore.com/live/wave/polyorb/html/polyorb_ug/ug_contents.html#) for details):
* set your the host `<HOST_IP>` address (with an available first `<HOST_PORT1>` for [`po_cos_naming`](http://docs.adacore.com/live/wave/polyorb/html/polyorb_ug/CORBA.html#po-cos-naming)) in `polyorb.conf` under [`[dsa]`](http://docs.adacore.com/live/wave/polyorb/html/polyorb_ug/Ada_Distributed_Systems_Annex_(DSA).html) and [`[iiop]`](http://docs.adacore.com/live/wave/polyorb/html/polyorb_ug/GIOP.html#iiop) entries;
* set `polyorb.protocols.iiop.default_port=<HOST_PORT2>` with a second `<HOST_PORT2>` (used by `base`) under the entry `[iiop]`, then run:
``` 
# po_cos_naming &
# export POLYORB_DSA_NAME_SERVICE=corbaloc:iiop:1.2@<HOST_IP>:<HOST_PORT1>/NameService/000000024fF0000000080000000
# ./base
```

On each robot RPi controller, you should do the following: 
* transfer to the RPi the corresponding `<runnable>` (`lead`, `foll_1` or `foll_2`) and the file `polyorb.conf`;
* set `polyorb.protocols.iiop.default_addr=<RPI_IP>` address in `polyorb.conf` under the entry `[iiop]`;
* set `polyorb.protocols.iiop.default_port=<RPI_PORT>` for some available `<RPI_PORT>` under the entry `[iiop]` then run:
```
# export POLYORB_DSA_NAME_SERVICE=corbaloc:iiop:1.2@<HOST_IP>:<HOST_PORT1>/NameService/000000024fF0000000080000000
#./<runnable>
```

## Contact
For any question, feel free to contact Sebti Mouelhi @ ECE Paris (`first _dot_ last _at_ ece _dot_ fr`).

## Reference
[\[Ref\]](https://hal.archives-ouvertes.fr/hal-01592739) S. Mouelhi, D. Cancila and A. Ramdane-Cherif, "Distributed Object-Oriented Design of Autonomous Control Systems for Connected Vehicle Platoons," 2017 22nd International Conference on Engineering of Complex Computer Systems (ICECCS), Fukuoka, 2017, pp. 40-49. doi: 10.1109/ICECCS.2017.32
