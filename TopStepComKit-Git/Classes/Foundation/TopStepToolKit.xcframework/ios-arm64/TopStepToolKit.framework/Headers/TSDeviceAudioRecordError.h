#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Error domain for device audio recording.
 * @chinese 普通设备录音错误域。
 */
FOUNDATION_EXPORT NSErrorDomain const TSDeviceAudioRecordErrorDomain;

/**
 * @brief Original device status code, when supplied by the vendor SDK.
 * @chinese 厂商 SDK 返回的原始设备状态码键。
 */
FOUNDATION_EXPORT NSString * const TSDeviceAudioRecordStatusCodeKey;

/**
 * @brief Device audio recording error codes.
 * @chinese 普通设备录音错误码。
 */
typedef NS_ERROR_ENUM(TSDeviceAudioRecordErrorDomain, TSDeviceAudioRecordErrorCode) {
    TSDeviceAudioRecordErrorDisconnected = 7001, ///< Not ready / 设备未就绪
    TSDeviceAudioRecordErrorUnsupported = 7002, ///< API unavailable / 能力不可用
    TSDeviceAudioRecordErrorInvalidDuration = 7003, ///< Invalid minutes / 分钟数越界
    TSDeviceAudioRecordErrorCommandFailed = 7004, ///< Command rejected / 命令失败
    TSDeviceAudioRecordErrorBusy = 7005, ///< Command in progress / 命令处理中
    TSDeviceAudioRecordErrorTimeout = 7006, ///< No response / 请求超时
    TSDeviceAudioRecordErrorUnavailable = 7007, ///< No cached value / 缓存尚未上报
};

NS_ASSUME_NONNULL_END
