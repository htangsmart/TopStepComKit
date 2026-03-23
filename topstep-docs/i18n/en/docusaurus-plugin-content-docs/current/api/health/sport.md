---
sidebar_position: 9
title: Sport
---

# Sport

The Sport module provides comprehensive management and synchronization of sport activity data from wearable devices. It enables retrieval of detailed metrics including distance, steps, calories, heart rate zones, and sport-specific measurements (swimming, jump rope, elliptical, rowing). The module supports multiple sport types and provides structured data models for analyzing athletic performance and health metrics.

## Prerequisites

- Device must support sport activity tracking and data synchronization
- User must have performed at least one sport activity on the device
- Device connectivity must be established before initiating data synchronization
- Timestamp parameters must be valid Unix timestamps (in seconds)

## Data Models

### TSSportModel

| Property | Type | Description |
|----------|------|-------------|
| `summary` | `TSSportSummaryModel *` | Summary information of the sport activity including statistics and performance metrics |
| `sportItems` | `NSArray<TSSportItemModel *> *` | Detailed metrics and measurements recorded during the activity |
| `heartRateItems` | `NSArray<TSHRValueItem *> *` | Heart rate measurements recorded throughout the activity |

### TSSportSummaryModel

| Property | Type | Description |
|----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp indicating when the activity started |
| `endTime` | `NSTimeInterval` | Unix timestamp indicating when the activity ended |
| `duration` | `double` | Total duration of the activity in seconds |
| `userID` | `NSString *` | Unique identifier for the user who performed the activity |
| `macAddress` | `NSString *` | MAC address of the recording device |
| `sportID` | `long` | Unique identifier for the sport activity session |
| `type` | `TSSportTypeEnum` | Type of sport activity performed |
| `steps` | `UInt32` | Total number of steps taken during the activity |
| `distance` | `UInt32` | Total distance covered in meters |
| `calorie` | `UInt32` | Total calories burned in calories |
| `maxHrValue` | `UInt8` | Highest heart rate recorded in BPM |
| `minHrValue` | `UInt8` | Lowest heart rate recorded in BPM |
| `avgHrValue` | `UInt8` | Average heart rate during the activity in BPM |
| `maxPace` | `float` | Highest pace recorded in seconds per kilometer |
| `minPace` | `float` | Lowest pace recorded in seconds per kilometer |
| `avgPace` | `float` | Average pace in seconds per kilometer |
| `maxSpeed` | `float` | Highest speed recorded in meters per second |
| `minSpeed` | `float` | Lowest speed recorded in meters per second |
| `avgSpeed` | `float` | Average speed in meters per second |
| `maxCadence` | `UInt8` | Highest cadence recorded in steps per minute |
| `minCadence` | `UInt8` | Lowest cadence recorded in steps per minute |
| `avgCadence` | `UInt8` | Average cadence in steps per minute |
| `warmHrDuration` | `UInt32` | Time spent in warm-up heart rate zone in seconds |
| `fatBurnHrDuration` | `UInt32` | Time spent in fat burning heart rate zone in seconds |
| `aerobicHrDuration` | `UInt32` | Time spent in aerobic heart rate zone in seconds |
| `anaerobicHrDuration` | `UInt32` | Time spent in anaerobic heart rate zone in seconds |
| `extremeHrDuration` | `UInt32` | Time spent in extreme heart rate zone in seconds |
| `warmHrRatio` | `UInt8` | Percentage of time in warm-up zone (0-100) |
| `fatBurnHrRatio` | `UInt8` | Percentage of time in fat burning zone (0-100) |
| `aerobicHrRatio` | `UInt8` | Percentage of time in aerobic zone (0-100) |
| `anaerobicHrRatio` | `UInt8` | Percentage of time in anaerobic zone (0-100) |
| `extremeHrRatio` | `UInt8` | Percentage of time in extreme zone (0-100) |
| `displayConfigs` | `NSData * _Nullable` | Bitmap of enabled display metrics (maximum 32 bytes) |

### TSSportDailyModel

| Property | Type | Description |
|----------|------|-------------|
| `sportRecords` | `NSArray<TSSportModel *> *` | Array of all sport activities performed during the day |
| `sportCount` | `NSUInteger` | Total number of sport activities performed |
| `totalDuration` | `NSTimeInterval` | Combined duration of all activities in seconds |
| `maxHeartRate` | `UInt8` | Highest heart rate recorded across all activities in BPM |
| `minHeartRate` | `UInt8` | Lowest heart rate recorded across all activities in BPM |

