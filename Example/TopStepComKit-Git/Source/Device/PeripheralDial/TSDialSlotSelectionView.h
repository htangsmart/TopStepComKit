//
//  TSDialSlotSelectionView.h
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/14.
//
//  文件说明:
//  「安装表盘」弹窗内的安装位置选择区：读取手表表盘位，以单选列表提供「自动」和每个可安装的表盘位。
//  只在设备支持指定表盘位时嵌入弹窗；不支持时弹窗保持原样。

#import <UIKit/UIKit.h>

@class TSDialInstallOptions;
@class TSDialModel;
@class TSPeripheralScreen;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Install-location list embedded in the install sheet
 * @chinese 嵌入「安装表盘」弹窗的安装位置选择区
 *
 * @discussion
 * [EN]: Reads slots with fetchDialSlots: (and dial names with fetchAllDials: unless knownDials is set),
 *       then lists "Automatic" plus every installable slot as single-choice rows.
 *       Frame based: set the width, set onContentChange, call reload, and resize the view to
 *       preferredHeight every time onContentChange fires.
 * [CN]: 通过 fetchDialSlots: 读取表盘位（未设置 knownDials 时再用 fetchAllDials: 补齐表盘名称），
 *       以单选行列出「自动」和每个可安装的表盘位。使用 frame 布局：先设置宽度和 onContentChange，
 *       再调用 reload；每次 onContentChange 回调时按 preferredHeight 调整高度。
 */
@interface TSDialSlotSelectionView : UIView

/**
 * @brief Whether the connected device supports choosing an install slot
 * @chinese 当前连接的设备是否支持指定安装表盘位
 *
 * @return
 * EN: YES when the dial interface reports isSupportInstallToSlot.
 * CN: 表盘接口的 isSupportInstallToSlot 为 YES 时返回 YES。
 */
+ (BOOL)isSupportedOnCurrentDevice;

/**
 * @brief Size of the file that will be installed
 * @chinese 将要安装的文件大小
 *
 * @discussion
 * [EN]: In bytes. When non-zero, slots whose reported capacity is smaller are disabled and the
 *       automatic row predicts the first slot that fits. 0 means unknown (e.g. a dial that is built
 *       during installation); size is then not checked. Slots that report no capacity (spaceSize 0)
 *       are always disabled because the SDK never installs into them.
 * [CN]: 单位为字节。非 0 时，上报容量小于该值的表盘位不可选，「自动」行按第一个放得下的位置预估。
 *       0 表示未知（如安装时才制作的表盘），此时不按大小拦截。未上报容量（spaceSize 为 0）的表盘位
 *       始终不可选，因为 SDK 不会向其安装。
 */
@property (nonatomic, assign) unsigned long long knownFileBytes;

/**
 * @brief Dial list already read by the caller
 * @chinese 调用方已读取的表盘列表
 *
 * @discussion
 * [EN]: Used to show the name and the "in use" tag of each slot. When nil, reload reads it with fetchAllDials:.
 * [CN]: 用于显示各表盘位上的表盘名称与「正在使用」标记。为 nil 时 reload 会通过 fetchAllDials: 读取。
 */
@property (nonatomic, copy, nullable) NSArray<TSDialModel *> *knownDials;

/**
 * @brief Screen of the connected device
 * @chinese 当前设备的屏幕信息
 *
 * @discussion
 * [EN]: Dial thumbnails follow its shape: round screens draw circles, square and rectangular screens draw
 *       rounded rectangles with the screen's aspect ratio and corner. nil is treated as an unknown shape (4:5 portrait).
 * [CN]: 表盘缩略图按其形状绘制：圆屏为圆形，方屏/长方屏按屏幕宽高比和圆角绘制。为 nil 时按形状未知处理（4:5 竖屏）。
 */
@property (nonatomic, strong, nullable) TSPeripheralScreen *screen;

