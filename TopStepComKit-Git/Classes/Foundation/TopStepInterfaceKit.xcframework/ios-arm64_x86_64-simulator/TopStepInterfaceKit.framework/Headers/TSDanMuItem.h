//
//  TSDanMuItem.h
//  TopStepInterfaceKit
//

#import <UIKit/UIKit.h>
#import "TSKitBaseModel.h"
#import "TSRealtimeDanMuDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Runtime danmaku item sent directly to a supported watch.
 * @chinese 直接发送到支持设备的实时弹幕项。
 *
 * @discussion
 * [EN]: This model is for runtime danmaku commands. It is intentionally separate from
 *       TSDialDanMuItem, which describes image/GIF resources used to build a danmaku watch face.
 * [CN]: 此模型用于实时弹幕指令。它与描述图片/GIF 弹幕表盘资源的 TSDialDanMuItem 独立存在。
 */
@interface TSDanMuItem : TSKitBaseModel <NSCopying>

/** @brief Danmaku owner type. @chinese 弹幕归属类型。 */
@property (nonatomic, assign) TSDanMuType type;
/** @brief UTF-8 text, limited to 128 bytes by the FitCloud protocol. @chinese UTF-8 文本，FitCloud 协议限制为 128 字节。 */
@property (nonatomic, copy) NSString *text;
/** @brief Text color. @chinese 文本颜色。 */
@property (nonatomic, strong) UIColor *color;
/** @brief Font size in device pixels. @chinese 设备像素字号。 */
@property (nonatomic, assign) UInt8 fontSize;
/** @brief Device-defined animation. @chinese 设备定义的动画类型。 */
@property (nonatomic, assign) TSDanMuAnimation animation;
/** @brief Scroll speed in pixels per second. @chinese 滚动速度，单位为像素/秒。 */
@property (nonatomic, assign) UInt8 speed;
/**
 * @brief Y coordinate, or TSDanMuRandomYCoordinate for a random position.
 * @chinese 纵坐标，使用 TSDanMuRandomYCoordinate 表示随机位置。
 */
@property (nonatomic, assign) NSInteger yCoordinate;

/**
 * @brief Initializes a runtime danmaku item with text.
 * @chinese 使用文本初始化实时弹幕项。
 * @param text EN: Danmaku text. CN: 弹幕文本。
 * @return EN: A configured danmaku item. CN: 已配置的弹幕项。
 */
- (instancetype)initWithText:(NSString *)text NS_DESIGNATED_INITIALIZER;

/**
 * @brief Creates a runtime danmaku item with text.
 * @chinese 使用文本创建实时弹幕项。
 * @param text EN: Danmaku text. CN: 弹幕文本。
 * @return EN: A configured danmaku item. CN: 已配置的弹幕项。
 */
+ (instancetype)itemWithText:(NSString *)text;

/** @brief Disables default initialization. @chinese 禁用默认初始化。 */
- (instancetype)init NS_UNAVAILABLE;
/** @brief Disables new. @chinese 禁用 new。 */
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