### TSSportItemModel

| Property | Type | Description |
|----------|------|-------------|
| `userID` | `NSString *` | Unique identifier for the user |
| `macAddress` | `NSString *` | MAC address of the recording device |
| `sportID` | `long` | Unique identifier for the sport activity session |
| `type` | `UInt16` | Type of sport activity |
| `distance` | `NSInteger` | Total distance covered in meters |
| `steps` | `NSInteger` | Total number of steps taken |
| `calories` | `NSInteger` | Total calories burned |
| `pace` | `NSInteger` | Current pace in seconds per kilometer |
| `cadence` | `NSInteger` | Step cadence in steps per minute |
| `speed` | `NSInteger` | Speed in meters per minute |
| `swimStyle` | `int` | Swimming style (1: Freestyle, 2: Breaststroke, 3: Backstroke, 4: Butterfly) |
| `swimLaps` | `int` | Total number of swimming laps completed |
| `swimStrokes` | `int` | Total number of swimming strokes |
| `swimStrokeFreq` | `int` | Swimming stroke frequency in strokes per minute |
| `swolf` | `int` | Swimming efficiency (SWOLF) score |
| `jumpCount` | `int` | Total number of successful jumps |
| `jumpBkCount` | `int` | Number of times rope skipping was interrupted |
| `jumpConsCount` | `int` | Highest number of consecutive jumps |
| `elCount` | `int` | Total number of elliptical strides |
| `elFrequecy` | `int` | Current elliptical stride frequency in strides per minute |
| `elMaxFrequecy` | `int` | Highest elliptical stride frequency in strides per minute |
| `elMinFrequecy` | `int` | Lowest elliptical stride frequency in strides per minute |
| `rowCount` | `int` | Total number of rowing strokes completed |
| `rowFrequecy` | `int` | Current rowing frequency in strokes per minute |
| `rowMaxFrequecy` | `int` | Highest rowing frequency in strokes per minute |
| `rowMinFrequecy` | `int` | Lowest rowing frequency in strokes per minute |

## Enumerations

### TSSportTypeEnum

