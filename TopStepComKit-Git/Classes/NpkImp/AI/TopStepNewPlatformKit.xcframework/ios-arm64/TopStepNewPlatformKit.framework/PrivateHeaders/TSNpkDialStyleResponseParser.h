//
//  TSNpkDialStyleResponseParser.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>

@class TSNpkDialStyleResource;
@class TSNpkDialStyleRequestContext;

NS_ASSUME_NONNULL_BEGIN

/** @brief NPK custom-dial cloud response parser @chinese NPK 自定义表盘云响应解析器 */
@interface TSNpkDialStyleResponseParser : NSObject

/**
 * @brief Parse and validate the first NPK template resource
 * @chinese 解析并校验首个 NPK 模板资源
 */
- (nullable TSNpkDialStyleResource *)parseResponseObject:(id)responseObject
                                                   error:(NSError *_Nullable *_Nullable)error;

/** @brief Parse a platform-specific response. @chinese 解析平台对应响应。
 * @param responseObject EN: JSON value. CN: JSON 对象。
 * @param context EN: Frozen request context. CN: 请求快照。
 * @param legacy EN: Legacy GUI schema. CN: 是否旧 GUI 响应格式。
 * @param error EN: Parsing error. CN: 解析错误。
 * @return EN: Validated typed result. CN: 校验后的类型化结果。 */
- (nullable TSNpkDialStyleResource *)parseResponseObject:(id)responseObject
    context:(TSNpkDialStyleRequestContext *)context legacy:(BOOL)legacy error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
