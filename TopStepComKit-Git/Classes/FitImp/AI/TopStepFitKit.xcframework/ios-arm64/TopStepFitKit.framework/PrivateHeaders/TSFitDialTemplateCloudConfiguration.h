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
                        requestTimeout:(NSTimeInterval)requestTimeout NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
