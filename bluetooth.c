#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <bluetooth/bluetooth.h>
#include <bluetooth/rfcomm.h>
#include "bluetooth.h"

int bluetooth_output_connection(char *destination_address)
{
  struct sockaddr_rc address = { 0 };
  int socketfd, status;
  
  
  socketfd = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
  
  address.rc_family = AF_BLUETOOTH;
  address.rc_channel = (uint8_t) 1;
  str2ba(destination_address, &address.rc_bdaddr);

  status = connect(socketfd, (struct sockaddr *)&address, sizeof(address));
  
  if( status < 0 )
    return status;
  
  return socketfd;
}

int bluetooth_send_data(int socketfd, uint8_t *bytes){
  int status = write(socketfd, bytes, sizeof(float));
  return status;
}

void bluetooth_input_connection(int *socketfds){
  struct sockaddr_rc local_address = { 0 }, remote_address = { 0 };
  int socketfd, client_socketfd;
  socklen_t address_size = sizeof(remote_address);
    
  socketfd = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
  
  local_address.rc_family = AF_BLUETOOTH;
  local_address.rc_bdaddr = *BDADDR_ANY;
  local_address.rc_channel = (uint8_t) 1;
  bind(socketfd, (struct sockaddr *)&local_address, sizeof(local_address));
  
  listen(socketfd, 1);
  client_socketfd = accept(socketfd, (struct sockaddr *)&remote_address, &address_size);

  socketfds[0] = socketfd;
  socketfds[1] = client_socketfd;
}

int bluetooth_receive_data(int socketfd, uint8_t *bytes){
  int status = read(socketfd, bytes, sizeof(float));
  return status;
}

void bluetooth_close_connection(int socketfd){
  close(socketfd);
}
