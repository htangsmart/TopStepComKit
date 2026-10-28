//
//  TSTakePhotoVC.m
//  TopStepComKit_Example
//

#import "TSTakePhotoVC.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreVideo/CoreVideo.h>
#import <ImageIO/ImageIO.h>
#import <Photos/Photos.h>
#import <float.h>
#import <math.h>

#import <TopStepComKit/TopStepComKit.h>
#import <TopStepToolKit/TopStepToolKit.h>

#import "TSDeviceCoordinator.h"
#import "UIViewController+TSToast.h"

// 采集、文件收尾与保存属于不同状态，禁止在停止回调前重配会话。
typedef NS_ENUM(NSInteger, TSCameraCapturePhase) {
    TSCameraCapturePhaseIdle,
    TSCameraCapturePhaseConfiguring,
    TSCameraCapturePhasePreparingRecording,
    TSCameraCapturePhaseRecording,
    TSCameraCapturePhaseStopping,
    TSCameraCapturePhaseSaving,
    TSCameraCapturePhaseSaveFailed,
};

// Demo 相机模块错误域与错误码，不与其他模块混用。
static NSErrorDomain const TSDemoCameraErrorDomain = @"TSDemoCameraErrorDomain";
static void *TSCameraMediaPreviewStatusContext = &TSCameraMediaPreviewStatusContext;
typedef NS_ENUM(NSInteger, TSDemoCameraErrorCode) {
    TSDemoCameraErrorCaptureConfiguration = 3201,
};

@interface TSTakePhotoVC () <AVCaptureVideoDataOutputSampleBufferDelegate,
    AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate>

// 采集设备与配置只在串行队列上修改。
@property (nonatomic, strong) AVCaptureSession *captureSession;
// 手机取景层。
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
// 当前视频输入。
@property (nonatomic, strong) AVCaptureDeviceInput *currentDeviceInput;
// 有权限且可用时添加的麦克风输入。
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
// 送给 SDK 的预览帧输出。
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
// 拍照模式输出。
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
// 真实录像文件输出。
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
// 串行采集队列。
@property (nonatomic, strong) dispatch_queue_t captureQueue;
// 固定当前连接的公开门面，异步回调不发送到之后连接的另一台设备。
@property (atomic, strong) id<TSCameraInterface> cameraService;
// 当前设备成功连接代次。
@property (nonatomic, assign) NSUInteger connectionGeneration;
// 过滤旧预览回调的代次。
@property (nonatomic, assign) NSUInteger previewGeneration;
// 过滤旧采集配置回调的代次。
@property (nonatomic, assign) NSUInteger configurationGeneration;
// 主线程拍摄和保存状态。
@property (nonatomic, assign) TSCameraCapturePhase phase;
// 当前相机授权状态。
@property (nonatomic, assign) BOOL cameraAuthorized;
// 采集会话是否已运行。
@property (nonatomic, assign) BOOL sessionReady;
// 拍摄页是否仍在当前导航栈中活动。
@property (nonatomic, assign) BOOL pageVisible;
// 设备业务会话是否就绪。
@property (nonatomic, assign) BOOL deviceReady;
// 当前设备是否已进入相机。
@property (nonatomic, assign) BOOL deviceEntered;
// 进入指令是否正在等待结果。
@property (nonatomic, assign) BOOL enterInFlight;
// 仅用于录像入口的固件能力。
@property (nonatomic, assign) BOOL videoModeSupported;
// 独立的手表预览能力。
@property (nonatomic, assign) BOOL previewSupported;
// 预览启动是否正在等待结果。
@property (nonatomic, assign) BOOL previewStarting;
// SDK 停流是否尚未完成。
@property (nonatomic, assign) BOOL previewStopping;
// 排队等待停流完成的配置与关闭操作。
@property (nonatomic, strong) NSMutableArray *previewStopCompletions;
// 可重试的预览启动失败状态。
@property (nonatomic, assign) BOOL previewFailed;
// 实际帧输出是否可用，旧系统录像模式不得假装持续推流。
@property (atomic, assign) BOOL previewFramesAvailable;
// 采集输出是否已选中 SDK 能处理的未压缩 8-bit YUV 格式。
@property (atomic, assign) BOOL previewPixelFormatSupported;
// 采集队列读取的送帧开关。
@property (atomic, assign) BOOL streaming;
// 前台与中断状态决定是否允许运行采集。
@property (atomic, assign) BOOL captureAllowed;
// 当前是否为后置镜头。
@property (atomic, assign) BOOL backCamera;
// 当前已成功配置的拍摄模式。
@property (nonatomic, assign) BOOL videoMode;
// 当前录像是否不含麦克风音轨。
@property (nonatomic, assign) BOOL silentRecording;
// 当前录像输出绑定时的麦克风授权状态，用于判断是否必须重绑音轨。
@property (nonatomic, assign) BOOL configuredAudioAuthorized;
// 麦克风授权弹窗是否仍未返回。
@property (nonatomic, assign) BOOL microphoneRequestPending;
// 输出配置完成后是否仍需开始录制。
@property (nonatomic, assign) BOOL pendingStartRecording;
// 开始请求是否来自设备。
@property (nonatomic, assign) BOOL pendingStartFromDevice;
// 开始请求所属连接代次。
@property (nonatomic, assign) NSUInteger recordingRequestGeneration;
// 开始请求所属公开门面。
@property (nonatomic, strong) id<TSCameraInterface> recordingRequestService;
// 当前真实录制是否由设备发起。
@property (nonatomic, assign) BOOL recordingFromDevice;
// 当前录制所属连接代次。
@property (nonatomic, assign) NSUInteger recordingConnectionGeneration;
// 当前录制所属公开门面。
@property (nonatomic, strong) id<TSCameraInterface> recordingOriginService;
// didStart 到达前排队的停止请求。
@property (nonatomic, assign) BOOL recordingStopRequested;
// 排队停止请求的来源。
@property (nonatomic, assign) BOOL stopFromDevice;
// 当前是否有待执行的关闭请求。
@property (nonatomic, assign) BOOL closeRequested;
// 关闭请求是否来自设备。
@property (nonatomic, assign) BOOL closeFromDevice;
// 关闭流程所属连接，旧停流回调不退出后连接的设备。
@property (nonatomic, assign) NSUInteger closeOriginGeneration;
// 关闭流程所属公开门面。
@property (nonatomic, strong) id<TSCameraInterface> closeOriginService;
// 停流退出流程是否已经开始。
@property (nonatomic, assign) BOOL closing;
// 文件收尾后是否需要回拍照模式。
@property (nonatomic, assign) BOOL returnToPhoto;
// 进入拍摄页前的系统返回手势状态。
@property (nonatomic, assign) BOOL previousPopGestureEnabled;
// 当前拍照闪光设置。
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
// 当前录像补光设置。
@property (nonatomic, assign) BOOL torchEnabled;
// 当前镜头显示倍率最小值。
@property (nonatomic, assign) CGFloat minimumZoomRatio;
// 当前镜头显示倍率最大值。
@property (nonatomic, assign) CGFloat maximumZoomRatio;
// 设置成功后的实际显示倍率。
@property (nonatomic, assign) CGFloat currentZoomRatio;
// 系统显示倍率与设备原始 factor 的映射系数。
@property (nonatomic, assign) CGFloat zoomDisplayMultiplier;
// 是否已读取有效硬件范围。
@property (nonatomic, assign) BOOL zoomRangeValid;
// 本次配置或连接是否还有待发送的范围。
@property (nonatomic, assign) BOOL zoomRangePending;
// 页面是否被导航父级从外部移除。
@property (nonatomic, assign) BOOL externallyRemoved;
// 真实采集委托完成前保留页面；终态立即解除，外部移除也能完成文件收尾。
@property (nonatomic, strong) TSTakePhotoVC *mediaOperationRetainer;
// 当前配置是否支持对应的闪光或补光。
@property (nonatomic, assign) BOOL flashAvailable;
// 单调时钟记录的实际开始时间。
@property (nonatomic, assign) NSTimeInterval recordingStartedAt;
// 文件收尾期间使用的有限后台任务。
@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundTask;
// 失败作品存于 Application Support，退出和重启都不删除。
@property (nonatomic, strong) NSURL *pendingMediaURL;
// 磁盘写入失败时保留原始照片数据供重试。
@property (nonatomic, copy) NSData *pendingPhotoData;
// 最近作品的原始文件或已保存缓存文件。
@property (nonatomic, strong) NSURL *recentMediaURL;
// 最近作品是否已经过相册成功回调。
@property (nonatomic, assign) BOOL recentMediaSaved;
// 拍照结果是否仍需通知原设备。
@property (nonatomic, assign) BOOL pendingPhotoNotification;
// 拍照结果所属连接代次。
@property (nonatomic, assign) NSUInteger photoNotificationGeneration;
// 拍照结果所属公开门面。
@property (nonatomic, strong) id<TSCameraInterface> photoOriginService;
// 最近真实作品的缩略图。
@property (nonatomic, strong) UIImage *recentThumbnail;
// 主队列与采集队列共享，作品预览期间暂停拍摄和设备动作。
@property (atomic, assign) BOOL mediaPreviewPresented;
// 两个队列用控制器身份排除旧的暂停和呈现回调。
@property (atomic, strong) UIViewController *mediaPreviewController;
// 播放失败的两类通知只处理一次，旧关闭完成不能影响下一作品。
@property (nonatomic, assign) BOOL mediaPreviewFailureHandling;
@property (nonatomic, assign) NSUInteger mediaPreviewGeneration;
// 当前作品播放器与被观察的播放项。
@property (nonatomic, strong) AVPlayer *mediaPreviewPlayer;
@property (nonatomic, strong) AVPlayerItem *mediaPreviewItem;
// 播放项状态监听是否已经登记。
@property (nonatomic, assign) BOOL mediaPreviewItemObserved;
// 临时播放音频前的应用音频配置。
@property (nonatomic, copy) NSString *mediaPreviewAudioCategory;
@property (nonatomic, copy) NSString *mediaPreviewAudioMode;
@property (nonatomic, assign) AVAudioSessionCategoryOptions mediaPreviewAudioOptions;
@property (nonatomic, assign) BOOL mediaPreviewAudioConfigured;
// 文件移动前后使用唯一文件名识别同一作品。
@property (nonatomic, copy) NSString *thumbnailMediaIdentifier;
// 隔离旧作品或旧路径的异步缩略图结果。
@property (nonatomic, assign) NSUInteger thumbnailGeneration;
// 仅用于刷新录制时间的定时器。
@property (nonatomic, strong) NSTimer *recordTimer;
// 拍摄界面沿用黑底与底部快门，新增独立能力入口。
@property (nonatomic, strong) UIButton *backButton;
// 拍照闪光或录像补光菜单。
@property (nonatomic, strong) UIButton *flashButton;
// 预览状态与启动失败重试入口。
@property (nonatomic, strong) UIButton *previewButton;
// 相机页面标题。
@property (nonatomic, strong) UILabel *titleLabel;
// 当前拍摄或保存状态。
@property (nonatomic, strong) UILabel *statusLabel;
// 录制时间显示。
@property (nonatomic, strong) UILabel *timerLabel;
// 当前实际倍率和镜头说明。
@property (nonatomic, strong) UILabel *zoomValueLabel;
// 无声录像提示。
@property (nonatomic, strong) UILabel *silentLabel;
// 底部操作区域。
@property (nonatomic, strong) UIView *bottomBar;
// Min、常用数字档和 Max 按钮。
@property (nonatomic, strong) UIStackView *zoomButtons;
// 受录像能力控制的拍照和录像切换。
@property (nonatomic, strong) UISegmentedControl *modeControl;
// 拍照或开始停止录像的主按钮。
@property (nonatomic, strong) UIButton *shutterButton;
// 白色拍照圆形或红色录制形状。
@property (nonatomic, strong) UIView *shutterCore;
// 前后镜头切换按钮。
@property (nonatomic, strong) UIButton *switchCameraButton;
// 最近作品与保留文件入口。
@property (nonatomic, strong) UIButton *thumbnailButton;
// 原色展示照片或视频封面，铺满作品按钮。
@property (nonatomic, strong) UIImageView *thumbnailImageView;
// 视频封面的播放标识。
@property (nonatomic, strong) UILabel *thumbnailVideoBadge;
// 拍照成功闪白效果。
@property (nonatomic, strong) UIView *flashOverlay;
// 相机权限被拒后的设置入口。
@property (nonatomic, strong) UIButton *permissionButton;
// 相册保存失败重试入口。
@property (nonatomic, strong) UIButton *retrySaveButton;
// 保留文件并继续或退出入口。
@property (nonatomic, strong) UIButton *keepMediaButton;

@end

@implementation TSTakePhotoVC

#pragma mark - 生命周期

// 尚未加载界面的实例也具有有效的后台任务初值。
- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundTask = UIBackgroundTaskInvalid;
    }
    return self;
}

