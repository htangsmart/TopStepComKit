//
//  TSDialEditorVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDialEditorVC.h"
#import <AVFoundation/AVFoundation.h>
#import <TopStepComKit/TopStepComKit.h>

// ─── 布局常量 ────────────────────────────────────────────────────────────────
static const CGFloat kEdPadH          = 16.f;
static const CGFloat kEdPadV          = 12.f;
static const CGFloat kEdSectionTitleH = 36.f;
static const CGFloat kEdSectionGap    = 8.f;
static const CGFloat kEdCardRadius    = 12.f;

// 时间位置选择器（宽度固定，高度根据表盘比例计算）
static const CGFloat kEdTimeCellW     = 80.f;

// 颜色选择器
static const CGFloat kEdColorCircleD  = 36.f;
static const CGFloat kEdColorRowH     = 52.f;

// 推送按钮
static const CGFloat kEdPushBtnH      = 52.f;
static const CGFloat kEdProgressH     = 52.f;

// ─── 时间位置模型 ─────────────────────────────────────────────────────────────
@interface TSTimePositionItem : NSObject
@property (nonatomic, assign) TSDialTimePosition position;
@property (nonatomic, copy)   NSString           *title;
@end
@implementation TSTimePositionItem
+ (instancetype)itemWithPosition:(TSDialTimePosition)p title:(NSString *)t {
    TSTimePositionItem *i = [TSTimePositionItem new];
    i.position = p; i.title = t;
    return i;
}
@end

// ─────────────────────────────────────────────────────────────────────────────
@interface TSDialEditorVC () <UIColorPickerViewControllerDelegate>

// 来源类型
@property (nonatomic, strong) UIImage  *sourceImage;
@property (nonatomic, strong) NSURL    *videoURL;
@property (nonatomic, assign) BOOL      isVideo;
@property (nonatomic, assign) CGSize    dialSize;

// 用户选择状态
@property (nonatomic, assign) TSDialTimePosition selectedPosition;
@property (nonatomic, strong) UIColor            *selectedColor;

// AVPlayer（视频预览）
@property (nonatomic, strong) AVPlayer       *player;
@property (nonatomic, strong) AVPlayerLayer  *playerLayer;

// ─── 子视图 ──
@property (nonatomic, strong) UIScrollView   *scrollView;

// 预览区
@property (nonatomic, strong) UIView         *previewCard;
@property (nonatomic, strong) UIImageView    *previewImageView;
@property (nonatomic, strong) UIImageView    *timeOverlayImageView;  // 时间位置图片叠加层（模板图，tintColor 着色）

// 时间位置区
@property (nonatomic, strong) UIView         *positionCard;
@property (nonatomic, strong) UILabel        *positionTitleLabel;
@property (nonatomic, strong) UIScrollView   *positionScrollView;
@property (nonatomic, strong) NSArray<TSTimePositionItem *> *positionItems;
@property (nonatomic, strong) NSMutableArray<UIButton *>     *positionBtns;

// 颜色选择区
@property (nonatomic, strong) UIView         *colorCard;
@property (nonatomic, strong) UILabel        *colorTitleLabel;
@property (nonatomic, strong) NSArray<UIColor *> *presetColors;
@property (nonatomic, strong) NSMutableArray<UIView *> *colorCircles;

// 推送按钮 / 进度条
@property (nonatomic, strong) UIButton       *pushBtn;
@property (nonatomic, strong) UIView         *progressBg;
@property (nonatomic, strong) UIView         *progressFill;
@property (nonatomic, strong) UILabel        *progressLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

// 最近一次推送的表盘 ID（用于保存预览图）
@property (nonatomic, copy)   NSString       *lastPushedDialId;

@end

@implementation TSDialEditorVC

#pragma mark - 初始化

