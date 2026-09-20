//
//  TSOfflineMapStore.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TSOfflineMapItem;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Local offline-map persistence store
 * @chinese 本地离线地图持久化存储
 *
 * @discussion
 * [EN]: A singleton that persists metadata of offline map packages downloaded to the phone.
 *       The SDK downloadOfflineMapWithRegion: returns a local package path; this store keeps the
 *       name / path / size index in a plist so the "My Maps · Local" tab can list them across launches.
 *       Device-side maps are NOT persisted here — they are fetched live from the SDK.
 * [CN]: 单例，持久化已下载到手机的离线地图包元数据。
 *       SDK 的 downloadOfflineMapWithRegion: 返回本地包路径；本存储将名称/路径/大小索引保存到 plist，
 *       以便「我的地图 · 本地」Tab 跨启动展示。设备端地图不在此持久化，而是实时从 SDK 获取。
 */
@interface TSOfflineMapStore : NSObject

/**
 * @brief Maximum number of local maps allowed
 * @chinese 允许的本地地图数量上限
 */
@property (nonatomic, assign, readonly) NSInteger maxLocalMapCount;

/**
 * @brief Shared singleton instance
 * @chinese 获取共享单例
 *
 * @return
 * EN: The shared store instance
 * CN: 共享存储实例
 */
+ (instancetype)sharedStore;

/**
 * @brief All local maps, newest first
 * @chinese 所有本地地图，最新在前
 *
 * @return
 * EN: Array of TSOfflineMapItem, may be empty
 * CN: TSOfflineMapItem 数组，可能为空
 */
- (NSArray<TSOfflineMapItem *> *)allLocalMaps;

/**
 * @brief Current local map count
 * @chinese 当前本地地图数量
 *
 * @return
 * EN: Number of stored local maps
 * CN: 已存储的本地地图数量
 */
- (NSInteger)localMapCount;

/**
 * @brief Whether a name is already used by a local map
 * @chinese 名称是否已被本地地图占用
 *
 * @param name
 * EN: The candidate name
 * CN: 待校验的名称
 *
 * @return
 * EN: YES if a local map with the same name exists
 * CN: 若存在同名本地地图返回 YES
 */
- (BOOL)isNameUsedLocally:(NSString *)name;

/**
 * @brief Add a downloaded local map and persist it
 * @chinese 新增一份已下载的本地地图并持久化
 *
 * @param name
 * EN: Display name
 * CN: 展示名称
 *
 * @param packagePath
 * EN: Local package file path returned by the SDK download API
 * CN: SDK 下载接口返回的本地包文件路径
 *
 * @param radius
 * EN: Selected radius in kilometers
 * CN: 圈选半径（公里）
 *
 * @return
 * EN: The created and stored item
 * CN: 创建并已存储的模型
 */
- (TSOfflineMapItem *)addLocalMapWithName:(NSString *)name
                              packagePath:(NSString *)packagePath
                                   radius:(NSInteger)radius;

/**
 * @brief Remove a local map by name and delete its package file
 * @chinese 按名称删除本地地图并删除其包文件
 *
 * @param name
 * EN: The map name to remove
 * CN: 要删除的地图名称
 */
- (void)removeLocalMapWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
