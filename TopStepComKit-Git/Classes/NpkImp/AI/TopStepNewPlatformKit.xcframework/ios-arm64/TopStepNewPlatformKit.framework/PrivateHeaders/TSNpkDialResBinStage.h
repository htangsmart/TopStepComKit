//
//  TSNpkDialResBinStage.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import "TSNpkDialBuildStage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stage 5: rebuild res.bin according to the plan (encode, lay out, patch font table, write)
 * @chinese 阶段 5：按计划重建 res.bin（编码、排布、修正字体表、写文件）
 */
@interface TSNpkDialResBinStage : NSObject <TSNpkDialBuildStage>
@end

NS_ASSUME_NONNULL_END