- (instancetype)initWithImage:(UIImage *)image dialSize:(CGSize)dialSize {
    self = [super init];
    if (self) {
        _sourceImage = image;
        _isVideo     = NO;
        _dialSize    = dialSize;
    }
    return self;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL dialSize:(CGSize)dialSize {
    self = [super init];
    if (self) {
        _videoURL = videoURL;
        _isVideo  = YES;
        _dialSize = dialSize;

        NSLog(@"[TSDialEditorVC] 初始化视频表盘编辑器");
        NSLog(@"[TSDialEditorVC] videoURL: %@", videoURL);
        NSLog(@"[TSDialEditorVC] dialSize: %.0f × %.0f", dialSize.width, dialSize.height);

        // 获取视频尺寸
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
        NSArray<AVAssetTrack *> *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        if (videoTracks.count > 0) {
            AVAssetTrack *videoTrack = videoTracks.firstObject;
            CGSize naturalSize = videoTrack.naturalSize;
            CGAffineTransform transform = videoTrack.preferredTransform;

            // 判断是否有旋转
            BOOL isRotated = (transform.b == 1.0 || transform.b == -1.0);
            CGSize displaySize = isRotated ? CGSizeMake(naturalSize.height, naturalSize.width) : naturalSize;

            NSLog(@"[TSDialEditorVC] 视频原始尺寸: %.0f × %.0f", naturalSize.width, naturalSize.height);
            NSLog(@"[TSDialEditorVC] 视频显示尺寸: %.0f × %.0f (旋转=%d)", displaySize.width, displaySize.height, isRotated);
            NSLog(@"[TSDialEditorVC] 视频 transform: a=%.2f b=%.2f c=%.2f d=%.2f",
                  transform.a, transform.b, transform.c, transform.d);
        }
    }
    return self;
}

#pragma mark - 数据初始化

- (void)initData {
    [super initData];
    self.title = @"表盘编辑";

    // 默认：时间位置上方，颜色白色
    self.selectedPosition = eTSDialTimePositionTop;
    self.selectedColor    = UIColor.whiteColor;

    // 时间位置选项（固定上/下/左/右四种）
    self.positionItems = @[
        [TSTimePositionItem itemWithPosition:eTSDialTimePositionTop    title:@"上方"],
        [TSTimePositionItem itemWithPosition:eTSDialTimePositionBottom title:@"下方"],
        [TSTimePositionItem itemWithPosition:eTSDialTimePositionLeft   title:@"左方"],
        [TSTimePositionItem itemWithPosition:eTSDialTimePositionRight  title:@"右方"],
    ];
    self.positionBtns = [NSMutableArray array];

    // 预设颜色（白/黑/橙/青）
    self.presetColors = @[
        UIColor.whiteColor,
        UIColor.blackColor,
        UIColor.orangeColor,
        UIColor.cyanColor,
    ];
    self.colorCircles = [NSMutableArray array];
}

#pragma mark - 视图构建

- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;
    [self.view addSubview:self.scrollView];

    // 预览卡片
    [self.scrollView addSubview:self.previewCard];
    [self.previewCard addSubview:self.previewImageView];
    [self.previewCard addSubview:self.timeOverlayImageView];

    // 如果是视频，添加 AVPlayerLayer
    if (self.isVideo) {
        [self setupVideoPlayer];
    }

    // 时间位置卡片
    [self.scrollView addSubview:self.positionCard];
    [self.positionCard addSubview:self.positionTitleLabel];
    [self.positionCard addSubview:self.positionScrollView];
    [self buildPositionButtons];

    // 颜色选择卡片
    [self.scrollView addSubview:self.colorCard];
    [self.colorCard addSubview:self.colorTitleLabel];
    [self buildColorCircles];

    // 推送按钮 & 进度条
    [self.scrollView addSubview:self.pushBtn];
    [self.scrollView addSubview:self.progressBg];
    [self.progressBg addSubview:self.progressFill];
    [self.progressBg addSubview:self.progressLabel];

    // 全局菊花（在 view 上，不在 progressBg 内）
    [self.view addSubview:self.spinner];

    // 初始隐藏进度条
    self.progressBg.hidden = YES;

    // 加载默认位置图片并应用默认颜色
    [self updatePreviewImageForPosition:self.selectedPosition];
}

/** 配置视频预览播放器 */
- (void)setupVideoPlayer {
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.videoURL];
    NSArray<AVAssetTrack *> *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count > 0) {
        AVAssetTrack *track = videoTracks.firstObject;
        NSLog(@"[TSDialEditorVC] 播放器加载视频 track.naturalSize = %@", NSStringFromCGSize(track.naturalSize));
        NSLog(@"[TSDialEditorVC] 播放器加载视频 track.preferredTransform = %@", NSStringFromCGAffineTransform(track.preferredTransform));
    }

    self.player = [AVPlayer playerWithURL:self.videoURL];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;  // 完全填充，可能变形
    self.playerLayer.frame = self.previewCard.bounds;

    // 将 playerLayer 插入到 timeOverlayImageView.layer 之下
    [self.previewCard.layer insertSublayer:self.playerLayer below:self.timeOverlayImageView.layer];

    NSLog(@"[TSDialEditorVC] playerLayer.videoGravity = %@", self.playerLayer.videoGravity);

    // 配置音频会话
    NSError *audioError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&audioError];
    [[AVAudioSession sharedInstance] setActive:YES error:&audioError];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(videoDidReachEnd:)
               name:AVPlayerItemDidPlayToEndTimeNotification
             object:self.player.currentItem];

    // 延迟播放，确保布局完成
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player play];
    });
}

- (void)videoDidReachEnd:(NSNotification *)n {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

/** 构建时间位置选择按钮 */
- (void)buildPositionButtons {
    [self.positionBtns removeAllObjects];
    for (TSTimePositionItem *item in self.positionItems) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = item.position;
        btn.backgroundColor     = TSColor_Background;
        btn.layer.cornerRadius  = 10.f;
        btn.layer.borderWidth   = 2.f;
        btn.layer.borderColor   = UIColor.clearColor.CGColor;
        btn.clipsToBounds       = YES;   // 圆角裁剪背景图
        [btn addTarget:self action:@selector(onPositionBtnTapped:)
      forControlEvents:UIControlEventTouchUpInside];
        [self.positionScrollView addSubview:btn];
        [self.positionBtns addObject:btn];
    }
    [self updatePositionSelection];
}

/** 构建颜色选择圆圈 */
- (void)buildColorCircles {
    [self.colorCircles removeAllObjects];

    // 预设颜色圆圈
    for (UIColor *color in self.presetColors) {
        UIView *circle = [self makeColorCircle:color isCustom:NO];
        [self.colorCard addSubview:circle];
        [self.colorCircles addObject:circle];
        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(onColorCircleTapped:)];
        [circle addGestureRecognizer:tap];
    }

    // 自定义颜色按钮
    UIView *customCircle = [self makeColorCircle:nil isCustom:YES];
    [self.colorCard addSubview:customCircle];
    [self.colorCircles addObject:customCircle];
    UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(onCustomColorTapped)];
    [customCircle addGestureRecognizer:tap];

    [self updateColorSelection];
}

