//
//  TSOfflineMapStore.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSOfflineMapStore.h"

#import "TSOfflineMapItem.h"

/// 本地地图数量上限
static const NSInteger kTSMaxLocalMapCount = 20;

@interface TSOfflineMapStore ()

// 内存中的本地地图列表（最新在前）
@property (nonatomic, strong) NSMutableArray<TSOfflineMapItem *> *localMaps;

@end

@implementation TSOfflineMapStore

#pragma mark - 单例实现

+ (instancetype)sharedStore {
    static TSOfflineMapStore *store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[TSOfflineMapStore alloc] init];
    });
    return store;
}

#pragma mark - 初始化

- (instancetype)init {
    self = [super init];
    if (self) {
        _localMaps = [NSMutableArray array];
        [self ts_loadFromDisk];
    }
    return self;
}

#pragma mark - 公开方法

- (NSInteger)maxLocalMapCount {
    return kTSMaxLocalMapCount;
}

/// 所有本地地图
- (NSArray<TSOfflineMapItem *> *)allLocalMaps {
    return [self.localMaps copy];
}

/// 本地地图数量
- (NSInteger)localMapCount {
    return self.localMaps.count;
}

/// 名称是否已被本地占用
- (BOOL)isNameUsedLocally:(NSString *)name {
    for (TSOfflineMapItem *item in self.localMaps) {
        if ([item.name isEqualToString:name]) return YES;
    }
    return NO;
}

/// 新增本地地图
- (TSOfflineMapItem *)addLocalMapWithName:(NSString *)name
                              packagePath:(NSString *)packagePath
                                   radius:(NSInteger)radius {
    TSOfflineMapItem *item = [[TSOfflineMapItem alloc] init];
    item.name = name;
    item.packagePath = packagePath;
    item.radius = radius;
    item.createdAt = [[NSDate date] timeIntervalSince1970];
    item.fileSize = [self ts_fileSizeAtPath:packagePath];

    [self.localMaps insertObject:item atIndex:0];
    [self ts_saveToDisk];
    return item;
}

/// 删除本地地图并删除包文件
- (void)removeLocalMapWithName:(NSString *)name {
    TSOfflineMapItem *target = nil;
    for (TSOfflineMapItem *item in self.localMaps) {
        if ([item.name isEqualToString:name]) {
            target = item;
            break;
        }
    }
    if (!target) return;

    if (target.packagePath.length > 0) {
        [[NSFileManager defaultManager] removeItemAtPath:target.packagePath error:nil];
    }
    [self.localMaps removeObject:target];
    [self ts_saveToDisk];
}

#pragma mark - 私有方法

/// 索引 plist 路径（Documents/OfflineMaps/index.plist）
- (NSString *)ts_indexFilePath {
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *dir = [docs stringByAppendingPathComponent:@"OfflineMaps"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dir]) {
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [dir stringByAppendingPathComponent:@"index.plist"];
}

/// 读取指定路径文件大小（字节）
- (unsigned long long)ts_fileSizeAtPath:(NSString *)path {
    if (path.length == 0) return 0;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [attrs fileSize];
}

/// 从磁盘加载索引
- (void)ts_loadFromDisk {
    NSArray *raw = [NSArray arrayWithContentsOfFile:[self ts_indexFilePath]];
    if (![raw isKindOfClass:[NSArray class]]) return;
    for (NSDictionary *dict in raw) {
        TSOfflineMapItem *item = [TSOfflineMapItem itemWithDictionary:dict];
        if (item) [self.localMaps addObject:item];
    }
}

/// 保存索引到磁盘
- (void)ts_saveToDisk {
    NSMutableArray *raw = [NSMutableArray arrayWithCapacity:self.localMaps.count];
    for (TSOfflineMapItem *item in self.localMaps) {
        [raw addObject:[item dictionaryRepresentation]];
    }
    [raw writeToFile:[self ts_indexFilePath] atomically:YES];
}

@end
