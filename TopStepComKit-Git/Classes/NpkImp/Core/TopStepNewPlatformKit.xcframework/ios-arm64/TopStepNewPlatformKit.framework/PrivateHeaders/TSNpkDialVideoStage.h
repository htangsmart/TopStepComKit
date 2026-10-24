//
//  TSNpkDialVideoStage.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import "TSNpkDialBuildStage.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Stage 2: encode W30 HEX or 579X AVI/LGEX and retain the processed cover
 * @chinese 阶段 2：编码 W30 HEX 或 579X AVI/LGEX，并保留实际处理封面
 *
 * @discussion
 * [EN]: Other draft types pass through untouched. Any videos directory shipped inside the template is removed first.
 * [CN]: 其它草稿类型直接通过。模板自带的 videos 目录会先被清空。
 */
@interface TSNpkDialVideoStage : NSObject <TSNpkDialBuildStage>
@end

NS_ASSUME_NONNULL_END
