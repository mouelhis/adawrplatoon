with Interfaces.C; use Interfaces.C;
with Bytes; use Bytes;

package Bluetooth_Component is 
   type Socket_FD_Array is array (0 .. 1) of Integer;
   type Bluetooth_Connector is tagged private;
   
   function Bluetooth_Output_Connection (Destination_Address : String) return Integer;
   pragma Import (C, Bluetooth_Output_Connection, "bluetooth_output_connection");
   
   function Bluetooth_Send_Data (Socket_File_Descriptor : Integer;
                                 Bytes : Unsigned_Uint8_Array_4) return Integer;
   pragma Import (C, Bluetooth_Send_Data, "bluetooth_send_data");
   
   procedure Bluetooth_Input_Connection (Socket_File_Descriptors : Socket_FD_Array);
   pragma Import (C, Bluetooth_Input_Connection, "bluetooth_input_connection");
   
   function Bluetooth_Receive_Data (Socket_File_Descriptor : Integer;
                                    Bytes : Unsigned_Uint8_Array_4) return Integer;
   pragma Import (C, Bluetooth_Receive_Data, "bluetooth_receive_data");
   
   procedure Bluetooth_Close_Connection (Socket_File_Descriptor : Integer);
   pragma Import (C, Bluetooth_Close_Connection, "bluetooth_close_connection");
   
   procedure Initialize (BT : in out Bluetooth_Connector);
   procedure Set_Data (BT : in out Bluetooth_Connector; Data : Float);
   function Get_Data (BT : in out Bluetooth_Connector) return Float;
   
   procedure Make_Client_Connection (BT : in out Bluetooth_Connector; Destination_Address : String);
   procedure Send_Data (BT : in out Bluetooth_Connector);
   
   procedure Make_Listener (BT : in out Bluetooth_Connector);
   procedure Receive_Data (BT : in out Bluetooth_Connector);
   
   procedure Close_Connections (BT : in out Bluetooth_Connector);
   
   Bluetooth_Client_Connection_Failure : exception;
   Bluetooth_Client_Sending_Failure : exception;
   Bluetooth_Listener_Failure : exception;
   Bluetooth_Listener_Receiving_Failure : exception;
private
   type Bluetooth_Connector is tagged record
      Data : aliased Float; -- In our context, exchanged data are floats
      Output_Bytes : Unsigned_Uint8_Array_4;   
      Input_Bytes : Unsigned_Uint8_Array_4;     
      Socket_File_Descriptor : Integer; 
      Client_Socket_File_Descriptor : Integer; -- For servers
   end record;
end Bluetooth_Component;

