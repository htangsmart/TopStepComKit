//
//  TSPeripheralDialVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/19.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPeripheralDialVC.h"

@interface TSPeripheralDialVC ()

/**
 * @brief Document picker for file selection
 * @chinese 用于文件选择的文档选择器
 *
 * @discussion
 * EN: Used to present the system file picker for selecting dial files.
 *     Allows users to choose files from the Files app or other document providers.
 *
 * CN: 用于显示系统文件选择器来选择表盘文件。
 *     允许用户从文件应用或其他文档提供者中选择文件。
 */
@property (nonatomic, strong) UIDocumentPickerViewController *documentPicker;

/**
 * @brief Selected file path for dial
 * @chinese 选中的表盘文件路径
 *
 * @discussion
 * EN: Stores the file path of the selected dial file.
 *     Used when pushing custom dials to set the filePath property.
 *
 * CN: 存储选中的表盘文件路径。
 *     在推送自定义表盘时用于设置filePath属性。
 */
@property (nonatomic, strong) NSString *selectedFilePath;

@end

@implementation TSPeripheralDialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self registerCallBack];
}

- (void)registerCallBack {
    [[[TopStepComKit sharedInstance] dial] registerDialDidChangedBlock:^(NSArray<TSDialModel *> * _Nullable allDials) {
        
    }];
    
}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"获取当前表盘"],
        [TSValueModel valueWithName:@"获取所有表盘"],
        [TSValueModel valueWithName:@"推送云端表盘"],
        [TSValueModel valueWithName:@"推送自定义表盘"],
        [TSValueModel valueWithName:@"删除云端表盘"],
        [TSValueModel valueWithName:@"删除自定义表盘"],
        [TSValueModel valueWithName:@"获取预留空间"],
        [TSValueModel valueWithName:@"选择文件并推送表盘"],
        [TSValueModel valueWithName:@"切换表盘"],
        [TSValueModel valueWithName:@"获取AI表盘参数"],

    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self getCurrentDial];
    } else if(indexPath.row == 1){
        [self getAllDials];
    } else if(indexPath.row == 2){
        [self pushCloudDial];
    } else if(indexPath.row == 3){
        [self pushCustomerDial];
    } else if(indexPath.row == 4){
        [self deleteCloudDial];
    } else if(indexPath.row == 5){
        [self deleteCustomDial];
    } else if(indexPath.row == 6){
        [self getRemainSpace];
    } else if(indexPath.row == 7){
        [self selectFileAndPushDial];
    }else if (indexPath.row == 8){
        [self switchDial];
    } else{
        [self reuqestAIDialParam];
    }
}

/**
 * 选择文件并推送表盘
 */
- (void)selectFileAndPushDial {
    [self showFilePicker];
}

/**
 * 显示文件选择器
 */
