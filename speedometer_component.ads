with Odometer_Component; use Odometer_Component;
package Speedometer_Component is
   type Speedometer is tagged private;
   type Access_Speedometer is access all Speedometer;
   
   procedure Initialize_Speedometer (S : in out Speedometer);
   procedure Set_Odometer (S : in out Speedometer; O : Access_Odometer);
   function Get_Velocity (S : in out Speedometer) return Float;
   procedure Compute_Velocity (S : in out Speedometer; Delta_Time : Integer);
   function To_String (S : in out Speedometer) return String;
   procedure Update_Velocity (S : in out Speedometer;
                              Period_MS : Integer;
                              Abortion: access Character);
   
   
   
private
   type Speedometer is tagged record 
      Odo : Access_Odometer;
      Previous_Absolute_Distance : Float; -- in mm
      Velocity : Float; -- in mm/ms
   end record;   
end Speedometer_Component;
