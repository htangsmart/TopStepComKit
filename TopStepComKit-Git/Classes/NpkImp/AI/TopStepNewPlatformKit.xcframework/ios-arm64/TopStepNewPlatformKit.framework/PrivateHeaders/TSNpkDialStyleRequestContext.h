//
//  TSNpkDialStyleRequestContext.h
//  TopStepNewPlatformKit
//
//  Created by Codex on 2026/8/17.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSNpkDialDeviceProfile;

NS_ASSUME_NONNULL_BEGIN

/** @brief Strong NPK custom-dial request parameters @chinese NPK 自定义表盘请求强类型参数 */
@interface TSNpkDialStyleRequestContext : NSObject

/**
 * @brief Screen geometry string used by LVGL requests
 * @chinese LVGL 请求使用的屏幕几何字符串
 *
 * @discussion
 * [EN]: Captured as width*height*shape in pixels, with c for circles and r otherwise.
 *       Included as lcd_size for LVGL; also participates in the metadata cache key.
 * [CN]: 按像素宽*高*形状生成，圆形为 c，其余为 r；LVGL 请求使用 lcd_size 字段，
 *       同时参与元数据缓存键。
 */
@property (nonatomic, copy, readonly) NSString *lcdSize;
/**
 * @brief LCD identifier resolved for GUI requests
 * @chinese GUI 请求解析出的屏幕编号
 *
 * @discussion
 * [EN]: Resolved by the GUI style policy from the captured profile. Nil for LVGL;
 *       GUI context creation fails when no supported mapping exists.
 * [CN]: 由 GUI 样式策略根据设备快照映射；LVGL 为 nil，
 *       GUI 没有支持的映射时上下文创建失败。
 */
@property (nonatomic, strong, readonly, nullable) NSNumber *lcdNumber;
/**
 * @brief Captured screen dimensions in pixels
 * @chinese 捕获的屏幕像素尺寸
 *
 * @discussion
 * [EN]: Copied from the profile when the context is created; later peripheral changes do not update it.
 * [CN]: 创建上下文时从设备快照复制，后续外设变化不会更新该值。
 */
@property (nonatomic, assign, readonly) CGSize screenSize;
/**
 * @brief Whether to use the GUI request contract
 * @chinese 是否使用 GUI 请求约定
 *
 * @discussion
 * [EN]: YES for TSNpkPlatformGUI579X. Selects lcd_number instead of LVGL's lcd_size.
 * [CN]: TSNpkPlatformGUI579X 时为 YES，请求使用 lcd_number 而非 LVGL 的 lcd_size。
 */
@property (nonatomic, assign, readonly) BOOL isGui;
/** @brief Build from frozen facts. @chinese 从冻结设备事实构建。
 * @param profile EN: Frozen facts. CN: 冻结设备事实。
 * @param error EN: Mapping error. CN: 映射错误。
 * @return EN: Context or nil. CN: 上下文或 nil。 */
+ (nullable instancetype)contextWithProfile:(TSNpkDialDeviceProfile *)profile error:(NSError **)error;
/** @brief Legacy GUI service parameters. @chinese 旧 GUI 服务参数。
 * @return EN: Legacy request values. CN: 旧请求字段。 */
- (NSDictionary<NSString *, id> *)legacyGuiParameters;
/**
 * @brief Tool version for the current metadata endpoint
 * @chinese 当前元数据接口使用的工具版本
 *
 * @discussion
 * [EN]: Set to 1.0.0.0 when creating the context. The legacy GUI request separately uses 1.5.
 * [CN]: 创建上下文时设置为 1.0.0.0；旧 GUI 请求另外使用 1.5。
 */
@property (nonatomic, copy, readonly) NSString *toolVersion;
/**
 * @brief Component presence captured from device facts
 * @chinese 从设备信息捕获的组件存在状态
 *
 * @discussion
 * [EN]: Copied from the profile; YES means dial feature bit 0 is clear.
 *       Serialized as has_component = 1 or 0.
 * [CN]: 从设备快照复制；表盘特性位 bit0 为零时为 YES，
 *       请求序列化为 has_component 的 1 或 0。
 */
@property (nonatomic, assign, readonly) BOOL hasComponent;
/**
 * @brief Cloud platform identifier
 * @chinese 云端平台标识
 *
 * @discussion
 * [EN]: pb-w30, pb-579x or gui-579X according to the captured device platform.
 *       This is a request string rather than a binary package platform value.
 * [CN]: 根据设备平台设置为 pb-w30、pb-579x 或 gui-579X，
 *       属于请求字符串，不是二进制包的平台数值。
 */
@property (nonatomic, copy, readonly) NSString *platformType;

/**
 * @brief Build request parameters from the current NPK peripheral
 * @chinese 根据当前 NPK 外设构建请求参数
 * @param peripheral EN: Connected NPK peripheral. CN: 已连接的 NPK 外设。
 * @param error EN: Public dial error. CN: 公开表盘错误。
 * @return EN: Valid context, or nil. CN: 有效上下文，失败时为 nil。
 */
+ (nullable instancetype)contextWithPeripheral:(TSPeripheral *)peripheral
                                         error:(NSError *_Nullable *_Nullable)error;

/** @brief JSON body expected by the NPK cloud service @chinese NPK 云服务要求的 JSON 请求体 */
- (NSDictionary<NSString *, id> *)requestParameters;

/** @brief Stable metadata cache key @chinese 稳定的元数据缓存键 */
- (NSString *)cacheKey;

@end

NS_ASSUME_NONNULL_END
