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
#import <TopStepInterfaceKit/TSDialVideoRequirements.h>
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
#import "TSDialSlotSelectionView.h"
#import "TSDialTemplateSelectionView.h"

typedef NS_ENUM(NSInteger, TSDialEditorInstallPhase) {
    TSDialEditorInstallPhaseIdle,
    TSDialEditorInstallPhasePreparing,
    TSDialEditorInstallPhaseBuilding,
    TSDialEditorInstallPhaseReviewing,
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
@property (nonatomic, strong) UIButton *qualityButton;
@property (nonatomic, strong) UIButton *videoAudioButton;
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
// 视频先完成画面裁切，确认后再写入草稿。
@property (nonatomic, strong) NSURL *pendingVideoURL;
@property (nonatomic, copy) NSString *pendingVideoName;
@property (nonatomic, assign) NSTimeInterval pendingVideoDuration;
// 安装面板和资源生命周期。
@property (nonatomic, strong) TSDialEditorSheet *sheet;
// 模板详情覆盖在安装确认之上，返回时保留已选安装位置。
@property (nonatomic, strong) TSDialEditorSheet *templateSheet;
@property (nonatomic, weak) TSDialTemplateSelectionView *templateSelectionView;
@property (nonatomic, weak) UIDocumentPickerViewController *templatePicker;
@property (nonatomic, assign) BOOL importingTemplate;
@property (nonatomic, assign) NSUInteger templateImportGeneration;
// 进度轨道：制作时显示循环光带，传输时按 SDK 百分比填充。
@property (nonatomic, strong) UIView *progressTrack;
@property (nonatomic, strong) UIView *progressFill;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *progressHintLabel;
@property (nonatomic, assign) NSInteger displayedInstallProgress;
@property (nonatomic, strong) TSDialArtifact *builtArtifact;
// 本次安装选择的表盘位；nil 表示自动选位。
@property (nonatomic, strong, nullable) TSDialInstallOptions *installOptions;
// 确认弹窗内的安装位置选择区；设备不支持指定表盘位时为 nil。
@property (nonatomic, weak) TSDialSlotSelectionView *slotSelectionView;
// 最近一次安装回调的错误，用于识别指定的表盘位被拒绝。
@property (nonatomic, strong, nullable) NSError *lastInstallError;
// 本轮安装中被拒绝过的表盘位，重新选位时不可再选；从编辑页重新发起安装时清空。
@property (nonatomic, strong) NSMutableSet<NSNumber *> *rejectedSlotIndexes;
@property (nonatomic, strong) TSDialArtifact *installedArtifact;
// 安装时冻结完成语义，Fit 的成功回调已包含槽位激活。
@property (nonatomic, assign) BOOL installationActivatesDial;
// 从设备读取的已安装标识，与造包产物标识分开保存。
@property (nonatomic, copy) NSString *installedDeviceDialId;
@property (nonatomic, strong) UIImage *installationPreview;
// 本次安装的冻结快照。
@property (nonatomic, strong) TSDialEditorState *installationState;
// 冻结本轮成品视频要求；nil 保留旧 Provider 的 App 导出行为。
@property (nonatomic, strong, nullable) TSDialVideoRequirements *installationVideoRequirements;
// NPK 的取消完成即任务退出，成功后不会再回原造包或安装回调。
@property (nonatomic, assign) BOOL installationCancellationCompletesTask;
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

// 保留现有视频调用方，源素材在每次安装前由 App 导出成品。
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
    if (_exportSession) {
        TSLogInfo(@"[TSDialEditorVC] dealloc: cancelVideoExport generation=%lu quality=%ld status=%ld",
                  (unsigned long)_installGeneration, (long)_installationState.quality, (long)_exportSession.status);
    }
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
    for (UIView *view in @[self.materialView, self.qualityButton, self.videoAudioButton, self.danMuView,
                           self.timeStyleView, self.timePositionView, self.loadingLabel]) {
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
    for (UIButton *button in @[self.qualityButton, self.videoAudioButton]) {
        if (!button.hidden) {
            button.frame = CGRectMake(20, offset + 6, contentWidth, 44);
            offset += 56;
        }
    }
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
    return @{@"maxImages":@(images), @"maxDuration":@(MAX(0, [self videoDurationLimit]))};
}

// 新合同按当前画质查询成品要求，旧 Provider 继续使用原时长能力。
- (NSTimeInterval)videoDurationLimit {
    TSDialVideoRequirements *requirements = [self.capability videoRequirementsForQuality:self.editorState.quality];
    return requirements ? requirements.maxDuration : self.capability.maxVideoDuration;
}

// 初始或结构变化时刷新各编辑模块。
- (void)renderEditor {
    NSArray *titles = @[@"照片表盘", @"相册表盘", @"视频表盘", @"弹幕表盘"];
    self.titleLabel.text = titles[self.editorState.draftType - TSDialDraftTypeSingleImage];
    [self renderMaterial];
    [self renderMediaOptions];
    if (self.editorState.draftType == TSDialDraftTypeDanMu) {
        [self.danMuView configureWithState:self.editorState];
    }
    [self renderTimeControls];
    [self updatePreview];
    [self.view setNeedsLayout];
}

// 素材变更不会重建时间控件。
- (void)renderMaterial {
    [self.materialView configureWithState:self.editorState limits:[self materialLimits]
                               thumbnails:self.videoThumbnails screen:self.screen];
}

// 只展示公开能力允许的选项，默认值不改变旧 Provider 行为。
- (void)renderMediaOptions {
    TSDialVideoRequirements *requirements = [self.capability videoRequirementsForQuality:self.editorState.quality];
    self.qualityButton.hidden = self.capability.qualityLevels.count == 0;
    self.videoAudioButton.hidden = self.editorState.draftType != TSDialDraftTypeVideo ||
        !requirements.supportsAudio;
    [self.qualityButton setTitle:[@"画质：" stringByAppendingString:[self titleForQuality:self.editorState.quality]]
                       forState:UIControlStateNormal];
    [self.videoAudioButton setTitle:[@"音轨：" stringByAppendingString:[self titleForAudioSelection:self.editorState.videoAudioSelection]]
                          forState:UIControlStateNormal];
}

// 画质名称不暴露 Provider 内部编码格式。
- (NSString *)titleForQuality:(TSDialQuality)quality {
    switch (quality) {
        case TSDialQualityStandard: return @"标准";
        case TSDialQualityLossless: return @"无损";
        default: return @"设备默认";
    }
}

// 音轨选择只控制生成文件，不承诺设备扬声器播放能力。
- (NSString *)titleForAudioSelection:(TSDialEditorVideoAudioSelection)selection {
    switch (selection) {
        case TSDialEditorVideoAudioSelectionMuted: return @"静音";
        case TSDialEditorVideoAudioSelectionPreserveFirstTrack: return @"保留首条音轨";
        default: return @"设备默认";
    }
}

// 默认选项始终可回退，显式画质来自能力快照。
- (void)chooseQuality {
    if ([self isInstalling] || !self.capability.qualityLevels.count) { return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"画质" message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray<NSNumber *> *levels = [@[@(TSDialQualityDefault)] arrayByAddingObjectsFromArray:self.capability.qualityLevels];
    __weak typeof(self) weakSelf = self;
    for (NSNumber *level in levels) {
        [alert addAction:[UIAlertAction actionWithTitle:[self titleForQuality:level.integerValue]
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                [weakSelf selectQuality:level.integerValue];
            }];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    alert.popoverPresentationController.sourceView = self.qualityButton;
    alert.popoverPresentationController.sourceRect = self.qualityButton.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

// 视频画布使用当前画质合同的独立数值副本，不能改写连接设备的共享屏幕模型。
- (TSPeripheralScreen *)videoCanvasForQuality:(TSDialQuality)quality {
    TSDialVideoRequirements *requirements = [self.capability videoRequirementsForQuality:quality];
    TSPeripheralScreen *canvas = [[TSPeripheralScreen alloc] init];
    canvas.screenSize = requirements ? requirements.inputPixelSize : self.screen.screenSize;
    canvas.shape = requirements ? requirements.inputShape : self.screen.shape;
    canvas.screenBorderRadius = requirements ? requirements.cornerRadius : self.screen.screenBorderRadius;
    canvas.dialPreviewSize = self.screen.dialPreviewSize;
    canvas.dialPreviewBorderRadius = self.screen.dialPreviewBorderRadius;
    canvas.videoPreviewSize = self.screen.videoPreviewSize;
    canvas.videoPreviewBorderRadius = self.screen.videoPreviewBorderRadius;
    return canvas;
}

// 保存的确认记录只适用于同一视频成品画布；旧草稿没有记录时要求重新确认。
- (BOOL)videoCropForState:(TSDialEditorState *)state matchesCanvas:(TSPeripheralScreen *)canvas {
    NSDictionary *record = state.images.firstObject;
    return record[@"videoCanvasSize"] && record[@"videoCanvasShape"] && record[@"videoCanvasRadius"] &&
        CGSizeEqualToSize(CGSizeFromString(record[@"videoCanvasSize"]), canvas.screenSize) &&
        [record[@"videoCanvasShape"] integerValue] == canvas.shape &&
        fabs([record[@"videoCanvasRadius"] doubleValue] - canvas.screenBorderRadius) < 0.000001;
}

// 改变视频画布时暂不提交画质；在裁剪页确认后一起提交，取消保留原画质和构图。
- (void)selectQuality:(TSDialQuality)quality {
    if ([self isInstalling] || quality == self.editorState.quality) { return; }
    if (self.editorState.draftType == TSDialDraftTypeVideo && self.editorState.videoURL) {
        TSPeripheralScreen *canvas = [self videoCanvasForQuality:quality];
        if (![self videoCropForState:self.editorState matchesCanvas:canvas]) {
            TSLogInfo(@"[TSDialEditorVC] selectQuality: mediaGeneration=%lu fromQuality=%ld toQuality=%ld reconfirmCrop=1 target=%.0fx%.0f shape=%ld radius=%.2f",
                      (unsigned long)self.mediaGeneration, (long)self.editorState.quality, (long)quality,
                      canvas.screenSize.width, canvas.screenSize.height, (long)canvas.shape, canvas.screenBorderRadius);
            NSArray *records = [self videoCroppingRecords];
            if (records.count) {
                [self beginCropping:records replacingCurrent:YES quality:quality];
            }
            return;
        }
    }
    self.editorState.quality = quality;
    if (self.editorState.draftType == TSDialDraftTypeVideo) {
        TSLogInfo(@"[TSDialEditorVC] selectQuality: committed mediaGeneration=%lu quality=%ld reconfirmCrop=0",
                  (unsigned long)self.mediaGeneration, (long)quality);
    }
    [self renderMediaOptions];
    [self renderMaterial];
    [self updatePreview];
}

// 音轨编辑由 App 完成，只有成品要求允许音轨时提供选择。
- (void)chooseVideoAudio {
    TSDialVideoRequirements *requirements = [self.capability videoRequirementsForQuality:self.editorState.quality];
    if ([self isInstalling] || !requirements.supportsAudio) { return; }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"视频音轨"
        message:@"保留音轨时，源视频没有音轨仍可生成。设备是否播放声音由固件决定。"
        preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    NSArray<NSNumber *> *selections = @[@(TSDialEditorVideoAudioSelectionAutomatic),
        @(TSDialEditorVideoAudioSelectionMuted), @(TSDialEditorVideoAudioSelectionPreserveFirstTrack)];
    for (NSNumber *selection in selections) {
        [alert addAction:[UIAlertAction actionWithTitle:[self titleForAudioSelection:selection.integerValue]
                                                 style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            weakSelf.editorState.videoAudioSelection = selection.integerValue;
            [weakSelf renderMediaOptions];
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    alert.popoverPresentationController.sourceView = self.videoAudioButton;
    alert.popoverPresentationController.sourceRect = self.videoAudioButton.bounds;
    [self presentViewController:alert animated:YES completion:nil];
}

// 时间控件与实时预览共用同一能力和样式就绪条件。
- (BOOL)hasAvailableTimeStyle {
    return self.capability.supportsComponent && self.editorReady &&
        self.styleConstraint.styles.count > 0;
}

// 四种表盘统一由组件能力控制时间编辑入口，样式加载完成后才展示实际选项。
- (void)renderTimeControls {
    BOOL supportsTime = [self hasAvailableTimeStyle];
    self.timeStyleView.hidden = !supportsTime;
    self.timePositionView.hidden = !supportsTime || !self.editorState.showsTime;
    [self.timeStyleView configureWithState:self.editorState constraint:self.styleConstraint images:self.styleImages];
    [self.timePositionView configureWithState:self.editorState constraint:self.styleConstraint];
}

// 预览统一读取同一份编辑配置。
- (void)updatePreview {
    UIImage *timeImage = [self hasAvailableTimeStyle] ? self.styleImages[@(self.editorState.timeStyle)] : nil;
    TSPeripheralScreen *canvas = self.editorState.draftType == TSDialDraftTypeVideo
        ? [self videoCanvasForQuality:self.editorState.quality] : self.screen;
    [self.previewView configureWithState:self.editorState screen:canvas constraint:self.styleConstraint
                              timeImage:timeImage];
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
    if (![self.capability.qualityLevels containsObject:@(self.editorState.quality)]) {
        self.editorState.quality = TSDialQualityDefault;
    }
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
        if (self.editorState.draftType == TSDialDraftTypeVideo && [self videoDurationLimit] > 0) {
            self.editorState.videoEnd = MIN(self.editorState.videoEnd,
                                           self.editorState.videoStart + [self videoDurationLimit]);
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
    CGSize screenSize = self.screen.screenSize;
    CGFloat screenRatio = screenSize.width > 0 && screenSize.height > 0 ? screenSize.width / screenSize.height : 1;
    BOOL circular = self.screen.shape == eTSPeriphShapeCircle;
    for (NSUInteger index = 0; index < backgrounds.count; index++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat tileWidth = cardWidth;
        CGFloat tileHeight = 113;
        if (circular) {
            tileWidth = tileHeight = MIN(cardWidth, 113);
        } else if (screenRatio > 1) {
            tileHeight = MIN(113, cardWidth / screenRatio);
        } else {
            tileWidth = MIN(cardWidth, 113 * screenRatio);
        }
        CGFloat cellX = index % 3 * (cardWidth + 9);
        CGFloat cellY = index / 3 * 122;
        button.frame = CGRectMake(cellX + (cardWidth - tileWidth) / 2,
                                  cellY + (113 - tileHeight) / 2, tileWidth, tileHeight);
        button.tag = index;
        CGFloat radius = circular ? tileWidth / 2 :
            (screenSize.width > 0 && self.screen.screenBorderRadius > 0 ?
             MIN(13, self.screen.screenBorderRadius * tileWidth / screenSize.width) : MIN(13, MIN(tileWidth, tileHeight) / 2));
        button.layer.cornerRadius = radius;
        button.clipsToBounds = YES;
        [button setImage:backgrounds[index][@"image"] forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button addTarget:self action:@selector(selectBackground:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *name = [TSDialEditorAppearance label:backgrounds[index][@"name"] size:11 color:0xFFFFFF];
        name.frame = CGRectMake(0, MAX(0, tileHeight - 27), tileWidth, MIN(27, tileHeight));
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

// 视频选择后先裁切展示画面，再在编辑页选择播放片段。
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
    if (self.editorState.draftType == TSDialDraftTypeVideo) {
        [self beginCropping:[self videoCroppingRecords] replacingCurrent:YES];
        return;
    }
    NSUInteger index = MIN(self.editorState.selectedImage, self.editorState.images.count - 1);
    [self beginCropping:@[self.editorState.images[index]] replacingCurrent:YES];
}

// 从原视频当前选段提取方向正确的完整帧，旧背景或旧裁剪成品不能充当视频源画面。
- (NSArray<NSDictionary *> *)videoCroppingRecords {
    if (!self.editorState.videoURL) { return @[]; }
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:
        [AVURLAsset assetWithURL:self.editorState.videoURL]];
    generator.appliesPreferredTrackTransform = YES;
    CGImageRef frame = [generator copyCGImageAtTime:CMTimeMakeWithSeconds(self.editorState.videoStart, 600)
                                       actualTime:nil error:nil];
    if (!frame) {
        [self showMessage:@"无法读取视频画面，请重新选择视频"];
        return @[];
    }
    UIImage *source = [UIImage imageWithCGImage:frame];
    CGImageRelease(frame);
    NSMutableDictionary *record = [self.editorState.images.firstObject mutableCopy] ?: [NSMutableDictionary dictionary];
    record[@"name"] = self.editorState.videoName ?: @"本机视频";
    record[@"source"] = source;
    record[@"image"] = source;
    return @[record];
}

// 整批完成前不写入编辑状态，取消无需恢复旧图片。
- (void)beginCropping:(NSArray<NSDictionary *> *)records replacingCurrent:(BOOL)replace {
    [self beginCropping:records replacingCurrent:replace quality:self.editorState.quality];
}

// 视频可以预览待确认画质的画布；图片继续使用设备屏幕，确认前不修改任何草稿字段。
- (void)beginCropping:(NSArray<NSDictionary *> *)records replacingCurrent:(BOOL)replace
              quality:(TSDialQuality)quality {
    BOOL video = self.editorState.draftType == TSDialDraftTypeVideo;
    TSPeripheralScreen *canvas = video ? [self videoCanvasForQuality:quality] : self.screen;
    if (!records.count || canvas.screenSize.width <= 0 || canvas.screenSize.height <= 0) {
        [self showMessage:@"请先读取设备屏幕尺寸"];
        return;
    }
    NSUInteger target = self.editorState.selectedImage;
    TSDialImageCropVC *crop = [[TSDialImageCropVC alloc] initWithRecords:records screen:canvas];
    crop.usesVideoCanvas = video;
    if (video) {
        crop.title = quality == self.editorState.quality ? @"确认视频构图" : @"画质变化，请确认构图";
    }
    __weak typeof(self) weakSelf = self;
    crop.onCropCancelled = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (video) {
            TSLogInfo(@"[TSDialEditorVC] beginCropping:replacingCurrent:quality: cancelled mediaGeneration=%lu requestedQuality=%ld retainedQuality=%ld",
                      (unsigned long)strongSelf.mediaGeneration, (long)quality, (long)strongSelf.editorState.quality);
        }
        NSURL *pendingURL = strongSelf.pendingVideoURL;
        if (pendingURL) {
            [[NSFileManager defaultManager] removeItemAtURL:pendingURL error:nil];
        }
        strongSelf.pendingVideoURL = nil;
        strongSelf.pendingVideoName = nil;
        strongSelf.pendingVideoDuration = 0;
    };
    crop.onCropBatchComplete = ^(NSArray<NSDictionary *> *results) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        NSMutableArray *images = [strongSelf.editorState.images mutableCopy];
        NSURL *pendingVideoURL = strongSelf.pendingVideoURL;
        NSString *pendingVideoName = strongSelf.pendingVideoName;
        NSTimeInterval pendingVideoDuration = strongSelf.pendingVideoDuration;
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
        if (video) {
            strongSelf.editorState.quality = quality;
            TSLogInfo(@"[TSDialEditorVC] beginCropping:replacingCurrent:quality: confirmed mediaGeneration=%lu quality=%ld target=%.0fx%.0f shape=%ld radius=%.2f",
                      (unsigned long)strongSelf.mediaGeneration, (long)quality,
                      canvas.screenSize.width, canvas.screenSize.height, (long)canvas.shape, canvas.screenBorderRadius);
        }
        if (pendingVideoURL && strongSelf.editorState.draftType == TSDialDraftTypeVideo) {
            strongSelf.editorState.videoURL = pendingVideoURL;
            strongSelf.editorState.videoName = pendingVideoName.length ? pendingVideoName : @"本机视频";
            strongSelf.editorState.videoDuration = pendingVideoDuration;
            strongSelf.editorState.videoStart = 0;
            strongSelf.editorState.videoEnd = MIN(pendingVideoDuration, MAX(0.2, [strongSelf videoDurationLimit]));
            strongSelf.pendingVideoURL = nil;
            strongSelf.pendingVideoName = nil;
            strongSelf.pendingVideoDuration = 0;
            strongSelf.videoThumbnails = @[];
        }
        [strongSelf dismissViewControllerAnimated:YES completion:^{
            [strongSelf renderMediaOptions];
            [strongSelf renderMaterial];
            [strongSelf updatePreview];
            if (pendingVideoURL) {
                [strongSelf loadVideoThumbnails:pendingVideoURL];
            }
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
            [strongSelf beginVideoCroppingWithURL:url name:name duration:duration generation:generation];
        });
    });
}

// 视频首帧先进入与图片一致的画面裁切页，确认后才替换当前视频。
- (void)beginVideoCroppingWithURL:(NSURL *)url name:(NSString *)name
                         duration:(NSTimeInterval)duration generation:(NSUInteger)generation {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVURLAsset assetWithURL:url]];
        generator.appliesPreferredTrackTransform = YES;
        generator.maximumSize = CGSizeMake(1200, 1200);
        CGImageRef image = [generator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
        UIImage *firstFrame = image ? [UIImage imageWithCGImage:image] : nil;
        if (image) {
            CGImageRelease(image);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.mediaGeneration) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                return;
            }
            if (!firstFrame) {
                [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                [strongSelf showMessage:@"无法读取视频画面，请选择其他视频"];
                return;
            }
            strongSelf.pendingVideoURL = url;
            strongSelf.pendingVideoName = name;
            strongSelf.pendingVideoDuration = duration;
            [strongSelf beginCropping:@[@{ @"name": name.length ? name : @"本机视频",
                                           @"image": firstFrame, @"source": firstFrame }]
                       replacingCurrent:YES];
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
            // 新视频完成画面裁切后保留裁切成品，首帧只作为无成品草稿的占位图。
            if (frames.count && strongSelf.editorState.images.count == 0) {
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
    [self.templateSheet dismiss];
    self.templateSheet = nil;
    self.templateImportGeneration++;
    self.importingTemplate = NO;
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
        self.installPhase == TSDialEditorInstallPhaseReviewing ||
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
    if (state.quality != TSDialQualityDefault && ![capability.qualityLevels containsObject:@(state.quality)]) {
        return @"当前设备不支持所选画质，请重新读取设备样式";
    }
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
        TSDialVideoRequirements *requirements = [capability videoRequirementsForQuality:state.quality];
        NSTimeInterval maximum = requirements ? requirements.maxDuration : capability.maxVideoDuration;
        if (!capability.supportsVideo || !isfinite(maximum) || maximum <= 0) {
            return @"当前设备不支持视频表盘";
        }
        if ([TopStepComKit sharedInstance].kitOption.sdkType == eTSSDKTypeTPB && !requirements) {
            return @"设备视频成品要求不可用，请重新读取设备样式";
        }
        if (!state.videoURL || ![[NSFileManager defaultManager] fileExistsAtPath:state.videoURL.path]) {
            return @"请先选择本机视频";
        }
        if (requirements && ![self videoCropForState:state matchesCanvas:[self videoCanvasForQuality:state.quality]]) {
            return @"视频画布已变化或尚未确认，请点裁剪重新确认构图";
        }
        NSTimeInterval duration = state.videoEnd - state.videoStart;
        if (!isfinite(duration) || !isfinite(state.videoStart) || !isfinite(state.videoEnd) ||
            duration < 0.199 || duration > maximum || state.videoStart < 0 ||
            state.videoEnd > state.videoDuration + 0.001) {
            return [NSString stringWithFormat:@"请将视频片段调整到 %.1f 秒以内", (double)maximum];
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
    [self.rejectedSlotIndexes removeAllObjects];
    [self confirmInstallationWithKnownBytes:0];
}

// 确认弹窗；支持指定表盘位时在弹窗内选择安装位置，knownBytes 为已知的表盘大小（0 表示未知）。
- (void)confirmInstallationWithKnownBytes:(unsigned long long)knownBytes {
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
    self.installOptions = nil;
    self.slotSelectionView = nil;
    TSDialEditorSheet *sheet = [[TSDialEditorSheet alloc] init];
    sheet.title = @"安装表盘";
    sheet.contentHeight = 352;
    [sheet.primaryButton setTitle:@"开始安装" forState:UIControlStateNormal];
    [sheet.secondaryButton setTitle:@"返回编辑" forState:UIControlStateNormal];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    UIView *summary = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 108)];
    summary.backgroundColor = [TSDialEditorAppearance color:0xF5F6F0];
    summary.layer.cornerRadius = 14;
    UIImageView *image = [[UIImageView alloc] initWithImage:self.editorState.images.firstObject[@"image"]];
    image.contentMode = UIViewContentModeScaleAspectFill;
    image.clipsToBounds = YES;
    // 缩略图按设备屏幕形状展示：圆屏为圆形，方屏/长方屏按屏幕比例与圆角
    CGFloat faceRadius = 0;
    CGSize faceSize = [TSDialEditorAppearance faceSizeForScreen:self.screen inBox:CGSizeMake(62, 78) cornerRadius:&faceRadius];
    image.frame = CGRectMake(15 + (62 - faceSize.width) / 2, (108 - faceSize.height) / 2, faceSize.width, faceSize.height);
    image.layer.cornerRadius = faceRadius;
    [summary addSubview:image];
    UILabel *title = [TSDialEditorAppearance label:self.titleLabel.text size:13 color:0x252823];
    title.frame = CGRectMake(86, 18, width - 100, 24);
    UILabel *detail = [TSDialEditorAppearance label:@"将制作表盘并传输到手表\n安装期间请保持设备连接" size:11 color:0x8F9B81];
    detail.numberOfLines = 2;
    detail.frame = CGRectMake(86, 47, width - 100, 44);
    [summary addSubview:title];
    [summary addSubview:detail];
    [sheet.contentView addSubview:summary];
    TSDialTemplateSelectionView *templateView = [[TSDialTemplateSelectionView alloc] initWithFrame:CGRectZero];
    templateView.frame = CGRectMake(0, 124, width, [templateView preferredHeight]);
    [sheet.contentView addSubview:templateView];
    self.templateSelectionView = templateView;
    __weak typeof(self) weakSelf = self;
    templateView.onDetails = ^{ [weakSelf showTemplateDetails]; };
    templateView.onChange = ^{ [weakSelf chooseTemplateSource]; };
    CGFloat slotTop = CGRectGetMaxY(templateView.frame) + 20;
    if ([TSDialSlotSelectionView isSupportedOnCurrentDevice]) {
        [self attachSlotSelectionToSheet:sheet top:slotTop width:width knownBytes:knownBytes];
    } else {
        UILabel *hint = [TSDialEditorAppearance label:@"安装不会清空当前编辑内容，可随时保存草稿。" size:11 color:0x959B8B];
        hint.numberOfLines = 2;
        hint.frame = CGRectMake(0, slotTop, width, 40);
        [sheet.contentView addSubview:hint];
    }
    sheet.onSecondary = ^{ [weakSelf closeSheet]; };
    sheet.onPrimary = ^{ [weakSelf startInstallationFromConfirmation]; };
    [self presentSheet:sheet];
    [self refreshTemplateSelection];
    [self.slotSelectionView reload];
}

// 把安装位置选择区放进确认弹窗，内容变化时同步弹窗高度与主按钮。
- (void)attachSlotSelectionToSheet:(TSDialEditorSheet *)sheet
                               top:(CGFloat)top
                             width:(CGFloat)width
                        knownBytes:(unsigned long long)knownBytes {
    TSDialSlotSelectionView *slotView = [[TSDialSlotSelectionView alloc] initWithFrame:CGRectMake(0, top, width, 0)];
    slotView.knownFileBytes = knownBytes;
    slotView.rejectedSlotIndexes = self.rejectedSlotIndexes;
    slotView.screen = self.screen;
    __weak TSDialEditorSheet *weakSheet = sheet;
    __weak TSDialSlotSelectionView *weakSlotView = slotView;
    __weak typeof(self) weakSelf = self;
    slotView.onContentChange = ^{
        TSDialEditorSheet *strongSheet = weakSheet;
        TSDialSlotSelectionView *strongSlotView = weakSlotView;
        // 弹窗已切换到进度或结果时不再改动
        if (!strongSheet || !strongSlotView || strongSlotView.superview != strongSheet.contentView) {
            return;
        }
        CGFloat height = [strongSlotView preferredHeight];
        strongSlotView.frame = CGRectMake(0, top, width, height);
        strongSheet.contentHeight = top + height + 4;
        [weakSelf refreshTemplateSelection];
        [strongSheet setNeedsLayout];
        [strongSheet layoutIfNeeded];
    };
    [sheet.contentView addSubview:slotView];
    self.slotSelectionView = slotView;
}

// 确认弹窗主按钮：带上所选安装位置开始安装；仍在读取表盘位时不响应。
- (void)startInstallationFromConfirmation {
    if ([self isInstalling] || self.importingTemplate || self.presentedViewController || self.templateSheet) {
        return;
    }
    TSDialSlotSelectionView *slotView = self.slotSelectionView;
    if (slotView && (slotView.superview != self.sheet.contentView || !slotView.canInstall)) {
        return;
    }
    self.installOptions = slotView.selectedOptions;
    [self startInstallation];
}

// 模板导入和表盘位读取共用主按钮状态，异步回调不能互相覆盖禁用状态。
- (void)refreshTemplateSelection {
    if (!self.templateSelectionView || self.templateSelectionView.superview != self.sheet.contentView) { return; }
    [self.templateSelectionView configureWithFileURL:self.editorState.templateFileURL
                                               name:self.editorState.templateName importing:self.importingTemplate];
    BOOL enabled = !self.importingTemplate && (!self.slotSelectionView || self.slotSelectionView.canInstall);
    self.sheet.primaryButton.enabled = enabled;
    self.sheet.primaryButton.alpha = enabled ? 1 : 0.45;
    NSString *title = self.importingTemplate ? @"正在导入…" : self.editorState.templateFileURL ? @"制作并预览" :
        (self.slotSelectionView ? [self.slotSelectionView primaryTitleWithDefault:@"开始安装"] : @"开始安装");
    [self.sheet.primaryButton setTitle:title forState:UIControlStateNormal];
}

// 二级面板不替换安装弹窗，返回后保留当前表盘位和滚动位置。
- (void)presentTemplateSheet:(TSDialEditorSheet *)sheet {
    [self.templateSheet dismiss];
    self.templateSheet = sheet;
    __weak typeof(self) weakSelf = self;
    sheet.onDismiss = ^{ weakSelf.templateSheet = nil; };
    [sheet showInView:self.view];
}

// 模板改变后旧产物大小和槽位失败记录失效，保留仍可用的当前选择。
- (void)didChangeTemplateSelection {
    self.builtArtifact = nil;
    [self.rejectedSlotIndexes removeAllObjects];
    self.slotSelectionView.knownFileBytes = 0;
    self.slotSelectionView.rejectedSlotIndexes = self.rejectedSlotIndexes;
    [self refreshTemplateSelection];
}

// 只在二级面板展示完整路径，自动模式明确说明 SDK 未公开路径。
- (void)showTemplateDetails {
    if (self.importingTemplate || [self isInstalling] || !self.templateSelectionView ||
        self.templateSelectionView.superview != self.sheet.contentView) { return; }
    NSURL *fileURL = self.editorState.templateFileURL;
    TSDialEditorSheet *sheet = [[TSDialEditorSheet alloc] init];
    sheet.title = fileURL ? @"本地模板" : @"模板来源";
    sheet.contentHeight = fileURL ? 240 : 132;
    UITextView *details = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 40, sheet.contentHeight)];
    details.editable = NO;
    details.font = [UIFont systemFontOfSize:13];
    details.textColor = [TSDialEditorAppearance color:0x647757];
    details.backgroundColor = [TSDialEditorAppearance color:0xF8F8F4];
    details.layer.cornerRadius = 12;
    details.textContainerInset = UIEdgeInsetsMake(14, 10, 14, 10);
    details.text = fileURL ? [NSString stringWithFormat:@"%@\n\nApp 内使用路径\n%@\n\n已复制到 App，原文件不会被修改。设备兼容性将在制作时由 SDK 校验。",
        self.editorState.templateName ?: fileURL.lastPathComponent, fileURL.path] :
        @"来源：SDK 自动匹配\n\nSDK 负责获取适配当前设备的模板。当前公开接口不提供默认模板的文件名、格式或实际路径。";
    [sheet.contentView addSubview:details];
    sheet.primaryButton.hidden = !fileURL;
    [sheet.primaryButton setTitle:@"复制路径" forState:UIControlStateNormal];
    [sheet.secondaryButton setTitle:@"返回" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    sheet.onPrimary = ^{
        UIPasteboard.generalPasteboard.string = fileURL.path;
        [weakSelf showMessage:@"路径已复制"];
    };
    sheet.onSecondary = ^{ [weakSelf.templateSheet dismiss]; };
    [self presentTemplateSheet:sheet];
}

// 更换来源仅改模板，不触碰照片、裁切和时间编辑记录。
- (void)chooseTemplateSource {
    if (self.importingTemplate || [self isInstalling] || !self.templateSelectionView ||
        self.templateSelectionView.superview != self.sheet.contentView) { return; }
    TSDialEditorSheet *sheet = [[TSDialEditorSheet alloc] init];
    sheet.title = @"选择表盘模板";
    sheet.contentHeight = 112;
    sheet.stacksActions = YES;
    UILabel *hint = [TSDialEditorAppearance label:@"SDK 自动匹配适合日常使用。\n也可从“文件”选择当前设备适用的模板。\n\n更换模板后，背景和时间设置会保留。" size:13 color:0x82916E];
    hint.numberOfLines = 0;
    hint.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 40, 108);
    [sheet.contentView addSubview:hint];
    [sheet.primaryButton setTitle:@"选择本地文件" forState:UIControlStateNormal];
    [sheet.secondaryButton setTitle:self.editorState.templateFileURL ? @"恢复 SDK 自动匹配" : @"继续使用 SDK 自动匹配"
                          forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    sheet.onPrimary = ^{
        [weakSelf.templateSheet dismiss];
        [weakSelf pickLocalTemplate];
    };
    sheet.onSecondary = ^{
        weakSelf.editorState.templateFileURL = nil;
        weakSelf.editorState.templateName = nil;
        [weakSelf.templateSheet dismiss];
        [weakSelf didChangeTemplateSelection];
    };
    [self presentTemplateSheet:sheet];
}

// 使用系统文件选择器；后缀不等于兼容性，模板内容由 SDK 验证。
- (void)pickLocalTemplate {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initWithDocumentTypes:@[(NSString *)kUTTypeData] inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    self.templatePicker = picker;
    [self presentViewController:picker animated:YES completion:nil];
}

// 导入在后台完成；失败、取消和过期回调均不会替换原模板。
- (void)importSelectedTemplate:(NSURL *)source {
    if (!source || !self.sheet || !self.templateSelectionView) { return; }
    self.importingTemplate = YES;
    NSUInteger generation = ++self.templateImportGeneration;
    TSDialEditorSheet *confirmation = self.sheet;
    [self refreshTemplateSelection];
    NSString *name = source.lastPathComponent;
    BOOL scoped = [source startAccessingSecurityScopedResource];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSError *error = nil;
        NSURL *ownedURL = [TSDialEditorState importTemplateAtURL:source error:&error];
        if (scoped) { [source stopAccessingSecurityScopedResource]; }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.templateImportGeneration || strongSelf.sheet != confirmation) {
                if (ownedURL) { [[NSFileManager defaultManager] removeItemAtURL:ownedURL error:nil]; }
                return;
            }
            strongSelf.importingTemplate = NO;
            if (ownedURL) {
                strongSelf.editorState.templateFileURL = ownedURL;
                strongSelf.editorState.templateName = name;
                [strongSelf didChangeTemplateSelection];
            }
            [strongSelf refreshTemplateSelection];
            [strongSelf showMessage:ownedURL ? @"模板已导入，制作后可确认预览" :
                error.localizedDescription ?: @"模板导入失败，原选择已保留"];
        });
    });
}

