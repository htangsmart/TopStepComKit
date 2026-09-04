//
//  TSAIStartRequest.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"

@class TSAIDeviceCoordination;
@class TSAIUseCaseParameters;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable request evaluated before an AI operation starts
 * @chinese AI 操作启动前接受资格校验的不可变请求
 *
 * @discussion
 * [EN]: A nil deviceCoordination denotes an App-only operation. A non-nil
 *       value requires exact scene, initiator and audio-route support.
 * [CN]: deviceCoordination 为 nil 表示纯 App 操作；非 nil 时必须精确支持
 *       对应场景、发起方和音频路由。
 */
@interface TSAIStartRequest : NSObject <NSCopying>

/**
 * @brief Identifier unique within the current connection generation
 * @chinese 当前连接代际内唯一的请求标识
 */
@property (nonatomic, copy, readonly) NSString *requestIdentifier;

/** @brief Business use case to start @chinese 需要启动的业务用例 */
@property (nonatomic, assign, readonly) TSAIUseCase useCase;

/** @brief Optional immutable typed use-case parameters @chinese 可选的不可变强类型用例参数 */
@property (nonatomic, copy, readonly, nullable) TSAIUseCaseParameters *parameters;

/**
 * @brief Optional device coordination; nil for App-only operations
 * @chinese 可选设备协同信息，纯 App 操作为 nil
 */
@property (nonatomic, copy, readonly, nullable) TSAIDeviceCoordination *deviceCoordination;

/**
 * @brief Create an immutable AI start request
 * @chinese 创建不可变 AI 启动请求
 *
 * @param requestIdentifier
 * EN: Identifier unique within the current connection generation
 * CN: 当前连接代际内唯一的请求标识
 *
 * @param useCase
 * EN: Business use case to start
 * CN: 需要启动的业务用例
 *
 * @param parameters
 * EN: Optional typed use-case parameters
 * CN: 可选的强类型用例参数
 *
 * @param deviceCoordination
 * EN: Required device coordination, or nil for an App-only operation
 * CN: 所需设备协同信息；纯 App 操作传 nil
 *
 * @return
 * EN: Immutable start request
 * CN: 不可变启动请求
 */
+ (instancetype)requestWithIdentifier:(NSString *)requestIdentifier
                              useCase:(TSAIUseCase)useCase
                           parameters:(nullable TSAIUseCaseParameters *)parameters
                   deviceCoordination:(nullable TSAIDeviceCoordination *)deviceCoordination;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