/** 创建颜色圆圈视图 */
- (UIView *)makeColorCircle:(nullable UIColor *)color isCustom:(BOOL)isCustom {
    UIView *circle = [[UIView alloc] init];
    circle.layer.cornerRadius = kEdColorCircleD / 2.f;
    circle.layer.borderWidth  = 2.f;
    circle.layer.borderColor  = UIColor.clearColor.CGColor;
    circle.layer.masksToBounds = YES;

    if (isCustom) {
        // 用渐变表示"自定义"
        CAGradientLayer *grad = [CAGradientLayer layer];
        grad.colors = @[
            (id)[UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor,
            (id)[UIColor colorWithRed:0 green:1 blue:0 alpha:1].CGColor,
            (id)[UIColor colorWithRed:0 green:0 blue:1 alpha:1].CGColor,
        ];
        grad.startPoint = CGPointMake(0, 0);
        grad.endPoint   = CGPointMake(1, 1);
        grad.frame = CGRectMake(0, 0, kEdColorCircleD, kEdColorCircleD);
        [circle.layer addSublayer:grad];
        circle.tag = -1;  // 标记为自定义
    } else {
        circle.backgroundColor = color;
        // 白色圆圈需要灰色描边以可见
        if ([color isEqual:UIColor.whiteColor]) {
            circle.layer.borderColor = TSColor_Separator.CGColor;
        }
    }
    return circle;
}

#pragma mark - Frame 布局

- (void)layoutViews {
    CGFloat w  = CGRectGetWidth(self.view.bounds);
    CGFloat h  = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;

    // scrollView 填满页面
    self.scrollView.frame = CGRectMake(0, top, w, h - top);

    CGFloat y    = kEdPadV;
    CGFloat cardW = w - kEdPadH * 2;

    // ── 预览卡片 ──────────────────────────────────────────────────────────────
    // 预览尺寸：直接使用表盘的实际像素尺寸（例如 410×502）
    CGFloat previewW = self.dialSize.width/2;
    CGFloat previewH = self.dialSize.height/2;
    CGFloat previewX = kEdPadH + (cardW - previewW) / 2.f;
    self.previewCard.frame = CGRectMake(previewX, y, previewW, previewH);
    self.previewImageView.frame = self.previewCard.bounds;
    self.timeOverlayImageView.frame = self.previewCard.bounds;

    NSLog(@"[TSDialEditorVC] 预览区域尺寸: %.0f × %.0f (表盘实际尺寸)", previewW, previewH);

    // 视频播放器 frame 需要在布局后更新
    if (self.playerLayer) {
        self.playerLayer.frame = self.previewCard.bounds;
        NSLog(@"[TSDialEditorVC] 更新 playerLayer.frame = %@", NSStringFromCGRect(self.playerLayer.frame));
    }

    y += previewH + kEdPadV;

    // ── 时间位置卡片 ─────────────────────────────────────────────────────────
    // 按钮宽高比与表盘尺寸一致
    CGFloat dialAspectH = (self.dialSize.width > 0 && self.dialSize.height > 0)
                          ? (self.dialSize.height / self.dialSize.width)
                          : 1.f;
    CGFloat timeCellH = kEdTimeCellW * dialAspectH;
    CGFloat posScrollH = timeCellH + kEdPadV;
    CGFloat posCardH = kEdSectionTitleH + posScrollH + kEdPadV;
    self.positionCard.frame = CGRectMake(kEdPadH, y, cardW, posCardH);
    self.positionTitleLabel.frame = CGRectMake(kEdPadH, 0, cardW - kEdPadH * 2, kEdSectionTitleH);
    CGFloat cvY = kEdSectionTitleH;
    self.positionScrollView.frame = CGRectMake(0, cvY, cardW, posScrollH);
    self.positionScrollView.contentSize = CGSizeMake(
        kEdPadH + (kEdTimeCellW + kEdSectionGap) * self.positionBtns.count,
        posScrollH);

    // 布局每个位置按钮
    CGFloat btnX = kEdPadH;
    for (UIButton *btn in self.positionBtns) {
        btn.frame = CGRectMake(btnX, (posScrollH - timeCellH) / 2.f,
                               kEdTimeCellW, timeCellH);
        btnX += kEdTimeCellW + kEdSectionGap;
    }
    // 内部：渲染时间预览图
    [self updatePositionBtnPreviews];

    y += posCardH + kEdPadV;

    // ── 颜色选择卡片 ─────────────────────────────────────────────────────────
    CGFloat colorCardH = kEdSectionTitleH + kEdColorRowH + kEdPadV;
    self.colorCard.frame = CGRectMake(kEdPadH, y, cardW, colorCardH);
    self.colorTitleLabel.frame = CGRectMake(kEdPadH, 0, cardW - kEdPadH * 2, kEdSectionTitleH);

    // 颜色圆圈从左到右排列，左边距与卡片标题对齐
    CGFloat spacing      = 12.f;
    CGFloat circleStartX = kEdPadH;
    CGFloat circleY      = kEdSectionTitleH + (kEdColorRowH - kEdColorCircleD) / 2.f;
    for (UIView *circle in self.colorCircles) {
        NSInteger idx = [self.colorCircles indexOfObject:circle];
        circle.frame = CGRectMake(circleStartX + idx * (kEdColorCircleD + spacing),
                                  circleY, kEdColorCircleD, kEdColorCircleD);
    }

    y += colorCardH + kEdPadV * 2;

    // ── 推送按钮 ─────────────────────────────────────────────────────────────
    self.pushBtn.frame    = CGRectMake(kEdPadH, y, cardW, kEdPushBtnH);
    self.progressBg.frame = CGRectMake(kEdPadH, y, cardW, kEdProgressH);

    // 进度条内部
    self.progressFill.frame  = CGRectMake(0, 0, 0, kEdProgressH);
    self.progressLabel.frame = CGRectMake(0, 0, cardW, kEdProgressH);

    // 全局菊花居中
    self.spinner.center = CGPointMake(w / 2.f, h / 2.f);

    y += kEdPushBtnH + kEdPadV * 2;

    self.scrollView.contentSize = CGSizeMake(w, y);
}

#pragma mark - 预览更新

/** 根据时间位置更新预览区叠加图片，并应用当前颜色 */
- (void)updatePreviewImageForPosition:(TSDialTimePosition)pos {
    NSString *imageName = nil;
    switch (pos) {
        case eTSDialTimePositionTop:    imageName = @"ic_dail_time_top_816N.png";    break;
        case eTSDialTimePositionBottom: imageName = @"ic_dail_time_bottom_816N.png"; break;
        case eTSDialTimePositionLeft:   imageName = @"ic_dail_time_left_816N.png";   break;
        case eTSDialTimePositionRight:  imageName = @"ic_dail_time_right_816N.png";  break;
        default: return;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName
                                                     ofType:nil
                                                inDirectory:@"dialResource"];
    UIImage *raw = path ? [UIImage imageWithContentsOfFile:path] : nil;
    self.timeOverlayImageView.image = [raw imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.timeOverlayImageView.tintColor = self.selectedColor;
}

/** 切换颜色时更新叠加图的 tintColor */
- (void)updateOverlayTintColor {
    self.timeOverlayImageView.tintColor = self.selectedColor;
}

/** 在位置选择按钮内渲染"09:30"预览 */
- (void)updatePositionBtnPreviews {
    for (UIButton *btn in self.positionBtns) {
        TSDialTimePosition pos = (TSDialTimePosition)btn.tag;
        UIImage *preview = [self generatePositionPreviewForPosition:pos];
        [btn setBackgroundImage:preview forState:UIControlStateNormal];
        [btn setTitle:nil forState:UIControlStateNormal];   // 图代替文字
    }
}

/** 生成位置预览缩略图（黑色小矩形 + "09:30" 文字）*/
- (UIImage *)generatePositionPreviewForPosition:(TSDialTimePosition)pos {
    CGFloat aspect = (self.dialSize.width > 0 && self.dialSize.height > 0)
                     ? (self.dialSize.height / self.dialSize.width)
                     : 1.f;
    CGSize size = CGSizeMake(kEdTimeCellW, kEdTimeCellW * aspect);
    UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    return [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        // 背景
        [[UIColor colorWithRed:0.13f green:0.13f blue:0.13f alpha:1.f] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));

        // 时间文字
        NSString *text = @"09:30";
        UIFont   *font = [UIFont monospacedDigitSystemFontOfSize:14 weight:UIFontWeightBold];
        NSDictionary *attrs = @{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.whiteColor
        };
        CGSize textSize = [text sizeWithAttributes:attrs];
        CGFloat tx, ty;
        CGFloat margin = 4;
        switch (pos) {
            case eTSDialTimePositionTop:
                tx = (size.width - textSize.width) / 2.f;
                ty = margin;
                break;
            case eTSDialTimePositionBottom:
                tx = (size.width - textSize.width) / 2.f;
                ty = size.height - textSize.height - margin;
                break;
            case eTSDialTimePositionLeft:
                tx = margin;
                ty = (size.height - textSize.height) / 2.f;
                break;
            case eTSDialTimePositionRight:
                tx = size.width - textSize.width - margin;
                ty = (size.height - textSize.height) / 2.f;
                break;
            default:
                tx = (size.width - textSize.width) / 2.f;
                ty = margin;
                break;
        }
        [text drawAtPoint:CGPointMake(tx, ty) withAttributes:attrs];
    }];
}