// 指定的表盘位被拒绝后回到确认弹窗重新选择，按刚制作出的表盘大小过滤放不下的位置。
- (void)reselectInstallSlot {
    unsigned long long bytes = 0;
    NSString *path = self.builtArtifact.filePath;
    if (path.length) {
        bytes = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    }
    [self confirmInstallationWithKnownBytes:bytes];
}

// 指定表盘位安装时，SDK 判定该位置不可用或放不下。
- (BOOL)isSlotRejection:(nullable NSError *)error {
    return self.installOptions.hasTargetSlot && [error.domain isEqualToString:kTSErrorDomainDialName] &&
        (error.code == TSDialErrorInvalidTargetSlot || error.code == eTSErrorNoSpace);
}

// 表盘位被拒绝时说明原因，其余沿用 SDK 的错误描述。
- (NSString *)installFailureMessageForError:(nullable NSError *)error {
    if ([self isSlotRejection:error]) {
        NSInteger slotIndex = self.installOptions.targetSlotIndex;
        return error.code == eTSErrorNoSpace
            ? [NSString stringWithFormat:@"表盘位 %ld 空间不足，请换一个更大的位置或选择自动", (long)slotIndex]
            : [NSString stringWithFormat:@"表盘位 %ld 不接受这个表盘，请换一个位置或选择自动", (long)slotIndex];
    }
    return error.localizedDescription ?: @"安装未成功完成，请重试";
}

