//
//  TSCompanionWorkoutDefines.h
//  TopStepInterfaceKit
//

#import <Foundation/Foundation.h>

/**
 * @brief Companion workout event
 * @chinese 互联运动事件
 */
typedef NS_ENUM(NSInteger, TSCompanionWorkoutEvent) {
    TSCompanionWorkoutEventStop = 0,    // Stop / 结束
    TSCompanionWorkoutEventStart = 1,   // Start / 开始
    TSCompanionWorkoutEventPause = 2,   // Pause / 暂停
    TSCompanionWorkoutEventResume = 3,  // Resume / 继续
};

/**
 * @brief Companion workout state
 * @chinese 互联运动状态
 */
typedef NS_ENUM(NSInteger, TSCompanionWorkoutState) {
    TSCompanionWorkoutStateCompleted = 0, // Completed / 已结束
    TSCompanionWorkoutStateActive = 1,    // Active / 进行中
    TSCompanionWorkoutStatePaused = 2,    // Paused / 已暂停
};

/**
 * @brief Companion workout initiator
 * @chinese 互联运动发起方
 */
typedef NS_ENUM(NSInteger, TSCompanionWorkoutInitiator) {
    TSCompanionWorkoutInitiatorApp = 1,    // App initiated / App 发起
    TSCompanionWorkoutInitiatorDevice = 2, // Device initiated / 设备发起
};
