#import <Foundation/Foundation.h>

@class TSPeripheral;
@class TSDialDraft;
@class FitCloudWatchfaceUIInfo;
@class TSFitDialHeader;
@class TSFitDialShapeOptions;

NS_ASSUME_NONNULL_BEGIN

/** @brief Device snapshot for generated Fit dials. @chinese Fit 全代码表盘的设备参数快照。 */
@interface TSFitDialPackDeviceContext : NSObject
/** @brief Resolved binary header. @chinese 已解析的二进制头部。 */
@property (nonatomic, strong, readonly) TSFitDialHeader *header;
/** @brief Logical screen geometry. @chinese 逻辑屏幕几何参数。 */
@property (nonatomic, strong, readonly) TSFitDialShapeOptions *shape;
/** @brief Maximum OTA bytes, nil when unknown. @chinese OTA 最大字节数，未知为 nil。 */
@property (nonatomic, copy, nullable, readonly) NSNumber *maximumBytes;
/** @brief Current effective enhancement flags. @chinese 本次有效的增强表盘标志。 */
@property (nonatomic, assign, readonly) uint8_t customDialFeatures;

/**
 * @brief Check platform and component eligibility for generated dials.
 * @chinese 检查平台及组件条件是否允许全代码表盘。
 * @param peripheral EN: Current peripheral. CN: 当前设备。
 * @return EN: Whether the device is eligible. CN: 是否满足设备条件。
 */
+ (BOOL)canGenerateForPeripheral:(nullable TSPeripheral *)peripheral;
/**
 * @brief Resolve enhancement flags from the device watch-face capabilities.
 * @chinese 从设备表盘能力快照解析增强标志，未上报时为零。
 * @return EN: Effective 0x28 flags. CN: 有效的 0x28 能力标志。
 */
+ (uint8_t)resolvedCustomDialFeatures;
/**
 * @brief Convert device watch-face rotation to quarter turns, using zero when unknown.
 * @chinese 将设备上报的非模板表盘角度转换为旋转次数，未知时回退为零。
 * @return EN: Clockwise quarter turns. CN: 顺时针旋转次数，每次 90 度。
 */
+ (NSUInteger)resolvedResourceRotation;
/**
 * @brief Snapshot device geometry, identifiers and slot capacity.
 * @chinese 固定设备几何参数、编号及槽位容量。
 * @param peripheral EN: Current peripheral. CN: 当前设备。
 * @param info EN: UI information for the same peripheral. CN: 同一设备的 UI 信息。
 * @param draft EN: Draft carrying the optional dial identifier. CN: 携带可选表盘编号的草稿。
 * @param error EN: Validation error. CN: 校验错误。
 * @return EN: Snapshot or nil. CN: 快照，失败为 nil。
 */
- (nullable instancetype)initWithPeripheral:(TSPeripheral *)peripheral
                                    UIInfo:(FitCloudWatchfaceUIInfo *)info
                                     draft:(TSDialDraft *)draft
                                     error:(NSError *_Nullable *_Nullable)error NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
