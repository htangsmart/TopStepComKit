//
//  TSWorkoutResourceModel.h
//  TopStepInterfaceKit
//

#import "TSFileModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Workout resource model
 * @chinese 运动资源模型
 *
 * @discussion
 * EN: Describes a local workout binary selected by the application. The SDK
 *     does not fetch or download cloud workout resources.
 * CN: 描述由应用选择的本地运动二进制文件。SDK 不负责查询或下载云端运动资源。
 */
@interface TSWorkoutResourceModel : TSFileModel

/**
 * @brief Unified workout type
 * @chinese 统一运动类型
 *
 * @discussion
 * EN: Contains a TSSportTypeEnum value when known. It may be nil for a local
 *     binary because the workout type is determined by the binary content.
 * CN: 已知时包含 TSSportTypeEnum 值。本地二进制文件可不提供，运动类型由文件内容决定。
 */
@property (nonatomic, strong, nullable) NSNumber *workoutType;

/**
 * @brief Workout display name
 * @chinese 运动展示名称
 *
 * @discussion
 * EN: Optional display name supplied by the application. The file name can be
 *     used when this value is nil or empty.
 * CN: 由应用提供的可选展示名称。为空时可使用文件名展示。
 */
@property (nonatomic, copy, nullable) NSString *workoutName;

@end

NS_ASSUME_NONNULL_END
