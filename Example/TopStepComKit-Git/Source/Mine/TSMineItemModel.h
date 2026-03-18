//
//  TSMineItemModel.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Mine page item model
 * @chinese 我的页面列表项模型
 *
 * @discussion
 * [EN]: Represents a single item in the mine page settings list
 * [CN]: 表示我的页面设置列表中的单个项目
 */
@interface TSMineItemModel : NSObject

/**
 * @brief Icon name (SF Symbol)
 * @chinese 图标名称（SF Symbol）
 */
@property (nonatomic, copy) NSString *iconName;

/**
 * @brief Item title
 * @chinese 项目标题
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Detail text (optional)
 * @chinese 详情文字（可选）
 */
@property (nonatomic, copy, nullable) NSString *detail;

/**
 * @brief Action identifier
 * @chinese 操作标识符
 */
@property (nonatomic, copy) NSString *action;

/**
 * @brief Create item model
 * @chinese 创建项目模型
 *
 * @param iconName
 * EN: SF Symbol icon name
 * CN: SF Symbol 图标名称
 *
 * @param title
 * EN: Item title
 * CN: 项目标题
 *
 * @param detail
 * EN: Detail text, can be nil
 * CN: 详情文字，可为 nil
 *
 * @param action
 * EN: Action identifier for handling tap
 * CN: 用于处理点击的操作标识符
 *
 * @return
 * EN: Item model instance
 * CN: 项目模型实例
 */
+ (instancetype)itemWithIcon:(NSString *)iconName
                       title:(NSString *)title
                      detail:(nullable NSString *)detail
                      action:(NSString *)action;

@end

NS_ASSUME_NONNULL_END
