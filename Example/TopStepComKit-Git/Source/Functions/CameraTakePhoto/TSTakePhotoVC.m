//
//  TSTakePhotoVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/12.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSTakePhotoVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <AudioToolbox/AudioToolbox.h>

// 底部控制区高度（不含 safeArea）
static const CGFloat kBottomBarH     = 100.f;
// 拍照按钮外圆直径
static const CGFloat kShutterOuter   = 70.f;
// 拍照按钮内圆直径
static const CGFloat kShutterInner   = 58.f;
// 缩略图尺寸
static const CGFloat kThumbSize      = 60.f;
// 顶部按钮区高度
static const CGFloat kTopBarH        = 44.f;

@interface TSTakePhotoVC () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate>

// 摄像头会话
@property (nonatomic, strong) AVCaptureSession              *captureSession;
// 全屏预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *previewLayer;
// 视频帧输出（推流用）
@property (nonatomic, strong) AVCaptureVideoDataOutput      *videoOutput;
// 拍照输出
@property (nonatomic, strong) AVCapturePhotoOutput          *photoOutput;
// 当前摄像头输入
@property (nonatomic, strong) AVCaptureDeviceInput          *currentDeviceInput;
// 推流串行队列
@property (nonatomic, strong) dispatch_queue_t               captureQueue;

// 是否后置摄像头
@property (nonatomic, assign) BOOL isBackCamera;
// 当前闪光模式
@property (nonatomic, assign) AVCaptureFlashMode currentFlashMode;
// 是否支持视频预览推流
@property (nonatomic, assign) BOOL isVideoPreviewSupported;
// 是否正在推流
@property (nonatomic, assign) BOOL isStreaming;

// 顶部返回按钮
@property (nonatomic, strong) UIButton  *backButton;
// 顶部闪光灯按钮
@property (nonatomic, strong) UIButton  *flashButton;
// 底部控制区背景
@property (nonatomic, strong) UIView    *bottomBar;
// 拍照按钮外圆
@property (nonatomic, strong) UIButton  *shutterButton;
// 切换摄像头按钮
@property (nonatomic, strong) UIButton  *switchCameraButton;
// 缩略图
@property (nonatomic, strong) UIImageView *thumbnailView;
// 快门闪白遮罩
@property (nonatomic, strong) UIView    *flashOverlay;

@end

@implementation TSTakePhotoVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self requestCameraPermission];
    [self registerDeviceCallback];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    if (self.captureSession && !self.captureSession.isRunning) {
        dispatch_async(self.captureQueue, ^{
            [self.captureSession startRunning];
        });
    }
    if (self.isTriggeredByDevice) {
        // 设备已主动进入相机，直接按需开启推流
        if (self.isVideoPreviewSupported) {
            [self startVideoStreaming];
        }
    } else {
        [self enterCameraMode];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self exitCameraMode];
    dispatch_async(self.captureQueue, ^{
        [self.captureSession stopRunning];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)dealloc {
    TSLogInfo(@"[Camera] TSTakePhotoVC dealloc");
}

#pragma mark - 公开方法

#pragma mark - 私有方法

/**
 * 请求相机权限
 */
- (void)requestCameraPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        [self setupCaptureSession];
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self setupCaptureSession];
                } else {
                    [self showPermissionDeniedAlert];
                }
            });
        }];
    } else {
        [self showPermissionDeniedAlert];
    }
}

/**
 * 初始化 AVCaptureSession 及预览层
 */
- (void)setupCaptureSession {
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.currentDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!self.currentDeviceInput) {
        TSLogError(@"[Camera] 摄像头输入初始化失败: %@", error.localizedDescription);
        return;
    }

    if ([self.captureSession canAddInput:self.currentDeviceInput]) {
        [self.captureSession addInput:self.currentDeviceInput];
    }

    // 视频帧输出（推流）
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [self.videoOutput setSampleBufferDelegate:self queue:self.captureQueue];
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }

    // 拍照输出
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.captureSession canAddOutput:self.photoOutput]) {
        [self.captureSession addOutput:self.photoOutput];
    }

    // 预览层
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];

    // 启动
    dispatch_async(self.captureQueue, ^{
        [self.captureSession startRunning];
    });

    self.isBackCamera = YES;
    self.currentFlashMode = AVCaptureFlashModeOff;
    self.isVideoPreviewSupported = [[[TopStepComKit sharedInstance] camera] isSupportVideoPreview];

    [self setupViews];
}

/**
 * 构建所有 UI 子视图
 */
- (void)setupViews {
    [self.view addSubview:self.flashOverlay];
    [self.view addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.shutterButton];
    [self.bottomBar addSubview:self.switchCameraButton];
    [self.bottomBar addSubview:self.thumbnailView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.flashButton];
}

