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
@property (nonatomic, assign) CGSize     videoNaturalSize; // 视频原始尺寸

// AVPlayer
@property (nonatomic, strong) AVPlayer         *player;
@property (nonatomic, strong) AVPlayerLayer    *playerLayer;
@property (nonatomic, strong) id                timeObserver;

// 视图
@property (nonatomic, strong) UIScrollView       *scrollView;
@property (nonatomic, strong) UIView             *contentView;
@property (nonatomic, strong) UIView             *sizeCard;
@property (nonatomic, strong) UILabel            *sizeCardTitle;
@property (nonatomic, strong) UIView             *previewContainer;  // 包含 playerLayer
@property (nonatomic, strong) UIView             *cropOverlay;        // 白色边框裁剪框
@property (nonatomic, strong) UILabel            *sizeLabel;          // 显示目标尺寸
@property (nonatomic, strong) UIView             *durationCard;
@property (nonatomic, strong) UILabel            *durationCardTitle;
@property (nonatomic, strong) UIView             *timelineContainer;
@property (nonatomic, strong) UIScrollView       *thumbScrollView;    // 缩略图滚动视图
@property (nonatomic, strong) UIView             *rangeHighlight;     // 高亮已选区间
@property (nonatomic, strong) TSVideoTrimHandle  *leftHandle;
@property (nonatomic, strong) TSVideoTrimHandle  *rightHandle;
@property (nonatomic, strong) UIView             *playhead;           // 播放进度线
@property (nonatomic, strong) UILabel            *startTimeLabel;
@property (nonatomic, strong) UILabel            *endTimeLabel;
@property (nonatomic, strong) UILabel            *selectedDurationLabel; // 已选时长提示
@property (nonatomic, strong) UIView             *bottomBar;
@property (nonatomic, strong) UIButton           *cancelBtn;
@property (nonatomic, strong) UIButton           *doneBtn;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

// 裁剪状态 - 时长
@property (nonatomic, assign) Float64  trimStart;      // 已选起始时间（秒）
@property (nonatomic, assign) Float64  trimEnd;        // 已选结束时间（秒）
@property (nonatomic, assign) CGFloat  timelineInnerW; // 时间轴可用宽度（手柄之间）

// 裁剪状态 - 尺寸
@property (nonatomic, assign) CGFloat  videoScale;     // 视频缩放比例
@property (nonatomic, assign) CGPoint  videoOffset;    // 视频偏移量
@property (nonatomic, assign) CGFloat  minScale;       // 最小缩放比例
@property (nonatomic, assign) CGFloat  maxScale;       // 最大缩放比例

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

        // 初始化裁剪状态
        _videoScale  = 1.0f;
        _videoOffset = CGPointZero;
        _minScale    = 0.5f;
        _maxScale    = 3.0f;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.05f alpha:1.f];
    self.title = @"视频编辑";
    [self setupViews];
    [self setupGestures];
    // loadVideo 在 viewDidAppear 执行，保证 layoutViews 已完成
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 保持导航栏显示
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
    // 滚动视图
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.contentView];

    // 视频尺寸卡片
    [self.contentView addSubview:self.sizeCard];
    [self.sizeCard addSubview:self.sizeCardTitle];
    [self.sizeCard addSubview:self.previewContainer];
    [self.sizeCard addSubview:self.cropOverlay];
    [self.sizeCard addSubview:self.sizeLabel];

    // 视频时长卡片
    [self.contentView addSubview:self.durationCard];
    [self.durationCard addSubview:self.durationCardTitle];
    [self.durationCard addSubview:self.timelineContainer];
    [self.timelineContainer addSubview:self.thumbScrollView];
    [self.timelineContainer addSubview:self.rangeHighlight];
    [self.timelineContainer addSubview:self.leftHandle];
    [self.timelineContainer addSubview:self.rightHandle];
    [self.timelineContainer addSubview:self.playhead];
    [self.timelineContainer addSubview:self.startTimeLabel];
    [self.timelineContainer addSubview:self.endTimeLabel];
    [self.timelineContainer addSubview:self.selectedDurationLabel];

    // 底部按钮栏
    [self.view addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.cancelBtn];
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

