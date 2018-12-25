with Bytes; use Bytes;
with Remote_Vehicle_Component; use Remote_Vehicle_Component; 
with Speedometer_Component; use Speedometer_Component;

package Vehicle_Component is
   type Vehicle is new Remote_Vehicle_Component.Remote_Vehicle with private;
   type Access_Vehicle is access all Vehicle;
   
   procedure Initialize_Vehicle(V : in out Vehicle);
   
   -- Trick for remote calls
   procedure Set_Local_Velocity (V : in out Vehicle);
   procedure Set_Speedometer (V : in out Vehicle; S : Access_Speedometer);
   
    -- Motion functions
   function Move_Forward (V : in out Vehicle) return Integer;
   function Move_Backward (V : in out Vehicle) return Integer;
   function Move_Right (V : in out Vehicle) return Integer;
   function Move_Left (V : in out Vehicle) return Integer;
   function Brake (V : in out Vehicle) return Integer;
   
   function Motor_Command (V : in out Vehicle) return Integer;
   
   -- Jobs 
   procedure Drive (V : in out Vehicle; 
                    Period_MS : Integer;
                    Break : out Character);
private 
   type Vehicle is new Remote_Vehicle_Component.Remote_Vehicle with record
      Spd : Access_Speedometer;
      Motor_Command : Integer := 0;
   end record;
end Vehicle_Component;
