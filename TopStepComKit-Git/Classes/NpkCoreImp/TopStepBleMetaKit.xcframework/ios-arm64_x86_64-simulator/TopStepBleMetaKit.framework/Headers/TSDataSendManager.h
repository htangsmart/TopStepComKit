//
//  TSDataSendManager.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/23.
//

#import "TSCommandBase.h"
#import "TSRequestOption.h"

NS_ASSUME_NONNULL_BEGIN


typedef void(^TSSendProgressBlock)(CGFloat progress);

/**
 * @brief 分包发送管理器
 * @chinese 负责蓝牙分包的发送、重发和状态管理
 *
 * @discussion
 * EN: This class is responsible for sending pre-split data packets over Bluetooth.
 *     Data splitting is handled by TSCommandDataWrapper, this class only manages
 *     the sending process, retry logic, and progress tracking.
 * CN: 此类负责通过蓝牙发送预先分包的数据包。
 *     数据拆分由 TSCommandDataWrapper 处理，此类只管理发送过程、
 *     重试逻辑和进度跟踪。
 */
@interface TSDataSendManager : TSCommandBase

/**
 * @brief 配置对象
 * @chinese 分包管理器的配置对象
 *
 * @discussion
 * EN: Configuration object for packet manager. If nil, uses [TSRequestOption defaultOption].
 * CN: 分包管理器的配置对象。如果为 nil，则使用 [TSRequestOption defaultOption]。
 */
@property (nonatomic, strong, nullable) TSRequestOption *option;

/**
 * @brief 是否需要重发
 * @chinese 是否需要重发该请求
 *
 * @discussion
 * EN: Indicates whether the request needs to be resent.
 * CN: 是否需要重发该请求。
 */
@property (nonatomic, assign) BOOL needResend;

/**
 * @brief 已重发次数
 * @chinese 已经重发的次数
 *
 * @discussion
 * EN: The number of times the request has been resent.
 * CN: 已经重发的次数。
 */
@property (nonatomic, assign) UInt8 resendCount;

/**
 * @brief 最大重试次数
 * @chinese 分包发送失败时的最大重试次数
 *
 * @discussion
 * EN: Maximum number of retries when packet sending fails.
 * CN: 分包发送失败时的最大重试次数。
 *
 * @note
 * EN: Default value is 3.
 * CN: 默认值为3。
 */
@property (nonatomic, assign) UInt8 maxRetryCount;

/**
 * @brief 重试间隔时间
 * @chinese 重试之间的等待时间，单位秒
 *
 * @discussion
 * EN: Wait time between retries, in seconds.
 * CN: 重试之间的等待时间，单位秒。
 *
 * @note
 * EN: Default value is 0.5 seconds.
 * CN: 默认值为0.5秒。
 */
@property (nonatomic, assign) NSTimeInterval retryInterval;

/**
 * @brief 重置分包管理器
 * @chinese 重置所有分包状态和数据
 */
- (void)reset;

/**
 * @brief 重置重试计数
 * @chinese 重置重试相关状态
 */
- (void)resetRetryState;


/**
 * @brief 开始发送数据
 * @chinese 开始执行数据分包发送流程
 *
 * @param packages 要发送的分包数组
 *        EN: Array of packets to be sent
 *        CN: 要发送的分包数组
 *
 * @note
 * EN: UUID configuration is now handled by TSRequestManager.
 * CN: UUID 配置现在由 TSRequestManager 处理。
 */
- (void)startSending:(NSArray<NSData *>*)packages progress:(TSSendProgressBlock)progress completion:(TSMetaCompletionBlock)completion;

/**
 * @brief 停止发送
 * @chinese 停止当前的数据发送流程
 */
- (void)stopSending;




@end

NS_ASSUME_NONNULL_END