// 指定了表盘位时的提示前缀，例如「安装到表盘位 5。」
- (NSString *)installationTargetPrefix {
    if (!self.installOptions.hasTargetSlot) {
        return @"";
    }
    return [NSString stringWithFormat:@"安装到表盘位 %ld。", (long)self.installOptions.targetSlotIndex];
}

// 制作、造包、传输与设置各阶段由实际回调推进。
- (void)startInstallation {
    NSString *message = [self installationValidationMessage];
    if (message) {
        [self showMessage:message];
        return;
    }
    NSURL *templateURL = self.editorState.templateFileURL;
    NSDictionary *templateAttributes = templateURL ?
        [[NSFileManager defaultManager] attributesOfItemAtPath:templateURL.path error:nil] : nil;
    if (templateURL && (![templateAttributes[NSFileType] isEqual:NSFileTypeRegular] || [templateAttributes fileSize] == 0)) {
        [self showMessage:@"本地模板不可用，请在安装弹窗中更换模板"];
        return;
    }
    self.installationState = [self.editorState copy];
    self.installationVideoRequirements = [[[TopStepComKit sharedInstance].dial dialCapability]
        videoRequirementsForQuality:self.installationState.quality];
    self.installationCancellationCompletesTask = [TopStepComKit sharedInstance].kitOption.sdkType == eTSSDKTypeTPB;
    self.installGeneration++;
    self.installPhase = TSDialEditorInstallPhasePreparing;
    self.cancellationRequested = NO;
    self.builtArtifact = nil;
    self.installedArtifact = nil;
    self.lastInstallError = nil;
    self.installationActivatesDial = [TopStepComKit sharedInstance].kitOption.sdkType == eTSSDKTypeFIT;
    self.installedDeviceDialId = nil;
    [self updateInstallationInteraction];
    [self showInstallationProgress:@"正在准备表盘素材…" progress:-1];
    NSUInteger generation = self.installGeneration;
    __weak typeof(self) weakSelf = self;
    if (self.installationState.draftType == TSDialDraftTypeVideo) {
        TSDialVideoRequirements *requirements = self.installationVideoRequirements;
        CGSize target = requirements ? requirements.inputPixelSize : self.styleConstraint.screenSize;
        TSLogInfo(@"[TSDialEditorVC] startInstallation: videoRequirements generation=%lu quality=%ld available=%d target=%.0fx%.0f maxDurationSeconds=%.3f shape=%ld radius=%.2f supportsAudio=%d audioSelection=%ld",
                  (unsigned long)generation, (long)self.installationState.quality, requirements != nil,
                  target.width, target.height, requirements.maxDuration, (long)requirements.inputShape,
                  requirements.cornerRadius, requirements.supportsAudio, (long)self.installationState.videoAudioSelection);
        [self exportVideoForState:self.installationState completion:^(NSURL *url, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                TSLogWarning(@"[TSDialEditorVC] startInstallation: exportCallback ownerReleased generation=%lu cleanupOutput=%d errorDomain=%@ errorCode=%ld",
                             (unsigned long)generation, url != nil, error.domain ?: @"none", (long)error.code);
                if (url) { [[NSFileManager defaultManager] removeItemAtURL:url error:nil]; }
                return;
            }
            [strongSelf completeVideoExportWithURL:url error:error generation:generation];
        }];
    } else if (self.installationState.draftType == TSDialDraftTypeDanMu) {
        [self prepareDanMuAnimations];
    } else {
        [self buildInstallationDraftWithVideoURL:nil];
    }
}

