//
//  TSRealtimeDanMuDraft.h
//  TopStepComKit_Example
//

#import <UIKit/UIKit.h>
#import <TopStepComKit/TopStepComKit.h>

NS_ASSUME_NONNULL_BEGIN

/** @brief Max queued drafts sent in one batch. @chinese 单次批量下发的弹幕上限。 */
FOUNDATION_EXPORT const NSUInteger kTSRealtimeDanMuMaxDraftCount;
/** @brief Max UTF-8 byte length, aligned with TSDanMuItem validation. @chinese UTF-8 字节上限，与 TSDanMuItem 校验一致。 */
FOUNDATION_EXPORT const NSUInteger kTSRealtimeDanMuMaxTextBytes;
/** @brief Font size slider bounds. @chinese 字号滑块边界。 */
FOUNDATION_EXPORT const NSInteger kTSRealtimeDanMuMinFontSize;
FOUNDATION_EXPORT const NSInteger kTSRealtimeDanMuMaxFontSize;
/** @brief Speed slider bounds. @chinese 速度滑块边界。 */
FOUNDATION_EXPORT const NSInteger kTSRealtimeDanMuMinSpeed;
FOUNDATION_EXPORT const NSInteger kTSRealtimeDanMuMaxSpeed;

/**
 * @brief Editable draft backing one runtime danmaku item.
 * @chinese 对应一条实时弹幕的可编辑草稿。
 *
 * @discussion
 * [EN]: The editor mutates drafts freely; `danMuItem` converts one into the SDK model
 *       and `validate` reuses the model's own rule set instead of duplicating it.
 * [CN]: 编辑区自由修改草稿；`danMuItem` 转换为 SDK 模型，`validate` 直接复用模型自带
 *       的校验规则，不重复实现一套。
 */
@interface TSRealtimeDanMuDraft : NSObject <NSCopying>

/** @brief Danmaku text. @chinese 弹幕文本。 */
@property (nonatomic, copy) NSString *text;
/** @brief Owner type. @chinese 归属类型。 */
@property (nonatomic, assign) TSDanMuType type;
/** @brief Text color. @chinese 文本颜色。 */
@property (nonatomic, strong) UIColor *color;
/** @brief Font size in device pixels. @chinese 设备像素字号。 */
@property (nonatomic, assign) UInt8 fontSize;
/** @brief Scroll speed in device pixels per second. @chinese 滚动速度，设备像素/秒。 */
@property (nonatomic, assign) UInt8 speed;
/** @brief Animation type. @chinese 动画类型。 */
@property (nonatomic, assign) TSDanMuAnimation animation;
/** @brief Y coordinate, or TSDanMuRandomYCoordinate. @chinese 纵坐标，或随机哨兵值。 */
@property (nonatomic, assign) NSInteger yCoordinate;

/**
 * @brief Creates a draft carrying SDK default values.
 * @chinese 创建携带 SDK 默认值的草稿。
 * @return EN: A new draft. CN: 新草稿。
 */
+ (instancetype)defaultDraft;

/**
 * @brief UTF-8 byte length of the text.
 * @chinese 文本的 UTF-8 字节长度。
 * @return EN: Byte count. CN: 字节数。
 */
- (NSUInteger)textByteLength;

/**
 * @brief Whether the draft asks the device to pick a random position.
 * @chinese 草稿是否请求设备随机选位。
 * @return EN: YES when random. CN: 随机时返回 YES。
 */
- (BOOL)isRandomPosition;

/**
 * @brief Switches the draft back to a device-picked random position.
 * @chinese 将草稿切回设备随机选位。
 */
- (void)useRandomPosition;

/**
 * @brief Converts the draft into the SDK model.
 * @chinese 将草稿转换为 SDK 模型。
 * @return EN: A configured item. CN: 已配置的弹幕项。
 */
- (TSDanMuItem *)danMuItem;

/**
 * @brief Validates the draft through the SDK model's own rules.
 * @chinese 通过 SDK 模型自身的规则校验草稿。
 * @return EN: Error, or nil when valid. CN: 错误，合法时为 nil。
 */
- (nullable NSError *)validate;

@end

NS_ASSUME_NONNULL_END
