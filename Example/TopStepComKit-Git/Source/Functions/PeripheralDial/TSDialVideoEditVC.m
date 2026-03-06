//
//  TSDialVideoEditVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDialVideoEditVC.h"
#import <AVFoundation/AVFoundation.h>

// 布局常量
static const CGFloat kVEBarH          = 72.f;   // 底部操作栏
static const CGFloat kVETimelineH     = 56.f;   // 时间轴高度
static const CGFloat kVEThumbH        = 48.f;   // 缩略图高度
static const CGFloat kVEHandleW       = 20.f;   // 拖拽手柄宽度
static const CGFloat kVETimeLabelH    = 20.f;   // 时间标签高度
static const CGFloat kVETimeLabelGap  = 4.f;    // 时间标签与时间轴间距

// 颜色
#define kVEPrimary      [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f]
#define kVEHighlight    [UIColor colorWithRed:255/255.f green:214/255.f blue:10/255.f alpha:0.7f]

/**
 * 可拖拽手柄视图（左 / 右）
 */
@interface TSVideoTrimHandle : UIView
@end
@implementation TSVideoTrimHandle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor    = UIColor.whiteColor;
        self.layer.cornerRadius = 3.f;
        // 竖向三条短线
        UIView *line1 = [self makeLine];
        UIView *line2 = [self makeLine];
        UIView *line3 = [self makeLine];
        CGFloat lw = 2, lh = 16, spacing = 2.5f;
        CGFloat totalW = lw * 3 + spacing * 2;
        CGFloat startX = (kVEHandleW - totalW) / 2.f;
        CGFloat startY = (frame.size.height - lh) / 2.f;
        line1.frame = CGRectMake(startX, startY, lw, lh);
        line2.frame = CGRectMake(startX + lw + spacing, startY, lw, lh);
        line3.frame = CGRectMake(startX + lw * 2 + spacing * 2, startY, lw, lh);
        [self addSubview:line1];
        [self addSubview:line2];
        [self addSubview:line3];
    }
    return self;
}
- (UIView *)makeLine {
    UIView *v = [[UIView alloc] init];
    v.backgroundColor    = [UIColor colorWithWhite:0.3f alpha:1.f];
    v.layer.cornerRadius = 1.f;
    return v;
}
@end

// ─────────────────────────────────────────────────────────────────────────────
@interface TSDialVideoEditVC ()

// 原始数据
@property (nonatomic, strong) NSURL     *videoURL;
@property (nonatomic, assign) CGFloat    aspectRatio;
@property (nonatomic, assign) NSInteger  maxDuration;
@property (nonatomic, assign) Float64    videoDuration;  // 视频总时长（秒）

// AVPlayer
@property (nonatomic, strong) AVPlayer         *player;
@property (nonatomic, strong) AVPlayerLayer    *playerLayer;
@property (nonatomic, strong) id                timeObserver;

// 视图
@property (nonatomic, strong) UIView             *bgView;
@property (nonatomic, strong) UIView             *previewContainer;  // 包含 playerLayer
@property (nonatomic, strong) UIView             *cropOverlay;        // 白色边框裁剪框
@property (nonatomic, strong) UIView             *timelineContainer;
@property (nonatomic, strong) UIScrollView       *thumbScrollView;    // 缩略图滚动视图
@property (nonatomic, strong) UIView             *rangeHighlight;     // 高亮已选区间
@property (nonatomic, strong) TSVideoTrimHandle  *leftHandle;
@property (nonatomic, strong) TSVideoTrimHandle  *rightHandle;
@property (nonatomic, strong) UIView             *playhead;           // 播放进度线
@property (nonatomic, strong) UILabel            *startTimeLabel;
@property (nonatomic, strong) UILabel            *endTimeLabel;
@property (nonatomic, strong) UILabel            *durationLabel;      // 已选时长提示
@property (nonatomic, strong) UIView             *bottomBar;
@property (nonatomic, strong) UIButton           *cancelBtn;
@property (nonatomic, strong) UIButton           *resetBtn;
@property (nonatomic, strong) UIButton           *doneBtn;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