// 导出结果只归属原安装代次，迟到输出先清理，不能覆盖新任务的文件所有权。
- (void)completeVideoExportWithURL:(NSURL *)url error:(NSError *)error generation:(NSUInteger)generation {
    if (generation != self.installGeneration) {
        TSLogWarning(@"[TSDialEditorVC] completeVideoExportWithURL:error:generation: stale generation=%lu currentGeneration=%lu cleanupOutput=%d errorDomain=%@ errorCode=%ld",
                     (unsigned long)generation, (unsigned long)self.installGeneration, url != nil,
                     error.domain ?: @"none", (long)error.code);
        if (url) { [[NSFileManager defaultManager] removeItemAtURL:url error:nil]; }
        return;
    }
    if (self.cancellationRequested) {
        TSLogInfo(@"[TSDialEditorVC] completeVideoExportWithURL:error:generation: cancellationCompleted generation=%lu quality=%ld cleanupOutput=%d",
                  (unsigned long)generation, (long)self.installationState.quality, url != nil);
        if (url) { [[NSFileManager defaultManager] removeItemAtURL:url error:nil]; }
        [self finishCancellation];
    } else if (error || !url) {
        if (url) { [[NSFileManager defaultManager] removeItemAtURL:url error:nil]; }
        [self failInstallation:error.localizedDescription ?: @"视频处理失败，请重新选择"];
    } else {
        self.exportedVideoURL = url;
        [self buildInstallationDraftWithVideoURL:url];
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

// App 完成选段、方向、裁剪、尺寸与音轨处理，SDK 只接收此次导出的成品。
- (void)exportVideoForState:(TSDialEditorState *)state
                completion:(void (^)(NSURL *url, NSError *error))completion {
    CFTimeInterval exportStartedAt = CACurrentMediaTime();
    NSUInteger generation = self.installGeneration;
    TSDialQuality quality = state.quality;
    AVURLAsset *asset = [AVURLAsset assetWithURL:state.videoURL];
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    TSDialVideoRequirements *requirements = self.installationVideoRequirements;
    CGSize target = requirements ? requirements.inputPixelSize : self.styleConstraint.screenSize;
    NSTimeInterval duration = state.videoEnd - state.videoStart;
    NSTimeInterval sourceDuration = CMTimeGetSeconds(asset.duration);
    TSLogInfo(@"[TSDialEditorVC] exportVideoForState:completion: begin generation=%lu quality=%ld target=%.0fx%.0f durationSeconds=%.3f audioSelection=%ld supportsAudio=%d",
              (unsigned long)generation, (long)quality, target.width, target.height, duration,
              (long)state.videoAudioSelection, requirements.supportsAudio);
    if (!track || !isfinite(target.width) || !isfinite(target.height) ||
        target.width <= 0 || target.height <= 0 || !isfinite(sourceDuration) ||
        !isfinite(state.videoStart) || state.videoStart < 0 || !isfinite(duration) || duration <= 0 ||
        state.videoEnd > sourceDuration + 0.001 ||
        (requirements && (!isfinite(requirements.maxDuration) || duration > requirements.maxDuration))) {
        TSLogWarning(@"[TSDialEditorVC] exportVideoForState:completion: failed generation=%lu quality=%ld stage=inputValidation errorDomain=TSDialEditorErrorDomain errorCode=1002",
                     (unsigned long)generation, (long)quality);
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
        TSLogWarning(@"[TSDialEditorVC] exportVideoForState:completion: failed generation=%lu quality=%ld stage=videoTrack errorDomain=%@ errorCode=%ld",
                     (unsigned long)generation, (long)quality, error.domain ?: @"none", (long)error.code);
        completion(nil, error);
        return;
    }
    // 旧 Provider 仍导出无音轨视频；新合同由 App 选择至多首条轨道，保持原声画时间关系。
    BOOL retainsAudio = requirements.supportsAudio &&
        state.videoAudioSelection != TSDialEditorVideoAudioSelectionMuted;
    AVAssetTrack *audio = retainsAudio ? [asset tracksWithMediaType:AVMediaTypeAudio].firstObject : nil;
    if (audio) {
        CMTimeRange audioRange = CMTimeRangeGetIntersection(range, audio.timeRange);
        if (CMTIMERANGE_IS_VALID(audioRange) && !CMTIMERANGE_IS_EMPTY(audioRange)) {
            AVMutableCompositionTrack *audioDestination = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                preferredTrackID:kCMPersistentTrackID_Invalid];
            if (!audioDestination || ![audioDestination insertTimeRange:audioRange ofTrack:audio
                atTime:CMTimeSubtract(audioRange.start, range.start) error:&error]) {
                TSLogWarning(@"[TSDialEditorVC] exportVideoForState:completion: failed generation=%lu quality=%ld stage=audioTrack errorDomain=%@ errorCode=%ld",
                             (unsigned long)generation, (long)quality, error.domain ?: @"TSDialEditorErrorDomain",
                             error ? (long)error.code : 1002L);
                completion(nil, error ?: [self editorError:@"所选音轨导出失败"]);
                return;
            }
        }
    }
    CGRect rotated = CGRectApplyAffineTransform((CGRect){CGPointZero, track.naturalSize}, track.preferredTransform);
    CGSize orientedSize = CGSizeMake(CGRectGetWidth(rotated), CGRectGetHeight(rotated));
    if (!isfinite(orientedSize.width) || !isfinite(orientedSize.height) ||
        orientedSize.width <= 0 || orientedSize.height <= 0) {
        TSLogWarning(@"[TSDialEditorVC] exportVideoForState:completion: failed generation=%lu quality=%ld stage=orientation errorDomain=TSDialEditorErrorDomain errorCode=1002",
                     (unsigned long)generation, (long)quality);
        completion(nil, [self editorError:@"视频方向或原始尺寸无效"]);
        return;
    }
    CGRect crop = CGRectFromString(state.images.firstObject[@"crop"] ?: NSStringFromCGRect(CGRectZero));
    BOOL hasCrop = isfinite(crop.origin.x) && isfinite(crop.origin.y) &&
        isfinite(crop.size.width) && isfinite(crop.size.height) && crop.size.width > 0 && crop.size.height > 0 &&
        crop.origin.x >= 0 && crop.origin.y >= 0 &&
        CGRectGetMaxX(crop) <= 1.001 && CGRectGetMaxY(crop) <= 1.001;
    if (!CGRectEqualToRect(crop, CGRectZero) && !hasCrop) {
        TSLogWarning(@"[TSDialEditorVC] exportVideoForState:completion: failed generation=%lu quality=%ld stage=cropValidation errorDomain=TSDialEditorErrorDomain errorCode=1002",
                     (unsigned long)generation, (long)quality);
        completion(nil, [self editorError:@"已保存的裁剪区域无效，请重新裁剪视频"]);
        return;
    }
    if (requirements && hasCrop) {
        TSPeripheralScreen *canvas = [[TSPeripheralScreen alloc] init];
        canvas.screenSize = requirements.inputPixelSize;
        canvas.shape = requirements.inputShape;
        canvas.screenBorderRadius = requirements.cornerRadius;
        if (![self videoCropForState:state matchesCanvas:canvas]) {
            TSLogWarning(@"[TSDialEditorVC] exportVideoForState:completion: failed generation=%lu quality=%ld stage=cropConfirmation errorDomain=TSDialEditorErrorDomain errorCode=1002",
                         (unsigned long)generation, (long)quality);
            completion(nil, [self editorError:@"视频画布尚未确认，请重新裁剪视频"]);
            return;
        }
    }
    CGRect cropRect = hasCrop ? CGRectMake(crop.origin.x * orientedSize.width,
                                            crop.origin.y * orientedSize.height,
                                            crop.size.width * orientedSize.width,
                                            crop.size.height * orientedSize.height) :
        (CGRect){CGPointZero, orientedSize};
    cropRect = CGRectIntersection(cropRect, (CGRect){CGPointZero, orientedSize});
    CGFloat scale = MAX(target.width / MAX(1, CGRectGetWidth(cropRect)),
                        target.height / MAX(1, CGRectGetHeight(cropRect)));
    // 已确认选区直接映射到画布，不再 aspect-fill 二次裁掉边缘；无选区保留旧默认填充。
    CGFloat horizontalScale = hasCrop && requirements ? target.width / CGRectGetWidth(cropRect) : scale;
    CGFloat verticalScale = hasCrop && requirements ? target.height / CGRectGetHeight(cropRect) : scale;
    CGAffineTransform transform = track.preferredTransform;
    transform.tx -= CGRectGetMinX(rotated);
    transform.ty -= CGRectGetMinY(rotated);
    transform.a *= horizontalScale;
    transform.b *= verticalScale;
    transform.c *= horizontalScale;
    transform.d *= verticalScale;
    transform.tx = transform.tx * horizontalScale - CGRectGetMinX(cropRect) * horizontalScale +
        (target.width - CGRectGetWidth(cropRect) * horizontalScale) / 2;
    transform.ty = transform.ty * verticalScale - CGRectGetMinY(cropRect) * verticalScale +
        (target.height - CGRectGetHeight(cropRect) * verticalScale) / 2;
    AVMutableVideoCompositionLayerInstruction *layer = [AVMutableVideoCompositionLayerInstruction
                                                       videoCompositionLayerInstructionWithAssetTrack:destination];
    [layer setTransform:transform atTime:kCMTimeZero];
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, range.duration);
    instruction.layerInstructions = @[layer];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = target;
    CGFloat frameRate = requirements && isfinite(track.nominalFrameRate) && track.nominalFrameRate > 0
        ? track.nominalFrameRate : 30;
    videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0 / frameRate, 60000);
    videoComposition.instructions = @[instruction];
    [self applyVideoMaskForRequirements:requirements composition:videoComposition];
    NSString *name = [NSString stringWithFormat:@"ts-dial-%@.mp4", NSUUID.UUID.UUIDString];
    NSURL *output = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:name]];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    if (!session) {
        TSLogWarning(@"[TSDialEditorVC] exportVideoForState:completion: failed generation=%lu quality=%ld stage=createSession errorDomain=TSDialEditorErrorDomain errorCode=1002",
                     (unsigned long)generation, (long)quality);
        completion(nil, [self editorError:@"无法创建视频导出任务"]);
        return;
    }
    self.exportSession = session;
    session.outputURL = output;
    session.outputFileType = AVFileTypeMPEG4;
    session.timeRange = CMTimeRangeMake(kCMTimeZero, range.duration);
    session.videoComposition = videoComposition;
    __weak typeof(self) weakSelf = self;
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSError *outputError = session.error;
        if (session.status == AVAssetExportSessionStatusCompleted) {
            outputError = [weakSelf validationErrorForPreparedVideoURL:output requirements:requirements
                                                        allowsAudio:retainsAudio];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.exportSession == session) { strongSelf.exportSession = nil; }
            if (strongSelf && session.status == AVAssetExportSessionStatusCompleted && !outputError) {
                TSLogInfo(@"[TSDialEditorVC] exportVideoForState:completion: succeeded generation=%lu quality=%ld target=%.0fx%.0f durationSeconds=%.3f audioAllowed=%d elapsedMs=%.0f",
                          (unsigned long)generation, (long)quality, target.width, target.height, duration,
                          retainsAudio, (CACurrentMediaTime() - exportStartedAt) * 1000);
                completion(output, nil);
            } else {
                [[NSFileManager defaultManager] removeItemAtURL:output error:nil];
                NSError *error = outputError ?: [NSError errorWithDomain:@"TSDialEditorErrorDomain" code:1001
                    userInfo:@{NSLocalizedDescriptionKey:@"视频导出已取消"}];
                TSLogWarning(@"[TSDialEditorVC] exportVideoForState:completion: ended generation=%lu quality=%ld status=%ld cancelled=%d ownerReleased=%d cleanupOutput=1 elapsedMs=%.0f errorDomain=%@ errorCode=%ld",
                             (unsigned long)generation, (long)quality, (long)session.status,
                             session.status == AVAssetExportSessionStatusCancelled, strongSelf == nil,
                             (CACurrentMediaTime() - exportStartedAt) * 1000, error.domain, (long)error.code);
                completion(nil, error);
            }
        });
    }];
}

