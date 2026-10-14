//
//  TSHsdParentalControlItemVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Parental-control item editor (third level)
 * @chinese 家长模式（进阶版）功能项编辑页：启用开关 / 时段内行为 / 生效时段列表（开始、结束、重复）
 *
 * @discussion
 * [EN]: Edits one TSHsdParentalControlItemModel in place of the draft held by TSHsdParentalControlVC.
 *       Nothing is sent to the watch here; "Done" hands the copy back through onDone.
 * [CN]: 编辑 TSHsdParentalControlVC 草稿中的一个功能项；本页不下发，点「完成」通过 onDone 交回副本。
 *       时段上限为 maxPeriodCount（来自 parentalControlMaxPeriodCount），开始 == 结束表示全天，结束早于开始表示跨天。
 */
@interface TSHsdParentalControlItemVC : TSHsdBaseVC

/**
 * @brief Controlled action this page edits
 * @chinese 本页编辑的受控动作（决定标题与图标）
 */
@property (nonatomic, assign) TSHsdParentalControlFunction function;

/**
 * @brief Existing item; nil creates a new one for `function`
 * @chinese 已有功能项；为 nil 时按 function 新建
 */
@property (nonatomic, strong, nullable) TSHsdParentalControlItemModel *item;

/**
 * @brief Maximum periods per item
 * @chinese 每项最多时段数（TSHuashengdaInterface.parentalControlMaxPeriodCount）
 */
@property (nonatomic, assign) NSUInteger maxPeriodCount;

/**
 * @brief Called with the edited copy when "Done" is tapped
 * @chinese 点「完成」时回调编辑后的副本
 */
@property (nonatomic, copy, nullable) void (^onDone)(TSHsdParentalControlItemModel *item);

/**
 * @brief Called when the user removes the item from the list; nil hides the remove link
 * @chinese 用户选择「从列表移除」时回调；为 nil 时不显示移除入口
 */
@property (nonatomic, copy, nullable) void (^onRemove)(void);

@end

NS_ASSUME_NONNULL_END