- (void)setupGestures {
    // 拖动手势
    UIPanGestureRecognizer *panGesture =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleVideoPan:)];
    [self.previewContainer addGestureRecognizer:panGesture];

    // 缩放手势
    UIPinchGestureRecognizer *pinchGesture =
        [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleVideoPinch:)];
    [self.previewContainer addGestureRecognizer:pinchGesture];
}

- (void)layoutViews {
    CGFloat w  = CGRectGetWidth(self.view.bounds);
    CGFloat h  = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat safeTop    = self.view.safeAreaInsets.top;
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;
    CGFloat navBarH    = self.navigationController.navigationBar.frame.size.height;
    CGFloat topOffset  = safeTop + navBarH;

    // 底部操作栏
    CGFloat barH = kVEBarH + safeBottom;
    self.bottomBar.frame = CGRectMake(0, h - barH, w, barH);

    CGFloat btnW = 100.f;
    self.cancelBtn.frame = CGRectMake(16, 0, btnW, kVEBarH);
    self.doneBtn.frame   = CGRectMake(w - btnW - 16, 0, btnW, kVEBarH);
    self.spinner.center  = CGPointMake(w / 2.f, h / 2.f);

    // 滚动视图
    CGFloat scrollH = h - topOffset - barH;
    self.scrollView.frame = CGRectMake(0, topOffset, w, scrollH);

    // 内容视图
    CGFloat padH = 16.f;
    CGFloat padV = 12.f;
    CGFloat cardW = w - padH * 2;
    CGFloat y = padV;

    // ── 视频尺寸卡片 ──
    CGFloat previewH = MIN(300.f, scrollH * 0.4f);
    CGFloat sizeCardH = 44 + previewH + 32 + padV;
    self.sizeCard.frame = CGRectMake(padH, y, cardW, sizeCardH);
    self.sizeCardTitle.frame = CGRectMake(padH, 0, cardW - padH * 2, 44);

    // 预览容器（保持表盘比例）
    CGFloat previewW = previewH / self.aspectRatio;
    if (previewW > cardW - padH * 2) {
        previewW = cardW - padH * 2;
        previewH = previewW * self.aspectRatio;
    }
    CGFloat previewX = (cardW - previewW) / 2.f;
    self.previewContainer.frame = CGRectMake(previewX, 44, previewW, previewH);
    self.playerLayer.frame = self.previewContainer.bounds;
    self.cropOverlay.frame = self.previewContainer.frame;

    // 尺寸标签
    self.sizeLabel.frame = CGRectMake(padH, 44 + previewH + 8, cardW - padH * 2, 24);

    y += sizeCardH + padV;

    // ── 视频时长卡片 ──
    CGFloat durationCardH = 44 + kVETimelineH + kVETimeLabelH + kVETimeLabelGap + padV;
    self.durationCard.frame = CGRectMake(padH, y, cardW, durationCardH);
    self.durationCardTitle.frame = CGRectMake(padH, 0, cardW - padH * 2, 44);

    // 时间轴容器
    self.timelineContainer.frame = CGRectMake(0, 44, cardW, kVETimelineH + kVETimeLabelH + kVETimeLabelGap);

    // 时间轴内部布局
    CGFloat tlW = cardW;
    self.timelineInnerW = tlW - kVEHandleW * 2;

    // 缩略图背景
    self.thumbScrollView.frame = CGRectMake(kVEHandleW, 0, self.timelineInnerW, kVEThumbH);

    // 范围高亮
    self.rangeHighlight.frame = CGRectMake(kVEHandleW, 0, self.timelineInnerW, kVEThumbH);

    // 左右手柄
    self.leftHandle.frame  = CGRectMake(0, 0, kVEHandleW, kVEThumbH);
    self.rightHandle.frame = CGRectMake(tlW - kVEHandleW, 0, kVEHandleW, kVEThumbH);

    // 播放进度线
    self.playhead.frame = CGRectMake(kVEHandleW, 0, 2, kVEThumbH);

    // 时间标签
    CGFloat labelY = kVEThumbH + kVETimeLabelGap;
    self.startTimeLabel.frame = CGRectMake(0, labelY, 60, kVETimeLabelH);
    self.endTimeLabel.frame   = CGRectMake(tlW - 60, labelY, 60, kVETimeLabelH);
    self.selectedDurationLabel.frame = CGRectMake((tlW - 100) / 2.f, labelY, 100, kVETimeLabelH);

    y += durationCardH + padV * 2;

    // 设置内容视图和滚动区域
    self.contentView.frame = CGRectMake(0, 0, w, y);
    self.scrollView.contentSize = CGSizeMake(w, y);

    [self updateHandlePositions];
    [self updateVideoTransform];
}

