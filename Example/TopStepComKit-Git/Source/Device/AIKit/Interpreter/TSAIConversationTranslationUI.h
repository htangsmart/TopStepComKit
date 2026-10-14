//
//  TSAIConversationTranslationUI.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TopStepAIKit/TopStepAIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Naming, preset matching and small controls shared by the conversation translation pages
 * @chinese 对话翻译三个页面共用的命名、预设匹配与小控件
 *
 * @discussion
 * [EN]: Colors and fonts come from `TSAIInterpreterTheme` so the conversation
 *       pages look like the interpreter pages. Participant colors are fixed:
 *       self = cobalt, peer = jade. The preset helpers map between the three
 *       product modes and the four explicit endpoints of a
 *       `TSAIConversationTranslationConfig`.
 * [CN]: 颜色与字体取自 `TSAIInterpreterTheme`，保证与同传页面同一套视觉。
 *       参与者颜色固定：我方 = 钴蓝，对方 = 翠绿。预设工具负责在三种产品
 *       模式与 `TSAIConversationTranslationConfig` 的四个显式端点之间互转。
 */
@interface TSAIConversationTranslationUI : NSObject

#pragma mark - Naming

/**
 * @brief Localized device name of an endpoint
 * @chinese 端点对应的设备名（手机 / 耳机 / 充电仓）
 *
 * @param endpoint
 * EN: Endpoint; `Automatic` returns the "auto" label
 * CN: 端点；`Automatic` 返回「自动」
 *
 * @return
 * EN: Localized name
 * CN: 本地化名称
 */
+ (NSString *)nameForEndpoint:(TSAIConversationEndpoint)endpoint;

/**
 * @brief SF Symbol for an endpoint device
 * @chinese 端点设备对应的 SF Symbol
 *
 * @param endpoint
 * EN: Endpoint
 * CN: 端点
 *
 * @return
 * EN: Symbol name
 * CN: 符号名
 */
+ (NSString *)symbolForEndpoint:(TSAIConversationEndpoint)endpoint;

/**
 * @brief Localized preset name; `Invalid` reads as "custom"
 * @chinese 预设名称；`Invalid` 显示为「自定义组合」
 *
 * @param mode
 * EN: Product mode
 * CN: 产品模式
 *
 * @return
 * EN: Localized title
 * CN: 本地化标题
 */
+ (NSString *)titleForMode:(TSAIConversationTranslationMode)mode;

/**
 * @brief Short scenario text shown under a preset card
 * @chinese 预设卡下方的场景短语
 */
+ (NSString *)scenarioForMode:(TSAIConversationTranslationMode)mode;

/**
 * @brief One-sentence description of a preset or of the custom combination
 * @chinese 预设或自定义组合的一句话说明
 */
+ (NSString *)descriptionForMode:(TSAIConversationTranslationMode)mode;

/**
 * @brief Localized end reason
 * @chinese 本地化的结束原因
 */
+ (NSString *)displayNameForEndReason:(TSAIConversationTranslationEndReason)reason;

#pragma mark - Presets

/**
 * @brief Preset endpoints of a product mode, in the order self capture / self playback / peer capture / peer playback
 * @chinese 产品模式的预设端点，顺序为 我方收音 / 我方播报 / 对方收音 / 对方播报
 *
 * @param mode
 * EN: FaceToFace / Private / Portable
 * CN: 面对面 / 私密听译 / 便携交流
 *
 * @return
 * EN: Four boxed `TSAIConversationEndpoint` values; empty for `Invalid`
 * CN: 四个装箱的 `TSAIConversationEndpoint`；`Invalid` 返回空数组
 */
+ (NSArray<NSNumber *> *)presetEndpointsForMode:(TSAIConversationTranslationMode)mode;

/**
 * @brief The preset whose endpoints equal the config's resolved endpoints, or `Invalid` for a custom combination
 * @chinese 与配置解析后端点完全一致的预设；无匹配时返回 `Invalid`（自定义组合）
 */
+ (TSAIConversationTranslationMode)presetMatchingConfig:(TSAIConversationTranslationConfig *)config;

/**
 * @brief Write a preset into the config: product mode plus the four explicit endpoints
 * @chinese 把预设写入配置：产品模式 + 四个显式端点
 */
+ (void)applyPreset:(TSAIConversationTranslationMode)mode toConfig:(TSAIConversationTranslationConfig *)config;

/**
 * @brief Product mode to send to the device for an arbitrary endpoint combination
 * @chinese 任意端点组合应下发给设备的产品模式
 *
 * @discussion
 * [EN]: Picks the preset whose charging-case behaviour is closest: when the
 *       case captures for one side, the other side's capture device decides
 *       (earbuds → Private, otherwise FaceToFace); without the case → Portable.
 * [CN]: 选充电仓行为最接近的预设：仓为某一方收音时，看另一方的收音设备
 *       （耳机 → 私密听译，否则 → 面对面）；仓不参与 → 便携交流。
 */
+ (TSAIConversationTranslationMode)deviceModeForConfig:(TSAIConversationTranslationConfig *)config;

#pragma mark - Navigation

/**
 * @brief Whether the controller draws its own top bar (conversation or interpreter pages)
 * @chinese 控制器是否自绘顶栏（对话翻译页或同传页）
 */
+ (BOOL)isCustomBarPage:(nullable UIViewController *)viewController;

@end

/**
 * @brief Three-device segmented picker used in the "who captures / who listens" matrix
 * @chinese 「谁收音 / 在哪听译文」矩阵里的三设备分段选择器
 *
 * @discussion
 * [EN]: Phone / earbuds / case tiles on a paper track. The selected tile is
 *       filled with `tint` (cobalt for self, jade for peer); unavailable
 *       tiles are dimmed but still tappable so the host can explain why.
 * [CN]: 手机 / 耳机 / 充电仓三格放在纸色轨道上。选中格填充 `tint`
 *       （我方钴蓝、对方翠绿）；不可用格变淡但仍可点击，便于宿主给出原因。
 */
@interface TSAIConversationDeviceSegment : UIView

/// @brief Fill color of the selected tile @chinese 选中格的填充色
@property (nonatomic, strong) UIColor *tint;
/// @brief Selected endpoint (Phone / Earbuds / Case) @chinese 当前选中端点
@property (nonatomic, assign) TSAIConversationEndpoint selectedEndpoint;
/// @brief Tap callback with the tapped endpoint @chinese 点击回调，参数为被点的端点
@property (nonatomic, copy, nullable) void (^onTap)(TSAIConversationEndpoint endpoint);

/**
 * @brief Set whether an endpoint can be chosen
 * @chinese 设置某端点是否可选
 */
- (void)setEndpoint:(TSAIConversationEndpoint)endpoint available:(BOOL)available;

@end

/**
 * @brief Preset card (face-to-face / private / portable) with the two device tiles
 * @chinese 预设卡（面对面 / 私密听译 / 便携交流），带双方设备图标
 */
@interface TSAIConversationPresetCard : UIControl

/// @brief Product mode this card stands for @chinese 本卡对应的产品模式
@property (nonatomic, assign) TSAIConversationTranslationMode mode;
/// @brief Whether the preset can be chosen now @chinese 当前是否可选
@property (nonatomic, assign) BOOL available;

@end

NS_ASSUME_NONNULL_END
