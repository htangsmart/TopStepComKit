//
//  TSFitCompanionWorkoutConverter.h
//  TopStepFitKit
//

#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Converter between FitCloudKit and unified companion workout models
 * @chinese FitCloudKit 与统一互联运动模型之间的转换器
 */
@interface TSFitCompanionWorkoutConverter : NSObject

/**
 * @brief Convert a unified workout type to FitCloudKit
 * @chinese 将统一运动类型转换为 FitCloudKit 类型
 * @param workoutType EN: Unified workout type. CN: 统一运动类型。
 * @return EN: FitCloudKit workout type, or Unknown when invalid. CN: FitCloudKit 运动类型；无效时返回 Unknown。
 */
+ (FitCloudWorkoutType)fitWorkoutTypeFromUnifiedType:(TSSportTypeEnum)workoutType;

/**
 * @brief Convert a FitCloudKit workout type to the unified type
 * @chinese 将 FitCloudKit 运动类型转换为统一类型
 * @param workoutType EN: FitCloudKit workout type. CN: FitCloudKit 运动类型。
 * @return EN: Unified workout type, or 0 when invalid. CN: 统一运动类型；无效时返回 0。
 */
+ (TSSportTypeEnum)unifiedWorkoutTypeFromFitType:(FitCloudWorkoutType)workoutType;

/**
 * @brief Convert a unified workout event to FitCloudKit
 * @chinese 将统一运动事件转换为 FitCloudKit 模型
 * @param event EN: Unified workout event. CN: 统一运动事件。
 * @return EN: FitCloudKit event, or nil when invalid. CN: FitCloudKit 事件；无效时返回 nil。
 */
+ (nullable FitCloudCompanionWorkoutEventModel *)fitEventFromUnifiedEvent:(TSCompanionWorkoutEventModel *)event;

/**
 * @brief Convert an App periodic report to FitCloudKit
 * @chinese 将 App 周期运动数据转换为 FitCloudKit 模型
 * @param reportData EN: Unified App periodic report. CN: 统一 App 周期运动数据。
 * @return EN: FitCloudKit periodic report. CN: FitCloudKit 周期运动数据。
 */
+ (nullable FitCloudCompanionWorkoutApp2DevicePeriodicReportDataModel *)fitReportFromUnifiedReport:(TSCompanionWorkoutAppReportModel *)reportData;

/**
 * @brief Convert a FitCloudKit workout event to the unified model
 * @chinese 将 FitCloudKit 运动事件转换为统一模型
 * @param event EN: FitCloudKit workout event. CN: FitCloudKit 运动事件。
 * @return EN: Unified event, or nil when invalid. CN: 统一事件；无效时返回 nil。
 */
+ (nullable TSCompanionWorkoutEventModel *)unifiedEventFromFitEvent:(FitCloudCompanionWorkoutEventModel *)event;

/**
 * @brief Convert FitCloudKit workout information to the unified model
 * @chinese 将 FitCloudKit 会话信息转换为统一模型
 * @param workoutInfo EN: FitCloudKit workout information. CN: FitCloudKit 会话信息。
 * @return EN: Unified workout information, or nil when invalid. CN: 统一会话信息；无效时返回 nil。
 */
+ (nullable TSCompanionWorkoutInfoModel *)unifiedInfoFromFitInfo:(FitCloudCompanionWorkoutInfoModel *)workoutInfo;

/**
 * @brief Convert a FitCloudKit device report to the unified model
 * @chinese 将 FitCloudKit 设备周期数据转换为统一模型
 * @param reportData EN: FitCloudKit device report. CN: FitCloudKit 设备周期数据。
 * @return EN: Unified device report, or nil when invalid. CN: 统一设备周期数据；无效时返回 nil。
 */
+ (nullable TSCompanionWorkoutDeviceReportModel *)unifiedReportFromFitReport:(FitCloudCompanionWorkoutDevice2AppPeriodicReportDataModel *)reportData;

@end

NS_ASSUME_NONNULL_END