| Value | Name | Description |
|-------|------|-------------|
| `0x01` | `TSSportTypeOutdoorCycling` | Outdoor Cycling |
| `0x05` | `TSSportTypeOutdoorRunning` | Outdoor Running |
| `0x09` | `TSSportTypeIndoorRunning` | Indoor Running |
| `0x0D` | `TSSportTypeOutdoorWalking` | Outdoor Walking |
| `0x11` | `TSSportTypeClimbing` | Climbing |
| `0x15` | `TSSportTypeBasketball` | Basketball |
| `0x19` | `TSSportTypeSwimming` | Swimming |
| `0x1D` | `TSSportTypeBadminton` | Badminton |
| `0x21` | `TSSportTypeFootball` | Football |
| `0x25` | `TSSportTypeElliptical` | Elliptical |
| `0x29` | `TSSportTypeYoga` | Yoga |
| `0x2D` | `TSSportTypePingPong` | Table Tennis |
| `0x31` | `TSSportTypeRopeSkipping` | Rope Skipping |
| `0x35` | `TSSportTypeRowing` | Rowing Machine |
| `0x39` | `TSSportTypeLazyBike` | Lazy Bike |
| `0x3D` | `TSSportTypeFitnessBike` | Fitness Bike |
| `0x41` | `TSSportTypeFreeTraining` | Free Training |
| `0x45` | `TSSportTypeTennis` | Tennis |
| `0x49` | `TSSportTypeBaseball` | Baseball |
| `0x4D` | `TSSportTypeRugby` | Rugby |
| `0x51` | `TSSportTypeCricket` | Cricket |
| `0x55` | `TSSportTypeFreeSports` | Free Sports |
| `0x59` | `TSSportTypeStrengthTraining` | Strength Training |
| `0x5D` | `TSSportTypeIndoorWalking` | Indoor Walking |
| `0x61` | `TSSportTypeIndoorCycling` | Indoor Cycling |
| `0x65` | `TSSportTypeDumbbell` | Dumbbell |
| `0x69` | `TSSportTypeDance` | Dance |
| `0x6D` | `TSSportTypeHulaHoop` | Hula Hoop |
| `0x71` | `TSSportTypeGolf` | Golf |
| `0x75` | `TSSportTypeLongJump` | Long Jump |
| `0x79` | `TSSportTypeSitUp` | Sit-up |
| `0x7D` | `TSSportTypeVolleyball` | Volleyball |
| `0x81` | `TSSportTypeParkour` | Parkour |
| `0x85` | `TSSportTypeHiking` | Hiking |
| `0x89` | `TSSportTypeHockey` | Hockey |
| `0x8D` | `TSSportTypeBoating` | Boating |
| `0x91` | `TSSportTypeHIIT` | High Intensity Interval Training |
| `0x95` | `TSSportTypeSoftball` | Softball |
| `0x99` | `TSSportTypeTrailRunning` | Trail Running |
| `0x9D` | `TSSportTypeSkiing` | Skiing |
| `0xA1` | `TSSportTypeTreadmill` | Treadmill |
| `0xA5` | `TSSportTypeRelaxation` | Relaxation |
| `0xA9` | `TSSportTypeCrossTraining` | Cross Training |
| `0xAD` | `TSSportTypePilates` | Pilates |
| `0xB1` | `TSSportTypeCrossMatch` | Cross Match |
| `0xB5` | `TSSportTypeFunctionalTraining` | Functional Training |
| `0xB9` | `TSSportTypePhysicalTraining` | Physical Training |
| `0xBD` | `TSSportTypeMixedCardio` | Mixed Cardio |
| `0xC1` | `TSSportTypeLatinDance` | Latin Dance |
| `0xC5` | `TSSportTypeStreetDance` | Street Dance |
| `0xC9` | `TSSportTypeFreeSparring` | Free Sparring |
| `0xCD` | `TSSportTypeBallet` | Ballet |
| `0xD1` | `TSSportTypeAustralianFootball` | Australian Football |
| `0xD5` | `TSSportTypeBowling` | Bowling |
| `0xD9` | `TSSportTypeSquash` | Squash |
| `0xDD` | `TSSportTypeCurling` | Curling |
| `0xE1` | `TSSportTypeSnowboarding` | Snowboarding |
| `0xE5` | `TSSportTypeFishing` | Fishing |
| `0xE9` | `TSSportTypeFrisbee` | Frisbee |
| `0xED` | `TSSportTypeAlpineSkiing` | Alpine Skiing |
| `0xF1` | `TSSportTypeCoreTraining` | Core Training |
| `0xF5` | `TSSportTypeSkating` | Skating |
| `0xF9` | `TSSportTypeFitnessGaming` | Fitness Gaming |
| `0xFD` | `TSSportTypeAerobics` | Aerobics |
| `0x0101` | `TSSportTypeGroupCallisthenics` | Group Calisthenics |
| `0x0105` | `TSSportTypeKickBoxing` | Kick Boxing |
| `0x0109` | `TSSportTypeFencing` | Fencing |
| `0x010D` | `TSSportTypeStairClimbing` | Stair Climbing |
| `0x0111` | `TSSportTypeAmericanFootball` | American Football |
| `0x0115` | `TSSportTypeFoamRolling` | Foam Rolling |
| `0x0119` | `TSSportTypePickleball` | Pickleball |
| `0x011D` | `TSSportTypeBoxing` | Boxing |
| `0x0121` | `TSSportTypeTaekwondo` | Taekwondo |
| `0x0125` | `TSSportTypeKarate` | Karate |
| `0x0129` | `TSSportTypeFlexibility` | Flexibility |
| `0x012D` | `TSSportTypeHandball` | Handball |
| `0x0131` | `TSSportTypeHandcar` | Handcar |
| `0x0135` | `TSSportTypeMeditation` | Meditation |
| `0x0139` | `TSSportTypeWrestling` | Wrestling |
| `0x013D` | `TSSportTypeStepping` | Stepping |
| `0x0141` | `TSSportTypeTaiChi` | Tai Chi |
| `0x0145` | `TSSportTypeGymnastics` | Gymnastics |
| `0x0149` | `TSSportTypeTrackAndField` | Track and Field |
| `0x014D` | `TSSportTypeMartialArts` | Martial Arts |
| `0x0151` | `TSSportTypeLeisureSports` | Leisure Sports |
| `0x0155` | `TSSportTypeSnowSports` | Snow Sports |
| `0x0159` | `TSSportTypeLacrosse` | Lacrosse |
| `0x015D` | `TSSportTypeHorizontalBar` | Horizontal Bar |
| `0x0161` | `TSSportTypeParallelBars` | Parallel Bars |
| `0x0165` | `TSSportTypeRollerSkating` | Roller Skating |
| `0x0169` | `TSSportTypeDarts` | Darts |
| `0x016D` | `TSSportTypeArchery` | Archery |
| `0x0171` | `TSSportTypeHorseRiding` | Horse Riding |
| `0x0175` | `TSSportTypeShuttlecock` | Shuttlecock |
| `0x0179` | `TSSportTypeIceHockey` | Ice Hockey |
| `0x017D` | `TSSportTypeAbdominalTraining` | Abdominal Training |
| `0x0181` | `TSSportTypeVO2MaxTest` | VO2 Max Test |
| `0x0185` | `TSSportTypeJudo` | Judo |
| `0x0189` | `TSSportTypeTrampolining` | Trampolining |
| `0x018D` | `TSSportTypeSkateboard` | Skateboard |
| `0x0191` | `TSSportTypeHoverBoard` | Hover Board |
| `0x0195` | `TSSportTypeInlineSkating` | Inline Skating |
| `0x0199` | `TSSportTypeTreadmillRunning` | Treadmill Running |
| `0x019D` | `TSSportTypeDiving` | Diving |
| `0x01A1` | `TSSportTypeSurfing` | Surfing |
| `0x01A5` | `TSSportTypeSnorkeling` | Snorkeling |
| `0x01A9` | `TSSportTypePullUp` | Pull-up |
| `0x01AD` | `TSSportTypePushUp` | Push-up |
| `0x01B1` | `TSSportTypePlank` | Plank |
| `0x01B5` | `TSSportTypeRockClimbing` | Rock Climbing |
| `0x01B9` | `TSSportTypeHighJump` | High Jump |
| `0x01BD` | `TSSportTypeBungeeJumping` | Bungee Jumping |
| `0x01C1` | `TSSportTypeNationalDance` | National Dance |
| `0x01C5` | `TSSportTypeHunting` | Hunting |
| `0x01C9` | `TSSportTypeShooting` | Shooting |
| `0x01CD` | `TSSportTypeMarathon` | Marathon |
| `0x01D1` | `TSSportTypeSpinningBike` | Spinning Bike |
| `0x01D5` | `TSSportTypePoolSwimming` | Pool Swimming |
| `0x01D9` | `TSSportTypeOpenWaterSwimming` | Open Water Swimming |
| `0x01DD` | `TSSportTypeBallroomDance` | Ballroom Dance |
| `0x01E1` | `TSSportTypeZumba` | Zumba |
| `0x01E5` | `TSSportTypeJazzDance` | Jazz Dance |
| `0x01E9` | `TSSportTypeStepMachine` | Step Machine |
| `0x01ED` | `TSSportTypeStairMachine` | Stair Machine |
| `0x01F1` | `TSSportTypeCroquet` | Croquet |
| `0x01F5` | `TSSportTypeWaterPolo` | Water Polo |
| `0x01F9` | `TSSportTypeWallBall` | Wall Ball |
| `0x01FD` | `TSSportTypeBilliards` | Billiards |
| `0x0201` | `TSSportTypeSepakTakraw` | Sepak Takraw |
| `0x0205` | `TSSportTypeStretching` | Stretching |
| `0x0209` | `TSSportTypeFreeGymnastics` | Free Gymnastics |
| `0x020D` | `TSSportTypeBarbell` | Barbell |
| `0x0211` | `TSSportTypeWeightlifting` | Weightlifting |
| `0x0215` | `TSSportTypeDeadlift` | Deadlift |
| `0x0219` | `TSSportTypeBurpee` | Burpee |
| `0x021D` | `TSSportTypeJumpingJack` | Jumping Jack |
| `0x0221` | `TSSportTypeUpperBodyTraining` | Upper Body Training |
| `0x0225` | `TSSportTypeLowerBodyTraining` | Lower Body Training |
| `0x0229` | `TSSportTypeBackTraining` | Back Training |
| `0x022D` | `TSSportTypeBeachBuggy` | Beach Buggy |
| `0x0231` | `TSSportTypeParagliding` | Paragliding |
| `0x0235` | `TSSportTypeFlyAKite` | Fly a Kite |
| `0x0239` | `TSSportTypeTugOfWar` | Tug of War |
| `0x023D` | `TSSportTypeTriathlon` | Triathlon |
| `0x0241` | `TSSportTypeSnowmobile` | Snowmobile |
| `0x0245` | `TSSportTypeSnowCar` | Snow Car |
| `0x0249` | `TSSportTypeSled` | Sled |
| `0x024D` | `TSSportTypeSkiBoard` | Ski Board |
| `0x0251` | `TSSportTypeCrossCountrySkiing` | Cross Country Skiing |
| `0x0255` | `TSSportTypeIndoorSkating` | Indoor Skating |
| `0x0259` | `TSSportTypeKabaddi` | Kabaddi |
| `0x025D` | `TSSportTypeMuayThai` | Muay Thai |
| `0x0261` | `TSSportTypeKickboxing` | Kickboxing |
| `0x0265` | `TSSportTypeRacing` | Racing |
| `0x0269` | `TSSportTypeIndoorFitness` | Indoor Fitness |
| `0x026D` | `TSSportTypeOutdoorSoccer` | Outdoor Soccer |
| `0x0271` | `TSSportTypeBellyDance` | Belly Dance |
| `0x0275` | `TSSportTypeSquareDance` | Square Dance |

