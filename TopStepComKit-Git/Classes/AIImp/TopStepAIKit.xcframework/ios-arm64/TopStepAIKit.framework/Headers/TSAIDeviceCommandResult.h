#import <Foundation/Foundation.h>
#import "TSAIDeviceCommandRequest.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const TSAIDeviceCommandErrorDomain;

/**
 * @brief Command adapter error codes
 * @chinese 指令适配错误码
 */
typedef NS_ENUM(NSInteger, TSAIDeviceCommandErrorCode) {
    TSAIDeviceCommandErrorCodeInvalidParameters = 7201,
    TSAIDeviceCommandErrorCodeUnavailable = 7202,
    TSAIDeviceCommandErrorCodeUnsupported = 7203,
    TSAIDeviceCommandErrorCodeBusy = 7204,
    TSAIDeviceCommandErrorCodeUncertain = 7205,
};

/**
 * @brief Actual command execution outcome
 * @chinese 设备指令真实执行结果
 */
typedef NS_ENUM(NSInteger, TSAIDeviceCommandStatus) {
    TSAIDeviceCommandStatusSucceeded = 0,
    TSAIDeviceCommandStatusFailed,
    TSAIDeviceCommandStatusUnsupported,
    TSAIDeviceCommandStatusBusy,
    TSAIDeviceCommandStatusInvalid,
    TSAIDeviceCommandStatusUncertain,
};

/**
 * @brief Device outcome independent of the model's spoken reply
 * @chinese 独立于模型语音回复的设备执行结果
 */
@interface TSAIDeviceCommandResult : NSObject

/**
 * @brief Original command snapshot
 * @chinese 原始指令快照
 * @discussion
 * [EN]: Retains receipt and source identity.
 * [CN]: 保留接收与来源身份。
 * @note
 * [EN]: Not the vendor's speech.
 * [CN]: 不使用厂商语音作为结果。
 */
@property (nonatomic, strong) TSAIDeviceCommandRequest *request;

/**
 * @brief Confirmed execution status
 * @chinese 已确认的执行状态
 * @discussion
 * [EN]: Uncertain means a write may have reached the device.
 * [CN]: Uncertain 表示写入可能已经到达设备。
 * @note
 * [EN]: Never automatically retry uncertain writes.
 * [CN]: 不自动重试不确定写入。
 */
@property (nonatomic, assign) TSAIDeviceCommandStatus status;

/**
 * @brief Error or unsupported reason
 * @chinese 错误或不支持原因
 * @discussion
 * [EN]: Includes a localized description.
 * [CN]: 包含可读错误说明。
 * @note
 * [EN]: Nil on success.
 * [CN]: 成功时为 nil。
 */
@property (nonatomic, strong, nullable) NSError *error;

/**
 * @brief Create an execution result
 * @chinese 创建设备执行结果
 * @param request
 * EN: Source command.
 * CN: 来源指令。
 * @param status
 * EN: Actual outcome.
 * CN: 真实结果。
 * @param error
 * EN: Failure reason, if any.
 * CN: 可空的失败原因。
 * @return
 * EN: New result.
 * CN: 新结果。
 */
+ (instancetype)resultWithRequest:(TSAIDeviceCommandRequest *)request
                            status:(TSAIDeviceCommandStatus)status
                             error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
