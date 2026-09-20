//
//  TSFitDialStyleConstraintMapper.h
//  TopStepFitKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSFitDialTemplateResource;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Maps Fit template resources to the provider-neutral dial-style constraint
 * @chinese 将 Fit 模板资源转换为 Provider 无关的表盘样式约束
 */
@interface TSFitDialStyleConstraintMapper : NSObject

/**
 * @brief Initialize with production non-GUI preview resources
 * @chinese 使用生产环境的非 GUI 预览资源初始化
 * @return EN: Initialized mapper. CN: 初始化后的转换器。
 */
- (instancetype)init;

/**
 * @brief Initialize with injectable non-GUI preview resources
 * @chinese 使用可注入的非 GUI 预览资源初始化
 * @param styleImageURLs EN: Style-name to local preview URL mapping. CN: 样式名称到本地预览地址的映射。
 * @return EN: Initialized mapper, or nil. CN: 初始化后的转换器，参数无效时为 nil。
 */
- (nullable instancetype)initWithNonGUIStyleImageURLs:(NSDictionary<NSString *, NSURL *> *)styleImageURLs
    NS_DESIGNATED_INITIALIZER;

/**
 * @brief Map a template catalog to a public constraint snapshot
 * @chinese 将模板目录转换为公开约束快照
 * @param resources EN: Fit template catalog. CN: Fit 模板目录。
 * @param screen EN: Current peripheral screen. CN: 当前设备屏幕。
 * @param error EN: Public dial error. CN: 公开表盘错误。
 * @return EN: Constraint snapshot, or nil. CN: 约束快照，失败时为 nil。
 */
- (nullable TSCustomDialStyleConstraint *)constraintFromResources:
    (NSArray<TSFitDialTemplateResource *> *)resources
                                                       screen:(TSPeripheralScreen *)screen
                                                        error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
