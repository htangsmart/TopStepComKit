//
//  TSNpkDialStyleRequestContext.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Strong NPK custom-dial request parameters @chinese NPK 自定义表盘请求强类型参数 */
@interface TSNpkDialStyleRequestContext : NSObject

@property (nonatomic, copy, readonly) NSString *lcdSize;
@property (nonatomic, copy, readonly) NSString *toolVersion;
@property (nonatomic, assign, readonly) BOOL hasComponent;
@property (nonatomic, copy, readonly) NSString *platformType;

/**
 * @brief Build request parameters from the current NPK peripheral
 * @chinese 根据当前 NPK 外设构建请求参数
 * @param peripheral EN: Connected NPK peripheral. CN: 已连接的 NPK 外设。
 * @param error EN: Public dial error. CN: 公开表盘错误。
 * @return EN: Valid context, or nil. CN: 有效上下文，失败时为 nil。
 */
+ (nullable instancetype)contextWithPeripheral:(TSPeripheral *)peripheral
                                         error:(NSError *_Nullable *_Nullable)error;

/** @brief JSON body expected by the NPK cloud service @chinese NPK 云服务要求的 JSON 请求体 */
- (NSDictionary<NSString *, id> *)requestParameters;

/** @brief Stable metadata cache key @chinese 稳定的元数据缓存键 */
- (NSString *)cacheKey;

@end

NS_ASSUME_NONNULL_END
