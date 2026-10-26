//
//  TSFitDialTemplateCloudConfiguration.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Injectable endpoints and timing for the dial-template cloud service
 * @chinese 表盘模板云服务的可注入地址与时间配置
 */
@interface TSFitDialTemplateCloudConfiguration : NSObject

/**
 * @brief New GUI template endpoint
 * @chinese 新 GUI 模板接口地址
 * @discussion
 * [EN]: Used by GUI 568X and 579X before an eligible legacy fallback.
 * [CN]: GUI 568X、579X 优先使用，满足条件时回退旧接口。
 * @note
 * [EN]: The default matches the Android test.ssmartlink.com endpoint.
 * [CN]: 默认与 Android 的 test.ssmartlink.com 接口一致。
 */
@property (nonatomic, strong, readonly) NSURL *customDialEndpointURL;

/** @brief Production GUI endpoint @chinese 生产 GUI 接口地址 */
@property (nonatomic, strong, readonly) NSURL *guiEndpointURL;
/** @brief Production non-GUI endpoint @chinese 生产非 GUI 接口地址 */
@property (nonatomic, strong, readonly) NSURL *nonGUIEndpointURL;
/** @brief In-memory response cache duration @chinese 内存响应缓存时长 */
@property (nonatomic, assign, readonly) NSTimeInterval cacheInterval;
/** @brief Template metadata request timeout @chinese 模板元数据请求超时 */
@property (nonatomic, assign, readonly) NSTimeInterval requestTimeout;

/**
 * @brief Return the production configuration
 * @chinese 返回生产环境配置
 * @return EN: Production configuration. CN: 生产环境配置。
 */
+ (instancetype)productionConfiguration;

/**
 * @brief Initialize a cloud configuration
 * @chinese 初始化云服务配置
 * @param guiEndpointURL EN: GUI endpoint. CN: GUI 接口地址。
 * @param nonGUIEndpointURL EN: Non-GUI endpoint. CN: 非 GUI 接口地址。
 * @param cacheInterval EN: Response cache duration. CN: 响应缓存时长。
 * @param requestTimeout EN: Metadata request timeout. CN: 元数据请求超时。
 * @return EN: Initialized configuration. CN: 初始化后的配置。
 */
- (nullable instancetype)initWithGUIEndpointURL:(NSURL *)guiEndpointURL
                     nonGUIEndpointURL:(NSURL *)nonGUIEndpointURL
                         cacheInterval:(NSTimeInterval)cacheInterval
                        requestTimeout:(NSTimeInterval)requestTimeout;

/**
 * @brief Initialize both template protocols with injectable endpoints
 * @chinese 使用可注入地址初始化新旧模板协议
 * @param newGUIEndpointURL
 * EN: New GUI endpoint.
 * CN: 新 GUI 接口地址。
 * @param guiEndpointURL
 * EN: Legacy GUI endpoint.
 * CN: 旧 GUI 接口地址。
 * @param nonGUIEndpointURL
 * EN: Legacy non-GUI endpoint.
 * CN: 旧非 GUI 接口地址。
 * @param cacheInterval
 * EN: Response cache duration in seconds.
 * CN: 响应缓存时长，单位为秒。
 * @param requestTimeout
 * EN: Metadata request timeout in seconds.
 * CN: 元数据请求超时，单位为秒。
 * @return
 * EN: An immutable configuration, or nil for missing endpoints.
 * CN: 不可变配置，缺少地址时返回 nil。
 */
- (nullable instancetype)initWithNewGUIEndpointURL:(NSURL *)newGUIEndpointURL
                                   guiEndpointURL:(NSURL *)guiEndpointURL
                                nonGUIEndpointURL:(NSURL *)nonGUIEndpointURL
                                    cacheInterval:(NSTimeInterval)cacheInterval
                                   requestTimeout:(NSTimeInterval)requestTimeout NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