// 先构建界面并监听协调器，再申请权限，设备动作不会覆盖首页监听。
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    self.backCamera = YES;
    self.flashMode = AVCaptureFlashModeOff;
    self.zoomDisplayMultiplier = 1;
    self.minimumZoomRatio = 1;
    self.maximumZoomRatio = 1;
    self.currentZoomRatio = 1;
    self.backgroundTask = UIBackgroundTaskInvalid;
    [self setupViews];
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(deviceActionReceived:)
                   name:TSDemoCameraActionDidReceiveNotification object:TSDeviceCoordinator.sharedInstance];
    [center addObserver:self selector:@selector(connectionChanged:)
                   name:TSDeviceConnectionSnapshotDidChangeNotification object:TSDeviceCoordinator.sharedInstance];
    [center addObserver:self selector:@selector(appWillResignActive:)
                   name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(appDidBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(captureWasInterrupted:)
                   name:AVCaptureSessionWasInterruptedNotification object:nil];
    [center addObserver:self selector:@selector(captureInterruptionEnded:)
                   name:AVCaptureSessionInterruptionEndedNotification object:nil];
    [self applyConnectionSnapshot:TSDeviceCoordinator.sharedInstance.snapshot];
    self.deviceEntered = self.isTriggeredByDevice && self.deviceReady;
    [self restoreRecentMedia];
    [self requestCameraPermission];
}

// 进入页面后满足授权、采集与设备条件才通知进入和启动推流。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL firstAppearance = !self.pageVisible;
    self.pageVisible = YES;
    self.captureAllowed = !self.mediaPreviewPresented &&
        UIApplication.sharedApplication.applicationState == UIApplicationStateActive;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    if (firstAppearance) {
        self.previousPopGestureEnabled = self.navigationController.interactivePopGestureRecognizer.enabled;
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self resumeCaptureIfPossible];
}

// 系统视频播放器关闭后也从此恢复，避免依赖其内部关闭按钮的实现。
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.mediaPreviewPresented) {
        [self finishMediaPreview];
    }
}

// 全屏作品预览不会退出相机；真实退出由关闭流程完成文件收尾。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController || self.navigationController.isBeingDismissed) {
        if (!self.closing) {
            self.externallyRemoved = YES;
            [self requestCloseFromDevice:NO];
            if (self.phase == TSCameraCapturePhaseSaveFailed && self.pendingMediaURL) {
                [self onKeepMediaTapped];
            }
        }
        self.pageVisible = NO;
        self.captureAllowed = NO;
        [self stopPreviewWithCompletion:nil];
        [self.navigationController setNavigationBarHidden:NO animated:animated];
        self.navigationController.interactivePopGestureRecognizer.enabled = self.previousPopGestureEnabled;
    }
}

// 全部布局根据当前安全区更新，窄屏仍保留五个倍率按钮。
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

// 页面不拥有 SDK 监听，只取消自身通知、定时器和采集输出。
- (void)dealloc {
    [self cleanupMediaPreview];
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self.recordTimer invalidate];
    AVCaptureSession *session = self.captureSession;
    [self.videoOutput setSampleBufferDelegate:nil queue:NULL];
    if (_captureQueue && session) {
        dispatch_async(_captureQueue, ^{ [session stopRunning]; });
    }
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [UIApplication.sharedApplication endBackgroundTask:self.backgroundTask];
    }
}

#pragma mark - 私有方法

// 创建有可访问名称的文本按钮。
- (UIButton *)buttonWithTitle:(NSString *)title selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.tintColor = UIColor.whiteColor;
    button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

// 构建批准的相机布局，变焦只提供直接设置按钮。
- (void)setupViews {
    self.backButton = [self buttonWithTitle:@"关闭" selector:@selector(onBackTapped)];
    self.flashButton = [self buttonWithTitle:@"闪光关" selector:@selector(onFlashTapped)];
    self.previewButton = [self buttonWithTitle:@"手表预览准备中" selector:@selector(onPreviewTapped)];
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"遥控相机";
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.bottomBar = [[UIView alloc] init];
    self.bottomBar.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.88];
    self.zoomButtons = [[UIStackView alloc] init];
    self.zoomButtons.axis = UILayoutConstraintAxisHorizontal;
    self.zoomButtons.distribution = UIStackViewDistributionFillEqually;
    self.zoomButtons.spacing = 8;
    self.modeControl = [[UISegmentedControl alloc] initWithItems:@[@"拍照", @"录像"]];
    self.modeControl.backgroundColor = UIColor.clearColor;
    if (@available(iOS 13.0, *)) {
        self.modeControl.selectedSegmentTintColor = UIColor.clearColor;
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.modeControl setBackgroundImage:transparentImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.modeControl setBackgroundImage:transparentImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.modeControl setDividerImage:transparentImage forLeftSegmentState:UIControlStateNormal
                   rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.modeControl setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.grayColor}
                                  forState:UIControlStateNormal];
    [self.modeControl setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColor.yellowColor}
                                  forState:UIControlStateSelected];
    [self.modeControl addTarget:self action:@selector(onModeChanged) forControlEvents:UIControlEventValueChanged];
    self.shutterButton = [self buttonWithTitle:@"" selector:@selector(onShutterTapped)];
    self.shutterButton.layer.cornerRadius = 36;
    self.shutterButton.layer.borderWidth = 3;
    self.shutterButton.layer.borderColor = UIColor.whiteColor.CGColor;
    self.shutterCore = [[UIView alloc] init];
    self.shutterCore.userInteractionEnabled = NO;
    [self.shutterButton addSubview:self.shutterCore];
    self.switchCameraButton = [self buttonWithTitle:@"翻转" selector:@selector(onSwitchCameraTapped)];
    [self applyIcon:@"xmark" toButton:self.backButton fallback:@"关闭相机"];
    [self applyIcon:@"arrow.triangle.2.circlepath" toButton:self.switchCameraButton fallback:@"切换前后镜头"];
    self.thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.thumbnailButton setTitle:@"作品" forState:UIControlStateNormal];
    [self.thumbnailButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.thumbnailButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [self.thumbnailButton addTarget:self action:@selector(onThumbnailTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    self.thumbnailButton.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.1];
    self.thumbnailButton.clipsToBounds = YES;
    self.thumbnailButton.layer.cornerRadius = 8;
    self.thumbnailImageView = [[UIImageView alloc] init];
    self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailImageView.userInteractionEnabled = NO;
    [self.thumbnailButton addSubview:self.thumbnailImageView];
    self.thumbnailVideoBadge = [[UILabel alloc] init];
    self.thumbnailVideoBadge.text = @"▶";
    self.thumbnailVideoBadge.textColor = UIColor.whiteColor;
    self.thumbnailVideoBadge.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
    self.thumbnailVideoBadge.font = [UIFont systemFontOfSize:10];
    self.thumbnailVideoBadge.textAlignment = NSTextAlignmentCenter;
    self.thumbnailVideoBadge.layer.cornerRadius = 3;
    self.thumbnailVideoBadge.clipsToBounds = YES;
    self.thumbnailVideoBadge.hidden = YES;
    [self.thumbnailButton addSubview:self.thumbnailVideoBadge];
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.textColor = UIColor.lightGrayColor;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.numberOfLines = 2;
    self.zoomValueLabel = [[UILabel alloc] init];
    self.zoomValueLabel.textColor = UIColor.yellowColor;
    self.zoomValueLabel.textAlignment = NSTextAlignmentCenter;
    self.zoomValueLabel.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.timerLabel = [[UILabel alloc] init];
    self.timerLabel.textColor = UIColor.redColor;
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.timerLabel.font = [UIFont monospacedDigitSystemFontOfSize:18 weight:UIFontWeightSemibold];
    self.silentLabel = [[UILabel alloc] init];
    self.silentLabel.text = @"无声录像";
    self.silentLabel.textColor = UIColor.yellowColor;
    self.silentLabel.font = [UIFont systemFontOfSize:12];
    self.permissionButton = [self buttonWithTitle:@"需要相机权限 · 前往设置" selector:@selector(onPermissionTapped)];
    self.retrySaveButton = [self buttonWithTitle:@"重试保存" selector:@selector(onRetrySaveTapped)];
    self.keepMediaButton = [self buttonWithTitle:@"保留，稍后保存" selector:@selector(onKeepMediaTapped)];
    self.flashOverlay = [[UIView alloc] init];
    self.flashOverlay.backgroundColor = UIColor.whiteColor;
    self.flashOverlay.alpha = 0;
    self.flashOverlay.userInteractionEnabled = NO;
    for (UIView *view in @[self.bottomBar, self.backButton, self.titleLabel, self.flashButton,
        self.previewButton, self.timerLabel, self.silentLabel, self.permissionButton, self.flashOverlay]) {
        [self.view addSubview:view];
    }
    for (UIView *view in @[self.zoomButtons, self.zoomValueLabel, self.modeControl, self.shutterButton,
        self.switchCameraButton, self.thumbnailButton, self.statusLabel, self.retrySaveButton, self.keepMediaButton]) {
        [self.bottomBar addSubview:view];
    }
    [self refreshUI];
}

// 取景保持全屏，控制区固定在安全区上方。
- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat top = self.view.safeAreaInsets.top;
    CGFloat bottom = self.view.safeAreaInsets.bottom;
    self.previewLayer.frame = self.view.bounds;
    self.flashOverlay.frame = self.view.bounds;
    self.backButton.frame = CGRectMake(8, top, 56, 44);
    self.flashButton.frame = CGRectMake(width - 88, top, 80, 44);
    self.titleLabel.frame = CGRectMake(72, top, width - 160, 44);
    self.previewButton.frame = CGRectMake(16, top + 46, width - 32, 40);
    self.timerLabel.frame = CGRectMake(60, top + 92, width - 120, 32);
    self.silentLabel.frame = CGRectMake(width - 92, top + 90, 80, 32);
    self.permissionButton.frame = CGRectMake(20, MAX(top + 130, (height - 280) / 2), width - 40, 50);
    self.bottomBar.frame = CGRectMake(0, height - 240 - bottom, width, 240 + bottom);
    self.zoomButtons.frame = CGRectMake(20, 8, width - 40, 44);
    self.zoomValueLabel.frame = CGRectMake(20, 52, width - 40, 20);
    self.modeControl.frame = CGRectMake((width - 170) / 2, 77, 170, 32);
    self.retrySaveButton.frame = CGRectMake(16, 73, (width - 40) / 2, 44);
    self.keepMediaButton.frame = CGRectMake(width / 2 + 4, 73, (width - 40) / 2, 44);
    self.shutterButton.frame = CGRectMake((width - 72) / 2, 124, 72, 72);
    BOOL recording = self.phase == TSCameraCapturePhaseRecording;
    self.shutterCore.frame = recording ? CGRectMake(22, 22, 28, 28) : CGRectMake(7, 7, 58, 58);
    self.shutterCore.layer.cornerRadius = recording ? 7 : 29;
    self.thumbnailButton.frame = CGRectMake(25, 134, 52, 52);
    self.thumbnailImageView.frame = self.thumbnailButton.bounds;
    self.thumbnailVideoBadge.frame = CGRectMake(32, 34, 18, 16);
    self.switchCameraButton.frame = CGRectMake(width - 81, 134, 56, 52);
    self.statusLabel.frame = CGRectMake(12, 201, width - 24, 36);
}

// 文件收尾与保存期间不能开始另一次拍摄或重配相机。
- (BOOL)isCaptureBusy {
    return self.phase != TSCameraCapturePhaseIdle && self.phase != TSCameraCapturePhaseRecording;
}

