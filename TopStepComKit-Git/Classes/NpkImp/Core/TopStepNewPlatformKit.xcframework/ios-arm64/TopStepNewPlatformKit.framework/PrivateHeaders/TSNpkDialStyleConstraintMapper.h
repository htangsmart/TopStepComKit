//
//  TSNpkDialStyleConstraintMapper.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSNpkDialStyleResource, TSNpkDialDeviceProfile, TSNpkDialGuiTemplateSnapshot;

NS_ASSUME_NONNULL_BEGIN

/** @brief Maps NPK cloud metadata to the public constraint @chinese 将 NPK 云元数据转换为公开约束 */
@interface TSNpkDialStyleConstraintMapper : NSObject

- (nullable TSCustomDialStyleConstraint *)constraintFromResource:(TSNpkDialStyleResource *)resource
                                                           screen:(TSPeripheralScreen *)screen
                                                            error:(NSError *_Nullable *_Nullable)error;

/**
 * @brief Map GUI metadata using verified template capabilities
 * @chinese 根据已验证模板能力映射 GUI 样式元数据
 *
 * @discussion
 * [EN]: Unsupported time customization returns empty options with tinting disabled.
 *       Supported templates require an exact metadata-to-template style count match.
 * [CN]: 不支持时间自定义时返回空选项并关闭染色；支持时要求元数据与模板样式数量严格一致。
 *
 * @param resource
 * EN: Metadata for the inspected GUI template.
 * CN: 被检查 GUI 模板对应的元数据。
 *
 * @param profile
 * EN: Device facts captured before the query.
 * CN: 查询开始前捕获的设备快照。
 *
 * @param templateSnapshot
 * EN: Verified template style and position capabilities.
 * CN: 已验证的模板样式与位置能力。
 *
 * @param error
 * EN: Optional output for invalid or inconsistent metadata.
 * CN: 可选错误输出，描述无效或不一致的元数据。
 *
 * @return
 * EN: Immutable public constraint, or nil on invalid input.
 * CN: 不可变公开约束；输入无效时返回 nil。
 */
- (nullable TSCustomDialStyleConstraint *)constraintFromResource:(TSNpkDialStyleResource *)resource
                                                        profile:(TSNpkDialDeviceProfile *)profile
                                                       template:(TSNpkDialGuiTemplateSnapshot *)templateSnapshot
                                                          error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
