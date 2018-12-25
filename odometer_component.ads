with Ada.Numerics;
package Odometer_Component is
   Pi : constant := Ada.Numerics.Pi;
   type Odometer is tagged private;
   type Access_Odometer is access all Odometer;
   
   procedure Initialize_Odometer (O : in out Odometer);
   procedure Compute_Absolute_Distance (O : in out Odometer);
   function Get_Absolute_Distance (O : in Odometer) return Float;
   procedure Set_Right_Interrupts (O : in out Odometer; RI: Integer);
   procedure Set_Left_Interrupts (O : in out Odometer; LI: Integer);
   function To_String (O : in out Odometer) return String;
   procedure Update_Distance (O : in out Odometer;
                              Period_MS : Integer;
                              Abortion: access Character; 
                              RI, LI : access Integer);
   
   
private  
   type Odometer is tagged record 
      Right_Interrupts : Integer;
      Left_Interrupts : Integer;
      Absolute_Right_Distance : Float; -- in mm
      Absolute_Left_Distance : Float; -- in mm
      Absolute_Distance : Float; -- in mm
   end record;
   
   procedure Compute_Current_Absolute_Right_Distance (O : in out Odometer);
   procedure Compute_Current_Absolute_Left_Distance (O : in out Odometer);  
end Odometer_Component;