// 更新能力、互斥状态和保存结果，录像与预览分别判断。
- (void)refreshUI {
    BOOL recording = self.phase == TSCameraCapturePhaseRecording;
    BOOL failed = self.phase == TSCameraCapturePhaseSaveFailed;
    BOOL ready = self.cameraAuthorized && self.sessionReady && !self.closing && ![self isCaptureBusy];
    self.modeControl.hidden = !self.videoModeSupported || failed;
    self.modeControl.selectedSegmentIndex = self.videoMode ? 1 : 0;
    self.modeControl.enabled = ready && !recording;
    self.shutterButton.enabled = ready;
    self.shutterButton.alpha = ready ? 1 : 0.4;
    self.shutterButton.accessibilityLabel = recording ? @"停止录像" : self.videoMode ? @"开始录像" : @"拍照";
    self.shutterCore.backgroundColor = self.videoMode ? UIColor.redColor : UIColor.whiteColor;
    self.switchCameraButton.enabled = ready && !recording;
    self.flashButton.hidden = !self.flashAvailable;
    self.flashButton.enabled = ready;
    NSString *flashTitle = self.videoMode ? (self.torchEnabled ? @"补光开" : @"补光关") :
        self.flashMode == AVCaptureFlashModeAuto ? @"闪光自动" :
        self.flashMode == AVCaptureFlashModeOn ? @"闪光开" : @"闪光关";
    [self.flashButton setTitle:flashTitle forState:UIControlStateNormal];
    NSString *flashIcon = self.videoMode ? (self.torchEnabled ? @"bolt.fill" : @"bolt.slash.fill") :
        self.flashMode == AVCaptureFlashModeAuto ? @"bolt.badge.a.fill" :
        self.flashMode == AVCaptureFlashModeOn ? @"bolt.fill" : @"bolt.slash.fill";
    [self applyIcon:flashIcon toButton:self.flashButton fallback:flashTitle];
    self.previewButton.hidden = !self.previewSupported;
    NSString *previewTitle = !self.deviceReady ? @"手表已断连" : self.previewFailed ? @"预览失败 · 点此重试" :
        self.sessionReady && !self.previewPixelFormatSupported ? @"当前输出格式不支持预览 · 手机可拍摄" :
        self.videoMode && !self.previewFramesAvailable ? @"此系统录像时暂停预览 · 切回拍照恢复" :
        self.streaming ? @"● 预览已启动 · 正在发送" : self.previewStarting ? @"正在启动手表预览" : @"手表预览已暂停";
    [self.previewButton setTitle:previewTitle forState:UIControlStateNormal];
    self.previewButton.enabled = self.previewFailed && self.deviceReady;
    self.permissionButton.hidden = self.cameraAuthorized;
    self.timerLabel.hidden = !recording;
    self.silentLabel.hidden = !self.videoMode || !self.silentRecording;
    self.retrySaveButton.hidden = !failed;
    self.keepMediaButton.hidden = !failed;
    self.thumbnailButton.enabled = self.recentMediaURL != nil && !self.mediaPreviewPresented &&
        (![self isCaptureBusy] || failed) && !recording;
    self.thumbnailImageView.image = self.recentThumbnail;
    self.thumbnailImageView.hidden = self.recentThumbnail == nil;
    BOOL recentVideo = [self.recentMediaURL.pathExtension.lowercaseString isEqualToString:@"mov"];
    self.thumbnailVideoBadge.hidden = self.recentThumbnail == nil || !recentVideo;
    [self.thumbnailButton setTitle:self.recentThumbnail ? @"" : @"作品" forState:UIControlStateNormal];
    self.thumbnailButton.accessibilityLabel = self.recentMediaURL ?
        [NSString stringWithFormat:@"最近%@，%@，打开预览", recentVideo ? @"视频" : @"照片",
         self.recentMediaSaved ? @"已保存到相册" : @"尚未保存到相册"] : @"作品";
    self.zoomValueLabel.text = [NSString stringWithFormat:@"%.1f× · %@", self.currentZoomRatio,
                               self.backCamera ? @"后置" : @"前置"];
    self.statusLabel.text = failed ? @"保存失败，原始文件已保留" :
        self.phase == TSCameraCapturePhaseSaving ? @"正在保存到相册…" :
        self.phase == TSCameraCapturePhaseStopping ? @"正在完成视频文件…" :
        self.phase == TSCameraCapturePhasePreparingRecording ? @"正在准备录像…" :
        self.phase == TSCameraCapturePhaseConfiguring ? @"正在配置相机…" :
        recording ? @"轻点停止，结束并保存录像" :
        !self.deviceReady ? @"设备已断连，仍可在手机上拍照" :
        self.videoMode ? @"轻点开始，或在手表上开始录像" : @"轻点快门，或在手表上拍照";
    [self rebuildZoomButtons];
    [self.view setNeedsLayout];
}

// 系统图标保持批准的相机操作布局，旧系统使用可读文字。
- (void)applyIcon:(NSString *)name toButton:(UIButton *)button fallback:(NSString *)fallback {
    button.accessibilityLabel = fallback;
    if (@available(iOS 13.0, *)) {
        UIImage *image = [UIImage systemImageNamed:name];
        [button setImage:image forState:UIControlStateNormal];
        [button setTitle:image ? @"" : fallback forState:UIControlStateNormal];
    }
}

// Min/Max 保持独立标签；边界与数字重合时优先高亮数字档。
- (void)rebuildZoomButtons {
    for (UIView *view in self.zoomButtons.arrangedSubviews) {
        [self.zoomButtons removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    BOOL fixed = fabs(self.maximumZoomRatio - self.minimumZoomRatio) < 0.001;
    NSArray<NSNumber *> *actions = fixed ? @[@(TSCameraActionZoomRatioOneX)] :
        @[@(TSCameraActionZoomRatioMinimum), @(TSCameraActionZoomRatioOneX),
          @(TSCameraActionZoomRatioTwoX), @(TSCameraActionZoomRatioThreeX), @(TSCameraActionZoomRatioMaximum)];
    BOOL commonSelected = NO;
    for (NSNumber *ratio in @[@1, @2, @3]) {
        commonSelected |= ratio.doubleValue >= self.minimumZoomRatio && ratio.doubleValue <= self.maximumZoomRatio &&
            fabs(ratio.doubleValue - self.currentZoomRatio) < 0.02;
    }
    for (NSNumber *actionNumber in actions) {
        TSCameraAction action = actionNumber.integerValue;
        CGFloat ratio = [self zoomRatioForAction:action];
        BOOL boundary = action == TSCameraActionZoomRatioMinimum || action == TSCameraActionZoomRatioMaximum;
        if (!fixed && !boundary && (ratio < self.minimumZoomRatio || ratio > self.maximumZoomRatio)) {
            continue;
        }
        UIButton *button = [self buttonWithTitle:fixed ? [NSString stringWithFormat:@"%.1f×", self.currentZoomRatio] :
            action == TSCameraActionZoomRatioMinimum ? @"Min" : action == TSCameraActionZoomRatioMaximum ? @"Max" :
            [NSString stringWithFormat:@"%.0f×", ratio] selector:@selector(onZoomTapped:)];
        button.tag = action;
        button.accessibilityLabel = [NSString stringWithFormat:@"%@ %.1f×", boundary ?
            (action == TSCameraActionZoomRatioMinimum ? @"最小倍率" : @"最大倍率") : @"变焦", ratio];
        BOOL selected = fabs(ratio - self.currentZoomRatio) < 0.02 && (!boundary || !commonSelected);
        [button setTitleColor:selected ? UIColor.yellowColor : UIColor.whiteColor forState:UIControlStateNormal];
        button.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:selected ? 0.2 : 0.08];
        button.layer.cornerRadius = 22;
        button.enabled = !fixed && self.cameraAuthorized && self.sessionReady && ![self isCaptureBusy];
        [self.zoomButtons addArrangedSubview:button];
    }
}

// 未授权时不创建会话，也不向手表启动预览。
- (void)requestCameraPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        __weak typeof(self) weakSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.cameraAuthorized = granted;
                [weakSelf resumeCaptureIfPossible];
                [weakSelf refreshUI];
            });
        }];
        return;
    }
    self.cameraAuthorized = status == AVAuthorizationStatusAuthorized;
    [self resumeCaptureIfPossible];
    [self refreshUI];
}

// 优先虚拟后置镜头，旧系统使用广角；显示倍率按设备的实际映射计算。
- (AVCaptureDevice *)captureDeviceForPosition:(AVCaptureDevicePosition)position {
    NSMutableArray<AVCaptureDeviceType> *types = [NSMutableArray array];
    if (position == AVCaptureDevicePositionBack) {
        if (@available(iOS 13.0, *)) {
            [types addObjectsFromArray:@[AVCaptureDeviceTypeBuiltInTripleCamera,
                                         AVCaptureDeviceTypeBuiltInDualWideCamera]];
        }
        [types addObject:AVCaptureDeviceTypeBuiltInDualCamera];
    }
    [types addObject:AVCaptureDeviceTypeBuiltInWideAngleCamera];
    for (AVCaptureDeviceType type in types) {
        AVCaptureDeviceDiscoverySession *discovery = [AVCaptureDeviceDiscoverySession
            discoverySessionWithDeviceTypes:@[type] mediaType:AVMediaTypeVideo position:position];
        if (discovery.devices.firstObject) {
            return discovery.devices.firstObject;
        }
    }
    return nil;
}

// 返回 Demo 模块自己的采集错误，不掩盖硬件配置失败。
- (NSError *)captureErrorWithDescription:(NSString *)description {
    return [NSError errorWithDomain:TSDemoCameraErrorDomain code:TSDemoCameraErrorCaptureConfiguration
                          userInfo:@{NSLocalizedDescriptionKey: description}];
}

// 串行配置真实采集输出；失败恢复上一次输入输出，成功才更新界面和同步范围。
- (void)configureVideoMode:(BOOL)video position:(AVCaptureDevicePosition)position
              fromDevice:(BOOL)fromDevice completion:(void (^)(BOOL))completion {
    if ([self isCaptureBusy] || self.phase == TSCameraCapturePhaseRecording) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    BOOL preserveSettings = self.captureSession != nil && self.videoMode == video &&
        self.backCamera == (position == AVCaptureDevicePositionBack);
    CGFloat requestedRatio = preserveSettings ? self.currentZoomRatio : 1;
    BOOL requestedTorch = preserveSettings && video && self.torchEnabled;
    self.phase = TSCameraCapturePhaseConfiguring;
    self.sessionReady = NO;
    self.previewFramesAvailable = NO;
    self.previewFailed = NO;
    NSUInteger generation = ++self.configurationGeneration;
    NSUInteger originGeneration = self.connectionGeneration;
    id<TSCameraInterface> originService = self.cameraService;
    BOOL shouldRun = self.pageVisible && UIApplication.sharedApplication.applicationState == UIApplicationStateActive;
    [self refreshUI];
    __weak typeof(self) weakSelf = self;
    [self stopPreviewWithCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        dispatch_async(strongSelf.captureQueue, ^{
            AVCaptureDevice *device = [strongSelf captureDeviceForPosition:position];
            NSError *error = nil;
            AVCaptureDeviceInput *input = device ? [AVCaptureDeviceInput deviceInputWithDevice:device error:&error] : nil;
            if (!input && !error) {
                error = [strongSelf captureErrorWithDescription:@"当前手机没有可用的目标摄像头"];
            }
            if (!strongSelf.captureSession) {
                strongSelf.captureSession = [[AVCaptureSession alloc] init];
                strongSelf.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
                strongSelf.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
                strongSelf.videoOutput.alwaysDiscardsLateVideoFrames = YES;
                [strongSelf.videoOutput setSampleBufferDelegate:strongSelf queue:strongSelf.captureQueue];
                strongSelf.photoOutput = [[AVCapturePhotoOutput alloc] init];
                strongSelf.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
            }
            AVCaptureSession *session = strongSelf.captureSession;
            NSArray<AVCaptureInput *> *previousInputs = session.inputs;
            NSArray<AVCaptureOutput *> *previousOutputs = session.outputs;
            [session beginConfiguration];
            for (AVCaptureInput *previous in previousInputs) {
                [session removeInput:previous];
            }
            for (AVCaptureOutput *previous in previousOutputs) {
                [session removeOutput:previous];
            }
            if (!error && [session canAddInput:input]) {
                [session addInput:input];
            } else if (!error) {
                error = [strongSelf captureErrorWithDescription:@"相机会话无法添加目标镜头"];
            }
            AVCaptureOutput *captureOutput = video ? (AVCaptureOutput *)strongSelf.movieOutput : strongSelf.photoOutput;
            if (!error && [session canAddOutput:strongSelf.videoOutput]) {
                [session addOutput:strongSelf.videoOutput];
            } else if (!error) {
                error = [strongSelf captureErrorWithDescription:@"相机会话无法添加预览帧输出"];
            }
            if (!error && [session canAddOutput:captureOutput]) {
                [session addOutput:captureOutput];
            } else if (!error) {
                error = [strongSelf captureErrorWithDescription:@"当前手机不支持同时取景与此拍摄配置"];
            }
            AVCaptureDeviceInput *audioInput = nil;
            BOOL audioAuthorized = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] ==
                AVAuthorizationStatusAuthorized;
            if (!error && video && audioAuthorized) {
                AVCaptureDevice *microphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
                audioInput = microphone ? [AVCaptureDeviceInput deviceInputWithDevice:microphone error:nil] : nil;
                if (audioInput && [session canAddInput:audioInput]) {
                    [session addInput:audioInput];
                } else {
                    audioInput = nil;
                }
            }
            if (error) {
                for (AVCaptureInput *added in session.inputs) {
                    [session removeInput:added];
                }
                for (AVCaptureOutput *added in session.outputs) {
                    [session removeOutput:added];
                }
                for (AVCaptureInput *previous in previousInputs) {
                    if ([session canAddInput:previous]) {
                        [session addInput:previous];
                    }
                }
                for (AVCaptureOutput *previous in previousOutputs) {
                    if ([session canAddOutput:previous]) {
                        [session addOutput:previous];
                    }
                }
            }
            [session commitConfiguration];
            NSNumber *pixelFormat = nil;
            if (!error) {
                pixelFormat = [strongSelf preferredPreviewPixelFormatFromAvailableFormats:
                    strongSelf.videoOutput.availableVideoCVPixelFormatTypes];
                // 仅选择系统声明可用的格式，不指定宽高，保持竖屏旋转后的真实采样尺寸。
                strongSelf.videoOutput.videoSettings = pixelFormat ?
                    @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: pixelFormat} : nil;
                [strongSelf configureConnection:[strongSelf.videoOutput connectionWithMediaType:AVMediaTypeVideo]
                                      mirrored:NO];
                [strongSelf configureConnection:[captureOutput connectionWithMediaType:AVMediaTypeVideo]
                                      mirrored:position == AVCaptureDevicePositionFront];
            }
            if (shouldRun && strongSelf.captureAllowed && !session.isRunning) {
                [session startRunning];
            }
            CGFloat multiplier = 1;
            if (@available(iOS 18.0, *)) {
                multiplier = device.displayVideoZoomFactorMultiplier;
            }
            if (!isfinite(multiplier) || multiplier <= 0) {
                multiplier = 1;
            }
            CGFloat minimum = device.minAvailableVideoZoomFactor * multiplier;
            CGFloat maximum = device.maxAvailableVideoZoomFactor * multiplier;
            BOOL validRange = isfinite(minimum) && isfinite(maximum) && minimum > 0 &&
                maximum >= minimum && maximum <= FLT_MAX;
            CGFloat defaultRatio = validRange ? MIN(maximum, MAX(minimum, requestedRatio)) : 1;
            if (!error) {
                NSError *zoomError = nil;
                if ([device lockForConfiguration:&zoomError]) {
                    device.videoZoomFactor = defaultRatio / multiplier;
                    if (device.hasTorch) {
                        AVCaptureTorchMode desiredTorch = requestedTorch && device.isTorchAvailable ?
                            AVCaptureTorchModeOn : AVCaptureTorchModeOff;
                        if ([device isTorchModeSupported:desiredTorch]) {
                            device.torchMode = desiredTorch;
                        }
                    }
                    [device unlockForConfiguration];
                } else {
                    TSLogWarning(@"[Camera] 倍率或补光恢复失败: %@", zoomError.localizedDescription);
                }
            }
            BOOL running = session.isRunning && strongSelf.captureAllowed;
            BOOL frameActive = [strongSelf.videoOutput connectionWithMediaType:AVMediaTypeVideo].isActive;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (generation != strongSelf.configurationGeneration) {
                    return;
                }
                strongSelf.phase = TSCameraCapturePhaseIdle;
                if (error) {
                    strongSelf.sessionReady = running && previousInputs.count > 0;
                    [strongSelf reportError:error fallback:@"相机配置失败"];
                    strongSelf.pendingStartRecording = NO;
                } else {
                    BOOL modeChanged = strongSelf.videoMode != video;
                    BOOL lensChanged = strongSelf.backCamera != (position == AVCaptureDevicePositionBack);
                    strongSelf.currentDeviceInput = input;
                    strongSelf.audioInput = audioInput;
                    strongSelf.backCamera = position == AVCaptureDevicePositionBack;
                    strongSelf.videoMode = video;
                    strongSelf.silentRecording = video && audioInput == nil;
                    strongSelf.configuredAudioAuthorized = video && audioAuthorized;
                    strongSelf.torchEnabled = video && device.torchMode == AVCaptureTorchModeOn;
                    strongSelf.zoomDisplayMultiplier = multiplier;
                    strongSelf.minimumZoomRatio = validRange ? minimum : defaultRatio;
                    strongSelf.maximumZoomRatio = validRange ? maximum : defaultRatio;
                    strongSelf.currentZoomRatio = device.videoZoomFactor * multiplier;
                    strongSelf.zoomRangeValid = validRange;
                    strongSelf.zoomRangePending = validRange;
                    strongSelf.flashAvailable = video ? device.hasTorch : device.hasFlash;
                    strongSelf.sessionReady = running;
                    strongSelf.previewPixelFormatSupported = pixelFormat != nil;
                    strongSelf.previewFramesAvailable = pixelFormat != nil &&
                        [strongSelf canFeedPreviewInVideoMode:video connectionActive:frameActive];
                    if (!pixelFormat) {
                        TSLogWarning(@"[Camera] 当前输入无可用 8-bit NV12/I420 输出，暂停手表预览，保留手机拍摄");
                    }
                    if (!strongSelf.previewLayer) {
                        strongSelf.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
                        strongSelf.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                        [strongSelf.view.layer insertSublayer:strongSelf.previewLayer atIndex:0];
                    }
                    [strongSelf configureConnection:strongSelf.previewLayer.connection
                                           mirrored:!strongSelf.backCamera];
                    if (!fromDevice && modeChanged) {
                        [strongSelf notifyDevice:video ? TSCameraActionEnterVideoMode : TSCameraActionEnterPhotoMode
                                    originService:originService generation:originGeneration];
                    }
                    if (!fromDevice && lensChanged) {
                        [strongSelf notifyDevice:strongSelf.backCamera ? TSCameraActionSwitchBackCamera :
                         TSCameraActionSwitchFrontCamera originService:originService generation:originGeneration];
                    }
                    if (validRange) {
                        [strongSelf sendCameraRange];
                    } else {
                        TSLogWarning(@"[Camera] 当前镜头未返回有效变焦范围，不发送相机信息");
                    }
                }
                [strongSelf refreshUI];
                if (completion) {
                    completion(error == nil);
                }
                [strongSelf finishPendingTransition];
                [strongSelf ensureDeviceCameraEntered];
            });
        });
    }];
}

