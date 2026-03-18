//
//  TSMakeCustomDialVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSMakeCustomDialVC.h"
#import "TSDialImageCropVC.h"
#import "TSDialVideoEditVC.h"
#import "TSDialEditorVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface TSMakeCustomDialVC () <UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate>

/** 设备表盘尺寸（像素） */
@property (nonatomic, assign) CGSize  dialSize;
/** 表盘高宽比（高/宽） */
@property (nonatomic, assign) CGFloat dialAspectRatio;
/** 是否支持视频表盘 */
@property (nonatomic, assign) BOOL    supportsVideo;
/** 视频表盘最大时长（秒） */
@property (nonatomic, assign) NSInteger maxVideoDuration;
/** 防止 ActionSheet 重复弹出 */
@property (nonatomic, assign) BOOL hasShownSheet;

@end

@implementation TSMakeCustomDialVC

#pragma mark - 生命周期

/** 初始化数据与设备能力 */
- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"dial.make_custom_title");
    [self loadDeviceCapabilities];
}

/** 在视图出现时弹出来源选择 ActionSheet（只弹一次） */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.hasShownSheet) {
        self.hasShownSheet = YES;
        [self showSourceActionSheet];
    }
}

#pragma mark - 设备能力加载

/** 从已连接设备读取表盘尺寸与功能支持 */
- (void)loadDeviceCapabilities {
    TSPeripheral *peri = [[TopStepComKit sharedInstance] connectedPeripheral];
    CGSize s = peri.screenInfo.screenSize;
    NSLog(@"[TSMakeCustomDialVC] SDK 返回的 screenSize: %.0f × %.0f", s.width, s.height);

    if (CGSizeEqualToSize(s, CGSizeZero)) {
        s = CGSizeMake(240, 280);   // 兜底默认尺寸
    }
    self.dialSize        = s;
    self.dialAspectRatio = s.height / s.width;

    id<TSPeripheralDialInterface> dialInterface = [[TopStepComKit sharedInstance] dial];
    self.supportsVideo    = [dialInterface isSupportVideoDial];
    self.maxVideoDuration = [dialInterface maxVideoDialDuration];
    if (self.maxVideoDuration <= 0) {
        self.maxVideoDuration = 10;
    }
}

#pragma mark - ActionSheet

/** 弹出来源选择 ActionSheet */
- (void)showSourceActionSheet {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:nil
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];

    if (self.supportsVideo) {
        [alert addAction:[UIAlertAction
            actionWithTitle:TSLocalizedString(@"dial.push_video")
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *a) { [self pickVideo]; }]];
    }

    [alert addAction:[UIAlertAction
        actionWithTitle:TSLocalizedString(@"dial.take_photo")
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *a) { [self pickFromCamera]; }]];

    [alert addAction:[UIAlertAction
        actionWithTitle:TSLocalizedString(@"dial.choose_album")
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *a) { [self pickFromLibrary]; }]];

    [alert addAction:[UIAlertAction
        actionWithTitle:TSLocalizedString(@"general.cancel")
                  style:UIAlertActionStyleCancel
                handler:^(UIAlertAction *a) {
                    [self.navigationController popViewControllerAnimated:YES];
                }]];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 图片/视频选取

/** 打开相机拍照 */
- (void)pickFromCamera {
    AVAuthorizationStatus status =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied ||
        status == AVAuthorizationStatusRestricted) {
        [self showAlertWithMsg:TSLocalizedString(@"dial.camera_permission")];
        return;
    }
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showAlertWithMsg:TSLocalizedString(@"camera.not_supported")];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType  = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes  = @[(NSString *)kUTTypeImage];
    picker.delegate    = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/** 从相册选取图片 */
- (void)pickFromLibrary {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.delegate   = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/** 从相册选取视频 */
- (void)pickVideo {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType           = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes           = @[(NSString *)kUTTypeMovie];
    picker.videoMaximumDuration = (NSTimeInterval)self.maxVideoDuration;
    picker.videoQuality         = UIImagePickerControllerQualityTypeHigh;
    picker.delegate             = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

/** 用户选取完图片或视频后的回调 */
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            if (image) [self pushImageCropVCWithImage:image];
        } else {
            NSURL *url = info[UIImagePickerControllerMediaURL];
            if (url)   [self pushVideoEditVCWithURL:url];
        }
    }];
}

/** 用户取消选取 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 导航至裁剪/编辑页

/** 跳转图片裁剪页 */
- (void)pushImageCropVCWithImage:(UIImage *)image {
    TSDialImageCropVC *vc =
        [[TSDialImageCropVC alloc] initWithImage:image aspectRatio:self.dialAspectRatio];
    __weak typeof(self) wself = self;
    vc.onCropComplete = ^(UIImage *croppedImage) {
        TSDialEditorVC *editorVC =
            [[TSDialEditorVC alloc] initWithImage:croppedImage dialSize:wself.dialSize];
        editorVC.onPushSuccess = wself.onPushSuccess;
        // 用 editor 替换 crop VC，避免 push+pop 同步触发动画冲突
        NSMutableArray *vcs = [wself.navigationController.viewControllers mutableCopy];
        if (vcs.count > 0) [vcs removeLastObject];
        [vcs addObject:editorVC];
        [wself.navigationController setViewControllers:vcs animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

/** 跳转视频编辑页 */
- (void)pushVideoEditVCWithURL:(NSURL *)url {
    TSDialVideoEditVC *vc =
        [[TSDialVideoEditVC alloc] initWithVideoURL:url
                                           dialSize:self.dialSize
                                        maxDuration:self.maxVideoDuration];
    __weak typeof(self) wself = self;
    vc.onEditComplete = ^(NSURL *processedURL) {
        TSDialEditorVC *editorVC =
            [[TSDialEditorVC alloc] initWithVideoURL:processedURL dialSize:wself.dialSize];
        editorVC.onPushSuccess = wself.onPushSuccess;
        [wself.navigationController pushViewController:editorVC animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

@end
