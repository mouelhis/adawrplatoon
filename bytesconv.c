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
#include "bytesconv.h"

uint16_t concatenate(uint8_t x, uint8_t y){
  return (x << 8) | y;
}

void float_to_bytes (float *data, uint8_t *bytes){
  memcpy(bytes, data, sizeof(float));
}

void bytes_to_float (float *data, uint8_t *bytes){
  memcpy(data, bytes, sizeof(float));
}
