//
//  MagicMemoryData.h
//  MagicHelper
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 记忆列表项模型，对应接口返回的 data 元素
@interface MagicMemoryData : NSObject

@property (nonatomic, copy) NSString *memoryId;
@property (nonatomic, copy) NSString *topic;
/// content 为 key-value 字典，如 @{@"location": @"地下停车场"}
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *content;
/// 展示用文案，接口字段名为 displayContent；若不为空则优先显示，为空则用 content 拼出的 contentDisplayString
@property (nonatomic, copy) NSString *displayContent;
/// 创建时间戳（秒）
@property (nonatomic, assign) NSTimeInterval gmtCreate;
/// 修改时间戳（秒）
@property (nonatomic, assign) NSTimeInterval gmtModified;

/// 从接口返回的字典解析
+ (nullable instancetype)modelWithDictionary:(NSDictionary *)dict;

/// 将 content 转为展示用字符串，如 "location: 地下停车场"
- (NSString *)contentDisplayString;

/// 展示用字符串：displayContent 不为空时返回 displayContent，否则返回 contentDisplayString
- (NSString *)displayStringForShow;

@end

NS_ASSUME_NONNULL_END