- (NSString *)positionTitle:(TSDialTimePosition)pos {
    switch (pos) {
        case eTSDialTimePositionTop:    return @"上方";
        case eTSDialTimePositionBottom: return @"下方";
        case eTSDialTimePositionLeft:   return @"左方";
        case eTSDialTimePositionRight:  return @"右方";
        default: return @"";
    }
}

#pragma mark - 选择状态更新

/** 更新位置选择按钮高亮 */
- (void)updatePositionSelection {
    for (UIButton *btn in self.positionBtns) {
        BOOL selected = (btn.tag == (NSInteger)self.selectedPosition);
        btn.layer.borderColor = selected
            ? TSColor_Primary.CGColor
            : UIColor.clearColor.CGColor;
    }
}

/** 更新颜色圆圈选中描边 */
- (void)updateColorSelection {
    NSArray<UIColor *> *allColors = self.presetColors;
    for (NSInteger i = 0; i < (NSInteger)self.colorCircles.count; i++) {
        UIView *circle = self.colorCircles[i];
        BOOL isCustom = (circle.tag == -1);
        BOOL selected = NO;
        if (!isCustom && i < (NSInteger)allColors.count) {
            selected = CGColorEqualToColor(allColors[i].CGColor, self.selectedColor.CGColor);
        }
        circle.layer.borderColor = selected
            ? TSColor_Primary.CGColor
            : (i == 0
               ? TSColor_Separator.CGColor   // 白色圆圈描边
               : UIColor.clearColor.CGColor);
    }
}

#pragma mark - 按钮回调

