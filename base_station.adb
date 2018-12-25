with System.Task_Info; use System.Task_Info;
procedure Base_Station is 
   pragma Priority(System.Priority'Last);
   
   procedure Stack_Prefault;
   pragma Import (C, Stack_Prefault, "stack_prefault");   
   procedure Lock_Mem;
   pragma Import (C, Lock_Mem, "lock_memory"); 
begin 
   Lock_Mem;
   Stack_Prefault;
end Base_Station;
