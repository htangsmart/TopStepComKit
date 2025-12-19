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
 * @brief Convert JSON string to dictionary object
 * @chinese 将JSON字符串转换为字典对象
 *
 * @param jsonString
 * EN: JSON string to be converted
 * CN: 需要转换的JSON字符串
 *
 * @return
 * EN: Converted dictionary object, nil if conversion fails
 * CN: 返回转换后的字典对象，如果转换失败则返回nil
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString ;

/**
 * @brief Convert dictionary object to JSON string
 * @chinese 将字典对象转换为JSON字符串
 *
 * @return
 * EN: JSON string representation of the dictionary, nil if conversion fails
 * CN: 返回字典的JSON字符串表示，如果转换失败则返回nil
 *
 * @discussion
 * [EN]: This method converts the dictionary to a JSON string using NSJSONSerialization.
 *       The dictionary must contain only JSON-compatible objects (NSString, NSNumber, NSArray, NSDictionary, NSNull).
 *       If the dictionary contains invalid objects, the conversion will fail and return nil.
 * [CN]: 此方法使用NSJSONSerialization将字典转换为JSON字符串。
 *       字典必须只包含JSON兼容的对象（NSString、NSNumber、NSArray、NSDictionary、NSNull）。
 *       如果字典包含无效对象，转换将失败并返回nil。
 */
- (nullable NSString *)jsonString;

+ (BOOL)isEmptyDictionary:(NSDictionary *)dict ;

/**
 * @brief Get all keys whose values match the specified value
 * @chinese 获取字典中所有值为指定值的键
 *
 * @param targetValue
 * EN: The target value to search for
 * CN: 要查找的目标值
 *
 * @return
 * EN: Array containing all keys whose values match the target value, empty array if no matches found or dictionary is nil
 * CN: 包含所有值为目标值的键的数组，如果没有找到匹配项或字典为nil则返回空数组
 *
 * @discussion
 * [EN]: This method traverses the dictionary and returns all keys whose corresponding values are equal to the target value.
 *       The comparison uses isEqual: method, so it works with NSString, NSNumber, and other Foundation types.
 *       If the dictionary is nil or empty, returns an empty array.
 * [CN]: 此方法遍历字典并返回所有对应值等于目标值的键。
 *       比较使用isEqual:方法，因此适用于NSString、NSNumber和其他Foundation类型。
 *       如果字典为nil或空，返回空数组。
 *
 * @note
 * [EN]: Example: If dictionary is @{@"key1": @"FIL", @"key2": @"FIL", @"key3": @"OTHER"},
 *       calling [dict keysForValue:@"FIL"] returns @[@"key1", @"key2"]
 * [CN]: 示例：如果字典是 @{@"key1": @"FIL", @"key2": @"FIL", @"key3": @"OTHER"}，
 *       调用 [dict keysForValue:@"FIL"] 返回 @[@"key1", @"key2"]
 */
- (NSArray *)keysForValue:(id)targetValue;

@end

NS_ASSUME_NONNULL_END
