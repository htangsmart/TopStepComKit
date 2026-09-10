//
//  TSDialEditorVC.m
//  TopStepComKit_Example
//

#import "TSDialEditorVC.h"
#import <AVFoundation/AVFoundation.h>
#import <PhotosUI/PhotosUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import <QuartzCore/QuartzCore.h>
#import <TopStepComKit/TopStepComKit.h>
#import "TSDialEditorState.h"
#import "TSDialEditorAppearance.h"
#import "TSDialPreviewView.h"
#import "TSDialTimeStyleView.h"
#import "TSDialTimePositionView.h"
#import "TSDialMaterialView.h"
#import "TSDialDanMuView.h"
#import "TSDialImageCropVC.h"
#import "TSDialColorPickerVC.h"
#import "TSDialEditorSheet.h"

typedef NS_ENUM(NSInteger, TSDialEditorInstallPhase) {
    TSDialEditorInstallPhaseIdle,
    TSDialEditorInstallPhasePreparing,
    TSDialEditorInstallPhaseBuilding,
    TSDialEditorInstallPhaseInstalling,
    TSDialEditorInstallPhaseSelecting,
    TSDialEditorInstallPhaseFailed,
    TSDialEditorInstallPhaseSucceeded
};

@interface TSDialEditorVC () <PHPickerViewControllerDelegate, UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate, UIDocumentPickerDelegate>
// 编辑草稿、设备与样式约束。
@property (nonatomic, strong) TSDialEditorState *editorState;
@property (nonatomic, strong) TSPeripheral *constraintPeripheral;
@property (nonatomic, strong) TSPeripheralScreen *screen;
@property (nonatomic, strong) TSDialCapability *capability;
@property (nonatomic, strong) TSCustomDialStyleConstraint *styleConstraint;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *styleImages;
@property (nonatomic, strong) NSURLSessionDataTask *styleImageTask;
@property (nonatomic, assign) NSUInteger constraintGeneration;
@property (nonatomic, assign) BOOL loadingConstraint;
@property (nonatomic, assign) BOOL editorReady;
// 固定导航、预览、操作与中间滚动区。
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) TSDialPreviewView *previewView;
@property (nonatomic, strong) UIScrollView *editorScroll;
@property (nonatomic, strong) TSDialMaterialView *materialView;
@property (nonatomic, strong) TSDialDanMuView *danMuView;
@property (nonatomic, strong) TSDialTimeStyleView *timeStyleView;
@property (nonatomic, strong) TSDialTimePositionView *timePositionView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *installButton;
@property (nonatomic, strong) UILabel *loadingLabel;
// 当前选择器与异步素材读取。
@property (nonatomic, assign) BOOL appendPhotos;
@property (nonatomic, assign) BOOL pickingVideo;
@property (nonatomic, assign) NSUInteger mediaGeneration;
@property (nonatomic, copy) NSArray<UIImage *> *videoThumbnails;
// 安装面板和资源生命周期。
@property (nonatomic, strong) TSDialEditorSheet *sheet;
// 进度轨道：制作时显示循环光带，传输时按 SDK 百分比填充。
@property (nonatomic, strong) UIView *progressTrack;
@property (nonatomic, strong) UIView *progressFill;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *progressHintLabel;
@property (nonatomic, assign) NSInteger displayedInstallProgress;
@property (nonatomic, strong) TSDialArtifact *builtArtifact;
@property (nonatomic, strong) TSDialArtifact *installedArtifact;
// 安装时冻结完成语义，Fit 的成功回调已包含槽位激活。
@property (nonatomic, assign) BOOL installationActivatesDial;
// 从设备读取的已安装标识，与造包产物标识分开保存。
@property (nonatomic, copy) NSString *installedDeviceDialId;
@property (nonatomic, strong) UIImage *installationPreview;
// 本次安装的冻结快照。
@property (nonatomic, strong) TSDialEditorState *installationState;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) NSURL *exportedVideoURL;
// GIF 的设备尺寸副本，只在本次造包期间持有。
@property (nonatomic, copy) NSArray<NSURL *> *preparedGIFURLs;
@property (nonatomic, assign) TSDialEditorInstallPhase installPhase;
@property (nonatomic, assign) NSUInteger installGeneration;
@property (nonatomic, assign) BOOL cancellationRequested;
@property (nonatomic, assign) BOOL savingDraft;
// 页面状态恢复。
@property (nonatomic, assign) BOOL previousNavigationHidden;
@property (nonatomic, assign) CGFloat keyboardHeight;
@end

@implementation TSDialEditorVC

#pragma mark - 生命周期

// 类型由外部确定，编辑器内部没有类型切换栏。
- (instancetype)initWithState:(TSDialEditorState *)state {
    self = [super init];
    if (self) {
        _editorState = state;
    }
    return self;
}

// 保留现有单图调用方的兼容入口。
- (instancetype)initWithImage:(UIImage *)image dialSize:(CGSize)dialSize {
    TSDialEditorState *state = [TSDialEditorState stateForType:TSDialDraftTypeSingleImage];
    state.images = @[@{@"name":@"照片", @"image":image, @"source":image}];
    state.screenSize = dialSize;
    return [self initWithState:state];
}

// 保留现有视频调用方，文件仍会在安装前按设备尺寸导出。
- (instancetype)initWithVideoURL:(NSURL *)videoURL dialSize:(CGSize)dialSize {
    TSDialEditorState *state = [TSDialEditorState stateForType:TSDialDraftTypeVideo];
    state.videoURL = videoURL;
    state.videoName = videoURL.lastPathComponent;
    state.videoDuration = CMTimeGetSeconds([AVURLAsset assetWithURL:videoURL].duration);
    state.videoStart = 0;
    state.videoEnd = state.videoDuration;
    state.screenSize = dialSize;
    return [self initWithState:state];
}

// 保存的类型状态与设备读取状态分开。
- (void)initData {
    [super initData];
    self.styleImages = [NSMutableDictionary dictionary];
    self.videoThumbnails = @[];
    self.screen = [TopStepComKit sharedInstance].connectedPeripheral.screenInfo;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(suspendPreview)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumePreview)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

// 自有导航栏匹配原型高度与字体。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.previousNavigationHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

// 系统页面关闭后恢复预览，换设备必须重新读取约束。
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.constraintPeripheral != [TopStepComKit sharedInstance].connectedPeripheral && ![self isInstalling]) {
        [self loadStyleConstraint];
    }
    [self resumePreview];
}

// 暂停播放器，但保留用户的播放或暂停选择。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.previewView suspend];
    [self.navigationController setNavigationBarHidden:self.previousNavigationHidden animated:animated];
}

// 执行手动布局。
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

// 移除下载、通知和无主播放器资源。
- (void)dealloc {
    [_styleImageTask cancel];
    [_exportSession cancelExport];
    [_previewView suspend];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 公开方法

// 三个共用 View 与素材 View 由一个 VC 编排。
- (void)setupViews {
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    self.view.backgroundColor = [TSDialEditorAppearance color:0xF6F5F2];
    [self.view addSubview:self.headerView];
    [self.headerView addSubview:self.titleLabel];
    [self.headerView addSubview:self.backButton];
    [self.view addSubview:self.previewView];
    [self.view addSubview:self.editorScroll];
    for (UIView *view in @[self.materialView, self.danMuView, self.timeStyleView, self.timePositionView, self.loadingLabel]) {
        [self.editorScroll addSubview:view];
    }
    [self.view addSubview:self.footerView];
    [self.footerView addSubview:self.saveButton];
    [self.footerView addSubview:self.installButton];
    [self bindEditorEvents];
    [self renderEditor];
    [self loadStyleConstraint];
    if (self.editorState.videoURL) {
        [self loadVideoThumbnails:self.editorState.videoURL];
    }
}

// 固定预览与底栏，中间独立滚动。
- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds), height = CGRectGetHeight(self.view.bounds);
    CGFloat top = self.view.safeAreaInsets.top;
    CGFloat bottom = self.keyboardHeight > 0 ? self.keyboardHeight : self.view.safeAreaInsets.bottom;
    self.headerView.frame = CGRectMake(0, top, width, 49);
    self.titleLabel.frame = CGRectMake(82, 0, width - 164, 49);
    self.backButton.frame = CGRectMake(18, 0, 65, 49);
    CGFloat previewHeight = height <= 730 || self.keyboardHeight > 0 ? 197 : 234;
    if (self.previewView.superview == self.view) {
        self.previewView.frame = CGRectMake(0, top + 49, width, previewHeight);
    } else if (self.previewView.enlarged) {
        self.previewView.frame = self.sheet.contentView.bounds;
    }
    CGFloat footerTop = height - bottom - 67;
    self.footerView.frame = CGRectMake(0, footerTop, width, 67 + self.view.safeAreaInsets.bottom);
    self.saveButton.frame = CGRectMake(18, 12, 88, 46);
    self.installButton.frame = CGRectMake(116, 12, width - 134, 46);
    CGFloat editorTop = top + 49 + previewHeight;
    self.editorScroll.frame = CGRectMake(0, editorTop, width, MAX(0, footerTop - editorTop));
    CGFloat contentWidth = width - 40, offset = 0;
    self.materialView.frame = CGRectMake(20, offset, contentWidth, self.materialView.preferredHeight);
    offset += self.materialView.preferredHeight;
    self.danMuView.hidden = self.editorState.draftType != TSDialDraftTypeDanMu;
    if (!self.danMuView.hidden) {
        self.danMuView.frame = CGRectMake(20, offset, contentWidth, 442);
        offset += 442;
    }
    if (!self.loadingLabel.hidden) {
        self.loadingLabel.frame = CGRectMake(20, offset + 17, contentWidth, 50);
        offset += 80;
    }
    if (!self.timeStyleView.hidden) {
        self.timeStyleView.frame = CGRectMake(20, offset, contentWidth, self.timeStyleView.preferredHeight);
        offset += self.timeStyleView.preferredHeight;
    }
    if (!self.timePositionView.hidden) {
        self.timePositionView.frame = CGRectMake(20, offset, contentWidth, self.timePositionView.preferredHeight);
        offset += self.timePositionView.preferredHeight;
    }
    self.editorScroll.contentSize = CGSizeMake(width, offset + 19);
    if (self.progressTrack.superview == self.sheet.contentView && self.sheet) {
        [self.sheet setNeedsLayout];
        [self.sheet layoutIfNeeded];
        [self layoutInstallationProgress];
    }
}

