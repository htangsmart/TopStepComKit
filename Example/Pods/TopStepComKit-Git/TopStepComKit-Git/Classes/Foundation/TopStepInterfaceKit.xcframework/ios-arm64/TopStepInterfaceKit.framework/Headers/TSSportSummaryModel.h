//
//  TSSportSummaryModel.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import "TSHealthValueModel.h"

/**
 * @brief Sport type enumeration
 * @chinese 运动类型枚举
 *
 * @discussion
 * [EN]: All supported sport types defined according to the FitCloud 2.0 protocol.
 * [CN]: 根据FitCloud 2.0协议定义的所有支持的运动类型。
 */
typedef NS_ENUM(NSInteger, TSSportType) {
    TSSportTypeOutdoorCycling     = 0x01,         // 户外骑行 Outdoor Cycling
    TSSportTypeOutdoorRunning     = 0x05,         // 户外跑步 Outdoor Running
    TSSportTypeIndoorRunning      = 0x09,         // 室内跑步 Indoor Running
    TSSportTypeOutdoorWalking     = 0x0D,         // 户外健走 Outdoor Walking
    TSSportTypeClimbing           = 0x11,         // 登山 Climbing
    TSSportTypeBasketball         = 0x15,         // 篮球 Basketball
    TSSportTypeSwimming           = 0x19,         // 游泳 Swimming
    TSSportTypeBadminton          = 0x1D,         // 羽毛球 Badminton
    TSSportTypeFootball           = 0x21,         // 足球 Football
    TSSportTypeElliptical         = 0x25,         // 椭圆机 Elliptical
    TSSportTypeYoga               = 0x29,         // 瑜伽 Yoga
    TSSportTypePingPong           = 0x2D,         // 乒乓球 Table Tennis
    TSSportTypeRopeSkipping       = 0x31,         // 跳绳 Rope Skipping
    TSSportTypeRowing             = 0x35,         // 划船机 Rowing Machine
    TSSportTypeLazyBike           = 0x39,         // 懒人车 Lazy Bike
    TSSportTypeFitnessBike        = 0x3D,         // 健身车 Fitness Bike
    TSSportTypeFreeTraining       = 0x41,         // 自由训练 Free Training
    TSSportTypeTennis             = 0x45,         // 网球 Tennis
    TSSportTypeBaseball           = 0x49,         // 棒球 Baseball
    TSSportTypeRugby              = 0x4D,         // 橄榄球 Rugby
    TSSportTypeCricket            = 0x51,         // 板球 Cricket
    TSSportTypeFreeSports         = 0x55,         // 自由运动 Free Sports
    TSSportTypeStrengthTraining   = 0x59,         // 力量训练 Strength Training
    TSSportTypeIndoorWalking      = 0x5D,         // 室内走路 Indoor Walking
    TSSportTypeIndoorCycling      = 0x61,         // 室内骑行 Indoor Cycling
    TSSportTypeDumbbell           = 0x65,         // 哑铃 Dumbbell
    TSSportTypeDance              = 0x69,         // 舞蹈 Dance
    TSSportTypeHulaHoop           = 0x6D,         // 呼啦圈 Hula Hoop
    TSSportTypeGolf               = 0x71,         // 高尔夫 Golf
    TSSportTypeLongJump           = 0x75,         // 跳远 Long Jump
    TSSportTypeSitUp              = 0x79,         // 仰卧起坐 Sit-up
    TSSportTypeVolleyball         = 0x7D,         // 排球 Volleyball
    TSSportTypeParkour            = 0x81,         // 跑酷 Parkour
    TSSportTypeHiking             = 0x85,         // 徒步 Hiking
    TSSportTypeHockey             = 0x89,         // 曲棍球 Hockey
    TSSportTypeBoating            = 0x8D,         // 划船 Boating
    TSSportTypeHIIT               = 0x91,         // HIIT High Intensity Interval Training
    TSSportTypeSoftball           = 0x95,         // 垒球 Softball
    TSSportTypeTrailRunning       = 0x99,         // 越野跑 Trail Running
    TSSportTypeSkiing             = 0x9D,         // 滑雪 Skiing
    TSSportTypeTreadmill          = 0xA1,         // 漫步机 Treadmill
    TSSportTypeRelaxation         = 0xA5,         // 整理放松 Relaxation
    TSSportTypeCrossTraining      = 0xA9,         // 交叉训练 Cross Training
    TSSportTypePilates            = 0xAD,         // 普拉提 Pilates
    TSSportTypeCrossMatch         = 0xB1,         // 交叉配合 Cross Match
    TSSportTypeFunctionalTraining = 0xB5,         // 功能性训练 Functional Training
    TSSportTypePhysicalTraining   = 0xB9,         // 体能训练 Physical Training
    TSSportTypeMixedCardio        = 0xBD,         // 混合有氧 Mixed Cardio
    TSSportTypeLatinDance         = 0xC1,         // 拉丁舞 Latin Dance
    TSSportTypeStreetDance        = 0xC5,         // 街舞 Street Dance
    TSSportTypeFreeSparring       = 0xC9,         // 自由搏击 Free Sparring
    TSSportTypeBallet             = 0xCD,         // 芭蕾 Ballet
    TSSportTypeAustralianFootball = 0xD1,         // 澳式足球 Australian Football
    TSSportTypeBowling            = 0xD5,         // 保龄球 Bowling
    TSSportTypeSquash             = 0xD9,         // 壁球 Squash
    TSSportTypeCurling            = 0xDD,         // 冰壶 Curling
    TSSportTypeSnowboarding       = 0xE1,         // 单板滑雪 Snowboarding
    TSSportTypeFishing            = 0xE5,         // 钓鱼 Fishing
    TSSportTypeFrisbee            = 0xE9,         // 飞盘 Frisbee
    TSSportTypeAlpineSkiing       = 0xED,         // 高山滑雪 Alpine Skiing
    TSSportTypeCoreTraining       = 0xF1,         // 核心训练 Core Training
    TSSportTypeSkating            = 0xF5,         // 滑冰 Skating
    TSSportTypeFitnessGaming      = 0xF9,         // 健身游戏 Fitness Gaming
    TSSportTypeAerobics           = 0xFD,         // 健身操 Aerobics
    TSSportTypeGroupCallisthenics = 0x0101,       // 团体操 Group Calisthenics
    TSSportTypeKickBoxing         = 0x0105,       // 搏击操 Kick Boxing
    TSSportTypeFencing            = 0x0109,       // 击剑 Fencing
    TSSportTypeStairClimbing      = 0x010D,       // 爬楼 Stair Climbing
    TSSportTypeAmericanFootball   = 0x0111,       // 美式橄榄球 American Football
    TSSportTypeFoamRolling        = 0x0115,       // 泡沫轴筋膜放松 Foam Rolling
    TSSportTypePickleball         = 0x0119,       // 匹克球 Pickleball
    TSSportTypeBoxing             = 0x011D,       // 拳击 Boxing
    TSSportTypeTaekwondo          = 0x0121,       // 跆拳道 Taekwondo
    TSSportTypeKarate             = 0x0125,       // 空手道 Karate
    TSSportTypeFlexibility        = 0x0129,       // 柔韧度 Flexibility
    TSSportTypeHandball           = 0x012D,       // 手球 Handball
    TSSportTypeHandcar            = 0x0131,       // 手摇车 Handcar
    TSSportTypeMeditation         = 0x0135,       // 舒缓冥想类运动 Meditation
    TSSportTypeWrestling          = 0x0139,       // 摔跤 Wrestling
    TSSportTypeStepping           = 0x013D,       // 踏步 Stepping
    TSSportTypeTaiChi             = 0x0141,       // 太极 Tai Chi
    TSSportTypeGymnastics         = 0x0145,       // 体操 Gymnastics
    TSSportTypeTrackAndField      = 0x0149,       // 田径 Track and Field
    TSSportTypeMartialArts        = 0x014D,       // 武术 Martial Arts
    TSSportTypeLeisureSports      = 0x0151,       // 休闲运动 Leisure Sports
    TSSportTypeSnowSports         = 0x0155,       // 雪上运动 Snow Sports
    TSSportTypeLacrosse           = 0x0159,       // 长曲棍球 Lacrosse
    TSSportTypeHorizontalBar      = 0x015D,       // 单杠 Horizontal Bar
    TSSportTypeParallelBars       = 0x0161,       // 双杠 Parallel Bars
    TSSportTypeRollerSkating      = 0x0165,       // 轮滑 Roller Skating
    TSSportTypeDarts              = 0x0169,       // 飞镖 Darts
    TSSportTypeArchery            = 0x016D,       // 射箭 Archery
    TSSportTypeHorseRiding        = 0x0171,       // 骑马 Horse Riding
    TSSportTypeShuttlecock        = 0x0175,       // 毽球 Shuttlecock
    TSSportTypeIceHockey          = 0x0179,       // 冰球 Ice Hockey
    TSSportTypeAbdominalTraining  = 0x017D,       // 腰腹训练 Abdominal Training
    TSSportTypeVO2MaxTest         = 0x0181,       // 最大摄氧量测试 VO2 Max Test
    TSSportTypeJudo               = 0x0185,       // 柔道 Judo
    TSSportTypeTrampolining       = 0x0189,       // 蹦床 Trampolining
    TSSportTypeSkateboard         = 0x018D,       // 滑板 Skateboard
    TSSportTypeHoverBoard         = 0x0191,       // 平衡车 Hover Board
    TSSportTypeInlineSkating      = 0x0195,       // 溜旱冰 Inline Skating
    TSSportTypeTreadmillRunning   = 0x0199,       // 跑步机 Treadmill Running
    TSSportTypeDiving             = 0x019D,       // 跳水 Diving
    TSSportTypeSurfing            = 0x01A1,       // 冲浪 Surfing
    TSSportTypeSnorkeling         = 0x01A5,       // 浮潜 Snorkeling
    TSSportTypePullUp             = 0x01A9,       // 引体向上 Pull-up
    TSSportTypePushUp             = 0x01AD,       // 俯卧撑 Push-up
    TSSportTypePlank              = 0x01B1,       // 平板支撑 Plank
    TSSportTypeRockClimbing       = 0x01B5,       // 攀岩 Rock Climbing
    TSSportTypeHighJump           = 0x01B9,       // 跳高 High Jump
    TSSportTypeBungeeJumping      = 0x01BD,       // 蹦极 Bungee Jumping
    TSSportTypeNationalDance      = 0x01C1,       // 民族舞 National Dance
    TSSportTypeHunting            = 0x01C5,       // 打猎 Hunting
    TSSportTypeShooting           = 0x01C9,       // 射击 Shooting
    TSSportTypeMarathon           = 0x01CD,       // 马拉松 Marathon
    TSSportTypeSpinningBike       = 0x01D1,       // 动感单车 Spinning Bike
    TSSportTypePoolSwimming       = 0x01D5,       // 泳池游泳 Pool Swimming
    TSSportTypeOpenWaterSwimming  = 0x01D9,       // 开放水域游泳 Open Water Swimming
    TSSportTypeBallroomDance      = 0x01DD,       // 交际舞 Ballroom Dance
    TSSportTypeZumba              = 0x01E1,       // 尊巴 Zumba
    TSSportTypeJazzDance          = 0x01E5,       // 爵士舞 Jazz Dance
    TSSportTypeStepMachine        = 0x01E9,       // 踏步机 Step Machine
    TSSportTypeStairMachine       = 0x01ED,       // 爬楼机 Stair Machine
    TSSportTypeCroquet            = 0x01F1,       // 门球 Croquet
    TSSportTypeWaterPolo          = 0x01F5,       // 水球 Water Polo
    TSSportTypeWallBall           = 0x01F9,       // 墙球 Wall Ball
    TSSportTypeBilliards          = 0x01FD,       // 台球 Billiards
    TSSportTypeSepakTakraw        = 0x0201,       // 藤球 Sepak Takraw
    TSSportTypeStretching         = 0x0205,       // 拉伸 Stretching
    TSSportTypeFreeGymnastics     = 0x0209,       // 自由体操 Free Gymnastics
    TSSportTypeBarbell            = 0x020D,       // 杠铃 Barbell
    TSSportTypeWeightlifting      = 0x0211,       // 举重 Weightlifting
    TSSportTypeDeadlift           = 0x0215,       // 硬拉 Deadlift
    TSSportTypeBurpee             = 0x0219,       // 波比跳 Burpee
    TSSportTypeJumpingJack        = 0x021D,       // 开合跳 Jumping Jack
    TSSportTypeUpperBodyTraining  = 0x0221,       // 上肢训练 Upper Body Training
    TSSportTypeLowerBodyTraining  = 0x0225,       // 下肢训练 Lower Body Training
    TSSportTypeBackTraining       = 0x0229,       // 背部训练 Back Training
    TSSportTypeBeachBuggy         = 0x022D,       // 沙滩车 Beach Buggy
    TSSportTypeParagliding        = 0x0231,       // 滑翔伞 Paragliding
    TSSportTypeFlyAKite           = 0x0235,      // 放风筝 Fly a Kite
    TSSportTypeTugOfWar           = 0x0239,       // 拔河 Tug of War
    TSSportTypeTriathlon          = 0x023D,       // 铁人三项 Triathlon
    TSSportTypeSnowmobile         = 0x0241,       // 雪地摩托 Snowmobile
    TSSportTypeSnowCar            = 0x0245,       // 雪车 Snow Car
    TSSportTypeSled               = 0x0249,       // 雪橇 Sled
    TSSportTypeSkiBoard           = 0x024D,       // 滑雪板 Ski Board
    TSSportTypeCrossCountrySkiing = 0x0251,       // 越野滑雪 Cross Country Skiing
    TSSportTypeIndoorSkating      = 0x0255,       // 室内滑冰 Indoor Skating
    TSSportTypeKabaddi            = 0x0259,       // 卡巴迪 Kabaddi
    TSSportTypeMuayThai           = 0x025D,       // 泰拳 Muay Thai
    TSSportTypeKickboxing         = 0x0261,       // 踢拳 Kickboxing
    TSSportTypeRacing             = 0x0265,       // 赛车 Racing
    TSSportTypeIndoorFitness      = 0x0269,       // 室内健身 Indoor Fitness
    TSSportTypeOutdoorSoccer      = 0x026D,       // 户外足球 Outdoor Soccer
    TSSportTypeBellyDance         = 0x0271,       // 肚皮舞 Belly Dance
    TSSportTypeSquareDance        = 0x0275,       // 广场舞 Square Dance
};


