//
//  TSDialVideoRecordVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/6.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDialVideoRecordVC.h"
#import <AVFoundation/AVFoundation.h>

// 布局常量
static const CGFloat kRecordBtnSize = 80.f;  // 录制按钮尺寸
static const CGFloat kRecordBtnBottom = 60.f; // 录制按钮距底部

@interface TSDialVideoRecordVC ()

@property (nonatomic, assign) NSInteger maxDuration;
@property (nonatomic, assign) NSTimeInterval recordingStartTime;
@property (nonatomic, assign) NSTimeInterval currentDuration;
@property (nonatomic, assign) BOOL isRecording;

// AVFoundation
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSURL *outputURL;

// UI
@property (nonatomic, strong) UIView *previewContainer;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIView *recordBtnInner;
@property (nonatomic, strong) NSTimer *updateTimer;

// 录制完成预览
@property (nonatomic, strong) UIView *previewOverlay;
@property (nonatomic, strong) UIButton *retakeBtn;
@property (nonatomic, strong) UIButton *useVideoBtn;

@end

@implementation TSDialVideoRecordVC

#pragma mark - 初始化

- (instancetype)initWithMaxDuration:(NSInteger)maxDuration {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _maxDuration = (maxDuration > 0) ? maxDuration : 15;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    [self setupViews];
    [self setupCamera];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    if (self.captureSession && !self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self stopRecording];
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
}

- (void)dealloc {
    if (self.updateTimer) {
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
}

#pragma mark - 视图构建

- (void)setupViews {
    // 预览容器
    self.previewContainer = [[UIView alloc] init];
    self.previewContainer.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.previewContainer];

    // 取消按钮
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelBtn setTitle:@"✕" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightLight];
    [self.cancelBtn addTarget:self action:@selector(onCancelTapped)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelBtn];

    // 计时器标签
    self.timerLabel = [[UILabel alloc] init];
    self.timerLabel.text = [NSString stringWithFormat:@"00:00 / 00:%02ld", (long)self.maxDuration];
    self.timerLabel.font = [UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightMedium];
    self.timerLabel.textColor = UIColor.whiteColor;
    self.timerLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:self.timerLabel];

    // 录制按钮
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recordBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3f];
    self.recordBtn.layer.cornerRadius = kRecordBtnSize / 2.f;
    self.recordBtn.layer.borderWidth = 4.f;
    self.recordBtn.layer.borderColor = UIColor.whiteColor.CGColor;
    [self.recordBtn addTarget:self action:@selector(onRecordBtnTapped)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordBtn];

    // 录制按钮内部圆点
    self.recordBtnInner = [[UIView alloc] init];
    self.recordBtnInner.backgroundColor = [UIColor colorWithRed:1 green:0.23f blue:0.19f alpha:1];
    self.recordBtnInner.layer.cornerRadius = 32.f;
    self.recordBtnInner.userInteractionEnabled = NO;
    [self.recordBtn addSubview:self.recordBtnInner];
}

- (void)layoutViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat safeTop = self.view.safeAreaInsets.top;
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;

    // 预览容器填满屏幕
    self.previewContainer.frame = self.view.bounds;
    self.previewLayer.frame = self.previewContainer.bounds;

    // 取消按钮（左上角）
    self.cancelBtn.frame = CGRectMake(16, safeTop + 8, 44, 44);

    // 计时器（右上角）
    self.timerLabel.frame = CGRectMake(w - 140, safeTop + 8, 124, 44);

    // 录制按钮（底部居中）
    CGFloat recordBtnY = h - kRecordBtnBottom - kRecordBtnSize - safeBottom;
    self.recordBtn.frame = CGRectMake((w - kRecordBtnSize) / 2.f, recordBtnY,
                                      kRecordBtnSize, kRecordBtnSize);

    // 录制按钮内部圆点
    CGFloat innerSize = 64.f;
    self.recordBtnInner.frame = CGRectMake((kRecordBtnSize - innerSize) / 2.f,
                                           (kRecordBtnSize - innerSize) / 2.f,
                                           innerSize, innerSize);

    // 预览覆盖层
    if (self.previewOverlay) {
        self.previewOverlay.frame = self.view.bounds;
        CGFloat btnW = 100.f;
        CGFloat btnH = 44.f;
        CGFloat btnY = h - safeBottom - 60 - btnH;
        self.retakeBtn.frame = CGRectMake(40, btnY, btnW, btnH);
        self.useVideoBtn.frame = CGRectMake(w - 40 - btnW, btnY, btnW, btnH);
    }
}

#pragma mark - 相机设置

- (void)setupCamera {
    // 检查相机权限
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    if (status == AVAuthorizationStatusNotDetermined) {
        // 首次使用，请求权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self setupCameraSession];
                } else {
                    [self showAlertWithMsg:@"需要相机权限才能录制视频"];
                }
            });
        }];
        return;
    }

    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showAlertWithMsg:@"请在「设置」中允许访问相机"];
        return;
    }

    // 已授权，直接设置
    [self setupCameraSession];
}

- (void)setupCameraSession {
    // 创建会话
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;

    // 视频输入
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
    if (error || !self.videoInput) {
        [self showAlertWithMsg:@"无法访问相机"];
        return;
    }
    if ([self.captureSession canAddInput:self.videoInput]) {
        [self.captureSession addInput:self.videoInput];
    }

    // 音频输入
    AVCaptureDevice *microphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    if (microphone) {
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:microphone error:nil];
        if (audioInput && [self.captureSession canAddInput:audioInput]) {
            [self.captureSession addInput:audioInput];
        }
    }

    // 视频输出
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.captureSession canAddOutput:self.movieOutput]) {
        [self.captureSession addOutput:self.movieOutput];
    }

    // 预览层
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewContainer.layer addSublayer:self.previewLayer];

    // 启动会话
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession startRunning];
    });
}

