with Ada.Text_IO; use Ada.Text_IO;

package body coursework with SPARK_Mode
is

   procedure PowerOn is
   begin
      if(ElectricCar.Engine.Power = Off and
         ElectricCar.Engine.Gear = ParkGear and
         ElectricCar.Engine.Speed = SpeedRange'First and
         ElectricCar.Engine.BatteryLevel > ElectricCar.Support.MinBattery)
      then
         ElectricCar.Engine.Power := On;
      end if;

   end;

   procedure PowerOff is
   begin
      if(ElectricCar.Engine.Power = On and
         ElectricCar.Engine.Gear = ParkGear and
         ElectricCar.Engine.Speed = SpeedRange'First and
         ElectricCar.Support.DiagnosticMode = Inactive)
      then
         ElectricCar.Engine.Power := Off;
      end if;

   end;

   procedure MoveUpGear is
   begin
      if(ElectricCar.Engine.Power = On and
         ElectricCar.Engine.Speed = SpeedRange'First and
         ElectricCar.Engine.Gear > Gears'First and
         ElectricCar.Support.DiagnosticMode = Inactive)
      then
         ElectricCar.Engine.Gear := Gears'Pred(ElectricCar.Engine.Gear);
      end if;

   end MoveUpGear;

   procedure MoveDownGear is
   begin
      if(ElectricCar.Engine.Power = On and
         ElectricCar.Engine.Speed = SpeedRange'First and
         ElectricCar.Engine.Gear < Gears'Last and
         ElectricCar.Support.DiagnosticMode = Inactive)
      then
         ElectricCar.Engine.Gear := Gears'Succ(ElectricCar.Engine.Gear);
      end if;
   end MoveDownGear;

   procedure Accelerate (newSpeed : in SpeedRange) is
   begin
      if(ElectricCar.Engine.Power = On
           and then ElectricCar.Engine.Speed + newSpeed <= ElectricCar.Support.SpeedLimit
           and then (ElectricCar.Engine.Gear = DriveGear or ElectricCar.Engine.Gear = ReverseGear)
           and then ElectricCar.Support.DiagnosticMode = Inactive
           and then ElectricCar.Engine.BatteryLevel > ElectricCar.Support.MinBattery
           and then newSpeed > 0
           and then newSpeed <= ElectricCar.Support.SpeedLimit

           and then (ElectricCar.FrontSensor.SpecificObstacle = ABSENT
               or (ElectricCar.FrontSensor.SpecificObstacle = PRESENT
                      and then not WithinStopDistance(ElectricCar.Engine.Speed,
                                                      ElectricCar.FrontSensor.PresentObstacle.DistanceFromObstacle))

               or (ElectricCar.FrontSensor.SpecificObstacle = OTHER_CAR
                     and then not WithinStopDistance(ElectricCar.Engine.Speed,
                                                     ElectricCar.FrontSensor.OtherCar.DistanceFromCar))))
      then
         ElectricCar.Engine.Speed := ElectricCar.Engine.Speed + newSpeed;
      end if;
   end Accelerate;

   procedure Decelerate (newSpeed : in SpeedRange) is
   begin
      if(ElectricCar.Engine.Power = On
           and (ElectricCar.Engine.Gear = DriveGear or ElectricCar.Engine.Gear = ReverseGear)
           and ElectricCar.Engine.Speed - newSpeed >= 0
           and ElectricCar.Engine.Speed > 0
           and ElectricCar.Support.DiagnosticMode = Inactive
           and newSpeed > 0)
      then
         ElectricCar.Engine.Speed := ElectricCar.Engine.Speed - newSpeed;
      end if;
   end Decelerate;

   procedure WarningLight is
   begin
      if(ElectricCar.Engine.Power = On
           and then (ElectricCar.Engine.Gear = DriveGear or ElectricCar.Engine.Gear = ReverseGear)
           and then ElectricCar.Engine.Speed > SpeedRange'First
           and then ElectricCar.Support.DiagnosticMode = Inactive
           and then ElectricCar.Engine.BatteryLevel <= ElectricCar.Support.LowBattery)
      then
         ElectricCar.Support.BatteryWarning := Lit;
      else
         ElectricCar.Support.BatteryWarning := Unlit;
      end if;
   end WarningLight;

   procedure DiagnosticModeToggle is
   begin
      if(ElectricCar.Engine.Power = On
           and ElectricCar.Engine.Gear = ParkGear
           and ElectricCar.Engine.Speed = SpeedRange'First
           and ElectricCar.Engine.BatteryLevel > ElectricCar.Support.LowBattery)
      then
         if(ElectricCar.Support.DiagnosticMode = Inactive) then
            ElectricCar.Support.DiagnosticMode := Active;
         else
            ElectricCar.Support.DiagnosticMode := Inactive;
         end if;
      end if;
   end DiagnosticModeToggle;

   function WithinStopDistance (speed : SpeedRange; distanceTo : DistanceRange) return Boolean is
      stopDistance : Float;
      floatDistanceTo : Float;
   begin
      stopDistance := ((Float(speed) * 0.44704) * 2.0);
      floatDistanceTo := Float(distanceTo);

      if (floatDistanceTo <= stopDistance) then
         return true;
      else
         return false;
      end if;
   end WithinStopDistance;

   procedure EmergencyStop is
   begin
      if (ElectricCar.Engine.Power = On
           and then ElectricCar.Engine.Gear = DriveGear
           and then ElectricCar.Engine.Speed > SpeedRange'First
           and then ElectricCar.Support.DiagnosticMode = Inactive)
           and then ((ElectricCar.FrontSensor.SpecificObstacle = PRESENT
                      and then WithinStopDistance(ElectricCar.Engine.Speed, ElectricCar.FrontSensor.PresentObstacle.DistanceFromObstacle))
                  or (ElectricCar.FrontSensor.SpecificObstacle = OTHER_CAR
                        and then ((ElectricCar.FrontSensor.OtherCar.Facing = Towards
                            and then   ElectricCar.FrontSensor.OtherCar.OtherCarSpeed >= SpeedRange'First)
                        or (ElectricCar.FrontSensor.OtherCar.Facing /= Towards
                            and then ElectricCar.FrontSensor.OtherCar.OtherCarSpeed = SpeedRange'First))
                        and then WithinStopDistance(ElectricCar.Engine.Speed, ElectricCar.FrontSensor.OtherCar.DistanceFromCar)))
      then
            ElectricCar.Engine.Speed := 0;
      end if;

   end EmergencyStop;

   procedure MatchSpeed is
   begin
      if(ElectricCar.Engine.Power = On
           and then ElectricCar.Engine.Gear = DriveGear
           and then ElectricCar.Engine.Speed > SpeedRange'First
           and then ElectricCar.Engine.Speed <= ElectricCar.Support.SpeedLimit
           and then ElectricCar.Support.DiagnosticMode = Inactive
           and then ElectricCar.FrontSensor.SpecificObstacle = OTHER_CAR
           and then ElectricCar.FrontSensor.OtherCar.Facing = Away
           and then ElectricCar.FrontSensor.OtherCar.OtherCarSpeed > SpeedRange'First
           and then ElectricCar.FrontSensor.OtherCar.OtherCarSpeed <= ElectricCar.Support.SpeedLimit
           and then ElectricCar.FrontSensor.OtherCar.DistanceFromCar <= ElectricCar.Support.MinDistance)
      then
         ElectricCar.Engine.Speed := ElectricCar.FrontSensor.OtherCar.OtherCarSpeed;
      end if;
   end MatchSpeed;
end coursework;






