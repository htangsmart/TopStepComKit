//
//  TSFileOTAVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/17.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSFileOTAVC.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface TSFileOTAVC ()

/// 文件选择控制器
@property (nonatomic, strong) UIDocumentPickerViewController *documentPicker;

@end

@implementation TSFileOTAVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件OTA升级";
}

#pragma mark - TableView DataSource & Delegate
- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"选择文件并开始升级"],
        [TSValueModel valueWithName:@"取消升级"],
    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self startOTA];
    } else if (indexPath.row == 1) {
        [self cancelOTA];
    }
}

#pragma mark - Private Methods

- (void)startOTA {
    // 创建文件选择器
    NSArray *documentTypes = @[@"public.data"];
    self.documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
    self.documentPicker.delegate = self;
    self.documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    // 显示文件选择器
    [self presentViewController:self.documentPicker animated:YES completion:nil];
}

- (void)cancelOTA {
    [[[TopStepComKit sharedInstance] fileOTA] stopFileOTAUpgrade:^(BOOL isSuccess, NSError * _Nullable error) {
        if (isSuccess) {
            [self showToast:@"取消升级成功"];
        } else {
            [self showToast:[NSString stringWithFormat:@"取消升级失败：%@", error.localizedDescription]];
        }
    }];
}

- (void)startOTAWithFilePath:(NSString *)filePath {
    // 创建OTA模型
    TSFileOTAModel *model = [TSFileOTAModel modelWithLocalFilePath:filePath];
    
    // 先检查是否可以升级
    [[[TopStepComKit sharedInstance] fileOTA] checkCanUpgrade:model completion:^(BOOL canUpgrade, NSError * _Nullable error) {
        if (!canUpgrade) {
            [self showToast:error.localizedDescription];
            return;
        }
        
        // 显示进度提示
        [TSToast showText:@"开始升级..." onView:self.view];
        
        // 开始OTA升级
        [[[TopStepComKit sharedInstance] fileOTA] startFileOTAUpgrade:model progressBlock:^(TSFileOTAResult result, NSInteger progress) {
            if (result == TSFileOTAResultProgress) {
                [TSToast showText:[NSString stringWithFormat:@"升级中...%.0f%%", progress / 100.0] onView:self.view];
            }
        } completion:^(TSFileOTAResult result, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 处理结果
                switch (result) {
                    case TSFileOTAResultSuccess:
                        [TSToast showText:@"升级成功" onView:self.view dismissAfterDelay:1.5];
                        break;
                    case TSFileOTAResultFailed:
                        [TSToast showText:[NSString stringWithFormat:@"升级失败：%@", error.localizedDescription] onView:self.view dismissAfterDelay:1.5];
                        break;
                    case TSFileOTAResultCompleted:
                        [TSToast showText:@"升级完成" onView:self.view dismissAfterDelay:1.5];
                        break;
                    default:
                        break;
                }
            });
        }];

    }];
    
}
     


#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) {
        [self showToast:@"未选择文件"];
        return;
    }
    
    // 获取选中文件的路径
    NSURL *fileURL = urls.firstObject;
    NSString *filePath = fileURL.path;
    
    // 开始OTA升级
    [self startOTAWithFilePath:filePath];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self showToast:@"已取消文件选择"];
}

#pragma mark - Helper Methods

- (void)showToast:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:2.0];
}

@end
