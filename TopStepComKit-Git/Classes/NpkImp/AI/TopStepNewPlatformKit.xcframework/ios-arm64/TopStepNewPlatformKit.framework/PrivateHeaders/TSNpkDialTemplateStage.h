//
//  TSNpkDialTemplateStage.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import "TSNpkDialBuildStage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stage 1: produce a validated dial content directory and the loaded screen document
 * @chinese 阶段 1：得到校验过的表盘内容目录和已读入的 screen 文档
 */
@interface TSNpkDialTemplateStage : NSObject <TSNpkDialBuildStage>
@end

NS_ASSUME_NONNULL_END
