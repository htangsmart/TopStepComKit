//
//  TSNpkResPlanners.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import "TSNpkResPlan.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Single image: preview at index 0, background at the index the background widget points to
 * @chinese 单图：预览图在下标 0，背景图在背景控件 Source.Value 指向的下标
 */
@interface TSNpkSingleImageResPlanner : NSObject <TSNpkResPlanner>
@end

/**
 * @brief Multiple images: backgrounds take the 10 preset slots; unused slots are removed, extra images are appended
 * @chinese 多图：背景图占用 10 个预设槽位；用不到的槽位移除，超出的图片追加到末尾
 */
@interface TSNpkMultiImageResPlanner : NSObject <TSNpkResPlanner>
@end

/**
 * @brief Video: only the preview at index 0 changes
 * @chinese 视频：只改下标 0 的预览图
 */
@interface TSNpkVideoResPlanner : NSObject <TSNpkResPlanner>
@end

NS_ASSUME_NONNULL_END
