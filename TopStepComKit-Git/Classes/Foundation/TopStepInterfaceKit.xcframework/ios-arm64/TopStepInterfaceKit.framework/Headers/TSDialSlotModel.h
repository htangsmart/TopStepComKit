//
//  TSDialSlotModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face slot model
 * @chinese 表盘槽位模型
 *
 * @discussion
 * [EN]: Returned by TSPeripheralDialInterface.fetchDialSlots:. Provider semantics:
 *      - NPK (platform GUI_579X): empty comes from the device; installable is always YES.
 *      - Fit: a slot always holds a watch face, so empty is always NO; installable is NO for built-in slots.
 * [CN]: 由 TSPeripheralDialInterface.fetchDialSlots: 返回。各平台语义：
 *      - NPK（GUI_579X 平台）：empty 来自设备；installable 恒为YES。
 *      - Fit：槽位始终有表盘，empty 恒为NO；内置槽位的 installable 为NO。
 */
@interface TSDialSlotModel : NSObject <NSCopying>

/**
 * @brief Slot index
 * @chinese 槽位序号
 *
 * @discussion
 * [EN]: Zero-based, in the order reported by the device.
 * [CN]: 从 0 开始，按设备返回顺序排列。
 */
@property (nonatomic, assign) NSInteger slotIndex;

/**
 * @brief Identifier of the watch face in the slot
 * @chinese 槽位内表盘的 id
 *
 * @discussion
 * [EN]: Same identifier used by selectDial:completion: and deleteDial:completion:; nil for an empty slot.
 * [CN]: 与 selectDial:completion: / deleteDial:completion: 使用的 dialId 一致；空槽时为nil。
 */
@property (nonatomic, copy, nullable) NSString *dialId;

/**
 * @brief Slot capacity
 * @chinese 槽位容量
 *
 * @discussion
 * [EN]: In bytes; 0 when the device does not report it.
 * [CN]: 单位为字节；设备未上报时为 0。
 */
@property (nonatomic, assign) unsigned long long spaceSize;

/**
 * @brief Whether the slot is empty
 * @chinese 槽位是否为空
 */
@property (nonatomic, assign, getter=isEmpty) BOOL empty;

/**
 * @brief Whether a cloud or custom watch face can be installed into the slot
 * @chinese 是否允许向该槽位推送云端/自定义表盘
 *
 * @note
 * [EN]: Check this instead of empty when deciding whether a slot is a valid push target.
 * [CN]: 判断槽位能否作为推送目标时请以此属性为准，而不是 empty。
 */
@property (nonatomic, assign, getter=isInstallable) BOOL installable;

@end

NS_ASSUME_NONNULL_END
