//
//  TSDialPreviewView.m
//  TopStepComKit_Example
//

#import "TSDialPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <TopStepComKit/TopStepComKit.h>
#import "TSDialEditorState.h"
#import "TSDialEditorAppearance.h"

@interface TSDialPreviewView ()
// 渲染输入。
@property (nonatomic, strong) TSDialEditorState *state;
@property (nonatomic, strong) TSPeripheralScreen *screen;
@property (nonatomic, strong) TSCustomDialStyleConstraint *constraint;
// 表带、表壳与屏幕。
@property (nonatomic, strong) UIView *strapView;
@property (nonatomic, strong) UIView *watchView;
@property (nonatomic, strong) UIView *screenView;
@property (nonatomic, strong) CAGradientLayer *metalLayer;
@property (nonatomic, strong) UIView *crownView;
// 背景与时间叠层。
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *timeView;
// 提示与操作。
@property (nonatomic, strong) UILabel *liveLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *expandButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *playLabel;
// 播放资源。
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSURL *loadedVideoURL;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic, strong) NSMutableArray<UILabel *> *textLabels;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *gifViews;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *gifImages;
// 瞬时播放游标不写入草稿。
@property (nonatomic, assign) NSUInteger displayedImage;
@property (nonatomic, assign) NSTimeInterval playbackElapsed;
@property (nonatomic, assign) BOOL suspended;
// 管理页成品模式不生成任何编辑器内容。
@property (nonatomic, assign) BOOL displaysInstalledImage;
// 无成品图时的明确占位。
@property (nonatomic, strong) UILabel *unavailableLabel;
@end

@implementation TSDialPreviewView

#pragma mark - 生命周期

// 预览部件始终使用一棵渲染树。
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _playing = YES;
        _installedPreviewScale = 0.67;
        self.clipsToBounds = YES;
        [self addSubview:self.strapView];
        [self addSubview:self.crownView];
        [self addSubview:self.watchView];
        [self.watchView addSubview:self.screenView];
        [self.screenView addSubview:self.backgroundView];
        [self.screenView addSubview:self.timeView];
        [self.screenView addSubview:self.unavailableLabel];
        [self addSubview:self.liveLabel];
        [self addSubview:self.nameLabel];
        [self addSubview:self.detailLabel];
        [self addSubview:self.expandButton];
        [self addSubview:self.playButton];
        [self addSubview:self.playLabel];
    }
    return self;
}

// 释放播放器与定时器。
- (void)dealloc {
    [_playbackTimer invalidate];
    [_player pause];
}

// 使用与 HTML 一致的浅色径向预览背景。
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSArray *colors = @[(id)[TSDialEditorAppearance color:0xFCFCF8].CGColor,
                        (id)[TSDialEditorAppearance color:0xEDEFE5].CGColor];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGContextDrawRadialGradient(context, gradient, center, 0, center, MAX(rect.size.width, rect.size.height) / 2, 3);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
}

