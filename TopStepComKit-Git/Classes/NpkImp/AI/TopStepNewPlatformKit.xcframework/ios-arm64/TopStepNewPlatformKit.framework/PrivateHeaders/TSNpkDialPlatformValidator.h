//
//  TSNpkDialPlatformValidator.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Validates PB dial contents against the connected platform @chinese 校验 PB 表盘内容与连接平台是否匹配 */
@interface TSNpkDialPlatformValidator : NSObject

+ (BOOL)validateContentDirectory:(NSString *)directoryPath
                           error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
