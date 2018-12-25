with Ada.Text_IO; use Ada.Text_IO;

package Bytes is 
   type Unsigned_Integer_8 is mod 2**8;
   type Unsigned_Integer_16 is mod 2**16;
   type Unsigned_Integer_32 is mod 2**32;
   type Unsigned_Uint8_Array_2 is array (0 .. 1) of Unsigned_Integer_8;
   type Unsigned_Uint8_Array_4 is array (0 .. 3) of Unsigned_Integer_8;
   type Unsigned_Uint8_Array_6 is array (0 .. 5) of Unsigned_Integer_8;
   
   package Unsigned_8_IO is new Ada.Text_IO.Modular_IO (Unsigned_Integer_8);
   package Unsigned_16_IO is new Ada.Text_IO.Modular_IO (Unsigned_Integer_16);
   package Unsigned_32_IO is new Ada.Text_IO.Modular_IO (Unsigned_Integer_32);
   
   function Concatenate_Bytes (X,Y : Unsigned_Integer_8) return Unsigned_Integer_16;
   pragma Import (C, Concatenate_Bytes, "concatenate");
   
   procedure Float_To_Bytes (Data : access Float; Bytes : Unsigned_Uint8_Array_4);
   pragma Import (C, Float_To_Bytes, "float_to_bytes");
   
   procedure Bytes_To_Float (Data : access Float; Bytes : Unsigned_Uint8_Array_4);
   pragma Import (C, Bytes_To_Float, "bytes_to_float");
end Bytes;
