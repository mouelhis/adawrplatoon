package body Base_Station_Component is      
   All_Vehicles : Connected_Vehicles;
   
   procedure Register_Vehicle (Id : Integer; V : Remote_Vehicle_Reference) is
   begin
      if Id >= 0 and Id <= Max_Vehicles then 
         All_Vehicles (Id) := V;
      else
         raise Illegal_Vehicle_Identifier;
      end if;
   end Register_Vehicle;
   
   function Get_Remote_Instance (Id : Integer) return Remote_Vehicle_Reference is
      LV : Remote_Vehicle_Reference;
   begin
      if Id >= 0 and Id <= Max_Vehicles then 
         LV := All_Vehicles (Id);
         if LV /= null then
            return All_Vehicles (Id);
         else
            raise Not_Connected_Vehicle;
         end if;
      else 
         raise Illegal_Vehicle_Identifier;
      end if;
   end Get_Remote_Instance;
end Base_Station_Component;
