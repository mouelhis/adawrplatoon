//sender program
int bluetooth_output_connection(char * destination_address);
int bluetooth_send_data(int socketfd, uint8_t *bytes);

//receiver program
void bluetooth_input_connection(int *socketfds);
int bluetooth_receive_data(int socketfd, uint8_t *bytes);

//close socket
void bluetooth_close_connection (int socketfd);
