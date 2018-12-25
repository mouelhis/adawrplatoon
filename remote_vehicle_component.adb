with Ada.Text_IO; use Ada.Text_IO;

package body Remote_Vehicle_Component is   
   function Get_Identifier (V : in out Remote_Vehicle) return Integer is
   begin
      return V.Identifier;
   end Get_Identifier;
   
   procedure Set_Identifier (V : in out Remote_Vehicle; I : Integer) is
   begin
      V.Identifier := I;
   end Set_Identifier;
   
   procedure Set_Velocity (V : in out Remote_Vehicle; Vl : Float) is 
   begin
      V.Velocity := Vl;
   end Set_Velocity;
   
   procedure Emergency_Brake_Alarm (V : access Remote_Vehicle) is
   begin
      V.Brake_Alarm := True;
   end Emergency_Brake_Alarm;
   
   function Get_Velocity (V : in out Remote_Vehicle) return Float is 
   begin
      return V.Velocity;
   end Get_Velocity;
   
   function Brake_Alarm_Status (V : in out Remote_Vehicle) return Boolean is 
   begin
      return V.Brake_Alarm;
   end Brake_Alarm_Status;
end Remote_Vehicle_Component;
