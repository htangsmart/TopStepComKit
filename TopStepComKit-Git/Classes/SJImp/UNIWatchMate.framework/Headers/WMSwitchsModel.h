//
//  WMSwitchsModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 开关设置 （Switch setting）
@interface WMSwitchsModel : NSObject

/// 来电时是否响铃 （Whether the bell rings when the call comes in）
@property (nonatomic, assign) BOOL isRingtoneEnabled;
/// 是否有通知触感 （Whether there is a notification touch）
@property (nonatomic, assign) BOOL isNotificationHaptic;
/// 表冠是否有触感反馈 （Whether the crown has tactile feedback）
@property (nonatomic, assign) BOOL isCrownHapticFeedback;
/// 系统是否有触感反馈 （Whether the system has tactile feedback）
@property (nonatomic, assign) BOOL isSystemHapticFeedback;
/// 是否静音 （Mute or not）
@property (nonatomic, assign) BOOL isMuted;
/// 是否开启抬腕 （Whether to enable the wrist lift）
@property (nonatomic, assign) BOOL isScreenWakeEnabled;

@end

NS_ASSUME_NONNULL_END