// 把设备要求的黑色边角写入真实视频帧，而不是只给播放器添加显示遮罩。
- (void)applyVideoMaskForRequirements:(TSDialVideoRequirements *)requirements
                         composition:(AVMutableVideoComposition *)composition {
    if (!requirements || (requirements.inputShape != eTSPeriphShapeCircle && requirements.cornerRadius <= 0)) {
        return;
    }
    CGRect bounds = (CGRect){CGPointZero, requirements.inputPixelSize};
    CALayer *canvas = [CALayer layer];
    canvas.frame = bounds;
    canvas.backgroundColor = UIColor.blackColor.CGColor;
    CALayer *video = [CALayer layer];
    video.frame = bounds;
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = bounds;
    CGFloat diameter = MIN(bounds.size.width, bounds.size.height);
    CGRect circleBounds = CGRectMake((bounds.size.width - diameter) / 2,
        (bounds.size.height - diameter) / 2, diameter, diameter);
    UIBezierPath *path = requirements.inputShape == eTSPeriphShapeCircle
        ? [UIBezierPath bezierPathWithOvalInRect:circleBounds]
        : [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:requirements.cornerRadius];
    mask.path = path.CGPath;
    mask.fillColor = UIColor.blackColor.CGColor;
    video.mask = mask;
    [canvas addSublayer:video];
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
        videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:video inLayer:canvas];
}

