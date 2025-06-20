//
//  TSGlassesStorageInfo.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Smart glasses storage information model
 * @chinese 智能眼镜存储信息模型
 * 
 * @discussion
 * EN: This model represents the storage information of the smart glasses device,
 *     including total storage space and available storage space.
 * CN: 此模型表示智能眼镜设备的存储信息，包括总存储空间和可用存储空间。
 */
@interface TSGlassesStorageInfo : NSObject

/**
 * @brief Total storage space of the device in bytes
 * @chinese 设备总存储空间（字节）
 *
 * @discussion
 * [EN]: Total storage capacity of the smart glasses device in bytes.
 *       This represents the maximum storage space available on the device.
 * [CN]: 智能眼镜设备的总存储容量（字节）。
 *       这表示设备上的最大可用存储空间。
 *
 * @note
 * [EN]: This value is typically constant and represents the device's storage capacity.
 * [CN]: 此值通常是固定的，表示设备的存储容量。
 */
@property (nonatomic, assign) unsigned long long totalSpace;

/**
 * @brief Available storage space in bytes
 * @chinese 可用存储空间（字节）
 *
 * @discussion
 * [EN]: Available storage space on the smart glasses device in bytes.
 *       This represents the remaining space that can be used for storing media files.
 * [CN]: 智能眼镜设备上的可用存储空间（字节）。
 *       这表示可用于存储媒体文件的剩余空间。
 *
 * @note
 * [EN]: This value changes as files are added or removed from the device.
 * [CN]: 此值会随着设备上文件的添加或删除而变化。
 */
@property (nonatomic, assign) unsigned long long availableSpace;

/**
 * @brief Get used storage space in bytes
 * @chinese 获取已使用存储空间（字节）
 *
 * @return 
 * EN: Used storage space calculated as totalSpace - availableSpace
 * CN: 已使用存储空间，计算为 totalSpace - availableSpace
 *
 * @discussion
 * EN: This method calculates the amount of storage space currently in use
 *     by subtracting available space from total space.
 * CN: 此方法通过从总空间中减去可用空间来计算当前使用的存储空间量。
 */
- (unsigned long long)usedSpace;

/**
 * @brief Get storage usage percentage
 * @chinese 获取存储使用百分比
 *
 * @return 
 * EN: Storage usage percentage (0.0 to 100.0)
 * CN: 存储使用百分比（0.0 到 100.0）
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
 * EN: Formatted string showing storage information (e.g., "2.5GB / 8GB (31.25%)")
 * CN: 格式化的存储信息字符串（例如："2.5GB / 8GB (31.25%)"）
 *
 * @discussion
 * EN: This method returns a human-readable string showing the current
 *     storage usage information in a formatted way.
 * CN: 此方法返回一个人类可读的字符串，以格式化方式显示当前存储使用信息。
 */
- (NSString *)formattedStorageInfo;

@end

NS_ASSUME_NONNULL_END 