NS_ASSUME_NONNULL_BEGIN

@interface TSSportSummaryModel : TSHealthValueModel

/**
 * @brief User identifier
 * @chinese 用户标识符
 *
 * @discussion
 * [EN]: Unique identifier for the user who performed the sport activity.
 * [CN]: 进行运动活动的用户的唯一标识符。
 */
@property (nonatomic, strong) NSString *userID;

/**
 * @brief Device MAC address
 * @chinese 设备MAC地址
 *
 * @discussion
 * [EN]: MAC address of the device that recorded the sport activity.
 * [CN]: 记录运动活动的设备的MAC地址。
 */
@property (nonatomic, strong) NSString *macAddress;

/**
 * @brief Sport activity identifier
 * @chinese 运动活动标识符
 *
 * @discussion
 * [EN]: Unique identifier for the sport activity session.
 * [CN]: 运动活动会话的唯一标识符。
 */
@property (nonatomic, assign) long sportID;

/**
 * @brief Type of sport activity
 * @chinese 运动活动类型
 *
 * @discussion
 * [EN]: The type of sport activity (e.g., running, cycling, swimming).
 * [CN]: 运动活动的类型（如跑步、骑行、游泳）。
 */
@property (nonatomic, assign) TSSportType type;

/**
 * @brief Step count during activity
 * @chinese 活动期间步数
 *
 * @discussion
 * [EN]: The total number of steps taken during the sport activity.
 * [CN]: 运动活动期间的总步数。
 */