// 裁剪状态
@property (nonatomic, assign) Float64  trimStart;      // 已选起始时间（秒）
@property (nonatomic, assign) Float64  trimEnd;        // 已选结束时间（秒）
@property (nonatomic, assign) CGFloat  timelineInnerW; // 时间轴可用宽度（手柄之间）
@property (nonatomic, assign) BOOL     videoLoaded;    // 防止重复加载

@end

@implementation TSDialVideoEditVC

#pragma mark - 初始化

- (instancetype)initWithVideoURL:(NSURL *)videoURL
                     aspectRatio:(CGFloat)aspectRatio
                     maxDuration:(NSInteger)maxDuration {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _videoURL    = videoURL;
        _aspectRatio = (aspectRatio > 0) ? aspectRatio : 1.0f;
        _maxDuration = (maxDuration > 0) ? maxDuration : 10;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    [self setupViews];
    // loadVideo 在 viewDidAppear 执行，保证 layoutViews 已完成（timelineInnerW 已初始化）
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.videoLoaded) {
        self.videoLoaded = YES;
        [self loadVideo];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.player pause];
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)dealloc {
    [self.player pause];
}

#pragma mark - 视图构建

- (void)setupViews {
    [self.view addSubview:self.bgView];
    [self.bgView addSubview:self.previewContainer];
    [self.bgView addSubview:self.cropOverlay];
    [self.bgView addSubview:self.timelineContainer];
    [self.timelineContainer addSubview:self.thumbScrollView];
    [self.timelineContainer addSubview:self.rangeHighlight];
    [self.timelineContainer addSubview:self.leftHandle];
    [self.timelineContainer addSubview:self.rightHandle];
    [self.timelineContainer addSubview:self.playhead];
    [self.timelineContainer addSubview:self.startTimeLabel];
    [self.timelineContainer addSubview:self.endTimeLabel];
    [self.timelineContainer addSubview:self.durationLabel];
    [self.view addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.cancelBtn];
    [self.bottomBar addSubview:self.resetBtn];
    [self.bottomBar addSubview:self.doneBtn];
    [self.view addSubview:self.spinner];

    // 手柄拖拽手势
    UIPanGestureRecognizer *leftPan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleLeftPan:)];
    [self.leftHandle addGestureRecognizer:leftPan];

    UIPanGestureRecognizer *rightPan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleRightPan:)];
    [self.rightHandle addGestureRecognizer:rightPan];
}

- (void)layoutViews {
    CGFloat w  = CGRectGetWidth(self.view.bounds);
    CGFloat h  = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat safeTop    = self.view.safeAreaInsets.top;
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;

    // 底部操作栏
    CGFloat barH = kVEBarH + safeBottom;
    self.bottomBar.frame = CGRectMake(0, h - barH, w, barH);

    CGFloat btnW = 72.f;
    self.cancelBtn.frame = CGRectMake(16, 0, btnW, kVEBarH);
    self.resetBtn.frame  = CGRectMake((w - btnW) / 2.f, 0, btnW, kVEBarH);
    self.doneBtn.frame   = CGRectMake(w - btnW - 16, 0, btnW, kVEBarH);
    self.spinner.center  = CGPointMake(w / 2.f, h / 2.f);

    // 时间轴区域
    CGFloat timelineY = h - barH - kVETimeLabelH - kVETimeLabelGap - kVETimelineH - 12;
    self.timelineContainer.frame = CGRectMake(0, timelineY, w, kVETimelineH + kVETimeLabelH + kVETimeLabelGap);

    // 背景区（视频预览 + 时间轴以上）
    CGFloat bgH = timelineY - safeTop;
    self.bgView.frame = CGRectMake(0, safeTop, w, bgH);

    // 视频预览框：居中，保持表盘比例
    CGFloat previewMaxW = w - 32;
    CGFloat previewMaxH = bgH - 32;
    CGFloat previewW, previewH;
    if ((previewMaxH / previewMaxW) >= self.aspectRatio) {
        previewW = previewMaxW;
        previewH = previewW * self.aspectRatio;
    } else {
        previewH = previewMaxH;
        previewW = previewH / self.aspectRatio;
    }
    CGFloat previewX = (w - previewW) / 2.f;
    CGFloat previewY = (bgH - previewH) / 2.f;
    self.previewContainer.frame = CGRectMake(previewX, previewY, previewW, previewH);
    self.playerLayer.frame      = self.previewContainer.bounds;
    self.cropOverlay.frame      = self.previewContainer.frame;

    // 时间轴内部布局
    CGFloat tlW = w;
    CGFloat handX_L = kVEHandleW;          // 左手柄位置
    CGFloat handX_R = tlW - kVEHandleW * 2; // 右手柄位置（从左手柄算）
    CGFloat thumbY  = 0;

    // 缩略图背景
    self.thumbScrollView.frame = CGRectMake(kVEHandleW, thumbY,
                                            tlW - kVEHandleW * 2, kVEThumbH);
    self.timelineInnerW = tlW - kVEHandleW * 2;

    // 范围高亮（初始为全宽）
    self.rangeHighlight.frame = CGRectMake(kVEHandleW, thumbY,
                                           tlW - kVEHandleW * 2, kVEThumbH);

    // 左右手柄
    self.leftHandle.frame  = CGRectMake(0, thumbY, kVEHandleW, kVEThumbH);
    self.rightHandle.frame = CGRectMake(tlW - kVEHandleW, thumbY, kVEHandleW, kVEThumbH);

    // 播放进度线
    self.playhead.frame = CGRectMake(kVEHandleW, thumbY, 2, kVEThumbH);

    // 时间标签
    CGFloat labelY = kVEThumbH + kVETimeLabelGap;
    self.startTimeLabel.frame    = CGRectMake(0, labelY, 60, kVETimeLabelH);
    self.endTimeLabel.frame      = CGRectMake(tlW - 60, labelY, 60, kVETimeLabelH);
    self.durationLabel.frame     = CGRectMake((tlW - 80) / 2.f, labelY, 80, kVETimeLabelH);

    (void)handX_L; (void)handX_R; // suppress unused warning
    [self updateHandlePositions];
}