// 送给 SDK 的 sample 保持不镜像；本地预览与自拍保存分别处理镜像。
- (void)configureConnection:(AVCaptureConnection *)connection mirrored:(BOOL)mirrored {
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    if (connection.isVideoMirroringSupported) {
        connection.automaticallyAdjustsVideoMirroring = NO;
        connection.videoMirrored = mirrored;
    }
}

// 每次成功配置后发送一次真实范围，不能把 unsupported 日志写成同步成功。
- (void)sendCameraRange {
    if (!self.deviceReady || !self.deviceEntered || !self.sessionReady || !self.zoomRangeValid ||
        !self.zoomRangePending || !self.cameraService || self.minimumZoomRatio <= 0 ||
        !isfinite(self.minimumZoomRatio) || self.maximumZoomRatio > FLT_MAX || !isfinite(self.maximumZoomRatio)) {
        return;
    }
    float minimum = (float)self.minimumZoomRatio;
    float maximum = (float)self.maximumZoomRatio;
    if (!isfinite(minimum) || !isfinite(maximum) || minimum <= 0 || maximum < minimum) {
        return;
    }
    self.zoomRangePending = NO;
    NSUInteger generation = self.connectionGeneration;
    NSUInteger configuration = self.configurationGeneration;
    __weak typeof(self) weakSelf = self;
    [self.cameraService setCameraInfoWithMinimumZoomRatio:minimum maximumZoomRatio:maximum
                                             completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf || generation != weakSelf.connectionGeneration || !weakSelf.deviceReady ||
                configuration != weakSelf.configurationGeneration) {
                return;
            }
            if (success) {
                TSLogInfo(@"[Camera] 当前镜头范围已发送 %.3f–%.3f", minimum, maximum);
            } else {
                TSLogWarning(@"[Camera] 当前平台未同步镜头范围: %@", error.localizedDescription);
            }
        });
    }];
}

// 恢复采集与设备会话，首次异步授权不会漏启动推流。
- (void)resumeCaptureIfPossible {
    if (self.mediaPreviewPresented || !self.pageVisible || !self.cameraAuthorized || self.closing || [self isCaptureBusy] ||
        UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        return;
    }
    if (!self.captureSession) {
        [self configureVideoMode:NO position:AVCaptureDevicePositionBack fromDevice:YES completion:nil];
        return;
    }
    dispatch_async(self.captureQueue, ^{
        if (self.captureAllowed && !self.captureSession.isRunning) {
            [self.captureSession startRunning];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.sessionReady = self.captureAllowed && self.captureSession.isRunning;
            self.previewFramesAvailable = self.previewPixelFormatSupported &&
                [self canFeedPreviewInVideoMode:self.videoMode connectionActive:
                [self.videoOutput connectionWithMediaType:AVMediaTypeVideo].isActive];
            [self refreshUI];
            [self ensureDeviceCameraEntered];
        });
    });
}

// 接受连接快照时刷新独立能力，旧设备回调不会修改新会话。
- (void)applyConnectionSnapshot:(TSDeviceConnectionSnapshot *)snapshot {
    BOOL newSession = snapshot.isReady && (!self.deviceReady ||
        snapshot.connectionGeneration != self.connectionGeneration);
    if (newSession && self.deviceReady) {
        self.returnToPhoto = self.videoMode || self.pendingStartRecording;
        self.pendingStartRecording = NO;
        [self stopRecordingFromDevice:YES];
    }
    if (!snapshot.isReady || newSession) {
        [self stopPreviewWithCompletion:nil];
        self.deviceEntered = NO;
        self.enterInFlight = NO;
    }
    self.deviceReady = snapshot.isReady;
    if (newSession) {
        self.connectionGeneration = snapshot.connectionGeneration;
        self.cameraService = TopStepComKit.sharedInstance.camera;
        self.videoModeSupported = [self.cameraService isSupportVideoMode];
        self.previewSupported = [self.cameraService isSupportVideoPreview];
        self.zoomRangePending = self.zoomRangeValid;
        if (self.sessionReady) {
            [self sendCameraRange];
        }
    }
    if (!self.deviceReady) {
        self.videoModeSupported = NO;
        self.returnToPhoto = self.videoMode;
        self.pendingStartRecording = NO;
        if (self.phase == TSCameraCapturePhaseRecording || self.phase == TSCameraCapturePhasePreparingRecording) {
            [self stopRecordingFromDevice:YES];
        }
    }
    [self refreshUI];
    [self finishPendingTransition];
    [self ensureDeviceCameraEntered];
}

// 只有四项条件齐备后进入设备相机，设备已主动进入时不重复回发。
- (void)ensureDeviceCameraEntered {
    if (self.mediaPreviewPresented || !self.pageVisible || !self.cameraAuthorized || !self.sessionReady || !self.deviceReady ||
        self.closing || self.closeRequested || self.enterInFlight ||
        UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        return;
    }
    if (self.deviceEntered) {
        [self sendCameraRange];
        [self startPreviewIfPossible];
        return;
    }
    self.enterInFlight = YES;
    NSUInteger generation = self.connectionGeneration;
    __weak typeof(self) weakSelf = self;
    [self.cameraService controlCameraWithAction:TSCameraActionEnterCamera completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf.deviceReady || generation != strongSelf.connectionGeneration) {
                return;
            }
            strongSelf.enterInFlight = NO;
            strongSelf.deviceEntered = success;
            if (!success) {
                strongSelf.previewFailed = YES;
                [strongSelf reportError:error fallback:@"进入设备相机失败，可重试预览"];
            }
            [strongSelf refreshUI];
            if (success && !strongSelf.closing) {
                [strongSelf sendCameraRange];
                [strongSelf startPreviewIfPossible];
            }
        });
    }];
}

// 手表预览仅受预览能力约束，与录像模式无关。
- (void)startPreviewIfPossible {
    if (self.mediaPreviewPresented || !self.previewSupported || !self.deviceReady || !self.deviceEntered || !self.sessionReady ||
        !self.previewFramesAvailable || !self.previewPixelFormatSupported ||
        !self.pageVisible || self.closing || self.closeRequested || self.streaming || self.previewStarting ||
        self.previewStopping ||
        UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        return;
    }
    self.previewStarting = YES;
    self.previewFailed = NO;
    NSUInteger token = ++self.previewGeneration;
    NSUInteger generation = self.connectionGeneration;
    [self refreshUI];
    __weak typeof(self) weakSelf = self;
    [self.cameraService startVideoPreviewWithFps:30 completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || token != strongSelf.previewGeneration || generation != strongSelf.connectionGeneration) {
                return;
            }
            strongSelf.previewStarting = NO;
            strongSelf.streaming = success && strongSelf.pageVisible && strongSelf.deviceReady &&
                !strongSelf.closing && UIApplication.sharedApplication.applicationState == UIApplicationStateActive;
            strongSelf.previewFailed = !success;
            if (!success) {
                [strongSelf reportError:error fallback:@"手表预览失败，手机仍可拍摄"];
            }
            [strongSelf refreshUI];
        });
    }];
}

// iOS16 前 Movie 与 Data 输出不能同时活动，较新系统仍检查实际连接。
- (BOOL)canFeedPreviewInVideoMode:(BOOL)video connectionActive:(BOOL)connectionActive {
    if (!connectionActive) {
        return NO;
    }
    if (video) {
        if (@available(iOS 16.0, *)) {
            return YES;
        }
        return NO;
    }
    return YES;
}

// 优先 NV12 full/video，再退到 I420；拒绝 BGRA、10-bit 与压缩像素格式。
- (NSNumber *)preferredPreviewPixelFormatFromAvailableFormats:(NSArray<NSNumber *> *)availableFormats {
    NSArray<NSNumber *> *preferredFormats = @[@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
        @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange), @(kCVPixelFormatType_420YpCbCr8PlanarFullRange),
        @(kCVPixelFormatType_420YpCbCr8Planar)];
    for (NSNumber *format in preferredFormats) {
        if ([availableFormats containsObject:format]) {
            return format;
        }
    }
    return nil;
}

// 先停止喂帧，再等待 SDK 停流完成，调用方随后配置或退出。
- (void)stopPreviewWithCompletion:(dispatch_block_t)completion {
    BOOL needsStop = self.streaming || self.previewStarting;
    self.streaming = NO;
    self.previewStarting = NO;
    self.previewGeneration += 1;
    if (completion) {
        if (!self.previewStopCompletions) {
            self.previewStopCompletions = [NSMutableArray array];
        }
        [self.previewStopCompletions addObject:[completion copy]];
    }
    if (self.previewStopping) {
        return;
    }
    id<TSCameraInterface> source = self.cameraService;
    if (!needsStop || !source) {
        [self completePreviewStop];
        return;
    }
    self.previewStopping = YES;
    [source stopVideoPreviewCompletion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                TSLogWarning(@"[Camera] 停止预览失败: %@", error.localizedDescription);
            }
            self.previewStopping = NO;
            [self completePreviewStop];
            [self ensureDeviceCameraEntered];
        });
    }];
}

