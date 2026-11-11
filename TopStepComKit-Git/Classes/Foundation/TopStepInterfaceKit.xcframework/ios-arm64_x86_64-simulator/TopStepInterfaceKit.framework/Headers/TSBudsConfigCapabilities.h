//
//  TSBudsConfigCapabilities.h
//  TopStepInterfaceKit
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Buds configuration capability model
 * @chinese Buds 配置能力模型
 *
 * @discussion
 * EN: This immutable model describes the availability of physical operation mappings,
 *     AI image resolution and video frame direction for the current device.
 * CN: 此不可变模型描述当前设备的物理操作映射、AI 识图清晰度和录像画幅方向三组配置能力。
 */
@interface TSBudsConfigCapabilities : TSKitBaseModel

/**
 * @brief Physical operation mapping availability
 * @chinese 物理操作映射是否可用
 *
 * @discussion
 * EN: Indicates whether the current device exposes the physical operation mapping API.
 * CN: 表示当前设备是否提供物理操作映射 API。
 *
 * @note
 * EN: NO after default initialization. An available API does not guarantee support for every
 *     operation/function combination; the device may reject specific combinations.
 * CN: 默认初始化时为 NO。API 可用不代表任意操作与功能组合均受支持，设备仍可能拒绝特定组合。
 */
@property (nonatomic, assign, readonly) BOOL supportsPhysicalOperations;

/**
 * @brief AI image resolution configuration availability
 * @chinese AI 识图清晰度配置是否可用
 *
 * @discussion
 * EN: Requires both a public SDK configuration API and support from the current device.
 * CN: 同时要求 SDK 提供公开配置 API，以及当前设备支持该配置。
 *
 * @note
 * EN: NO after default initialization or when the integrated SDK has no public configuration API.
 *     API unavailability does not imply that the firmware permanently lacks this feature.
 * CN: 默认初始化或已接入 SDK 缺少公开配置 API 时为 NO。API 不可用不代表固件永久不支持该功能。
 */
@property (nonatomic, assign, readonly) BOOL supportsAIImageResolution;

/**
 * @brief Video frame direction configuration availability
 * @chinese 录像画幅方向配置是否可用
 *
 * @discussion
 * EN: Describes video frame direction configuration availability independently of recording state
 *     and the other configuration groups.
 * CN: 独立描述录像画幅方向配置是否可用，不依赖录像活动状态或其他配置分组。
 *
 * @note
 * EN: NO after default initialization or when the integrated SDK has no public configuration API.
 * CN: 默认初始化或已接入 SDK 缺少公开配置 API 时为 NO。
 */
@property (nonatomic, assign, readonly) BOOL supportsVideoRecordDirection;

/**
 * @brief Initialize a configuration capability model
 * @chinese 初始化配置能力模型
 *
 * @param physicalOperations
 * EN: Whether physical operation mapping is available.
 * CN: 物理操作映射是否可用。
 *
 * @param imageResolution
 * EN: Whether AI image resolution configuration is available.
 * CN: AI 识图清晰度配置是否可用。
 *
 * @param videoDirection
 * EN: Whether video frame direction configuration is available.
 * CN: 录像画幅方向配置是否可用。
 *
 * @return
 * EN: Immutable capability model containing the supplied independent values.
 * CN: 包含所传各项独立能力值的不可变模型。
 */
- (instancetype)initWithPhysicalOperations:(BOOL)physicalOperations
                 imageResolution:(BOOL)imageResolution
                  videoDirection:(BOOL)videoDirection NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
