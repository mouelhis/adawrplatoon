with Bytes; use Bytes;
with Ada.Text_IO; use Ada.Text_IO;

package body Bluetooth_Component is 
   procedure Initialize (BT : in out Bluetooth_Connector) is
   begin
      BT.Data := 0.0;
      BT.Socket_File_Descriptor := -1; 
      BT.Client_Socket_File_Descriptor := -1;
   end Initialize;
   
   procedure Set_Data (BT : in out Bluetooth_Connector; Data : Float) is 
   begin
      BT.Data := Data;
   end Set_Data;
      
   function Get_Data (BT : in out Bluetooth_Connector) return Float is 
   begin
      return BT.Data;
   end Get_Data;
     
   procedure Make_Client_Connection (BT : in out Bluetooth_Connector; Destination_Address : String) is
   begin
      BT.Socket_File_Descriptor := Bluetooth_Output_Connection(Destination_Address);
      if BT.Socket_File_Descriptor < 0 then 
         raise Bluetooth_Client_Connection_Failure;
      end if;
   end Make_Client_Connection;
   
   procedure Send_Data (BT : in out Bluetooth_Connector) is 
      Size : constant Integer := 4; -- Fixed (size of Float)
   begin
      Float_To_Bytes(BT.Data'Access, BT.Output_Bytes);
      if Bluetooth_Send_Data(BT.Socket_File_Descriptor, BT.Output_Bytes) /= Size 
      then 
         raise Bluetooth_Client_Sending_Failure;
      end if;
   end Send_Data;
   
   procedure Make_Listener (BT : in out Bluetooth_Connector) is 
      Socket_File_Descriptors : Socket_FD_Array;
   begin
      Socket_File_Descriptors(0) := 0;
      Socket_File_Descriptors(1) := 0;      
      Bluetooth_Input_Connection(Socket_File_Descriptors);
      if Socket_File_Descriptors(0) < 0 or Socket_File_Descriptors(1) < 0 then
         raise Bluetooth_Listener_Failure;
      end if;
      BT.Socket_File_Descriptor := Socket_File_Descriptors(0);
      BT.Client_Socket_File_Descriptor := Socket_File_Descriptors(1);
   end Make_Listener;
   
   
   procedure Receive_Data (BT : in out Bluetooth_Connector) is 
      Size : constant Integer := 4; -- Fixed (size of Float)
   begin
      if Bluetooth_Receive_Data(BT.Client_Socket_File_Descriptor, BT.Input_Bytes) /= Size then 
         raise Bluetooth_Listener_Receiving_Failure;
      end if;
      Bytes_To_Float (BT.Data'Access, BT.Input_Bytes);
   end Receive_Data;

   procedure Close_Connections (BT : in out Bluetooth_Connector) is 
   begin 
      Bluetooth_Close_Connection(BT.Socket_File_Descriptor);
      Bluetooth_Close_Connection(BT.Client_Socket_File_Descriptor);
   end Close_Connections;
end Bluetooth_Component;

