//
//  TSAIInterpreterDeviceCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Which side of the audio path a cell belongs to
 * @chinese 设备格子属于音频链路的哪一侧
 */
typedef NS_ENUM(NSInteger, TSAIInterpreterDeviceCellKind) {
    /// @brief Pickup (jade) @chinese 收音（翠绿）
    TSAIInterpreterDeviceCellKindInput = 0,
    /// @brief Playback (cobalt) @chinese 播放（钴蓝）
    TSAIInterpreterDeviceCellKindOutput = 1,
};

/**
 * @brief Grid cell for choosing a pickup / playback device (`.cell` in the prototype)
 * @chinese 选择收音 / 播放设备的格子（原型中的 `.cell`）
 *
 * @discussion
 * [EN]: 36pt rounded icon tile above a 12pt title, 2pt border, radius 16,
 *       min height 84. `selected` draws the colored border and fills the
 *       icon tile; `available = NO` dims the whole cell to 50% and greys the
 *       tile while still accepting taps so the host can explain why.
 * [CN]: 36pt 圆角图标块 + 12pt 标题，2pt 边框，圆角 16，最小高 84。
 *       `selected` 时边框着色、图标块填色；`available = NO` 时整体 50%
 *       透明、图标块置灰，但仍可点击，便于宿主给出原因提示。
 */
@interface TSAIInterpreterDeviceCell : UIControl

/**
 * @brief Input (jade) or output (cobalt) styling
 * @chinese 输入（翠绿）或输出（钴蓝）配色
 */
@property (nonatomic, assign) TSAIInterpreterDeviceCellKind kind;

/**
 * @brief Whether the option can currently be chosen
 * @chinese 该选项当前是否可选
 */
@property (nonatomic, assign) BOOL available;

/**
 * @brief Arbitrary identifier the host uses to map the cell back to its option
 * @chinese 宿主用来回溯选项的标识
 */
@property (nonatomic, assign) NSInteger optionId;

/**
 * @brief Configure icon and title
 * @chinese 设置图标与标题
 *
 * @param symbolName
 * EN: SF Symbol name
 * CN: SF Symbol 名称
 *
 * @param title
 * EN: Title under the icon
 * CN: 图标下的标题
 */
- (void)setSymbol:(NSString *)symbolName title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
