with Speedometer_Component; use Speedometer_Component;
with Sensor_Component; use Sensor_Component;

package Speed_Controller_Component is
   
   type Speed_Controller is tagged private;
   type Access_Speed_Controller is access all Speed_Controller;
   
   procedure Initialize_Speed_Controller (C : in out Speed_Controller);
   
   procedure Reach_Velocity_And_Stabilize (C : in out Speed_Controller);
   procedure Reach_Barrier_And_Stabilize (C : in out Speed_Controller; 
                                          Offset : Float;
                                          Predecessor_Velocity : Float);
     
   procedure Set_Speedometer  (C : in out Speed_Controller; S : Access_Speedometer);
   procedure Set_Sensor (C : in out Speed_Controller; S : Access_Sensor);
   procedure Set_Speed_Request (C : in out Speed_Controller; SR : Float);
     
   function Get_Speed_Request (C : in out Speed_Controller) return Float;   
   function Get_PWM_Command (C : in out Speed_Controller) return Integer;
   function Get_Brake_Alarm (C : in out Speed_Controller) return Boolean;
   
   
   function To_String (C : in out Speed_Controller) return String;
   
   
   procedure Dependent_Speed_Control (C : in out Speed_Controller; 
                                      Predecessor_Velocity : Float);
   procedure Autonomous_Speed_Control (C : in out Speed_Controller);
private
   type Speed_Controller is tagged record 
      Spd : Access_Speedometer;
      Sns : Access_Sensor;
      Speed_Request : Float; -- in mm/ms
      PWM_Command : Integer;
      Brake_Alarm : Boolean;
   end record;
   
   function Constrain_PWM (PWM : Integer) return Integer;
   function Constrain_Speed_Request (SR : Float) return Float;
   function Step_For_Distance_Error (Error : Float) return Integer; -- Fixed      
   function Step_For_Velocity_Error (Error : Float) return Integer; -- Fixed
end Speed_Controller_Component;