@property (nonatomic, assign) UInt8 steps;

/**
 * @brief Distance covered during activity
 * @chinese 活动期间距离
 *
 * @discussion
 * [EN]: The total distance covered during the sport activity, in meters.
 * [CN]: 运动活动期间的总距离，以米为单位。
 */
@property (nonatomic, assign) UInt8 distance;

/**
 * @brief Calories burned during activity
 * @chinese 活动期间消耗的卡路里
 *
 * @discussion
 * [EN]: The total calories burned during the sport activity, in calories.
 * [CN]: 运动活动期间消耗的总卡路里，以小卡卡为单位。
 */
@property (nonatomic, assign) UInt8 calorie;

/**
 * @brief Maximum heart rate during activity
 * @chinese 活动期间最大心率
 *
 * @discussion
 * [EN]: The highest heart rate recorded during the sport activity, in BPM.
 * [CN]: 运动活动期间记录的最高心率，以每分钟心跳次数表示。
 */
@property (nonatomic, assign) UInt8 maxHrValue;

/**
 * @brief Minimum heart rate during activity
 * @chinese 活动期间最小心率
 *
 * @discussion
 * [EN]: The lowest heart rate recorded during the sport activity, in BPM.
 * [CN]: 运动活动期间记录的最低心率，以每分钟心跳次数表示。
 */