### TSSportDisplayMetric

| Value | Name | Description |
|-------|------|-------------|
| `1` | `TSSportDisplayMetricDuration` | Duration |
| `2` | `TSSportDisplayMetricHeartRate` | Heart Rate |
| `3` | `TSSportDisplayMetricSteps` | Steps |
| `4` | `TSSportDisplayMetricDistance` | Distance |
| `5` | `TSSportDisplayMetricCalories` | Calories |
| `6` | `TSSportDisplayMetricAvgSpeed` | Average Speed |
| `7` | `TSSportDisplayMetricAvgPace` | Average Pace |
| `8` | `TSSportDisplayMetricAvgCadence` | Average Cadence |
| `9` | `TSSportDisplayMetricAvgStride` | Average Stride |
| `10` | `TSSportDisplayMetricTotalAscent` | Total Ascent |
| `11` | `TSSportDisplayMetricTotalDescent` | Total Descent |
| `12` | `TSSportDisplayMetricSwimLaps` | Swim Laps |
| `13` | `TSSportDisplayMetricSwimStrokes` | Swim Strokes |
| `14` | `TSSportDisplayMetricSwimStyle` | Swim Style |
| `15` | `TSSportDisplayMetricSwimStrokeRate` | Swim Stroke Rate |
| `16` | `TSSportDisplayMetricSwimEfficiency` | Swim Efficiency (SWOLF) |
| `17` | `TSSportDisplayMetricTriggerCount` | Trigger Count |
| `18` | `TSSportDisplayMetricTriggerRate` | Trigger Rate |
| `19` | `TSSportDisplayMetricInterruptionCount` | Interruption Count |
| `20` | `TSSportDisplayMetricContinuousCount` | Continuous Count |