#pragma mark - 私有方法

// 当前设备的真实数量和时长上限。
- (NSDictionary *)materialLimits {
    NSInteger images = self.capability.maxSlideshowImages > 0 ? MIN(10, self.capability.maxSlideshowImages) : 10;
    return @{@"maxImages":@(images), @"maxDuration":@(MAX(0, self.capability.maxVideoDuration))};
}

// 初始或结构变化时刷新各编辑模块。
- (void)renderEditor {
    NSArray *titles = @[@"照片表盘", @"相册表盘", @"视频表盘", @"弹幕表盘"];
    self.titleLabel.text = titles[self.editorState.draftType - TSDialDraftTypeSingleImage];
    [self renderMaterial];
    if (self.editorState.draftType == TSDialDraftTypeDanMu) {
        [self.danMuView configureWithState:self.editorState];
    }
    [self renderTimeControls];
    [self updatePreview];
    [self.view setNeedsLayout];
}

// 素材变更不会重建时间控件。
- (void)renderMaterial {
    [self.materialView configureWithState:self.editorState limits:[self materialLimits] thumbnails:self.videoThumbnails];
}

// 设备没有时间样式时不展示虚假选项。
- (void)renderTimeControls {
    BOOL supportsTime = self.editorReady && self.styleConstraint.styles.count > 0;
    self.timeStyleView.hidden = !supportsTime;
    self.timePositionView.hidden = !supportsTime || !self.editorState.showsTime;
    [self.timeStyleView configureWithState:self.editorState constraint:self.styleConstraint images:self.styleImages];
    [self.timePositionView configureWithState:self.editorState constraint:self.styleConstraint];
}

// 预览统一读取同一份编辑配置。
- (void)updatePreview {
    [self.previewView configureWithState:self.editorState screen:self.screen constraint:self.styleConstraint
                              timeImage:self.styleImages[@(self.editorState.timeStyle)]];
    if ((self.sheet && !self.previewView.enlarged) || self.presentedViewController || [self isInstalling]) {
        [self.previewView suspend];
    }
}

// 共用 View 的事件在宿主更新状态。
- (void)bindEditorEvents {
    __weak typeof(self) weakSelf = self;
    self.timeStyleView.onStyleSelected = ^(NSInteger style) {
        weakSelf.editorState.timeStyle = style;
        [weakSelf renderTimeControls];
        [weakSelf updatePreview];
    };
    self.timeStyleView.onColorSelected = ^(NSString *hex) {
        weakSelf.editorState.timeColor = hex;
        weakSelf.editorState.customTimeColor = NO;
        [weakSelf renderTimeControls];
        [weakSelf updatePreview];
    };
    self.timeStyleView.onCustomColorRequested = ^{ [weakSelf chooseColorForText:NO]; };
    self.timeStyleView.onVisibilityChanged = ^(BOOL visible) {
        weakSelf.editorState.showsTime = visible;
        [weakSelf renderTimeControls];
        [weakSelf updatePreview];
        [weakSelf.view setNeedsLayout];
    };
    self.timePositionView.onPositionSelected = ^(NSInteger position) {
        weakSelf.editorState.timePosition = position;
        [weakSelf renderTimeControls];
        [weakSelf updatePreview];
    };
    self.materialView.onChoosePhotos = ^(BOOL append) { [weakSelf showBackgroundsAppending:append]; };
    self.materialView.onCrop = ^{ [weakSelf cropCurrentImage]; };
    self.materialView.onSelectImage = ^(NSUInteger index) {
        weakSelf.editorState.selectedImage = index;
        weakSelf.previewView.playing = NO;
        [weakSelf renderMaterial];
        [weakSelf updatePreview];
    };
    self.materialView.onDeleteImage = ^(NSUInteger index) { [weakSelf deleteImage:index]; };
    self.materialView.onMoveImage = ^(NSInteger delta) { [weakSelf moveImage:delta]; };
    self.materialView.onIntervalChanged = ^(NSInteger seconds) { weakSelf.editorState.interval = seconds; };
    self.materialView.onChooseVideo = ^{ [weakSelf chooseVideo]; };
    self.materialView.onTrimChanged = ^(NSTimeInterval start, NSTimeInterval end) {
        weakSelf.editorState.videoStart = start;
        weakSelf.editorState.videoEnd = end;
        [weakSelf updatePreview];
    };
    self.previewView.onExpandRequested = ^{ [weakSelf showFullPreview]; };
    [self bindDanMuEvents];
}

// 弹幕输入只更新预览，保留当前键盘与光标。
- (void)bindDanMuEvents {
    __weak typeof(self) weakSelf = self;
    self.danMuView.onSelectText = ^(NSUInteger index) {
        weakSelf.editorState.selectedText = index;
        [weakSelf.danMuView configureWithState:weakSelf.editorState];
        [weakSelf updatePreview];
    };
    self.danMuView.onValueChanged = ^(NSString *key, id value) { [weakSelf updateTextValue:value key:key]; };
    self.danMuView.onAddText = ^{ [weakSelf addText]; };
    self.danMuView.onRemoveText = ^{ [weakSelf removeText]; };
    self.danMuView.onChooseColor = ^{ [weakSelf chooseColorForText:YES]; };
    self.danMuView.onChooseGIF = ^{ [weakSelf chooseGIF]; };
    self.danMuView.onRemoveGIF = ^{
        [weakSelf updateTextValue:nil key:@"gif"];
        [weakSelf.danMuView configureWithState:weakSelf.editorState];
    };
}

// 读取接口约束，每次请求用代号隔离旧设备回调。
- (void)loadStyleConstraint {
    [self.styleImageTask cancel];
    NSUInteger generation = ++self.constraintGeneration;
    self.loadingConstraint = YES;
    self.editorReady = NO;
    self.styleConstraint = nil;
    [self.styleImages removeAllObjects];
    self.constraintPeripheral = [TopStepComKit sharedInstance].connectedPeripheral;
    self.screen = self.constraintPeripheral.screenInfo;
    id<TSPeripheralDialInterface> dial = [TopStepComKit sharedInstance].dial;
    self.capability = dial.dialCapability;
    self.loadingLabel.hidden = NO;
    self.loadingLabel.text = @"正在读取设备表盘样式…";
    self.installButton.enabled = NO;
    [self renderEditor];
    if (!self.constraintPeripheral || self.screen.screenSize.width <= 0 || self.screen.screenSize.height <= 0 ||
        !self.capability.supportsCustom || !dial.isSupportCustomDialStyleConstraint) {
        [self finishStyleLoading:@"设备表盘信息不可用，请连接手表后重试"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [dial fetchCustomDialStyleConstraint:^(TSCustomDialStyleConstraint *constraint, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.constraintGeneration) {
                return;
            }
            if (error || !constraint || constraint.screenSize.width <= 0 || constraint.screenSize.height <= 0 ||
                (constraint.styles.count && !constraint.positions.count) ||
                strongSelf.constraintPeripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
                [strongSelf finishStyleLoading:error.localizedDescription ?: @"设备表盘样式不可用，请重试"];
                return;
            }
            strongSelf.styleConstraint = constraint;
            if (![strongSelf selectedStyleOption]) {
                strongSelf.editorState.timeStyle = constraint.styles.count ? constraint.styles.firstObject.style : eTSDialTimeStyleNone;
            }
            if (![strongSelf selectedPositionOption]) {
                strongSelf.editorState.timePosition = constraint.positions.firstObject.position;
            }
            [strongSelf loadStyleImageAtIndex:0 generation:generation];
        });
    }];
}

// 加载 SDK 指定的实际样式图片，不猜测本地模板路径。
- (void)loadStyleImageAtIndex:(NSUInteger)index generation:(NSUInteger)generation {
    if (index >= self.styleConstraint.styles.count) {
        [self finishStyleLoading:nil];
        return;
    }
    TSCustomDialStyleOption *option = self.styleConstraint.styles[index];
    if (!option.previewImageURL || option.size.width <= 0 || option.size.height <= 0) {
        [self finishStyleLoading:@"样式图片信息不完整，请重试"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    void (^completion)(NSData *, NSError *) = ^(NSData *data, NSError *error) {
        UIImage *image = data.length ? [UIImage imageWithData:data] : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.constraintGeneration) {
                return;
            }
            if (!image || error) {
                [strongSelf finishStyleLoading:error.localizedDescription ?: @"样式图片读取失败，请重试"];
                return;
            }
            // 样式画布使用接口精确尺寸，保留透明区域。
            UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
            format.scale = 1;
            UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:option.size format:format];
            strongSelf.styleImages[@(option.style)] = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
                [image drawInRect:(CGRect){CGPointZero, option.size}];
            }];
            [strongSelf loadStyleImageAtIndex:index + 1 generation:generation];
        });
    };
    if (option.previewImageURL.isFileURL) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfURL:option.previewImageURL options:0 error:&error];
            completion(data, error);
        });
    } else if ([option.previewImageURL.scheme.lowercaseString isEqualToString:@"https"]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:option.previewImageURL
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
        self.styleImageTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSInteger status = [response isKindOfClass:NSHTTPURLResponse.class] ? [(NSHTTPURLResponse *)response statusCode] : 0;
                completion(status >= 200 && status < 300 ? data : nil, error);
            }];
        [self.styleImageTask resume];
    } else {
        [self finishStyleLoading:@"样式图片地址不可用"];
    }
}

// 成功才开放真实安装，失败保留重试按钮。
- (void)finishStyleLoading:(NSString *)message {
    if (!message && self.constraintPeripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
        message = @"连接设备已变化，请重试";
    }
    self.loadingConstraint = NO;
    self.editorReady = message == nil;
    self.loadingLabel.hidden = message == nil;
    self.loadingLabel.text = message;
    self.installButton.enabled = YES;
    [self.installButton setTitle:message ? @"重新读取设备样式" : @"设置为当前表盘  →" forState:UIControlStateNormal];
    if (!message) {
        self.editorState.screenSize = self.styleConstraint.screenSize;
        if (self.editorState.draftType == TSDialDraftTypeVideo && self.capability.maxVideoDuration > 0) {
            self.editorState.videoEnd = MIN(self.editorState.videoEnd,
                                           self.editorState.videoStart + self.capability.maxVideoDuration);
        }
    }
    [self renderEditor];
}

