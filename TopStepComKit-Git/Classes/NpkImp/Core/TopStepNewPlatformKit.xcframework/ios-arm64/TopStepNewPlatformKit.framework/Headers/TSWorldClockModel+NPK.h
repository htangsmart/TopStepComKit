//
//  TSWorldClockModel+NPK.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/11/18.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepBleMetaKit/PbSettingParam.pbobjc.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSWorldClockModel (NPK)

/**
 * @brief 将TSWorldClockModel数组转换为TSMetaWorldClockList
 * @chinese 将TSWorldClockModel数组转换为TSMetaWorldClockList
 *
 * @param models TSWorldClockModel数组
 * @return TSMetaWorldClockList对象
 */
+ (TSMetaWorldClockList *)worldClockModelsToMetaWorldClockList:(NSArray<TSWorldClockModel *> *)models;

/**
 * @brief 将TSMetaWorldClockList转换为TSWorldClockModel数组
 * @chinese 将TSMetaWorldClockList转换为TSWorldClockModel数组
 *
 * @param worldClockList TSMetaWorldClockList对象
 * @return TSWorldClockModel数组
 */
+ (NSArray<TSWorldClockModel *> *)worldClockModelsFromMetaWorldClockList:(TSMetaWorldClockList *)worldClockList;

@end

NS_ASSUME_NONNULL_END