#pragma mark - 视频加载

/** 加载视频：异步获取 duration 和 naturalSize 后再初始化播放器和 UI */
- (void)loadVideo {
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.videoURL];
    __weak typeof(self) wself = self;

    // 异步加载 duration 和 tracks
    [asset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
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

            // 获取视频原始尺寸
            NSArray<AVAssetTrack *> *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
            if (videoTracks.count > 0) {
                AVAssetTrack *videoTrack = videoTracks.firstObject;
                sself.videoNaturalSize = videoTrack.naturalSize;

                // 计算初始缩放比例（确保视频填充裁剪框）
                CGSize previewSize = sself.previewContainer.bounds.size;
                CGFloat scaleX = previewSize.width / sself.videoNaturalSize.width;
                CGFloat scaleY = previewSize.height / sself.videoNaturalSize.height;
                sself.videoScale = MAX(scaleX, scaleY);
                sself.minScale = sself.videoScale * 0.5f;
                sself.maxScale = sself.videoScale * 3.0f;
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

            // 开始播放
            [sself.player play];

            // 更新 UI
            [sself updateHandlePositions];
            [sself updateTimeLabelsWith:sself.trimStart end:sself.trimEnd];
            [sself updateVideoTransform];
            [sself updateSizeLabel];
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

#pragma mark - 视频手势处理

/** 拖动视频 */
- (void)handleVideoPan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.previewContainer];

    if (pan.state == UIGestureRecognizerStateChanged) {
        self.videoOffset = CGPointMake(self.videoOffset.x + translation.x,
                                       self.videoOffset.y + translation.y);
        [self updateVideoTransform];
    }

    [pan setTranslation:CGPointZero inView:self.previewContainer];
}

/** 缩放视频 */
- (void)handleVideoPinch:(UIPinchGestureRecognizer *)pinch {
    if (pinch.state == UIGestureRecognizerStateChanged) {
        CGFloat newScale = self.videoScale * pinch.scale;
        newScale = MAX(self.minScale, MIN(self.maxScale, newScale));
        self.videoScale = newScale;
        [self updateVideoTransform];
        [self updateSizeLabel];
    }

    if (pinch.state == UIGestureRecognizerStateEnded) {
        pinch.scale = 1.0;
    }
}

/** 更新视频变换（缩放和偏移） */
- (void)updateVideoTransform {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, self.videoScale, self.videoScale);
    transform = CGAffineTransformTranslate(transform, self.videoOffset.x, self.videoOffset.y);
    self.playerLayer.affineTransform = transform;
}

/** 更新尺寸标签 */
- (void)updateSizeLabel {
    if (CGSizeEqualToSize(self.videoNaturalSize, CGSizeZero)) {
        self.sizeLabel.text = @"加载中...";
        return;
    }

    // 计算裁剪后的实际尺寸
    CGSize previewSize = self.previewContainer.bounds.size;
    CGFloat cropW = previewSize.width / self.videoScale;
    CGFloat cropH = previewSize.height / self.videoScale;

    self.sizeLabel.text = [NSString stringWithFormat:@"裁剪尺寸：%.0f × %.0f px", cropW, cropH];
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
    self.selectedDurationLabel.text = [NSString stringWithFormat:@"已选择：%.1fs", dur];
}

/** 格式化秒数为 mm:ss */
- (NSString *)formatTime:(Float64)seconds {
    NSInteger s = (NSInteger)seconds;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(s / 60), (long)(s % 60)];
}

#pragma mark - 按钮回调

