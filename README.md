# Distributed control of wheeled robots platoons using the middlware PolyORB

This github repository is an Ada implementation of the design approach presented in the paper "Distributed Object-Oriented Design of Autonomous Control Systems for Connected Vehicle Platoons" (doi : 10.1109/ICECCS.2017.32).

See the animations videos below<br/>
https://www.youtube.com/watch?v=2WHyy5Z7nv4<br/>
https://www.youtube.com/watch?v=vIlWZUfYKIY<br/>
https://www.youtube.com/watch?v=Cl-vGISxBe4

Robots are directly controlled by the Romeo All-in-One V1.3 boards enslaved by Raspberry Pi 3 cards on which a distributed software application of platooning control is deployed and executed under real-time (Preempt_RT) Linux kernels 4.4.21. The control software  is implemented in Ada and based on the object-oriented component-based design approach presented in the reference paper above. Distribution in the application is managed by the middleware PolyORB (maintained by AdaCore).

## Compilation 
### PolyORB 2014 patching

Sources (old) can be found under the folder polyorb-src/ of the repository; the patch polyorb-src/polyorb_2014_for_arm.patch should be applied before to enable error-free ARM compilation 

`cp polyorb_2014_arm_enabled.patch <polyorb_sources>/`<br/>
`cd <polyorb_sources>/`<br/>
`cat polyorb_2014_arm_enabled.patch | patch -p1`

Compatibility issues are to be checked and fixed if a newer version of PolyORB (https://github.com/AdaCore/PolyORB) should be used. 

### Dependencies

For native/ARM `arm-linux-gnueabihf` cross) compilation, the following packages (version 5 or higher) are required under Debian distributons:
```
gnat
gcc
g++
g++
cpp
```

The apt installation process of the GNAT compiler automatically build the package `gprbuild`, be sure to remove it later.

### ARM cross-compilation

`# ./configure --target=arm-linux-gnueabi --prefix=/usr/local/arm-linux-gnueabihf --with-appli-perso="corba moma dsa" --with-corba-services="event ir naming notification time"`
`# make`
`# make install`

Read `INSTALL` for more details.

## Deployment 
Check file DEPLOYMENT

## RUN
Check file RUN

## Conact
Sebti Mouelhi (sebti _dot_ mouelhi _at_ ece _dot_ fr)
