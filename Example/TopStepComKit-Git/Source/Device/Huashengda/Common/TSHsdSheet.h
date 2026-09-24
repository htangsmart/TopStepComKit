//
//  TSHsdSheet.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSHsdViews.h"
#import "TSHsdReadbackDiff.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Value picker config
 * @chinese 数值滚轮配置：单列（min…max 逐 1）或「时 + 分」双列（value 为总分钟数）；另带快捷值与说明文字
 */
@interface TSHsdValuePickConfig : NSObject

/// 面板标题
@property (nonatomic, copy) NSString *title;
/// 取值下限 / 上限（含）
@property (nonatomic, assign) NSInteger minValue;
@property (nonatomic, assign) NSInteger maxValue;
/// YES：value 为总分钟数，显示「小时 + 分钟」双列滚轮；NO：单列滚轮
@property (nonatomic, assign) BOOL hourMinute;
/// 单列时的单位（滚轮下方标签、数值后缀）
@property (nonatomic, copy, nullable) NSString *unit;
/// 单列时 0 的显示文字（如「准时」）；nil 则显示 0
@property (nonatomic, copy, nullable) NSString *zeroText;
/// 快捷值及其按钮文字（两数组等长）
@property (nonatomic, copy) NSArray<NSNumber *> *quickValues;
@property (nonatomic, copy) NSArray<NSString *> *quickTitles;
/// 大字下方的说明文字，随选中值变化；可为 nil
@property (nonatomic, copy, nullable) NSString * _Nullable (^hintBlock)(NSInteger value);

/// 限制到 [minValue, maxValue]
- (NSInteger)clampValue:(NSInteger)value;

/// 「数字 + 单位」富文本：数字用 numberFont，单位用 unitFont 且带 unitColor
- (NSAttributedString *)attributedTextForValue:(NSInteger)value
                                    numberFont:(UIFont *)numberFont
                                      unitFont:(UIFont *)unitFont
                                         color:(UIColor *)color
                                     unitColor:(UIColor *)unitColor;

@end

/**
 * @brief Bottom sheet (.sheet)
 * @chinese 底部弹层：顶部圆角 30、标题 + 右上角按钮、可滚动的积木内容；时间 / 网格选择 / 金币调整 / 回读差异四种内容
 */
@interface TSHsdSheet : UIViewController

/// 通用：标题 + 右上角按钮 + 积木
+ (instancetype)sheetWithTitle:(NSString *)title
                   buttonTitle:(NSString *)buttonTitle
                        blocks:(NSArray<UIView *> *)blocks
                      onButton:(nullable void (^)(void))onButton;

/// 时间：大字 + 时 / 分滚轮 + 快捷时间；点「完成」回调分钟偏移
+ (void)presentTimeFrom:(UIViewController *)presenter
                  title:(NSString *)title
                 minute:(NSInteger)minute
                    hue:(UIColor *)hue
                 onPick:(void (^)(NSInteger minute))onPick;

/// 数值：大字 + 说明 + 滚轮（单列或时 / 分双列）+ 快捷值；点「完成」回调新值，点遮罩关闭不回调
+ (void)presentValueFrom:(UIViewController *)presenter
                  config:(TSHsdValuePickConfig *)config
                   value:(NSInteger)value
                     hue:(UIColor *)hue
                  onPick:(void (^)(NSInteger value))onPick;

/// 网格选择（4 列瓦片：右上角序号、图标、名称）；点瓦片立即回调并关闭
+ (void)presentGridFrom:(UIViewController *)presenter
                  title:(NSString *)title
            buttonTitle:(NSString *)buttonTitle
                 titles:(NSArray<NSString *> *)titles
                symbols:(NSArray<NSString *> *)symbols
                indexes:(NSArray<NSNumber *> *)indexes
               selected:(NSInteger)selected
                    hue:(UIColor *)hue
               footNote:(nullable NSString *)footNote
                 onPick:(void (^)(NSInteger index))onPick;

/// 金币调整：大步进器 + 预设；点「完成」回调新值
+ (void)presentCoinsFrom:(UIViewController *)presenter
                   value:(NSInteger)value
                     hue:(UIColor *)hue
                  onDone:(void (^)(NSInteger value))onDone;

/// 回读差异表
+ (void)presentDiffFrom:(UIViewController *)presenter items:(NSArray<TSHsdDiffItem *> *)items;

- (void)presentFrom:(UIViewController *)presenter;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
