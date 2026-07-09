//
//  TSAITTSSpeakerSelector.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Speaker entry { id, displayName }
 * @chinese 发音人条目 { id, 展示名称 }
 */
@interface TSAITTSSpeakerEntry : NSObject

@property (nonatomic, copy) NSString *speakerId;
@property (nonatomic, copy) NSString *displayName;

+ (instancetype)entryWithId:(NSString *)speakerId displayName:(NSString *)displayName;

@end

@class TSAITTSSpeakerSelector;

/**
 * @brief Speaker selector delegate
 * @chinese 发音人选择器委托
 */
@protocol TSAITTSSpeakerSelectorDelegate <NSObject>

/// 用户选中某个 speakerId（含点击 chip 与自定义后自动选中）
- (void)speakerSelector:(TSAITTSSpeakerSelector *)selector didSelectSpeakerId:(NSString *)speakerId;
/// 用户点击「自定义…」按钮，宿主 VC 应弹出 alert 让用户输入
- (void)speakerSelectorDidRequestCustomSpeaker:(TSAITTSSpeakerSelector *)selector;

@end

/**
 * @brief Horizontal speaker chip selector
 * @chinese 横向发音人 chip 选择器
 *
 * @discussion
 * [EN]: Renders a card with a title bar (section title + "Custom…" entry) and
 *       a horizontal scrollview of speaker chips. Selection state is owned by
 *       the host (set via -setSelectedSpeakerId:); the selector only emits
 *       selection intent.
 * [CN]: 渲染一张卡片，含标题栏（区域标题 + 「自定义…」入口）和横向 chip
 *       列表。选中态由宿主管理（通过 -setSelectedSpeakerId: 写入），
 *       选择器自身只发出选择意图。
 */
@interface TSAITTSSpeakerSelector : UIView

/// 委托
@property (nonatomic, weak, nullable) id<TSAITTSSpeakerSelectorDelegate> delegate;
/// 当前选中的 speakerId
@property (nonatomic, copy, nullable, readonly) NSString *selectedSpeakerId;
/// chip 是否可交互（合成 / 播放过程中应置为 NO）
@property (nonatomic, assign) BOOL chipsEnabled;

/**
 * @brief Reset speaker list and rebuild chips
 * @chinese 重置发音人列表并重建 chip
 *
 * @param entries
 * EN: Ordered speaker entries (built-in + custom merged by the host)
 * CN: 有序发音人条目（内置 + 自定义由宿主合并后传入）
 */
- (void)setSpeakerEntries:(NSArray<TSAITTSSpeakerEntry *> *)entries;

/**
 * @brief Update the selected speaker ID and refresh chip styles
 * @chinese 更新选中的 speakerId 并刷新 chip 样式
 */
- (void)setSelectedSpeakerId:(nullable NSString *)speakerId;

@end

NS_ASSUME_NONNULL_END
