//
//  NSDictionary+Tool.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Tool)

/**
 * @brief 将JSON字符串转换为字典对象
 * @param jsonString 需要转换的JSON字符串
 * @return 返回转换后的字典对象，如果转换失败则返回nil
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString ;

+ (BOOL)isEmptyDictionary:(NSDictionary *)dict ;

@end

NS_ASSUME_NONNULL_END