@property (nonatomic, assign) UInt8 minHrValue;

/**
 * @brief Average heart rate during activity
 * @chinese 活动期间平均心率
 *
 * @discussion
 * [EN]: The average heart rate during the sport activity, in BPM.
 * [CN]: 运动活动期间的平均心率，以每分钟心跳次数表示。
 */
@property (nonatomic, assign) UInt8 avgHrValue;

/**
 * @brief Maximum pace during activity
 * @chinese 活动期间最大配速
 *
 * @discussion
 * [EN]: The highest pace recorded during the sport activity, in minutes per kilometer.
 * [CN]: 运动活动期间记录的最高配速，以每公里所需分钟数表示。（min/km）
 */
@property (nonatomic, assign) float maxPace;

/**
 * @brief Minimum pace during activity
 * @chinese 活动期间最小配速
 *
 * @discussion
 * [EN]: The lowest pace recorded during the sport activity, in minutes per kilometer.
 * [CN]: 运动活动期间记录的最低配速，以每公里所需分钟数表示。（min/km）
 */
@property (nonatomic, assign) float minPace;

/**
 * @brief Average pace during activity
 * @chinese 活动期间平均配速
 *
 * @discussion
 * [EN]: The average pace during the sport activity, in minutes per kilometer.
 * [CN]: 运动活动期间的平均配速，以每公里所需分钟数表示。（min/km）
 */