// 同一停流过程的配置和退出请求按顺序完成，避免旧 stop 回调截断新预览。
- (void)completePreviewStop {
    NSArray *completions = [self.previewStopCompletions copy];
    [self.previewStopCompletions removeAllObjects];
    for (dispatch_block_t completion in completions) {
        completion();
    }
}

// 本地动作同步只通过公开门面，平台拒绝时明确记录，不影响本地拍摄结果。
- (void)notifyDevice:(TSCameraAction)action {
    if (!self.deviceReady || !self.cameraService) {
        return;
    }
    NSUInteger generation = self.connectionGeneration;
    __weak typeof(self) weakSelf = self;
    [self.cameraService controlCameraWithAction:action completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != weakSelf.connectionGeneration || !weakSelf.deviceReady) {
                return;
            }
            if (!success) {
                TSLogWarning(@"[Camera] 本地动作 %ld 未同步: %@", (long)action, error.localizedDescription);
            }
        });
    }];
}

// 媒体异步结果只通知实际发起拍摄的连接与门面。
- (BOOL)isCurrentMediaOrigin:(id<TSCameraInterface>)source generation:(NSUInteger)generation {
    return self.deviceReady && source != nil && source == self.cameraService &&
        generation == self.connectionGeneration;
}

// 任何异步本地操作都只向原连接同步，晚回调仍可完成本地状态收尾。
- (void)notifyDevice:(TSCameraAction)action originService:(id<TSCameraInterface>)source
         generation:(NSUInteger)generation {
    if ([self isCurrentMediaOrigin:source generation:generation]) {
        [self notifyDevice:action];
    }
}

// 迟到的 didStart 不得让后来连接的设备进入录像态。
- (void)notifyRecordingStartedIfCurrent {
    if (!self.recordingFromDevice &&
        [self isCurrentMediaOrigin:self.recordingOriginService generation:self.recordingConnectionGeneration]) {
        [self notifyDevice:TSCameraActionStartRecording];
    }
}

// 拍照结果通知保留 Android 语义，但跨设备的保存重试不发送。
- (void)notifyPhotoResultIfCurrent {
    if (self.pendingPhotoNotification &&
        [self isCurrentMediaOrigin:self.photoOriginService generation:self.photoNotificationGeneration]) {
        [self notifyDevice:TSCameraActionTakePhoto];
    }
    self.pendingPhotoNotification = NO;
}

// 手机按钮与设备动作共用入口，来源只决定是否通知回设备。
- (void)handleAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice {
    if (self.mediaPreviewPresented && action != TSCameraActionExitCamera &&
        action != TSCameraActionStopRecording) {
        return;
    }
    if (action == TSCameraActionExitCamera) {
        [self requestCloseFromDevice:fromDevice];
        return;
    }
    if (action == TSCameraActionEnterCamera) {
        if (fromDevice) {
            self.deviceEntered = YES;
        }
        [self resumeCaptureIfPossible];
        return;
    }
    if (action == TSCameraActionStopRecording) {
        [self stopRecordingFromDevice:fromDevice];
        return;
    }
    if (action == TSCameraActionEnterPhotoMode && (self.phase != TSCameraCapturePhaseIdle ||
        self.pendingStartRecording)) {
        self.pendingStartRecording = NO;
        self.returnToPhoto = YES;
        if (self.phase == TSCameraCapturePhaseRecording || self.phase == TSCameraCapturePhasePreparingRecording) {
            [self stopRecordingFromDevice:fromDevice];
        }
        [self finishPendingTransition];
        return;
    }
    if (!self.cameraAuthorized || !self.sessionReady || [self isCaptureBusy] || self.closeRequested) {
        [self ts_showToast:@"相机尚未就绪或作品等待保存"];
        return;
    }
    if ((action == TSCameraActionEnterVideoMode || action == TSCameraActionStartRecording) &&
        !self.videoModeSupported) {
        [self ts_showToast:@"当前固件未声明录像能力"];
        return;
    }
    switch (action) {
        case TSCameraActionTakePhoto: [self takePhoto]; break;
        case TSCameraActionSwitchBackCamera:
        case TSCameraActionSwitchFrontCamera: [self switchLensForAction:action fromDevice:fromDevice]; break;
        case TSCameraActionFlashOff:
        case TSCameraActionFlashAuto:
        case TSCameraActionFlashOn: [self applyFlashAction:action fromDevice:fromDevice]; break;
        case TSCameraActionEnterPhotoMode:
        case TSCameraActionEnterVideoMode: [self switchModeForAction:action fromDevice:fromDevice]; break;
        case TSCameraActionZoomRatioMaximum:
        case TSCameraActionZoomRatioMinimum:
        case TSCameraActionZoomRatioOneX:
        case TSCameraActionZoomRatioTwoX:
        case TSCameraActionZoomRatioThreeX: [self setZoomForAction:action fromDevice:fromDevice]; break;
        case TSCameraActionStartRecording: [self prepareRecordingFromDevice:fromDevice]; break;
        default: break;
    }
}

// 指定镜头重复设置保持幂等，录制中不替换输入。
- (void)switchLensForAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice {
    BOOL back = action == TSCameraActionSwitchBackCamera;
    if (self.phase == TSCameraCapturePhaseRecording) {
        [self ts_showToast:@"请先停止录像再切换镜头"];
        return;
    }
    if (self.backCamera == back) {
        return;
    }
    [self configureVideoMode:self.videoMode position:back ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront
                 fromDevice:fromDevice completion:nil];
}

// 模式切换成功后才更新 UI 和通知设备。
- (void)switchModeForAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice {
    BOOL video = action == TSCameraActionEnterVideoMode;
    if (self.phase == TSCameraCapturePhaseRecording || self.videoMode == video) {
        return;
    }
    if (video && !self.deviceReady) {
        [self ts_showToast:@"重新连接设备后才能使用录像"];
        return;
    }
    [self configureVideoMode:video position:self.backCamera ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront
                 fromDevice:fromDevice completion:nil];
}

// 动作使用显示倍率，执行时换算到 AVCaptureDevice 的 zoom factor。
- (CGFloat)zoomRatioForAction:(TSCameraAction)action {
    switch (action) {
        case TSCameraActionZoomRatioMaximum: return self.maximumZoomRatio;
        case TSCameraActionZoomRatioMinimum: return self.minimumZoomRatio;
        case TSCameraActionZoomRatioTwoX: return 2;
        case TSCameraActionZoomRatioThreeX: return 3;
        default: return 1;
    }
}

// 只设置目标倍率，不随点击重发相机范围。
- (void)setZoomForAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice {
    CGFloat requested = [self zoomRatioForAction:action];
    CGFloat target = MIN(self.maximumZoomRatio, MAX(self.minimumZoomRatio, requested));
    CGFloat multiplier = self.zoomDisplayMultiplier;
    AVCaptureDevice *device = self.currentDeviceInput.device;
    NSUInteger generation = self.configurationGeneration;
    NSUInteger originGeneration = self.connectionGeneration;
    id<TSCameraInterface> originService = self.cameraService;
    dispatch_async(self.captureQueue, ^{
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            device.videoZoomFactor = MIN(device.maxAvailableVideoZoomFactor,
                                         MAX(device.minAvailableVideoZoomFactor, target / multiplier));
            [device unlockForConfiguration];
        }
        CGFloat actual = device.videoZoomFactor * multiplier;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != self.configurationGeneration) {
                return;
            }
            if (error) {
                [self reportError:error fallback:@"变焦设置失败"];
                return;
            }
            self.currentZoomRatio = actual;
            [self refreshUI];
            [self ts_showToast:[NSString stringWithFormat:@"已设置 %.1f×%@", actual,
                               fabs(target - requested) > 0.01 ? @"（已限制到镜头范围）" : @""]];
            if (!fromDevice) {
                [self notifyDevice:action originService:originService generation:originGeneration];
            }
        });
    });
}

// 拍照闪光与录像常亮补光分别按硬件能力执行。
- (void)applyFlashAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice {
    AVCaptureFlashMode mode = action == TSCameraActionFlashAuto ? AVCaptureFlashModeAuto :
        action == TSCameraActionFlashOn ? AVCaptureFlashModeOn : AVCaptureFlashModeOff;
    AVCaptureDevice *device = self.currentDeviceInput.device;
    if (!self.flashAvailable || (self.videoMode && mode == AVCaptureFlashModeAuto)) {
        [self ts_showToast:@"当前镜头或模式不支持此闪光设置"];
        return;
    }
    if (!self.videoMode) {
        if (![self.photoOutput.supportedFlashModes containsObject:@(mode)]) {
            [self ts_showToast:@"当前拍照配置不支持此闪光模式"];
            return;
        }
        self.flashMode = mode;
        [self refreshUI];
        if (!fromDevice) {
            [self notifyDevice:action];
        }
        return;
    }
    BOOL enabled = mode == AVCaptureFlashModeOn;
    NSUInteger generation = self.configurationGeneration;
    NSUInteger originGeneration = self.connectionGeneration;
    id<TSCameraInterface> originService = self.cameraService;
    dispatch_async(self.captureQueue, ^{
        NSError *error = nil;
        AVCaptureTorchMode torchMode = enabled ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        BOOL success = [device isTorchModeSupported:torchMode] && [device lockForConfiguration:&error];
        if (success) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != self.configurationGeneration) {
                return;
            }
            if (!success) {
                [self reportError:error fallback:@"补光设置失败"];
                return;
            }
            self.torchEnabled = enabled;
            [self refreshUI];
            if (!fromDevice) {
                [self notifyDevice:action originService:originService generation:originGeneration];
            }
        });
    });
}

// 保存原始照片文件后再请求相册写入，失败仍保留可恢复作品。
- (void)takePhoto {
    if (self.videoMode || self.phase != TSCameraCapturePhaseIdle) {
        [self ts_showToast:@"请先回到拍照模式"];
        return;
    }
    self.phase = TSCameraCapturePhaseSaving;
    self.mediaOperationRetainer = self;
    // 对齐 Android：拍照成功作为结果通知，不属于模式/录像动作回声。
    self.pendingPhotoNotification = YES;
    self.photoNotificationGeneration = self.connectionGeneration;
    self.photoOriginService = self.cameraService;
    [self refreshUI];
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    if ([self.photoOutput.supportedFlashModes containsObject:@(self.flashMode)]) {
        settings.flashMode = self.flashMode;
    }
    dispatch_async(self.captureQueue, ^{
        [self.photoOutput capturePhotoWithSettings:settings delegate:self];
    });
}

// 首次录像才申请麦克风；拒绝后继续无声录像。
- (void)prepareRecordingFromDevice:(BOOL)fromDevice {
    if (self.phase == TSCameraCapturePhaseRecording || self.pendingStartRecording) {
        return;
    }
    if (!self.videoModeSupported || !self.deviceReady || self.closeRequested) {
        [self ts_showToast:@"设备录像能力尚未就绪"];
        return;
    }
    self.pendingStartRecording = YES;
    self.pendingStartFromDevice = fromDevice;
    self.recordingRequestGeneration = self.connectionGeneration;
    self.recordingRequestService = self.cameraService;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusNotDetermined) {
        self.phase = TSCameraCapturePhasePreparingRecording;
        self.microphoneRequestPending = YES;
        [self refreshUI];
        __weak typeof(self) weakSelf = self;
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.microphoneRequestPending = NO;
                weakSelf.phase = TSCameraCapturePhaseIdle;
                [weakSelf continueRecordingPreparation];
                [weakSelf finishPendingTransition];
            });
        }];
        return;
    }
    [self continueRecordingPreparation];
}

// 权限回调和前台恢复都从同一入口继续，输出绑定后才真正开始录像。
- (void)continueRecordingPreparation {
    if (self.mediaPreviewPresented || !self.pendingStartRecording || self.microphoneRequestPending) {
        return;
    }
    if (!self.deviceReady || !self.videoModeSupported || self.closeRequested || self.closing ||
        ![self isCurrentMediaOrigin:self.recordingRequestService generation:self.recordingRequestGeneration]) {
        self.pendingStartRecording = NO;
        [self refreshUI];
        return;
    }
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive || !self.pageVisible ||
        self.phase != TSCameraCapturePhaseIdle) {
        return;
    }
    BOOL fromDevice = self.pendingStartFromDevice;
    BOOL audioAuthorized = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] ==
        AVAuthorizationStatusAuthorized;
    if ([self canReuseRecordingConfigurationWithAudioAuthorized:audioAuthorized]) {
        self.pendingStartRecording = NO;
        [self startMovieRecordingFromDevice:fromDevice];
        return;
    }
    [self configureVideoMode:YES position:self.backCamera ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront
                 fromDevice:fromDevice completion:^(BOOL success) {
        if (!success) {
            self.pendingStartRecording = NO;
            return;
        }
        if (!self.pendingStartRecording || self.closeRequested || !self.deviceReady || !self.videoModeSupported ||
            ![self isCurrentMediaOrigin:self.recordingRequestService generation:self.recordingRequestGeneration] ||
            UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
            return;
        }
        self.pendingStartRecording = NO;
        [self startMovieRecordingFromDevice:fromDevice];
    }];
}