// 查找真实样式标识。
- (TSCustomDialStyleOption *)selectedStyleOption {
    for (TSCustomDialStyleOption *option in self.styleConstraint.styles) {
        if (option.style == self.editorState.timeStyle) {
            return option;
        }
    }
    return nil;
}

// 查找实际设备允许的位置区域。
- (TSCustomDialPositionOption *)selectedPositionOption {
    for (TSCustomDialPositionOption *option in self.styleConstraint.positions) {
        if (option.position == self.editorState.timePosition) {
            return option;
        }
    }
    return nil;
}

// 背景库中的图片也必须先经过裁切。
- (void)showBackgroundsAppending:(BOOL)append {
    if ([self isInstalling]) {
        return;
    }
    self.appendPhotos = append;
    [self.view endEditing:YES];
    TSDialEditorSheet *sheet = [[TSDialEditorSheet alloc] init];
    sheet.title = @"选择背景";
    sheet.contentHeight = 320;
    sheet.primaryButton.hidden = YES;
    sheet.secondaryButton.hidden = YES;
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40, cardWidth = (width - 18) / 3;
    NSArray *backgrounds = [TSDialEditorState backgrounds];
    for (NSUInteger index = 0; index < backgrounds.count; index++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(index % 3 * (cardWidth + 9), index / 3 * 122, cardWidth, 113);
        button.tag = index;
        button.layer.cornerRadius = 13;
        button.clipsToBounds = YES;
        [button setImage:backgrounds[index][@"image"] forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button addTarget:self action:@selector(selectBackground:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *name = [TSDialEditorAppearance label:backgrounds[index][@"name"] size:11 color:0xFFFFFF];
        name.frame = CGRectMake(0, 86, cardWidth, 27);
        name.textAlignment = NSTextAlignmentCenter;
        name.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [button addSubview:name];
        [sheet.contentView addSubview:button];
    }
    UIButton *choose = [TSDialEditorAppearance button:@"＋ 从本机选择照片" primary:NO];
    choose.frame = CGRectMake(0, 258, width, 46);
    [choose addTarget:self action:@selector(choosePhotos) forControlEvents:UIControlEventTouchUpInside];
    [sheet.contentView addSubview:choose];
    [self presentSheet:sheet];
}

// 内置图库选择后进入同一裁切流程。
- (void)selectBackground:(UIButton *)sender {
    NSDictionary *record = [TSDialEditorState backgrounds][sender.tag];
    [self closeSheet];
    [self beginCropping:@[record] replacingCurrent:!self.appendPhotos];
}

// 照片选取由系统提供，iOS 14 支持按顺序多选。
- (void)choosePhotos {
    [self closeSheet];
    self.pickingVideo = NO;
    self.mediaGeneration++;
    if (@available(iOS 14.0, *)) {
        PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
        configuration.filter = PHPickerFilter.imagesFilter;
        NSInteger capacity = [[self materialLimits][@"maxImages"] integerValue] - (NSInteger)self.editorState.images.count;
        if (self.appendPhotos && capacity <= 0) {
            [self showMessage:@"已达到当前设备的照片数量上限"];
            return;
        }
        configuration.selectionLimit = self.appendPhotos ? capacity : 1;
        PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self presentLegacyPickerForVideo:NO];
    }
}

// 视频选择后在编辑页直接选段，不增加额外必经页面。
- (void)chooseVideo {
    self.pickingVideo = YES;
    self.mediaGeneration++;
    [self.view endEditing:YES];
    if (@available(iOS 14.0, *)) {
        PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] init];
        configuration.filter = PHPickerFilter.videosFilter;
        configuration.selectionLimit = 1;
        PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self presentLegacyPickerForVideo:YES];
    }
}

// 低版本继续支持系统照片和视频选择。
- (void)presentLegacyPickerForVideo:(BOOL)video {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self showMessage:@"当前无法打开照片图库"];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[video ? (NSString *)kUTTypeMovie : (NSString *)kUTTypeImage];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

// 再次裁切始终使用原图和上次构图。
- (void)cropCurrentImage {
    NSUInteger index = MIN(self.editorState.selectedImage, self.editorState.images.count - 1);
    [self beginCropping:@[self.editorState.images[index]] replacingCurrent:YES];
}

// 整批完成前不写入编辑状态，取消无需恢复旧图片。
- (void)beginCropping:(NSArray<NSDictionary *> *)records replacingCurrent:(BOOL)replace {
    if (!records.count || self.screen.screenSize.width <= 0 || self.screen.screenSize.height <= 0) {
        [self showMessage:@"请先读取设备屏幕尺寸"];
        return;
    }
    NSUInteger target = self.editorState.selectedImage;
    TSDialImageCropVC *crop = [[TSDialImageCropVC alloc] initWithRecords:records screen:self.screen];
    __weak typeof(self) weakSelf = self;
    crop.onCropBatchComplete = ^(NSArray<NSDictionary *> *results) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        NSMutableArray *images = [strongSelf.editorState.images mutableCopy];
        if (strongSelf.editorState.draftType == TSDialDraftTypeMultipleImage) {
            if (replace) {
                images[target] = results.firstObject;
                strongSelf.editorState.selectedImage = target;
            } else {
                NSUInteger maximum = [[strongSelf materialLimits][@"maxImages"] unsignedIntegerValue];
                if (images.count + results.count > maximum) {
                    [strongSelf showMessage:@"照片数量超过当前设备上限，请重新选择"];
                    return;
                }
                [images addObjectsFromArray:results];
                strongSelf.editorState.selectedImage = images.count - 1;
            }
            strongSelf.previewView.playing = NO;
        } else {
            images = [results mutableCopy];
            strongSelf.editorState.selectedImage = 0;
        }
        strongSelf.editorState.images = images;
        [strongSelf dismissViewControllerAnimated:YES completion:^{
            [strongSelf renderMaterial];
            [strongSelf updatePreview];
        }];
    };
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:crop];
    navigation.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigation animated:YES completion:nil];
}

// 至少保留一张，不修改其他照片设置。
- (void)deleteImage:(NSUInteger)index {
    if (self.editorState.images.count <= 1) {
        [self showMessage:@"至少保留一张照片"];
        return;
    }
    NSMutableArray *images = [self.editorState.images mutableCopy];
    [images removeObjectAtIndex:index];
    self.editorState.images = images;
    self.editorState.selectedImage = MIN(self.editorState.selectedImage, images.count - 1);
    [self renderMaterial];
    [self updatePreview];
}

// 移动后仍选中同一张照片。
- (void)moveImage:(NSInteger)delta {
    NSInteger source = self.editorState.selectedImage, target = source + delta;
    if (target < 0 || target >= self.editorState.images.count) {
        return;
    }
    NSMutableArray *images = [self.editorState.images mutableCopy];
    [images exchangeObjectAtIndex:source withObjectAtIndex:target];
    self.editorState.images = images;
    self.editorState.selectedImage = target;
    self.previewView.playing = NO;
    [self renderMaterial];
    [self updatePreview];
}

// 仅修改当前弹幕，其他行独立保留。
- (void)updateTextValue:(id)value key:(NSString *)key {
    NSMutableArray *lines = [self.editorState.textItems mutableCopy];
    NSMutableDictionary *line = [lines[self.editorState.selectedText] mutableCopy];
    if (value) {
        line[key] = value;
    } else {
        [line removeObjectForKey:key];
    }
    lines[self.editorState.selectedText] = line;
    self.editorState.textItems = lines;
    [self updatePreview];
}

// 原型最多三条弹幕，新增后选中该条。
- (void)addText {
    if (self.editorState.textItems.count >= 3) {
        return;
    }
    NSMutableArray *lines = [self.editorState.textItems mutableCopy];
    NSMutableDictionary *line = [[TSDialEditorState defaultText] mutableCopy];
    line[@"text"] = @"今天也要开心呀";
    line[@"size"] = @20;
    line[@"position"] = lines.count == 1 ? @73 : @45;
    [lines addObject:line];
    self.editorState.textItems = lines;
    self.editorState.selectedText = lines.count - 1;
    [self.danMuView configureWithState:self.editorState];
    [self updatePreview];
}

// 至少保留一条弹幕。
- (void)removeText {
    if (self.editorState.textItems.count <= 1) {
        return;
    }
    NSMutableArray *lines = [self.editorState.textItems mutableCopy];
    [lines removeObjectAtIndex:self.editorState.selectedText];
    self.editorState.textItems = lines;
    self.editorState.selectedText = MIN(self.editorState.selectedText, lines.count - 1);
    [self.danMuView configureWithState:self.editorState];
    [self updatePreview];
}

// 时间与弹幕颜色使用同一个选择器，确定才提交。
- (void)chooseColorForText:(BOOL)text {
    [self.view endEditing:YES];
    NSString *hex = text ? self.editorState.textItems[self.editorState.selectedText][@"color"] : self.editorState.timeColor;
    TSDialColorPickerVC *picker = [[TSDialColorPickerVC alloc]
        initWithColor:[TSDialEditorAppearance colorFromHex:hex] subtitle:text ? @"弹幕文字颜色" : @"自定义时间颜色"];
    NSUInteger selectedText = self.editorState.selectedText;
    __weak typeof(self) weakSelf = self;
    picker.onConfirm = ^(UIColor *color) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        NSString *value = [TSDialEditorAppearance hexFromColor:color];
        if (text && selectedText < strongSelf.editorState.textItems.count) {
            NSMutableArray *lines = [strongSelf.editorState.textItems mutableCopy];
            NSMutableDictionary *line = [lines[selectedText] mutableCopy];
            line[@"color"] = value;
            lines[selectedText] = line;
            strongSelf.editorState.textItems = lines;
            [strongSelf.danMuView configureWithState:strongSelf.editorState];
        } else if (!text) {
            strongSelf.editorState.timeColor = value;
            strongSelf.editorState.customTimeColor = YES;
            [strongSelf renderTimeControls];
        }
        [strongSelf updatePreview];
    };
    [self presentViewController:picker animated:YES completion:nil];
}

