//
//  TSDialStorage.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/19.
//
//  文件说明:
//  表盘存储空间快照模型。替代原先只返回剩余字节数的回调，
//  以对象形式同时携带剩余空间与总空间。

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Watch face storage snapshot
 * @chinese 表盘存储空间快照
 *
 * @discussion
 * [EN]: Carries the free and total storage bytes available for watch faces.
 * [CN]: 携带表盘可用的剩余空间与总空间（字节）。
 */
@interface TSDialStorage : TSKitBaseModel

/**
 * @brief Free space in bytes
 * @chinese 剩余空间（字节）
 */
@property (nonatomic, assign) long long freeBytes;

/**
 * @brief Total space in bytes
 * @chinese 总空间（字节）
 *
 * @discussion
 * [EN]: 0 means unknown / not reported by the device.
 * [CN]: 为 0 表示未知 / 设备未上报。
 */
@property (nonatomic, assign) long long totalBytes;

@end

NS_ASSUME_NONNULL_END
