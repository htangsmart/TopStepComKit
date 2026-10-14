//
//  TSNpkDialStyleResponseParser.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>

@class TSNpkDialStyleResource;

NS_ASSUME_NONNULL_BEGIN

/** @brief NPK custom-dial cloud response parser @chinese NPK 自定义表盘云响应解析器 */
@interface TSNpkDialStyleResponseParser : NSObject

/**
 * @brief Parse and validate the first NPK template resource
 * @chinese 解析并校验首个 NPK 模板资源
 */
- (nullable TSNpkDialStyleResource *)parseResponseObject:(id)responseObject
                                                   error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
