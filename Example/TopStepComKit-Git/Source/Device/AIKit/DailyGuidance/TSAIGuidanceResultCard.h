//
//  TSAIGuidanceResultCard.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AI daily guidance result card view
 * @chinese AI 每日健康引导结果卡片视图
 *
 * @discussion
 * [EN]: A reusable white card that renders a TSAIDailyGuidanceResult: an icon +
 *       title header, a main guidance paragraph, a checklist of action items and
 *       a disclaimer. It lays out purely with frames and exposes heightForWidth:
 *       so callers using manual frame layout (e.g. the home page) can size it.
 * [CN]: 可复用的白色卡片，用于展示 TSAIDailyGuidanceResult：图标+标题头部、
 *       主引导文案、✓行动建议清单与免责声明。内部使用 frame 布局，并提供
 *       heightForWidth: 供手动 frame 布局的调用方（如首页）计算高度。
 */
@interface TSAIGuidanceResultCard : UIView

/**
 * @brief Card header title
 * @chinese 卡片头部标题
 *
 * @discussion
 * [EN]: Title shown next to the icon, e.g. "AI Health Tips" or "Result".
 * [CN]: 显示在图标旁的标题，如「AI 健康提示」或「生成结果」。
 */
@property (nonatomic, copy) NSString *cardTitle;

/**
 * @brief Configure card content from a guidance result
 * @chinese 使用引导结果配置卡片内容
 *
 * @param mainText
 * EN: Main guidance paragraph; pass nil/empty to show a placeholder.
 * CN: 主引导文案；传 nil/空 时显示占位提示。
 *
 * @param actionItems
 * EN: Action item strings; pass nil/empty to hide the checklist.
 * CN: 行动建议文案数组；传 nil/空 时隐藏清单。
 *
 * @param disclaimer
 * EN: Disclaimer text; pass nil to use the built-in localized default.
 * CN: 免责声明文案；传 nil 时使用内置本地化默认文案。
 */
- (void)configureWithMainText:(nullable NSString *)mainText
                  actionItems:(nullable NSArray<NSString *> *)actionItems
                   disclaimer:(nullable NSString *)disclaimer;

/**
 * @brief Calculate the height needed for the given width
 * @chinese 计算给定宽度下所需的高度
 *
 * @param width
 * EN: Target card width in points.
 * CN: 目标卡片宽度（point）。
 *
 * @return
 * EN: Total height in points fitting the current content.
 * CN: 适配当前内容的总高度（point）。
 */
- (CGFloat)heightForWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
