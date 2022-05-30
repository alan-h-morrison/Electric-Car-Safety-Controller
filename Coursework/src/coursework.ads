with Ada.Text_IO; use Ada.Text_IO;

package coursework with SPARK_Mode
is
   type SpeedRange is range 0..200;
   type BatteryRange is range 0..100;
   type DistanceRange is range 1..500;

   type BatteryWarningLight is (Lit, Unlit);
   type ChargeState is (Engaged, Disengaged);
   type DiagnosticModeState is (Active, Inactive);
   type FacingType is (Away, Towards, Perpendicular);
   type Gears is (ParkGear, ReverseGear, DriveGear, NeutralGear);
   type ObstaclePresent is (PRESENT, ABSENT, OTHER_CAR);
   type PowerState is (On, Off);

   type EngineType is record
      BatteryLevel : BatteryRange;
      Gear : Gears;
      Power : PowerState;
      Speed : SpeedRange;
   end record;

   type SupportType is record
      BatteryWarning : BatteryWarningLight;
      DiagnosticMode : DiagnosticModeState;
      LowBattery : BatteryRange;
      MinBattery : BatteryRange;
      MinDistance: DistanceRange;
      SpeedLimit : SpeedRange;
   end record;

   type PresentObstacleType is record
      DistanceFromObstacle : DistanceRange;
   end record;

   type OtherCarType is record
      DistanceFromCar : DistanceRange;
      Facing : FacingType;
      OtherCarSpeed : SpeedRange;
   end record;

   type ObstacleType (SpecificObstacle : ObstaclePresent := ABSENT) is record
      case SpecificObstacle is
         when ABSENT =>  null;
         when OTHER_CAR => OtherCar: OtherCarType;
         when PRESENT =>  PresentObstacle: PresentObstacleType;
      end case;
   end record;

   type CarType is record
      Support : SupportType;
      Engine : EngineType;
      FrontSensor : ObstacleType;
   end record;