- (void)showFilePicker {
    // 创建文档类型数组，支持常见的表盘文件格式
    // 使用字符串数组来避免iOS版本兼容性问题
    NSArray *documentTypes = @[
        @"public.data",           // 通用数据文件
        @"public.archive",        // 压缩文件
        @"public.item"            // 通用项目文件
    ];
    
    // 创建文档选择器 - 使用iOS 8.0+兼容的初始化方法
    self.documentPicker = [[UIDocumentPickerViewController alloc]
                          initWithDocumentTypes:documentTypes
                          inMode:UIDocumentPickerModeImport];
    self.documentPicker.delegate = self;
    self.documentPicker.allowsMultipleSelection = NO;
    
    // 设置标题
    self.documentPicker.title = @"选择表盘文件";
    
    // 显示文件选择器
    [self presentViewController:self.documentPicker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

/**
 * 用户选择了文件
 */
- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) {
        NSLog(@"没有选择文件");
        return;
    }
    
    NSURL *selectedURL = urls.firstObject;
    NSLog(@"选择的文件URL: %@", selectedURL);
    
    // 获取文件名
    NSString *fileName = [selectedURL lastPathComponent];
    NSLog(@"文件名: %@", fileName);
    
    // 获取Documents目录路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *destinationPath = [documentsPath stringByAppendingPathComponent:fileName];
    
    NSLog(@"目标路径: %@", destinationPath);
    
    // 检查目标文件是否已存在，如果存在则删除
    if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        NSError *removeError;
        if (![[NSFileManager defaultManager] removeItemAtPath:destinationPath error:&removeError]) {
            NSLog(@"删除已存在的文件失败: %@", removeError);
            [self showAlertWithTitle:@"错误" message:@"删除已存在的文件失败"];
            return;
        }
    }
    
    // 开始安全访问文件
    BOOL startedAccessing = [selectedURL startAccessingSecurityScopedResource];
    
    @try {
        // 复制文件到Documents目录
        NSError *copyError;
        BOOL copySuccess = [[NSFileManager defaultManager] copyItemAtURL:selectedURL
                                                                   toURL:[NSURL fileURLWithPath:destinationPath]
                                                                    error:&copyError];
        
        if (!copySuccess) {
            NSLog(@"文件复制失败: %@", copyError);
            [self showAlertWithTitle:@"错误" message:[NSString stringWithFormat:@"文件复制失败: %@", copyError.localizedDescription]];
            return;
        }
        
        // 设置沙盒文件路径
        self.selectedFilePath = destinationPath;
        
        // 获取文件信息
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:destinationPath error:nil];
        NSNumber *fileSize = fileAttributes[NSFileSize];
        
        NSLog(@"文件已复制到沙盒: %@", destinationPath);
        NSLog(@"文件大小: %@ bytes", fileSize);
        
        // 显示文件信息并询问是否推送
        NSString *message = [NSString stringWithFormat:@"文件已保存到沙盒\n文件名: %@\n文件大小: %@ bytes\n\n是否要推送这个表盘文件？",
                            fileName, fileSize];
        
        [self showConfirmAlertWithTitle:@"确认推送"
                               message:message
                        confirmHandler:^{
            [self pushDialWithSelectedFile];
        }];
        
    } @finally {
        // 停止安全访问
        if (startedAccessing) {
            [selectedURL stopAccessingSecurityScopedResource];
        }
    }
}

/**
 * 用户取消了文件选择
 */
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"用户取消了文件选择");
}

/**
 * 使用选中的文件推送表盘
 */
- (void)pushDialWithSelectedFile {
    if (!self.selectedFilePath) {
        NSLog(@"没有选中的文件");
        return;
    }
    
    // 验证沙盒文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.selectedFilePath]) {
        NSLog(@"沙盒文件不存在: %@", self.selectedFilePath);
        [self showAlertWithTitle:@"错误" message:@"沙盒文件不存在"];
        return;
    }
    