// GIF 保持动画原文件，不走静态背景图片的裁切管线。
- (void)chooseGIF {
    [self.view endEditing:YES];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initWithDocumentTypes:@[(NSString *)kUTTypeGIF] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

// 只有读到合法视频后才替换原视频。
- (void)acceptVideoURL:(NSURL *)url name:(NSString *)name {
    NSUInteger generation = self.mediaGeneration;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
        BOOL valid = isfinite(duration) && duration >= 0.2 && [asset tracksWithMediaType:AVMediaTypeVideo].count > 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.mediaGeneration) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                return;
            }
            if (!valid) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                [strongSelf showMessage:@"无法读取该视频，请选择其他视频"];
                return;
            }
            strongSelf.editorState.videoURL = url;
            strongSelf.editorState.videoName = name.length ? name : @"本机视频";
            strongSelf.editorState.videoDuration = duration;
            strongSelf.editorState.videoStart = 0;
            strongSelf.editorState.videoEnd = MIN(duration, MAX(0.2, strongSelf.capability.maxVideoDuration));
            strongSelf.videoThumbnails = @[];
            strongSelf.previewView.playing = YES;
            [strongSelf renderMaterial];
            [strongSelf updatePreview];
            [strongSelf loadVideoThumbnails:url];
        });
    });
}

// 从真实视频生成不同时间点的缩略帧。
- (void)loadVideoThumbnails:(NSURL *)url {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
        if (!isfinite(duration) || duration <= 0) {
            return;
        }
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = CGSizeMake(500, 500);
        NSMutableArray *frames = [NSMutableArray array];
        for (NSUInteger index = 0; index < 7; index++) {
            NSTimeInterval time = MIN(duration - 0.02, duration * index / 7);
            CGImageRef frame = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(MAX(0, time), 600)
                                               actualTime:NULL error:nil];
            if (frame) {
                [frames addObject:[UIImage imageWithCGImage:frame]];
                CGImageRelease(frame);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || ![url isEqual:strongSelf.editorState.videoURL]) {
                return;
            }
            strongSelf.videoThumbnails = frames;
            if (frames.count) {
                strongSelf.editorState.images = @[@{@"name":strongSelf.editorState.videoName,
                    @"image":frames.firstObject, @"source":frames.firstObject}];
            }
            [strongSelf renderMaterial];
            [strongSelf updatePreview];
        });
    });
}

// 草稿写入后台，当前编辑不受影响。
- (void)saveDraft {
    if (self.savingDraft) {
        return;
    }
    self.savingDraft = YES;
    self.saveButton.enabled = NO;
    TSDialEditorState *snapshot = [self.editorState copy];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSError *error = nil;
        BOOL saved = [snapshot saveWithError:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.savingDraft = NO;
            weakSelf.saveButton.enabled = ![weakSelf isInstalling];
            [weakSelf showMessage:saved ? @"草稿已保存，下次打开可继续编辑" :
             error.localizedDescription ?: @"草稿保存失败，请检查本机存储空间"];
        });
    });
}

// 统一管理底部面板及编辑区域播放暂停。
- (void)presentSheet:(TSDialEditorSheet *)sheet {
    [self closeSheet];
    self.sheet = sheet;
    [self.view endEditing:YES];
    [self.previewView suspend];
    __weak typeof(self) weakSelf = self;
    sheet.onDismiss = ^{
        weakSelf.sheet = nil;
        [weakSelf resumePreview];
    };
    [sheet showInView:self.view];
}

// 关闭面板不清理编辑草稿。
- (void)closeSheet {
    [self.sheet dismiss];
    self.sheet = nil;
}

// 放大移动同一预览 View，避免两套播放器。
- (void)showFullPreview {
    TSDialEditorSheet *sheet = [[TSDialEditorSheet alloc] init];
    sheet.title = @"表盘预览";
    sheet.contentHeight = 400;
    sheet.primaryButton.hidden = YES;
    sheet.secondaryButton.hidden = YES;
    [self presentSheet:sheet];
    [self.previewView removeFromSuperview];
    self.previewView.enlarged = YES;
    self.previewView.frame = CGRectMake(0, 0, CGRectGetWidth(sheet.contentView.bounds), 400);
    [sheet.contentView addSubview:self.previewView];
    [self.previewView resume];
    __weak typeof(self) weakSelf = self;
    sheet.onDismiss = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.previewView removeFromSuperview];
        strongSelf.previewView.enlarged = NO;
        [strongSelf.view insertSubview:strongSelf.previewView belowSubview:strongSelf.editorScroll];
        strongSelf.sheet = nil;
        [strongSelf.view setNeedsLayout];
        [strongSelf resumePreview];
    };
}

// 键盘只调整可用空间，素材和时间状态保持不变。
- (void)keyboardChanged:(NSNotification *)notification {
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect local = [self.view convertRect:frame fromView:nil];
    self.keyboardHeight = MAX(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(local));
    [self layoutViews];
    if (self.keyboardHeight > 0 && !self.danMuView.hidden) {
        CGRect textFrame = [self.editorScroll convertRect:CGRectMake(0, 85, self.danMuView.bounds.size.width, 76)
                                                 fromView:self.danMuView];
        [self.editorScroll scrollRectToVisible:textFrame animated:YES];
    }
}

// 暂停所有预览资源。
- (void)suspendPreview {
    [self.previewView suspend];
}

// 只有当前可见编辑器才恢复预览。
- (void)resumePreview {
    if (self.view.window && !self.presentedViewController && !self.sheet &&
        self.navigationController.topViewController == self) {
        [self.previewView resume];
    }
}

// 返回类型入口，安装进行中留在本页。
- (void)goBack {
    if ([self isInstalling]) {
        return;
    }
    [self closeSheet];
    [self.navigationController popViewControllerAnimated:YES];
}

// 轻量提示不阻断正常编辑。
- (void)showMessage:(NSString *)message {
    UIView *host = self.presentedViewController.view ?: self.view;
    UILabel *toast = [TSDialEditorAppearance label:message size:12 color:0xFFFFFF];
    toast.numberOfLines = 0;
    toast.textAlignment = NSTextAlignmentCenter;
    toast.backgroundColor = [TSDialEditorAppearance color:0x303C2B];
    toast.layer.cornerRadius = 12;
    toast.clipsToBounds = YES;
    CGFloat width = MIN(310, CGRectGetWidth(host.bounds) - 40);
    CGFloat height = MAX(44, [toast sizeThatFits:CGSizeMake(width - 24, 200)].height + 24);
    toast.frame = CGRectMake((CGRectGetWidth(host.bounds) - width) / 2,
                             CGRectGetHeight(host.bounds) - host.safeAreaInsets.bottom - height - 78, width, height);
    [host addSubview:toast];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast removeFromSuperview];
    });
}

// 是否存在尚未结束的真实安装任务。
- (BOOL)isInstalling {
    return self.installPhase == TSDialEditorInstallPhasePreparing ||
        self.installPhase == TSDialEditorInstallPhaseBuilding ||
        self.installPhase == TSDialEditorInstallPhaseInstalling ||
        self.installPhase == TSDialEditorInstallPhaseSelecting;
}

// 安装前重新核对连接和类型能力，不用失败试探设备能力。
- (NSString *)installationValidationMessage {
    TSPeripheral *peripheral = [TopStepComKit sharedInstance].connectedPeripheral;
    if (!peripheral || peripheral != self.constraintPeripheral) {
        return @"设备连接已变化，请重新读取设备样式";
    }
    TSDialCapability *capability = [[TopStepComKit sharedInstance].dial dialCapability];
    if (!self.editorReady || !capability.supportsCustom) {
        return @"当前设备不支持制作此表盘";
    }
    TSDialEditorState *state = self.editorState;
    if (state.draftType != TSDialDraftTypeVideo && !state.images.count) {
        return @"请先选择并裁切表盘背景";
    }
    if ((state.draftType == TSDialDraftTypeSingleImage || state.draftType == TSDialDraftTypeDanMu) &&
        state.images.count != 1) {
        return @"当前类型需要一张表盘背景，请重新选择";
    }
    if (state.draftType == TSDialDraftTypeMultipleImage) {
        NSInteger maximum = capability.maxSlideshowImages > 0 ? MIN(10, capability.maxSlideshowImages) : 10;
        if (!capability.supportsSlideshow || state.images.count == 0 || state.images.count > maximum) {
            return [NSString stringWithFormat:@"当前设备的多图表盘最多支持 %ld 张照片", (long)maximum];
        }
    } else if (state.draftType == TSDialDraftTypeVideo) {
        if (!capability.supportsVideo || capability.maxVideoDuration <= 0) {
            return @"当前设备不支持视频表盘";
        }
        if (!state.videoURL || ![[NSFileManager defaultManager] fileExistsAtPath:state.videoURL.path]) {
            return @"请先选择本机视频";
        }
        NSTimeInterval duration = state.videoEnd - state.videoStart;
        if (!isfinite(duration) || duration < 0.199 || duration > capability.maxVideoDuration + 0.001 ||
            state.videoStart < 0 || state.videoEnd > state.videoDuration + 0.001) {
            return [NSString stringWithFormat:@"请将视频片段调整到 %.1f 秒以内", (double)capability.maxVideoDuration];
        }
    } else if (state.draftType == TSDialDraftTypeDanMu) {
        if (!capability.supportsDanMu) {
            return @"当前设备不支持弹幕表盘";
        }
        if (state.textItems.count == 0 || state.textItems.count > 3) {
            return @"请保留 1～3 条弹幕";
        }
        for (NSDictionary *line in state.textItems) {
            NSString *text = [line[@"text"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
            if (!text.length || text.length > 40) {
                return @"请填写每条弹幕的文字，最多 40 个字符";
            }
            NSString *gif = line[@"gif"];
            if (gif.length && ![[NSFileManager defaultManager] fileExistsAtPath:gif]) {
                return @"关联 GIF 已失效，请重新选择";
            }
        }
    }
    return nil;
}

// 主按钮先展示摘要确认，不直接开始传输。
- (void)confirmInstallation {
    [self.view endEditing:YES];
    if (self.loadingConstraint || [self isInstalling]) {
        return;
    }
    if (!self.editorReady || self.constraintPeripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
        [self loadStyleConstraint];
        return;
    }
    NSString *message = [self installationValidationMessage];
    if (message) {
        [self showMessage:message];
        return;
    }
    TSDialEditorSheet *sheet = [[TSDialEditorSheet alloc] init];
    sheet.title = @"安装表盘";
    sheet.contentHeight = 172;
    [sheet.primaryButton setTitle:@"开始安装" forState:UIControlStateNormal];
    [sheet.secondaryButton setTitle:@"返回编辑" forState:UIControlStateNormal];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    UIView *summary = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 108)];
    summary.backgroundColor = [TSDialEditorAppearance color:0xF5F6F0];
    summary.layer.cornerRadius = 14;
    UIImageView *image = [[UIImageView alloc] initWithImage:self.editorState.images.firstObject[@"image"]];
    image.contentMode = UIViewContentModeScaleAspectFill;
    image.clipsToBounds = YES;
    image.layer.cornerRadius = 9;
    image.frame = CGRectMake(15, 15, 56, 77);
    [summary addSubview:image];
    UILabel *title = [TSDialEditorAppearance label:self.titleLabel.text size:13 color:0x252823];
    title.frame = CGRectMake(86, 18, width - 100, 24);
    UILabel *detail = [TSDialEditorAppearance label:@"将制作表盘并传输到手表\n安装期间请保持设备连接" size:11 color:0x8F9B81];
    detail.numberOfLines = 2;
    detail.frame = CGRectMake(86, 47, width - 100, 44);
    [summary addSubview:title];
    [summary addSubview:detail];
    [sheet.contentView addSubview:summary];
    UILabel *hint = [TSDialEditorAppearance label:@"安装不会清空当前编辑内容，可随时保存草稿。" size:11 color:0x959B8B];
    hint.numberOfLines = 2;
    hint.frame = CGRectMake(0, 121, width, 40);
    [sheet.contentView addSubview:hint];
    __weak typeof(self) weakSelf = self;
    sheet.onSecondary = ^{ [weakSelf closeSheet]; };
    sheet.onPrimary = ^{ [weakSelf startInstallation]; };
    [self presentSheet:sheet];
}

