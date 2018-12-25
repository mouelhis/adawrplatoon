#define ADDRESS 0x04

int i2c_open_device();
int i2c_set_slave(int file_descriptor);
int i2c_write(int file_descriptor, uint8_t *command, int length);
int i2c_read(int file_descriptor, uint8_t *buffer, int length);
void i2c_close_device(int file_descriptor);