// 导出结束后重新读取成品，阻止尺寸、音轨或时长不符的文件进入 SDK。
- (NSError *)validationErrorForPreparedVideoURL:(NSURL *)url
                                  requirements:(TSDialVideoRequirements *)requirements
                                   allowsAudio:(BOOL)allowsAudio {
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    NSArray<AVAssetTrack *> *videos = [asset tracksWithMediaType:AVMediaTypeVideo];
    NSArray<AVAssetTrack *> *audios = [asset tracksWithMediaType:AVMediaTypeAudio];
    NSTimeInterval duration = CMTimeGetSeconds(asset.duration);
    if (videos.count != 1 || !isfinite(duration) || duration <= 0 ||
        audios.count > 1 || (!allowsAudio && audios.count != 0)) {
        return [self editorError:@"导出的视频轨道、音轨或时长无效"];
    }
    if (requirements) {
        AVAssetTrack *track = videos.firstObject;
        CGRect oriented = CGRectApplyAffineTransform((CGRect){CGPointZero, track.naturalSize}, track.preferredTransform);
        if (!CGSizeEqualToSize(oriented.size, requirements.inputPixelSize) ||
            duration > requirements.maxDuration + 0.000001) {
            return [self editorError:@"导出结果不符合设备尺寸或时长要求，请调整视频后重试"];
        }
    }
    return nil;
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
        TSDialDraftItem *item = [TSDialDraftItem itemWithVideoFilePath:videoURL.path time:time];
        [items addObject:item];
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
    TSDialDraft *draft = [[TSDialDraft alloc] initWithDraftType:state.draftType
                                          templateFilePath:state.templateFileURL.path items:items];
    draft.quality = state.quality;
    if (state.draftType == TSDialDraftTypeMultipleImage) {
        draft.multiplePlayIntervalMillis = state.interval * 1000;
    }
    if (state.templateFileURL) {
        // 本地模板保留用户的时间设置，由 SDK 重新制作预览，不复用编辑页的合成图。
        self.installationPreview = nil;
        return draft;
    }
    BOOL renderTime = self.capability.shouldRenderTimeInPreview;
    TSLogInfo(@"[TSDialEditorVC] Installation preview: draftType=%ld, supportsComponent=%d, renderTime=%d",
              (long)state.draftType, self.capability.supportsComponent, renderTime);
    self.installationPreview = [self composeInstallationPreview:draft
                                                       videoURL:videoURL
                                                     renderTime:renderTime];
    if (CGSizeEqualToSize(self.installationPreview.size, self.screen.dialPreviewSize)) {
        draft.previewImage = self.installationPreview;
    }
    return draft;
}

