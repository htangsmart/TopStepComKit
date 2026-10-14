//
//  TSNpkDialResPlanStage.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import "TSNpkDialBuildStage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stage 4: decide which res.bin images are replaced, removed or added
 * @chinese 阶段 4：决定 res.bin 里哪些图片被替换、移除或新增
 */
@interface TSNpkDialResPlanStage : NSObject <TSNpkDialBuildStage>
@end

NS_ASSUME_NONNULL_END
