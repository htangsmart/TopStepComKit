//
//  TSMessageVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/17.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSMessageVC.h"

@interface TSMessageVC ()


@end

@implementation TSMessageVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Callback

- (void)registerCallBack {
}

#pragma mark - TableView DataSource & Delegate

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"设置消息通知"],
        [TSValueModel valueWithName:@"获取消息通知"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self setMessage];
    } else if (indexPath.row == 1) {
        [self getMessage];
    }
}

#pragma mark - Private Methods

/**
 * 创建测试用的消息通知列表
 * @return 包含多种类型的消息通知模型数组
 */
- (NSArray<TSMessageModel *> *)messages {
    NSMutableArray<TSMessageModel *> *result = [NSMutableArray array];
    
    // 系统通知
    [result addObject:[TSMessageModel modelWithType:TSMessage_Phone enable:YES]];      // 电话
    [result addObject:[TSMessageModel modelWithType:TSMessage_Messages enable:YES]];   // 短信
    [result addObject:[TSMessageModel modelWithType:TSMessage_Email enable:YES]];      // 邮件
    [result addObject:[TSMessageModel modelWithType:TSMessage_Calendar enable:YES]];   // 日历
    
    // 社交应用
    [result addObject:[TSMessageModel modelWithType:TSMessage_WeChat enable:YES]];     // 微信
    [result addObject:[TSMessageModel modelWithType:TSMessage_QQ enable:YES]];         // QQ
    [result addObject:[TSMessageModel modelWithType:TSMessage_WhatsApp enable:YES]];   // WhatsApp
    [result addObject:[TSMessageModel modelWithType:TSMessage_Line enable:YES]];       // Line
    [result addObject:[TSMessageModel modelWithType:TSMessage_Telegram enable:YES]];   // Telegram
    
    // 国外社交
    [result addObject:[TSMessageModel modelWithType:TSMessage_Facebook enable:NO]];    // Facebook
    [result addObject:[TSMessageModel modelWithType:TSMessage_Twitter enable:NO]];     // Twitter
    [result addObject:[TSMessageModel modelWithType:TSMessage_Instagram enable:NO]];   // Instagram
    [result addObject:[TSMessageModel modelWithType:TSMessage_Snapchat enable:NO]];    // Snapchat
    
    // 邮件客户端
    [result addObject:[TSMessageModel modelWithType:TSMessage_Gmail enable:YES]];      // Gmail
    [result addObject:[TSMessageModel modelWithType:TSMessage_Outlook enable:YES]];    // Outlook
    
    // 视频和音乐
    [result addObject:[TSMessageModel modelWithType:TSMessage_YouTube enable:YES]];    // YouTube
    [result addObject:[TSMessageModel modelWithType:TSMessage_AppleMusic enable:YES]]; // Apple Music
    
    // 其他常用应用
    [result addObject:[TSMessageModel modelWithType:TSMessage_Alipay enable:YES]];     // 支付宝
    [result addObject:[TSMessageModel modelWithType:TSMessage_FaceTime enable:YES]];   // FaceTime
    [result addObject:[TSMessageModel modelWithType:TSMessage_Zoom enable:YES]];       // Zoom
    
    return [result copy];
}

#pragma mark - Network Methods

- (void)setMessage {
    TSLog(@"[TSMessageVC] 开始设置消息通知");
    
    NSArray<TSMessageModel *> *messages = [self messages];
    __weak typeof(self) weakSelf = self;
    
    [[[TopStepComKit sharedInstance] message] setMessageEnableList:messages 
                                                      completion:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            TSLog(@"[TSMessageVC] 设置消息通知失败: %@", error.localizedDescription);
            //[TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        
        TSLog(@"[TSMessageVC] 设置消息通知成功");
        //[TSToast showText:@"设置消息通知成功" onView:weakSelf.view dismissAfterDelay:1.0f];
    }];
}

- (void)getMessage {
    TSLog(@"[TSMessageVC] 开始获取消息通知");
    
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] message] getMessageEnableList:^(NSArray<TSMessageModel *> * _Nullable notifications, NSError * _Nullable error) {
        if (error) {
            TSLog(@"[TSMessageVC] 获取消息通知失败: %@", error.localizedDescription);
            //[TSToast showText:error.localizedDescription onView:weakSelf.view dismissAfterDelay:2.0f];
            return;
        }
        
        if (notifications.count == 0) {
            TSLog(@"[TSMessageVC] 未获取到消息通知设置");
            //[TSToast showText:@"未获取到消息通知设置" onView:weakSelf.view dismissAfterDelay:1.0f];
            return;
        }
        
        TSLog(@"[TSMessageVC] 获取消息通知成功，共%lu个通知类型", (unsigned long)notifications.count);
        //[TSToast showText:@"获取消息通知成功" onView:weakSelf.view dismissAfterDelay:1.0f];
        
        // 打印通知详情
        [weakSelf logNotifications:notifications];
    }];
}

/**
 * 打印通知列表详情
 * @param notifications 要打印的通知列表
 */
- (void)logNotifications:(NSArray<TSMessageModel *> *)notifications {
    TSLog(@"[TSMessageVC] 通知列表详情 =========");
    [notifications enumerateObjectsUsingBlock:^(TSMessageModel *model, NSUInteger idx, BOOL *stop) {
        TSLog(@"[TSMessageVC] %lu : %@", model.type, model.enable ? @"启用" : @"禁用");
    }];
    TSLog(@"[TSMessageVC] =====================");
}

@end