// 预览图严格使用 dialPreviewSize，视频取首帧，时间层由调用方显式控制。
- (UIImage *)composeInstallationPreview:(TSDialDraft *)draft
                               videoURL:(NSURL *)videoURL
                             renderTime:(BOOL)renderTime {
    CGSize output = self.screen.dialPreviewSize;
    if (output.width <= 0 || output.height <= 0) {
        output = self.styleConstraint.screenSize;
    }
    UIImage *background = draft.items.firstObject.image;
    if (videoURL) {
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVURLAsset assetWithURL:videoURL]];
        generator.appliesPreferredTrackTransform = YES;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        // 此 URL 已是 App 导出的完整成品；禁止按源片段起点或裁剪区域再处理一次。
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
        // 安装预览图与设备屏幕保持同一外形，圆屏外沿以黑色表示不可见区域。
        CGContextSaveGState(context.CGContext);
        CGContextSetRGBFillColor(context.CGContext, 0, 0, 0, 1);
        CGContextFillRect(context.CGContext, (CGRect){CGPointZero, output});
        if (self.screen.shape == eTSPeriphShapeCircle) {
            CGContextAddEllipseInRect(context.CGContext, (CGRect){CGPointZero, output});
        } else {
            CGFloat radius = self.screen.screenSize.width > 0 ?
                self.screen.screenBorderRadius * output.width / self.screen.screenSize.width : 0;
            CGPathRef path = CGPathCreateWithRoundedRect((CGRect){CGPointZero, output},
                                                         MIN(radius, MIN(output.width, output.height) / 2.0),
                                                         MIN(radius, MIN(output.width, output.height) / 2.0), NULL);
            CGContextAddPath(context.CGContext, path);
            CGPathRelease(path);
        }
        CGContextClip(context.CGContext);
        [background drawInRect:(CGRect){CGPointZero, output}];
        CGRect frame = time.timeRect;
        frame = CGRectMake(frame.origin.x * horizontal, frame.origin.y * vertical,
                           frame.size.width * horizontal, frame.size.height * vertical);
        if (renderTime && time.timeImage) {
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
        CGContextRestoreGState(context.CGContext);
    }];
}

// 造包回调结束后才允许安装，并隔离已经取消或过期的任务。
- (void)buildInstallationDraftWithVideoURL:(NSURL *)url {
    if (self.cancellationRequested) {
        [self finishCancellation];
        return;
    }
    TSDialDraft *draft = [self installationDraftWithVideoURL:url];
    if (!draft) {
        [self failInstallation:@"无法读取源视频尺寸，请重新选择视频"];
        return;
    }
    self.installPhase = TSDialEditorInstallPhaseBuilding;
    [self showInstallationProgress:@"正在制作表盘…" progress:-1];
    NSUInteger generation = self.installGeneration;
    id<TSPeripheralDialInterface> dial = [TopStepComKit sharedInstance].dial;
    __weak typeof(self) weakSelf = self;
    if (draft.draftType == TSDialDraftTypeVideo) {
        TSDialVideoRequirements *requirements = self.installationVideoRequirements;
        CGSize target = requirements ? requirements.inputPixelSize : self.styleConstraint.screenSize;
        TSLogInfo(@"[TSDialEditorVC] buildInstallationDraftWithVideoURL: handoffPreparedVideo generation=%lu quality=%ld hasOutput=%d target=%.0fx%.0f durationSeconds=%.3f audioSelection=%ld supportsAudio=%d",
                  (unsigned long)generation, (long)draft.quality, url != nil, target.width, target.height,
                  self.installationState.videoEnd - self.installationState.videoStart,
                  (long)self.installationState.videoAudioSelection, requirements.supportsAudio);
    }
    [dial buildDialWithDraft:draft completion:^(TSDialArtifact *artifact, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.installGeneration ||
                strongSelf.installPhase != TSDialEditorInstallPhaseBuilding) {
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
                if (strongSelf.installationState.templateFileURL) {
                    [strongSelf reviewBuiltTemplate];
                } else {
                    [strongSelf installBuiltArtifact];
                }
            }
        });
    }];
}

