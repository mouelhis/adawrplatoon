with Interfaces.C; use Interfaces.C;
with Bytes; use Bytes;

package I2C_Component is 
   type I2C_Connector is tagged private;
   type Access_I2C_Connector is access all I2C_Connector;
   
   function I2C_Open_Device return Integer;
   pragma Import (C, I2C_Open_Device, "i2c_open_device");
   
   procedure I2C_Close_Device(File_Descriptor : Integer);
   pragma Import (C, I2C_Close_Device, "i2c_close_device");
   
   function I2C_Set_Slave (File_Descriptor : Integer) return Integer;
   pragma Import (C, I2C_Set_Slave, "i2c_set_slave");
   
   function I2C_Write_Uint8_2 (File_Descriptor : Integer; 
                               Cmd : Unsigned_Uint8_Array_2; 
                               Len : Integer) 
                              return Integer;
   pragma Import (C, I2C_Write_Uint8_2, "i2c_write");
   
   function I2C_Write_Uint8_4 (File_Descriptor : Integer; 
                               Cmd : Unsigned_Uint8_Array_4; 
                               Len : Integer) 
                              return Integer;
   pragma Import (C, I2C_Write_Uint8_4, "i2c_write");
   
   function I2C_Read_Uint8_6 (File_Descriptor : Integer; 
                              Buf :  Unsigned_Uint8_Array_6; 
                              Len : Integer) 
                             return Integer;
   pragma Import (C, I2C_Read_Uint8_6, "i2c_read");
   
   function I2C_Read_Uint8_4 (File_Descriptor : Integer; 
                              Buf :  Unsigned_Uint8_Array_4; 
                              Len : Integer) 
                             return Integer;
   pragma Import (C, I2C_Read_Uint8_4, "i2c_read");  
   
   function I2C_Read_Uint8_2 (File_Descriptor : Integer; 
                              Buf:  Unsigned_Uint8_Array_2; 
                              Len : Integer) 
                             return Integer;
   pragma Import (C, I2C_Read_Uint8_2, "i2c_read");  
   
   
   
   procedure Initialize (I2C : in out I2C_Connector);
   procedure Connect (I2C : in out I2C_Connector);
   procedure Disconnect (I2C : in out I2C_Connector);
   procedure Acquire_Bus (I2C : in out I2C_Connector);
   procedure Send_Output_Data (I2C : in out I2C_Connector; 
                               Data : Unsigned_Uint8_Array_2;
                               Size : Integer);
   procedure Receive_Input_Data (I2C : in out I2C_Connector; 
                                 Size : Integer);
   function Get_Input_Data (I2C : in out I2C_Connector) return Unsigned_Uint8_Array_6;
   
   
   
   I2C_Open_Connection_Failure : exception; 
   I2C_Bus_Acquiring_Failure : exception;
   I2C_Sending_Failure : exception;
   I2C_Reading_Failure : exception;
     
private
   type I2C_Connector is tagged record       
      Output : Unsigned_Uint8_Array_2;   
      Input : Unsigned_Uint8_Array_6; --:= (others => Unsigned_Integer_8'First);    
      File_Descriptor : Integer; 
   end record;
end I2C_Component;