// 制作、造包、传输与设置各阶段由实际回调推进。
- (void)startInstallation {
    NSString *message = [self installationValidationMessage];
    if (message) {
        [self showMessage:message];
        return;
    }
    self.installationState = [self.editorState copy];
    self.installGeneration++;
    self.installPhase = TSDialEditorInstallPhasePreparing;
    self.cancellationRequested = NO;
    self.builtArtifact = nil;
    self.installedArtifact = nil;
    self.installationActivatesDial = [TopStepComKit sharedInstance].kitOption.sdkType == eTSSDKTypeFIT;
    self.installedDeviceDialId = nil;
    [self updateInstallationInteraction];
    [self showInstallationProgress:@"正在准备表盘素材…" progress:-1];
    NSUInteger generation = self.installGeneration;
    __weak typeof(self) weakSelf = self;
    if (self.installationState.draftType == TSDialDraftTypeVideo) {
        [self exportVideoForState:self.installationState completion:^(NSURL *url, NSError *error) {
            if (generation != weakSelf.installGeneration) {
                return;
            }
            if (weakSelf.cancellationRequested) {
                if (url) {
                    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                }
                [weakSelf finishCancellation];
            } else if (error || !url) {
                [weakSelf failInstallation:error.localizedDescription ?: @"视频处理失败，请重新选择"];
            } else {
                weakSelf.exportedVideoURL = url;
                [weakSelf buildInstallationDraftWithVideoURL:url];
            }
        }];
    } else if (self.installationState.draftType == TSDialDraftTypeDanMu) {
        [self prepareDanMuAnimations];
    } else {
        [self buildInstallationDraftWithVideoURL:nil];
    }
}

// 保留原 GIF，按预览中 45 点的视觉比例生成设备像素副本。
- (void)prepareDanMuAnimations {
    TSDialEditorState *state = self.installationState;
    NSUInteger generation = self.installGeneration;
    CGFloat reference = self.screen.shape == eTSPeriphShapeCircle ? 252 : 217;
    CGFloat side = MAX(1, round(45 * self.styleConstraint.screenSize.width / reference));
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSMutableArray<NSURL *> *outputs = [NSMutableArray array];
        NSMutableArray<NSDictionary *> *lines = [NSMutableArray array];
        BOOL failed = NO;
        for (NSDictionary *line in state.textItems) {
            NSMutableDictionary *prepared = [line mutableCopy];
            NSString *path = line[@"gif"];
            if (path.length) {
                NSURL *url = [self resizeGIFAtPath:path side:side];
                if (!url) {
                    failed = YES;
                    break;
                }
                prepared[@"gif"] = url.path;
                [outputs addObject:url];
            }
            [lines addObject:prepared];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != self.installGeneration) {
                for (NSURL *url in outputs) {
                    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                }
                return;
            }
            self.preparedGIFURLs = outputs;
            if (self.cancellationRequested) {
                [self finishCancellation];
            } else if (failed) {
                [self failInstallation:@"GIF 处理失败，请重新选择动画"];
            } else {
                state.textItems = lines;
                [self buildInstallationDraftWithVideoURL:nil];
            }
        });
    });
}

// 逐帧等比缩放并保留帧时长，透明留白与预览的 aspect-fit 一致。
- (NSURL *)resizeGIFAtPath:(NSString *)path side:(CGFloat)side {
    NSURL *sourceURL = [NSURL fileURLWithPath:path];
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)sourceURL, NULL);
    size_t count = source ? CGImageSourceGetCount(source) : 0;
    if (!count) {
        if (source) {
            CFRelease(source);
        }
        return nil;
    }
    NSString *name = [NSString stringWithFormat:@"ts-dial-%@.gif", NSUUID.UUID.UUIDString];
    NSURL *output = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)output, kUTTypeGIF, count, NULL);
    if (!destination) {
        CFRelease(source);
        return nil;
    }
    NSDictionary *loop = @{(NSString *)kCGImagePropertyGIFDictionary:@{(NSString *)kCGImagePropertyGIFLoopCount:@0}};
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)loop);
    BOOL valid = YES;
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = 1;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(side, side) format:format];
    for (NSUInteger index = 0; index < count; index++) {
        @autoreleasepool {
            NSDictionary *options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways:@YES,
                                       (NSString *)kCGImageSourceThumbnailMaxPixelSize:@(side)};
            CGImageRef frame = CGImageSourceCreateThumbnailAtIndex(source, index, (__bridge CFDictionaryRef)options);
            if (!frame) {
                valid = NO;
                break;
            }
            UIImage *image = [UIImage imageWithCGImage:frame];
            CGFloat scale = MIN(side / image.size.width, side / image.size.height);
            CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
            UIImage *resized = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
                [image drawInRect:CGRectMake((side - size.width) / 2, (side - size.height) / 2, size.width, size.height)];
            }];
            NSDictionary *properties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, index, NULL));
            NSDictionary *timing = properties[(NSString *)kCGImagePropertyGIFDictionary] ?:
                @{(NSString *)kCGImagePropertyGIFDelayTime:@0.1};
            NSDictionary *frameProperties = @{(NSString *)kCGImagePropertyGIFDictionary:timing};
            CGImageDestinationAddImage(destination, resized.CGImage, (__bridge CFDictionaryRef)frameProperties);
            CGImageRelease(frame);
        }
    }
    valid = valid && CGImageDestinationFinalize(destination);
    CFRelease(destination);
    CFRelease(source);
    if (!valid) {
        [[NSFileManager defaultManager] removeItemAtURL:output error:nil];
    }
    return valid ? output : nil;
}

// 导出所选片段，先应用视频方向，再等比填满设备像素画布。
- (void)exportVideoForState:(TSDialEditorState *)state
                completion:(void (^)(NSURL *url, NSError *error))completion {
    AVURLAsset *asset = [AVURLAsset assetWithURL:state.videoURL];
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    CGSize target = self.styleConstraint.screenSize;
    if (!track || target.width <= 0 || target.height <= 0) {
        completion(nil, [self editorError:@"视频轨道或设备尺寸不可用"]);
        return;
    }
    CMTimeRange range = CMTimeRangeMake(CMTimeMakeWithSeconds(state.videoStart, 600),
                                        CMTimeMakeWithSeconds(state.videoEnd - state.videoStart, 600));
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *destination = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                     preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError *error = nil;
    if (![destination insertTimeRange:range ofTrack:track atTime:kCMTimeZero error:&error]) {
        completion(nil, error);
        return;
    }
    CGRect rotated = CGRectApplyAffineTransform((CGRect){CGPointZero, track.naturalSize}, track.preferredTransform);
    CGFloat scale = MAX(target.width / CGRectGetWidth(rotated), target.height / CGRectGetHeight(rotated));
    CGAffineTransform transform = track.preferredTransform;
    transform.tx -= CGRectGetMinX(rotated);
    transform.ty -= CGRectGetMinY(rotated);
    transform.a *= scale;
    transform.b *= scale;
    transform.c *= scale;
    transform.d *= scale;
    transform.tx = transform.tx * scale + (target.width - CGRectGetWidth(rotated) * scale) / 2;
    transform.ty = transform.ty * scale + (target.height - CGRectGetHeight(rotated) * scale) / 2;
    AVMutableVideoCompositionLayerInstruction *layer = [AVMutableVideoCompositionLayerInstruction
                                                       videoCompositionLayerInstructionWithAssetTrack:destination];
    [layer setTransform:transform atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, range.duration);
    instruction.layerInstructions = @[layer];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = target;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.instructions = @[instruction];
    NSString *name = [NSString stringWithFormat:@"ts-dial-%@.mp4", NSUUID.UUID.UUIDString];
    NSURL *output = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    if (!session) {
        completion(nil, [self editorError:@"无法创建视频导出任务"]);
        return;
    }
    self.exportSession = session;
    session.outputURL = output;
    session.outputFileType = AVFileTypeMPEG4;
    session.videoComposition = videoComposition;
    __weak typeof(self) weakSelf = self;
    [session exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.exportSession = nil;
            if (session.status == AVAssetExportSessionStatusCompleted) {
                completion(output, nil);
            } else {
                [[NSFileManager defaultManager] removeItemAtURL:output error:nil];
                completion(nil, session.error ?: [weakSelf editorError:@"视频导出已取消"]);
            }
        });
    }];
}

// 统一编辑器错误，不吞掉资源准备失败。
- (NSError *)editorError:(NSString *)message {
    return [NSError errorWithDomain:@"TSDialEditorErrorDomain" code:1002
                            userInfo:@{NSLocalizedDescriptionKey:message}];
}