//    // 创建表盘模型
//    TSFitDialModel *cloudDial = [TSFitDialModel new];
//    cloudDial.dialId = [NSString stringWithFormat:@"custom_%ld", (long)[[NSDate date] timeIntervalSince1970]];
//    cloudDial.dialName = [NSString stringWithFormat:@"自定义表盘_%@", [[self.selectedFilePath lastPathComponent] stringByDeletingPathExtension]];
//    
//    cloudDial.dialType = eTSDialTypeCustomer; // 使用自定义表盘类型
//    cloudDial.dialImage = [UIImage imageNamed:@"customer_background_Image"];
//    cloudDial.dialPreviewImage = [UIImage imageNamed:@"customer_background_Image"];
//
//    cloudDial.filePath = self.selectedFilePath; // 使用沙盒路径
//    cloudDial.dialSize = CGSizeMake(240, 240); // 默认尺寸，可根据需要调整
//    cloudDial.dialPreviewSize = CGSizeMake(120, 120);
//    cloudDial.timePosition = eTSDialTimePositionRight;
//    cloudDial.timeStyleIndex = 1;
//    cloudDial.version = 1;
//    cloudDial.hidden = NO;
//    
//    NSLog(@"准备推送自定义表盘: %@", cloudDial.dialName);
//    NSLog(@"沙盒文件路径: %@", cloudDial.filePath);
//    
//    // 推送自定义表盘
//    [[[TopStepComKit sharedInstance] dial] pushCustomDial:cloudDial progressBlock:^(TSDialPushResult result, NSInteger progress) {
//        NSLog(@"推送进度: %ld%%", (long)progress);
//    } completion:^(TSDialPushResult result, NSError * _Nullable error) {
//        if (result == eTSDialPushResultCompleted) {
//            NSLog(@"自定义表盘推送成功");
//            [self showAlertWithTitle:@"成功" message:@"自定义表盘推送成功"];
//        } else {
//            NSLog(@"自定义表盘推送失败: %@", error);
//            [self showAlertWithTitle:@"失败" message:[NSString stringWithFormat:@"自定义表盘推送失败: %@", error.localizedDescription]];
//        }
//
//    }];
}

/**
 * 显示确认对话框
 */
- (void)showConfirmAlertWithTitle:(NSString *)title
                         message:(NSString *)message
                  confirmHandler:(void(^)(void))confirmHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        if (confirmHandler) {
            confirmHandler();
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 显示提示对话框
 */
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)getCurrentDial {
    [[[TopStepComKit sharedInstance] dial] fetchCurrentDial:^(TSDialModel * _Nullable dial, NSError * _Nullable error) {
        
    }];
}

- (void)getAllDials {
    [[[TopStepComKit sharedInstance] dial] fetchAllDials:^(NSArray<TSDialModel *> * _Nonnull dials, NSError * _Nullable error) {
        
    }];
}

- (void)pushCloudDial{
    TSDialModel *cloudDial = [TSDialModel new];
    cloudDial.filePath = @"";
    [[[TopStepComKit sharedInstance] dial] installDownloadedCloudDial:cloudDial progressBlock:^(TSDialPushResult result, NSInteger progress) {
        
    } completion:^(TSDialPushResult result, NSError * _Nullable error) {
        
    }];
}
- (void)pushCustomerDial{
    
    TSCustomDial *customeDial = [TSCustomDial new];

    [[[TopStepComKit sharedInstance] dial] installCustomDial:customeDial progressBlock:^(TSDialPushResult result, NSInteger progress) {
        
    } completion:^(TSDialPushResult result, NSError * _Nullable error) {
        
    }];
}

- (void)deleteCloudDial{
//    [[[TopStepComKit sharedInstance] dial] deleteDial:cloudDial.dialId completion:^(BOOL success, NSError * _Nullable error) {
//
//    }];
}

- (void)deleteCustomDial{
    
//    TSFitDialModel *customeDial = [TSFitDialModel new];
//    [[[TopStepComKit sharedInstance] dial] dele]
//    [[[TopStepComKit sharedInstance] dial] deleteDial:customeDial.dialId completion:^(BOOL success, NSError * _Nullable error) {
//
//    }];
}

- (void)getRemainSpace{
    
    [[[TopStepComKit sharedInstance] dial] fetchAllDials:^(NSArray<TSDialModel *> * _Nullable dials, NSError * _Nullable error) {
        
    }];
}

- (void)switchDial{
    
//    TSFitDialModel *dial = [TSFitDialModel new];

//    [[[TopStepComKit sharedInstance] dial] switchToDial:dial.dialId completion:^(BOOL success, NSError * _Nullable error) {
//        
//    }];
}

- (void)reuqestAIDialParam{
//    [TSFitDialModel requestAIParamCompletion:^(NSDictionary * _Nonnull param, NSError * _Nonnull error) {
//        TSLog(@"param is %@",param);
//    }];
}

@end