/** 取消 */
- (void)onCancelTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 完成 → 导出裁剪后视频 */
- (void)onDoneTapped {
    self.doneBtn.enabled = NO;
    [self.spinner startAnimating];
    [self exportProcessedVideoWithCompletion:^(NSURL *outputURL) {
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

/** 使用 AVAssetExportSession 和 AVMutableVideoComposition 导出处理后的视频 */
- (void)exportProcessedVideoWithCompletion:(void(^)(NSURL *outputURL))completion {
    AVAsset *asset = [AVAsset assetWithURL:self.videoURL];
    NSString *tmpPath = [NSTemporaryDirectory()
                         stringByAppendingPathComponent:@"ts_dial_processed.mp4"];
    NSURL *outputURL = [NSURL fileURLWithPath:tmpPath];
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];

    // 获取视频轨道
    NSArray<AVAssetTrack *> *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count == 0) {
        completion(nil);
        return;
    }
    AVAssetTrack *videoTrack = videoTracks.firstObject;

    // 创建视频合成
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30); // 30 FPS

    // 计算裁剪区域和变换
    CGSize naturalSize = videoTrack.naturalSize;
    CGSize previewSize = self.previewContainer.bounds.size;

    // 计算裁剪矩形（在原始视频坐标系中）
    CGFloat cropW = previewSize.width / self.videoScale;
    CGFloat cropH = previewSize.height / self.videoScale;
    CGFloat cropX = (naturalSize.width - cropW) / 2.0 - self.videoOffset.x / self.videoScale;
    CGFloat cropY = (naturalSize.height - cropH) / 2.0 - self.videoOffset.y / self.videoScale;

    // 确保裁剪区域在视频范围内
    cropX = MAX(0, MIN(cropX, naturalSize.width - cropW));
    cropY = MAX(0, MIN(cropY, naturalSize.height - cropH));

    CGRect cropRect = CGRectMake(cropX, cropY, cropW, cropH);

    // 创建视频合成指令
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);

    AVMutableVideoCompositionLayerInstruction *layerInstruction =
        [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];

    // 应用裁剪变换
    CGAffineTransform transform = videoTrack.preferredTransform;

    // 缩放到裁剪区域
    CGFloat scaleX = previewSize.width / cropW;
    CGFloat scaleY = previewSize.height / cropH;
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(scaleX, scaleY));

    // 平移到裁剪位置
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(-cropX * scaleX, -cropY * scaleY));

    [layerInstruction setTransform:transform atTime:kCMTimeZero];

    instruction.layerInstructions = @[layerInstruction];
    videoComposition.instructions = @[instruction];
    videoComposition.renderSize = previewSize;

    // 创建导出会话
    AVAssetExportSession *session =
        [[AVAssetExportSession alloc] initWithAsset:asset
                                         presetName:AVAssetExportPresetHighestQuality];
    session.outputURL      = outputURL;
    session.outputFileType = AVFileTypeMPEG4;
    session.videoComposition = videoComposition;

    // 设置时间范围（时长裁剪）
    session.timeRange = CMTimeRangeMake(
        CMTimeMakeWithSeconds(self.trimStart, NSEC_PER_SEC),
        CMTimeMakeWithSeconds(self.trimEnd - self.trimStart, NSEC_PER_SEC));

    [session exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (session.status == AVAssetExportSessionStatusCompleted) {
                completion(outputURL);
            } else {
                NSLog(@"导出失败: %@", session.error);
                completion(nil);
            }
        });
    }];
}

#pragma mark - 懒加载

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor colorWithWhite:0.05f alpha:1.f];
        _scrollView.showsVerticalScrollIndicator = YES;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = UIColor.clearColor;
    }
    return _contentView;
}

- (UIView *)sizeCard {
    if (!_sizeCard) {
        _sizeCard = [[UIView alloc] init];
        _sizeCard.backgroundColor = [UIColor colorWithWhite:0.12f alpha:1.f];
        _sizeCard.layer.cornerRadius = 12.f;
        _sizeCard.clipsToBounds = YES;
    }
    return _sizeCard;
}

- (UILabel *)sizeCardTitle {
    if (!_sizeCardTitle) {
        _sizeCardTitle = [[UILabel alloc] init];
        _sizeCardTitle.text = @"📐 视频尺寸";
        _sizeCardTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _sizeCardTitle.textColor = UIColor.whiteColor;
    }
    return _sizeCardTitle;
}

- (UIView *)previewContainer {
    if (!_previewContainer) {
        _previewContainer = [[UIView alloc] init];
        _previewContainer.backgroundColor = UIColor.blackColor;
        _previewContainer.clipsToBounds = YES;
        _previewContainer.layer.cornerRadius = 8.f;
        _previewContainer.userInteractionEnabled = YES;
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [_previewContainer.layer addSublayer:self.playerLayer];
    }
    return _previewContainer;
}

