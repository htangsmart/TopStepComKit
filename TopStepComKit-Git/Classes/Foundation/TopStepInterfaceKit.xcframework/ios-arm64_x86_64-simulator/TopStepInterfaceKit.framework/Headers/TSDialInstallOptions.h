//
//  TSDialInstallOptions.h
//  TopStepInterfaceKit
//
//  Created by Claude on 2026/10/14.
//
//  文件说明:
//  表盘安装选项。目前用于指定目标表盘位；不指定时由 SDK 自动选位，
//  行为与 installDial:progressBlock:completion: 一致。

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Marker for automatic slot selection
 * @chinese 自动选位标记
 *
 * @discussion
 * [EN]: Value is -1. The SDK chooses the slot exactly as installDial:progressBlock:completion: does.
 * [CN]: 取值为 -1。由 SDK 自动选位，与 installDial:progressBlock:completion: 的行为一致。
 */
FOUNDATION_EXPORT NSInteger const TSDialSlotIndexAutomatic;

/**
 * @brief Watch face install options
 * @chinese 表盘安装选项
 *
 * @discussion
 * [EN]: Passed to TSPeripheralDialInterface installDial:options:progressBlock:completion:.
 *       Check isSupportInstallToSlot before setting targetSlotIndex.
 * [CN]: 用于 TSPeripheralDialInterface 的 installDial:options:progressBlock:completion:。
 *       设置 targetSlotIndex 前请先确认 isSupportInstallToSlot 为 YES。
 */
@interface TSDialInstallOptions : TSKitBaseModel <NSCopying>

/**
 * @brief Target watch face slot index
 * @chinese 目标表盘位序号
 *
 * @discussion
 * [EN]: Use TSDialSlotModel.slotIndex returned by fetchDialSlots: whose installable is YES
 *       (valid range 0-255). Defaults to TSDialSlotIndexAutomatic. When a slot is specified, the SDK installs into
 *       that slot or fails; it never falls back to automatic selection. Installing into the
 *       slot of the current watch face replaces it.
 * [CN]: 取 fetchDialSlots: 返回的、installable 为 YES 的 TSDialSlotModel.slotIndex（有效范围 0–255）。
 *       默认 TSDialSlotIndexAutomatic。指定后 SDK 只会安装到该位或返回失败，
 *       不会退回自动选位；指定当前正在使用的表盘所在位时会直接覆盖。
 */
@property (nonatomic, assign) NSInteger targetSlotIndex;

/**
 * @brief Whether a target slot is specified
 * @chinese 是否指定了目标表盘位
 *
 * @return
 * EN: NO when targetSlotIndex is TSDialSlotIndexAutomatic.
 * CN: targetSlotIndex 为 TSDialSlotIndexAutomatic 时返回 NO。
 */
- (BOOL)hasTargetSlot;

/**
 * @brief Create options for a specific slot
 * @chinese 创建指定表盘位的安装选项
 *
 * @param slotIndex
 * EN: Target slot index from fetchDialSlots:.
 * CN: fetchDialSlots: 返回的目标表盘位序号。
 *
 * @return
 * EN: Install options.
 * CN: 安装选项。
 */
+ (instancetype)optionsWithTargetSlotIndex:(NSInteger)slotIndex;

@end

NS_ASSUME_NONNULL_END