ElectricCar : CarType := (Support=>(BatteryWarning => Unlit,
                                          DiagnosticMode => Inactive,
                                          LowBattery => 20,
                                          MinBattery => 5,
                                          MinDistance => 10,
                                          SpeedLimit => 50),

                          Engine=>(BatteryLevel => 100,
                                  Gear => ParkGear,
                                  Power => Off,
                                  Speed => 0),

                          FrontSensor=>(SpecificObstacle=>ABSENT));

   procedure PowerOn with
     Global => (In_Out => ElectricCar),
     Pre => (ElectricCar.Engine.Power = Off
             and ElectricCar.Engine.Gear = ParkGear
             and ElectricCar.Engine.Speed = SpeedRange'First
             and ElectricCar.Engine.BatteryLevel > ElectricCar.Support.MinBattery),
     Post => ElectricCar.Engine.Power = On;

   procedure PowerOff with
     Global => (In_Out => ElectricCar),
     Pre => (ElectricCar.Engine.Power = On
             and ElectricCar.Engine.Gear = ParkGear
             and ElectricCar.Engine.Speed = SpeedRange'First
             and ElectricCar.Support.DiagnosticMode = Inactive),
     Post => ElectricCar.Engine.Power = Off;

   procedure MoveUpGear with
     Global=>(In_Out => ElectricCar),
     Pre => (ElectricCar.Engine.Power = On
             and ElectricCar.Engine.Gear > Gears'First
             and ElectricCar.Engine.Speed = SpeedRange'First
             and ElectricCar.Support.DiagnosticMode = Inactive),
     Post=> ElectricCar.Engine.Gear = Gears'Pred(ElectricCar.Engine.Gear'Old);

   procedure MoveDownGear with
     Global=>(In_Out => ElectricCar),
     Pre => (ElectricCar.Engine.Power = On
             and ElectricCar.Engine.Speed = SpeedRange'First
             and ElectricCar.Engine.Gear < Gears'Last
             and ElectricCar.Support.DiagnosticMode = Inactive),
     Post=> ElectricCar.Engine.Gear = Gears'Succ(ElectricCar.Engine.Gear'Old);

   procedure Accelerate (newSpeed : in SpeedRange) with
     Global=>(In_Out => ElectricCar),
     Pre=>(ElectricCar.Engine.Power = On
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
                                                     ElectricCar.FrontSensor.OtherCar.DistanceFromCar)))),

     Post => (ElectricCar.Engine.Speed <= ElectricCar.Support.SpeedLimit
              and ElectricCar.Engine.Speed > ElectricCar.Engine.Speed'Old);

   procedure Decelerate (newSpeed : in SpeedRange) with
     Global=>(In_Out => ElectricCar),
     Pre=>(ElectricCar.Engine.Power = On
           and (ElectricCar.Engine.Gear = DriveGear or ElectricCar.Engine.Gear = ReverseGear)
           and ElectricCar.Engine.Speed - newSpeed >= SpeedRange'First
           and ElectricCar.Engine.Speed > SpeedRange'First
           and ElectricCar.Support.DiagnosticMode = Inactive
           and newSpeed > SpeedRange'First),
     Post => (ElectricCar.Engine.Speed < ElectricCar.Engine.Speed'Old);

   procedure WarningLight with
     Global=>(In_Out => ElectricCar),
     Pre=>(ElectricCar.Engine.Power = On
           and (ElectricCar.Engine.Gear = DriveGear or ElectricCar.Engine.Gear = ReverseGear)
           and ElectricCar.Engine.Speed > SpeedRange'First
           and ElectricCar.Support.DiagnosticMode = Inactive
           and ElectricCar.Engine.BatteryLevel <= ElectricCar.Support.LowBattery),

     Contract_Cases => (ElectricCar.Engine.Power = On
                        and (ElectricCar.Engine.Gear = DriveGear or ElectricCar.Engine.Gear = ReverseGear)
                        and ElectricCar.Engine.Speed > SpeedRange'First
                        and ElectricCar.Support.DiagnosticMode = Inactive
                        and ElectricCar.Engine.BatteryLevel <= ElectricCar.Support.LowBattery =>
                            ElectricCar.Support.BatteryWarning = Lit,

                        others => ElectricCar.Support.BatteryWarning = Unlit);


   procedure DiagnosticModeToggle  with
     Global=>(In_Out => ElectricCar),
     Pre=>(ElectricCar.Engine.Power = On
           and ElectricCar.Engine.Gear = ParkGear
           and ElectricCar.Engine.Speed = SpeedRange'First
           and ElectricCar.Engine.BatteryLevel > ElectricCar.Support.LowBattery),
   Post=>(ElectricCar.Support.DiagnosticMode /= ElectricCar.Support.DiagnosticMode'Old);

    function WithinStopDistance (speed : SpeedRange; distanceTo : DistanceRange) return Boolean with
     Pre=>(speed >= SpeedRange'First
           and speed <= SpeedRange'Last
           and distanceTo >= DistanceRange'First and distanceTo <= DistanceRange'Last);

   procedure EmergencyStop with
     Global=>(In_Out => ElectricCar),
     Pre=>(ElectricCar.Engine.Power = On
           and then ElectricCar.Engine.Gear = DriveGear
           and then ElectricCar.Engine.Speed > SpeedRange'First
           and then ElectricCar.Support.DiagnosticMode = Inactive
           and then ((ElectricCar.FrontSensor.SpecificObstacle = PRESENT
                      and then WithinStopDistance(ElectricCar.Engine.Speed, ElectricCar.FrontSensor.PresentObstacle.DistanceFromObstacle))
                  or (ElectricCar.FrontSensor.SpecificObstacle = OTHER_CAR
                        and then ((ElectricCar.FrontSensor.OtherCar.Facing = Towards
                                   and then ElectricCar.FrontSensor.OtherCar.OtherCarSpeed >= SpeedRange'First)
                                 or (ElectricCar.FrontSensor.OtherCar.Facing /= Towards
                                     and then ElectricCar.FrontSensor.OtherCar.OtherCarSpeed = SpeedRange'First))
                        and then WithinStopDistance(ElectricCar.Engine.Speed, ElectricCar.FrontSensor.OtherCar.DistanceFromCar)))),
     Post=> ElectricCar.Engine.Speed = SpeedRange'First;

   procedure MatchSpeed with
     Global=>(In_Out => ElectricCar),
     Pre=>(ElectricCar.Engine.Power = On
           and then ElectricCar.Engine.Gear = DriveGear
           and then ElectricCar.Engine.Speed > SpeedRange'First
           and then ElectricCar.Engine.Speed <= ElectricCar.Support.SpeedLimit
           and then ElectricCar.Support.DiagnosticMode = Inactive
           and then ElectricCar.FrontSensor.SpecificObstacle = OTHER_CAR
           and then ElectricCar.FrontSensor.OtherCar.Facing = Away
           and then ElectricCar.FrontSensor.OtherCar.OtherCarSpeed > SpeedRange'First
           and then ElectricCar.FrontSensor.OtherCar.OtherCarSpeed <= ElectricCar.Support.SpeedLimit
           and then ElectricCar.FrontSensor.OtherCar.DistanceFromCar <= ElectricCar.Support.MinDistance),

     Post=> ElectricCar.Engine.Speed = ElectricCar.FrontSensor.OtherCar.OtherCarSpeed
     and ElectricCar.Engine.Speed > SpeedRange'First
     and ElectricCar.Engine.Speed <= ElectricCar.Support.SpeedLimit;

end coursework;
