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
 * @brief Stage 2: encode the user's video into videos/0.hex (video drafts only)
 * @chinese 阶段 2：把用户视频编码成 videos/0.hex（仅视频草稿）
 *
 * @discussion
 * [EN]: Other draft types pass through untouched. Any videos directory shipped inside the template is removed first.
 * [CN]: 其它草稿类型直接通过。模板自带的 videos 目录会先被清空。
 */
@interface TSNpkDialVideoStage : NSObject <TSNpkDialBuildStage>
@end

NS_ASSUME_NONNULL_END