// 本地模板必须查看本轮 SDK 成品预览后再传输，缺少预览不拿旧编辑图冒充。
- (void)reviewBuiltTemplate {
    NSString *previewPath = self.builtArtifact.previewFilePath;
    UIImage *preview = previewPath.length ? [UIImage imageWithContentsOfFile:previewPath] : nil;
    if (!preview) {
        [self failInstallation:@"SDK 未提供可用预览，请更换模板或恢复自动匹配。"];
        return;
    }
    self.installationPreview = preview;
    self.installPhase = TSDialEditorInstallPhaseReviewing;
    [self.progressFill.layer removeAnimationForKey:@"TSDialPreparingProgress"];
    for (UIView *view in self.sheet.contentView.subviews) { [view removeFromSuperview]; }
    self.sheet.title = @"确认制作结果";
    self.sheet.contentHeight = 330;
    self.sheet.allowsDismissal = NO;
    self.sheet.primaryButton.hidden = NO;
    self.sheet.primaryButton.enabled = YES;
    self.sheet.primaryButton.alpha = 1;
    self.sheet.secondaryButton.enabled = YES;
    [self.sheet.primaryButton setTitle:@"确认安装" forState:UIControlStateNormal];
    [self.sheet.secondaryButton setTitle:@"返回调整" forState:UIControlStateNormal];
    CGFloat width = CGRectGetWidth(self.view.bounds) - 40;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:preview];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(0, 0, width, 216);
    [self.sheet.contentView addSubview:imageView];
    UILabel *name = [TSDialEditorAppearance label:self.installationState.templateName ?: @"本地模板" size:13 color:0x252823];
    name.lineBreakMode = NSLineBreakByTruncatingMiddle;
    name.textAlignment = NSTextAlignmentCenter;
    name.frame = CGRectMake(0, 224, width, 22);
    [self.sheet.contentView addSubview:name];
    UILabel *hint = [TSDialEditorAppearance label:[[self installationTargetPrefix]
        stringByAppendingString:@"请确认本次 SDK 制作的预览。确认后开始传输到手表。"] size:12 color:0x82916E];
    hint.numberOfLines = 0;
    hint.textAlignment = NSTextAlignmentCenter;
    hint.frame = CGRectMake(0, 254, width, 64);
    [self.sheet.contentView addSubview:hint];
    __weak typeof(self) weakSelf = self;
    self.sheet.onSecondary = ^{ [weakSelf returnToTemplateConfirmation]; };
    self.sheet.onPrimary = ^{
        if (weakSelf.installPhase != TSDialEditorInstallPhaseReviewing) { return; }
        if (!weakSelf.constraintPeripheral || weakSelf.constraintPeripheral != [TopStepComKit sharedInstance].connectedPeripheral) {
            [weakSelf failInstallation:@"设备连接已变化，请返回编辑后重试"];
            return;
        }
        [weakSelf installBuiltArtifact];
    };
    [self.sheet setNeedsLayout];
}

// 返回安装设置时丢弃本轮制作状态，后续确认始终使用最新模板重新制作。
- (void)returnToTemplateConfirmation {
    self.installPhase = TSDialEditorInstallPhaseIdle;
    [self cleanupExportedVideo];
    self.builtArtifact = nil;
    [self updateInstallationInteraction];
    [self closeSheet];
    [self confirmInstallationWithKnownBytes:0];
}

// SDK 进度只用于显示，完成回调才决定状态。
- (void)installBuiltArtifact {
    self.installPhase = TSDialEditorInstallPhaseInstalling;
    [self showInstallationProgress:@"正在传输表盘 · 0%" progress:0];
    NSUInteger generation = self.installGeneration;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial installDial:self.builtArtifact
        options:self.installOptions
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
                } else if (strongSelf.cancellationRequested && !strongSelf.installationCancellationCompletesTask) {
                    [strongSelf finishCancellation];
                } else {
                    strongSelf.lastInstallError = error;
                    [strongSelf failInstallation:[strongSelf installFailureMessageForError:error]];
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
        [[self installationTargetPrefix] stringByAppendingString:@"请保持手表连接，完成后将自动设为当前表盘。"];
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

// NPK 造包和安装共用真实任务取消，旧 Provider 造包仍等待原回调退出。
- (void)cancelInstallation {
    if (self.installPhase == TSDialEditorInstallPhaseReviewing) {
        [self finishCancellation];
        return;
    }
    if (self.cancellationRequested || self.installPhase == TSDialEditorInstallPhaseSelecting) {
        return;
    }
    self.cancellationRequested = YES;
    [self showInstallationProgress:@"正在取消，请稍候…" progress:-1];
    if (self.installPhase == TSDialEditorInstallPhasePreparing) {
        if (self.installationState.draftType == TSDialDraftTypeVideo) {
            TSLogInfo(@"[TSDialEditorVC] cancelInstallation: cancelVideoExport generation=%lu quality=%ld hasSession=%d status=%ld",
                      (unsigned long)self.installGeneration, (long)self.installationState.quality,
                      self.exportSession != nil, (long)self.exportSession.status);
        }
        [self.exportSession cancelExport];
    } else if (self.installPhase == TSDialEditorInstallPhaseInstalling ||
               (self.installPhase == TSDialEditorInstallPhaseBuilding && self.installationCancellationCompletesTask)) {
        NSUInteger generation = self.installGeneration;
        TSDialEditorInstallPhase phase = self.installPhase;
        __weak typeof(self) weakSelf = self;
        [[TopStepComKit sharedInstance].dial cancelDialInstall:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (generation != weakSelf.installGeneration || weakSelf.installPhase != phase) {
                    return;
                }
                if (!success || error) {
                    weakSelf.cancellationRequested = NO;
                    BOOL mayStillFinish = error.code == eTSErrorIsBusy || error.code == eTSErrorNotReady;
                    if (weakSelf.installationCancellationCompletesTask && !mayStillFinish) {
                        // NPK 的取消 ACK 失败也已释放本地任务，不能继续等待被抑制的原回调。
                        [weakSelf failInstallation:error.localizedDescription ?: @"取消未获设备确认，本地任务已结束"];
                    } else {
                        // END、重复取消或终态竞争会拒绝取消，仍由原业务终态给出结果。
                        [weakSelf showInstallationProgress:@"取消未生效，等待任务结果…" progress:-1];
                    }
                } else if (weakSelf.installationCancellationCompletesTask) {
                    [weakSelf finishCancellation];
                }
                // 旧 Provider 仍等待原安装终态，NPK 已在取消完成前等待内部退出。
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
    BOOL templateFailed = self.installationState.templateFileURL && self.installPhase == TSDialEditorInstallPhaseBuilding;
    self.installPhase = TSDialEditorInstallPhaseFailed;
    self.cancellationRequested = NO;
    [self cleanupExportedVideo];
    [self updateInstallationInteraction];
    self.sheet.title = self.installedArtifact ? @"设置未完成" : @"安装未完成";
    [self showResultMessage:message success:NO];
    // 指定的表盘位被拒绝时回到选位，其余失败按原选择重试
    BOOL slotRejected = !self.installedArtifact && [self isSlotRejection:self.lastInstallError];
    if (slotRejected) {
        [self.rejectedSlotIndexes addObject:@(self.installOptions.targetSlotIndex)];
    }
    NSString *primaryTitle = self.installedArtifact ? @"设为当前表盘" : slotRejected ? @"重新选择位置" :
        templateFailed ? @"更换模板" : @"重试";
    [self.sheet.primaryButton setTitle:primaryTitle forState:UIControlStateNormal];
    [self.sheet.secondaryButton setTitle:@"返回编辑" forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    self.sheet.onSecondary = ^{ [weakSelf closeSheet]; };
    self.sheet.onPrimary = ^{
        if (weakSelf.installedArtifact) {
            [weakSelf selectInstalledArtifact];
        } else if (slotRejected) {
            [weakSelf reselectInstallSlot];
        } else if (templateFailed) {
            [weakSelf returnToTemplateConfirmation];
            [weakSelf chooseTemplateSource];
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
    NSString *resultMessage = self.installOptions.hasTargetSlot
        ? [NSString stringWithFormat:@"已安装到表盘位 %ld，并设为当前表盘", (long)self.installOptions.targetSlotIndex]
        : @"已设为当前表盘";
    [self showResultMessage:resultMessage success:YES];
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
    self.sheet.primaryButton.alpha = 1;
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

// 模板与 GIF 使用独立的选择器身份，避免把模板误当作弹幕图片。
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (controller == self.templatePicker) {
        self.templatePicker = nil;
        [self importSelectedTemplate:urls.firstObject];
        return;
    }
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

// 取消系统文件选择保持当前模板和安装位置。
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if (controller == self.templatePicker) {
        self.templatePicker = nil;
    }
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

// 画质选项只在能力列表非空时展示。
- (UIButton *)qualityButton {
    if (!_qualityButton) {
        _qualityButton = [TSDialEditorAppearance button:@"画质：设备默认" primary:NO];
        [_qualityButton addTarget:self action:@selector(chooseQuality) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qualityButton;
}

// 新视频处理能力提供的音轨选项。
- (UIButton *)videoAudioButton {
    if (!_videoAudioButton) {
        _videoAudioButton = [TSDialEditorAppearance button:@"音轨：设备默认" primary:NO];
        [_videoAudioButton addTarget:self action:@selector(chooseVideoAudio) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoAudioButton;
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

// 被拒绝过的表盘位。
- (NSMutableSet<NSNumber *> *)rejectedSlotIndexes {
    if (!_rejectedSlotIndexes) {
        _rejectedSlotIndexes = [NSMutableSet set];
    }
    return _rejectedSlotIndexes;
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