// 时间模型使用明确设备像素区域；弹幕隐藏时间时可以为 nil。
- (TSDialTime *)installationTime {
    TSDialEditorState *state = self.installationState;
    if (state.draftType == TSDialDraftTypeDanMu && !state.showsTime) {
        return nil;
    }
    TSCustomDialStyleOption *style = [self selectedStyleOption];
    TSCustomDialPositionOption *position = [self selectedPositionOption];
    return [[TSDialTime alloc] initWithTimeImage:style ? self.styleImages[@(style.style)] : nil
                                 timeImagePath:nil timePosition:state.timePosition
                                      timeRect:style ? position.frame : CGRectZero
                                     timeColor:style && self.styleConstraint.allowColorTint ?
                 [TSDialEditorAppearance colorFromHex:state.timeColor] : nil
                                         style:style ? style.style : eTSDialTimeStyleNone];
}

// App 将文字颜色、字体转为透明图片，再交给统一弹幕模型。
- (NSArray<TSDialDanMuItem *> *)installationDanMuItems {
    NSMutableArray *items = [NSMutableArray array];
    CGSize screenSize = self.styleConstraint.screenSize;
    CGFloat referenceWidth = self.screen.shape == eTSPeriphShapeCircle ? 252 : 217;
    CGFloat scale = screenSize.width / referenceWidth;
    for (NSDictionary *line in self.installationState.textItems) {
        UIFont *font = [UIFont systemFontOfSize:[line[@"size"] doubleValue] * scale weight:UIFontWeightBold];
        NSDictionary *attributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:[TSDialEditorAppearance colorFromHex:line[@"color"]]};
        CGSize measured = [line[@"text"] sizeWithAttributes:attributes];
        CGSize size = CGSizeMake(MAX(1, ceil(measured.width)), MAX(1, ceil(measured.height)));
        UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
        format.scale = 1;
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [line[@"text"] drawAtPoint:CGPointZero withAttributes:attributes];
        }];
        TSDialDanMuItem *item = [[TSDialDanMuItem alloc] initWithImage:image];
        item.imageX = TSDialDanMuCoordinateMake(TSDialDanMuAnchorStart, 0);
        item.imageY = TSDialDanMuCoordinateMake(TSDialDanMuAnchorAbsolute,
                                               lround(screenSize.height * [line[@"position"] doubleValue] / 100));
        item.walkSpeed = [line[@"speed"] doubleValue] * scale;
        item.leftToRight = [line[@"right"] boolValue];
        item.animationFilePath = line[@"gif"];
        item.animationX = TSDialDanMuCoordinateMake(TSDialDanMuAnchorCenter, 0);
        item.animationY = TSDialDanMuCoordinateMake(TSDialDanMuAnchorCenter, 0);
        [items addObject:item];
    }
    return items;
}

// 按四种草稿类型装配，图片不重复烘焙时间层。
- (TSDialDraft *)installationDraftWithVideoURL:(NSURL *)videoURL {
    TSDialEditorState *state = self.installationState;
    TSDialTime *time = [self installationTime];
    NSMutableArray<TSDialDraftItem *> *items = [NSMutableArray array];
    if (state.draftType == TSDialDraftTypeVideo) {
        [items addObject:[TSDialDraftItem itemWithVideoFilePath:videoURL.path time:time]];
    } else {
        for (NSDictionary *record in state.images) {
            UIImage *image = [TSDialEditorAppearance fillImage:record[@"image"] size:self.styleConstraint.screenSize];
            TSDialDraftItem *item = [TSDialDraftItem itemWithImage:image time:time];
            if (state.draftType == TSDialDraftTypeDanMu) {
                item.danMuItems = [self installationDanMuItems];
            }
            [items addObject:item];
        }
    }
    TSDialDraft *draft = [[TSDialDraft alloc] initWithDraftType:state.draftType templateFilePath:nil items:items];
    if (state.draftType == TSDialDraftTypeMultipleImage) {
        draft.multiplePlayIntervalMillis = state.interval * 1000;
    }
    self.installationPreview = [self composeInstallationPreview:draft videoURL:videoURL];
    if (CGSizeEqualToSize(self.installationPreview.size, self.screen.dialPreviewSize)) {
        draft.previewImage = self.installationPreview;
    }
    return draft;
}

// 预览图严格使用 dialPreviewSize，视频取导出片段首帧。
- (UIImage *)composeInstallationPreview:(TSDialDraft *)draft videoURL:(NSURL *)videoURL {
    CGSize output = self.screen.dialPreviewSize;
    if (output.width <= 0 || output.height <= 0) {
        output = self.styleConstraint.screenSize;
    }
    UIImage *background = draft.items.firstObject.image;
    if (videoURL) {
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVURLAsset assetWithURL:videoURL]];
        generator.appliesPreferredTrackTransform = YES;
        CGImageRef image = [generator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
        if (image) {
            background = [UIImage imageWithCGImage:image];
            CGImageRelease(image);
        }
    }
    if (!background) {
        return nil;
    }
    TSDialTime *time = draft.items.firstObject.time;
    CGSize screen = self.styleConstraint.screenSize;
    CGFloat horizontal = output.width / screen.width, vertical = output.height / screen.height;
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = 1;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:output format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [background drawInRect:(CGRect){CGPointZero, output}];
        CGRect frame = time.timeRect;
        frame = CGRectMake(frame.origin.x * horizontal, frame.origin.y * vertical,
                           frame.size.width * horizontal, frame.size.height * vertical);
        if (time.timeImage) {
            CGContextBeginTransparencyLayer(context.CGContext, NULL);
            [time.timeImage drawInRect:frame];
            if (time.timeColor) {
                [time.timeColor setFill];
                UIRectFillUsingBlendMode(frame, kCGBlendModeSourceIn);
            }
            CGContextEndTransparencyLayer(context.CGContext);
        }
        for (TSDialDanMuItem *item in draft.items.firstObject.danMuItems) {
            [item.image drawInRect:CGRectMake(0, item.imageY.offset * vertical,
                                             item.image.size.width * horizontal, item.image.size.height * vertical)];
            if (item.animationFilePath.length) {
                UIImage *animation = [UIImage imageWithContentsOfFile:item.animationFilePath];
                CGSize size = CGSizeMake(animation.size.width * horizontal, animation.size.height * vertical);
                [animation drawInRect:CGRectMake((output.width - size.width) / 2, (output.height - size.height) / 2,
                                                 size.width, size.height)];
            }
        }
    }];
}

// 造包回调结束后才允许安装，并隔离已经取消或过期的任务。
- (void)buildInstallationDraftWithVideoURL:(NSURL *)url {
    if (self.cancellationRequested) {
        [self finishCancellation];
        return;
    }
    TSDialDraft *draft = [self installationDraftWithVideoURL:url];
    self.installPhase = TSDialEditorInstallPhaseBuilding;
    [self showInstallationProgress:@"正在制作表盘…" progress:-1];
    NSUInteger generation = self.installGeneration;
    id<TSPeripheralDialInterface> dial = [TopStepComKit sharedInstance].dial;
    __weak typeof(self) weakSelf = self;
    [dial buildDialWithDraft:draft completion:^(TSDialArtifact *artifact, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.installGeneration) {
                return;
            }
            if (strongSelf.cancellationRequested) {
                [strongSelf finishCancellation];
            } else if (!artifact || error) {
                [strongSelf failInstallation:error.localizedDescription ?: @"表盘制作失败，请检查素材"];
            } else if (strongSelf.constraintPeripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
                [strongSelf failInstallation:@"设备连接已变化，请返回编辑后重试"];
            } else {
                strongSelf.builtArtifact = artifact;
                [strongSelf installBuiltArtifact];
            }
        });
    }];
}

// SDK 进度只用于显示，完成回调才决定状态。
- (void)installBuiltArtifact {
    self.installPhase = TSDialEditorInstallPhaseInstalling;
    [self showInstallationProgress:@"正在传输表盘 · 0%" progress:0];
    NSUInteger generation = self.installGeneration;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial installDial:self.builtArtifact
        progressBlock:^(TSDialInstallResult result, NSInteger progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (generation != weakSelf.installGeneration ||
                    weakSelf.installPhase != TSDialEditorInstallPhaseInstalling || weakSelf.cancellationRequested) {
                    return;
                }
                NSInteger value = MAX(0, MIN(100, progress));
                [weakSelf showInstallationProgress:[NSString stringWithFormat:@"正在传输表盘 · %ld%%", (long)value]
                                          progress:value];
            });
        } completion:^(TSDialInstallResult result, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf || generation != strongSelf.installGeneration ||
                    strongSelf.installPhase != TSDialEditorInstallPhaseInstalling) {
                    return;
                }
                if (result == eTSDialInstallResultSuccess && !error) {
                    strongSelf.installedArtifact = strongSelf.builtArtifact;
                    if (strongSelf.cancellationRequested && !strongSelf.installationActivatesDial) {
                        [strongSelf failInstallation:@"取消前表盘已完成安装，可继续设置为当前表盘"];
                    } else {
                        [strongSelf selectInstalledArtifact];
                    }
                } else if (strongSelf.cancellationRequested) {
                    [strongSelf finishCancellation];
                } else {
                    [strongSelf failInstallation:error.localizedDescription ?: @"安装未成功完成，请重试"];
                }
            });
        }];
}

// 按安装完成语义处理，Fit 已在 SDK 内按真实槽位和模块样式激活，不能再按产物 ID 切换。
- (void)selectInstalledArtifact {
    if (!self.installedArtifact || self.constraintPeripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
        [self failInstallation:@"表盘已安装，设备连接已变化，暂时无法设置为当前表盘"];
        return;
    }
    if (self.installationActivatesDial) {
        [self syncActivatedDialAndFinish];
        return;
    }
    self.installPhase = TSDialEditorInstallPhaseSelecting;
    self.cancellationRequested = NO;
    [self updateInstallationInteraction];
    [self showInstallationProgress:@"正在设置为当前表盘…" progress:-1];
    self.sheet.secondaryButton.enabled = NO;
    NSUInteger generation = self.installGeneration;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial selectDial:self.installedArtifact.dialId completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (generation != weakSelf.installGeneration || weakSelf.installPhase != TSDialEditorInstallPhaseSelecting) {
                return;
            }
            if (weakSelf.constraintPeripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
                [weakSelf failInstallation:@"设备连接已变化，请确认设备后重新设置表盘"];
            } else if (success && !error) {
                weakSelf.installedDeviceDialId = weakSelf.installedArtifact.dialId;
                [weakSelf finishInstallation];
            } else {
                [weakSelf failInstallation:error.localizedDescription ?: @"表盘已安装，设置为当前表盘失败"];
            }
        });
    }];
}