/** 时间位置按钮被点击 */
- (void)onPositionBtnTapped:(UIButton *)btn {
    self.selectedPosition = (TSDialTimePosition)btn.tag;
    [self updatePositionSelection];
    [self updatePreviewImageForPosition:self.selectedPosition];
}

/** 颜色圆圈被点击（预设颜色） */
- (void)onColorCircleTapped:(UITapGestureRecognizer *)tap {
    UIView *circle = tap.view;
    NSInteger idx  = [self.colorCircles indexOfObject:circle];
    if (idx >= 0 && idx < (NSInteger)self.presetColors.count) {
        self.selectedColor = self.presetColors[idx];
        [self updateColorSelection];
        [self updateOverlayTintColor];
    }
}

/** 自定义颜色按钮被点击 */
- (void)onCustomColorTapped {
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
        picker.selectedColor = self.selectedColor;
        picker.supportsAlpha = NO;
        picker.delegate      = self;

        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
        nav.view.backgroundColor = UIColor.systemBackgroundColor;

        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
                                      initWithTitle:@"取消"
                                              style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(onColorPickerCancel)];
        picker.navigationItem.leftBarButtonItem = cancelBtn;

        UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc]
                                       initWithTitle:@"确定"
                                               style:UIBarButtonItemStyleDone
                                              target:self
                                              action:@selector(onColorPickerConfirm:)];
        picker.navigationItem.rightBarButtonItem = confirmBtn;

        [self presentViewController:nav animated:YES completion:nil];
    } else {
        [self showAlertWithMsg:@"自定义颜色需要 iOS 14 或以上系统"];
    }
}

/** 颜色选择器取消按钮 */
- (void)onColorPickerCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** 颜色选择器确定按钮 */
- (void)onColorPickerConfirm:(UIBarButtonItem *)sender API_AVAILABLE(ios(14.0)) {
    UINavigationController *nav = (UINavigationController *)self.presentedViewController;
    UIColorPickerViewController *picker = (UIColorPickerViewController *)nav.topViewController;
    self.selectedColor = picker.selectedColor;
    [self updateColorSelection];
    [self updateOverlayTintColor];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIColorPickerViewControllerDelegate (iOS 14+)

- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)viewController
    API_AVAILABLE(ios(14.0)) {
    // 不立即生效，等待用户点击确定按钮
}

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController
    API_AVAILABLE(ios(14.0)) {
    // 不立即生效，等待用户点击确定按钮
}

#pragma mark - 推送表盘

/** 点击"设置为当前表盘"开始推送 */
- (void)onPushBtnTapped {
    if (![[TopStepComKit sharedInstance] connectedPeripheral]) {
        [self showAlertWithMsg:@"请先连接设备"];
        return;
    }

    id<TSPeripheralDialInterface> dialIF = [[TopStepComKit sharedInstance] dial];
    if (!dialIF) {
        [self showAlertWithMsg:@"表盘功能不可用"];
        return;
    }

    // 视频表盘：先确认设备支持
    if (self.isVideo && ![dialIF isSupportVideoDial]) {
        [self showAlertWithMsg:@"当前设备不支持视频表盘"];
        return;
    }

    TSCustomDial *customDial = [self buildCustomDial];
    if (!customDial) {
        [self showAlertWithMsg:@"表盘数据无效，请重试"];
        return;
    }

    [self enterPushingState];
    [self updateProgress:0];

    __weak typeof(self) wself = self;
    [dialIF installCustomDial:customDial
                progressBlock:^(TSDialPushResult result, NSInteger progress) {
                    NSLog(@"[TSDialEditorVC] SDK 进度回调: result=%ld, progress=%ld", (long)result, (long)progress);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [wself updateProgress:progress];
                    });
                }
                   completion:^(TSDialPushResult result, NSError *_Nullable error) {
                    NSLog(@"[TSDialEditorVC] SDK 完成回调: result=%ld, error=%@", (long)result, error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (result == eTSDialPushResultSuccess) {
                            [wself handlePushSuccess];
                        } else if (result == eTSDialPushResultFailed) {
                            [wself handlePushFailed:error];
                        }
                    });
                }];
}

