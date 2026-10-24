//
//  TSDialVideoRequirements+Internal.h
//  TopStepInterfaceKit
//
//  Created by Codex on 2026/10/20.
//

#import "TSDialVideoRequirements.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSDialVideoRequirements ()

/**
 * @brief Capture validated prepared-video requirements in one immutable object
 * @chinese 一次捕获已校验的成品视频要求，构造不可变对象
 *
 * @param quality
 * EN: Supported quality lookup key, including Default when implemented.
 * CN: 受支持的质量查询键，实现默认路径时须使用 Default 键。
 * @param inputPixelSize
 * EN: Validated positive integer input pixels before device storage rotation.
 * CN: 已校验的正整数输入像素尺寸，位于设备存储旋转之前。
 * @param maxDuration
 * EN: Validated finite positive maximum duration in seconds.
 * CN: 已校验的有限正数最大时长，单位秒。
 * @param inputShape
 * EN: Shape required for the prepared canvas, not necessarily the screen shape.
 * CN: 成品画布要求的形状，不一定等同于屏幕形状。
 * @param cornerRadius
 * EN: Validated finite nonnegative radius in input pixels; ignored for circles.
 * CN: 已校验的有限非负输入像素圆角半径，圆形不使用。
 * @param supportsAudio
 * EN: Whether this contract permits source audio.
 * CN: 当前合同是否允许源音轨。
 * @return
 * EN: A value snapshot with no mutable configuration phase.
 * CN: 无后续可写配置阶段的值快照。
 */
- (instancetype)initWithQuality:(TSDialQuality)quality
                 inputPixelSize:(CGSize)inputPixelSize
                    maxDuration:(NSTimeInterval)maxDuration
                     inputShape:(TSPeriphShape)inputShape
                   cornerRadius:(CGFloat)cornerRadius
                  supportsAudio:(BOOL)supportsAudio NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