// 录像输出和音轨授权配置均未变化时直接开始，保留待机倍率与补光且不重发范围。
- (BOOL)canReuseRecordingConfigurationWithAudioAuthorized:(BOOL)audioAuthorized {
    return self.videoMode && self.movieOutput != nil && self.sessionReady &&
        self.configuredAudioAuthorized == audioAuthorized;
}

// 录像直接输出持久化临时文件，收到 didStart 回调才开始计时和同步。
- (void)startMovieRecordingFromDevice:(BOOL)fromDevice {
    NSError *error = nil;
    NSURL *fileURL = [self newMediaURLWithExtension:@"mov" error:&error];
    if (!fileURL) {
        [self reportError:error fallback:@"无法创建录像文件"];
        return;
    }
    self.pendingMediaURL = fileURL;
    self.mediaOperationRetainer = self;
    self.pendingPhotoNotification = NO;
    self.phase = TSCameraCapturePhasePreparingRecording;
    self.recordingFromDevice = fromDevice;
    self.recordingConnectionGeneration = self.connectionGeneration;
    self.recordingOriginService = self.cameraService;
    self.recordingStopRequested = NO;
    [self refreshUI];
    if (self.silentRecording) {
        [self ts_showToast:@"麦克风不可用，将录制无声视频"];
    }
    dispatch_async(self.captureQueue, ^{
        [self.movieOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
    });
}

// 重复停止幂等；准备中的录像延迟到 didStart 后停止，不能提前重绑输出。
- (void)stopRecordingFromDevice:(BOOL)fromDevice {
    self.pendingStartRecording = NO;
    if (self.microphoneRequestPending) {
        self.phase = TSCameraCapturePhaseIdle;
        [self refreshUI];
        [self finishPendingTransition];
        return;
    }
    if (self.phase == TSCameraCapturePhasePreparingRecording) {
        self.recordingStopRequested = YES;
        self.stopFromDevice = fromDevice;
        return;
    }
    if (self.phase != TSCameraCapturePhaseRecording) {
        return;
    }
    self.phase = TSCameraCapturePhaseStopping;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    if (!fromDevice && [self isCurrentMediaOrigin:self.recordingOriginService generation:self.recordingConnectionGeneration]) {
        [self notifyDevice:TSCameraActionStopRecording];
    }
    [self refreshUI];
    dispatch_async(self.captureQueue, ^{ [self.movieOutput stopRecording]; });
}

// 相机关闭延迟到配置、录像收尾和保存结果明确之后。
- (void)requestCloseFromDevice:(BOOL)fromDevice {
    if (self.closing) {
        return;
    }
    if (!self.closeRequested) {
        self.closeOriginGeneration = self.connectionGeneration;
        self.closeOriginService = self.cameraService;
        self.closeFromDevice = fromDevice;
    } else {
        self.closeFromDevice |= fromDevice;
    }
    self.closeRequested = YES;
    self.pendingStartRecording = NO;
    [self stopRecordingFromDevice:fromDevice];
    if (self.mediaPreviewPresented) {
        [self dismissMediaPreview];
        return;
    }
    if (self.phase == TSCameraCapturePhaseSaveFailed) {
        [self ts_showToast:@"请选择重试保存或保留作品后退出"];
    }
    [self finishPendingTransition];
}

// 执行排队的关闭或回拍照，保存失败时保留选择权和文件。
- (void)finishPendingTransition {
    if (self.phase != TSCameraCapturePhaseIdle || self.closing || self.microphoneRequestPending) {
        return;
    }
    if (self.closeRequested) {
        [self finishClosing];
        return;
    }
    if (self.mediaPreviewPresented) {
        return;
    }
    if (self.returnToPhoto && self.videoMode) {
        self.returnToPhoto = NO;
        [self configureVideoMode:NO position:self.backCamera ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront
                     fromDevice:YES completion:nil];
        return;
    }
    self.returnToPhoto = NO;
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        self.sessionReady = NO;
        dispatch_async(self.captureQueue, ^{ [self.captureSession stopRunning]; });
        [self endMediaBackgroundTask];
    } else {
        [self continueRecordingPreparation];
    }
}

// 停流完成后再发送退出；设备来源不反发相同动作。
- (void)finishClosing {
    if (self.mediaPreviewPresented) {
        [self dismissMediaPreview];
        return;
    }
    self.closing = YES;
    self.pageVisible = NO;
    self.captureAllowed = NO;
    self.deviceEntered = NO;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    [self stopPreviewWithCompletion:^{
        if (!self.closeFromDevice) {
            [self notifyDevice:TSCameraActionExitCamera originService:self.closeOriginService
                    generation:self.closeOriginGeneration];
        }
        dispatch_async(self.captureQueue, ^{
            [self.captureSession stopRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self endMediaBackgroundTask];
                if (!self.externallyRemoved) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                self.mediaOperationRetainer = nil;
            });
        });
    }];
}

// 仅在后台收尾期间申请有限时间，原始文件始终先落盘。
- (void)beginMediaBackgroundTask {
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.backgroundTask = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
        [weakSelf endMediaBackgroundTask];
    }];
}

// 结束系统后台任务。
- (void)endMediaBackgroundTask {
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [UIApplication.sharedApplication endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

// 临时作品保存在应用支持目录，系统缓存清理不会误删失败作品。
- (NSURL *)retainedMediaDirectoryWithError:(NSError **)error {
    NSFileManager *manager = NSFileManager.defaultManager;
    NSURL *support = [manager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask
                          appropriateForURL:nil create:YES error:error];
    if (!support) {
        return nil;
    }
    NSURL *directory = [support URLByAppendingPathComponent:@"TSCameraPending" isDirectory:YES];
    if (![manager createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:error]) {
        return nil;
    }
    return directory;
}

// 为每次拍摄创建独立文件，重试和退出都不覆盖其他待保存作品。
- (NSURL *)newMediaURLWithExtension:(NSString *)extension error:(NSError **)error {
    NSURL *directory = [self retainedMediaDirectoryWithError:error];
    NSString *name = [NSString stringWithFormat:@"camera_%@.%@", NSUUID.UUID.UUIDString, extension];
    return directory ? [directory URLByAppendingPathComponent:name] : nil;
}

// 最近成功作品的独立缓存目录。
- (NSURL *)recentMediaCacheDirectory {
    return [[NSFileManager.defaultManager URLsForDirectory:NSCachesDirectory
                                                inDomains:NSUserDomainMask].firstObject
            URLByAppendingPathComponent:@"TSCameraRecent" isDirectory:YES];
}

// 只读取真实媒体文件，按修改时间从新到旧排列。
- (NSArray<NSURL *> *)mediaURLsInDirectory:(NSURL *)directory {
    NSArray<NSURL *> *files = directory ? [NSFileManager.defaultManager contentsOfDirectoryAtURL:directory
        includingPropertiesForKeys:@[NSURLContentModificationDateKey, NSURLIsRegularFileKey]
        options:NSDirectoryEnumerationSkipsHiddenFiles
        error:nil] : @[];
    NSPredicate *mediaPredicate = [NSPredicate predicateWithBlock:^BOOL(NSURL *file, NSDictionary *bindings) {
        NSNumber *regularFile = nil;
        [file getResourceValue:&regularFile forKey:NSURLIsRegularFileKey error:nil];
        return regularFile.boolValue && [@[@"jpg", @"mov"] containsObject:file.pathExtension.lowercaseString];
    }];
    return [[files filteredArrayUsingPredicate:mediaPredicate] sortedArrayUsingComparator:
        ^NSComparisonResult(NSURL *first, NSURL *second) {
        NSDate *firstDate = nil;
        NSDate *secondDate = nil;
        [first getResourceValue:&firstDate forKey:NSURLContentModificationDateKey error:nil];
        [second getResourceValue:&secondDate forKey:NSURLContentModificationDateKey error:nil];
        return [(secondDate ?: NSDate.distantPast) compare:(firstDate ?: NSDate.distantPast)];
    }];
}

// 已入相册但移动缓存失败的原件不再提示重复保存。
- (NSArray<NSURL *> *)retainedMediaURLs {
    NSArray<NSURL *> *files = [self mediaURLsInDirectory:[self retainedMediaDirectoryWithError:nil]];
    return [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSURL *file, NSDictionary *bindings) {
        return ![NSFileManager.defaultManager fileExistsAtPath:[file URLByAppendingPathExtension:@"saved"].path];
    }]];
}

// 优先恢复未保存作品，否则恢复最近成功缓存与封面。
- (void)restoreRecentMedia {
    NSURL *latest = self.retainedMediaURLs.firstObject;
    BOOL saved = latest == nil;
    if (!latest) {
        latest = [self mediaURLsInDirectory:self.recentMediaCacheDirectory].firstObject;
    }
    if (!latest) {
        // 缓存移动失败时，保存凭据仍允许原件作为已保存作品展示。
        for (NSURL *candidate in [self mediaURLsInDirectory:[self retainedMediaDirectoryWithError:nil]]) {
            if ([NSFileManager.defaultManager fileExistsAtPath:
                 [candidate URLByAppendingPathExtension:@"saved"].path]) {
                latest = candidate;
                break;
            }
        }
    }
    if (!latest) {
        return;
    }
    self.pendingMediaURL = saved ? nil : latest;
    self.recentMediaURL = latest;
    self.recentMediaSaved = saved;
    self.phase = saved ? TSCameraCapturePhaseIdle : TSCameraCapturePhaseSaveFailed;
    [self updateThumbnailForURL:latest];
    [self refreshUI];
}

// 原始照片先持久化，再异步导入相册；磁盘写失败仍保留内存数据供重试。
- (void)persistPhotoData:(NSData *)data {
    self.pendingPhotoData = data;
    self.phase = TSCameraCapturePhaseSaving;
    [self refreshUI];
    dispatch_async(self.captureQueue, ^{
        NSError *error = nil;
        NSURL *fileURL = [self newMediaURLWithExtension:@"jpg" error:&error];
        BOOL success = fileURL && [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                self.phase = TSCameraCapturePhaseSaveFailed;
                [self reportError:error fallback:@"原始照片写入失败，请释放空间后重试"];
                [self refreshUI];
                self.mediaOperationRetainer = nil;
                return;
            }
            self.pendingPhotoData = nil;
            self.pendingMediaURL = fileURL;
            self.recentMediaURL = fileURL;
            self.recentMediaSaved = NO;
            [self updateThumbnailForURL:fileURL];
            [self savePendingMedia];
        });
    });
}

// 按添加权限保存，拒绝或写入失败保留原文件并显示重试。
- (void)savePendingMedia {
    if (!self.pendingMediaURL) {
        if (self.pendingPhotoData) {
            [self persistPhotoData:self.pendingPhotoData];
        }
        return;
    }
    self.phase = TSCameraCapturePhaseSaving;
    [self refreshUI];
    PHAuthorizationStatus status;
    if (@available(iOS 14.0, *)) {
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly];
    } else {
        status = PHPhotoLibrary.authorizationStatus;
    }
    if (status == PHAuthorizationStatusNotDetermined) {
        void (^authorizationResult)(PHAuthorizationStatus) = ^(PHAuthorizationStatus result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == PHAuthorizationStatusAuthorized || result == PHAuthorizationStatusLimited) {
                    [self importPendingMedia];
                } else {
                    [self mediaSaveFailed:[self captureErrorWithDescription:@"相册权限未授权，作品已保留"]];
                }
            });
        };
        if (@available(iOS 14.0, *)) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:authorizationResult];
        } else {
            [PHPhotoLibrary requestAuthorization:authorizationResult];
        }
        return;
    }
    if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
        [self importPendingMedia];
    } else {
        [self mediaSaveFailed:[self captureErrorWithDescription:@"请在设置中允许保存到相册，作品已保留"]];
    }
}

// 相册成功回调是唯一的“已保存”依据。
- (void)importPendingMedia {
    NSURL *fileURL = self.pendingMediaURL;
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        if ([fileURL.pathExtension.lowercaseString isEqualToString:@"mov"]) {
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileURL];
        } else {
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileURL];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                [self mediaSaveFailed:error];
                return;
            }
            self.recentMediaSaved = YES;
            self.pendingMediaURL = nil;
            self.phase = TSCameraCapturePhaseIdle;
            [self notifyPhotoResultIfCurrent];
            [self moveSavedMediaToRecentCache:fileURL];
            [self updateThumbnailForURL:self.recentMediaURL];
            [self ts_showToast:@"已保存到相册"];
            [self refreshUI];
            [self endMediaBackgroundTask];
            [self finishPendingTransition];
            [self resumeCaptureIfPossible];
            self.mediaOperationRetainer = nil;
        });
    }];
}

// 保存失败只改变状态，不删除已完成的视频或照片。
- (void)mediaSaveFailed:(NSError *)error {
    self.phase = TSCameraCapturePhaseSaveFailed;
    [self reportError:error fallback:@"保存失败，原始作品已保留，可重试或稍后保存"];
    [self refreshUI];
    [self endMediaBackgroundTask];
    if (self.externallyRemoved && self.pendingMediaURL) {
        [self onKeepMediaTapped];
    }
    self.mediaOperationRetainer = nil;
}