- (UIView *)cropOverlay {
    if (!_cropOverlay) {
        _cropOverlay = [[UIView alloc] init];
        _cropOverlay.backgroundColor = UIColor.clearColor;
        _cropOverlay.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.6f].CGColor;
        _cropOverlay.layer.borderWidth = 2.f;
        _cropOverlay.layer.cornerRadius = 8.f;
        _cropOverlay.userInteractionEnabled = NO;
    }
    return _cropOverlay;
}

- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [[UILabel alloc] init];
        _sizeLabel.text = @"双指缩放，单指拖动调整";
        _sizeLabel.font = [UIFont systemFontOfSize:13];
        _sizeLabel.textColor = [UIColor colorWithWhite:0.6f alpha:1.f];
        _sizeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sizeLabel;
}

- (UIView *)durationCard {
    if (!_durationCard) {
        _durationCard = [[UIView alloc] init];
        _durationCard.backgroundColor = [UIColor colorWithWhite:0.12f alpha:1.f];
        _durationCard.layer.cornerRadius = 12.f;
        _durationCard.clipsToBounds = YES;
    }
    return _durationCard;
}

- (UILabel *)durationCardTitle {
    if (!_durationCardTitle) {
        _durationCardTitle = [[UILabel alloc] init];
        _durationCardTitle.text = @"⏱️ 视频时长";
        _durationCardTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _durationCardTitle.textColor = UIColor.whiteColor;
    }
    return _durationCardTitle;
}

- (UIView *)timelineContainer {
    if (!_timelineContainer) {
        _timelineContainer = [[UIView alloc] init];
        _timelineContainer.backgroundColor = [UIColor colorWithWhite:0.1f alpha:1.f];
        _timelineContainer.clipsToBounds = YES;
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
        _rangeHighlight.backgroundColor = kVEHighlight;
        _rangeHighlight.userInteractionEnabled = NO;
    }
    return _rangeHighlight;
}

- (TSVideoTrimHandle *)leftHandle {
    if (!_leftHandle) {
        _leftHandle = [[TSVideoTrimHandle alloc] initWithFrame:CGRectMake(0, 0, kVEHandleW, kVEThumbH)];
    }
    return _leftHandle;
}

- (TSVideoTrimHandle *)rightHandle {
    if (!_rightHandle) {
        _rightHandle = [[TSVideoTrimHandle alloc] initWithFrame:CGRectMake(0, 0, kVEHandleW, kVEThumbH)];
    }
    return _rightHandle;
}

- (UIView *)playhead {
    if (!_playhead) {
        _playhead = [[UIView alloc] init];
        _playhead.backgroundColor = kVEPrimary;
        _playhead.userInteractionEnabled = NO;
    }
    return _playhead;
}

- (UILabel *)startTimeLabel {
    if (!_startTimeLabel) {
        _startTimeLabel = [[UILabel alloc] init];
        _startTimeLabel.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightMedium];
        _startTimeLabel.textColor = [UIColor colorWithWhite:0.7f alpha:1.f];
        _startTimeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _startTimeLabel;
}

- (UILabel *)endTimeLabel {
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] init];
        _endTimeLabel.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightMedium];
        _endTimeLabel.textColor = [UIColor colorWithWhite:0.7f alpha:1.f];
        _endTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _endTimeLabel;
}

- (UILabel *)selectedDurationLabel {
    if (!_selectedDurationLabel) {
        _selectedDurationLabel = [[UILabel alloc] init];
        _selectedDurationLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        _selectedDurationLabel.textColor = kVEPrimary;
        _selectedDurationLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _selectedDurationLabel;
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
        [_cancelBtn setTitleColor:[UIColor colorWithWhite:0.7f alpha:1.f] forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_cancelBtn addTarget:self action:@selector(onCancelTapped)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_doneBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:kVEPrimary forState:UIControlStateNormal];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [_doneBtn addTarget:self action:@selector(onDoneTapped)
           forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        if (@available(iOS 13.0, *)) {
            _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        _spinner.hidesWhenStopped = YES;
    }
    return _spinner;
}

@end