#pragma mark - 视频加载

/** 加载视频：异步获取 duration 后再初始化播放器和 UI */
- (void)loadVideo {
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.videoURL];
    __weak typeof(self) wself = self;

    // 异步加载 duration（避免主线程阻塞或获取到 kCMTimeIndefinite）
    [asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wself) sself = wself;
            if (!sself) return;

            NSError *err = nil;
            AVKeyValueStatus status = [asset statusOfValueForKey:@"duration" error:&err];
            if (status == AVKeyValueStatusLoaded) {
                sself.videoDuration = CMTimeGetSeconds(asset.duration);
            }
            if (sself.videoDuration <= 0) {
                sself.videoDuration = (Float64)sself.maxDuration;
            }

            // 裁剪范围：[0, min(maxDuration, totalDuration)]
            sself.trimStart = 0;
            sself.trimEnd   = MIN((Float64)sself.maxDuration, sself.videoDuration);

            // 创建 AVPlayer
            AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
            sself.player = [AVPlayer playerWithPlayerItem:item];
            sself.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [sself.playerLayer setPlayer:sself.player];

            // 监听播放结束以实现循环
            [[NSNotificationCenter defaultCenter]
                addObserver:sself
                   selector:@selector(playerItemDidReachEnd:)
                       name:AVPlayerItemDidPlayToEndTimeNotification
                     object:item];

            // 定期更新播放头
            CMTime interval = CMTimeMakeWithSeconds(0.05, NSEC_PER_SEC);
            sself.timeObserver = [sself.player addPeriodicTimeObserverForInterval:interval
                                                                            queue:dispatch_get_main_queue()
                                                                       usingBlock:^(CMTime time) {
                [wself updatePlayheadForTime:CMTimeGetSeconds(time)];
            }];

            // playerLayer 此时已有正确 frame（layoutViews 已执行），开始播放
            [sself.player play];

            // 更新时间轴手柄位置（此时 timelineInnerW 已由 layoutViews 赋值）
            [sself updateHandlePositions];
            [sself updateTimeLabelsWith:sself.trimStart end:sself.trimEnd];
            [sself generateThumbnailsForAsset:asset];
        });
    }];
}

/** 视频播到结尾时从 trimStart 重新播放 */
- (void)playerItemDidReachEnd:(NSNotification *)note {
    [self.player seekToTime:CMTimeMakeWithSeconds(self.trimStart, NSEC_PER_SEC)
          toleranceBefore:kCMTimeZero
           toleranceAfter:kCMTimeZero];
    [self.player play];
}

