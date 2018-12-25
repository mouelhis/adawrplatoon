with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;

package body Vehicle_Component is   
   procedure Initialize_Vehicle (V : in out Vehicle) is
   begin
      null;
   end Initialize_Vehicle;
    
   procedure Set_Local_Velocity (V : in out Vehicle) is 
   begin
      V.Set_Velocity(V.Spd.all.Get_Velocity);
   end Set_Local_Velocity;
   
   procedure Set_Speedometer (V : in out Vehicle; S : Access_Speedometer) is
   begin
      V.Spd := S;
   end Set_Speedometer;
   
   function Move_Forward (V : in out Vehicle) return Integer is 
   begin
      return 1;
   end Move_Forward;
   
   function Move_Backward (V : in out Vehicle) return Integer is 
   begin 
      return 4;
   end Move_Backward;
   
   function Move_Right (V : in out Vehicle) return Integer is 
   begin 
      return 2;
   end Move_Right;
   
   function Move_Left (V : in out Vehicle) return Integer is 
   begin
      return 3;
   end Move_Left;

   function Brake (V : in out Vehicle) return Integer is
   begin
      return 0;
   end Brake;
   
   function Motor_Command (V : in out Vehicle) return Integer is 
   begin 
      return V.Motor_Command;
   end Motor_Command;
   
   procedure Drive (V : in out Vehicle; 
                    Period_MS : Integer;
                    Break : out Character) is
      Next : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
      Deadline : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
   begin
      V.Motor_Command := V.Move_Forward;
      Next := Ada.Real_Time.Clock;   
      loop 
         if V.Brake_Alarm_Status = True then 
            Break := 'e';
            V.Motor_Command := V.Brake;
         end if; 
         exit when Break = 'e';
         
         if Ada.Real_Time.Clock - Next > Deadline then 
            Put_Line("Drive misses deadline !");
         end if;
         
         Next := Next + Period;
         delay until Next;  
      end loop;  
   end Drive;
   
end Vehicle_Component;
