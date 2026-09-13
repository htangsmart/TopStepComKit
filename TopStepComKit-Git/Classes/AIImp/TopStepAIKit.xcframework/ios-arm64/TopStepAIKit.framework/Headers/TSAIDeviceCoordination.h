//
//  TSAIDeviceCoordination.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"

@class TSAIAudioRouteConfiguration;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable device coordination required by one AI start request
 * @chinese 单次 AI 启动请求所需的不可变设备协同信息
 *
 * @discussion
 * [EN]: App-only operations omit this object. The audio route distinguishes
 *       device audio capture from a device page synchronized with phone audio.
 * [CN]: App-only 操作不携带本对象。音频路由用于区分设备采音与手机采音时的
 *       设备页面同步。
 */
@interface TSAIDeviceCoordination : NSObject <NSCopying>

/** @brief Device AI scene @chinese 设备 AI 场景 */
@property (nonatomic, assign, readonly) TSAIDeviceAIScene scene;

/** @brief Side that initiates the session @chinese 会话发起方 */
@property (nonatomic, assign, readonly) TSAISessionInitiator initiator;

/** @brief Complete audio route requested for the session @chinese 会话请求的完整音频路由 */
@property (nonatomic, copy, readonly) TSAIAudioRouteConfiguration *audioRouteConfiguration;

/**
 * @brief Create device coordination for one AI session
 * @chinese 创建单次 AI 会话的设备协同信息
 *
 * @param scene
 * EN: Device AI scene
 * CN: 设备 AI 场景
 *
 * @param initiator
 * EN: Side that initiates the session
 * CN: 会话发起方
 *
 * @param audioRouteConfiguration
 * EN: Complete requested audio route
 * CN: 请求的完整音频路由
 *
 * @return
 * EN: Immutable device coordination
 * CN: 不可变设备协同信息
 */
+ (instancetype)coordinationWithScene:(TSAIDeviceAIScene)scene
                            initiator:(TSAISessionInitiator)initiator
              audioRouteConfiguration:(TSAIAudioRouteConfiguration *)audioRouteConfiguration;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
