//
//  TSBOValueItem.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/25.
//

#import "TSHealthValueItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSBOValueItem : TSHealthValueItem <NSCopying>

/**
 * @brief Blood oxygen value
 * @chinese 血氧值
 * 
 * @discussion
 * [EN]: The blood oxygen value measured as a percentage.
 * [CN]: 以百分比为单位测量的血氧值。
 */
@property (nonatomic,assign) UInt8 oxyValue;

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
 * @brief Convert database dictionary array to TSBOValueItem array
 * @chinese 将数据库字典数组转换为TSBOValueItem数组
 */
+ (NSArray<TSBOValueItem *> *)valueItemsFromDBDicts:(NSArray<NSDictionary *> *)dicts;

/**
 * @brief Convert database dictionary to TSBOValueItem
 * @chinese 将数据库字典转换为TSBOValueItem
 */
+ (TSBOValueItem *)valueItemFromDBDict:(NSDictionary *)dict;


- (NSString *)debugDescription ;

@end

NS_ASSUME_NONNULL_END
