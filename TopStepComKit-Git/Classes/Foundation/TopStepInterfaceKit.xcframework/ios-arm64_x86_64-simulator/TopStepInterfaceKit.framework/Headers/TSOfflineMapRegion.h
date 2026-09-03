//
//  TSOfflineMapRegion.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/8.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Offline map download region model
 * @chinese 离线地图下载区域模型
 *
 * @discussion
 * [EN]: Describes the geographic region to download as an offline map package.
 *       The region is defined by a center point (latitude/longitude) and a radius in kilometers.
 * [CN]: 描述要下载为离线地图包的地理区域。
 *       区域由中心点（经纬度）和以公里为单位的半径确定。
 */
@interface TSOfflineMapRegion : TSKitBaseModel

/**
 * @brief Center latitude in degrees
 * @chinese 中心点纬度（度）
 */
@property (nonatomic, assign) double latitude;

/**
 * @brief Center longitude in degrees
 * @chinese 中心点经度（度）
 */
@property (nonatomic, assign) double longitude;

/**
 * @brief Download radius in kilometers
 * @chinese 下载半径（公里）
 */
@property (nonatomic, assign) NSInteger radius;

/**
 * @brief Create a region model
 * @chinese 创建区域模型
 *
 * @param latitude
 * EN: Center latitude in degrees
 * CN: 中心点纬度（度）
 *
 * @param longitude
 * EN: Center longitude in degrees
 * CN: 中心点经度（度）
 *
 * @param radius
 * EN: Download radius in kilometers
 * CN: 下载半径（公里）
 *
 * @return
 * EN: A configured region model instance
 * CN: 配置好的区域模型实例
 */
+ (instancetype)regionWithLatitude:(double)latitude
                         longitude:(double)longitude
                            radius:(NSInteger)radius;

@end

NS_ASSUME_NONNULL_END
