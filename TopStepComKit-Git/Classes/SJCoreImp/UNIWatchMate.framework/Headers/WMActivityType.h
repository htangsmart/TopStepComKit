//
//  WMActivityType.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#ifndef WMActivityType_h
#define WMActivityType_h

// Motion class abandonment 运动类别 废弃（使用注册的方式，API不关心有多少中运动，API调用者与设备约定好每个运动的ID，api直接将设备给的运动ID对应注册的运动类吐出）
//typedef NS_ENUM(NSInteger, WMActivityType) {
//    WMActivityTypeOutdoorRunning,      // 户外跑步
//    WMActivityTypeOutdoorWalking,      // 户外健走
//    WMActivityTypeMountainClimbing,    // 登山
//    WMActivityTypeCrossCountry,        // 越野
//    WMActivityTypeOutdoorHiking,       // 户外徒步
//    WMActivityTypeIndoorRunning,       // 室内跑步
//    WMActivityTypeOutdoorCycling,      // 户外骑行
//    WMActivityTypeSmallWheelBike,      // 小轮车
//    WMActivityTypeHunting,             // 打猎
//    WMActivityTypeSailing,             // 帆船运动
//    WMActivityTypeSkateboarding,       // 滑板
//    WMActivityTypeRollerSkating,       // 轮滑
//    WMActivityTypeOutdoorIceSkating,   // 户外滑冰
//    WMActivityTypeHorsebackRiding,     // 马术
//    WMActivityTypeMountainBiking,      // 山地自行车
//    WMActivityTypeIndoorCycling,       // 室内骑行
//    WMActivityTypeFreeTraining,        // 自由训练
//    WMActivityTypeBasketball,          // 篮球
//    WMActivityTypeSoccer,              // 足球
//    WMActivityTypePingPong,            // 乒乓球
//    WMActivityTypeBadminton,           // 羽毛球
//    WMActivityTypeTennis,              // 网球
//    WMActivityTypeStrengthTraining,    // 力量训练
//    WMActivityTypePilates,             // 普拉提
//    WMActivityTypeIndoorWalking,       // 室内走路
//    WMActivityTypeTreadmill,           // 跑步机
//    WMActivityTypeGymnastics,          // 体操
//    WMActivityTypeRowing,              // 划船
//    WMActivityTypeJumpingJack,         // 开合跳
//    WMActivityTypeElliptical,          // 椭圆机
//    WMActivityTypeStepping,            // 踏步
//    WMActivityTypeRiding,              // 骑马
//    WMActivityTypeYoga,                // 瑜伽
//    WMActivityTypeCricket,             // 板球
//    WMActivityTypeBaseball,            // 棒球
//    WMActivityTypeBowling,             // 保龄球
//    WMActivityTypeSquash,              // 壁球
//    WMActivityTypeSoftball,            // 垒球
//    WMActivityTypeVolleyball,          // 排球
//    WMActivityTypeBallet,              // 芭蕾
//    WMActivityTypeStreetDance,         // 街舞
//    WMActivityTypeDance,               // 舞蹈
//    WMActivityTypeFencing,             // 击剑
//    WMActivityTypeKarate,              // 空手道
//    WMActivityTypeBoxing,              // 拳击
//    WMActivityTypeJudo,                // 柔道
//    WMActivityTypeWrestling,           // 摔跤
//    WMActivityTypeTaiChi,              // 太极
//    WMActivityTypeShuttlecock,         // 毽球
//    WMActivityTypeTaekwondo,           // 跆拳道
//    WMActivityTypeCrossTraining,       // 交叉训练
//    WMActivityTypeSitups,              // 仰卧起坐
//    WMActivityTypeAbdominalTraining,   // 腰腹训练
//    WMActivityTypeLatinDance,          // 拉丁舞
//    WMActivityTypeRugby,               // 橄榄球
//    WMActivityTypeFieldHockey,         // 曲棍球
//    WMActivityTypeRowingMachine,       // 划船机
//    WMActivityTypeSkiing,              // 滑雪
//    WMActivityTypeIceHockey,           // 冰球
//    WMActivityTypeVO2Max,              // 最大摄氧量
//    WMActivityTypeWalkingMachine,      // 漫步机
//    WMActivityTypeTrackAndField,       // 田径
//    WMActivityTypeRelaxation,          // 整理放松
//    WMActivityTypeCrossFit,            // 交叉配合
//    WMActivityTypeFunctionalTraining,  // 功能性训练
//    WMActivityTypeFitnessTraining,     // 体能训练
//    WMActivityTypeArchery,             // 射箭
//    WMActivityTypeFlexibility,         // 柔韧度
//    WMActivityTypeMixedAerobics,       // 混合有氧
//    WMActivityTypeKickboxing,          // 自由搏击
//    WMActivityTypeAustralianFootball,  // 澳式足球
//    WMActivityTypeMartialArts,         // 武术
//    WMActivityTypeBuildingClimbing,    // 爬楼
//    WMActivityTypeHandball,            // 手球
//    WMActivityTypeCurling,             // 冰壶
//    WMActivityTypeSnowboarding,        // 单板滑雪
//    WMActivityTypeLeisureSports,       // 休闲运动
//    WMActivityTypeAmericanFootball,    // 美式橄榄球
//    WMActivityTypeHandCrankedBike,     // 手摇车
//    WMActivityTypeFishing,             // 钓鱼
//    WMActivityTypeFrisbee,             // 飞盘
//    WMActivityTypeGolf,                // 高尔夫
//    WMActivityTypeFolkDance,           // 民族舞
//    WMActivityTypeAlpineSkiing,        // 高山滑雪
//    WMActivityTypeSnowSports,          // 雪上运动
//    WMActivityTypeRelaxationMeditation,// 舒缓冥想类运动
//    WMActivityTypeCoreTraining,        // 核心训练
//    WMActivityTypeFitnessGame,         // 健身游戏
//    WMActivityTypeFitnessDance,        // 健身操
//    WMActivityTypeGroupGymnastics,     // 团体操
//    WMActivityTypeBoxingDance,         // 搏击操
//    WMActivityTypeLongFieldHockey,     // 长曲棍球
//    WMActivityTypeFoamRollerRelaxation,// 泡沫轴筋膜放松
//    WMActivityTypeHorizontalBar,       // 单杠
//    WMActivityTypeParallelBars,        // 双杠
//    WMActivityTypeHulaHoop,            // 呼啦圈
//    WMActivityTypeDarts,               // 飞镖
//    WMActivityTypePickleball,          // 匹克球
//    WMActivityTypeHIIT,                // HIIT
//    WMActivityTypeShooting,            // 射击
//    WMActivityTypeTrampoline,          // 蹦床
//    WMActivityTypeBalanceBike,         // 平衡车
//    WMActivityTypeRollerblading,       // 溜旱冰
//    WMActivityTypeParkour,             // 跑酷
//    WMActivityTypePullUps,             // 引体向上
//    WMActivityTypePushUps,             // 俯卧撑
//    WMActivityTypePlank,               // 平板支撑
//    WMActivityTypeRockClimbing,        // 攀岩
//    WMActivityTypeHighJump,            // 跳高
//    WMActivityTypeBungeeJumping,       // 蹦极
//    WMActivityTypeLongJump,            // 跳远
//    WMActivityTypeMarathon,            // 马拉松
//    WMActivityTypeJumpRope             // 跳绳
//};

#endif /* WMActivityType_h */
