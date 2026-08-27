//
//  TSWorkoutSlotModel.h
//  TopStepInterfaceKit
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Workout slot model
 * @chinese 运动槽位模型
 *
 * @discussion
 * EN: Represents a stable workout slot returned by the connected device.
 * CN: 表示设备返回的稳定运动槽位。
 */
@interface TSWorkoutSlotModel : TSKitBaseModel

/**
 * @brief Stable slot index
 * @chinese 稳定槽位索引
 *
 * @discussion
 * EN: Provider-defined stable identifier. It is not the position of this model
 *     in the returned array.
 * CN: Provider 定义的稳定标识，不是该模型在返回数组中的位置。
 */
@property (nonatomic, assign) NSInteger slotIndex;

/**
 * @brief Current unified workout type
 * @chinese 当前统一运动类型
 *
 * @discussion
 * EN: Contains a TSSportTypeEnum value when the type can be mapped; otherwise nil.
 * CN: 当前类型可映射时包含 TSSportTypeEnum 值，否则为 nil。
 */
@property (nonatomic, strong, nullable) NSNumber *workoutType;

/**
 * @brief Whether the slot can be replaced
 * @chinese 槽位是否允许替换
 *
 * @return
 * EN: YES when installation to this slot is allowed, otherwise NO.
 * CN: 允许安装到该槽位时返回 YES，否则返回 NO。
 */
@property (nonatomic, assign, getter=isReplaceable) BOOL replaceable;

@end

NS_ASSUME_NONNULL_END