// 相册确认成功后才移到最近作品缓存，待保存目录中的其他文件不受影响。
- (void)moveSavedMediaToRecentCache:(NSURL *)fileURL {
    NSFileManager *manager = NSFileManager.defaultManager;
    NSURL *cache = self.recentMediaCacheDirectory;
    NSError *error = nil;
    if (![manager createDirectoryAtURL:cache withIntermediateDirectories:YES attributes:nil error:&error]) {
        TSLogWarning(@"[Camera] 最近作品缓存不可用: %@", error.localizedDescription);
        // 保存凭据用于恢复时排除已入相册的原始文件。
        [@"saved" writeToURL:[fileURL URLByAppendingPathExtension:@"saved"]
                 atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return;
    }
    NSURL *destination = [cache URLByAppendingPathComponent:fileURL.lastPathComponent];
    if ([manager moveItemAtURL:fileURL toURL:destination error:&error]) {
        self.recentMediaURL = destination;
        for (NSURL *previous in [self mediaURLsInDirectory:cache]) {
            // 同目录文件名唯一，避免不同 NSURL 表示误删当前作品。
            if (![previous.lastPathComponent isEqualToString:destination.lastPathComponent]) {
                [manager removeItemAtURL:previous error:nil];
            }
        }
    } else {
        TSLogWarning(@"[Camera] 最近作品缓存移动失败: %@", error.localizedDescription);
        [@"saved" writeToURL:[fileURL URLByAppendingPathExtension:@"saved"]
                 atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

// 图片按方向解码小图；视频抽取实际可用帧，失败保留错误供日志定位。
- (UIImage *)thumbnailImageForURL:(NSURL *)fileURL error:(NSError **)error {
    UIImage *image = nil;
    NSError *decodeError = nil;
    if ([fileURL.pathExtension.lowercaseString isEqualToString:@"mov"]) {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = CGSizeMake(320, 320);
        CGImageRef frame = [generator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&decodeError];
        if (!frame) {
            frame = [generator copyCGImageAtTime:CMTimeMake(1, 10) actualTime:NULL error:&decodeError];
        }
        if (frame) {
            image = [UIImage imageWithCGImage:frame];
            CGImageRelease(frame);
        }
    } else {
        NSData *data = [NSData dataWithContentsOfURL:fileURL options:NSDataReadingMappedIfSafe error:&decodeError];
        CGImageSourceRef source = data ? CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL) : NULL;
        if (source) {
            NSDictionary *options = @{
                (__bridge NSString *)kCGImageSourceCreateThumbnailFromImageAlways: @YES,
                (__bridge NSString *)kCGImageSourceCreateThumbnailWithTransform: @YES,
                (__bridge NSString *)kCGImageSourceThumbnailMaxPixelSize: @320,
                (__bridge NSString *)kCGImageSourceShouldCacheImmediately: @YES,
            };
            CGImageRef frame = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)options);
            if (frame) {
                image = [UIImage imageWithCGImage:frame];
                CGImageRelease(frame);
            }
            CFRelease(source);
        }
    }
    if (error) {
        *error = image ? nil : (decodeError ?: [self captureErrorWithDescription:@"作品封面解码失败"]);
    }
    return image;
}

// 后台生成真实封面；移动后的同一作品可识别，失败不清空已有封面。
- (void)updateThumbnailForURL:(NSURL *)fileURL {
    if (!fileURL) {
        return;
    }
    NSString *identifier = fileURL.lastPathComponent;
    if (![self.thumbnailMediaIdentifier isEqualToString:identifier]) {
        self.thumbnailMediaIdentifier = identifier;
        self.recentThumbnail = nil;
    }
    NSUInteger generation = ++self.thumbnailGeneration;
    [self refreshUI];
    dispatch_async(self.captureQueue, ^{
        NSError *error = nil;
        UIImage *image = [self thumbnailImageForURL:fileURL error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != self.thumbnailGeneration ||
                ![self.recentMediaURL.lastPathComponent isEqualToString:identifier]) {
                return;
            }
            if (image) {
                self.recentThumbnail = image;
            } else {
                TSLogWarning(@"[Camera] 作品封面生成失败 %@: %@", identifier, error.localizedDescription);
            }
            [self refreshUI];
        });
    });
}

// 用项目 Toast 与日志报告可操作的错误。
- (void)reportError:(NSError *)error fallback:(NSString *)fallback {
    NSString *message = error.localizedDescription.length > 0 ? error.localizedDescription : fallback;
    TSLogWarning(@"[Camera] %@", message);
    [self ts_showToast:message];
}

// 手机关闭与设备退出共用延迟收尾流程。
- (void)onBackTapped {
    [self handleAction:TSCameraActionExitCamera fromDevice:NO];
}

// 手机快门按当前模式映射，录像中同一按钮执行停止。
- (void)onShutterTapped {
    TSCameraAction action = !self.videoMode ? TSCameraActionTakePhoto :
        self.phase == TSCameraCapturePhaseRecording ? TSCameraActionStopRecording : TSCameraActionStartRecording;
    [self handleAction:action fromDevice:NO];
}

// 镜头按钮只请求目标镜头，实际结果以配置回调为准。
- (void)onSwitchCameraTapped {
    [self handleAction:self.backCamera ? TSCameraActionSwitchFrontCamera : TSCameraActionSwitchBackCamera fromDevice:NO];
}

// 模式控件不先行修改采集状态。
- (void)onModeChanged {
    [self handleAction:self.modeControl.selectedSegmentIndex == 1 ? TSCameraActionEnterVideoMode :
     TSCameraActionEnterPhotoMode fromDevice:NO];
    [self refreshUI];
}

// 倍率按钮直接执行对应动作，无滑杆或捏合。
- (void)onZoomTapped:(UIButton *)sender {
    [self handleAction:(TSCameraAction)sender.tag fromDevice:NO];
}

// 拍照显示硬件支持的三态；录像只显示常亮补光关和开。
- (void)onFlashTapped {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:self.videoMode ? @"录像补光" : @"拍照闪光"
        message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray<NSNumber *> *actions = self.videoMode ? @[@(TSCameraActionFlashOff), @(TSCameraActionFlashOn)] :
        @[@(TSCameraActionFlashOff), @(TSCameraActionFlashAuto), @(TSCameraActionFlashOn)];
    for (NSNumber *number in actions) {
        TSCameraAction action = number.integerValue;
        AVCaptureFlashMode mode = action == TSCameraActionFlashAuto ? AVCaptureFlashModeAuto :
            action == TSCameraActionFlashOn ? AVCaptureFlashModeOn : AVCaptureFlashModeOff;
        if (!self.videoMode && ![self.photoOutput.supportedFlashModes containsObject:@(mode)]) {
            continue;
        }
        NSString *title = action == TSCameraActionFlashOff ? @"关" : action == TSCameraActionFlashAuto ? @"自动" : @"开";
        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *choice) {
            [self handleAction:action fromDevice:NO];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.sourceView = self.flashButton;
    sheet.popoverPresentationController.sourceRect = self.flashButton.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

// 预览失败不会阻止手机拍照，可单独重试。
- (void)onPreviewTapped {
    self.previewFailed = NO;
    [self ensureDeviceCameraEntered];
}

// 权限只由用户在系统设置中修改。
- (void)onPermissionTapped {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                    options:@{} completionHandler:nil];
}

// 相册重试复用同一原始文件。
- (void)onRetrySaveTapped {
    [self savePendingMedia];
}

// 临时保留后允许退出或继续拍摄；未落盘的数据不能误称已保留。
- (void)onKeepMediaTapped {
    if (self.pendingPhotoData && !self.pendingMediaURL) {
        [self ts_showToast:@"原始照片尚未写入磁盘，请释放空间后重试"];
        return;
    }
    self.pendingMediaURL = nil;
    self.pendingPhotoNotification = NO;
    self.phase = TSCameraCapturePhaseIdle;
    [self ts_showToast:@"作品已临时保留，可在作品入口重试保存"];
    [self refreshUI];
    [self finishPendingTransition];
    [self resumeCaptureIfPossible];
}

// 最近作品与所有保留文件都可操作，避免退出后留下无法访问的失败媒体。
- (void)onThumbnailTapped {
    if (self.mediaPreviewPresented || self.presentedViewController || self.closeRequested || self.closing ||
        self.pendingStartRecording || self.phase == TSCameraCapturePhaseRecording ||
        ([self isCaptureBusy] && self.phase != TSCameraCapturePhaseSaveFailed)) {
        return;
    }
    NSURL *recentURL = self.recentMediaURL;
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"最近作品"
        message:self.recentMediaSaved ? @"已保存到相册" : @"临时保留，尚未保存到相册"
        preferredStyle:UIAlertControllerStyleActionSheet];
    if (recentURL) {
        [sheet addAction:[UIAlertAction actionWithTitle:@"预览最近作品" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) { [self presentMediaAtURL:recentURL]; }]];
    }
    for (NSURL *fileURL in self.retainedMediaURLs) {
        NSString *title = [NSString stringWithFormat:@"保存保留的%@ · %@",
            [fileURL.pathExtension isEqualToString:@"mov"] ? @"视频" : @"照片",
            [fileURL.lastPathComponent substringToIndex:MIN((NSUInteger)19, fileURL.lastPathComponent.length)]];
        [sheet addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.pendingMediaURL = fileURL;
            self.recentMediaURL = fileURL;
            self.recentMediaSaved = NO;
            [self updateThumbnailForURL:fileURL];
            [self savePendingMedia];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.sourceView = self.thumbnailButton;
    sheet.popoverPresentationController.sourceRect = self.thumbnailButton.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

// 验证真实文件后再展示，缓存失效或照片解码失败不打开空页面。
- (void)presentMediaAtURL:(NSURL *)fileURL {
    if (self.mediaPreviewPresented || self.closing || self.closeRequested ||
        self.pendingStartRecording || self.phase == TSCameraCapturePhaseRecording ||
        ([self isCaptureBusy] && self.phase != TSCameraCapturePhaseSaveFailed)) {
        return;
    }
    if ([self.presentedViewController isKindOfClass:UIAlertController.class]) {
        [self dismissViewControllerAnimated:YES completion:^{ [self presentMediaAtURL:fileURL]; }];
        return;
    }
    if (self.presentedViewController) {
        return;
    }
    NSDictionary *attributes = fileURL.isFileURL ?
        [NSFileManager.defaultManager attributesOfItemAtPath:fileURL.path error:nil] : nil;
    BOOL readable = fileURL.isFileURL && [NSFileManager.defaultManager isReadableFileAtPath:fileURL.path];
    BOOL supported = [@[@"jpg", @"mov"] containsObject:fileURL.pathExtension.lowercaseString];
    if (!readable || !supported || [attributes[NSFileSize] unsignedLongLongValue] == 0 ||
        ![attributes[NSFileType] isEqualToString:NSFileTypeRegular]) {
        [self reportError:[self captureErrorWithDescription:@"作品文件不存在或无法读取，请重新拍摄"]
                fallback:@"作品无法预览"];
        return;
    }
    if ([fileURL.pathExtension.lowercaseString isEqualToString:@"mov"]) {
        AVPlayerViewController *player = [[AVPlayerViewController alloc] init];
        self.mediaPreviewItem = [AVPlayerItem playerItemWithURL:fileURL];
        self.mediaPreviewPlayer = [AVPlayer playerWithPlayerItem:self.mediaPreviewItem];
        player.player = self.mediaPreviewPlayer;
        player.allowsPictureInPicturePlayback = NO;
        player.modalPresentationStyle = UIModalPresentationFullScreen;
        [self beginMediaPreviewWithController:player];
        return;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:fileURL.path];
    if (!image) {
        [self reportError:[self captureErrorWithDescription:@"照片解码失败，无法打开预览"]
                fallback:@"照片无法预览"];
        return;
    }
    UIViewController *preview = [[UIViewController alloc] init];
    preview.title = self.recentMediaSaved ? @"已保存的照片" : @"临时保留的照片";
    preview.edgesForExtendedLayout = UIRectEdgeNone;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = UIColor.blackColor;
    preview.view = imageView;
    preview.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回相机"
        style:UIBarButtonItemStyleDone target:self action:@selector(dismissMediaPreview)];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:preview];
    navigation.modalPresentationStyle = UIModalPresentationFullScreen;
    [self beginMediaPreviewWithController:navigation];
}

// 停止真实采集和推流后再展示，视频播放不会继续占用相机麦克风。
- (void)beginMediaPreviewWithController:(UIViewController *)controller {
    self.mediaPreviewPresented = YES;
    self.mediaPreviewFailureHandling = NO;
    self.mediaPreviewGeneration += 1;
    self.mediaPreviewController = controller;
    self.captureAllowed = NO;
    self.sessionReady = NO;
    if (self.mediaPreviewItem) {
        self.mediaPreviewItemObserved = YES;
        [self.mediaPreviewItem addObserver:self forKeyPath:@"status"
                                  options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                  context:TSCameraMediaPreviewStatusContext];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(mediaPlaybackFailed:)
            name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.mediaPreviewItem];
    }
    [self refreshUI];
    [self stopPreviewWithCompletion:^{
        if (!self.mediaPreviewPresented || self.mediaPreviewController != controller) {
            return;
        }
        dispatch_async(self.captureQueue, ^{
            if (!self.mediaPreviewPresented || self.mediaPreviewController != controller) {
                return;
            }
            [self.captureSession stopRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.mediaPreviewPresented || self.mediaPreviewController != controller) {
                    return;
                }
                if (self.closing || self.closeRequested || !self.pageVisible ||
                    UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
                    [self finishMediaPreview];
                    return;
                }
                if (self.mediaPreviewPlayer && ![self configureAudioForMediaPlayback]) {
                    [self handleMediaPlaybackError:[self captureErrorWithDescription:@"无法启用视频播放声音"]];
                    return;
                }
                [self presentViewController:controller animated:YES completion:^{
                    if (self.mediaPreviewPresented && self.mediaPreviewController == controller &&
                        UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
                        [self.mediaPreviewPlayer play];
                    }
                }];
            });
        });
    }];
}