## Callback Types

### Sport Data Synchronization Completion Block

```objc
void (^)(NSArray<TSSportModel *> *_Nullable sports, NSError *_Nullable error)
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `sports` | `NSArray<TSSportModel *> *` | Array of synchronized sport activities, or nil if error occurred |
| `error` | `NSError *` | Error object containing details if synchronization failed, or nil on success |

## API Reference

### Synchronize sport history data within a specified time range

Retrieves sport activity data from the device for activities that occurred between the specified start and end times.

```objc
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                             endTime:(NSTimeInterval)endTime
                          completion:(nonnull void (^)(NSArray<TSSportModel *> *_Nullable sports, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp (in seconds) for the beginning of the sync period |
| `endTime` | `NSTimeInterval` | Unix timestamp (in seconds) for the end of the sync period |
| `completion` | `void (^)(NSArray<TSSportModel *> *_Nullable, NSError *_Nullable)` | Callback block executed when synchronization completes |

**Code Example:**

```objc
// Get current date and date from 7 days ago
NSDate *endDate = [NSDate date];
NSDate *startDate = [endDate dateByAddingTimeInterval:-(7 * 24 * 60 * 60)];

NSTimeInterval startTime = [startDate timeIntervalSince1970];
NSTimeInterval endTime = [endDate timeIntervalSince1970];

id<TSSportInterface> sportInterface = (id<TSSportInterface>)kitManager.getService(TSServiceTypeSport);

[sportInterface syncHistoryDataFormStartTime:startTime
                                     endTime:endTime
                                  completion:^(NSArray<TSSportModel *> * _Nullable sports, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Sport sync failed: %@", error.localizedDescription);
        return;
    }
    
    for (TSSportModel *sport in sports) {
        TSLog(@"Sport Type: %ld, Duration: %.0f seconds", (long)sport.summary.type, sport.summary.duration);
        TSLog(@"Distance: %u m, Steps: %u", sport.summary.distance, sport.summary.steps);
        TSLog(@"Avg HR: %u BPM, Calories: %u", sport.summary.avgHrValue, sport.summary.calorie);
    }
}];
```

### Synchronize sport history data from a specified start time until now

Retrieves sport activity data from the device for all activities that occurred from the specified start time until the current moment.

```objc
- (void)syncHistoryDataFormStartTime:(NSTimeInterval)startTime
                          completion:(nonnull void (^)(NSArray<TSSportModel *> *_Nullable sports, NSError *_Nullable error))completion;
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `startTime` | `NSTimeInterval` | Unix timestamp (in seconds) for the beginning of the sync period |
| `completion` | `void (^)(NSArray<TSSportModel *> *_Nullable, NSError *_Nullable)` | Callback block executed when synchronization completes |

**Code Example:**

```objc
// Get timestamp for 30 days ago
NSDate *thirtyDaysAgo = [[NSDate date] dateByAddingTimeInterval:-(30 * 24 * 60 * 60)];
NSTimeInterval startTime = [thirtyDaysAgo timeIntervalSince1970];

id<TSSportInterface> sportInterface = (id<TSSportInterface>)kitManager.getService(TSServiceTypeSport);

[sportInterface syncHistoryDataFormStartTime:startTime
                                  completion:^(NSArray<TSSportModel *> * _Nullable sports, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Sport sync failed: %@", error.localizedDescription);
        return;
    }
    
    TSLog(@"Total activities synced: %lu", (unsigned long)sports.count);
    
    NSUInteger totalSteps = 0;
    NSUInteger totalDistance = 0;
    UInt8 maxHeartRate = 0;
    
    for (TSSportModel *sport in sports) {
        totalSteps += sport.summary.steps;
        totalDistance += sport.summary.distance;
        if (sport.summary.maxHrValue > maxHeartRate) {
            maxHeartRate = sport.summary.maxHrValue;
        }
    }
    
    TSLog(@"Total Steps: %lu, Total Distance: %lu m, Max HR: %u BPM",
          (unsigned long)totalSteps, (unsigned long)totalDistance, maxHeartRate);
}];
```

## Important Notes

1. **Timestamp `Format**`: All time parameters use Unix timestamps in seconds. Convert `NSDate` objects using `timeIntervalSince1970` property.

2. **Data Retrieval `Timing**`: Synchronization operations are asynchronous. Ensure device connectivity is established before initiating sync operations.

3. **Time Range `Validation**`: Verify that `startTime` is less than `endTime` to avoid unexpected behavior. The device will only return activities that fall within the specified time range.

4. **Heart Rate Zones `Calculation**`: The five heart rate zones are calculated based on user age and maximum heart rate formula `(220 - age)`. Verify user age is correctly set on the device for accurate zone classification.

5. **Sport-Specific `Metrics**`: Different sport types populate different metric fields. For example, swimming activities populate `swimStyle`, `swimLaps`, and `SWOLF` values, while jump rope activities use `jumpCount` and `jumpConsCount`.

6. **Display Metrics `Configuration**`: The `displayConfigs` bitmap in `TSSportSummaryModel` indicates which metrics the device is configured to display. Check `hasDisplayMetric:` before relying on specific metric availability.

7. **Heart Rate Data `Frequency**`: `heartRateItems` array may contain heart rate measurements at varying intervals depending on device firmware and activity type.

8. **Performance `Considerations**`: Large time ranges or devices with many activities may require extended synchronization time. Consider breaking up large date ranges into smaller chunks for better responsiveness.

9. **Pace `Units**`: Pace values are measured in seconds per kilometer (s/km). Convert to minutes per kilometer by dividing by 60.

10. **Summary vs. Detailed `Items**`: `TSSportSummaryModel` contains aggregated statistics, while `TSSportItemModel` array contains granular data points. Use summary data for overview displays and detailed items for in-depth analysis.