//
//  TSGlassesStorageInfo+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/6/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <SJWatchLib/SJWatchLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSGlassesStorageInfo (SJ)

/**
 * @brief Convert WmGlassesStorageInfo to TSGlassesStorageInfo
 * @chinese 将WmGlassesStorageInfo转换为TSGlassesStorageInfo
 *
 * @param wmInfo
 * EN: WmGlassesStorageInfo object to be converted
 * CN: 需要转换的WmGlassesStorageInfo对象
 *
 * @return
 * EN: Converted TSGlassesStorageInfo object, nil if conversion fails
 * CN: 转换后的TSGlassesStorageInfo对象，转换失败时返回nil
 */
+ (nullable TSGlassesStorageInfo *)modelWithWmGlassesStorageInfo:(nullable WmGlassesStorageInfo *)wmInfo;

@end

NS_ASSUME_NONNULL_END
