//
//  TSDemoModuleCenter.m
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSDemoModuleCenter.h"

#import <TopStepComKit/TopStepComKit.h>

/**
 * 已知的可选模块入口类。新增模块在这里加一行（同时在 Scripts/ts_demo_modules.rb 定义 entry_class）。
 * 被 Podfile 开关排除的模块运行时不存在，NSClassFromString 返回 nil，自动跳过。
 */
static NSArray<NSString *> *TSDemoKnownModuleClassNames(void) {
    return @[
        @"TSAIDemoModule",  // Modules/AI：AI 对话 / 录音 / 翻译 / 问答
    ];
}

static TSDemoModuleCenter *_moduleCenter = nil;

@interface TSDemoModuleCenter ()

// 已加载的模块
@property (nonatomic, copy, readwrite) NSArray<id<TSDemoModule>> *modules;
// 是否已经启动
@property (nonatomic, assign) BOOL isStarted;

@end

@implementation TSDemoModuleCenter

#pragma mark - 单例实现

/// 获取单例实例
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _moduleCenter = [[super allocWithZone:NULL] init];
    });
    return _moduleCenter;
}

/// 重写 allocWithZone 以确保单例模式
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

/// 实现 NSCopying 协议
- (id)copyWithZone:(struct _NSZone *)zone {
    return [[self class] sharedInstance];
}

/// 实现 NSMutableCopying 协议
- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[self class] sharedInstance];
}

#pragma mark - 生命周期

/// 初始化为空模块列表
- (instancetype)init {
    self = [super init];
    if (self) {
        _modules = @[];
    }
    return self;
}

#pragma mark - 公开方法

/**
 * 按类名清单创建当前构建中存在的模块
 */
- (void)startWithHost:(id<TSDemoModuleHost>)host {
    NSAssert([NSThread isMainThread], @"TSDemoModuleCenter must start on the main thread");
    if (self.isStarted) {
        return;
    }
    self.isStarted = YES;

    NSMutableArray<id<TSDemoModule>> *modules = [NSMutableArray array];
    NSMutableArray<NSString *> *loadedNames = [NSMutableArray array];
    NSMutableArray<NSString *> *absentClassNames = [NSMutableArray array];
    for (NSString *className in TSDemoKnownModuleClassNames()) {
        Class moduleClass = NSClassFromString(className);
        if (moduleClass == Nil) {
            [absentClassNames addObject:className];
            continue;
        }
        if (![moduleClass conformsToProtocol:@protocol(TSDemoModule)]) {
            TSLog(@"[TSDemoModuleCenter] %@ 未遵循 TSDemoModule 协议，已跳过", className);
            continue;
        }
        id<TSDemoModule> module = [(id<TSDemoModule>)[moduleClass alloc] initWithHost:host];
        if (module) {
            [modules addObject:module];
            [loadedNames addObject:[moduleClass moduleName]];
        }
    }
    self.modules = modules;
    TSLog(@"[TSDemoModuleCenter] 已加载模块: %@；未编译进本次构建: %@",
          loadedNames.count > 0 ? [loadedNames componentsJoinedByString:@", "] : @"无",
          absentClassNames.count > 0 ? [absentClassNames componentsJoinedByString:@", "] : @"无");
}

/**
 * 按模块名查找已加载的模块
 */
- (nullable id<TSDemoModule>)moduleNamed:(NSString *)moduleName {
    for (id<TSDemoModule> module in self.modules) {
        if ([[[module class] moduleName] isEqualToString:moduleName]) {
            return module;
        }
    }
    return nil;
}

/**
 * 转发主界面加载完成
 */
- (void)notifyMainInterfaceDidLoad {
    [self ts_forEachModuleRespondingToSelector:@selector(mainInterfaceDidLoad)
                                         block:^(id<TSDemoModule> module) {
        [module mainInterfaceDidLoad];
    }];
}

/**
 * 转发 App 回到活跃状态
 */
- (void)notifyApplicationDidBecomeActive {
    [self ts_forEachModuleRespondingToSelector:@selector(applicationDidBecomeActive)
                                         block:^(id<TSDemoModule> module) {
        [module applicationDidBecomeActive];
    }];
}

/**
 * 转发公网探测结果
 */
- (void)notifyPublicNetworkAccessDidUpdate:(BOOL)isAvailable {
    [self ts_forEachModuleRespondingToSelector:@selector(publicNetworkAccessDidUpdate:)
                                         block:^(id<TSDemoModule> module) {
        [module publicNetworkAccessDidUpdate:isAvailable];
    }];
}

/**
 * 转发网络路径恢复可用
 */
- (void)notifyNetworkPathDidBecomeReachable {
    [self ts_forEachModuleRespondingToSelector:@selector(networkPathDidBecomeReachable)
                                         block:^(id<TSDemoModule> module) {
        [module networkPathDidBecomeReachable];
    }];
}

/**
 * 转发新的设备就绪会话
 */
- (void)notifyDeviceDidBecomeReady:(TSDeviceConnectionSnapshot *)snapshot {
    [self ts_forEachModuleRespondingToSelector:@selector(deviceDidBecomeReady:)
                                         block:^(id<TSDemoModule> module) {
        [module deviceDidBecomeReady:snapshot];
    }];
}

/**
 * 转发设备会话结束
 */
- (void)notifyDeviceDidBecomeUnavailable {
    [self ts_forEachModuleRespondingToSelector:@selector(deviceDidBecomeUnavailable)
                                         block:^(id<TSDemoModule> module) {
        [module deviceDidBecomeUnavailable];
    }];
}

/**
 * 转发绑定记录清除
 */
- (void)notifyDeviceBindingDidClear {
    [self ts_forEachModuleRespondingToSelector:@selector(deviceBindingDidClear)
                                         block:^(id<TSDemoModule> module) {
        [module deviceBindingDidClear];
    }];
}

/**
 * 汇总各模块为指定分组提供的菜单项
 */
- (NSArray<TSValueModel *> *)deviceMenuItemsForSection:(TSDemoModuleMenuSection)section
                                              snapshot:(TSDeviceConnectionSnapshot *)snapshot {
    NSMutableArray<TSValueModel *> *items = [NSMutableArray array];
    for (id<TSDemoModule> module in self.modules) {
        if (![module respondsToSelector:@selector(deviceMenuItemsForSection:snapshot:)]) {
            continue;
        }
        NSArray<TSValueModel *> *moduleItems = [module deviceMenuItemsForSection:section snapshot:snapshot];
        if (moduleItems.count > 0) {
            [items addObjectsFromArray:moduleItems];
        }
    }
    return [items copy];
}

#pragma mark - 私有方法

/**
 * 在主线程依次调用实现了指定钩子的模块
 */
- (void)ts_forEachModuleRespondingToSelector:(SEL)selector block:(void (^)(id<TSDemoModule> module))block {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ts_forEachModuleRespondingToSelector:selector block:block];
        });
        return;
    }
    for (id<TSDemoModule> module in self.modules) {
        if ([module respondsToSelector:selector]) {
            block(module);
        }
    }
}

@end
