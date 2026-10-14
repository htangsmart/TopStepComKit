//
//  TSNpkDialBuildState.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TSNpkResPlan;
@class TSNpkScreenDocument;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Intermediate results handed from one build stage to the next
 * @chinese 在造包各阶段之间传递的中间结果
 *
 * @discussion
 * [EN]: Each property is written by exactly one stage and read by later ones.
 * [CN]: 每个属性只由一个阶段写入，供后面的阶段读取。
 */
@interface TSNpkDialBuildState : NSObject

/** @brief Written by the template stage @chinese 由模板阶段写入 */
@property (nonatomic, strong, nullable) TSNpkScreenDocument *screenDocument;
/** @brief Written by the preview stage @chinese 由预览图阶段写入 */
@property (nonatomic, strong, nullable) UIImage *previewImage;
/** @brief Written by the res-plan stage @chinese 由替换计划阶段写入 */
@property (nonatomic, strong, nullable) TSNpkResPlan *resPlan;

@end

NS_ASSUME_NONNULL_END
