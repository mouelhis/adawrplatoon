with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;


package body Speed_Controller_Component is
   Null_PWM : constant Integer := 0;
   Max_Speed : constant Float := 0.2;
   Inter_Vehicle_Safe_Distance : constant Float := 150.0;        
   Obstacle_Safe_Distance : constant Float := 150.0;
   
   
   procedure Initialize_Speed_Controller (C : in out Speed_Controller) is 
   begin
      C.Speed_Request := 0.0;
      C.PWM_Command := 0;
      C.Brake_Alarm := False;
   end Initialize_Speed_Controller;
   
   function Get_Speed_Request (C : in out Speed_Controller) return Float is 
   begin
      return C.Speed_Request;
   end Get_Speed_Request;
 
   function Get_PWM_Command (C : in out Speed_Controller) return Integer is 
   begin
      return C.PWM_Command;
   end Get_PWM_Command;
   
   function Get_Brake_Alarm (C : in out Speed_Controller) return Boolean is
   begin
      return C.Brake_Alarm;
   end Get_Brake_Alarm;
   
   procedure Set_Speedometer  (C : in out Speed_Controller; S : Access_Speedometer) is
   begin
      C.Spd := S;
   end Set_Speedometer;
   
   procedure Set_Sensor  (C : in out Speed_Controller; S : Access_Sensor) is
   begin
      C.Sns := S;
   end Set_Sensor;
   
   procedure Set_Speed_Request (C : in out Speed_Controller; SR : Float) is
   begin
      C.Speed_Request := SR;
   end Set_Speed_Request;
      
   procedure Reach_Velocity_And_Stabilize (C : in out Speed_Controller) is
      Current_Step : Integer;
      Velocity_Error : Float;
   begin 
      Velocity_Error := abs(C.Speed_Request) - abs(C.Spd.all.Get_Velocity);
      Current_Step := Step_For_Velocity_Error(abs(Velocity_Error));
      if Velocity_Error > 0.0 then 
         C.PWM_Command := Constrain_PWM(C.PWM_Command + Current_Step);
      elsif Velocity_Error < 0.0 then
         C.PWM_Command := Constrain_PWM(C.PWM_Command - Current_Step);
      end if;
   end Reach_Velocity_And_Stabilize;
   
   
   procedure Reach_Barrier_And_Stabilize (C : in out Speed_Controller; 
                                          Offset : Float; 
                                          Predecessor_Velocity : Float) is
      Distance_Error : Float;
      Step : Integer;
      Barrier : Float := Inter_Vehicle_Safe_Distance + Offset;
   begin      
      Distance_Error := abs(C.Sns.all.Get_Distance_From_Obstacle) - abs(Barrier);
      if Distance_Error >= 0.0 then 
         Step := Step_For_Distance_Error(abs(Distance_Error));
         C.PWM_Command := Constrain_PWM(C.PWM_Command + Step);
      else 
         Distance_Error := 
           abs(C.Sns.all.Get_Distance_From_Obstacle) - abs(Inter_Vehicle_Safe_Distance);
         if Distance_Error >= 0.0 then  
           C.Speed_Request := Predecessor_Velocity;
           C.Reach_Velocity_And_Stabilize;
         else
            C.PWM_Command := Constrain_PWM(50);
         end if; 
      end if;
   end Reach_Barrier_And_Stabilize;

   
   function To_String (C : in out Speed_Controller) return String is 
   begin
      return
        "DFL: " & Float'Image(C.Sns.all.Get_Distance_From_Obstacle) & " mm, " & 
        "SA: "  & Float'Image(C.Spd.all.Get_Velocity * 100.0) & " cm/s" &
        "SR:" & Float'Image(C.Speed_Request) & " mm/ms, " & 
        "PWM: "  & Integer'Image(C.PWM_Command);      
   end To_String;
   
   procedure Dependent_Speed_Control (C : in out Speed_Controller; 
                                      Predecessor_Velocity : Float) is
      Offset : Float := 300.0;
   begin    
      C.Reach_Barrier_And_Stabilize(Offset, Predecessor_Velocity);
   end Dependent_Speed_Control;
   
   
   procedure Autonomous_Speed_Control (C : in out Speed_Controller) is
      Distance_From_Obstacle : Float;
   begin      
 
      C.Speed_Request := 0.11;
      Distance_From_Obstacle := C.Sns.all.Get_Distance_From_Obstacle;
      if Distance_From_Obstacle < Inter_Vehicle_Safe_Distance and Distance_From_Obstacle > 0.0 then 
         C.Speed_Request := 0.0;
         C.PWM_Command := Null_PWM;
         C.Brake_Alarm := True;
      else
         -- Else, set the fixed control speed ...
         C.Reach_Velocity_And_Stabilize;
      end if; 
   end Autonomous_Speed_Control;
   
   
   function Constrain_PWM (PWM : Integer) return Integer is
   begin
      if PWM > 255 then 
         return 255;
      elsif  PWM < 50 then 
         return 50;
      else 
         return PWM;
      end if;
   end Constrain_PWM;
   
   function Constrain_Speed_Request (SR : Float) return Float is 
   begin
      if SR <= 0.0 then 
         return 0.0;
      else
         return SR;
      end if;
   end Constrain_Speed_Request;
   
   function Step_For_Velocity_Error (Error : Float) return Integer is 
   begin
      if Error > 0.1 then 
         return 6;
      elsif Error > 0.08 then 
         return 5; 
      elsif Error > 0.06 then 
         return 4; 
      elsif Error > 0.04 then
         return 3;
      elsif Error > 0.02 then
         return 2;
      else
         return 1;
      end if;
   end Step_For_Velocity_Error;
   
   function Step_For_Distance_Error (Error : Float) return Integer is 
      Max_Step : constant Integer := 3;
   begin
      if Error > 200.0 then
         return Max_Step;
      elsif Error > 150.0 then
         return Max_Step - 1;
      elsif Error > 100.0 then
         return Max_Step - 2;
      elsif Error > 50.0 then 
         return Max_Step - 3;
      else 
         return Max_Step - 3;
      end if;
   end Step_For_Distance_Error;
   
end Speed_Controller_Component;
