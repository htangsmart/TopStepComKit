//
//  TSOfflineMapItem.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Local offline-map metadata model
 * @chinese 本地离线地图元数据模型
 *
 * @discussion
 * [EN]: Describes an offline map package that has been downloaded to the phone but not yet
 *       pushed to the device. It records the display name, the local package file path, the
 *       package size in bytes, the selected radius in kilometers and the created timestamp.
 * [CN]: 描述一份已下载到手机、但尚未推送到设备的离线地图包。记录展示名称、本地包文件路径、
 *       包大小（字节）、圈选半径（公里）以及创建时间。
 */
@interface TSOfflineMapItem : NSObject

/**
 * @brief Display name of the offline map
 * @chinese 离线地图的展示名称
 */
@property (nonatomic, copy) NSString *name;

/**
 * @brief Local file path of the downloaded offline map package
 * @chinese 已下载离线地图包的本地文件路径
 */
@property (nonatomic, copy) NSString *packagePath;

/**
 * @brief Package size in bytes
 * @chinese 包大小（字节）
 */
@property (nonatomic, assign) unsigned long long fileSize;

/**
 * @brief Selected download radius in kilometers
 * @chinese 圈选下载半径（公里）
 */
@property (nonatomic, assign) NSInteger radius;

/**
 * @brief Created timestamp (seconds since 1970)
 * @chinese 创建时间（自 1970 年起的秒数）
 */
@property (nonatomic, assign) NSTimeInterval createdAt;

/**
 * @brief Human-readable size text, e.g. "4 MB"
 * @chinese 人类可读的大小文案，例如 "4 MB"
 *
 * @return
 * EN: Formatted size string derived from fileSize
 * CN: 由 fileSize 换算而来的格式化大小字符串
 */
- (NSString *)readableSize;

/**
 * @brief Restore an item from a dictionary
 * @chinese 从字典还原模型
 *
 * @param dictionary
 * EN: Dictionary previously produced by dictionaryRepresentation
 * CN: 先前由 dictionaryRepresentation 生成的字典
 *
 * @return
 * EN: A restored item, or nil if the dictionary is invalid
 * CN: 还原后的模型，字典非法时返回 nil
 */
+ (nullable instancetype)itemWithDictionary:(NSDictionary *)dictionary;

/**
 * @brief Serialize the item to a dictionary for persistence
 * @chinese 将模型序列化为字典以便持久化
 *
 * @return
 * EN: Dictionary representation of the item
 * CN: 模型的字典表示
 */
- (NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
