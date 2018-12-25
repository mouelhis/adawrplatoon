with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;

package body Speedometer_Component is 
   procedure Initialize_Speedometer (S : in out Speedometer) is 
   begin
      S.Previous_Absolute_Distance := 0.0;
      S.Velocity := 0.0;
   end Initialize_Speedometer;
   
   function Get_Velocity (S :in out Speedometer) return Float is 
   begin
      return S.Velocity;
   end Get_Velocity;
   
   
   procedure Set_Odometer (S :in out Speedometer; O : Access_Odometer) is 
   begin
      S.Odo := O;
   end Set_Odometer;
   
   procedure Compute_Velocity (S :in out Speedometer; Delta_Time : Integer) is
      Current_Absolute_Distance : Float;
      Delta_Absolute_Distance : Float;
   begin 
      Current_Absolute_Distance := S.Odo.all.Get_Absolute_Distance;
      Delta_Absolute_Distance := Current_Absolute_Distance - S.Previous_Absolute_Distance;
      S.Velocity := Delta_Absolute_Distance / Float(Delta_Time);
      S.Previous_Absolute_Distance := Current_Absolute_Distance;
   end Compute_Velocity;
   
   
   function To_String (S : in out Speedometer) return String is 
   begin
      return
        "V:" & Float'Image(S.Velocity) & " mm/ms"; 
   end To_String;
   
   procedure Update_Velocity (S : in out Speedometer;
                              Period_MS : Integer;
                              Abortion: access Character) is
      Next : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
      Deadline : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
   begin
      Next := Ada.Real_Time.Clock;     
      loop   
         exit when Abortion.all = 'e'; 
         
         S.Compute_Velocity(Period_MS);
         
         --Put_Line("Current Velocity Information : " & S.To_String);
         if Ada.Real_Time.Clock - Next > Deadline then 
            Put_Line("Update_Velocity misses deadline !");
         end if;
         
         Next := Next + Period;
         delay until Next;  
      end loop;
      
   end Update_Velocity;
end Speedometer_Component;
