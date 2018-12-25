with Remote_Vehicle_Component; use Remote_Vehicle_Component;

package Base_Station_Component is
   pragma Remote_Call_Interface;
   Max_Vehicles : constant Integer := 5;
   
   type Remote_Vehicle_Reference is access all Remote_Vehicle'Class;
   type Connected_Vehicles is array (0 .. Max_Vehicles) of Remote_Vehicle_Reference;
   
   procedure Register_Vehicle (Id : Integer; V : Remote_Vehicle_Reference);
   function Get_Remote_Instance (Id : Integer) return Remote_Vehicle_Reference;
   
   Illegal_Vehicle_Identifier : exception;
   Not_Connected_Vehicle : exception;
end Base_Station_Component;