/**
 * Frame 布局
 */
- (void)layoutViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    CGFloat safeTop    = self.view.safeAreaInsets.top;
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;

    // 预览层全屏
    self.previewLayer.frame = self.view.bounds;

    // 快门遮罩全屏
    self.flashOverlay.frame = self.view.bounds;

    // 顶部按钮
    CGFloat topBarY = safeTop;
    self.backButton.frame  = CGRectMake(12.f, topBarY, kTopBarH, kTopBarH);
    self.flashButton.frame = CGRectMake(w - kTopBarH - 12.f, topBarY, kTopBarH, kTopBarH);

    // 底部控制区
    CGFloat bottomBarH = kBottomBarH + safeBottom;
    self.bottomBar.frame = CGRectMake(0, h - bottomBarH, w, bottomBarH);

    // 拍照按钮居中
    CGFloat shutterY = (kBottomBarH - kShutterOuter) / 2.f;
    self.shutterButton.frame = CGRectMake((w - kShutterOuter) / 2.f, shutterY, kShutterOuter, kShutterOuter);
    self.shutterButton.layer.cornerRadius = kShutterOuter / 2.f;

    // 切换摄像头按钮（右侧，与缩略图对称）
    CGFloat switchSize = 44.f;
    CGFloat switchX = w - 16.f - kThumbSize / 2.f - switchSize / 2.f;
    self.switchCameraButton.frame = CGRectMake(switchX, (kBottomBarH - switchSize) / 2.f, switchSize, switchSize);

    // 缩略图（左侧）
    CGFloat thumbX = 16.f;
    CGFloat thumbY = (kBottomBarH - kThumbSize) / 2.f;
    self.thumbnailView.frame = CGRectMake(thumbX, thumbY, kThumbSize, kThumbSize);
}

/**
 * 进入相机模式，成功后按需开启推流
 */
- (void)enterCameraMode {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] camera] controlCameraWithAction:TSCameraActionEnterCamera completion:^(BOOL isSuccess, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                TSLogInfo(@"[Camera] 进入相机模式成功");
                if (weakSelf.isVideoPreviewSupported) {
                    [weakSelf startVideoStreaming];
                }
            } else {
                TSLogError(@"[Camera] 进入相机模式失败: %@", error.localizedDescription);
            }
        });
    }];
}

/**
 * 退出相机模式，先停推流再发退出指令
 */
- (void)exitCameraMode {
    __weak typeof(self) weakSelf = self;
    if (self.isStreaming) {
        [[[TopStepComKit sharedInstance] camera] stopVideoPreviewCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
            weakSelf.isStreaming = NO;
            TSLogInfo(@"[Camera] 停止推流");
        }];
    }
    [[[TopStepComKit sharedInstance] camera] controlCameraWithAction:TSCameraActionExitCamera completion:^(BOOL isSuccess, NSError * _Nullable error) {
        TSLogInfo(@"[Camera] 退出相机模式");
    }];
}

/**
 * 开始视频推流
 */
- (void)startVideoStreaming {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] camera] startVideoPreviewWithFps:30 completion:^(BOOL isSuccess, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                weakSelf.isStreaming = YES;
                TSLogInfo(@"[Camera] 视频推流已开始");
            } else {
                TSLogError(@"[Camera] 视频推流启动失败: %@", error.localizedDescription);
                [weakSelf showStreamingFailedAlert];
            }
        });
    }];
}

/**
 * 拍照并保存到相册
 */
- (void)takePhoto {
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    settings.flashMode = self.currentFlashMode;
    [self.photoOutput capturePhotoWithSettings:settings delegate:self];
}

/**
 * 切换前/后置摄像头
 */
- (void)switchCamera {
    AVCaptureDevicePosition targetPosition = self.isBackCamera
        ? AVCaptureDevicePositionFront
        : AVCaptureDevicePositionBack;

    AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession
        discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                              mediaType:AVMediaTypeVideo
                               position:targetPosition];
    AVCaptureDevice *newDevice = session.devices.firstObject;
    if (!newDevice) return;

    NSError *error = nil;
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:&error];
    if (!newInput) return;

    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.currentDeviceInput];
    if ([self.captureSession canAddInput:newInput]) {
        [self.captureSession addInput:newInput];
        self.currentDeviceInput = newInput;
        self.isBackCamera = !self.isBackCamera;
    } else {
        [self.captureSession addInput:self.currentDeviceInput];
    }
    [self.captureSession commitConfiguration];
}

/**
 * 设置闪光模式并更新按钮图标
 */