// 关闭照片或播放页后统一解除观察与恢复相机。
- (void)dismissMediaPreview {
    [self.mediaPreviewPlayer pause];
    if (self.presentedViewController == self.mediaPreviewController && self.mediaPreviewController) {
        [self dismissViewControllerAnimated:YES completion:^{ [self finishMediaPreview]; }];
    } else {
        [self finishMediaPreview];
    }
}

// 播放期间使用正常媒体音频路由，结束后恢复进入前的配置。
- (BOOL)configureAudioForMediaPlayback {
    AVAudioSession *audio = AVAudioSession.sharedInstance;
    self.mediaPreviewAudioCategory = audio.category;
    self.mediaPreviewAudioMode = audio.mode;
    self.mediaPreviewAudioOptions = audio.categoryOptions;
    NSError *error = nil;
    if (![audio setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeMoviePlayback
                    options:0 error:&error]) {
        TSLogWarning(@"[Camera] 视频播放音频配置失败: %@", error.localizedDescription);
        return NO;
    }
    self.mediaPreviewAudioConfigured = YES;
    if (![audio setActive:YES error:&error]) {
        TSLogWarning(@"[Camera] 视频播放音频启动失败: %@", error.localizedDescription);
        return NO;
    }
    return YES;
}

// 播放监听必须先解除再清空播放项，避免结束后旧错误影响下一作品。
- (void)cleanupMediaPreview {
    if (self.mediaPreviewItemObserved && self.mediaPreviewItem) {
        [self.mediaPreviewItem removeObserver:self forKeyPath:@"status" context:TSCameraMediaPreviewStatusContext];
        [NSNotificationCenter.defaultCenter removeObserver:self
            name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.mediaPreviewItem];
    }
    self.mediaPreviewItemObserved = NO;
    [self.mediaPreviewPlayer pause];
    [self.mediaPreviewPlayer replaceCurrentItemWithPlayerItem:nil];
    self.mediaPreviewPlayer = nil;
    self.mediaPreviewItem = nil;
    if (self.mediaPreviewAudioConfigured) {
        NSError *error = nil;
        if (![AVAudioSession.sharedInstance setCategory:self.mediaPreviewAudioCategory
            mode:self.mediaPreviewAudioMode options:self.mediaPreviewAudioOptions error:&error]) {
            TSLogWarning(@"[Camera] 视频播放后音频配置恢复失败: %@", error.localizedDescription);
        }
    }
    self.mediaPreviewAudioConfigured = NO;
    self.mediaPreviewAudioCategory = nil;
    self.mediaPreviewAudioMode = nil;
}

// 原生播放器关闭和照片返回共用终态，重复回调只恢复一次。
- (void)finishMediaPreview {
    if (!self.mediaPreviewPresented) {
        return;
    }
    self.mediaPreviewPresented = NO;
    self.mediaPreviewFailureHandling = NO;
    [self cleanupMediaPreview];
    self.mediaPreviewController = nil;
    self.captureAllowed = self.pageVisible && !self.closing && !self.closeRequested &&
        UIApplication.sharedApplication.applicationState == UIApplicationStateActive;
    [self refreshUI];
    if (self.closeRequested) {
        if (self.phase == TSCameraCapturePhaseSaveFailed) {
            [self ts_showToast:@"请选择重试保存或保留作品后退出"];
        }
        [self finishPendingTransition];
    } else {
        [self finishPendingTransition];
        [self resumeCaptureIfPossible];
    }
}

// 错误提示在返回相机后展示，不留在无内容的播放器上。
- (void)handleMediaPlaybackError:(NSError *)error {
    if (!self.mediaPreviewPresented || self.mediaPreviewFailureHandling) {
        return;
    }
    self.mediaPreviewFailureHandling = YES;
    NSUInteger generation = self.mediaPreviewGeneration;
    void (^finish)(void) = ^{
        if (generation != self.mediaPreviewGeneration) {
            return;
        }
        [self finishMediaPreview];
        if (!self.closing && !self.closeRequested) {
            [self reportError:error fallback:@"视频无法播放，请重新录制"];
        }
    };
    if (self.presentedViewController == self.mediaPreviewController && self.mediaPreviewController) {
        [self dismissViewControllerAnimated:YES completion:finish];
    } else {
        finish();
    }
}

// 定时器只更新显示，持续时间来自单调时钟。
- (void)updateRecordingTimer {
    NSTimeInterval duration = MAX(0, NSProcessInfo.processInfo.systemUptime - self.recordingStartedAt);
    NSInteger seconds = (NSInteger)duration;
    self.timerLabel.text = [NSString stringWithFormat:@"● %02ld:%02ld", (long)(seconds / 60), (long)(seconds % 60)];
}

#pragma mark - 通知回调

// 加载失败和解码失败都能反馈，旧播放项的异步通知被忽略。
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (context != TSCameraMediaPreviewStatusContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    AVPlayerItem *item = object;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.mediaPreviewPresented && item == self.mediaPreviewItem && item.status == AVPlayerItemStatusFailed) {
            [self handleMediaPlaybackError:item.error];
        }
    });
}

// 播放过程中发生终止错误也返回相机并保留原件。
- (void)mediaPlaybackFailed:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.mediaPreviewPresented && notification.object == self.mediaPreviewItem) {
            [self handleMediaPlaybackError:notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey]];
        }
    });
}

// 消费协调器唯一监听转发的主线程动作，后台只接受安全停止与退出。
- (void)deviceActionReceived:(NSNotification *)notification {
    TSCameraAction action = [notification.userInfo[TSDemoCameraActionUserInfoKey] integerValue];
    if (!self.deviceReady || self.closing || !self.pageVisible) {
        return;
    }
    BOOL cleanup = action == TSCameraActionExitCamera || action == TSCameraActionStopRecording;
    if (!cleanup && UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        return;
    }
    [self handleAction:action fromDevice:YES];
}

// 断连立即停流，录像收尾完成后回拍照；重连使用新的门面和能力。
- (void)connectionChanged:(NSNotification *)notification {
    [self applyConnectionSnapshot:notification.userInfo[TSDeviceConnectionSnapshotUserInfoKey]];
}

// 系统弹窗和后台期间不持续推流，录像先收尾并保留原始文件。
- (void)appWillResignActive:(NSNotification *)notification {
    self.captureAllowed = NO;
    [self.mediaPreviewPlayer pause];
    [self stopPreviewWithCompletion:nil];
    if (self.microphoneRequestPending) {
        return;
    }
    self.pendingStartRecording = NO;
    if (self.phase == TSCameraCapturePhaseRecording || self.phase == TSCameraCapturePhasePreparingRecording) {
        [self beginMediaBackgroundTask];
        self.returnToPhoto = YES;
        [self stopRecordingFromDevice:NO];
    } else if (self.phase == TSCameraCapturePhaseSaving || self.phase == TSCameraCapturePhaseStopping) {
        [self beginMediaBackgroundTask];
    } else if (self.phase == TSCameraCapturePhaseIdle || self.phase == TSCameraCapturePhaseSaveFailed) {
        self.sessionReady = NO;
        dispatch_async(self.captureQueue, ^{ [self.captureSession stopRunning]; });
    }
    [self refreshUI];
}

// 返回前台重新检查系统权限，并按当前连接恢复独立预览。
- (void)appDidBecomeActive:(NSNotification *)notification {
    self.captureAllowed = !self.mediaPreviewPresented;
    self.cameraAuthorized = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] ==
        AVAuthorizationStatusAuthorized;
    [self applyConnectionSnapshot:TSDeviceCoordinator.sharedInstance.snapshot];
    [self continueRecordingPreparation];
    [self resumeCaptureIfPossible];
    [self refreshUI];
}

// 电话或其他采集占用导致中断时明确显示状态并先完成录像。
- (void)captureWasInterrupted:(NSNotification *)notification {
    if (notification.object != self.captureSession || self.mediaPreviewPresented) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopPreviewWithCompletion:nil];
        self.captureAllowed = NO;
        self.sessionReady = NO;
        if (self.phase == TSCameraCapturePhaseRecording || self.phase == TSCameraCapturePhasePreparingRecording) {
            self.returnToPhoto = YES;
            [self stopRecordingFromDevice:NO];
        }
        [self ts_showToast:@"相机被系统中断，已暂停取景并保留作品"];
        [self refreshUI];
    });
}

// 中断结束后复用授权、会话与设备就绪检查。
- (void)captureInterruptionEnded:(NSNotification *)notification {
    if (notification.object == self.captureSession) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.captureAllowed = !self.mediaPreviewPresented &&
                UIApplication.sharedApplication.applicationState == UIApplicationStateActive;
            [self resumeCaptureIfPossible];
        });
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

// 所有帧都来自已设为竖屏、不镜像的输出连接。
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    if (!self.previewFramesAvailable && self.previewPixelFormatSupported && self.captureAllowed && connection.isActive) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.previewFramesAvailable = self.previewPixelFormatSupported &&
                [self canFeedPreviewInVideoMode:self.videoMode connectionActive:YES];
            [self refreshUI];
            [self ensureDeviceCameraEntered];
        });
    }
    if (self.streaming) {
        [self.cameraService sendVideoPreviewSampleBuffer:sampleBuffer isBack:self.backCamera];
    }
}

#pragma mark - AVCapturePhotoCaptureDelegate

// 拍照失败回到就绪，成功先持久化原始数据再保存。
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo
                error:(NSError *)error API_AVAILABLE(ios(11.0)) {
    NSData *data = error ? nil : [photo fileDataRepresentation];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!data.length) {
            self.phase = TSCameraCapturePhaseIdle;
            self.pendingPhotoNotification = NO;
            [self reportError:error fallback:@"拍照失败，未取得照片数据"];
            [self refreshUI];
            [self finishPendingTransition];
            self.mediaOperationRetainer = nil;
            return;
        }
        self.flashOverlay.alpha = 0.85;
        [UIView animateWithDuration:0.2 animations:^{ self.flashOverlay.alpha = 0; }];
        AudioServicesPlaySystemSound(1108);
        [self persistPhotoData:data];
    });
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

// 真正开始回调后才计时；已排队的停止立即收尾，不重配输出。
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
      fromConnections:(NSArray<AVCaptureConnection *> *)connections {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.phase = TSCameraCapturePhaseRecording;
        self.recordingStartedAt = NSProcessInfo.processInfo.systemUptime;
        [self.recordTimer invalidate];
        __weak typeof(self) weakSelf = self;
        self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 repeats:YES block:^(NSTimer *timer) {
            [weakSelf updateRecordingTimer];
        }];
        [self updateRecordingTimer];
        [self notifyRecordingStartedIfCurrent];
        [self refreshUI];
        if (self.recordingStopRequested || self.closeRequested || !self.deviceReady ||
            UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
            BOOL fromDevice = self.recordingStopRequested ? self.stopFromDevice : self.closeFromDevice;
            self.recordingStopRequested = NO;
            [self stopRecordingFromDevice:fromDevice];
        }
    });
}

// 非致命错误可能仍生成完整录像，使用系统标记判断，失败原文件不删除。
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)fileURL
      fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error {
    BOOL finished = error == nil || [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfItemAtPath:fileURL.path error:nil];
    BOOL hasFile = [attributes[NSFileSize] unsignedLongLongValue] > 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recordTimer invalidate];
        self.recordTimer = nil;
        self.pendingMediaURL = hasFile ? fileURL : nil;
        self.recentMediaURL = hasFile ? fileURL : self.recentMediaURL;
        self.recentMediaSaved = hasFile ? NO : self.recentMediaSaved;
        if (hasFile) {
            [self updateThumbnailForURL:fileURL];
        }
        if (finished && hasFile) {
            [self savePendingMedia];
        } else if (hasFile) {
            [self mediaSaveFailed:error ?: [self captureErrorWithDescription:@"视频未完整完成，文件已保留"]];
        } else {
            self.phase = TSCameraCapturePhaseIdle;
            [self reportError:error fallback:@"未生成可用录像文件"];
            [self refreshUI];
            [self endMediaBackgroundTask];
            [self finishPendingTransition];
            self.mediaOperationRetainer = nil;
        }
    });
}

#pragma mark - 属性懒加载

// 采集操作和采样回调共用一个串行队列，避免重绑与拍摄并发。
- (dispatch_queue_t)captureQueue {
    if (!_captureQueue) {
        _captureQueue = dispatch_queue_create("com.topstep.demo.camera.capture", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}

@end
