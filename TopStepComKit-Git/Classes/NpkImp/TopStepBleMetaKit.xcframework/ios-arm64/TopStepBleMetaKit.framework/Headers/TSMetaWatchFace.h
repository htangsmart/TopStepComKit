//
//  TSMetaWatchFace.h
//  TopStepBleMetaKit
//
//  Created by 磐石 on 2025/9/4.
//

#import "TSBusinessBase.h"
#import <TopStepBleMetaKit/PbSettingParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSMetaWatchFace : TSBusinessBase

/**
 * @brief Fetch all watch faces
 * @chinese 获取所有表盘
 */
+ (void)fetchAllDialsWithCompletion:(void(^)(TSMetaDialList *_Nullable list, NSError *_Nullable error))completion;

/**
 * @brief Select a watch face
 * @chinese 选中表盘
 */
+ (void)selectDial:(TSMetaDialId *)dialId
        completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Delete a watch face
 * @chinese 删除表盘
 */
+ (void)deleteDial:(TSMetaDialId *)dialId
        completion:(TSMetaCompletionBlock)completion;

/**
 * @brief Register notify of dial changed
 * @chinese 注册表盘变更监听
 */
+(void)registerPeripheralDialDidChanged:(void(^)(TSMetaDialList *_Nullable list, NSError *_Nullable error))completion;

/**
 * @brief Fetch dial slots (0x02-0x70)
 * @chinese 查询表盘槽位（0x02-0x70）
 *
 * @discussion
 * [EN]: Only supported when TSMetaPeripheralInfo.platform == 2 (GUI_579X); callers must gate on platform.
 *       Response is TSMetaSlotSpaceList; returns its items in device order (index == slot index).
 * [CN]: 仅 TSMetaPeripheralInfo.platform == 2 (GUI_579X) 的设备支持，调用方需按 platform 判定。
 *       响应为 TSMetaSlotSpaceList，按设备返回顺序给出 items（下标即槽位序号）。
 */
+ (void)fetchDialSlotsWithCompletion:(void(^)(NSArray<TSMetaSlotSpace *> *_Nullable slots, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
