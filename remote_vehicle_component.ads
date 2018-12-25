with Interfaces.C; use Interfaces.C;

package Remote_Vehicle_Component is
   pragma Remote_Types;
   
   type Remote_Vehicle is tagged limited private; 
  
   -- Getter/Setter functions
   function Get_Identifier (V : in out Remote_Vehicle) return Integer;
   procedure Set_Identifier (V : in out Remote_Vehicle; I : Integer);
   procedure Set_Velocity (V : in out Remote_Vehicle; Vl : Float);
   
   procedure Emergency_Brake_Alarm (V : access Remote_Vehicle);
   function Get_Velocity (V : in out Remote_Vehicle) return Float;
   function Brake_Alarm_Status (V : in out Remote_Vehicle) return Boolean;
      
private 
   type Remote_Vehicle is tagged limited record
      Identifier : Integer := 0;
      Brake_Alarm : Boolean := False;
      -- Velocity for remote calls
      Velocity : Float := 0.0;
   end record;
end Remote_Vehicle_Component;
