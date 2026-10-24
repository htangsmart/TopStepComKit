//
//  TSNpkDialTemplateValidator.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSNpkScreenDocument;
@class TSNpkDialDeviceProfile;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Checks that an unpacked dial content directory can be used for a draft type
 * @chinese 校验解压出来的表盘内容目录能否用于某种草稿类型
 *
 * @discussion
 * [EN]: Checks: the three files exist, the res.bin platform marker matches the connected device, and screen.json
 *       matches the draft type. Widgets are found through TSNpkScreenLocator, so templates made before the naming
 *       convention pass as long as their structure is right.
 * [CN]: 校验三件事：三个文件齐全、res.bin 平台标记与已连接设备一致、screen.json 与草稿类型匹配。
 *       控件通过 TSNpkScreenLocator 查找，所以命名约定之前的模板只要结构正确也能通过。
 */
@interface TSNpkDialTemplateValidator : NSObject

/**
 * @brief Validate and return the loaded screen document
 * @chinese 校验并返回已读入的 screen 文档
 *
 * @return EN: The loaded screen.json, or nil with an error. CN: 已读入的 screen.json；失败返回 nil 并给出错误。
 */
+ (nullable TSNpkScreenDocument *)validateContentDirectory:(NSString *)contentDirectory
                                                 draftType:(TSDialDraftType)draftType
                                                     error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Validate against the frozen platform profile.
 * @chinese 使用冻结的平台快照校验模板。
 * @param contentDirectory EN: Extracted content path. CN: 解压后的内容路径。
 * @param draftType EN: Effective mode. CN: 有效模式。
 * @param profile EN: Frozen device profile. CN: 冻结的设备快照。
 * @param error EN: Failure details. CN: 失败信息。
 * @return EN: Loaded document or nil. CN: 文档或 nil。
 */
+ (nullable TSNpkScreenDocument *)validateContentDirectory:(NSString *)contentDirectory draftType:(TSDialDraftType)draftType profile:(nullable TSNpkDialDeviceProfile *)profile error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