@property (nonatomic, assign) float avgPace;

/**
 * @brief Maximum speed during activity
 * @chinese 活动期间最大速度
 *
 * @discussion
 * [EN]: The highest speed recorded during the sport activity, in meters per second (m/s).
 * [CN]: 运动活动期间记录的最高速度，以米/秒为单位（m/s）。
 */
@property (nonatomic, assign) float maxSpeed;

/**
 * @brief Minimum speed during activity
 * @chinese 活动期间最小速度
 *
 * @discussion
 * [EN]: The lowest speed recorded during the sport activity, in meters per second (m/s).
 * [CN]: 运动活动期间记录的最低速度，以米/秒为单位（m/s）。
 */
@property (nonatomic, assign) float minSpeed;

/**
 * @brief Average speed during activity
 * @chinese 活动期间平均速度
 *
 * @discussion
 * [EN]: The average speed during the sport activity, in meters per second (m/s).
 * [CN]: 运动活动期间的平均速度，以米/秒为单位（m/s）。
 */
@property (nonatomic, assign) float avgSpeed;

/**
 * @brief Maximum cadence during activity
 * @chinese 活动期间最大步频
 *
 * @discussion
 * [EN]: The highest cadence (steps per minute) recorded during the sport activity.
 * Represents the fastest stepping rhythm achieved during the exercise.
 *
 * [CN]: 运动活动期间记录的最高步频（每分钟步数）。
 * 表示运动过程中达到的最快步伐节奏。
 */
