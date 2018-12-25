#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include "i2c.h"

static const char *devName = "/dev/i2c-1";

int i2c_open_device(){
  int file_descriptor = open(devName, O_RDWR);
  return file_descriptor;
}


int i2c_set_slave(int file_descriptor){
  int status = ioctl(file_descriptor, I2C_SLAVE, ADDRESS);
  return status;
}

int i2c_write(int file_descriptor, uint8_t *command, int length){
  int status = write(file_descriptor, command, length);
  return status;
}

int i2c_read(int file_descriptor, uint8_t *buffer, int length){
  int status = read(file_descriptor, buffer, length);
  return status;
}


void i2c_close_device(int file_descriptor){
  close(file_descriptor);
}