- (void)applyFlashMode:(AVCaptureFlashMode)mode {
    self.currentFlashMode = mode;
    NSString *icon = @"bolt.slash.fill";
    if (mode == AVCaptureFlashModeOn)   icon = @"bolt.fill";
    if (mode == AVCaptureFlashModeAuto) icon = @"bolt.badge.a.fill";
    if (@available(iOS 13.0, *)) {
        [self.flashButton setImage:[UIImage systemImageNamed:icon] forState:UIControlStateNormal];
    }
}

/**
 * 注册设备相机事件回调
 */
- (void)registerDeviceCallback {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] camera] registerAppCameraeControledByDevice:^(TSCameraAction action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleDeviceAction:action];
        });
    }];
}

/**
 * 处理设备触发的相机动作
 */
- (void)handleDeviceAction:(TSCameraAction)action {
    switch (action) {
        case TSCameraActionTakePhoto:
            TSLogInfo(@"[Camera] 设备触发拍照");
            [self takePhoto];
            break;
        case TSCameraActionSwitchBackCamera:
            TSLogInfo(@"[Camera] 设备切换后置");
            if (!self.isBackCamera) [self switchCamera];
            break;
        case TSCameraActionSwitchFrontCamera:
            TSLogInfo(@"[Camera] 设备切换前置");
            if (self.isBackCamera) [self switchCamera];
            break;
        case TSCameraActionFlashOff:
            TSLogInfo(@"[Camera] 设备关闭闪光");
            [self applyFlashMode:AVCaptureFlashModeOff];
            break;
        case TSCameraActionFlashAuto:
            TSLogInfo(@"[Camera] 设备设置闪光自动");
            [self applyFlashMode:AVCaptureFlashModeAuto];
            break;
        case TSCameraActionFlashOn:
            TSLogInfo(@"[Camera] 设备开启闪光");
            [self applyFlashMode:AVCaptureFlashModeOn];
            break;
        default:
            break;
    }
}

/**
 * 播放快门动画（全屏闪白 + 音效）
 */
- (void)playShutterAnimation {
    self.flashOverlay.alpha = 1.f;
    [UIView animateWithDuration:0.15 animations:^{
        self.flashOverlay.alpha = 0.f;
    }];
    AudioServicesPlaySystemSound(1108);
}

/**
 * 更新左下角缩略图，带飞入动画
 */
- (void)updateThumbnailWithImage:(UIImage *)image {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);

    // 起始位置：屏幕右下角（模拟从预览区飞入）
    CGRect startFrame = CGRectMake(w - 20.f, h - 20.f, 10.f, 10.f);
    CGRect endFrame   = self.thumbnailView.frame;

    self.thumbnailView.image  = image;
    self.thumbnailView.frame  = startFrame;
    self.thumbnailView.alpha  = 0.f;

    [UIView animateWithDuration:0.35
                          delay:0
         usingSpringWithDamping:0.75f
          initialSpringVelocity:0.5f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.thumbnailView.frame = endFrame;
        self.thumbnailView.alpha = 1.f;
    } completion:nil];
}

/**
 * 保存图片到相册
 */
- (void)saveImageToAlbum:(UIImage *)image {
    PHAuthorizationStatus status;
    if (@available(iOS 14.0, *)) {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly];
    } else {
        status = [PHPhotoLibrary authorizationStatus];
    }

    if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
        [self doSaveImage:image];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        __weak typeof(self) weakSelf = self;
        if (@available(iOS 14.0, *)) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus st) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (st == PHAuthorizationStatusAuthorized || st == PHAuthorizationStatusLimited) {
                        [weakSelf doSaveImage:image];
                    }
                });
            }];
        } else {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus st) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (st == PHAuthorizationStatusAuthorized) {
                        [weakSelf doSaveImage:image];
                    }
                });
            }];
        }
    } else {
        [self showAlbumPermissionDeniedAlert];
    }
}

/**
 * 执行保存图片
 */
- (void)doSaveImage:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    UIImageWriteToSavedPhotosAlbum(image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        TSLogError(@"[Camera] 保存相册失败: %@", error.localizedDescription);
    } else {
        TSLogInfo(@"[Camera] 照片已保存到相册");
    }
}

/**
 * 相机权限被拒 Alert
 */
- (void)showPermissionDeniedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"需要相机权限"
                                                                   message:@"请前往设置开启相机权限"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *a) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 相册权限被拒 Alert
 */
- (void)showAlbumPermissionDeniedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"需要相册权限"
                                                                   message:@"请前往设置开启相册权限"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 推流失败 Alert
 */
