with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;

package body Sensor_Component is
   procedure Initialize_Sensor (S : in out Sensor) is 
   begin
      S.Trigger_Echo_Duration := 0;
      S.Distance_From_Obstacle := 0.0;
   end Initialize_Sensor;
   
   
   procedure Set_Duration (S : in out Sensor; D : Integer) is 
   begin
      S.Trigger_Echo_Duration := D;
   end Set_Duration;

   function Get_Duration (S : in out Sensor) return Integer is
   begin
      return S.Trigger_Echo_Duration;
   end Get_Duration;
   
   function Get_Distance_From_Obstacle (S: in out Sensor) return Float is
   begin
      return S.Distance_From_Obstacle;
   end Get_Distance_From_Obstacle;
   
   procedure Compute_Distance_From_Obstacle (S: in out Sensor) is
   begin
      S.Distance_From_Obstacle := (Float(S.Trigger_Echo_Duration) / 58.0) * 10.0; -- in mm  
      -- (cf. HC-SR04 specification)
   end Compute_Distance_From_Obstacle;
   
   function To_String (S : in out Sensor) return String is 
   begin
      return
        "D_F_O:" & Float'Image(S.Distance_From_Obstacle) & " mm";
   end To_String;
   
   
   procedure Update_Sensor_Data  (S : in out Sensor;
                                  Period_MS : Integer;
                                  Abortion: access Character; 
                                  D : access Integer) is 
      Next : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
      Deadline : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
   begin
      Next := Ada.Real_Time.Clock;     
      loop 
         exit when Abortion.all = 'e';
         
         S.Set_Duration(D.all);
         S.Compute_Distance_From_Obstacle;
         
         --Put_Line("Current Sensor Information : " & S.To_String);
         if Ada.Real_Time.Clock - Next > Deadline then 
            Put_Line("Udpate_Sensor_Data misses deadline !");
         end if;
         
         Next := Next + Period;
         delay until Next; 
      end loop;  
   end Update_Sensor_Data;
end Sensor_Component;
