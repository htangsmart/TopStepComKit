//
//  TSCompanionWorkoutCapabilitiesModel.h
//  TopStepInterfaceKit
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Companion workout capabilities
 * @chinese 互联运动能力模型
 */
@interface TSCompanionWorkoutCapabilitiesModel : TSKitBaseModel

/** @brief Whether companion workout is supported @chinese 是否支持互联运动 */
@property (nonatomic, assign, getter=isCompanionWorkoutSupported) BOOL companionWorkoutSupported;

/** @brief Whether the device has built-in GPS @chinese 设备是否内置 GPS */
@property (nonatomic, assign, getter=isDeviceGPSSupported) BOOL deviceGPSSupported;

/** @brief Whether all eight realtime metric fields are supported @chinese 是否支持八字段实时数据 */
@property (nonatomic, assign, getter=isEightFieldPeriodicReportSupported) BOOL eightFieldPeriodicReportSupported;

@end

NS_ASSUME_NONNULL_END