// 屏幕保持真实比例，表壳随圆形和方形切换。
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds), height = CGRectGetHeight(self.bounds);
    BOOL round = self.screen.shape == eTSPeriphShapeCircle;
    CGFloat factor = self.enlarged ? 1.05 : height < 220 ? 0.57 : 0.65;
    if (self.displaysInstalledImage) {
        factor = self.installedPreviewScale;
    }
    CGFloat watchWidth = (round ? 278 : 241) * factor;
    CGFloat watchHeight = round ? watchWidth : 295 * factor;
    CGFloat inset = (round ? 13 : 12) * factor;
    if (!round && self.screen.screenSize.width > 0 && self.screen.screenSize.height > 0) {
        CGFloat ratio = self.screen.screenSize.height / self.screen.screenSize.width;
        watchHeight = MIN((height - 35), 295 * factor);
        watchWidth = (watchHeight - inset * 2) / ratio + inset * 2;
        if (watchWidth > 280 * factor) {
            watchWidth = 280 * factor;
            watchHeight = (watchWidth - inset * 2) * ratio + inset * 2;
        }
    }
    self.watchView.frame = CGRectMake((width - watchWidth) / 2, (height - watchHeight) / 2, watchWidth, watchHeight);
    self.metalLayer.frame = self.watchView.bounds;
    self.watchView.layer.cornerRadius = round ? watchWidth / 2 : 56 * factor;
    self.metalLayer.cornerRadius = self.watchView.layer.cornerRadius;
    self.strapView.frame = CGRectMake((width - 104 * factor / 0.65) / 2, (height - 235 * factor / 0.65) / 2,
                                     104 * factor / 0.65, 235 * factor / 0.65);
    self.strapView.layer.cornerRadius = 30;
    self.crownView.frame = CGRectMake(CGRectGetMaxX(self.watchView.frame) - 1,
                                     CGRectGetMinY(self.watchView.frame) + watchHeight * 0.34, 6, 23);
    self.screenView.frame = CGRectInset(self.watchView.bounds, inset, inset);
    CGFloat pixelScale = self.screen.screenSize.width > 0 ? CGRectGetWidth(self.screenView.bounds) / self.screen.screenSize.width : 1;
    self.screenView.layer.cornerRadius = round ? CGRectGetWidth(self.screenView.bounds) / 2 :
        self.screen.screenBorderRadius * pixelScale;
    self.backgroundView.frame = self.screenView.bounds;
    self.unavailableLabel.frame = CGRectInset(self.screenView.bounds, 12, 12);
    self.playerLayer.frame = self.screenView.bounds;
    [self layoutTime];
    [self layoutText];
    self.liveLabel.frame = CGRectMake(21, 16, 110, 25);
    self.expandButton.frame = CGRectMake(width - 65, 13, 48, 30);
    self.nameLabel.frame = CGRectMake(20, height - 45, width * 0.48, 15);
    self.detailLabel.frame = CGRectMake(20, height - 27, width * 0.55, 12);
    self.playButton.frame = CGRectMake(width - 105, height - 44, 29, 29);
    self.playLabel.frame = CGRectMake(width - 69, height - 39, 64, 20);
    self.liveLabel.hidden = self.enlarged;
    self.expandButton.hidden = self.enlarged;
    self.detailLabel.hidden = height < 220 && !self.enlarged;
    if (self.displaysInstalledImage) {
        self.liveLabel.hidden = YES;
        self.expandButton.hidden = YES;
        self.nameLabel.hidden = YES;
        self.detailLabel.hidden = YES;
        self.playButton.hidden = YES;
        self.playLabel.hidden = YES;
    }
}

#pragma mark - 公开方法

// 复用相同表壳和纹理，仅渲染设备成品预览。
- (void)configureWithInstalledImage:(UIImage *)image screen:(TSPeripheralScreen *)screen {
    [self suspend];
    self.displaysInstalledImage = YES;
    self.state = nil;
    self.constraint = nil;
    self.screen = screen;
    self.backgroundView.image = image;
    self.screenView.backgroundColor = [TSDialEditorAppearance color:0xE9ECE2];
    self.unavailableLabel.hidden = image != nil;
    self.timeView.hidden = YES;
    [self updateVideo];
    [self rebuildText];
    [self setNeedsLayout];
}

