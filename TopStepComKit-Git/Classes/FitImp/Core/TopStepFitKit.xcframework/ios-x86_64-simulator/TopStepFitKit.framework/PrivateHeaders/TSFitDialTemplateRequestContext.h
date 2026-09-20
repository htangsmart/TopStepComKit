//
//  TSFitDialTemplateRequestContext.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/11.
//

#import <Foundation/Foundation.h>
#import <FitCloudKit/FitCloudKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Strongly typed parameters for a dial-template request
 * @chinese 表盘模板请求的强类型参数
 */
@interface TSFitDialTemplateRequestContext : NSObject

/** @brief LCD identifier @chinese LCD 标识 */
@property (nonatomic, assign, readonly) NSInteger lcd;
/** @brief Watch-face tool version @chinese 表盘工具版本 */
@property (nonatomic, copy, readonly) NSString *toolVersion;
/** @brief GUI platform identifier @chinese GUI 平台标识 */
@property (nonatomic, copy, readonly) NSString *platform;
/**
 * @brief Whether iOS reports the new GUI architecture
 * @chinese iOS 是否上报新 GUI 架构
 * @discussion
 * [EN]: This is the closest iOS equivalent to Android's GUI feature flag.
 * [CN]: 这是 iOS 对 Android GUI feature 标志的当前近似映射。
 */
@property (nonatomic, assign, readonly) BOOL isNextGUI;

/**
 * @brief Initialize a request context
 * @chinese 初始化请求上下文
 * @param lcd EN: LCD identifier. CN: LCD 标识。
 * @param toolVersion EN: Watch-face tool version. CN: 表盘工具版本。
 * @param platform EN: GUI platform identifier. CN: GUI 平台标识。
 * @param isNextGUI EN: Whether the GUI endpoint is required. CN: 是否使用 GUI 接口。
 * @return EN: Initialized context. CN: 初始化后的上下文。
 */
- (nullable instancetype)initWithLCD:(NSInteger)lcd
                toolVersion:(NSString *)toolVersion
                   platform:(NSString *)platform
                  isNextGUI:(BOOL)isNextGUI NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Parse parameters returned by TSDialModel+Fit
 * @chinese 解析 TSDialModel+Fit 返回的参数
 * @param parameters EN: Raw parameter dictionary. CN: 原始参数字典。
 * @param series EN: Current FitCloud SoC platform series. CN: 当前 FitCloud SoC 平台系列。
 * @param error EN: Parse error. CN: 解析错误。
 * @return EN: Valid context, or nil. CN: 有效上下文，失败时为 nil。
 */
+ (nullable instancetype)contextWithParameters:(NSDictionary *)parameters
                             socPlatformSeries:(FitCloudSoCPlatformSeries)series
                                          error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Stable key used by the one-hour response cache
 * @chinese 一小时响应缓存使用的稳定键
 * @return EN: Cache key. CN: 缓存键。
 */
- (NSString *)cacheKey;

@end

NS_ASSUME_NONNULL_END
