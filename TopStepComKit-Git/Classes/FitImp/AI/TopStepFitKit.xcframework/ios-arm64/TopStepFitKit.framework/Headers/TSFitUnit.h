//
//  TSFitUnit.h
//  TopStepFitKit
//
//  Created by 磐石 on 2025/2/20.
//

/**
 * TSFitUnit
 * 设备单位管理类，负责处理设备的各种单位设置，包括长度、温度、重量和时间格式
 * 该类实现了TSUnitInterface协议中定义的所有单位相关方法
 * 
 * 主要功能：
 * 1. 长度单位设置（公制/英制）
 * 2. 温度单位设置（摄氏度/华氏度）
 * 3. 重量单位设置（公斤/磅）
 * 4. 时间格式设置（12小时制/24小时制）
 */
#import "TSFitKitBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSFitUnit : TSFitKitBase<TSUnitInterface>

@end

NS_ASSUME_NONNULL_END
