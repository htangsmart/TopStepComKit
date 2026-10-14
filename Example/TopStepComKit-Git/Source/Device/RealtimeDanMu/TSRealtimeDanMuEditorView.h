//
//  TSRealtimeDanMuEditorView.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

@class TSRealtimeDanMuDraft;

NS_ASSUME_NONNULL_BEGIN

/** @brief Draft field keys reported by onValueChanged. @chinese onValueChanged 回调使用的字段键。 */
FOUNDATION_EXPORT NSString *const kTSRealtimeDanMuFieldText;
FOUNDATION_EXPORT NSString *const kTSRealtimeDanMuFieldType;
FOUNDATION_EXPORT NSString *const kTSRealtimeDanMuFieldFontSize;
FOUNDATION_EXPORT NSString *const kTSRealtimeDanMuFieldSpeed;
FOUNDATION_EXPORT NSString *const kTSRealtimeDanMuFieldAnimation;
FOUNDATION_EXPORT NSString *const kTSRealtimeDanMuFieldYCoordinate;
FOUNDATION_EXPORT NSString *const kTSRealtimeDanMuFieldColor;
/** @brief Random/fixed switch; value is a boxed BOOL meaning "random". @chinese 随机/指定切换，值为装箱 BOOL，表示是否随机。 */
FOUNDATION_EXPORT NSString *const kTSRealtimeDanMuFieldPositionRandom;

/**
 * @brief Numbered editing sections for one selected danmaku draft.
 * @chinese 针对选中弹幕草稿的编号编辑分节。
 *
 * @discussion
 * [EN]: Mirrors the section layout of TSDialDanMuView so the two editors read alike.
 *       The view owns no state; the host passes drafts in and receives field changes back.
 * [CN]: 沿用 TSDialDanMuView 的分节排版，使两个编辑器观感一致。
 *       视图本身不持有状态，宿主传入草稿并接收字段变更。
 */
@interface TSRealtimeDanMuEditorView : UIView

/** @brief Height required by the current content. @chinese 当前内容所需高度。 */
@property (nonatomic, assign, readonly) CGFloat preferredHeight;

/** @brief Select a queued draft. @chinese 选择队列中的一条草稿。 */
@property (nonatomic, copy, nullable) void (^onSelectDraft)(NSUInteger index);
/** @brief Append a draft. @chinese 追加一条草稿。 */
@property (nonatomic, copy, nullable) void (^onAddDraft)(void);
/** @brief Remove the selected draft. @chinese 删除选中草稿。 */
@property (nonatomic, copy, nullable) void (^onRemoveDraft)(void);
/** @brief A field of the selected draft changed. @chinese 选中草稿的某个字段发生变化。 */
@property (nonatomic, copy, nullable) void (^onValueChanged)(NSString *field, id value);
/** @brief Open the shared color picker. @chinese 打开共用选色器。 */
@property (nonatomic, copy, nullable) void (^onChooseColor)(void);

/**
 * @brief Renders the queue and the selected draft.
 * @chinese 渲染队列与选中草稿。
 * @param drafts EN: Whole queue. CN: 完整队列。
 * @param index EN: Selected index. CN: 选中下标。
 * @param screen EN: Device screen, bounds the Y slider. CN: 设备屏幕，决定 Y 滑块量程。
 */
- (void)configureWithDrafts:(NSArray<TSRealtimeDanMuDraft *> *)drafts
              selectedIndex:(NSUInteger)index
                     screen:(nullable TSPeripheralScreen *)screen;

/**
 * @brief Dismisses the text keyboard.
 * @chinese 收起文本键盘。
 */
- (void)endTextEditing;

@end

NS_ASSUME_NONNULL_END
