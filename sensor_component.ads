with Ada.Real_Time; use Ada.Real_Time;
with Interfaces.C; use Interfaces.C;

package Sensor_Component is 
   type Sensor is tagged private;
   type Access_Sensor is access all Sensor;
      
   procedure Initialize_Sensor (S : in out Sensor);
   procedure Set_Duration (S: in out Sensor; D : Integer);
   function Get_Duration (S: in out Sensor) return Integer;
   function Get_Distance_From_Obstacle (S: in out Sensor) return Float;
   procedure Compute_Distance_From_Obstacle (S: in out Sensor);
   procedure Update_Sensor_Data (S : in out Sensor;
                                 Period_MS : Integer;
                                 Abortion: access Character; 
                                 D : access Integer);
   
private
   type Sensor is tagged record    
      Trigger_Echo_Duration : Integer;
      Distance_From_Obstacle : Float;
   end record;
end Sensor_Component;