// 安装已完成激活，此查询仅补齐设备 ID；查询失败不能推翻 SDK 已确认的安装结果。
- (void)syncActivatedDialAndFinish {
    self.installPhase = TSDialEditorInstallPhaseSelecting;
    self.cancellationRequested = NO;
    [self updateInstallationInteraction];
    [self showInstallationProgress:@"正在同步表盘状态…" progress:-1];
    NSUInteger generation = self.installGeneration;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial fetchCurrentDial:^(TSDialModel *dial, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.installGeneration ||
                strongSelf.installPhase != TSDialEditorInstallPhaseSelecting) {
                return;
            }
            if (strongSelf.constraintPeripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
                [strongSelf failInstallation:@"表盘已安装，设备连接已变化，请确认当前设备"];
                return;
            }
            if (!error && dial.dialId.length && dial.dialType == strongSelf.installedArtifact.dialType) {
                strongSelf.installedDeviceDialId = dial.dialId;
            }
            [strongSelf finishInstallation];
        });
    }];
}

// 真实任务进行中防止重复安装及误返回。
- (void)updateInstallationInteraction {
    BOOL busy = [self isInstalling];
    self.editorScroll.userInteractionEnabled = !busy;
    self.backButton.enabled = !busy;
    self.installButton.enabled = !busy;
    self.saveButton.enabled = !busy && !self.savingDraft;
    self.navigationController.interactivePopGestureRecognizer.enabled = !busy;
}

// 制作、设置与取消显示动态光带；传输阶段显示 SDK 的真实百分比。
- (void)showInstallationProgress:(NSString *)message progress:(NSInteger)progress {
    if (!self.sheet) {
        TSDialEditorSheet *sheet = [[TSDialEditorSheet alloc] init];
        [self presentSheet:sheet];
    }
    self.sheet.title = self.cancellationRequested ? @"正在取消" :
        self.installPhase == TSDialEditorInstallPhaseSelecting ?
            (self.installationActivatesDial ? @"正在同步表盘" : @"正在设置表盘") :
        self.installPhase == TSDialEditorInstallPhaseInstalling ? @"正在传输表盘" : @"正在制作表盘";
    self.sheet.contentHeight = 104;
    self.sheet.allowsDismissal = NO;
    self.sheet.primaryButton.hidden = YES;
    self.sheet.secondaryButton.hidden = NO;
    self.sheet.secondaryButton.enabled = !self.cancellationRequested &&
        self.installPhase != TSDialEditorInstallPhaseSelecting;
    [self.sheet.secondaryButton setTitle:self.cancellationRequested ? @"正在取消…" : @"取消安装" forState:UIControlStateNormal];
    if (self.progressTrack.superview != self.sheet.contentView) {
        for (UIView *view in self.sheet.contentView.subviews) {
            [view removeFromSuperview];
        }
        self.progressTrack = [[UIView alloc] init];
        self.progressTrack.backgroundColor = [TSDialEditorAppearance color:0xE9EDDF];
        self.progressTrack.layer.cornerRadius = 2.5;
        self.progressTrack.clipsToBounds = YES;
        self.progressFill = [[UIView alloc] init];
        self.progressFill.backgroundColor = [TSDialEditorAppearance color:0xF16D43];
        self.progressFill.layer.cornerRadius = 2.5;
        [self.progressTrack addSubview:self.progressFill];
        self.progressLabel = [TSDialEditorAppearance label:@"" size:12 color:0x82916E];
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        self.progressLabel.numberOfLines = 2;
        self.progressLabel.isAccessibilityElement = YES;
        self.progressHintLabel = [TSDialEditorAppearance label:@"" size:11 color:0x93958E];
        self.progressHintLabel.textAlignment = NSTextAlignmentCenter;
        self.progressHintLabel.numberOfLines = 2;
        [self.sheet.contentView addSubview:self.progressTrack];
        [self.sheet.contentView addSubview:self.progressLabel];
        [self.sheet.contentView addSubview:self.progressHintLabel];
    }
    self.displayedInstallProgress = progress;
    self.progressLabel.text = message;
    self.progressHintLabel.text = self.cancellationRequested ? @"正在结束当前任务，编辑内容会保留。" :
        self.installationActivatesDial && self.installPhase == TSDialEditorInstallPhaseSelecting ?
            @"表盘已安装，正在同步设备状态。" :
        @"请保持手表连接，完成后将自动设为当前表盘。";
    __weak typeof(self) weakSelf = self;
    self.sheet.onSecondary = ^{ [weakSelf cancelInstallation]; };
    [self.sheet setNeedsLayout];
    [self.sheet layoutIfNeeded];
    [self layoutInstallationProgress];
}

// 轨道与文案按内容宽度布局，未知进度不冒充完成百分比。
- (void)layoutInstallationProgress {
    CGFloat width = CGRectGetWidth(self.sheet.contentView.bounds);
    self.progressTrack.frame = CGRectMake(0, 18, width, 5);
    self.progressLabel.frame = CGRectMake(0, 35, width, 28);
    self.progressHintLabel.frame = CGRectMake(0, 68, width, 30);
    if (width <= 0) {
        return;
    }
    NSString *animationKey = @"TSDialPreparingProgress";
    if (self.displayedInstallProgress < 0) {
        CGFloat segmentWidth = width * 0.28;
        BOOL widthChanged = fabs(CGRectGetWidth(self.progressFill.bounds) - segmentWidth) > 0.5;
        self.progressFill.frame = CGRectMake(-segmentWidth, 0, segmentWidth, 5);
        if (widthChanged || ![self.progressFill.layer animationForKey:animationKey]) {
            [self.progressFill.layer removeAnimationForKey:animationKey];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
            animation.fromValue = @0;
            animation.toValue = @(width + segmentWidth);
            animation.duration = 1.2;
            animation.repeatCount = HUGE_VALF;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            [self.progressFill.layer addAnimation:animation forKey:animationKey];
        }
    } else {
        [self.progressFill.layer removeAnimationForKey:animationKey];
        CGFloat fraction = MAX(0, MIN(100, self.displayedInstallProgress)) / 100.0;
        self.progressFill.frame = CGRectMake(0, 0, width * fraction, 5);
    }
}

// 造包阶段等待回调丢弃产物，传输阶段发送真实取消指令。
- (void)cancelInstallation {
    if (self.cancellationRequested || self.installPhase == TSDialEditorInstallPhaseSelecting) {
        return;
    }
    self.cancellationRequested = YES;
    [self showInstallationProgress:@"正在取消，请稍候…" progress:-1];
    if (self.installPhase == TSDialEditorInstallPhasePreparing) {
        [self.exportSession cancelExport];
    } else if (self.installPhase == TSDialEditorInstallPhaseInstalling) {
        NSUInteger generation = self.installGeneration;
        __weak typeof(self) weakSelf = self;
        [[TopStepComKit sharedInstance].dial cancelDialInstall:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (generation != weakSelf.installGeneration || weakSelf.installPhase != TSDialEditorInstallPhaseInstalling) {
                    return;
                }
                if (!success || error) {
                    weakSelf.cancellationRequested = NO;
                    [weakSelf showInstallationProgress:@"取消失败，任务仍在进行，可再次取消" progress:-1];
                }
                // 指令成功后仍等待安装结束回调，不能提前显示取消成功。
            });
        }];
    }
}

// 任务已经结束后才能回到编辑状态。
- (void)finishCancellation {
    [self.progressFill.layer removeAnimationForKey:@"TSDialPreparingProgress"];
    self.installPhase = TSDialEditorInstallPhaseIdle;
    self.cancellationRequested = NO;
    [self cleanupExportedVideo];
    [self updateInstallationInteraction];
    [self closeSheet];
    [self showMessage:@"安装已取消，编辑内容已保留"];
}

// 失败沿用同一面板；已安装但设置失败只重试设置。
- (void)failInstallation:(NSString *)message {
    self.installPhase = TSDialEditorInstallPhaseFailed;
    self.cancellationRequested = NO;
    [self cleanupExportedVideo];
    [self updateInstallationInteraction];
    self.sheet.title = self.installedArtifact ? @"设置未完成" : @"安装未完成";
    [self showResultMessage:message success:NO];
    [self.sheet.primaryButton setTitle:self.installedArtifact ? @"设为当前表盘" : @"重试" forState:UIControlStateNormal];
    [self.sheet.secondaryButton setTitle:@"返回编辑" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    self.sheet.onSecondary = ^{ [weakSelf closeSheet]; };
    self.sheet.onPrimary = ^{
        if (weakSelf.installedArtifact) {
            [weakSelf selectInstalledArtifact];
        } else {
            [weakSelf startInstallation];
        }
    };
}

// 成功停留在结果页，由用户决定继续编辑或返回入口。
- (void)finishInstallation {
    self.installPhase = TSDialEditorInstallPhaseSucceeded;
    [self cleanupExportedVideo];
    [self updateInstallationInteraction];
    self.sheet.title = @"安装完成";
    [self showResultMessage:@"已设为当前表盘" success:YES];
    [self.sheet.primaryButton setTitle:@"返回上一页" forState:UIControlStateNormal];
    [self.sheet.secondaryButton setTitle:@"继续编辑" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    self.sheet.onSecondary = ^{ [weakSelf closeSheet]; };
    self.sheet.onPrimary = ^{ [weakSelf goBack]; };
    UIImage *preview = self.installationPreview;
    NSString *dialId = self.installedDeviceDialId;
    if (preview && self.onInstalledPreview) {
        self.onInstalledPreview(preview);
    }
    if (preview && dialId.length) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
                                   stringByAppendingPathComponent:@"dialPreviews"];
            [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *path = [directory stringByAppendingPathComponent:[dialId stringByAppendingPathExtension:@"jpg"]];
            [UIImageJPEGRepresentation(preview, 0.9) writeToFile:path atomically:YES];
        });
    }
    if (self.onPushSuccess) {
        self.onPushSuccess();
    }
}

