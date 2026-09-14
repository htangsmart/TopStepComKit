//
//  TSStorageSpace.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/4/28.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Storage information for a device or a specific storage area
 * @chinese 设备或指定存储区域的空间信息模型
 *
 * @discussion
 * EN: Carries total and available bytes. The returning interface defines the
 *     storage scope, such as device storage or watch face storage.
 * CN: 携带总空间和可用空间（字节）；存储范围由返回该模型的接口定义，
 *     例如设备存储或表盘存储。
 */

@interface TSStorageSpace : TSKitBaseModel

/**
 * @brief Total capacity of the queried storage area in bytes
 * @chinese 查询区域的总存储空间（字节）
 *
 * @discussion
 * [EN]: Total capacity of the storage area specified by the returning interface.
 * [CN]: 返回该模型的接口所指定存储区域的总容量。
 *
 * @note
 * [EN]: 0 means unknown or not reported by the device.
 * [CN]: 0 表示未知或设备未上报。
 */
@property (nonatomic, assign) unsigned long long total;

/**
 * @brief Available storage space in bytes
 * @chinese 可用存储空间（字节）
 *
 * @discussion
 * [EN]: Remaining bytes in the queried storage area, even when total is unknown.
 * [CN]: 查询区域的剩余空间（字节），total 未知时仍可使用此值。
 *
 * @note
 * [EN]: This value changes as files are added or removed from the device.
 * [CN]: 此值会随着设备上文件的添加或删除而变化。
 */
@property (nonatomic, assign) unsigned long long available;

/**
 * @brief Get used storage space in bytes
 * @chinese 获取已使用存储空间（字节）
 *
 * @return
 * EN: Used storage space calculated as total - available
 * CN: 已使用存储空间，计算为 total - available
 * EN: Returns 0 when total is unknown or less than available.
 * CN: total 未知或小于 available 时返回 0。
 *
 * @discussion
 * EN: This method calculates the amount of storage space currently in use
 *     by subtracting available space from total space.
 * CN: 此方法通过从总空间中减去可用空间来计算当前使用的存储空间量。
 */
- (unsigned long long)used;

/**
 * @brief Get storage usage percentage
 * @chinese 获取存储使用百分比
 *
 * @return
 * EN: Storage usage percentage (0.0 to 100.0)
 * CN: 存储使用百分比（0.0 到 100.0）
 * EN: Returns 0 when total is unknown; this does not indicate actual usage.
 * CN: total 未知时返回 0，此时不代表实际使用率。
 *
 * @discussion
 * EN: This method calculates the percentage of storage space currently in use.
 *     Returns a value between 0.0 (0%) and 100.0 (100%).
 * CN: 此方法计算当前使用的存储空间百分比。
 *     返回值在 0.0（0%）到 100.0（100%）之间。
 */
- (double)usagePercentage;

/**
 * @brief Check if storage space is sufficient for given size
 * @chinese 检查存储空间是否足够存储指定大小的文件
 *
 * @param requiredSize
 * EN: Required storage size in bytes
 * CN: 需要的存储大小（字节）
 *
 * @return
 * EN: YES if available space is sufficient, NO otherwise
 * CN: 如果可用空间足够返回YES，否则返回NO
 *
 * @discussion
 * EN: This method checks if the device has enough available space
 *     to store a file of the specified size.
 * CN: 此方法检查设备是否有足够的可用空间来存储指定大小的文件。
 */
- (BOOL)hasEnoughSpaceForSize:(unsigned long long)requiredSize;

/**
 * @brief Get formatted storage information string
 * @chinese 获取格式化的存储信息字符串
 *
 * @return
 * EN: Formatted string showing storage information (e.g., "2560.00MB / 8192.00MB (31.25%)")
 * CN: 格式化的存储信息字符串（例如："2560.00MB / 8192.00MB (31.25%)"）
 *
 * @discussion
 * EN: This method returns a human-readable string showing the current
 *     storage usage information in MB (1 MB = 1024 * 1024 bytes), with two decimal places.
 * CN: 此方法以 MB 显示当前存储使用信息（1 MB = 1024 × 1024 字节），保留两位小数。
 * EN: When total is 0, shows available space and marks total capacity and usage percentage as unknown.
 * CN: total 为 0 时，仅显示可用空间，并标注总量未知、使用率未知。
 */
- (NSString *)formattedStorageInfo;



@end

NS_ASSUME_NONNULL_END
