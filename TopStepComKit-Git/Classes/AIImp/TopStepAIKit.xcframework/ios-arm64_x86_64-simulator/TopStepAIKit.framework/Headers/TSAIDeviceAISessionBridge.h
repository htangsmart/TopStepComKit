//
//  TSAIDeviceAISessionBridge.h
//  TopStepAIKit
//
//  Created by Codex on 2026/9/4.
//

#import <Foundation/Foundation.h>

#import "TSAICapabilityDefines.h"
#import "TSAIDeviceBridge.h"

@class TSAIStartRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Normalized reason for rejecting a device-origin AI start
 * @chinese 拒绝设备发起 AI 请求的标准化原因
 */
typedef NS_ENUM(NSUInteger, TSAIDeviceAIStartRejectionReason) {
    TSAIDeviceAIStartRejectionReasonUnsupported = 0,
    TSAIDeviceAIStartRejectionReasonBusy,
    TSAIDeviceAIStartRejectionReasonAuthenticationFailed,
    TSAIDeviceAIStartRejectionReasonServiceFailed,
    TSAIDeviceAIStartRejectionReasonInvalidRequest,
    TSAIDeviceAIStartRejectionReasonTimeout,
    TSAIDeviceAIStartRejectionReasonOther,
};

/**
 * @brief Result of synchronizing one AI start with a device
 * @chinese 一次 AI 启动与设备同步后的结果
 */
@interface TSAIDeviceAISessionStartResult : NSObject <NSCopying>

/** @brief Whether both sides entered the requested coordination @chinese 双端是否已进入请求的协同状态 */
@property (nonatomic, assign, readonly, getter=isSuccessful) BOOL successful;

/** @brief Whether the device already ended because of its own exception @chinese 设备是否因自身异常已结束 */
@property (nonatomic, assign, readonly) BOOL deviceSideExceptionOccurred;

/** @brief Whether the transport retains a logical device coordination lease after success @chinese 成功后传输层是否仍保留设备逻辑协同占用 */
@property (nonatomic, assign, readonly) BOOL coordinationRetained;

/**
 * @brief Create an immutable synchronization result
 * @chinese 创建不可变的同步结果
 */
+ (instancetype)resultWithSuccess:(BOOL)success
      deviceSideExceptionOccurred:(BOOL)deviceSideExceptionOccurred
             coordinationRetained:(BOOL)coordinationRetained;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/** @brief Completion for device AI start synchronization @chinese 设备 AI 启动同步回调 */
typedef void (^TSAIDeviceAISessionStartCompletion)(
    TSAIDeviceAISessionStartResult * _Nullable result,
    NSError * _Nullable error);

/**
 * @brief Optional transport for direction-aware device AI sessions
 * @chinese 带发起方向的可选设备 AI 会话传输协议
 */
@protocol TSAIDeviceAISessionBridge <TSAIDeviceBridge>

    /**
     * @brief Start an App-origin device session
     * @chinese 启动 App 发起的设备会话
     * @param request EN: Validated App-origin request. CN: 已校验的 App 发起请求。
     * @param completion EN: Device synchronization result. CN: 设备同步结果。
     */
    - (void)startDeviceAISessionWithRequest:(TSAIStartRequest *)request
                                 completion:(TSAIDeviceAISessionStartCompletion)completion;

    /**
     * @brief Accept the matching pending device request
     * @chinese 接受匹配的待处理设备请求
     * @param request EN: Validated device-origin request. CN: 已校验的设备发起请求。
     * @param completion EN: Device synchronization result. CN: 设备同步结果。
     */
    - (void)acceptDeviceAISessionStartRequest:(TSAIStartRequest *)request
                                   completion:(TSAIDeviceAISessionStartCompletion)completion;

    /**
     * @brief Reject the matching pending device request
     * @chinese 拒绝匹配的待处理设备请求
     * @param request EN: Original device-origin request. CN: 原始设备发起请求。
     * @param reason EN: Normalized rejection reason. CN: 标准化拒绝原因。
     * @param completion EN: Optional delivery result. CN: 可选的发送结果。
     */
    - (void)rejectDeviceAISessionStartRequest:(TSAIStartRequest *)request
                                       reason:(TSAIDeviceAIStartRejectionReason)reason
                                   completion:(nullable TSAICompletionBlock)completion;

    /**
     * @brief End an App-controlled device session
     * @chinese 结束 App 控制的设备会话
     * @param request EN: Active session request. CN: 活动会话请求。
     * @param completion EN: Optional device end result. CN: 可选的设备结束结果。
     */
    - (void)endDeviceAISessionWithRequest:(TSAIStartRequest *)request
                               completion:(nullable TSAICompletionBlock)completion;

@optional

    /**
     * @brief Enter the device conversation-translation product mode
     * @chinese 进入设备对话翻译产品模式
     */
    - (void)startDeviceConversationTranslationWithMode:(TSAIConversationTranslationMode)mode
                                            completion:(nullable TSAICompletionBlock)completion;

    /**
     * @brief Leave the device conversation-translation product mode
     * @chinese 退出设备对话翻译产品模式
     */
    - (void)stopDeviceConversationTranslationWithCompletion:
        (nullable TSAICompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
