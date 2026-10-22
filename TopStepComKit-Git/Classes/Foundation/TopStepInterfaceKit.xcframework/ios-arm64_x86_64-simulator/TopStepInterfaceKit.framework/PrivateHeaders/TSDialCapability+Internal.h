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
 * @brief Explicit quality presets configured by the Provider
 * @chinese Provider 配置的显式画质档位
 *
 * @discussion
 * [EN]: Defaults to an empty array. Supply NSNumber-wrapped TSDialQuality values
 *       supported by the actual build path, excluding Default. Set only before
 *       publishing the snapshot; an empty array does not disable legacy defaults.
 * [CN]: 默认为空数组。填写实际造包路径支持的 TSDialQuality NSNumber 值，
 *       不包含 Default。仅在发布快照前设置；空数组不关闭旧调用的默认行为。
 */
@property (nonatomic, copy, readwrite) NSArray<NSNumber *> *qualityLevels;

/**
 * @brief Prepared-video requirements indexed by supported quality
 * @chinese 按受支持质量索引的成品视频要求
 *
 * @discussion
 * [EN]: Defaults to an empty dictionary. Assignment copies the dictionary; values
 *       are immutable TSDialVideoRequirements snapshots. Each NSNumber quality key
 *       must match the value's quality. Include Default explicitly when supported,
 *       and omit unimplemented qualities. Set only before publishing this capability.
 * [CN]: 默认空字典，赋值复制字典，值为不可变 TSDialVideoRequirements 快照。
 *       每个 NSNumber 质量键须与值的 quality 一致；支持 Default 时须明确提供，
 *       未实现的档位不加入字典。仅在发布当前能力快照前设置。
 */
@property (nonatomic, copy) NSDictionary<NSNumber *, TSDialVideoRequirements *> *videoRequirementsByQuality;

/**
 * @brief Set scrolling-overlay support before publishing the capability snapshot
 * @chinese Provider 在返回能力快照前设置弹幕支持状态
 *
 * @discussion
 * [EN]: Defaults to NO. Combine device restrictions with an implemented DanMu build
 *       path before enabling it. Set only while constructing the snapshot,
 *       before returning it to callers.
 * [CN]: 默认为 NO，必须同时满足设备限制和弹幕造包实现条件才可开启。
 *       仅在构建快照期间赋值，不得修改已经返回给调用方的快照。
 */
@property (nonatomic, assign, readwrite) BOOL supportsDanMu;

/**
 * @brief Set the time overlay policy before publishing the capability snapshot
 * @chinese Provider 在返回能力快照前设置预览时间渲染策略
 *
 * @discussion
 * [EN]: Defaults to NO. This governs SDK-composed previews only and remains
 *       independent of supportsComponent. It does not create a device clock or
 *       alter an explicit preview. Set only before publishing the snapshot.
 * [CN]: 默认为 NO，仅控制 SDK 合成的预览，与 supportsComponent 独立；
 *       不创建手表时钟，也不修改显式传入的预览。仅在发布快照前设置。
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
