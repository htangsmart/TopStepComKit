//
//  TSAIQAEmptyStateView.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSAIQAEmptyStateView;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Callback of the empty state view
 * @chinese 空态视图的回调
 */
@protocol TSAIQAEmptyStateViewDelegate <NSObject>

/**
 * @brief A suggested question was tapped
 * @chinese 点击了一条推荐问题
 *
 * @param view
 * EN: Source view
 * CN: 来源视图
 *
 * @param question
 * EN: Suggested question text
 * CN: 推荐问题文本
 */
- (void)emptyStateView:(TSAIQAEmptyStateView *)view didSelectSuggestion:(NSString *)question;

@end

/**
 * @brief Empty state of the text mode: orb, title, subtitle and suggested questions
 * @chinese 文字模式空态：光球、标题、副标题与推荐问题
 */
@interface TSAIQAEmptyStateView : UIView

/**
 * @brief Interaction delegate
 * @chinese 交互代理
 */
@property (nonatomic, weak, nullable) id<TSAIQAEmptyStateViewDelegate> delegate;

/**
 * @brief Suggested questions rendered as tappable rows
 * @chinese 以可点击行渲染的推荐问题
 */
@property (nonatomic, copy) NSArray<NSString *> *suggestions;

/**
 * @brief Whether suggestion rows are enabled
 * @chinese 推荐行是否可点击
 */
@property (nonatomic, assign) BOOL suggestionsEnabled;

/**
 * @brief Preferred height for a given width
 * @chinese 指定宽度下的推荐高度
 *
 * @param width
 * EN: Available width
 * CN: 可用宽度
 *
 * @param count
 * EN: Number of suggestions
 * CN: 推荐问题数量
 *
 * @return
 * EN: Height in points
 * CN: 高度（pt）
 */
+ (CGFloat)heightForWidth:(CGFloat)width suggestionCount:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
