//
//  TSNpkPostConnectCoordinator.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/7/31.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TSNpkPostConnectAppStatusHandling <NSObject>

- (void)startMonitoring;
- (void)stopMonitoring;

@end


@protocol TSNpkPostConnectTimeSetting <NSObject>

- (BOOL)isSupport;
- (void)setSystemTimeWithCompletion:(TSCompletionBlock)completion;

@end


@protocol TSNpkPostConnectLanguageSetting <NSObject>

- (BOOL)isSupport;
- (void)setLanguage:(TSLanguageModel *)language completion:(TSCompletionBlock)completion;

@end


/**
 * @brief Coordinates non-critical actions after an NPK device connection succeeds
 * @chinese 协调 NPK 设备连接成功后的非关键行为
 */
@interface TSNpkPostConnectCoordinator : NSObject

/**
 * @brief Creates a coordinator with injectable action handlers
 * @chinese 使用可注入的行为处理器创建协调器
 *
 * @param appStatusHandler
 * EN: App status monitoring handler
 * CN: App 状态监听处理器
 *
 * @param timeSetter
 * EN: Device time setting handler
 * CN: 设备时间设置处理器
 *
 * @param languageSetter
 * EN: Device language setting handler
 * CN: 设备语言设置处理器
 *
 * @return
 * EN: An initialized coordinator
 * CN: 初始化后的协调器
 */
- (instancetype)initWithAppStatusHandler:(id<TSNpkPostConnectAppStatusHandling>)appStatusHandler
                              timeSetter:(id<TSNpkPostConnectTimeSetting>)timeSetter
                          languageSetter:(id<TSNpkPostConnectLanguageSetting>)languageSetter;

/**
 * @brief Starts independent post-connect actions without waiting for their completion
 * @chinese 独立发起连接后行为，不等待各行为完成
 *
 * @param connectParam
 * EN: Parameters controlling optional post-connect actions
 * CN: 控制可选连接后行为的连接参数
 */
- (void)startWithConnectParam:(TSPeripheralConnectParam *)connectParam;

/**
 * @brief Stops long-lived post-connect services
 * @chinese 停止连接后的长生命周期服务
 */
- (void)stop;

/**
 * @brief Converts an iOS preferred language identifier to an SDK language model
 * @chinese 将 iOS 首选语言标识转换为 SDK 语言模型
 *
 * @param identifier
 * EN: An iOS language identifier such as en-US or zh-Hant-TW
 * CN: iOS 语言标识，例如 en-US 或 zh-Hant-TW
 *
 * @return
 * EN: A matching language model, or nil when unsupported
 * CN: 匹配的语言模型，不支持时返回 nil
 */
+ (nullable TSLanguageModel *)languageModelWithPreferredLanguageIdentifier:(nullable NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
