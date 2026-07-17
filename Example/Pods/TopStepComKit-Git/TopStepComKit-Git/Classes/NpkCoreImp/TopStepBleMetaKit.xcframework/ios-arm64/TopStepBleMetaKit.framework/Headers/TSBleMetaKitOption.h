//
//  TSBleMetaKitOption.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief SDK全局配置管理器
 * @chinese 管理整个 TopStepBleMetaKit SDK 的全局配置参数
 *
 * @discussion
 * EN: This class manages SDK-level global configurations (logging, packet size, etc.).
 *     Request-specific configurations (timeout, retry) are managed by TSRequestOption.
 * CN: 此类管理 SDK 级别的全局配置（日志、分包大小等）。
 *     Request 特定的配置（超时、重试）由 TSRequestOption 管理。
 */
@interface TSBleMetaKitOption : NSObject

// ==================== SDK级别配置 ====================

/**
 * @brief 分包大小
 * @chinese 数据分包的大小，单位字节
 *
 * @discussion
 * EN: Size for data packetization, in bytes.
 * CN: 数据分包的大小，单位字节。
 *
 * @note
 * EN: Default value is 20 bytes (typical BLE MTU).
 * CN: 默认值为20字节（典型的BLE MTU）。
 */
@property (nonatomic, assign) NSUInteger packetSize;

/**
 * @brief 是否启用日志输出
 * @chinese 是否启用详细的日志输出
 *
 * @discussion
 * EN: Whether to enable detailed logging output.
 * CN: 是否启用详细的日志输出。
 *
 * @note
 * EN: Default value is YES in Debug mode, NO in Release mode.
 * CN: 默认在Debug模式下为YES，Release模式下为NO。
 */
@property (nonatomic, assign) BOOL enableLogging;

/**
 * @brief 是否启用重复请求检测
 * @chinese 是否检测并阻止重复的请求被添加到队列
 *
 * @discussion
 * EN: Whether to detect and prevent duplicate requests from being added to the queue.
 * CN: 是否检测并阻止重复的请求被添加到队列。
 *
 * @note
 * EN: Default value is YES. When enabled, identical requests will be ignored.
 * CN: 默认值为YES。启用时，相同的请求将被忽略。
 */
@property (nonatomic, assign) BOOL enableDuplicateDetection;


/**
 * @brief 获取单例实例
 * @chinese 获取配置管理器的单例实例
 * @return 配置管理器单例实例
 */
+ (instancetype)sharedOption;

- (void)syncOptionsWithOption:(TSBleMetaKitOption *)kitOption;

/**
 * @brief 重置为默认配置
 * @chinese 将所有配置重置为默认值
 */
- (void)resetToDefaults;

/**
 * @brief 从字典加载配置
 * @chinese 从字典数据中加载配置参数
 *
 * @param configDict 配置字典
 *        EN: Configuration dictionary
 *        CN: 配置字典
 */
- (void)loadFromDictionary:(NSDictionary *)configDict;

/**
 * @brief 导出配置到字典
 * @chinese 将当前配置导出为字典格式
 * @return 配置字典
 */
- (NSDictionary *)exportToDictionary;

/**
 * @brief 验证配置有效性
 * @chinese 验证当前配置参数是否有效
 * @return 配置是否有效
 */
- (BOOL)validateConfig;

- (void)logMessage:(NSString *)message ;

@end

NS_ASSUME_NONNULL_END 