- (void)showStreamingFailedAlert {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"视频预览失败"
                                                                   message:@"视频预览启动失败，是否重试？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
        [weakSelf startVideoStreaming];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 按钮事件

- (void)onBackTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onFlashTapped {
    AVCaptureFlashMode next;
    switch (self.currentFlashMode) {
        case AVCaptureFlashModeOff:  next = AVCaptureFlashModeAuto; break;
        case AVCaptureFlashModeAuto: next = AVCaptureFlashModeOn;   break;
        default:                     next = AVCaptureFlashModeOff;  break;
    }
    [self applyFlashMode:next];
}

- (void)onShutterTapped {
    [self takePhoto];
}

- (void)onSwitchCameraTapped {
    [self switchCamera];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (!self.isStreaming) return;
    [[[TopStepComKit sharedInstance] camera] sendVideoPreviewSampleBuffer:sampleBuffer isBack:self.isBackCamera];
}

#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output
didFinishProcessingPhoto:(AVCapturePhoto *)photo
                error:(NSError *)error API_AVAILABLE(ios(11.0)) {
    if (error) {
        TSLogError(@"[Camera] 拍照失败: %@", error.localizedDescription);
        return;
    }
    NSData *data = [photo fileDataRepresentation];
    UIImage *image = [UIImage imageWithData:data];
    if (!image) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self playShutterAnimation];
        [self updateThumbnailWithImage:image];
        [self saveImageToAlbum:image];
    });
}

#pragma mark - 属性（懒加载）

- (dispatch_queue_t)captureQueue {
    if (!_captureQueue) {
        _captureQueue = dispatch_queue_create("com.topstep.camera.capture", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        if (@available(iOS 13.0, *)) {
            UIImage *icon = [UIImage systemImageNamed:@"chevron.left"];
            [_backButton setImage:icon forState:UIControlStateNormal];
        } else {
            [_backButton setTitle:@"‹" forState:UIControlStateNormal];
            _backButton.titleLabel.font = [UIFont systemFontOfSize:28.f weight:UIFontWeightLight];
        }
        _backButton.tintColor = [UIColor whiteColor];
        [_backButton addTarget:self action:@selector(onBackTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)flashButton {
    if (!_flashButton) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
        if (@available(iOS 13.0, *)) {
            [_flashButton setImage:[UIImage systemImageNamed:@"bolt.slash.fill"] forState:UIControlStateNormal];
        } else {
            [_flashButton setTitle:@"⚡" forState:UIControlStateNormal];
        }
        _flashButton.tintColor = [UIColor whiteColor];
        [_flashButton addTarget:self action:@selector(onFlashTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashButton;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    }
    return _bottomBar;
}

- (UIButton *)shutterButton {
    if (!_shutterButton) {
        _shutterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shutterButton.backgroundColor = [UIColor whiteColor];
        _shutterButton.layer.cornerRadius = kShutterOuter / 2.f;
        _shutterButton.layer.borderWidth  = (kShutterOuter - kShutterInner) / 2.f;
        _shutterButton.layer.borderColor  = [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor;
        _shutterButton.clipsToBounds = YES;
        [_shutterButton addTarget:self action:@selector(onShutterTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shutterButton;
}

- (UIButton *)switchCameraButton {
    if (!_switchCameraButton) {
        _switchCameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
        if (@available(iOS 13.0, *)) {
            [_switchCameraButton setImage:[UIImage systemImageNamed:@"camera.rotate.fill"] forState:UIControlStateNormal];
        } else {
            [_switchCameraButton setTitle:@"⇄" forState:UIControlStateNormal];
            _switchCameraButton.titleLabel.font = [UIFont systemFontOfSize:22.f];
        }
        _switchCameraButton.tintColor = [UIColor whiteColor];
        [_switchCameraButton addTarget:self action:@selector(onSwitchCameraTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraButton;
}

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[UIImageView alloc] init];
        _thumbnailView.contentMode        = UIViewContentModeScaleAspectFill;
        _thumbnailView.clipsToBounds      = YES;
        _thumbnailView.layer.cornerRadius = 8.f;
        _thumbnailView.layer.borderWidth  = 2.f;
        _thumbnailView.layer.borderColor  = [UIColor whiteColor].CGColor;
        _thumbnailView.backgroundColor    = [[UIColor whiteColor] colorWithAlphaComponent:0.1f];
        _thumbnailView.alpha              = 0.f;
    }
    return _thumbnailView;
}

- (UIView *)flashOverlay {
    if (!_flashOverlay) {
        _flashOverlay = [[UIView alloc] init];
        _flashOverlay.backgroundColor = [UIColor whiteColor];
        _flashOverlay.alpha = 0.f;
        _flashOverlay.userInteractionEnabled = NO;
    }
    return _flashOverlay;
}

@end