#pragma mark - 缩略图生成

/** 使用 AVAssetImageGenerator 生成时间轴缩略图 */
- (void)generateThumbnailsForAsset:(AVAsset *)asset {
    AVAssetImageGenerator *gen = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    gen.maximumSize = CGSizeMake(50, 60);

    NSInteger count     = 8;
    NSMutableArray *times = [NSMutableArray array];
    for (NSInteger i = 0; i < count; i++) {
        Float64 t = (self.videoDuration * i) / (Float64)(count - 1);
        [times addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(t, NSEC_PER_SEC)]];
    }

    NSInteger __block idx = 0;
    CGFloat thumbW = self.timelineInnerW / count;
    if (thumbW <= 0) thumbW = 40;
    __weak typeof(self) wself = self;

    [gen generateCGImagesAsynchronouslyForTimes:times
                              completionHandler:^(CMTime requestedTime,
                                                  CGImageRef cgImage,
                                                  CMTime actualTime,
                                                  AVAssetImageGeneratorResult result,
                                                  NSError *error) {
        if (result == AVAssetImageGeneratorSucceeded && cgImage) {
            UIImage *img = [UIImage imageWithCGImage:cgImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                iv.contentMode  = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                NSInteger i2 = idx;
                iv.frame = CGRectMake(thumbW * i2, 0, thumbW, kVEThumbH);
                [wself.thumbScrollView addSubview:iv];
            });
        }
        idx++;
    }];
}

#pragma mark - 手柄拖拽

- (void)handleLeftPan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.timelineContainer];
    [pan setTranslation:CGPointZero inView:self.timelineContainer];

    CGRect f  = self.leftHandle.frame;
    CGFloat newX = CGRectGetMinX(f) + translation.x;
    CGFloat maxX = CGRectGetMinX(self.rightHandle.frame) - kVEHandleW;
    // 不超过右手柄，不超出左边界
    newX = MAX(0, MIN(newX, maxX));

    self.leftHandle.frame = CGRectMake(newX, f.origin.y, f.size.width, f.size.height);
    self.trimStart = [self timeForHandleX:newX + kVEHandleW];
    [self updateRangeHighlight];
    [self updateTimeLabelsWith:self.trimStart end:self.trimEnd];
    // 跳转播放位置
    [self.player seekToTime:CMTimeMakeWithSeconds(self.trimStart, NSEC_PER_SEC)
          toleranceBefore:kCMTimeZero
           toleranceAfter:kCMTimeZero];
}

- (void)handleRightPan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.timelineContainer];
    [pan setTranslation:CGPointZero inView:self.timelineContainer];

    CGRect  f    = self.rightHandle.frame;
    CGFloat newX = CGRectGetMinX(f) + translation.x;
    CGFloat minX = CGRectGetMaxX(self.leftHandle.frame);
    CGFloat maxX = CGRectGetWidth(self.timelineContainer.bounds) - kVEHandleW;
    newX = MAX(minX, MIN(newX, maxX));

    self.rightHandle.frame = CGRectMake(newX, f.origin.y, f.size.width, f.size.height);
    self.trimEnd = [self timeForHandleX:newX];
    // 强制最大时长限制
    if ((self.trimEnd - self.trimStart) > (Float64)self.maxDuration) {
        self.trimEnd = self.trimStart + (Float64)self.maxDuration;
        self.rightHandle.frame = CGRectMake(
            [self xForTime:self.trimEnd], f.origin.y, f.size.width, f.size.height);
    }
    [self updateRangeHighlight];
    [self updateTimeLabelsWith:self.trimStart end:self.trimEnd];
}

#pragma mark - 辅助计算

/** 根据时间（秒）计算手柄在时间轴中的 x 坐标 */
- (CGFloat)xForTime:(Float64)t {
    if (self.videoDuration <= 0) return kVEHandleW;
    return kVEHandleW + (t / self.videoDuration) * self.timelineInnerW;
}

/** 根据手柄 x 坐标反算时间（秒） */
- (Float64)timeForHandleX:(CGFloat)x {
    if (self.timelineInnerW <= 0) return 0;
    CGFloat ratio = (x - kVEHandleW) / self.timelineInnerW;
    return MAX(0, MIN(self.videoDuration, ratio * self.videoDuration));
}