// 更新画面时保留播放器，避免调整颜色引起视频重新加载。
- (void)configureWithState:(TSDialEditorState *)state screen:(TSPeripheralScreen *)screen
               constraint:(TSCustomDialStyleConstraint *)constraint timeImage:(UIImage *)timeImage {
    self.displaysInstalledImage = NO;
    self.unavailableLabel.hidden = YES;
    self.nameLabel.hidden = NO;
    self.screenView.backgroundColor = UIColor.blackColor;
    self.state = state;
    self.screen = screen;
    self.constraint = constraint;
    self.displayedImage = state.images.count ? MIN(state.selectedImage, state.images.count - 1) : 0;
    NSDictionary *image = state.images.count ? state.images[self.displayedImage] : nil;
    self.backgroundView.image = image[@"image"];
    self.nameLabel.text = state.draftType == TSDialDraftTypeVideo ? @"视频表盘" :
        state.draftType == TSDialDraftTypeDanMu ? @"让心情动起来" : image[@"name"];
    self.detailLabel.text = [self detailText];
    self.timeView.image = [timeImage imageWithRenderingMode:constraint.allowColorTint ?
                           UIImageRenderingModeAlwaysTemplate : UIImageRenderingModeAlwaysOriginal];
    self.timeView.tintColor = [TSDialEditorAppearance colorFromHex:state.timeColor];
    self.timeView.hidden = !state.showsTime || !timeImage;
    self.playButton.hidden = self.playLabel.hidden = state.draftType == TSDialDraftTypeSingleImage;
    [self.playButton setImage:[TSDialEditorAppearance icon:self.isPlaying ? @"pause" : @"play"]
                    forState:UIControlStateNormal];
    self.playLabel.text = self.isPlaying ? @"正在预览" : @"已暂停";
    [self updateVideo];
    [self rebuildText];
    [self setNeedsLayout];
    [self resume];
}

// 播放选择由组件管理，与素材修改相互独立。
- (void)setPlaying:(BOOL)playing {
    _playing = playing;
    [self.playButton setImage:[TSDialEditorAppearance icon:playing ? @"pause" : @"play"]
                    forState:UIControlStateNormal];
    self.playLabel.text = playing ? @"正在预览" : @"已暂停";
    if (playing) {
        [self resume];
    } else {
        [self.player pause];
        [self.playbackTimer invalidate];
        self.playbackTimer = nil;
        for (UIImageView *imageView in self.gifViews) {
            [imageView stopAnimating];
        }
    }
}

// 退到后台或显示裁切页时停止资源消耗。
- (void)suspend {
    self.suspended = YES;
    [self.player pause];
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
    for (UIImageView *imageView in self.gifViews) {
        [imageView stopAnimating];
    }
}

// 恢复用户期望的播放状态。
- (void)resume {
    if (self.displaysInstalledImage) {
        return;
    }
    self.suspended = NO;
    if (!self.window || !self.isPlaying || UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        return;
    }
    [self.player play];
    for (UIImageView *imageView in self.gifViews) {
        [imageView startAnimating];
    }
    if (!self.playbackTimer && self.state.draftType != TSDialDraftTypeSingleImage) {
        __weak typeof(self) weakSelf = self;
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer *timer) {
            [weakSelf advancePlayback];
        }];
    }
}

#pragma mark - 私有方法

// 时间区域按设备像素等比换算。
- (void)layoutTime {
    CGSize target = self.screenView.bounds.size;
    CGSize source = self.constraint.screenSize;
    if (source.width <= 0 || source.height <= 0) {
        self.timeView.frame = CGRectZero;
        return;
    }
    for (TSCustomDialPositionOption *option in self.constraint.positions) {
        if (option.position == self.state.timePosition) {
            CGRect frame = option.frame;
            self.timeView.frame = CGRectMake(frame.origin.x * target.width / source.width,
                                            frame.origin.y * target.height / source.height,
                                            frame.size.width * target.width / source.width,
                                            frame.size.height * target.height / source.height);
            break;
        }
    }
}

// 每种类型自己的预览说明。
- (NSString *)detailText {
    switch (self.state.draftType) {
        case TSDialDraftTypeMultipleImage:
            return [NSString stringWithFormat:@"多图表盘 · %lu / %lu", self.displayedImage + 1, self.state.images.count];
        case TSDialDraftTypeVideo:
            return self.state.videoURL ? @"本机视频 · 片段循环预览" : @"选择视频后预览";
        case TSDialDraftTypeDanMu:
            return [NSString stringWithFormat:@"弹幕表盘 · %lu 条内容", self.state.textItems.count];
        default:
            return self.screen.shape == eTSPeriphShapeCircle ? @"单图表盘 · 圆形预览" : @"单图表盘 · 方形预览";
    }
}

