//
//  TSRealtimeDanMuPreviewView.m
//  TopStepComKit_Example
//

#import "TSRealtimeDanMuPreviewView.h"

#import "TSDialEditorAppearance.h"
#import "TSRealtimeDanMuDraft.h"
#import "TSRootVC.h"

/** 表壳边框厚度的上下限，按可用宽度的 5% 取值，与表盘预览的比例一致 */
static const CGFloat kTSDanMuMinBezel = 5.f;
static const CGFloat kTSDanMuMaxBezel = 14.f;
/** 底部信息行与说明行占用的高度 */
static const CGFloat kTSDanMuFooterHeight = 52.f;
/** 未知形状且无尺寸时的兜底屏幕 */
static const CGSize kTSDanMuFallbackScreenSize = (CGSize){368.f, 448.f};
static const CGFloat kTSDanMuFallbackBorderRadius = 80.f;

#pragma mark - 单条滚动弹幕

/** @brief One scrolling label with its own motion state. @chinese 一条带独立运动状态的滚动弹幕。 */
@interface TSRealtimeDanMuBullet : NSObject
@property (nonatomic, strong) UILabel *label;
/** 当前横坐标，单位为预览点 */
@property (nonatomic, assign) CGFloat positionX;
/** 换算到预览坐标系后的速度，点/秒 */
@property (nonatomic, assign) CGFloat pointsPerSecond;
/** 是否每轮重新随机纵坐标 */
@property (nonatomic, assign) BOOL randomPosition;
/** 指定纵坐标时的预览纵坐标 */
@property (nonatomic, assign) CGFloat fixedY;
@end

@implementation TSRealtimeDanMuBullet
@end

#pragma mark - 预览视图

@interface TSRealtimeDanMuPreviewView ()

/** 表壳、金属层、表冠与屏幕，取色与 TSDialPreviewView 一致 */
@property (nonatomic, strong) UIView *watchView;
@property (nonatomic, strong) CAGradientLayer *metalLayer;
@property (nonatomic, strong) UIView *crownView;
@property (nonatomic, strong) UIView *screenView;
/** 屏幕内的背景、时间与弹幕层 */
@property (nonatomic, strong) UIImageView *backdropImageView;
@property (nonatomic, strong) CAGradientLayer *backdropGradient;
@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) UILabel *clockLabel;
@property (nonatomic, strong) UILabel *dateLabel;
/** 底部信息与背景切换 */
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UISegmentedControl *backdropSegment;
@property (nonatomic, strong) UILabel *noteLabel;
/** 滚动驱动 */
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval lastTimestamp;
@property (nonatomic, strong) NSMutableArray<TSRealtimeDanMuBullet *> *bullets;
/** 最近一次用于构建弹幕的草稿与内容尺寸 */
@property (nonatomic, copy) NSArray<TSRealtimeDanMuDraft *> *drafts;
@property (nonatomic, assign) CGSize renderedContentSize;

@end

@implementation TSRealtimeDanMuPreviewView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bullets = [NSMutableArray array];
        _drafts = @[];
        _backdrop = TSRealtimeDanMuBackdropDefault;
        self.backgroundColor = UIColor.clearColor;
        self.contentMode = UIViewContentModeRedraw;
        [self buildSubviews];
        [self applyBackdrop];
    }
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
}

/** 预览区底色沿用表盘预览的浅色径向渐变，与页面平铺底色区分开 */
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSArray *colors = @[(id)[TSDialEditorAppearance color:0xFCFCF8].CGColor,
                        (id)[TSDialEditorAppearance color:0xEDEFE5].CGColor];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGContextDrawRadialGradient(context, gradient, center, 0, center,
                                MAX(rect.size.width, rect.size.height) / 2, 3);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
}

/** 宽高变化才重建弹幕，避免每帧重复布局 */
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutShell];
    if (!CGSizeEqualToSize(self.renderedContentSize, self.trackView.bounds.size)) {
        [self rebuildBullets];
    }
}

#pragma mark - 公开方法

- (void)setScreen:(TSPeripheralScreen *)screen {
    _screen = screen;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self rebuildBullets];
}

