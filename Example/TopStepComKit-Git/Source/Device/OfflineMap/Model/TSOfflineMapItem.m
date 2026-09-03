//
//  TSOfflineMapItem.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSOfflineMapItem.h"

@implementation TSOfflineMapItem

#pragma mark - 公开方法

/// 换算为可读大小文案
- (NSString *)readableSize {
    double mb = self.fileSize / (1024.0 * 1024.0);
    if (mb >= 1024.0) {
        return [NSString stringWithFormat:@"%.2f GB", mb / 1024.0];
    }
    if (mb >= 1.0) {
        return [NSString stringWithFormat:@"%.0f MB", mb];
    }
    double kb = self.fileSize / 1024.0;
    return [NSString stringWithFormat:@"%.0f KB", MAX(kb, 1.0)];
}

/// 从字典还原模型
+ (instancetype)itemWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) return nil;
    NSString *name = dictionary[@"name"];
    NSString *path = dictionary[@"packagePath"];
    if (name.length == 0 || path.length == 0) return nil;

    TSOfflineMapItem *item = [[TSOfflineMapItem alloc] init];
    item.name = name;
    item.packagePath = path;
    item.fileSize = [dictionary[@"fileSize"] unsignedLongLongValue];
    item.radius = [dictionary[@"radius"] integerValue];
    item.createdAt = [dictionary[@"createdAt"] doubleValue];
    return item;
}

/// 序列化为字典
- (NSDictionary *)dictionaryRepresentation {
    return @{
        @"name": self.name ?: @"",
        @"packagePath": self.packagePath ?: @"",
        @"fileSize": @(self.fileSize),
        @"radius": @(self.radius),
        @"createdAt": @(self.createdAt),
    };
}

@end