/** 根据选择的来源和配置组装 TSCustomDial */
- (nullable TSCustomDial *)buildCustomDial {
    id<TSPeripheralDialInterface> dialIF = [[TopStepComKit sharedInstance] dial];
    if (!dialIF) return nil;

    TSPeripheralScreen *screen = [[[TopStepComKit sharedInstance] connectedPeripheral] screenInfo];
    CGSize screenSize  = screen.screenSize;
    CGSize previewSize = screen.dialPreviewSize;
    NSLog(@"[TSDialEditorVC] screenSize=%@ dialPreviewSize=%@",
          NSStringFromCGSize(screenSize), NSStringFromCGSize(previewSize));

    if (CGSizeEqualToSize(screenSize, CGSizeZero))  screenSize  = self.dialSize;
    if (CGSizeEqualToSize(previewSize, CGSizeZero)) previewSize = self.dialSize;

    UIImage *timeImage = [self timeTemplateImageForPosition:self.selectedPosition];

    TSCustomDial *customDial = [TSCustomDial new];
    customDial.dialName = @"自定义表盘";

    if (self.isVideo) {
        if (!self.videoURL) return nil;
        customDial.dialType         = eTSCustomDialVideo;
        customDial.dialId           = [dialIF generateCustomDialIdWithType:eTSCustomDialVideo];
        customDial.templateFilePath = [self templateFilePathForType:eTSCustomDialVideo];
        self.lastPushedDialId       = customDial.dialId;

        if (self.sourceImage) {
            TSCustomDialItem *previewItem = [TSCustomDialItem new];
            previewItem.dialType      = eTSCustomDialVideo;
            previewItem.resourceImage = [self imageScaledTo:previewSize image:self.sourceImage];
            previewItem.dialTime.timeImage    = timeImage;
            previewItem.dialTime.timePosition = self.selectedPosition;
            previewItem.dialTime.timeColor    = self.selectedColor;
            previewItem.dialTime.style        = eTSDialTimeStyleNone;
            customDial.previewImageItem = previewItem;
        }

        TSCustomDialItem *videoItem = [TSCustomDialItem new];
        videoItem.dialType      = eTSCustomDialVideo;
        videoItem.videoLocalPath  = self.videoURL.path;
        videoItem.dialTime.timeImage    = timeImage;
        videoItem.dialTime.timePosition = self.selectedPosition;
        videoItem.dialTime.timeColor    = self.selectedColor;
        videoItem.dialTime.style        = eTSDialTimeStyleNone;
        customDial.resourceItems = @[videoItem];

    } else {
        if (!self.sourceImage) return nil;
        customDial.dialType         = eTSCustomDialSingleImage;
        customDial.dialId           = [dialIF generateCustomDialIdWithType:eTSCustomDialSingleImage];
        customDial.templateFilePath = [self templateFilePathForType:eTSCustomDialSingleImage];
        self.lastPushedDialId       = customDial.dialId;

        // previewImageItem：dialPreviewSize（274×334）
        TSCustomDialItem *previewItem = [TSCustomDialItem new];
        previewItem.dialType      = eTSCustomDialSingleImage;
        previewItem.resourceImage = [self imageScaledTo:previewSize image:self.sourceImage];
        previewItem.dialTime.timeImage    = timeImage;
        previewItem.dialTime.timePosition = self.selectedPosition;
        previewItem.dialTime.timeColor    = self.selectedColor;
        previewItem.dialTime.style        = eTSDialTimeStyleNone;
        customDial.previewImageItem = previewItem;

        // resourceItems：screenSize（410×502）
        TSCustomDialItem *bgItem = [TSCustomDialItem new];
        bgItem.dialType      = eTSCustomDialSingleImage;
        bgItem.resourceImage = [self imageScaledTo:screenSize image:self.sourceImage];
        bgItem.dialTime.timeImage    = timeImage;
        bgItem.dialTime.timePosition = self.selectedPosition;
        bgItem.dialTime.timeColor    = self.selectedColor;
        bgItem.dialTime.style        = eTSDialTimeStyleNone;
        customDial.resourceItems = @[bgItem];
    }

    return customDial;
}

/** 将图片缩放到表盘像素尺寸（dialSize = screenSize），scale=1.0 保证像素精确 */
- (UIImage *)imageScaledToDialSize:(UIImage *)image {
    return [self imageScaledTo:self.dialSize image:image];
}

/** 通用缩放：scale=1.0，输出像素尺寸精确匹配 target */
- (UIImage *)imageScaledTo:(CGSize)target image:(UIImage *)image {
    if (target.width <= 0 || target.height <= 0) return image;
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = 1.0;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:target format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        [image drawInRect:CGRectMake(0, 0, target.width, target.height)];
    }];
}

/** 从 dialResource 加载当前位置对应的白色模板图（透明底+白色时间），供 SDK 着色 */
- (nullable UIImage *)timeTemplateImageForPosition:(TSDialTimePosition)pos {
    NSString *name = nil;
    switch (pos) {
        case eTSDialTimePositionTop:    name = @"ic_dail_time_top_816N.png";    break;
        case eTSDialTimePositionBottom: name = @"ic_dail_time_bottom_816N.png"; break;
        case eTSDialTimePositionLeft:   name = @"ic_dail_time_left_816N.png";   break;
        case eTSDialTimePositionRight:  name = @"ic_dail_time_right_816N.png";  break;
        default: return nil;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil inDirectory:@"dialResource"];
    return path ? [UIImage imageWithContentsOfFile:path] : nil;
}

/**
 * 把 ic_custom_dial_6202.zip 从 bundle 拷贝到 tmp 目录并返回路径。
 * bundle 资源是只读的，SDK 在处理模板时需要可写路径。
 */
- (nullable NSString *)templateFilePathForType:(TSCustomDialType)type {
    NSString *fileName   = @"ic_custom_dial_6202.zip";
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:fileName
                                                           ofType:nil
                                                      inDirectory:@"dialResource"];
    if (!bundlePath) {
        NSLog(@"[TSDialEditorVC] 模板文件未找到: %@", fileName);
        return nil;
    }
    NSString *dstDir  = [NSTemporaryDirectory() stringByAppendingPathComponent:@"dialTemplate"];
    NSString *dstPath = [dstDir stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:dstDir withIntermediateDirectories:YES attributes:nil error:nil];
    // 每次覆盖，保证是最新版本
    [fm removeItemAtPath:dstPath error:nil];
    NSError *copyError = nil;
    if (![fm copyItemAtPath:bundlePath toPath:dstPath error:&copyError]) {
        NSLog(@"[TSDialEditorVC] 拷贝模板文件失败: %@", copyError.localizedDescription);
        return nil;
    }
    return dstPath;
}

#pragma mark - 预览图保存