- (void)setBackdrop:(TSRealtimeDanMuBackdrop)backdrop {
    _backdrop = backdrop;
    self.backdropSegment.selectedSegmentIndex = backdrop;
    [self applyBackdrop];
}

- (void)reloadWithDrafts:(NSArray<TSRealtimeDanMuDraft *> *)drafts {
    self.drafts = drafts ?: @[];
    [self rebuildBullets];
}

- (void)resume {
    if (self.displayLink) {
        return;
    }
    self.lastTimestamp = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(step:)];
    [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (void)suspend {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

#pragma mark - 私有方法：屏幕参数

/** 未知形状时按真实宽高比反推，避免圆表被当成方表 */
- (TSPeriphShape)effectiveShape {
    TSPeriphShape shape = self.screen.shape;
    if (shape != eTSPeriphShapeUnknow) {
        return shape;
    }
    CGSize size = self.screen.screenSize;
    if (size.width <= 0 || size.height <= 0) {
        return eTSPeriphShapeVerticalRectangle;
    }
    if (fabs(size.width - size.height) < 0.01) {
        return eTSPeriphShapeSquare;
    }
    return size.width > size.height ? eTSPeriphShapeTransverseRectangle : eTSPeriphShapeVerticalRectangle;
}

/** 设备未上报尺寸时回退到 368 × 448 */
- (CGSize)effectiveScreenSize {
    CGSize size = self.screen.screenSize;
    if (size.width > 0 && size.height > 0) {
        return size;
    }
    return kTSDanMuFallbackScreenSize;
}

- (CGFloat)effectiveBorderRadius {
    CGSize size = self.screen.screenSize;
    if (size.width > 0 && size.height > 0) {
        return MAX(0.f, self.screen.screenBorderRadius);
    }
    return kTSDanMuFallbackBorderRadius;
}

- (NSString *)shapeName {
    switch ([self effectiveShape]) {
        case eTSPeriphShapeCircle:
            return TSLocalizedString(@"realtime_danmu.shape.circle");
        case eTSPeriphShapeSquare:
            return TSLocalizedString(@"realtime_danmu.shape.square");
        case eTSPeriphShapeTransverseRectangle:
            return TSLocalizedString(@"realtime_danmu.shape.transverse");
        default:
            return TSLocalizedString(@"realtime_danmu.shape.vertical");
    }
}

#pragma mark - 私有方法：布局

/** 几何规则照搬 TSDialPreviewView：真实比例定表壳，圆角按 screenBorderRadius 等比换算 */
- (void)layoutShell {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    if (width <= 0 || height <= 0) {
        return;
    }
    BOOL circular = [self effectiveShape] == eTSPeriphShapeCircle;
    CGSize screenSize = [self effectiveScreenSize];
    CGFloat maximumWidth = width - 40;
    CGFloat maximumHeight = height - kTSDanMuFooterHeight - 8;
    // 表壳厚度按可用宽度取比例，避免大预览上出现一圈过细的金属边
    CGFloat bezel = MIN(kTSDanMuMaxBezel, MAX(kTSDanMuMinBezel, round(maximumWidth * 0.05f)));
    CGFloat shellWidth = 0, shellHeight = 0, shellRadius = 0;

    if (circular) {
        shellWidth = shellHeight = MIN(maximumWidth, maximumHeight);
        shellRadius = shellWidth / 2;
    } else {
        CGFloat ratio = screenSize.width / screenSize.height;
        shellWidth = maximumWidth;
        shellHeight = (shellWidth - bezel * 2) / ratio + bezel * 2;
        if (shellHeight > maximumHeight) {
            shellHeight = maximumHeight;
            shellWidth = (shellHeight - bezel * 2) * ratio + bezel * 2;
        }
        CGFloat scale = (shellWidth - bezel * 2) / screenSize.width;
        shellRadius = [self effectiveBorderRadius] * scale + bezel;
        shellRadius = MIN(shellRadius, MIN(shellWidth, shellHeight) / 2);
    }

    CGFloat shellTop = MAX(0.f, (maximumHeight - shellHeight) / 2);
    self.watchView.frame = CGRectMake((width - shellWidth) / 2, shellTop, shellWidth, shellHeight);
    self.metalLayer.frame = self.watchView.bounds;
    self.metalLayer.cornerRadius = shellRadius;
    self.watchView.layer.shadowPath =
        [UIBezierPath bezierPathWithRoundedRect:self.watchView.bounds cornerRadius:shellRadius].CGPath;

    // 圆表按几何中心对齐；方形与长方形沿用表盘预览偏上 34% 的位置
    CGFloat crownHeight = 23;
    CGFloat crownTop = circular ? (shellHeight - crownHeight) / 2 : shellHeight * 0.34;
    self.crownView.frame = CGRectMake(CGRectGetMaxX(self.watchView.frame) - 1,
                                      CGRectGetMinY(self.watchView.frame) + crownTop, 6, crownHeight);

    self.screenView.frame = CGRectInset(self.watchView.bounds, bezel, bezel);
    CGRect content = self.screenView.bounds;
    CGFloat pixelScale = CGRectGetWidth(content) / screenSize.width;
    self.screenView.layer.cornerRadius = circular ? CGRectGetWidth(content) / 2
                                                  : [self effectiveBorderRadius] * pixelScale;

    self.backdropImageView.frame = content;
    self.backdropGradient.frame = content;
    self.trackView.frame = content;

    CGFloat base = MIN(CGRectGetWidth(content), CGRectGetHeight(content));
    self.clockLabel.font = [UIFont systemFontOfSize:round(base * 0.21) weight:UIFontWeightUltraLight];
    self.dateLabel.font = [UIFont systemFontOfSize:MAX(8.f, round(base * 0.045))];
    CGFloat clockHeight = round(base * 0.26);
    self.clockLabel.frame = CGRectMake(0, CGRectGetMidY(content) - clockHeight,
                                       CGRectGetWidth(content), clockHeight);
    self.dateLabel.frame = CGRectMake(0, CGRectGetMaxY(self.clockLabel.frame),
                                      CGRectGetWidth(content), round(base * 0.08));

    CGFloat footerTop = CGRectGetMaxY(self.watchView.frame) + 10;
    CGFloat segmentWidth = 168;
    self.metaLabel.frame = CGRectMake(20, footerTop, width - 40 - segmentWidth - 8, 26);
    self.backdropSegment.frame = CGRectMake(width - 20 - segmentWidth, footerTop, segmentWidth, 26);
    self.noteLabel.frame = CGRectMake(20, footerTop + 28, width - 40, 14);

    self.metaLabel.text = [NSString stringWithFormat:@"%.0f × %.0f · %@",
                           screenSize.width, screenSize.height, [self shapeName]];
}

#pragma mark - 私有方法：构建

- (void)buildSubviews {
    // 表冠先加，让金属表壳压住内侧一小段
    self.crownView = [[UIView alloc] init];
    self.crownView.backgroundColor = [TSDialEditorAppearance color:0x424639];
    self.crownView.layer.cornerRadius = 2;
    [self addSubview:self.crownView];

    self.watchView = [[UIView alloc] init];
    self.watchView.layer.shadowColor = [TSDialEditorAppearance color:0x444A30].CGColor;
    self.watchView.layer.shadowOpacity = 0.25;
    self.watchView.layer.shadowRadius = 10;
    self.watchView.layer.shadowOffset = CGSizeMake(0, 10);
    [self addSubview:self.watchView];

    self.metalLayer = [CAGradientLayer layer];
    self.metalLayer.colors = @[(id)[TSDialEditorAppearance color:0xB9BBB0].CGColor,
                               (id)[TSDialEditorAppearance color:0x242620].CGColor,
                               (id)[TSDialEditorAppearance color:0x777B6C].CGColor];
    self.metalLayer.startPoint = CGPointZero;
    self.metalLayer.endPoint = CGPointMake(1, 1);
    self.metalLayer.borderWidth = 2;
    self.metalLayer.borderColor = [TSDialEditorAppearance color:0x33372A].CGColor;
    [self.watchView.layer addSublayer:self.metalLayer];

    self.screenView = [[UIView alloc] init];
    self.screenView.clipsToBounds = YES;
    self.screenView.backgroundColor = UIColor.blackColor;
    self.screenView.layer.borderWidth = 1;
    self.screenView.layer.borderColor = [TSDialEditorAppearance color:0x141A13].CGColor;
    [self.watchView addSubview:self.screenView];

    self.backdropImageView = [[UIImageView alloc] init];
    self.backdropImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backdropImageView.clipsToBounds = YES;
    [self.screenView addSubview:self.backdropImageView];

    self.backdropGradient = [CAGradientLayer layer];
    self.backdropGradient.startPoint = CGPointMake(0.15, 0);
    self.backdropGradient.endPoint = CGPointMake(0.85, 1);
    [self.screenView.layer addSublayer:self.backdropGradient];

    self.clockLabel = [[UILabel alloc] init];
    self.clockLabel.textAlignment = NSTextAlignmentCenter;
    self.clockLabel.text = @"09:41";
    [self.screenView addSubview:self.clockLabel];

    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.text = TSLocalizedString(@"realtime_danmu.preview.date");
    [self.screenView addSubview:self.dateLabel];

    self.trackView = [[UIView alloc] init];
    self.trackView.clipsToBounds = YES;
    self.trackView.userInteractionEnabled = NO;
    [self.screenView addSubview:self.trackView];

    self.metaLabel = [TSDialEditorAppearance label:@"" size:10 color:0x93958E];
    self.metaLabel.font = [UIFont monospacedDigitSystemFontOfSize:10 weight:UIFontWeightRegular];
    [self addSubview:self.metaLabel];

    self.backdropSegment = [[UISegmentedControl alloc] initWithItems:@[
        TSLocalizedString(@"realtime_danmu.backdrop.default"),
        TSLocalizedString(@"realtime_danmu.backdrop.black"),
        TSLocalizedString(@"realtime_danmu.backdrop.white")
    ]];
    self.backdropSegment.selectedSegmentIndex = 0;
    self.backdropSegment.tintColor = [TSDialEditorAppearance color:0x849475];
    [self.backdropSegment addTarget:self action:@selector(changeBackdrop:)
                   forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.backdropSegment];

    self.noteLabel = [TSDialEditorAppearance label:TSLocalizedString(@"realtime_danmu.preview.note")
                                              size:10 color:0x93958E];
    self.noteLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.noteLabel];
}

/** 优先用内置资源，缺资源时退回程序绘制的渐变，保证 Demo 不因缺图而空白 */
- (void)applyBackdrop {
    UIImage *image = [UIImage imageNamed:@"ts_danmu_preview_bg"];
    BOOL useDefault = self.backdrop == TSRealtimeDanMuBackdropDefault;
    self.backdropImageView.image = useDefault ? image : nil;
    self.backdropGradient.hidden = !useDefault || image != nil;

    if (useDefault) {
        self.screenView.backgroundColor = [TSDialEditorAppearance color:0x16203A];
        self.backdropGradient.colors = @[
            (__bridge id)[TSDialEditorAppearance color:0x2B3F6B].CGColor,
            (__bridge id)[TSDialEditorAppearance color:0x23304F].CGColor,
            (__bridge id)[TSDialEditorAppearance color:0x0C1020].CGColor
        ];
    } else if (self.backdrop == TSRealtimeDanMuBackdropWhite) {
        self.screenView.backgroundColor = UIColor.whiteColor;
    } else {
        self.screenView.backgroundColor = UIColor.blackColor;
    }

    BOOL light = self.backdrop == TSRealtimeDanMuBackdropWhite;
    self.clockLabel.textColor = [UIColor colorWithWhite:light ? 0 : 1 alpha:light ? 0.13 : 0.18];
    self.dateLabel.textColor = [UIColor colorWithWhite:light ? 0 : 1 alpha:light ? 0.11 : 0.14];
}

- (void)changeBackdrop:(UISegmentedControl *)sender {
    _backdrop = (TSRealtimeDanMuBackdrop)sender.selectedSegmentIndex;
    [self applyBackdrop];
    if (self.onBackdropChanged) {
        self.onBackdropChanged(self.backdrop);
    }
}

#pragma mark - 私有方法：弹幕

/** 动画类型在预览里用符号示意，不代表设备实际动画资源 */
- (NSString *)animationSymbol:(TSDanMuAnimation)animation {
    switch (animation) {
        case TSDanMuAnimationHeart:
            return @"  ♥";
        case TSDanMuAnimationBirthday1:
            return @"  🎂";
        case TSDanMuAnimationBirthday2:
            return @"  🎉";
        default:
            return @"";
    }
}

/** 圆形表盘上下留白，避免文字飞到圆外被裁 */
- (CGFloat)randomTopForHeight:(CGFloat)labelHeight {
    CGFloat contentHeight = CGRectGetHeight(self.trackView.bounds);
    CGFloat padding = [self effectiveShape] == eTSPeriphShapeCircle ? contentHeight * 0.18 : 6;
    CGFloat span = MAX(4.f, contentHeight - padding * 2 - labelHeight);
    return padding + arc4random_uniform((uint32_t)span);
}

- (void)rebuildBullets {
    for (TSRealtimeDanMuBullet *bullet in self.bullets) {
        [bullet.label removeFromSuperview];
    }
    [self.bullets removeAllObjects];

    CGSize contentSize = self.trackView.bounds.size;
    self.renderedContentSize = contentSize;
    if (contentSize.width <= 0 || contentSize.height <= 0) {
        return;
    }

    CGSize screenSize = [self effectiveScreenSize];
    CGFloat scale = contentSize.width / screenSize.width;
    NSUInteger index = 0;

    for (TSRealtimeDanMuDraft *draft in self.drafts) {
        if (draft.text.length == 0) {
            continue;
        }
        UILabel *label = [[UILabel alloc] init];
        label.text = [draft.text stringByAppendingString:[self animationSymbol:draft.animation]];
        label.textColor = draft.color;
        label.font = [UIFont systemFontOfSize:MAX(8.f, draft.fontSize * scale) weight:UIFontWeightMedium];
        label.layer.shadowColor = UIColor.blackColor.CGColor;
        label.layer.shadowOpacity = 0.35;
        label.layer.shadowRadius = 2;
        label.layer.shadowOffset = CGSizeMake(0, 1);
        [label sizeToFit];
        [self.trackView addSubview:label];

        TSRealtimeDanMuBullet *bullet = [[TSRealtimeDanMuBullet alloc] init];
        bullet.label = label;
        bullet.pointsPerSecond = MAX(4.f, draft.speed * scale);
        bullet.randomPosition = [draft isRandomPosition];
        bullet.fixedY = bullet.randomPosition ? 0
            : MIN(contentSize.height - CGRectGetHeight(label.bounds),
                  draft.yCoordinate * contentSize.height / screenSize.height);
        bullet.positionX = contentSize.width + index * 90;
        label.frame = CGRectMake(bullet.positionX,
                                 bullet.randomPosition ? [self randomTopForHeight:CGRectGetHeight(label.bounds)]
                                                       : bullet.fixedY,
                                 CGRectGetWidth(label.bounds), CGRectGetHeight(label.bounds));
        [self.bullets addObject:bullet];
        index++;
    }
}

/** 匀速左移，出界后回到右侧；随机位的每轮重新落位 */
- (void)step:(CADisplayLink *)link {
    if (self.lastTimestamp <= 0) {
        self.lastTimestamp = link.timestamp;
        return;
    }
    CFTimeInterval delta = MIN(0.05, link.timestamp - self.lastTimestamp);
    self.lastTimestamp = link.timestamp;
    CGFloat contentWidth = CGRectGetWidth(self.trackView.bounds);

    for (TSRealtimeDanMuBullet *bullet in self.bullets) {
        CGRect frame = bullet.label.frame;
        bullet.positionX -= bullet.pointsPerSecond * delta;
        if (bullet.positionX < -CGRectGetWidth(frame) - 10) {
            bullet.positionX = contentWidth + 10;
            if (bullet.randomPosition) {
                frame.origin.y = [self randomTopForHeight:CGRectGetHeight(frame)];
            }
        }
        frame.origin.x = bullet.positionX;
        bullet.label.frame = frame;
    }
}

@end
