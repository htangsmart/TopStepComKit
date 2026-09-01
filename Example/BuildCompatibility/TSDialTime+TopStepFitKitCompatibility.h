//
//  TSDialTime+TopStepFitKitCompatibility.h
//  TopStepComKit-Git_Example
//
//  Created by Codex on 2026/8/28.
//

#if defined(__OBJC__)

#import <TopStepInterfaceKit/TSDialTime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Compile-time compatibility declaration for TopStepFitKit
 * @chinese TopStepFitKit 的编译期兼容声明
 *
 * @discussion
 * [EN]: TSDialTime implements this setter internally, while its public property is readonly.
 * [CN]: TSDialTime 内部已实现该 setter，但公共属性被声明为只读。
 */
@interface TSDialTime (TopStepFitKitCompatibility)

/**
 * @brief Writable time style image used by the current TopStepFitKit implementation
 * @chinese 当前 TopStepFitKit 实现使用的可写时间样式图片
 */
@property (nonatomic, strong, nullable, readwrite) UIImage *timeImage;

@end

NS_ASSUME_NONNULL_END

#endif