/** 截取 previewCard 当前画面（图片叠加时间位置图层）作为预览图 */
- (nullable UIImage *)capturePreviewSnapshot {
    CGSize size = self.previewCard.bounds.size;
    if (size.width <= 0 || size.height <= 0) return nil;

    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [self.previewCard drawViewHierarchyInRect:self.previewCard.bounds afterScreenUpdates:YES];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // 视频表盘：playerLayer 不在 UIKit 渲染树中，尝试用视频首帧补底
    if (self.isVideo && self.videoURL) {
        UIImage *frame = [self extractVideoFirstFrame];
        if (frame && img) {
            UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);
            [frame drawInRect:CGRectMake(0, 0, size.width, size.height)];
            [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        } else if (frame) {
            img = frame;
        }
    }
    return img;
}

/** 提取视频首帧 */
- (nullable UIImage *)extractVideoFirstFrame {
    if (!self.videoURL) return nil;
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.videoURL];
    AVAssetImageGenerator *gen = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CGImageRef cgImg = [gen copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
    if (!cgImg) return nil;
    UIImage *frame = [UIImage imageWithCGImage:cgImg];
    CGImageRelease(cgImg);
    return frame;
}

/** 将预览图持久化保存到 Documents/dialPreviews/<dialId>.jpg */
- (void)savePreviewSnapshot:(UIImage *)image forDialId:(NSString *)dialId {
    if (!image || dialId.length == 0) return;
    NSString *dir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                     stringByAppendingPathComponent:@"dialPreviews"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSString *path = [dir stringByAppendingPathComponent:
                      [NSString stringWithFormat:@"%@.jpg", dialId]];
    NSData *data = UIImageJPEGRepresentation(image, 0.85f);
    [data writeToFile:path atomically:YES];
    NSLog(@"[TSDialEditorVC] 表盘预览图已保存: %@", path);
}

#pragma mark - 推送状态管理

/** 进入推送中状态 */
- (void)enterPushingState {
    NSLog(@"[TSDialEditorVC] 进入推送状态");
    self.pushBtn.hidden    = YES;
    self.progressBg.hidden = NO;
    [self.spinner startAnimating];
    NSLog(@"[TSDialEditorVC] spinner.isAnimating = %d, spinner.center = %@",
          self.spinner.isAnimating, NSStringFromCGPoint(self.spinner.center));
    // 所有设置选项禁用
    for (UIButton *btn in self.positionBtns) btn.enabled = NO;
    for (UIView *c in self.colorCircles) c.userInteractionEnabled = NO;
}

/** 退出推送状态（失败时） */
- (void)exitPushingState {
    self.pushBtn.hidden    = NO;
    self.progressBg.hidden = YES;
    [self.spinner stopAnimating];
    for (UIButton *btn in self.positionBtns) btn.enabled = YES;
    for (UIView *c in self.colorCircles) c.userInteractionEnabled = YES;
}

/** 更新进度条（0-100） */
- (void)updateProgress:(NSInteger)progress {
    NSLog(@"[TSDialEditorVC] 更新进度: %ld%%", (long)progress);
    CGFloat w = CGRectGetWidth(self.progressBg.bounds);
    CGFloat ratio = MIN(1.f, progress / 100.f);
    self.progressFill.frame   = CGRectMake(0, 0, w * ratio, kEdProgressH);
    self.progressLabel.text   = [NSString stringWithFormat:@"%ld%%", (long)progress];
}

/** 推送成功处理：直接返回到 TSPeripheralDialVC */
- (void)handlePushSuccess {
    NSLog(@"[TSDialEditorVC] 推送成功");
    [self.spinner stopAnimating];
    [self updateProgress:100];

    // 保存预览图到本地
    UIImage *preview = [self capturePreviewSnapshot];
    [self savePreviewSnapshot:preview forDialId:self.lastPushedDialId];

    // 显示成功提示，然后返回到 TSPeripheralDialVC
    void (^onSuccess)(void) = self.onPushSuccess;
    [self showToast:@"推送成功 🎉" success:YES completion:^{
        // 查找导航栈中的 TSPeripheralDialVC
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:NSClassFromString(@"TSPeripheralDialVC")]) {
                [self.navigationController popToViewController:vc animated:YES];
                if (onSuccess) onSuccess();
                return;
            }
        }
        // 如果没找到，就 pop 到根视图
        [self.navigationController popToRootViewControllerAnimated:YES];
        if (onSuccess) onSuccess();
    }];
}

/** 推送失败处理：停留在当前页面，按钮改为"重新推送" */
- (void)handlePushFailed:(NSError *)error {
    NSLog(@"[TSDialEditorVC] 推送失败: %@", error);
    NSString *msg = error.localizedDescription ?: @"推送失败，请重试";
    [self exitPushingState];

    // 修改按钮文字为"重新推送"
    [self.pushBtn setTitle:@"重新推送" forState:UIControlStateNormal];

    [self showToast:msg success:NO completion:nil];
}

#pragma mark - Toast（与 TSPushCloudDialVC 保持一致）

- (void)showToast:(NSString *)msg success:(BOOL)success {
    [self showToast:msg success:success completion:nil];
}

