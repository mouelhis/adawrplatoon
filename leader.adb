with System.Task_Info; use System.Task_Info;
with Ada.Streams.Stream_IO;
with Ada.Integer_Text_Io; use Ada.Integer_Text_Io;
with Ada.Task_Identification; use Ada.Task_Identification;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Exceptions;
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with Bytes; use Bytes;
with I2C_Component; use I2C_Component;
with Bluetooth_Component; use Bluetooth_Component;
with Sensor_Component; use Sensor_Component;
with Odometer_Component; use Odometer_Component;
with Speedometer_Component; use Speedometer_Component;
with Sensor_Component; use Sensor_Component;
with Speed_Controller_Component; use Speed_Controller_Component;
with Remote_Vehicle_Component; use Remote_Vehicle_Component;
with Base_Station_Component; use Base_Station_Component;
with Vehicle_Component; use Vehicle_Component;

procedure Leader is
   procedure Stack_Prefault;
   pragma Import (C, Stack_Prefault, "stack_prefault");
   
   procedure Lock_Mem;
   pragma Import (C, Lock_Mem, "lock_memory");
   
   pragma Priority(System.Priority'Last);
   pragma Warnings (Off);
   
   Period_MS : Integer := 100;
   
   
   I2C_Input : Unsigned_Uint8_Array_6;
   I2C_Output : Unsigned_Uint8_Array_2;
      
   Break : aliased Character;
   Trigger_Echo_Duration : aliased Integer; -- in micros
   Right_Interrupts, Left_Interrupts : aliased Integer;
      
   Follower_Identifier : Integer := 2; --fixed
   Follower_Remote_Instance : Base_Station_Component.Remote_Vehicle_Reference;
   
   Follower_2_Identifier : Integer := 3; --fixed
   Follower_2_Remote_Instance : Base_Station_Component.Remote_Vehicle_Reference;

   I2C_Connector : I2C_Component.I2C_Connector;
   Bluetooth_Connector : Bluetooth_Component.Bluetooth_Connector;
   Odometer : Odometer_Component.Access_Odometer := 
     new Odometer_Component.Odometer;
   
   
   -- Speedometer instance ...
   Speedometer : Speedometer_Component.Access_Speedometer := 
     new Speedometer_Component.Speedometer;
   Speed_Controller : Speed_Controller_Component.Access_Speed_Controller := 
     new Speed_Controller_Component.Speed_Controller;
   Sensor : Sensor_Component.Access_Sensor := 
     new Sensor_Component.Sensor;
   
   Identifier : Integer := 1; --fixed
   Instance : Vehicle_Component.Access_Vehicle := 
     new Vehicle_Component.Vehicle;  
   
   task RPi_Romeo_Data_Exchange is 
      pragma Priority(System.Priority'Last); 
   end RPi_Romeo_Data_Exchange; 
   
   
   task Update_Distance is
      pragma Priority(System.Priority'Last); 
   end Update_Distance; 
   
   task Update_Velocity is 
      pragma Priority(System.Priority'Last); 
   end Update_Velocity;
   
   task Update_Sensor_Data is 
      pragma Priority(System.Priority'Last); 
   end Update_Sensor_Data;
   
   task Send_Velocity_To_Follower_1  is 
      pragma Priority(System.Priority'Last); 
   end Send_Velocity_To_Follower_1;
   
   task Send_Velocity_To_Follower_2  is 
      pragma Priority(System.Priority'Last); 
   end Send_Velocity_To_Follower_2;
   
   task Autonomous_Speed_Control is 
      pragma Priority(System.Priority'Last); 
   end Autonomous_Speed_Control;
   
   task body RPi_Romeo_Data_Exchange is        
      Byte_0_Interrupts_Right : Unsigned_Integer_8; 
      Byte_1_Interrupts_Right : Unsigned_Integer_8;
      Byte_0_Interrupts_Left : Unsigned_Integer_8;  
      Byte_1_Interrupts_Left : Unsigned_Integer_8; 
      Byte_0_Trigger_Echo_Duration : Unsigned_Integer_8; 
      Byte_1_Trigger_Echo_Duration : Unsigned_Integer_8;
      
      
      Release : Ada.Real_Time.Time;
      Next : Ada.Real_Time.Time;
      Period_MS : Integer := 20;
      Period : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
      Deadline : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
   begin
      I2C_Connector.Connect;
      I2C_Connector.Acquire_Bus;
      
      -- Asynchronous function-based data exchange (periodic)      
      Next := Ada.Real_Time.Clock;     
      loop 
         Release := Ada.Real_Time.Clock;
         
         
         -- Send PWM and the I2C driving signal 
         I2C_Output(0) := Unsigned_Integer_8(Speed_Controller.all.Get_PWM_Command);
         I2C_Output(1) := Unsigned_Integer_8(Instance.Motor_Command);
         I2C_Connector.Send_Output_Data(I2C_Output,2);
         exit when Break = 'e';
         
         
         -- Read wheel encoder and sensor data
         I2C_Connector.Receive_Input_Data(6);
         I2C_Input := I2C_Connector.Get_Input_Data;
         Byte_0_Interrupts_Right := I2C_Input(0); 
         Byte_1_Interrupts_Right := I2C_Input(1);
         Byte_0_Interrupts_Left  := I2C_Input(2); 
         Byte_1_Interrupts_Left  := I2C_Input(3);
         Byte_0_Trigger_Echo_Duration  := I2C_Input(4); 
         Byte_1_Trigger_Echo_Duration  := I2C_Input(5);
         
         Right_Interrupts := 
           Integer(Concatenate_Bytes(Byte_0_Interrupts_Right, Byte_1_Interrupts_Right));
         Left_Interrupts := 
           Integer(Concatenate_Bytes(Byte_0_Interrupts_Left, Byte_1_Interrupts_Left));
         Trigger_Echo_Duration := 
           Integer(Concatenate_Bytes(Byte_0_Trigger_Echo_Duration, Byte_1_Trigger_Echo_Duration));
                       
         if Ada.Real_Time.Clock - Release > Deadline then 
            Put_Line("RPi_Romeo_Data_Exchange misses deadline !");
         end if;
         
         Next := Next + Period;
         delay until Next; 
      end loop;
      I2C_Connector.Disconnect;
   exception
      when I2C_Open_Connection_Failure => 
         Put_Line("I2C: Failed to access /dev/i2c-1 !");
      when I2C_Bus_Acquiring_Failure => 
         Put_Line("I2C: Failed to acquire bus access/talk to slave 0x04 !");
      when I2C_Sending_Failure =>
        Put_Line("Failure by sending data !");
      when I2C_Reading_Failure =>
        Put_Line("Failure by acquiring data !");
   end RPi_Romeo_Data_Exchange;
   
   task body Update_Distance is
      Period_MS : Integer := 40;
   begin
      Odometer.all.Initialize_Odometer;
      Odometer.all.Update_Distance(Period_MS, Break'Access, 
                                   Right_Interrupts'Access, Left_Interrupts'Access);
   end Update_Distance;
   
   task body Update_Velocity is
      Period_MS : Integer := 80;
   begin
      Speedometer.all.Initialize_Speedometer;
      Speedometer.all.Set_Odometer(Odometer);
      Speedometer.all.Update_Velocity(Period_MS, Break'Access);
   end Update_Velocity;
   
   task body Update_Sensor_Data is 
      Period_MS : Integer := 80;
   begin
      Sensor.all.Initialize_Sensor;
      Sensor.all.Update_Sensor_Data(Period_MS, Break'Access, Trigger_Echo_Duration'Access);
   end Update_Sensor_Data;
   
   
      
   task body Send_Velocity_To_Follower_1  is 
      Velocity : Float;
      Follower_Address : constant String := "B8:27:EB:DD:CB:B7";
      --Follower_Address : constant String := "B8:27:EB:81:CF:92";
      Release : Ada.Real_Time.Time;
      Next : Ada.Real_Time.Time;
      Period_MS : Integer := 80;
      Period : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
      Deadline : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
   begin
      Bluetooth_Connector.Initialize;
      Bluetooth_Connector.Make_Client_Connection(Follower_Address);
      
      Next := Ada.Real_Time.Clock;     
      loop 
         Release := Ada.Real_Time.Clock;
         exit when Break = 'e';
         
         Velocity := Speedometer.all.Get_Velocity;
         Bluetooth_Connector.Set_Data(Velocity);
         Bluetooth_Connector.Send_Data;
         
         --Put_Line ("Leader Velocity : " & Float'Image(Velocity));
         
         if Ada.Real_Time.Clock - Release > Deadline then 
            Put_Line("Bluetooth_Listener misses deadline !");
         end if;
         
         Next := Next + Period;
         delay until Next; 
      end loop;
      Bluetooth_Connector.Close_Connections;
   exception
      when Bluetooth_Client_Connection_Failure => 
         Put_Line ("Bluetooth: Failed to make client connection !");
      when Bluetooth_Client_Sending_Failure => 
         Put_Line ("Bluetooth: Failed to send data !");
   end Send_Velocity_To_Follower_1;
   
   
   task body Send_Velocity_To_Follower_2  is 
      Velocity : Float;
      --Follower_Address : constant String := "B8:27:EB:DD:CB:B7";
      Follower_Address : constant String := "B8:27:EB:81:CF:92";
      Release : Ada.Real_Time.Time;
      Next : Ada.Real_Time.Time;
      Period_MS : Integer := 80;
      Period : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
      Deadline : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
   begin
      Bluetooth_Connector.Initialize;
      Bluetooth_Connector.Make_Client_Connection(Follower_Address);
      
      Next := Ada.Real_Time.Clock;     
      loop 
         Release := Ada.Real_Time.Clock;
         exit when Break = 'e';
         
         Velocity := Speedometer.all.Get_Velocity;
         Bluetooth_Connector.Set_Data(Velocity);
         Bluetooth_Connector.Send_Data;
         
         --Put_Line ("Leader Velocity : " & Float'Image(Velocity));
         
         if Ada.Real_Time.Clock - Release > Deadline then 
            Put_Line("Bluetooth_Listener misses deadline !");
         end if;
         
         Next := Next + Period;
         delay until Next; 
      end loop;
      Bluetooth_Connector.Close_Connections;
   exception
      when Bluetooth_Client_Connection_Failure => 
         Put_Line ("Bluetooth: Failed to make client connection !");
      when Bluetooth_Client_Sending_Failure => 
         Put_Line ("Bluetooth: Failed to send data !");
   end Send_Velocity_To_Follower_2;

   -- Autonomous leader's speed control  
   task body Autonomous_Speed_Control is
      Period_MS : Integer := 80;
      Release : Ada.Real_Time.Time;
      Next : Ada.Real_Time.Time;
      Period : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
      Deadline : constant Ada.Real_Time.Time_Span := Milliseconds(Period_MS);
   begin
      Speed_Controller.all.Initialize_Speed_Controller;
      Speed_Controller.all.Set_Speedometer(Speedometer);
      Speed_Controller.all.Set_Sensor(Sensor);
      
      Follower_Remote_Instance := Base_Station_Component.Get_Remote_Instance (Follower_Identifier);
      Follower_2_Remote_Instance := Base_Station_Component.Get_Remote_Instance (Follower_2_Identifier);
      
      
      
      Next := Ada.Real_Time.Clock;  
      loop
         Release := Ada.Real_Time.Clock;
         if Speed_Controller.all.Get_Brake_Alarm = True then   
            -- Synchronous remote object method call 
            Follower_Remote_Instance.Emergency_Brake_Alarm;
            Follower_2_Remote_Instance.Emergency_Brake_Alarm;
            Instance.Emergency_Brake_Alarm;
         end if;
         exit when Break = 'e';
      
         -- Control the leader's speed 
         Speed_Controller.all.Autonomous_Speed_Control; 
         
         
         Put_Line(Speed_Controller.all.To_String);
         if Ada.Real_Time.Clock - Release > Deadline then 
            Put_Line("Speed_Control misses deadline !");
         end if;
         
         Next := Next + Period; 
         delay until Next;  
      end loop;
   end Autonomous_Speed_Control;

begin
   -- For real-time determinism 
   Lock_Mem;
   Stack_Prefault;
   
   Instance.Initialize_Vehicle;
   Instance.Set_Identifier(Identifier);
   Instance.Set_Speedometer(Speedometer);
   Base_Station_Component.Register_Vehicle(Identifier, 
                                           Base_Station_Component.Remote_Vehicle_Reference 
                                             (Instance));
   
   delay 2.0;
   Instance.Drive(Period_MS, Break);  
end Leader;
