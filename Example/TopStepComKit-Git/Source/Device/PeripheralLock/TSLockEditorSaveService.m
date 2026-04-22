//
//  TSLockEditorSaveService.m
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/3/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSLockEditorSaveService.h"
#import <TopStepComKit/TopStepComKit.h>

@implementation TSLockEditorSaveService

/**
 * 将 1–6 位密码左侧补 0 为 6 位，供 SDK 使用；nil/空则返回 000000
 */
+ (NSString *)ts_passwordPaddedToSix:(NSString *)password {
    if (!password || password.length == 0) return @"000000";
    if (password.length >= 6) return [password substringToIndex:6];
    NSMutableString *padded = [password mutableCopy];
    while (padded.length < 6) {
        [padded insertString:@"0" atIndex:0];
    }
    return [padded copy];
}

/**
 * 获取外设锁接口；不支持时在主线程回调 completion(success, nil) 并返回 nil
 */
+ (nullable id<TSPeripheralLockInterface>)ts_lockInterfaceOrCallCompletion:(void (^)(BOOL, NSError * _Nullable))completion
                                                               successOnUnsupported:(BOOL)successOnUnsupported {
    id<TSPeripheralLockInterface> lock = [TopStepComKit sharedInstance].peripheralLock;
    if (!lock) {
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(successOnUnsupported, nil); });
        return nil;
    }
    return lock;
}

#pragma mark - 公开方法

/**
 * 通过 SDK 保存屏幕锁或游戏锁，主线程回调 completion
 */
+ (void)saveWithScreenLock:(BOOL)isScreenLock
                  password:(NSString *)password
             startMinutes:(NSInteger)startMinutes
               endMinutes:(NSInteger)endMinutes
               completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    if (isScreenLock) {
        [self ts_saveScreenLockWithPassword:password completion:completion];
    } else {
        [self ts_saveGameLockWithPassword:password startMinutes:startMinutes endMinutes:endMinutes completion:completion];
    }
}

/**
 * 设置屏幕锁开/关到设备
 */
+ (void)setScreenLockEnabled:(BOOL)enabled
                    password:(NSString * _Nullable)password
                  completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    id<TSPeripheralLockInterface> lock = [self ts_lockInterfaceOrCallCompletion:completion successOnUnsupported:YES];
    if (!lock) return;
    if (![lock isSupportScreenLock]) {
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(YES, nil); });
        return;
    }
    TSScreenLockModel *model = [[TSScreenLockModel alloc] init];
    model.enabled = enabled;
    model.password = [self ts_passwordPaddedToSix:password];
    [lock setScreenLock:model completion:^(BOOL success, NSError * _Nullable error) {
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(success, error); });
    }];
}

/**
 * 设置游戏锁开/关到设备
 */
+ (void)setGameLockEnabled:(BOOL)enabled
                  password:(NSString * _Nullable)password
             startMinutes:(NSInteger)startMinutes
               endMinutes:(NSInteger)endMinutes
               completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    id<TSPeripheralLockInterface> lock = [self ts_lockInterfaceOrCallCompletion:completion successOnUnsupported:YES];
    if (!lock) return;
    if (![lock isSupportGameLock]) {
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(YES, nil); });
        return;
    }
    TSGameLockModel *model = [[TSGameLockModel alloc] init];
    model.enabled = enabled;
    model.password = [self ts_passwordPaddedToSix:password];
    model.start = startMinutes;
    model.end = endMinutes;
    [lock setGameLock:model completion:^(BOOL success, NSError * _Nullable error) {
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(success, error); });
    }];
}

#pragma mark - 私有方法

/**
 * 保存屏幕锁配置（isEnabled=YES）
 */
+ (void)ts_saveScreenLockWithPassword:(NSString *)password
                           completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    id<TSPeripheralLockInterface> lock = [self ts_lockInterfaceOrCallCompletion:completion successOnUnsupported:NO];
    if (!lock) return;
    if (![lock isSupportScreenLock]) {
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, nil); });
        return;
    }
    TSScreenLockModel *model = [[TSScreenLockModel alloc] init];
    model.enabled = YES;
    model.password = [self ts_passwordPaddedToSix:password];
    [lock setScreenLock:model completion:^(BOOL success, NSError * _Nullable error) {
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(success, error); });
    }];
}

/**
 * 保存游戏锁配置（isEnabled=YES）
 */
+ (void)ts_saveGameLockWithPassword:(NSString *)password
                       startMinutes:(NSInteger)startMinutes
                         endMinutes:(NSInteger)endMinutes
                         completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    id<TSPeripheralLockInterface> lock = [self ts_lockInterfaceOrCallCompletion:completion successOnUnsupported:NO];
    if (!lock) return;
    if (![lock isSupportGameLock]) {
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(NO, nil); });
        return;
    }
    TSGameLockModel *model = [[TSGameLockModel alloc] init];
    model.enabled = YES;
    model.password = [self ts_passwordPaddedToSix:password];
    model.start = startMinutes;
    model.end = endMinutes;
    [lock setGameLock:model completion:^(BOOL success, NSError * _Nullable error) {
        if (completion) dispatch_async(dispatch_get_main_queue(), ^{ completion(success, error); });
    }];
}

@end