@property (nonatomic, assign) UInt8 maxCadence;

/**
 * @brief Minimum cadence during activity
 * @chinese 活动期间最小步频
 *
 * @discussion
 * [EN]: The lowest cadence (steps per minute) recorded during the sport activity.
 * Represents the slowest stepping rhythm during the exercise.
 *
 * [CN]: 运动活动期间记录的最低步频（每分钟步数）。
 * 表示运动过程中的最慢步伐节奏。
 */
@property (nonatomic, assign) UInt8 minCadence;

/**
 * @brief Average cadence during activity
 * @chinese 活动期间平均步频
 *
 * @discussion
 * [EN]: The average cadence (steps per minute) during the sport activity.
 * Represents the overall stepping rhythm maintained throughout the exercise.
 *
 * [CN]: 运动活动期间的平均步频（每分钟步数）。
 * 表示整个运动过程中保持的平均步伐节奏。
 */
@property (nonatomic, assign) UInt8 avgCadence;

/**
 * @brief Duration in warm-up heart rate zone
 * @chinese 热身心率区间持续时间
 *
 * @discussion
 * [EN]: Time spent in the warm-up heart rate zone during the activity, in seconds.
 * Heart rate zone calculation: HR < (220-age) * 0.6
 * This represents the warm-up phase where heart rate is below 60% of maximum heart rate.
 *
 * [CN]: 运动活动期间在热身心率区间的持续时间，以秒为单位。
 * 心率区间计算方式：心率 < (220-年龄) * 0.6
 * 表示热身阶段，心率低于最大心率的60%。
 */
@property (nonatomic, assign) UInt8 warmHrDuration;

/**
 * @brief Duration in fat burning heart rate zone
 * @chinese 脂肪燃烧心率区间持续时间
 *
 * @discussion
 * [EN]: Time spent in the fat burning heart rate zone during the activity, in seconds.
 * Heart rate zone calculation: (220-age) * 0.6 ≤ HR < (220-age) * 0.7
 * This represents the fat burning zone where heart rate is between 60% and 70% of maximum heart rate.
 *
 * [CN]: 运动活动期间在脂肪燃烧心率区间的持续时间，以秒为单位。
 * 心率区间计算方式：(220-年龄) * 0.6 ≤ 心率 < (220-年龄) * 0.7
 * 表示脂肪燃烧区间，心率在最大心率的60%到70%之间。
 */
@property (nonatomic, assign) UInt8 fatBurnHrDuration;

/**
 * @brief Duration in aerobic heart rate zone
 * @chinese 有氧心率区间持续时间
 *
 * @discussion
 * [EN]: Time spent in the aerobic heart rate zone during the activity, in seconds.
 * Heart rate zone calculation: (220-age) * 0.7 ≤ HR < (220-age) * 0.8
 * This represents the aerobic zone where heart rate is between 70% and 80% of maximum heart rate.
 *
 * [CN]: 运动活动期间在有氧心率区间的持续时间，以秒为单位。
 * 心率区间计算方式：(220-年龄) * 0.7 ≤ 心率 < (220-年龄) * 0.8
 * 表示有氧运动区间，心率在最大心率的70%到80%之间。
 */
@property (nonatomic, assign) UInt8 aerobicHrDuration;

/**
 * @brief Duration in anaerobic heart rate zone
 * @chinese 无氧心率区间持续时间
 *
 * @discussion
 * [EN]: Time spent in the anaerobic heart rate zone during the activity, in seconds.
 * Heart rate zone calculation: (220-age) * 0.8 ≤ HR < (220-age) * 0.9
 * This represents the anaerobic zone where heart rate is between 80% and 90% of maximum heart rate.
 *
 * [CN]: 运动活动期间在无氧心率区间的持续时间，以秒为单位。
 * 心率区间计算方式：(220-年龄) * 0.8 ≤ 心率 < (220-年龄) * 0.9
 * 表示无氧运动区间，心率在最大心率的80%到90%之间。
 */