// 新视频才重建播放对象，并保持填充比例及静音。
- (void)updateVideo {
    NSURL *url = self.state.draftType == TSDialDraftTypeVideo ? self.state.videoURL : nil;
    if (![url isEqual:self.loadedVideoURL]) {
        [self.player pause];
        [self.playerLayer removeFromSuperlayer];
        self.loadedVideoURL = url;
        self.player = url ? [AVPlayer playerWithURL:url] : nil;
        self.player.muted = YES;
        self.playerLayer = self.player ? [AVPlayerLayer playerLayerWithPlayer:self.player] : nil;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        if (self.playerLayer) {
            [self.screenView.layer insertSublayer:self.playerLayer above:self.backgroundView.layer];
        }
    }
    NSTimeInterval current = CMTimeGetSeconds(self.player.currentTime);
    if (url && (current < self.state.videoStart || current >= self.state.videoEnd)) {
        [self.player seekToTime:CMTimeMakeWithSeconds(self.state.videoStart, 600)
               toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

// 播放推进不修改草稿选择或脏标记。
- (void)advancePlayback {
    if (!self.window || self.suspended || !self.isPlaying ||
        UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        return;
    }
    self.playbackElapsed += 0.05;
    if (self.state.draftType == TSDialDraftTypeMultipleImage && self.state.images.count &&
        self.playbackElapsed >= self.state.interval) {
        self.playbackElapsed = 0;
        self.displayedImage = (self.displayedImage + 1) % self.state.images.count;
        self.backgroundView.image = self.state.images[self.displayedImage][@"image"];
        self.nameLabel.text = self.state.images[self.displayedImage][@"name"];
        self.detailLabel.text = [self detailText];
    } else if (self.state.draftType == TSDialDraftTypeVideo) {
        [self updateVideo];
        if (self.player.rate == 0) {
            [self.player play];
        }
    } else if (self.state.draftType == TSDialDraftTypeDanMu) {
        [self layoutText];
    }
}

// 播放暂停按钮。
- (void)togglePlayback {
    self.playing = !self.isPlaying;
}

// 放大由宿主呈现。
- (void)expandPreview {
    if (self.onExpandRequested) {
        self.onExpandRequested();
    }
}

// 更新弹幕内容，动画位置继续使用已有播放时间。
- (void)rebuildText {
    for (UIView *view in self.textLabels) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.gifViews) {
        [view removeFromSuperview];
    }
    self.textLabels = [NSMutableArray array];
    self.gifViews = [NSMutableArray array];
    if (self.state.draftType != TSDialDraftTypeDanMu) {
        return;
    }
    for (NSUInteger index = 0; index < self.state.textItems.count; index++) {
        NSDictionary *item = self.state.textItems[index];
        UILabel *label = [TSDialEditorAppearance label:[item[@"text"] length] ? item[@"text"] : @"输入你的弹幕"
                                                size:22 color:0xF4F6C3];
        label.textColor = [TSDialEditorAppearance colorFromHex:item[@"color"]];
        [self.screenView addSubview:label];
        [self.textLabels addObject:label];
        NSString *path = item[@"gif"];
        if (path.length && index == self.state.selectedText) {
            UIImage *image = [self animatedGIFAtPath:path];
            if (image) {
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.image = image.images.firstObject ?: image;
                imageView.animationImages = image.images;
                imageView.animationDuration = image.duration;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [self.screenView addSubview:imageView];
                [self.gifViews addObject:imageView];
            }
        }
    }
}

// 高度百分比以完整屏幕为基准，文字受圆形遮罩裁切。
- (void)layoutText {
    CGFloat width = CGRectGetWidth(self.screenView.bounds);
    CGFloat height = CGRectGetHeight(self.screenView.bounds);
    CGFloat reference = self.screen.shape == eTSPeriphShapeCircle ? 252 : 217;
    CGFloat scale = width / reference;
    for (NSUInteger index = 0; index < self.textLabels.count; index++) {
        NSDictionary *item = self.state.textItems[index];
        UILabel *label = self.textLabels[index];
        label.font = [UIFont systemFontOfSize:[item[@"size"] doubleValue] * scale weight:UIFontWeightBold];
        CGSize textSize = [label sizeThatFits:CGSizeMake(CGFLOAT_MAX, 100)];
        CGFloat distance = width + textSize.width;
        CGFloat offset = fmod((self.playbackElapsed + index * 1.4) * [item[@"speed"] doubleValue] * scale,
                              MAX(1, distance));
        CGFloat horizontal = [item[@"right"] boolValue] ? -textSize.width + offset : width - offset;
        label.frame = CGRectMake(horizontal, height * [item[@"position"] doubleValue] / 100,
                                 textSize.width, textSize.height);
    }
    for (UIImageView *imageView in self.gifViews) {
        CGFloat side = 45 * scale;
        imageView.frame = CGRectMake((width - side) / 2, (height - side) / 2, side, side);
    }
}

// 预览解码使用缩略帧，造包按同一显示比例生成独立动画副本。
- (UIImage *)animatedGIFAtPath:(NSString *)path {
    if (!self.gifImages) {
        self.gifImages = [NSMutableDictionary dictionary];
    }
    if (self.gifImages[path]) {
        return self.gifImages[path];
    }
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], NULL);
    if (!source) {
        return nil;
    }
    NSMutableArray<UIImage *> *frames = [NSMutableArray array];
    NSTimeInterval duration = 0;
    for (NSUInteger index = 0; index < CGImageSourceGetCount(source); index++) {
        @autoreleasepool {
            NSDictionary *properties = CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, index, NULL));
            NSDictionary *gif = properties[(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delay = gif[(NSString *)kCGImagePropertyGIFUnclampedDelayTime] ?: gif[(NSString *)kCGImagePropertyGIFDelayTime];
            NSTimeInterval frameDuration = MAX(0.02, delay ? delay.doubleValue : 0.1);
            NSDictionary *options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways:@YES,
                                       (NSString *)kCGImageSourceThumbnailMaxPixelSize:@128};
            CGImageRef frame = CGImageSourceCreateThumbnailAtIndex(source, index, (__bridge CFDictionaryRef)options);
            if (frame) {
                UIImage *image = [UIImage imageWithCGImage:frame];
                NSUInteger ticks = MAX(1, lround(frameDuration / 0.02));
                for (NSUInteger tick = 0; tick < ticks; tick++) {
                    [frames addObject:image];
                }
                duration += ticks * 0.02;
                CGImageRelease(frame);
            }
        }
    }
    CFRelease(source);
    UIImage *image = frames.count ? [UIImage animatedImageWithImages:frames duration:duration] : nil;
    if (image) {
        self.gifImages[path] = image;
    }
    return image;
}