/** 更新高亮区间 frame */
- (void)updateRangeHighlight {
    CGFloat leftX   = CGRectGetMaxX(self.leftHandle.frame);
    CGFloat rightX  = CGRectGetMinX(self.rightHandle.frame);
    CGFloat y       = self.leftHandle.frame.origin.y;
    CGFloat h       = self.leftHandle.frame.size.height;
    self.rangeHighlight.frame = CGRectMake(leftX, y, MAX(0, rightX - leftX), h);
}

/** 根据当前播放时间更新进度线位置 */
- (void)updatePlayheadForTime:(Float64)t {
    CGFloat x = [self xForTime:t];
    self.playhead.frame = CGRectMake(x, 0, 2, kVEThumbH);
}

/** 更新手柄位置（在 layoutViews 中调用） */
- (void)updateHandlePositions {
    if (self.videoDuration <= 0) return;
    CGFloat lx = [self xForTime:self.trimStart] - kVEHandleW;
    CGFloat rx = [self xForTime:self.trimEnd];
    CGFloat h  = kVEThumbH;
    self.leftHandle.frame  = CGRectMake(lx, 0, kVEHandleW, h);
    self.rightHandle.frame = CGRectMake(rx, 0, kVEHandleW, h);
    [self updateRangeHighlight];
}

/** 更新时间标签文字 */
- (void)updateTimeLabelsWith:(Float64)start end:(Float64)end {
    self.startTimeLabel.text  = [self formatTime:start];
    self.endTimeLabel.text    = [self formatTime:end];
    Float64 dur = end - start;
    self.durationLabel.text   = [NSString stringWithFormat:@"%.1fs", dur];
}

/** 格式化秒数为 mm:ss */
- (NSString *)formatTime:(Float64)seconds {
    NSInteger s = (NSInteger)seconds;
    return [NSString stringWithFormat:@"%02d:%02d", s / 60, s % 60];
}

#pragma mark - 按钮回调

/** 取消 */
- (void)onCancelTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 还原裁剪范围为初始值 */
- (void)onResetTapped {
    self.trimStart = 0;
    self.trimEnd   = MIN((Float64)self.maxDuration, self.videoDuration);
    [self updateHandlePositions];
    [self updateTimeLabelsWith:self.trimStart end:self.trimEnd];
}

/** 完成 → 导出裁剪后视频 */
- (void)onDoneTapped {
    self.doneBtn.enabled = NO;
    [self.spinner startAnimating];
    [self exportTrimmedVideoWithCompletion:^(NSURL *outputURL) {
        [self.spinner stopAnimating];
        self.doneBtn.enabled = YES;
        if (outputURL && self.onEditComplete) {
            self.onEditComplete(outputURL);
        } else {
            UIAlertController *alert =
                [UIAlertController alertControllerWithTitle:@"导出失败"
                                                    message:@"视频处理出错，请重试"
                                             preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

#pragma mark - 视频导出

/** 使用 AVAssetExportSession 导出裁剪后视频 */
- (void)exportTrimmedVideoWithCompletion:(void(^)(NSURL *outputURL))completion {
    AVAsset *asset = [AVAsset assetWithURL:self.videoURL];
    NSString *tmpPath = [NSTemporaryDirectory()
                         stringByAppendingPathComponent:@"ts_dial_trim.mp4"];
    NSURL *outputURL = [NSURL fileURLWithPath:tmpPath];
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];

    AVAssetExportSession *session =
        [[AVAssetExportSession alloc] initWithAsset:asset
                                         presetName:AVAssetExportPresetHighestQuality];
    session.outputURL      = outputURL;
    session.outputFileType = AVFileTypeMPEG4;
    session.timeRange      = CMTimeRangeMake(
        CMTimeMakeWithSeconds(self.trimStart, NSEC_PER_SEC),
        CMTimeMakeWithSeconds(self.trimEnd - self.trimStart, NSEC_PER_SEC));

    [session exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (session.status == AVAssetExportSessionStatusCompleted) {
                completion(outputURL);
            } else {
                completion(nil);
            }
        });
    }];
}

#pragma mark - 懒加载

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColor.blackColor;
    }
    return _bgView;
}

