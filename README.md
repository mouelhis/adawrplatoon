# Distributed control of wheeled robots platoons using the middlware PolyORB

This github repository is an Ada implementation of the design approach presented in the paper [Distributed Object-Oriented Design of Autonomous Control Systems for Connected Vehicle Platoons](https://hal.archives-ouvertes.fr/hal-01592739) (doi : 10.1109/ICECCS.2017.32).

See the animations videos below<br/>
https://www.youtube.com/watch?v=2WHyy5Z7nv4<br/>
https://www.youtube.com/watch?v=vIlWZUfYKIY<br/>
https://www.youtube.com/watch?v=Cl-vGISxBe4

Robots are directly controlled by the Romeo All-in-One V1.3 boards enslaved by Raspberry Pi (RPi) 3 cards on which a distributed software application of platooning control is deployed and executed under real-time (Preempt_RT) Linux kernels. The control software  is implemented in Ada and based on the object-oriented component-based design approach presented in the [reference paper](https://hal.archives-ouvertes.fr/hal-01592739). Distribution in the application is managed by the middleware PolyORB (maintained by AdaCore).

## Wheeled robots setting

Robots should be mounted according the architecture provided in the [reference paper](https://hal.archives-ouvertes.fr/hal-01592739); the first settings are the following:
* flash the Arduino code `arduino/sketch_wheeled_robot.ino` under the low-level Romeo controllers of robots:
  - robots should be connected by USB to your host;
  - use the tool `arduino` under your host to flash the code; 
* use preferably a real-time kernel under high level RPi controllers of robots;
* be sure that GCC and GNAT are installed under the robot RPi controllers.

## PolyORB 2014 Compilation 
### Patching

Sources (old) can be found under the folder polyorb-src/ of the repository; the patch polyorb-src/polyorb_2014_for_arm.patch should be applied before to enable error-free ARM compilation 

```
cp polyorb_2014_arm_enabled.patch <polyorb_sources>/
cd <polyorb_sources>/
cat polyorb_2014_arm_enabled.patch | patch -p1
```

Compatibility issues are to be checked and fixed if a [newer version](https://github.com/AdaCore/PolyORB) of PolyORB should be used. 

### Native/ARM-cross compilation

For native/ARM `arm-linux-gnueabihf` cross) compilation, the following dependencies (version 5 or higher) are required under Debian distributions:
```
gnat
gcc
g++
cpp
```

The apt installation process of the GNAT compiler automatically build the package `gprbuild`, be sure to remove it later.

To ARM-cross compile, being under `<polyorb_sources>` run the follwoing commands (read `INSTALL` for more details):
```
# export RANLIB=/usr/bin/arm-linux-gnueabihf-ranlib
# ./configure --target=arm-linux-gnueabihf --prefix=/usr/local/arm-linux-gnueabihf --with-appli-perso="corba moma dsa" --with-corba-services="event ir naming notification time"`
# make
# make install
```

If `make install`does not finish properly and displays an error message about the absence of a binary `arm-linux-gnueabihf-gcc-*-*` where `*` is a version equal to (or higher than) 5, create a copy of `arm-linux-gnueabihf-gcc-*` with the name `arm-linux-gnueabihf-gcc-*-*` under `/usr/bin` and redo `make install` again.

After the installation process, the binaries `po_gnatdist` and `po_cos_naming` and other required libraries and tools will be available under `/usr/local/arm-linux-gnueabihf`. Be sure that tools and libraries are distributed correctly in the tree `bin  include  lib  share` under `/usr/local/arm-linux-gnueabihf`.

Finally, export `/usr/local/arm-linux-gnueabihf/bin` in your `PATH`.

For native compilation, the above compilation steps are adapted:

```
# ./configure --with-appli-perso="corba moma dsa" --with-corba-services="event ir naming notification time"`
# make
# make install
```

## Application compilation 

The [BlueZ](http://www.bluez.org/download/) library (5.44 or higher) should be ARM-cross compiled; I remember following the steps described in this [tutorial](https://wiki.beyondlogic.org/index.php?title=Cross_Compiling_BlueZ_Bluetooth_tools_for_ARM) (the stepborn part was to cross-compile dependencies).   

ARM-cross compilation: `export TARGET=arm; make clean; make all`
Native compilation: `export TARGET=; make clean; make all`

## Deployment and running
Remote robots object refrences are to be stored in a base station (`base` runnable) that should be launched before running the wheeled robots platoon (`lead`, `foll_1` and `foll_2` runnbales). 

The runnbale `base` could be compiled natively on your host machine, and the runnables `lead`, `foll_1` and `foll_2` are to be ARM-cross compiled and deployed on the high level RPi controllers of robots. Be sure to provide the good MAC bluetooth addresses respectively in `leader.adb`, `follower_1.adb` and `follower_2.adb`. 

Before launching `base` on your host, you should first run the following commands (see [PolyORB User's Guide](http://docs.adacore.com/live/wave/polyorb/html/polyorb_ug/ug_contents.html#) for details):
* set your the host `<IP>` address (with an available first `<PORT1>` for [`po_cos_naming`](http://docs.adacore.com/live/wave/polyorb/html/polyorb_ug/CORBA.html#po-cos-naming)) in `polyorb.conf` under [`[dsa]`](http://docs.adacore.com/live/wave/polyorb/html/polyorb_ug/Ada_Distributed_Systems_Annex_(DSA).html) and [`[iiop]`](http://docs.adacore.com/live/wave/polyorb/html/polyorb_ug/GIOP.html#iiop) entries;
* set `polyorb.protocols.iiop.default_port=<PORT2>` with a second `<PORT2>` (used by `base`) under the entry `[iiop]`;
* run `po_cos_naming` in background (suffix `&`);
* export `POLYORB_DSA_NAME_SERVICE=corbaloc:iiop:1.2@<IP>:<PORT1>/NameService/000000024fF0000000080000000` to the environment;
* run `sudo ./base`.

## Contact
Sebti Mouelhi (`sebti _dot_ mouelhi _at_ ece _dot_ fr`)