#pragma mark - 录制控制

- (void)onRecordBtnTapped {
    if (self.isRecording) {
        [self stopRecording];
    } else {
        [self startRecording];
    }
}

- (void)startRecording {
    // 生成输出文件路径
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                            [NSString stringWithFormat:@"dial_video_%@.mov",
                             @((NSInteger)[[NSDate date] timeIntervalSince1970])]];
    self.outputURL = [NSURL fileURLWithPath:outputPath];

    // 删除旧文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    }

    // 开始录制
    [self.movieOutput startRecordingToOutputFileURL:self.outputURL recordingDelegate:self];

    self.isRecording = YES;
    self.recordingStartTime = [NSDate timeIntervalSinceReferenceDate];
    self.currentDuration = 0;

    // 启动计时器
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                        target:self
                                                      selector:@selector(onTimerUpdate)
                                                      userInfo:nil
                                                       repeats:YES];

    // 录制按钮动画
    [UIView animateWithDuration:0.2 animations:^{
        self.recordBtnInner.layer.cornerRadius = 8.f;
        self.recordBtnInner.transform = CGAffineTransformMakeScale(0.6, 0.6);
    }];

    // 开始脉动动画
    [self startPulseAnimation];
}

- (void)stopRecording {
    if (!self.isRecording) return;

    // 先停止并清理 timer，避免悬空指针
    if (self.updateTimer && [self.updateTimer isValid]) {
        [self.updateTimer invalidate];
    }
    self.updateTimer = nil;

    // 停止录制
    if (self.movieOutput && self.movieOutput.isRecording) {
        [self.movieOutput stopRecording];
    }

    self.isRecording = NO;

    // 停止脉动动画
    [self.recordBtnInner.layer removeAllAnimations];

    // 恢复按钮状态
    [UIView animateWithDuration:0.2 animations:^{
        self.recordBtnInner.layer.cornerRadius = 32.f;
        self.recordBtnInner.transform = CGAffineTransformIdentity;
    }];
}

- (void)onTimerUpdate {
    self.currentDuration = [NSDate timeIntervalSinceReferenceDate] - self.recordingStartTime;

    NSInteger current = (NSInteger)self.currentDuration;
    NSInteger max = self.maxDuration;

    self.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld",
                            (long)(current / 60), (long)(current % 60),
                            (long)(max / 60), (long)(max % 60)];

    // 达到最大时长自动停止
    if (self.currentDuration >= self.maxDuration) {
        [self stopRecording];
    }
}

- (void)startPulseAnimation {
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulse.fromValue = @1.0;
    pulse.toValue = @0.3;
    pulse.duration = 0.8;
    pulse.autoreverses = YES;
    pulse.repeatCount = HUGE_VALF;
    [self.recordBtnInner.layer addAnimation:pulse forKey:@"pulse"];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)output
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray<AVCaptureConnection *> *)connections
                error:(nullable NSError *)error {

    if (error) {
        NSLog(@"录制错误: %@", error);
        [self showAlertWithMsg:@"录制失败，请重试"];
        return;
    }

    // 显示预览界面
    [self showPreviewOverlay];
}

#pragma mark - 预览界面

- (void)showPreviewOverlay {
    self.previewOverlay = [[UIView alloc] initWithFrame:self.view.bounds];
    self.previewOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    [self.view addSubview:self.previewOverlay];

    self.retakeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.retakeBtn setTitle:@"重拍" forState:UIControlStateNormal];
    [self.retakeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.retakeBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    self.retakeBtn.backgroundColor = [UIColor colorWithWhite:0.3f alpha:1];
    self.retakeBtn.layer.cornerRadius = 8.f;
    [self.retakeBtn addTarget:self action:@selector(onRetakeTapped)
             forControlEvents:UIControlEventTouchUpInside];
    [self.previewOverlay addSubview:self.retakeBtn];

    self.useVideoBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.useVideoBtn setTitle:@"使用视频" forState:UIControlStateNormal];
    [self.useVideoBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.useVideoBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.useVideoBtn.backgroundColor = [UIColor colorWithRed:0 green:0.48f blue:1 alpha:1];
    self.useVideoBtn.layer.cornerRadius = 8.f;
    [self.useVideoBtn addTarget:self action:@selector(onUseVideoTapped)
               forControlEvents:UIControlEventTouchUpInside];
    [self.previewOverlay addSubview:self.useVideoBtn];

    [self layoutViews];
}

- (void)onRetakeTapped {
    [self.previewOverlay removeFromSuperview];
    self.previewOverlay = nil;

    // 删除录制的文件
    if (self.outputURL) {
        [[NSFileManager defaultManager] removeItemAtURL:self.outputURL error:nil];
        self.outputURL = nil;
    }

    // 重置计时器
    self.currentDuration = 0;
    self.timerLabel.text = [NSString stringWithFormat:@"00:00 / 00:%02ld", (long)self.maxDuration];
}

- (void)onUseVideoTapped {
    if (self.onRecordComplete && self.outputURL) {
        self.onRecordComplete(self.outputURL);
    }
}

#pragma mark - 按钮事件

- (void)onCancelTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 辅助方法

- (void)showAlertWithMsg:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