#pragma mark - 属性懒加载

// 缺少成品图时不伪造时间或风景。
- (UILabel *)unavailableLabel {
    if (!_unavailableLabel) {
        _unavailableLabel = [TSDialEditorAppearance label:@"暂无预览" size:12 color:0x8E9984];
        _unavailableLabel.textAlignment = NSTextAlignmentCenter;
        _unavailableLabel.hidden = YES;
    }
    return _unavailableLabel;
}

// 浅色纹理表带。
- (UIView *)strapView {
    if (!_strapView) {
        _strapView = [[UIView alloc] init];
        _strapView.backgroundColor = [TSDialEditorAppearance color:0xE4E4DB];
        _strapView.layer.borderWidth = 1;
        _strapView.layer.borderColor = [TSDialEditorAppearance color:0xD1D2C7].CGColor;
        for (NSUInteger index = 0; index < 22; index++) {
            UIView *stripe = [[UIView alloc] initWithFrame:CGRectMake(index * 5, 0, 1, 400)];
            stripe.backgroundColor = [UIColor colorWithWhite:1 alpha:0.16];
            [_strapView addSubview:stripe];
        }
        _strapView.clipsToBounds = YES;
    }
    return _strapView;
}

// 金属表壳渐变与柔和阴影。
- (UIView *)watchView {
    if (!_watchView) {
        _watchView = [[UIView alloc] init];
        _watchView.layer.shadowColor = [TSDialEditorAppearance color:0x444A30].CGColor;
        _watchView.layer.shadowOpacity = 0.25;
        _watchView.layer.shadowRadius = 10;
        _watchView.layer.shadowOffset = CGSizeMake(0, 10);
        _metalLayer = [CAGradientLayer layer];
        _metalLayer.colors = @[(id)[TSDialEditorAppearance color:0xB9BBB0].CGColor,
                              (id)[TSDialEditorAppearance color:0x242620].CGColor,
                              (id)[TSDialEditorAppearance color:0x777B6C].CGColor];
        _metalLayer.startPoint = CGPointZero;
        _metalLayer.endPoint = CGPointMake(1, 1);
        _metalLayer.borderWidth = 2;
        _metalLayer.borderColor = [TSDialEditorAppearance color:0x33372A].CGColor;
        [_watchView.layer addSublayer:_metalLayer];
    }
    return _watchView;
}