// 完成和失败共用视觉结构，保留两个操作按钮。
- (void)showResultMessage:(NSString *)message success:(BOOL)success {
    [self.progressFill.layer removeAnimationForKey:@"TSDialPreparingProgress"];
    self.sheet.contentHeight = 196;
    self.sheet.allowsDismissal = YES;
    self.sheet.primaryButton.hidden = NO;
    self.sheet.secondaryButton.hidden = NO;
    self.sheet.primaryButton.enabled = YES;
    self.sheet.secondaryButton.enabled = YES;
    for (UIView *view in self.sheet.contentView.subviews) {
        [view removeFromSuperview];
    }
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    UILabel *symbol = [TSDialEditorAppearance label:success ? @"✓" : @"!" size:27 color:success ? 0x718B55 : 0xC58350];
    symbol.frame = CGRectMake((width - 58) / 2, 10, 58, 58);
    symbol.backgroundColor = [TSDialEditorAppearance color:success ? 0xEFF4E7 : 0xFFF1DF];
    symbol.layer.cornerRadius = 29;
    symbol.clipsToBounds = YES;
    symbol.textAlignment = NSTextAlignmentCenter;
    [self.sheet.contentView addSubview:symbol];
    UILabel *title = [TSDialEditorAppearance label:message size:16 color:0x252823];
    title.textAlignment = NSTextAlignmentCenter;
    title.numberOfLines = 3;
    title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    title.frame = CGRectMake(0, 82, width, 67);
    [self.sheet.contentView addSubview:title];
    UILabel *detail = [TSDialEditorAppearance label:@"编辑内容已保留，可继续修改。" size:11 color:0x959B8B];
    detail.textAlignment = NSTextAlignmentCenter;
    detail.frame = CGRectMake(0, 158, width, 24);
    [self.sheet.contentView addSubview:detail];
    [self.sheet setNeedsLayout];
}

// 只删除本次生成的设备尺寸素材，保留用户导入的原文件。
- (void)cleanupExportedVideo {
    if (self.exportedVideoURL) {
        [[NSFileManager defaultManager] removeItemAtURL:self.exportedVideoURL error:nil];
        self.exportedVideoURL = nil;
    }
    for (NSURL *url in self.preparedGIFURLs) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    }
    self.preparedGIFURLs = @[];
}

#pragma mark - Picker Delegate

// 多选结果按系统返回顺序读取，整个批次准备好后进入裁切。
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14.0)) {
    BOOL video = self.pickingVideo;
    BOOL append = self.appendPhotos;
    NSUInteger generation = self.mediaGeneration;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (!results.count) {
            return;
        }
        if (video) {
            [self loadPickedVideo:results.firstObject generation:generation];
            return;
        }
        dispatch_group_t group = dispatch_group_create();
        NSMutableArray *records = [NSMutableArray array];
        for (NSUInteger index = 0; index < results.count; index++) {
            [records addObject:NSNull.null];
        }
        __weak typeof(self) weakSelf = self;
        CGFloat sourceLimit = MAX(2048, MAX(self.editorState.screenSize.width, self.editorState.screenSize.height) * 4);
        [results enumerateObjectsUsingBlock:^(PHPickerResult *result, NSUInteger index, BOOL *stop) {
            dispatch_group_enter(group);
            NSString *name = result.itemProvider.suggestedName ?: [NSString stringWithFormat:@"照片 %lu", index + 1];
            [result.itemProvider loadFileRepresentationForTypeIdentifier:(NSString *)kUTTypeImage completionHandler:^(NSURL *url, NSError *error) {
                CGImageSourceRef source = url ? CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL) : NULL;
                NSDictionary *options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways:@YES,
                                           (NSString *)kCGImageSourceCreateThumbnailWithTransform:@YES,
                                           (NSString *)kCGImageSourceThumbnailMaxPixelSize:@(sourceLimit)};
                CGImageRef decoded = source ? CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)options) : NULL;
                if (decoded) {
                    UIImage *image = [UIImage imageWithCGImage:decoded];
                    @synchronized (records) {
                        records[index] = @{@"name":name, @"image":image, @"source":image};
                    }
                    CGImageRelease(decoded);
                }
                if (source) {
                    CFRelease(source);
                }
                dispatch_group_leave(group);
            }];
        }];
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.mediaGeneration ||
                strongSelf.navigationController.topViewController != strongSelf) {
                return;
            }
            NSMutableArray *valid = [NSMutableArray array];
            for (id record in records) {
                if ([record isKindOfClass:NSDictionary.class]) {
                    [valid addObject:record];
                }
            }
            if (valid.count != results.count) {
                [strongSelf showMessage:@"部分照片无法读取，已跳过"];
            }
            if (valid.count) {
                [strongSelf beginCropping:valid replacingCurrent:!append];
            }
        });
    }];
}

// loadFileRepresentation 的地址只在回调内有效，必须立即复制。
- (void)loadPickedVideo:(PHPickerResult *)result generation:(NSUInteger)generation API_AVAILABLE(ios(14.0)) {
    NSString *name = result.itemProvider.suggestedName ?: @"本机视频";
    __weak typeof(self) weakSelf = self;
    [result.itemProvider loadFileRepresentationForTypeIdentifier:(NSString *)kUTTypeMovie completionHandler:^(NSURL *url, NSError *error) {
        NSError *copyError = nil;
        NSURL *owned = url ? [TSDialEditorState importFile:url error:&copyError] : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf || generation != weakSelf.mediaGeneration) {
                if (owned) {
                    [[NSFileManager defaultManager] removeItemAtURL:owned error:nil];
                }
                return;
            }
            if (owned) {
                [weakSelf acceptVideoURL:owned name:name];
            } else {
                [weakSelf showMessage:error.localizedDescription ?: copyError.localizedDescription ?: @"视频读取失败"];
            }
        });
    }];
}

// 低版本系统选择器使用相同的后续处理。
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSURL *video = info[UIImagePickerControllerMediaURL];
    NSError *error = nil;
    NSURL *owned = video ? [TSDialEditorState importFile:video error:&error] : nil;
    [picker dismissViewControllerAnimated:YES completion:^{
        if (image) {
            [self beginCropping:@[@{@"name":@"照片", @"image":image, @"source":image}] replacingCurrent:!self.appendPhotos];
        } else if (owned) {
            [self acceptVideoURL:owned name:video.lastPathComponent];
        } else {
            [self showMessage:error.localizedDescription ?: @"素材读取失败"];
        }
    }];
}

// 取消选择不修改已有素材。
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// GIF 读取后保留原文件供 SDK 造包，取消不改当前关联。
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *source = urls.firstObject;
    NSError *error = nil;
    NSURL *owned = source ? [TSDialEditorState importFile:source error:&error] : nil;
    CGImageSourceRef image = owned ? CGImageSourceCreateWithURL((__bridge CFURLRef)owned, NULL) : NULL;
    BOOL valid = image && CGImageSourceGetCount(image) > 0 &&
        UTTypeConformsTo(CGImageSourceGetType(image), kUTTypeGIF);
    if (image) {
        CFRelease(image);
    }
    if (!valid) {
        if (owned) {
            [[NSFileManager defaultManager] removeItemAtURL:owned error:nil];
        }
        [self showMessage:error.localizedDescription ?: @"请选择有效的 GIF 文件"];
        return;
    }
    [self updateTextValue:owned.path key:@"gif"];
    [self.danMuView configureWithState:self.editorState];
}

#pragma mark - 属性懒加载

// 固定导航容器。
- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
    }
    return _headerView;
}

// 当前类型标题。
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [TSDialEditorAppearance label:@"" size:18 color:0x252823];
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

// 返回外部类型入口。
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_backButton setTitle:@"〈 返回" forState:UIControlStateNormal];
        _backButton.tintColor = [TSDialEditorAppearance color:0x647757];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

// 四种表盘共用预览。
- (TSDialPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[TSDialPreviewView alloc] init];
    }
    return _previewView;
}

// 中间编辑区单独滚动。
- (UIScrollView *)editorScroll {
    if (!_editorScroll) {
        _editorScroll = [[UIScrollView alloc] init];
        _editorScroll.backgroundColor = UIColor.whiteColor;
        _editorScroll.showsVerticalScrollIndicator = NO;
        _editorScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _editorScroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    }
    return _editorScroll;
}

// 不同类型的素材操作。
- (TSDialMaterialView *)materialView {
    if (!_materialView) {
        _materialView = [[TSDialMaterialView alloc] init];
    }
    return _materialView;
}

// 弹幕字段。
- (TSDialDanMuView *)danMuView {
    if (!_danMuView) {
        _danMuView = [[TSDialDanMuView alloc] init];
    }
    return _danMuView;
}

// 共用时间样式和颜色。
- (TSDialTimeStyleView *)timeStyleView {
    if (!_timeStyleView) {
        _timeStyleView = [[TSDialTimeStyleView alloc] init];
    }
    return _timeStyleView;
}

// 共用时间位置。
- (TSDialTimePositionView *)timePositionView {
    if (!_timePositionView) {
        _timePositionView = [[TSDialTimePositionView alloc] init];
    }
    return _timePositionView;
}

// 底部操作固定在安全区之上。
- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = UIColor.whiteColor;
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1)];
        separator.backgroundColor = [TSDialEditorAppearance color:0xE7EADE];
        [_footerView addSubview:separator];
        _footerView.clipsToBounds = YES;
    }
    return _footerView;
}

// 本机草稿保存。
- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [TSDialEditorAppearance button:@"保存草稿" primary:NO];
        [_saveButton addTarget:self action:@selector(saveDraft) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

// 真实安装入口。
- (UIButton *)installButton {
    if (!_installButton) {
        _installButton = [TSDialEditorAppearance button:@"设置为当前表盘  →" primary:YES];
        [_installButton addTarget:self action:@selector(confirmInstallation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _installButton;
}

// 读取设备约束中的说明。
- (UILabel *)loadingLabel {
    if (!_loadingLabel) {
        _loadingLabel = [TSDialEditorAppearance label:@"正在读取设备表盘样式…" size:12 color:0x93958E];
        _loadingLabel.numberOfLines = 2;
    }
    return _loadingLabel;
}

@end
