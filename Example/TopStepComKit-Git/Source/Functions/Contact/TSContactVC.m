//
//  TSContactVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/12.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSContactVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>

@interface TSContactVC ()

@end

@implementation TSContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"联系人管理";
    
    TSLogInfo(@"[Contact] 联系人管理页面已加载");
    [self registerCallBack];
}

- (void)registerCallBack {
    TSLogInfo(@"[Contact] 开始注册联系人变化回调");
    
    [[[TopStepComKit sharedInstance] contact] registerContactsDidChangedBlock:^(NSArray<TSContactModel *> * _Nonnull allContacts, NSError * _Nonnull error) {
        if (error) {
            TSLogError(@"[Contact] 联系人变化回调错误: %@", error);
            [TSToast showText:@"联系人同步失败" onView:self.view dismissAfterDelay:1.0f];
            return;
        }
        
        if (allContacts && allContacts.count > 0) {
            TSLogInfo(@"[Contact] 联系人发生变化，当前数量: %lu", (unsigned long)allContacts.count);
            [TSToast showText:@"联系人已更新" onView:self.view dismissAfterDelay:1.0f];
        } else {
            TSLogInfo(@"[Contact] 联系人已清空");
            [TSToast showText:@"联系人已清空" onView:self.view dismissAfterDelay:1.0f];
        }
    }];
    
    TSLogInfo(@"[Contact] 联系人变化回调注册完成");
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"设置联系人"],
        [TSValueModel valueWithName:@"获取联系人"],
        [TSValueModel valueWithName:@"设置紧急联系人"],
        [TSValueModel valueWithName:@"获取紧急联系人"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self setContact];
    } else if (indexPath.row == 1) {
        [self getContact];
    } else if (indexPath.row == 2) {
        [self setEmergencyContact];
    } else {
        [self getEmergencyContact];
    }
}

- (NSArray *)allContact {
    return @[
        [TSContactModel contactWithName:@"张三" phoneNum:@"15201053240"],
        [TSContactModel contactWithName:@"李四" phoneNum:@"15201053252"],
        [TSContactModel contactWithName:@"王五" phoneNum:@"15201053263"],
        [TSContactModel contactWithName:@"赵六" phoneNum:@"15201053274"],
        [TSContactModel contactWithName:@"王麻子" phoneNum:@"15201053285"]
    ];
}

- (NSArray *)emergencyContact {
    return @[[TSContactModel contactWithName:@"张三" phoneNum:@"15201053240" shortName:@"D"],
             [TSContactModel contactWithName:@"李四" phoneNum:@"15201053252" shortName:@"D"]];
}

/**
 * 设置所有联系人
 */
- (void)setContact {
    TSLogInfo(@"[Contact] 开始设置联系人");
    [TSToast showText:@"正在设置联系人..." onView:self.view dismissAfterDelay:1.0f complete:^{
        NSArray *contacts = [self allContact];
        [[[TopStepComKit sharedInstance] contact] setAllContacts:contacts completion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                TSLogInfo(@"[Contact] 联系人设置成功，数量: %lu", (unsigned long)contacts.count);
                [TSToast showText:@"联系人设置成功" onView:self.view dismissAfterDelay:1.0f];
            } else {
                TSLogError(@"[Contact] 联系人设置失败: %@", error);
                [TSToast showText:@"联系人设置失败" onView:self.view dismissAfterDelay:1.0f];
            }
        }];

    }];
    
}

/**
 * 获取所有联系人
 */
- (void)getContact {
    TSLogInfo(@"[Contact] 开始获取联系人");
    [TSToast showText:@"正在获取联系人..." onView:self.view dismissAfterDelay:1.0f complete:^{
        
        [[[TopStepComKit sharedInstance] contact] getAllContacts:^(NSArray<TSContactModel *> * _Nullable allContacts, NSError * _Nullable error) {
            if (error) {
                TSLogError(@"[Contact] 获取联系人失败: %@", error);
                [TSToast showText:@"获取联系人失败" onView:self.view dismissAfterDelay:1.0f];
                return;
            }
            
            if (allContacts && allContacts.count > 0) {
                TSLogInfo(@"[Contact] 获取联系人成功，数量: %lu", (unsigned long)allContacts.count);
                [TSToast showText:[NSString stringWithFormat:@"获取到%lu个联系人", (unsigned long)allContacts.count]
                         onView:self.view
               dismissAfterDelay:1.0f];
            } else {
                TSLogInfo(@"[Contact] 没有联系人");
                [TSToast showText:@"没有联系人" onView:self.view dismissAfterDelay:1.0f];
            }
        }];
        

    }];
    
}

/**
 * 设置紧急联系人
 */
- (void)setEmergencyContact {
    TSLogInfo(@"[Contact] 开始设置紧急联系人");
    [TSToast showText:@"正在设置紧急联系人..." onView:self.view dismissAfterDelay:1.0f complete:^{
        NSArray *emergencyContacts = [self emergencyContact];
        [[[TopStepComKit sharedInstance] contact] setEmergencyContacts:emergencyContacts sosOn:YES completion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                TSLogInfo(@"[Contact] 紧急联系人设置成功，数量: %lu", (unsigned long)emergencyContacts.count);
                [TSToast showText:@"紧急联系人设置成功" onView:self.view dismissAfterDelay:1.0f];
            } else {
                TSLogError(@"[Contact] 紧急联系人设置失败: %@", error);
                [TSToast showText:@"紧急联系人设置失败" onView:self.view dismissAfterDelay:1.0f];
            }
        }];
    }];
    
}

/**
 * 获取紧急联系人
 */
- (void)getEmergencyContact {
    TSLogInfo(@"[Contact] 开始获取紧急联系人");
    [TSToast showText:@"正在获取紧急联系人..." onView:self.view dismissAfterDelay:1.0f complete:^{
        
        [[[TopStepComKit sharedInstance] contact] getEmergencyContacts:^(NSArray<TSContactModel *> * _Nullable emergencyContact, BOOL isSosOn, NSError * _Nullable error) {
            if (error) {
                TSLogError(@"[Contact] 获取紧急联系人失败: %@", error);
                [TSToast showText:@"获取紧急联系人失败" onView:self.view dismissAfterDelay:1.0f];
                return;
            }
            if (emergencyContact && emergencyContact.count > 0) {
                TSLogInfo(@"[Contact] 获取紧急联系人成功，数量: %lu", (unsigned long)emergencyContact.count);
                [TSToast showText:[NSString stringWithFormat:@"获取到%lu个紧急联系人", (unsigned long)emergencyContact.count]
                         onView:self.view
               dismissAfterDelay:1.0f];
            } else {
                TSLogInfo(@"[Contact] 没有紧急联系人");
                [TSToast showText:@"没有紧急联系人" onView:self.view dismissAfterDelay:1.0f];
            }

        }];
        
    }];
    
}

- (void)dealloc {
    TSLogInfo(@"[Contact] 联系人管理页面已释放");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
