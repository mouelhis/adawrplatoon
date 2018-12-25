BARE_GCC = gcc
BARE_GNAT = gnatmake
BARE_GPP = g++
BARE_POLYORB = po_gnatdist
BARE_BLUETOOTHLIB = libbluetooth.a

CCOMPFLAG = -c
ADALIBS = -largs
ADA2005 = -gnat05
PRAGMA_CONF = -gnatec
BLUETOOTHSWITCHES = -lm -lbluetooth

PWD = $(shell pwd)

RM = rm

ARCH=arm-linux-gnueabihf-

ifeq ($(TARGET),arm)
	GCC = $(ARCH)$(BARE_GCC)
	GNAT = $(ARCH)$(BARE_GNAT)
	GPP = $(ARCH)$(BARE_GPP)
	POLYORB = $(ARCH)$(BARE_POLYORB)
	BLUETOOTHLIB = /usr/arm-linux-gnueabihf/lib/$(BARE_BLUETOOTHLIB)
else
	GCC = $(BARE_GCC)
	GNAT = $(BARE_GNAT)
	GPP = $(BARE_GPP)
	POLYORB = $(BARE_POLYORB)
	BLUETOOTHLIB = /usr/lib/x86_64-linux-gnu/$(BARE_BLUETOOTHLIB)
endif

c_interfaces: 	bytesconv.c i2c.c bluetooth.c
	$(GCC) $(CCOMPFLAG) bytesconv.c
	$(GCC) $(CCOMPFLAG) i2c.c
	$(GCC) $(CCOMPFLAG) bluetooth.c $(BLUETOOTHSWITCHES)
	$(GCC) $(CCOMPFLAG) lock_mem.c
	$(GCC) $(CCOMPFLAG) pre_fault.c


ada_packages: 	bytes.ads i2c_component.ads i2c_component.adb bluetooth_component.ads bluetooth_component.adb sensor_component.ads sensor_component.adb odometer_component.ads odometer_component.adb speedometer_component.ads speedometer_component.adb speed_controller_component.adb
	$(GCC) $(PRAGMA_CONF)$(PWD)/platoon.adc $(CCOMPFLAG) bytes.ads
	$(GCC) $(PRAGMA_CONF)$(PWD)/platoon.adc $(CCOMPFLAG) i2c_component.adb
	$(GCC) $(PRAGMA_CONF)$(PWD)/platoon.adc $(CCOMPFLAG) bluetooth_component.adb 
	$(GCC) $(PRAGMA_CONF)$(PWD)/platoon.adc $(CCOMPFLAG) sensor_component.adb	
	$(GCC) $(PRAGMA_CONF)$(PWD)/platoon.adc $(CCOMPFLAG) odometer_component.adb
	$(GCC) $(PRAGMA_CONF)$(PWD)/platoon.adc $(CCOMPFLAG) speedometer_component.adb
	$(GCC) $(PRAGMA_CONF)$(PWD)/platoon.adc $(CCOMPFLAG) speed_controller_component.adb



polyorb:	platoon.cfg
	$(POLYORB) platoon.cfg $(PRAGMA_CONF)$(PWD)/platoon.adc $(ADALIBS) lock_mem.o pre_fault.o bytesconv.o bluetooth.o i2c.o $(BLUETOOTHLIB)


all: c_interfaces ada_packages polyorb

clean:
	$(RM) *.o *.ali
	$(RM) -rf dsa
	$(RM) base foll_1 foll_2 lead

