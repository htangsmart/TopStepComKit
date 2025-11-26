//
//  TSRequestOption.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Request配置类
 * @chinese 专门用于配置单个Request的超时和重试参数
 *
 * @discussion
 * EN: This class manages timeout and retry configurations for individual requests.
 *     Separated from TSBleMetaKitOption to maintain clear responsibility boundaries.
 * CN: 此类管理单个请求的超时和重试配置。
 *     与 TSBleMetaKitOption 分离以保持清晰的职责边界。
 */
@interface TSRequestOption : NSObject

// ==================== 超时配置 ====================

/**
 * @brief 请求总超时时间，单位秒
 * @chinese 请求的总超时时间（包括所有重试）
 *
 * @discussion
 * EN: Total timeout for the entire request (including all retries), in seconds.
 * CN: 请求的总超时时间（包括所有重试），单位秒。
 *
 * @note
 * EN: Default value is 18 seconds.
 * CN: 默认值为18秒。
 */
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

/**
 * @brief 响应超时时间，单位秒
 * @chinese 等待设备响应的超时时间
 *
 * @discussion
 * EN: Timeout for waiting device response after data is sent, in seconds.
 * CN: 数据发送完成后等待设备响应的超时时间，单位秒。
 *
 * @note
 * EN: Default value is 5 seconds.
 * CN: 默认值为5秒。
 */
@property (nonatomic, assign) NSTimeInterval responseTimeoutInterval;

/**
 * @brief 单包发送超时时间，单位秒
 * @chinese 单个蓝牙数据包发送的超时时间
 *
 * @discussion
 * EN: Timeout for sending a single BLE packet, in seconds.
 * CN: 单个蓝牙数据包发送的超时时间，单位秒。
 *
 * @note
 * EN: Default value is 3 seconds.
 * CN: 默认值为3秒。
 */
@property (nonatomic, assign) NSTimeInterval packetSendTimeout;

// ==================== 重试配置 ====================

/**
 * @brief Request级别重试次数
 * @chinese Request级别失败时的最大重试次数
 *
 * @discussion
 * EN: Maximum retry count at request level when request fails.
 * CN: Request级别失败时的最大重试次数。
 *
 * @note
 * EN: Default value is 2 times (3 attempts total).
 * CN: 默认值为2次（总共3次尝试）。
 */
@property (nonatomic, assign) NSUInteger requestMaxRetryCount;

/**
 * @brief Request级别重试间隔
 * @chinese Request重试之间的等待时间，单位秒
 *
 * @discussion
 * EN: Wait time between request retries, in seconds.
 * CN: Request重试之间的等待时间，单位秒。
 *
 * @note
 * EN: Default value is 0.5 seconds.
 * CN: 默认值为0.5秒。
 */
@property (nonatomic, assign) NSTimeInterval requestRetryInterval;

/**
 * @brief 分包级别重试次数
 * @chinese 单个数据包发送失败时的最大重试次数
 *
 * @discussion
 * EN: Maximum retry count at packet level when packet sending fails.
 * CN: 单个数据包发送失败时的最大重试次数。
 *
 * @note
 * EN: Default value is 2 times (3 attempts total).
 * CN: 默认值为2次（总共3次尝试）。
 */
@property (nonatomic, assign) NSUInteger packetMaxRetryCount;

/**
 * @brief 分包级别重试间隔
 * @chinese 数据包重试之间的等待时间，单位秒
 *
 * @discussion
 * EN: Wait time between packet retries, in seconds.
 * CN: 数据包重试之间的等待时间，单位秒。
 *
 * @note
 * EN: Default value is 0.5 seconds.
 * CN: 默认值为0.5秒。
 */
@property (nonatomic, assign) NSTimeInterval packetRetryInterval;

/**
 * @brief 创建默认配置
 * @chinese 创建使用默认值的配置对象
 * @return 配置对象
 */
+ (instancetype)defaultOption;

/**
 * @brief 创建快速查询配置
 * @chinese 用于电量、时间等快速查询操作
 * @return 配置对象
 */
+ (instancetype)fastQueryOption;

/**
 * @brief 创建数据同步配置
 * @chinese 用于运动、睡眠等数据同步操作
 * @return 配置对象
 */
+ (instancetype)dataSyncOption;

/**
 * @brief 创建OTA升级配置
 * @chinese 用于固件升级操作
 * @return 配置对象
 */
+ (instancetype)otaOption;

/**
 * @brief 创建文件传输配置
 * @chinese 用于表盘、音乐等文件传输操作
 * @return 配置对象
 */
+ (instancetype)fileTransferOption;

/**
 * @brief 验证配置有效性
 * @chinese 检查当前配置参数是否在有效范围内
 * @return 配置是否有效
 */
- (BOOL)validateConfig;

/**
 * @brief 从另一个配置对象复制
 * @chinese 复制另一个配置对象的所有参数
 * @param option 源配置对象
 */
- (void)copyFromOption:(TSRequestOption *)option;

@end

NS_ASSUME_NONNULL_END

