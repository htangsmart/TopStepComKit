//
//  TSGlassesMediaCount+SJ.h
//  TopStepSJWatchKit
//
//  Created by 磐石 on 2025/6/19.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <SJWatchLib/SJWatchLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSGlassesMediaCount (SJ)

/**
 * @brief Convert WmGlassesMediaCount to TSGlassesMediaCount
 * @chinese 将WmGlassesMediaCount转换为TSGlassesMediaCount
 *
 * @param wmCount
 * EN: WmGlassesMediaCount object to be converted
 * CN: 需要转换的WmGlassesMediaCount对象
 *
 * @return
 * EN: Converted TSGlassesMediaCount object, nil if conversion fails
 * CN: 转换后的TSGlassesMediaCount对象，转换失败时返回nil
 */
+ (nullable TSGlassesMediaCount *)modelWithWmGlassesMediaCount:(nullable WmGlassesMediaCount *)wmCount;

@end

NS_ASSUME_NONNULL_END