- (UIView *)previewContainer {
    if (!_previewContainer) {
        _previewContainer = [[UIView alloc] init];
        _previewContainer.backgroundColor = UIColor.blackColor;
        _previewContainer.clipsToBounds   = YES;
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [_previewContainer.layer addSublayer:self.playerLayer];
    }
    return _previewContainer;
}

- (UIView *)cropOverlay {
    if (!_cropOverlay) {
        _cropOverlay = [[UIView alloc] init];
        _cropOverlay.backgroundColor   = UIColor.clearColor;
        _cropOverlay.layer.borderColor  = [UIColor colorWithWhite:1 alpha:0.8f].CGColor;
        _cropOverlay.layer.borderWidth  = 1.5f;
        _cropOverlay.userInteractionEnabled = NO;
    }
    return _cropOverlay;
}

- (UIView *)timelineContainer {
    if (!_timelineContainer) {
        _timelineContainer = [[UIView alloc] init];
        _timelineContainer.backgroundColor = [UIColor colorWithWhite:0.1f alpha:1.f];
        _timelineContainer.clipsToBounds   = YES;
    }
    return _timelineContainer;
}

- (UIScrollView *)thumbScrollView {
    if (!_thumbScrollView) {
        _thumbScrollView = [[UIScrollView alloc] init];
        _thumbScrollView.scrollEnabled = NO;
        _thumbScrollView.clipsToBounds = YES;
        _thumbScrollView.backgroundColor = [UIColor colorWithWhite:0.15f alpha:1.f];
    }
    return _thumbScrollView;
}

- (UIView *)rangeHighlight {
    if (!_rangeHighlight) {
        _rangeHighlight = [[UIView alloc] init];
        _rangeHighlight.backgroundColor   = kVEHighlight;
        _rangeHighlight.userInteractionEnabled = NO;
    }
    return _rangeHighlight;
}

- (TSVideoTrimHandle *)leftHandle {
    if (!_leftHandle) {
        _leftHandle = [[TSVideoTrimHandle alloc] initWithFrame:CGRectMake(0, 0, kVEHandleW, kVEThumbH)];
        _leftHandle.layer.cornerRadius = 4.f;
    }
    return _leftHandle;
}

- (TSVideoTrimHandle *)rightHandle {
    if (!_rightHandle) {
        _rightHandle = [[TSVideoTrimHandle alloc] initWithFrame:CGRectMake(0, 0, kVEHandleW, kVEThumbH)];
        _rightHandle.layer.cornerRadius = 4.f;
    }
    return _rightHandle;
}

- (UIView *)playhead {
    if (!_playhead) {
        _playhead = [[UIView alloc] init];
        _playhead.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9f];
        _playhead.layer.cornerRadius = 1.f;
        _playhead.userInteractionEnabled = NO;
    }
    return _playhead;
}

- (UILabel *)startTimeLabel {
    if (!_startTimeLabel) {
        _startTimeLabel = [[UILabel alloc] init];
        _startTimeLabel.font          = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightRegular];
        _startTimeLabel.textColor     = [UIColor colorWithWhite:0.8f alpha:1.f];
        _startTimeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _startTimeLabel;
}

- (UILabel *)endTimeLabel {
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] init];
        _endTimeLabel.font          = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightRegular];
        _endTimeLabel.textColor     = [UIColor colorWithWhite:0.8f alpha:1.f];
        _endTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _endTimeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font          = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightMedium];
        _durationLabel.textColor     = kVEHighlight;
        _durationLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _durationLabel;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = [UIColor colorWithWhite:0.08f alpha:1.f];
    }
    return _bottomBar;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithWhite:0.75f alpha:1.f]
                         forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelBtn addTarget:self action:@selector(onCancelTapped)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        _resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_resetBtn setTitle:@"还原" forState:UIControlStateNormal];
        [_resetBtn setTitleColor:[UIColor colorWithWhite:0.75f alpha:1.f]
                        forState:UIControlStateNormal];
        _resetBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_resetBtn addTarget:self action:@selector(onResetTapped)
            forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithRed:0/255.f
                                               green:122/255.f
                                                blue:255/255.f
                                               alpha:1.f]
                       forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [_doneBtn addTarget:self action:@selector(onDoneTapped)
           forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _spinner.color = UIColor.whiteColor;
        _spinner.hidesWhenStopped = YES;
    }
    return _spinner;
}

@end
