//
//  TSDialCapability+Internal.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/20.
//

#import "TSDialCapability.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSDialCapability ()

/**
 * @brief Set scrolling-overlay support before publishing the capability snapshot
 * @chinese Provider 在返回能力快照前设置弹幕支持状态
 *
 * @discussion
 * [EN]: Defaults to NO. Set only while constructing the snapshot, before returning it to callers.
 * [CN]: 默认为 NO，仅在构建快照期间赋值，不得修改已经返回给调用方的快照。
 */
@property (nonatomic, assign, readwrite) BOOL supportsDanMu;

/**
 * @brief Set the time overlay policy before publishing the capability snapshot
 * @chinese Provider 在返回能力快照前设置预览时间渲染策略
 *
 * @discussion
 * [EN]: Defaults to NO. Set only while constructing the snapshot.
 * [CN]: 默认为 NO，仅在构建快照期间赋值，不得修改已经返回给调用方的快照。
 */
@property (nonatomic, assign, readwrite) BOOL shouldRenderTimeInPreview;

- (instancetype)initWithSupportsCustom:(BOOL)supportsCustom
                         supportsVideo:(BOOL)supportsVideo
                      maxVideoDuration:(NSInteger)maxVideoDuration
                     supportsSlideshow:(BOOL)supportsSlideshow
                    maxSlideshowImages:(NSInteger)maxSlideshowImages
                         colorTintable:(BOOL)colorTintable
                     supportsComponent:(BOOL)supportsComponent
                       maxInstallCount:(NSInteger)maxInstallCount
                          maxInnerCount:(NSInteger)maxInnerCount
                           screenWidth:(NSInteger)screenWidth
                          screenHeight:(NSInteger)screenHeight
                    deviceCornerRadius:(CGFloat)deviceCornerRadius
                          previewWidth:(NSInteger)previewWidth
                         previewHeight:(NSInteger)previewHeight
                   previewCornerRadius:(CGFloat)previewCornerRadius
                                 shape:(TSPeriphShape)shape NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
