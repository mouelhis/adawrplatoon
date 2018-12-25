with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;

package body Odometer_Component is
   procedure Initialize_Odometer (O : in out Odometer) is
   begin
      O.Right_Interrupts        := 0;
      O.Left_Interrupts         := 0;
      O.Absolute_Right_Distance := 0.0;
      O.Absolute_Left_Distance  := 0.0;
      O.Absolute_Distance       := 0.0;
   end Initialize_Odometer;
   
   procedure Compute_Absolute_Distance (O : in out Odometer) is 
   begin
      O.Compute_Current_Absolute_Right_Distance;
      O.Compute_Current_Absolute_Left_Distance;
      O.Absolute_Distance := 
        (O.Absolute_Right_Distance + O.Absolute_Left_Distance) / 2.0;
   end Compute_Absolute_Distance;
   
   function Get_Absolute_Distance (O : in Odometer) return Float is
   begin
      return O.Absolute_Distance;
   end  Get_Absolute_Distance;
   
   procedure Set_Right_Interrupts(O : in out Odometer; RI: Integer) is 
   begin 
      O.Right_Interrupts := RI;
   end Set_Right_Interrupts;
   
   procedure Set_Left_Interrupts(O : in out Odometer; LI: Integer) is 
   begin 
      O.Left_Interrupts := LI;
   end Set_Left_Interrupts;
   
   procedure Compute_Current_Absolute_Right_Distance (O : in out Odometer) is 
   begin
      O.Absolute_Right_Distance := ((Pi * 32.5) / 10.0) * Float(O.Right_Interrupts);
   end Compute_Current_Absolute_Right_Distance;
   
   procedure Compute_Current_Absolute_Left_Distance (O : in out Odometer) is 
   begin
      O.Absolute_Left_Distance := ((Pi * 32.5) / 10.0) * Float(O.Left_Interrupts);
   end Compute_Current_Absolute_Left_Distance;
   
   function To_String (O : in out Odometer) return String is 
   begin
      return
        "RI: "  & O.Right_Interrupts'Img & ", " & 
        "LI: "  & O.Left_Interrupts'Img & ", " &
        "ARD: " & Float'Image(O.Absolute_Right_Distance) & ", " &
        "ALD: " & Float'Image(O.Absolute_Left_Distance) & ", " &
        "AD: "  & Float'Image(O.Absolute_Distance) & " mm";
   end To_String;
   
   
   procedure Update_Distance (O : in out Odometer;
                              Period_MS : Integer;
                              Abortion: access Character; 
                              RI, LI : access Integer) is 
      Next : Ada.Real_Time.Time;
      Period, 
      Deadline : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
   begin
      Next := Ada.Real_Time.Clock;     
      loop 
         exit when Abortion.all = 'e';
         
         O.Set_Right_Interrupts(RI.all);
         O.Set_Left_Interrupts(LI.all);
         O.Compute_Absolute_Distance;
         
         
         --Put_Line("Current Distance Information : " & O.To_String);
         if Ada.Real_Time.Clock - Next > Deadline then 
            Put_Line("Update_Distance misses deadline !");
         end if;
         
         Next := Next + Period;
         delay until Next; 
      end loop;  
   end Update_Distance;
end Odometer_Component;
