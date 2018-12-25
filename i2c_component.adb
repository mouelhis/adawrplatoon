with Ada.Text_IO; use Ada.Text_IO;
package body I2C_Component is 
   procedure Initialize (I2C : in out I2C_Connector) is
   begin
      null;
   end Initialize;
   
   procedure Connect (I2C : in out I2C_Connector) is
   begin 
      I2C.File_Descriptor := I2C_Open_Device;
      if I2C.File_Descriptor < 0 then 
         raise I2C_Open_Connection_Failure;
      end if;
   end Connect;
   
   procedure Disconnect (I2C : in out I2C_Connector) is 
   begin
      I2C_Close_Device(I2C.File_Descriptor);
   end Disconnect;

   procedure Acquire_Bus (I2C : in out I2C_Connector) is
   begin
      if I2C_Set_Slave (I2C.File_Descriptor) < 0 then 
         raise I2C_Bus_Acquiring_Failure;
      end if;
   end Acquire_Bus;

   
   procedure Send_Output_Data (I2C : in out I2C_Connector; 
                               Data : Unsigned_Uint8_Array_2;
                               Size : Integer) is
   begin
      for I in Integer range 0 .. Size - 1 loop
         I2C.Output(I) := Data(I);
      end loop;    
      if I2C_Write_Uint8_2(I2C.File_Descriptor, I2C.Output, Size) /= Size then 
         raise I2C_Sending_Failure;
      end if;
   end Send_Output_Data;

   
   procedure Receive_Input_Data (I2C : in out I2C_Connector; Size : Integer) is 
   begin 
      if I2C_Read_Uint8_6(I2C.File_Descriptor, I2C.Input, Size) /= Size then
         raise I2C_Reading_Failure;
      end if;
   end Receive_Input_Data;
   
   
   function Get_Input_Data (I2C : in out I2C_Connector) return Unsigned_Uint8_Array_6 is 
   begin
      return I2C.Input;
   end Get_Input_Data;
end I2C_Component;
