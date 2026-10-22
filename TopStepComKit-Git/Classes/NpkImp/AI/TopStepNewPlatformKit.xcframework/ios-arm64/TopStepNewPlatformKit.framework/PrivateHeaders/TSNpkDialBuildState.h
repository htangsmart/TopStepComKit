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
@class TSNpkDialDanMuMaterial;
@class TSNpkDialVideoResult;

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

/**
 * @brief Prepared DanMu material
 * @chinese 已准备的弹幕素材
 *
 * @discussion
 * [EN]: Set by the DanMu material stage for reuse by preview, resource and screen stages; nil before preparation or in other modes.
 * [CN]: 由弹幕素材阶段写入，供预览、资源与屏幕阶段复用；准备前及其他模式下为 nil。
 */
@property (nonatomic, strong, nullable) TSNpkDialDanMuMaterial *danmuMaterial;
/**
 * @brief Processed video and matching cover
 * @chinese 已处理视频及匹配封面
 *
 * @discussion
 * [EN]: Set after the video stage succeeds; later stages reuse its file and cover instead of decoding the source again.
 * [CN]: 视频阶段成功后写入；后续阶段复用输出文件与封面，避免重新抽取源首帧；非视频模式为 nil。
 */
@property (nonatomic, strong, nullable) TSNpkDialVideoResult *videoResult;

/**
 * @brief Mutable screen document loaded from the template
 * @chinese 从模板载入的可变屏幕文档
 *
 * @discussion
 * [EN]: Set by the template stage, then read for planning and edited by the screen stage; nil before template validation.
 * [CN]: 模板阶段写入，随后用于资源规划并由屏幕阶段编辑；模板校验完成前为 nil。
 */
@property (nonatomic, strong, nullable) TSNpkScreenDocument *screenDocument;
/**
 * @brief Preview image prepared for later resource encoding
 * @chinese 已准备、供后续资源编码使用的预览图
 *
 * @discussion
 * [EN]: Set by the preview stage after explicit-preview or composed-preview selection; nil before that stage succeeds.
 * [CN]: 预览阶段完成显式预览或合成预览选择后写入；该阶段成功前为 nil。
 */
@property (nonatomic, strong, nullable) UIImage *previewImage;
/**
 * @brief Resource replacement and allocation plan
 * @chinese 资源替换与分配计划
 *
 * @discussion
 * [EN]: Set by the resource planning stage and shared by binary writing and screen reference updates; initially nil.
 * [CN]: 由资源规划阶段写入，供二进制写入与屏幕引用更新共用；初始为 nil。
 */
@property (nonatomic, strong, nullable) TSNpkResPlan *resPlan;

@end

NS_ASSUME_NONNULL_END
