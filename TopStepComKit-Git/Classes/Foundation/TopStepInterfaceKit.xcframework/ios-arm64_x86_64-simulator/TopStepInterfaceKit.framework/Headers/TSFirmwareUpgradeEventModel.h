#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Firmware upgrade process stages, excluding the final result.
 * @chinese 固件升级过程阶段，不包含最终结果。
 */
typedef NS_ENUM(NSInteger, TSFirmwareUpgradeStage) {
    /**
     * @brief Preparing the upgrade.
     * @chinese 准备升级。
     */
    TSFirmwareUpgradeStagePreparing = 0,
    /**
     * @brief Transferring the package.
     * @chinese 传输固件。
     */
    TSFirmwareUpgradeStageTransferring = 1,
    /**
     * @brief Waiting for device flashing.
     * @chinese 等待设备刷写。
     */
    TSFirmwareUpgradeStageWaitingForFlashing = 2,
    /**
     * @brief Flashing the firmware.
     * @chinese 设备刷写固件。
     */
    TSFirmwareUpgradeStageFlashing = 3,
};

/**
 * @brief Immutable firmware upgrade process snapshot.
 * @chinese 不可变的固件升级过程快照。
 */
@interface TSFirmwareUpgradeEventModel : TSKitBaseModel

/**
 * @brief Current upgrade stage.
 * @chinese 当前升级阶段。
 *
 * @discussion
 * [EN]: Stages describe progress only; the completion callback owns the final result.
 * [CN]: 阶段只描述过程，最终结果由完成回调交付。
 *
 * @note
 * [EN]: Assigned at initialization and cannot be changed.
 * [CN]: 在初始化时设置，之后不可更改。
 */
@property (nonatomic, assign, readonly) TSFirmwareUpgradeStage stage;

/**
 * @brief Percentage within the current stage.
 * @chinese 当前阶段内的进度百分比。
 *
 * @discussion
 * [EN]: Transfer and flashing percentages are independent, each ranging from 0 to 100.
 * [CN]: 传输和刷写的百分比相互独立，分别取值 0～100。
 *
 * @note
 * [EN]: Nil when unavailable, preparing, or waiting. A value of 100 is not a success result.
 * [CN]: 未知、准备或等待阶段为 nil；数值 100 不代表升级成功。
 */
@property (nonatomic, copy, readonly, nullable) NSNumber *progress;

/**
 * @brief Create an immutable process event.
 * @chinese 创建不可变的过程事件。
 *
 * @param stage
 * EN: The current upgrade stage.
 * CN: 当前升级阶段。
 *
 * @param progress
 * EN: Optional percentage, clamped to 0–100; ignored for preparing and waiting stages.
 * CN: 可空的百分比，限制为 0～100；准备和等待阶段忽略该值。
 *
 * @return
 * EN: A new process snapshot.
 * CN: 新的过程快照。
 */
- (instancetype)initWithStage:(TSFirmwareUpgradeStage)stage
                     progress:(nullable NSNumber *)progress NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * @brief Receive firmware upgrade process events on the main queue.
 * @chinese 在主队列接收固件升级过程事件。
 *
 * @param event
 * EN: An immutable snapshot; no process events follow the final completion callback.
 * CN: 不可变快照；最终完成回调后不再发送过程事件。
 */
typedef void (^TSFirmwareUpgradeEventBlock)(TSFirmwareUpgradeEventModel *event);

NS_ASSUME_NONNULL_END
