with coursework; use coursework;
with Ada.Text_IO; use Ada.Text_IO;
procedure Main is

   stringInput : String(1..2);
   stringLast : Natural := 1;

   task Simulate;
   task Detect is
      pragma Priority(10);
   end Detect;

   task body Simulate is
   begin
      loop
         <<Start_Menu>>
         Put_Line("==========================================================================");
         Put_Line("Please select an option:");
         Put_Line("==========================================================================");
         Put_Line("---> (0) = Display car details");
         Put_Line("---> (1) = Toggle power");
         Put_Line("---> (2) = Change gears");
         Put_Line("---> (3) = Accelerate");
         Put_Line("---> (4) = Decelerate");
         Put_Line("---> (5) = Toggle Diagnostic Mode");
         Put_Line("---> (#) = Exit");
         Put_Line(" ");

         Get_Line(stringInput, stringLast);

         case stringInput(1) is
         when '0' =>
            Put_Line("==========================================================================");
            Put_Line(" ");
            Put_Line("--------------------- Car's Current State --------------------");
            Put_Line("   Battery Level ---> "& ElectricCar.Engine.BatteryLevel'Image &"%");
            Put_Line("   Gear ---> "& ElectricCar.Engine.Gear'Image);
            Put_Line("   Power ---> "& ElectricCar.Engine.Power'Image);
            Put_Line("   Speed ---> "& ElectricCar.Engine.Speed'Image &" mph");
            Put_Line(" ");

            Put_Line("--------------------- Additional Information --------------------");
            Put_Line("   Battery Warning Light ---> "& ElectricCar.Support.BatteryWarning'Image);
            Put_Line("   Diagnostic Mode ---> "& ElectricCar.Support.DiagnosticMode'Image);
            Put_Line("   Low Battery Level ---> "& ElectricCar.Support.LowBattery'Image &"%");
            Put_Line("   Minimum Battery Level ---> "& ElectricCar.Support.MinBattery'Image &"%");
            Put_Line("   Minimum Ditance ---> "& ElectricCar.Support.MinDistance'Image &"m");
            Put_Line("   Current Speed Limit ---> "& ElectricCar.Support.SpeedLimit'Image &" mph");
            Put_Line(" ");

            Put_Line("--------------------- Sensor Information --------------------");
            Put_Line("   Obstacle ---> "& ElectricCar.FrontSensor.SpecificObstacle'Image);

            if(ElectricCar.FrontSensor.SpecificObstacle = ABSENT)
            then
               Put_Line(" ");
               null;

            elsif(ElectricCar.FrontSensor.SpecificObstacle = PRESENT)
            then
               Put_Line("   Distance To Obstacle ---> "
                        & ElectricCar.FrontSensor.PresentObstacle.DistanceFromObstacle'Image &"m");
               Put_Line(" ");

            elsif(ElectricCar.FrontSensor.SpecificObstacle = OTHER_CAR)
            then
               Put_Line("   Distance To Other Car ---> "
                        & ElectricCar.FrontSensor.OtherCar.DistanceFromCar'Image &"m");
               Put_Line("   Other Car's Speed ---> "
                        & ElectricCar.FrontSensor.OtherCar.OtherCarSpeed'Image &" mph");
               Put_Line("   Other Car's Facing ---> "
                        & ElectricCar.FrontSensor.OtherCar.Facing'Image);
               Put_Line(" ");
            end if;

         when '1' =>
            if(ElectricCar.Engine.Power = On) then
               Put_Line("==========================================================================");
               Put_Line("Turning Electric Car Off...");

               PowerOff;
            elsif (ElectricCar.Engine.Power = Off) then
               Put_Line("==========================================================================");
               Put_Line("Turning Electric Car On...");

               PowerOn;
            end if;

         when '2' =>
            <<Select_Gear>>
            Put_Line("==========================================================================");
            Put_Line(" ");
            Put_Line("--------------------- Change Gears --------------------");
            Put_Line("Current Gear = " & ElectricCar.Engine.Gear'Image);
            Put_Line("---> (0) = Go up a gear");
            Put_Line("---> (1) = Go down a gear");
            Put_Line("---> (#) = Exit");
            Put_Line("==========================================================================");

            Put_Line(" ");

            Get_Line(stringInput, stringLast);

            case stringInput(1) is
               when '0' =>
                  MoveUpGear;
                  goto Select_Gear;

               when '1' =>
                  MoveDownGear;
                  goto Select_Gear;

               when '#' =>
                  goto Start_Menu;

               when others =>
                  goto Select_Gear;

            end case;

         when '3' =>
            <<Accelerate_Car>>
            Put_Line("==========================================================================");
            Put_Line(" ");
            Put_Line("--------------------- Accelerate --------------------");
            Put_Line("Current Speed = " & ElectricCar.Engine.Speed'Image &" mph");
            Put_Line("---> (0) = Accelerate by 1 mph");
            Put_Line("---> (1) = Accelerate by 5 mph");
            Put_Line("---> (2) = Accelerate by 10 mph");
            Put_Line("---> (3) = Accelerate by 25 mph");
            Put_Line("---> (4) = Accelerate by 50 mph");
            Put_Line("---> (#) = Exit to start menu");
            Put_Line("==========================================================================");
            Put_Line(" ");

            Get_Line(stringInput, stringLast);

            case stringInput(1) is
               when '0' =>
                  Accelerate(1);
                  goto Accelerate_Car;

               when '1' =>
                  Accelerate(5);
                  goto Accelerate_Car;

               when '2' =>
                  Accelerate(10);
                  goto Accelerate_Car;

               when '3' =>
                  Accelerate(25);
                  goto Accelerate_Car;

               when '4' =>
                  Accelerate(50);
                  goto Accelerate_Car;

               when '#' =>
                  goto Start_Menu;

               when others =>
                  goto Accelerate_Car;

            end case;

         when '4' =>
            <<Decelerate_Car>>
            Put_Line("==========================================================================");
            Put_Line(" ");
            Put_Line("--------------------- Decelerate --------------------");
            Put_Line("Current Speed = " & ElectricCar.Engine.Speed'Image &" mph");
            Put_Line("---> (0) = Decelerate by 1 mph");
            Put_Line("---> (1) = Decelerate by 5 mph");
            Put_Line("---> (2) = Decelerate by 10 mph");
            Put_Line("---> (3) = Decelerate by 25 mph");
            Put_Line("---> (4) = Decelerate by 50 mph");
            Put_Line("---> (#) = Exit to start menu");
            Put_Line("==========================================================================");

            Get_Line(stringInput, stringLast);

            case stringInput(1) is
               when '0' =>
                  Decelerate(1);
                  goto Decelerate_Car;

               when '1' =>
                  Decelerate(5);
                  goto Decelerate_Car;

               when '2' =>
                  Decelerate(10);
                  goto Decelerate_Car;

               when '3' =>
                  Decelerate(25);
                  goto Decelerate_Car;

               when '4' =>
                  Decelerate(50);
                  goto Decelerate_Car;

               when '#' =>
                  goto Start_Menu;

               when others =>
                  goto Decelerate_Car;

            end case;

            when '5' =>
               if(ElectricCar.Support.DiagnosticMode = Inactive) then
                  Put_Line("==========================================================================");
                  Put_Line("Turning Diagnostic Mode On...");

               elsif (ElectricCar.Support.DiagnosticMode = Active) then
                  Put_Line("==========================================================================");
                  Put_Line("Turning Diagnostic Mode Off...");

               end if;
               DiagnosticModeToggle;

            when '#' =>
               abort Detect;
            exit;

         when others =>
            Put_Line(" ");
            goto Start_Menu;
         end case;
      end loop;
   end Simulate;

   task body Detect is
   begin
      loop
         EmergencyStop;
         MatchSpeed;
         WarningLight;
         delay 0.5;
      end loop;
   end Detect;

begin
   null;
end Main;