/**
 * @brief Preview images keyed by dial id
 * @chinese 以表盘 id 为键的预览图
 *
 * @discussion
 * [EN]: Optional. Slots without an entry fall back to Documents/dialPreviews/<dialId>.jpg, then to a placeholder.
 * [CN]: 可选。没有对应图片的表盘位依次使用 Documents/dialPreviews/<dialId>.jpg 和占位图。
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, UIImage *> *previewImages;

/**
 * @brief Slots that rejected this install
 * @chinese 本次安装中被拒绝过的表盘位
 *
 * @discussion
 * [EN]: Slot indexes that failed with TSDialErrorInvalidTargetSlot or eTSErrorNoSpace. Their rows are disabled and
 *       the automatic prediction skips them. Clear it when the file or the dial content changes.
 * [CN]: 安装时返回 TSDialErrorInvalidTargetSlot 或 eTSErrorNoSpace 的表盘位序号。对应行不可选，「自动」的预估会跳过它们。
 *       更换文件或表盘内容后请清空。
 */
@property (nonatomic, copy, nullable) NSSet<NSNumber *> *rejectedSlotIndexes;

/**
 * @brief Why automatic selection cannot be used
 * @chinese 不能使用自动选位的原因
 *
 * @discussion
 * [EN]: nil (default) keeps "Automatic" as the default choice. When set, the automatic row is disabled and
 *       shows this text, and nothing is selected until the user picks a slot.
 * [CN]: 为 nil（默认）时「自动」为默认选项。设置后「自动」行不可选并显示该文案，用户选择表盘位前不选中任何项。
 */
@property (nonatomic, copy, nullable) NSString *automaticUnavailableReason;

/**
 * @brief Whether the current choice can be installed
 * @chinese 当前选择能否开始安装
 *
 * @discussion
 * [EN]: NO while loading or when the choice has no usable target. YES when slots could not be read;
 *       selectedOptions is then nil and the caller handles it as automatic selection (including its own
 *       checks, such as the install limit).
 * [CN]: 读取中、或当前选择没有可用目标时为 NO。读不到表盘位时为 YES，此时 selectedOptions 为 nil，
 *       由调用方按自动选位处理（包括调用方自己的检查，如安装数量上限）。
 */
@property (nonatomic, assign, readonly) BOOL canInstall;

/**
 * @brief Install options for the current choice
 * @chinese 当前选择对应的安装选项
 *
 * @discussion
 * [EN]: nil means automatic selection; otherwise options targeting the chosen slot.
 * [CN]: 为 nil 表示自动选位；否则为指定所选表盘位的安装选项。
 */
@property (nonatomic, strong, readonly, nullable) TSDialInstallOptions *selectedOptions;

/**
 * @brief Called on the main thread whenever height, choice or canInstall may have changed
 * @chinese 高度、选择或 canInstall 可能变化时在主线程回调
 */
@property (nonatomic, copy, nullable) void (^onContentChange)(void);

/**
 * @brief Read the slots again
 * @chinese 重新读取表盘位
 *
 * @discussion
 * [EN]: Shows the loading state, then the list or a read-failure note. Results of an earlier reload are ignored.
 * [CN]: 先显示读取中，再显示列表或读取失败提示。之前一次 reload 的迟到结果会被忽略。
 */
- (void)reload;

/**
 * @brief Height needed for the current width
 * @chinese 按当前宽度所需的高度
 *
 * @return
 * EN: Height in points.
 * CN: 高度，单位为点。
 */
- (CGFloat)preferredHeight;

/**
 * @brief Title for the sheet's primary button
 * @chinese 弹窗主按钮的标题
 *
 * @param title
 * EN: Title used for automatic selection.
 * CN: 自动选位时使用的标题。
 *
 * @return
 * EN: "安装到表盘位 N" when a slot is chosen, otherwise the given title.
 * CN: 选中表盘位时为「安装到表盘位 N」，否则为传入的标题。
 */
- (NSString *)primaryTitleWithDefault:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
