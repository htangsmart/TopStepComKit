//
//  TSDeviceMenuBuilder.h
//  TopStepComKit_Example
//
//  Created by Codex on 2026/8/30.
//

#import <Foundation/Foundation.h>

@class TSDeviceConnectionSnapshot;
@class TSValueModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Builds device menu models from one connection snapshot
 * @chinese 根据统一连接快照构建设备菜单模型
 */
@interface TSDeviceMenuBuilder : NSObject

/**
 * @brief Build feature, settings and danger menu sections
 * @chinese 构建功能、设置与危险操作菜单分组
 *
 * @param snapshot
 * EN: Current immutable device connection snapshot.
 * CN: 当前不可变设备连接快照。
 *
 * @return
 * EN: Three menu sections containing TSValueModel items.
 * CN: 包含 TSValueModel 的三个菜单分组。
 */
+ (NSArray<NSArray<TSValueModel *> *> *)sectionDataWithSnapshot:(TSDeviceConnectionSnapshot *)snapshot;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