// 所有叠层共用一个屏幕遮罩。
- (UIView *)screenView {
    if (!_screenView) {
        _screenView = [[UIView alloc] init];
        _screenView.clipsToBounds = YES;
        _screenView.backgroundColor = UIColor.blackColor;
        _screenView.layer.borderWidth = 1;
        _screenView.layer.borderColor = [TSDialEditorAppearance color:0x141A13].CGColor;
    }
    return _screenView;
}

// 表冠。
- (UIView *)crownView {
    if (!_crownView) {
        _crownView = [[UIView alloc] init];
        _crownView.backgroundColor = [TSDialEditorAppearance color:0x424639];
        _crownView.layer.cornerRadius = 2;
    }
    return _crownView;
}

// 背景填充不拉伸。
- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
        _backgroundView.clipsToBounds = YES;
    }
    return _backgroundView;
}

// 设备样式图片叠层。
- (UIImageView *)timeView {
    if (!_timeView) {
        _timeView = [[UIImageView alloc] init];
        _timeView.contentMode = UIViewContentModeScaleToFill;
    }
    return _timeView;
}

// 左上实时预览标记。
- (UILabel *)liveLabel {
    if (!_liveLabel) {
        _liveLabel = [TSDialEditorAppearance label:@"L I V E  P R E V I E W" size:8 color:0x9A9E90];
        _liveLabel.font = [UIFont systemFontOfSize:8 weight:UIFontWeightSemibold];
    }
    return _liveLabel;
}

// 当前素材名。
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [TSDialEditorAppearance label:@"" size:10 color:0x252823];
    }
    return _nameLabel;
}

// 当前类型及播放进度说明。
- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [TSDialEditorAppearance label:@"" size:8 color:0x9A9F90];
    }
    return _detailLabel;
}

// 右上放大按钮。
- (UIButton *)expandButton {
    if (!_expandButton) {
        _expandButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_expandButton setTitle:@"⌗ 放大" forState:UIControlStateNormal];
        _expandButton.titleLabel.font = [UIFont systemFontOfSize:10];
        _expandButton.tintColor = [TSDialEditorAppearance color:0x939888];
        _expandButton.accessibilityLabel = @"放大表盘预览";
        [_expandButton addTarget:self action:@selector(expandPreview) forControlEvents:UIControlEventTouchUpInside];
    }
    return _expandButton;
}

// 动态播放圆按钮。
- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _playButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
        _playButton.layer.cornerRadius = 14.5;
        _playButton.tintColor = [TSDialEditorAppearance color:0x616B55];
        _playButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        _playButton.accessibilityLabel = @"播放或暂停动态预览";
        [_playButton addTarget:self action:@selector(togglePlayback) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

// 播放状态。
- (UILabel *)playLabel {
    if (!_playLabel) {
        _playLabel = [TSDialEditorAppearance label:@"正在预览" size:9 color:0x93958E];
    }
    return _playLabel;
}

@end