- (void)showToast:(NSString *)msg success:(BOOL)success completion:(nullable void(^)(void))completion {
    UIView *toast      = [[UIView alloc] init];
    toast.alpha        = 0;
    toast.backgroundColor      = [UIColor colorWithWhite:0.1f alpha:0.88f];
    toast.layer.cornerRadius   = 10.f;
    toast.layer.masksToBounds  = YES;

    UILabel *lbl       = [[UILabel alloc] init];
    lbl.text           = msg;
    lbl.font           = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    lbl.textColor      = success ? UIColor.whiteColor : [UIColor colorWithRed:1 green:0.4f blue:0.4f alpha:1.f];
    lbl.textAlignment  = NSTextAlignmentCenter;
    lbl.numberOfLines  = 2;
    [toast addSubview:lbl];

    CGFloat tw = MIN(CGRectGetWidth(self.view.bounds) - 48, 280);
    CGSize  ts = [lbl sizeThatFits:CGSizeMake(tw - 32, 200)];
    CGFloat th = ts.height + 24;
    CGFloat tx = (CGRectGetWidth(self.view.bounds) - tw) / 2.f;
    CGFloat ty = CGRectGetHeight(self.view.bounds) / 2.f - th / 2.f;
    toast.frame = CGRectMake(tx, ty, tw, th);
    lbl.frame   = CGRectMake(16, 12, tw - 32, ts.height);
    [self.view addSubview:toast];

    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1; } completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{ toast.alpha = 0; } completion:^(BOOL f2) {
                [toast removeFromSuperview];
                if (completion) completion();
            }];
        });
    }];
}

#pragma mark - 懒加载

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = TSColor_Background;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)previewCard {
    if (!_previewCard) {
        _previewCard = [[UIView alloc] init];
        _previewCard.backgroundColor    = UIColor.blackColor;
        _previewCard.layer.cornerRadius = kEdCardRadius;
        _previewCard.clipsToBounds      = YES;
        _previewCard.layer.shadowColor  = UIColor.blackColor.CGColor;
        _previewCard.layer.shadowOpacity = 0.1f;
        _previewCard.layer.shadowOffset  = CGSizeMake(0, 4);
        _previewCard.layer.shadowRadius  = 8.f;
    }
    return _previewCard;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.contentMode  = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
        _previewImageView.image = self.sourceImage;
    }
    return _previewImageView;
}

- (UIImageView *)timeOverlayImageView {
    if (!_timeOverlayImageView) {
        _timeOverlayImageView = [[UIImageView alloc] init];
        _timeOverlayImageView.contentMode = UIViewContentModeScaleAspectFill;
        _timeOverlayImageView.clipsToBounds = YES;
    }
    return _timeOverlayImageView;
}

- (UIView *)positionCard {
    if (!_positionCard) {
        _positionCard = [[UIView alloc] init];
        _positionCard.backgroundColor   = TSColor_Card;
        _positionCard.layer.cornerRadius = kEdCardRadius;
        _positionCard.clipsToBounds      = YES;
    }
    return _positionCard;
}

- (UILabel *)positionTitleLabel {
    if (!_positionTitleLabel) {
        _positionTitleLabel = [[UILabel alloc] init];
        _positionTitleLabel.text      = @"时间位置";
        _positionTitleLabel.font      = TSFont_H2;
        _positionTitleLabel.textColor = TSColor_TextPrimary;
    }
    return _positionTitleLabel;
}

- (UIScrollView *)positionScrollView {
    if (!_positionScrollView) {
        _positionScrollView = [[UIScrollView alloc] init];
        _positionScrollView.showsHorizontalScrollIndicator = NO;
        _positionScrollView.backgroundColor = UIColor.clearColor;
    }
    return _positionScrollView;
}

- (UIView *)colorCard {
    if (!_colorCard) {
        _colorCard = [[UIView alloc] init];
        _colorCard.backgroundColor   = TSColor_Card;
        _colorCard.layer.cornerRadius = kEdCardRadius;
        _colorCard.clipsToBounds      = YES;
    }
    return _colorCard;
}

- (UILabel *)colorTitleLabel {
    if (!_colorTitleLabel) {
        _colorTitleLabel = [[UILabel alloc] init];
        _colorTitleLabel.text      = @"时间颜色";
        _colorTitleLabel.font      = TSFont_H2;
        _colorTitleLabel.textColor = TSColor_TextPrimary;
    }
    return _colorTitleLabel;
}

- (UIButton *)pushBtn {
    if (!_pushBtn) {
        _pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pushBtn setTitle:@"设置为当前表盘" forState:UIControlStateNormal];
        [_pushBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _pushBtn.backgroundColor    = TSColor_Primary;
        _pushBtn.titleLabel.font    = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _pushBtn.layer.cornerRadius = kEdCardRadius;
        _pushBtn.layer.masksToBounds = YES;
        [_pushBtn addTarget:self action:@selector(onPushBtnTapped)
           forControlEvents:UIControlEventTouchUpInside];
    }
    return _pushBtn;
}

- (UIView *)progressBg {
    if (!_progressBg) {
        _progressBg = [[UIView alloc] init];
        _progressBg.backgroundColor    = [UIColor colorWithWhite:0.9f alpha:1.f];
        _progressBg.layer.cornerRadius = kEdCardRadius;
        _progressBg.clipsToBounds      = YES;
    }
    return _progressBg;
}

- (UIView *)progressFill {
    if (!_progressFill) {
        _progressFill = [[UIView alloc] init];
        _progressFill.backgroundColor = TSColor_Primary;
    }
    return _progressFill;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.text          = @"0%";
        _progressLabel.font          = [UIFont monospacedDigitSystemFontOfSize:16
                                                                        weight:UIFontWeightSemibold];
        _progressLabel.textColor     = TSColor_TextPrimary;
        _progressLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _progressLabel;
}

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        if (@available(iOS 13.0, *)) {
            _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        _spinner.hidesWhenStopped = YES;
        _spinner.color = TSColor_Primary;
    }
    return _spinner;
}

@end
