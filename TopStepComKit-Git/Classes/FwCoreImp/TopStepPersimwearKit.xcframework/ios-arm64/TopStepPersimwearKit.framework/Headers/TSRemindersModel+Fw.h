//
//  TSRemindersModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/13.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSRemindersModel (Fw)

+ (NSArray *)remindSettingArrayWithItems:(NSDictionary *)itemDict index:(NSDictionary *)indexDict;

/// 将提醒数组转换为 ht.alertContents 格式的字典
/// Convert reminder array to ht.alertContents format dictionary
+ (NSDictionary *)transRemindersToValueDict:(NSArray<TSRemindersModel *> *)reminders;

/// 将提醒数组转换为索引数组（用于 ht.alertIndexes）
/// Convert reminder array to index array (for ht.alertIndexes)
+ (NSArray *)transRemindersToIndexArray:(NSArray<TSRemindersModel *> *)reminders;

@end

NS_ASSUME_NONNULL_END
