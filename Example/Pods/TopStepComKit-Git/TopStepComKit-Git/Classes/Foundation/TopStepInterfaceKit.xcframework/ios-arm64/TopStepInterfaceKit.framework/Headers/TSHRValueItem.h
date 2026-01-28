//
//  TSHRValueItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import <Foundation/Foundation.h>
#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN


@interface TSHRValueItem : TSHealthValueItem <NSCopying>

/**
 * @brief Heart rate value
 * @chinese 心率值
 * 
 * @discussion
 * [EN]: The heart rate value measured in beats per minute (BPM).
 * [CN]: 以每分钟心跳次数（BPM）为单位测量的心率值。
 */
@property (nonatomic,assign) UInt8 hrValue;

/**
 * @brief Indicates if the measurement was initiated by the user
 * @chinese 指示测量是否为用户主动发起
 * 
 * @discussion
 * [EN]: A boolean value indicating whether the measurement was taken as initiated by the user.
 * [CN]: 布尔值，指示测量是否为用户主动发起的测量。
 */
@property (nonatomic,assign) BOOL isUserInitiated;


/**
 * @brief Convert database dictionary to TSHRValueItem
 * @chinese 将数据库字典转换为TSHRValueItem
 */
+ (TSHRValueItem *)valueItemFromDBDict:(NSDictionary *)dict;

/**
 * @brief Convert database dictionary array to TSHRValueItem array
 * @chinese 将数据库字典数组转换为TSHRValueItem数组
 */
+ (NSArray<TSHRValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

+ (NSArray<TSHRValueItem *> *)sportValueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts ;

- (NSString *)debugDescription ;

@end

NS_ASSUME_NONNULL_END
