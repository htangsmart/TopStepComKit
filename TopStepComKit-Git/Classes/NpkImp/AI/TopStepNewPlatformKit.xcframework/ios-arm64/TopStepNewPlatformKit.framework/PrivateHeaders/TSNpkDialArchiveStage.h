//
//  TSNpkDialArchiveStage.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import "TSNpkDialBuildStage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stage 8: pack the content directory into the output tar
 * @chinese 阶段 8：把内容目录打成输出 tar 包
 */
@interface TSNpkDialArchiveStage : NSObject <TSNpkDialBuildStage>
@end

NS_ASSUME_NONNULL_END