@property (nonatomic, assign) UInt8 anaerobicHrDuration;

/**
 * @brief Duration in extreme heart rate zone
 * @chinese 极限心率区间持续时间
 *
 * @discussion
 * [EN]: Time spent in the extreme heart rate zone during the activity, in seconds.
 * Heart rate zone calculation: HR ≥ (220-age) * 0.9
 * This represents the extreme zone where heart rate is above 90% of maximum heart rate.
 *
 * [CN]: 运动活动期间在极限心率区间的持续时间，以秒为单位。
 * 心率区间计算方式：心率 ≥ (220-年龄) * 0.9
 * 表示极限运动区间，心率在最大心率的90%以上。
 */
@property (nonatomic, assign) UInt8 ExtremeHrDuration;

/**
 * @brief Percentage of time spent in warm-up heart rate zone
 * @chinese 热身心率区间时间占比
 *
 * @discussion
 * [EN]: The percentage (0-100) of total activity time spent in the warm-up heart rate zone.
 * Heart rate zone: HR < (220-age) * 0.6
 * [CN]: 在热身心率区间的时间占总运动时间的百分比（0-100）。
 * 心率区间：心率 < (220-年龄) * 0.6
 */
@property (nonatomic, assign) UInt8 warmHrRatio;

/**
 * @brief Percentage of time spent in fat burning heart rate zone
 * @chinese 脂肪燃烧心率区间时间占比
 *
 * @discussion
 * [EN]: The percentage (0-100) of total activity time spent in the fat burning heart rate zone.
 * Heart rate zone: (220-age) * 0.6 ≤ HR < (220-age) * 0.7
 * [CN]: 在脂肪燃烧心率区间的时间占总运动时间的百分比（0-100）。
 * 心率区间：(220-年龄) * 0.6 ≤ 心率 < (220-年龄) * 0.7
 */
@property (nonatomic, assign) UInt8 fatBurnHrRatio;

/**
 * @brief Percentage of time spent in aerobic heart rate zone
 * @chinese 有氧心率区间时间占比
 *
 * @discussion
 * [EN]: The percentage (0-100) of total activity time spent in the aerobic heart rate zone.
 * Heart rate zone: (220-age) * 0.7 ≤ HR < (220-age) * 0.8
 * [CN]: 在有氧心率区间的时间占总运动时间的百分比（0-100）。
 * 心率区间：(220-年龄) * 0.7 ≤ 心率 < (220-年龄) * 0.8
 */
@property (nonatomic, assign) UInt8 aerobicHrRatio;

/**
 * @brief Percentage of time spent in anaerobic heart rate zone
 * @chinese 无氧心率区间时间占比
 *
 * @discussion
 * [EN]: The percentage (0-100) of total activity time spent in the anaerobic heart rate zone.
 * Heart rate zone: (220-age) * 0.8 ≤ HR < (220-age) * 0.9
 * [CN]: 在无氧心率区间的时间占总运动时间的百分比（0-100）。
 * 心率区间：(220-年龄) * 0.8 ≤ 心率 < (220-年龄) * 0.9
 */
@property (nonatomic, assign) UInt8 anaerobicHrRatio;

/**
 * @brief Percentage of time spent in extreme heart rate zone
 * @chinese 极限心率区间时间占比
 *
 * @discussion
 * [EN]: The percentage (0-100) of total activity time spent in the extreme heart rate zone.
 * Heart rate zone: HR ≥ (220-age) * 0.9
 * [CN]: 在极限心率区间的时间占总运动时间的百分比（0-100）。
 * 心率区间：心率 ≥ (220-年龄) * 0.9
 */
@property (nonatomic, assign) UInt8 ExtremeHrRatio;


@end

NS_ASSUME_NONNULL_END
