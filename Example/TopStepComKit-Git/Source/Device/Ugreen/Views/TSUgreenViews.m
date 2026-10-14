//
//  TSUgreenViews.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/14.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSUgreenViews.h"

#import "TSRootVC.h"
#import "TSHsdDisplay.h"
#import "TSHsdViews.h"
#import "TSHsdCallLog.h"

#pragma mark - 工具函数

/** 0xRRGGBB → UIColor */
static UIColor *TSUgRGB(NSInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.f green:((hex >> 8) & 0xFF) / 255.f blue:(hex & 0xFF) / 255.f alpha:1.f];
}

/** 卡片内分隔线色 */
static UIColor *TSUgLine(void) {
    return TSAdaptiveColor([[UIColor blackColor] colorWithAlphaComponent:0.06f], [[UIColor whiteColor] colorWithAlphaComponent:0.08f]);
}

/** 二级填充色（原型 --fill-2） */
static UIColor *TSUgFill2(void) {
    return TSAdaptiveColor(TSUgRGB(0xE2E5EF), TSUgRGB(0x2B3041));
}

/** 原型 --sky */
static UIColor *TSUgSky(void) {
    return TSAdaptiveColor(TSUgRGB(0x1B8FD6), TSUgRGB(0x4DB5F5));
}

/** 卡片阴影（原型 --sh） */
static void TSUgApplyCardShadow(UIView *view) {
    view.layer.shadowColor = TSUgRGB(0x141726).CGColor;
    view.layer.shadowOpacity = 0.06f;
    view.layer.shadowRadius = 10.f;
    view.layer.shadowOffset = CGSizeMake(0, 4.f);
}

/** 新建标签 */
static UILabel *TSUgLabel(UIFont *font, UIColor *color) {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    return label;
}

/** 文字在给定宽度下的高度 */
static CGFloat TSUgTextHeight(NSString *text, UIFont *font, CGFloat width, CGFloat lineMultiple) {
    if (!text.length) { return 0; }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = lineMultiple;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font, NSParagraphStyleAttributeName: style}
                                     context:nil];
    return ceil(rect.size.height);
}

/** 带行高的富文本 */
static NSAttributedString *TSUgParagraph(NSString *text, UIFont *font, UIColor *color, CGFloat lineMultiple, NSTextAlignment alignment) {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = lineMultiple;
    style.alignment = alignment;
    return [[NSAttributedString alloc] initWithString:text ?: @""
                                           attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: style}];
}

/** 线性渐变图层 */
static CAGradientLayer *TSUgLinear(NSArray<UIColor *> *colors, NSArray<NSNumber *> *_Nullable locations, CGFloat cssAngle) {
    CAGradientLayer *layer = [CAGradientLayer layer];
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *color in colors) { [cgColors addObject:(__bridge id)color.CGColor]; }
    layer.colors = cgColors;
    layer.locations = locations;
    [TSUgreenDisplay applyCSSAngle:cssAngle toGradient:layer];
    return layer;
}

/** 24 栅格里的播放控制图标（0 上一首 / 1 播放 / 2 下一首） */
static CAShapeLayer *TSUgControlIcon(NSInteger kind, CGRect frame) {
    CGFloat f = frame.size.width / 24.f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (kind == 1) {
        [path moveToPoint:CGPointMake(8 * f, 5 * f)];
        [path addLineToPoint:CGPointMake(8 * f, 19 * f)];
        [path addLineToPoint:CGPointMake(19 * f, 12 * f)];
        [path closePath];
    } else {
        BOOL prev = (kind == 0);
        [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake((prev ? 6 : 16) * f, 6 * f, 2 * f, 12 * f)]];
        [path moveToPoint:CGPointMake((prev ? 20 : 4) * f, 6 * f)];
        [path addLineToPoint:CGPointMake((prev ? 20 : 4) * f, 18 * f)];
        [path addLineToPoint:CGPointMake((prev ? 10 : 14) * f, 12 * f)];
        [path closePath];
    }
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = frame;
    layer.path = path.CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    return layer;
}

#pragma mark - TSUgreenDeviceView

@interface TSUgreenDeviceView ()
// 支架腿（.leg）
@property (nonatomic, strong) UIView *legView;
@property (nonatomic, strong) CAGradientLayer *legGradient;
// 外壳（.dev）
@property (nonatomic, strong) UIView *bezelView;
@property (nonatomic, strong) CAGradientLayer *bezelGradient;
// 未上报屏幕信息时的虚线外框
@property (nonatomic, strong) CAShapeLayer *dashedBorder;
// 屏幕裁切区（.scrbox）
@property (nonatomic, strong) UIView *screenClip;
// 按设备像素排版的屏幕（.scr）
@property (nonatomic, strong, nullable) UIView *screenView;
@end

@implementation TSUgreenDeviceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _spec = [TSUgreenScreenSpec specWithScreen:nil];
    _lyricsColor = [UIColor whiteColor];
    _bezel = 9.f;
    _maxScreenSize = CGSizeMake(250.f, 176.f);
    _maxScale = 0.5f;

    _legView = [[UIView alloc] init];
    _legView.layer.anchorPoint = CGPointMake(0.5f, 0.f);
    _legView.layer.cornerRadius = 4.f;
    _legView.clipsToBounds = YES;
    _legGradient = TSUgLinear(@[TSUgRGB(0x2A2C33), TSUgRGB(0x62656E)], nil, 90.f);
    [_legView.layer addSublayer:_legGradient];
    _legView.hidden = YES;
    [self addSubview:_legView];

    _bezelView = [[UIView alloc] init];
    _bezelGradient = TSUgLinear(@[TSUgRGB(0x5D6069), TSUgRGB(0x1A1B20), TSUgRGB(0x30323A)], @[@0, @0.45, @1], 150.f);
    _bezelGradient.masksToBounds = YES;
    [_bezelView.layer addSublayer:_bezelGradient];
    _bezelView.layer.shadowColor = [UIColor blackColor].CGColor;
    _bezelView.layer.shadowOffset = CGSizeMake(0, 18.f);
    _bezelView.layer.shadowRadius = 15.f;
    [self addSubview:_bezelView];

    _dashedBorder = [CAShapeLayer layer];
    _dashedBorder.fillColor = [UIColor clearColor].CGColor;
    _dashedBorder.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f].CGColor;
    _dashedBorder.lineWidth = 1.5f;
    _dashedBorder.lineDashPattern = @[@5, @4];
    [_bezelView.layer addSublayer:_dashedBorder];

    _screenClip = [[UIView alloc] init];
    _screenClip.backgroundColor = [UIColor blackColor];
    _screenClip.clipsToBounds = YES;
    [_bezelView addSubview:_screenClip];
    return self;
}

#pragma mark - 公开方法

/** 重建屏幕内容 */
- (void)reload {
    [self.screenView removeFromSuperview];
    self.screenView = [self ts_buildScreen];
    [self.screenClip addSubview:self.screenView];

    BOOL known = self.spec.isKnown;
    self.bezelGradient.hidden = !known;
    self.dashedBorder.hidden = known;
    self.bezelView.backgroundColor = known ? [UIColor clearColor] : [[UIColor whiteColor] colorWithAlphaComponent:0.03f];
    self.bezelView.layer.borderWidth = known ? 1.f : 0;
    self.bezelView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.18f].CGColor;
    self.bezelView.layer.shadowOpacity = known ? 0.55f : 0;
    self.legView.hidden = !self.showsLeg;
    [self setNeedsLayout];
}

/** 外壳尺寸 */
- (CGSize)deviceSize {
    CGFloat k = [self ts_scale];
    return CGSizeMake(self.spec.size.width * k + self.bezel * 2, self.spec.size.height * k + self.bezel * 2);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self deviceSize];
}

#pragma mark - 私有方法

/** 缩放倍数 */
- (CGFloat)ts_scale {
    CGSize s = self.spec.size;
    return MIN(self.maxScale, MIN(self.maxScreenSize.width / s.width, self.maxScreenSize.height / s.height));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat k = [self ts_scale];
    CGSize native = self.spec.size;
    CGSize scaled = CGSizeMake(native.width * k, native.height * k);
    CGSize device = [self deviceSize];
    CGRect bezelRect = CGRectMake((self.bounds.size.width - device.width) / 2.f, (self.bounds.size.height - device.height) / 2.f,
                                  device.width, device.height);
    CGFloat outerRadius = self.spec.cornerRadius * k + self.bezel;

    self.bezelView.frame = bezelRect;
    self.bezelView.layer.cornerRadius = outerRadius;
    self.bezelGradient.frame = self.bezelView.bounds;
    self.bezelGradient.cornerRadius = outerRadius;
    // 原型阴影 0 18 30 -14：向内收 14 再模糊
    self.bezelView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bezelView.bounds, 14.f, 14.f)
                                                                 cornerRadius:MAX(outerRadius - 14.f, 0)].CGPath;
    self.dashedBorder.frame = self.bezelView.bounds;
    self.dashedBorder.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bezelView.bounds, 0.75f, 0.75f)
                                                        cornerRadius:MAX(outerRadius - 0.75f, 0)].CGPath;

    self.screenClip.frame = CGRectMake(self.bezel, self.bezel, scaled.width, scaled.height);
    self.screenClip.layer.cornerRadius = self.spec.cornerRadius * k;
    self.screenView.transform = CGAffineTransformIdentity;
    self.screenView.bounds = CGRectMake(0, 0, native.width, native.height);
    self.screenView.center = CGPointMake(scaled.width / 2.f, scaled.height / 2.f);
    self.screenView.transform = CGAffineTransformMakeScale(k, k);

    // 支架腿：外壳 58% 处，顶部嵌进外壳 6，绕顶部转 16°
    self.legView.transform = CGAffineTransformIdentity;
    self.legView.bounds = CGRectMake(0, 0, 7.f, 30.f);
    self.legView.center = CGPointMake(CGRectGetMinX(bezelRect) + device.width * 0.58f, CGRectGetMaxY(bezelRect) - 6.f);
    self.legView.transform = CGAffineTransformMakeRotation(16.f * M_PI / 180.f);
    self.legGradient.frame = self.legView.bounds;
}

/** 按设备像素生成屏幕 */
- (UIView *)ts_buildScreen {
    CGSize s = self.spec.size;
    CGFloat u = MAX(0.55f, MIN(1.4f, MIN(s.width, s.height) / 360.f));
    BOOL circle = self.spec.isCircle;
    UIView *screen = [[UIView alloc] initWithFrame:CGRectMake(0, 0, s.width, s.height)];
    screen.backgroundColor = [UIColor blackColor];
    screen.layer.cornerRadius = self.spec.cornerRadius;
    screen.clipsToBounds = YES;
    switch (self.content) {
        case TSUgreenScreenContentLyrics: [self ts_buildLyricsIn:screen u:u circle:circle]; break;
        case TSUgreenScreenContentMusic:  [self ts_buildMusicIn:screen u:u circle:circle]; break;
        case TSUgreenScreenContentStatus: [self ts_buildStatusIn:screen u:u]; break;
    }
    if (self.badgeText.length) { [self ts_addBadgeIn:screen u:u circle:circle]; }
    if (self.overlayFunction) { [self ts_addOverlayIn:screen u:u]; }
    return screen;
}

/** 歌词页：主题底色 + 歌曲名 + 三行歌词（中间行为当前行） */
- (void)ts_buildLyricsIn:(UIView *)screen u:(CGFloat)u circle:(BOOL)circle {
    CGFloat w = screen.bounds.size.width, h = screen.bounds.size.height;
    [TSUgreenDisplay applyTheme:self.theme toLayer:screen.layer starScale:2.2f * u];

    UILabel *meta = TSUgLabel([UIFont systemFontOfSize:19.f * u weight:UIFontWeightSemibold], [[UIColor whiteColor] colorWithAlphaComponent:0.55f]);
    meta.text = TSLocalizedString(@"ugreen.preview.song");
    [meta sizeToFit];
    if (circle) {
        meta.textAlignment = NSTextAlignmentCenter;
        meta.frame = CGRectMake(0, h * 0.15f, w, meta.bounds.size.height);
    } else {
        meta.frame = CGRectMake(26.f * u, 22.f * u, meta.bounds.size.width, meta.bounds.size.height);
    }
    [screen addSubview:meta];

    NSArray<NSString *> *lines = @[TSLocalizedString(@"ugreen.preview.lyric1"), TSLocalizedString(@"ugreen.preview.lyric2"), TSLocalizedString(@"ugreen.preview.lyric3")];
    UIFont *small = [UIFont systemFontOfSize:22.f * u];
    UIFont *big = [UIFont systemFontOfSize:36.f * u weight:UIFontWeightHeavy];
    CGFloat smallH = 22.f * u * 1.25f, bigH = 36.f * u * 1.25f, gap = 14.f * u;
    CGFloat total = smallH * 2 + bigH + gap * 2;
    CGFloat y = (26.f * u + h) / 2.f - total / 2.f;   // 内容区从 26u 开始，垂直居中
    UIColor *accent = [TSUgreenDisplay themeAccent:self.theme customColor:self.lyricsColor];
    UIColor *dim = [TSUgreenDisplay themeDimText:self.theme];
    for (NSUInteger i = 0; i < lines.count; i++) {
        BOOL current = (i == 1);
        UILabel *line = TSUgLabel(current ? big : small, current ? accent : dim);
        line.text = lines[i];
        line.textAlignment = NSTextAlignmentCenter;
        CGFloat lineH = current ? bigH : smallH;
        line.frame = CGRectMake(0, y, w, lineH);
        [screen addSubview:line];
        y += lineH + gap;
    }
}

/** 音乐控制页：封面 + 歌名 + 歌手 + 进度条 + 三个按钮 */
- (void)ts_buildMusicIn:(UIView *)screen u:(CGFloat)u circle:(BOOL)circle {
    CGFloat w = screen.bounds.size.width, h = screen.bounds.size.height;
    CAGradientLayer *bg = TSUgLinear(@[TSUgRGB(0x16181F), [UIColor blackColor]], nil, 170.f);
    bg.frame = screen.bounds;
    [screen.layer insertSublayer:bg atIndex:0];

    CGFloat gap = (circle ? 10.f : 12.f) * u;
    CGFloat padTop = (circle ? 58.f : 18.f) * u;
    CGFloat coverSide = 80.f * u, titleH = 27.f * u * 1.25f, artistH = 18.f * u * 1.25f, barH = 5.f * u, controlH = 46.f * u;
    CGFloat total = coverSide + gap + titleH + gap - 6.f * u + artistH + gap + barH + gap + controlH;
    CGFloat y = padTop + (h - padTop - total) / 2.f;

    UIView *cover = [[UIView alloc] initWithFrame:CGRectMake((w - coverSide) / 2.f, y, coverSide, coverSide)];
    cover.layer.cornerRadius = 20.f * u;
    cover.clipsToBounds = YES;
    CAGradientLayer *coverGradient = TSUgLinear(@[TSUgRGB(0x4FD58A), TSUgRGB(0x2A7BD6)], nil, 135.f);
    coverGradient.frame = cover.bounds;
    [cover.layer addSublayer:coverGradient];
    [screen addSubview:cover];
    y += coverSide + gap;

    UILabel *title = TSUgLabel([UIFont systemFontOfSize:27.f * u weight:UIFontWeightBold], [UIColor whiteColor]);
    title.text = TSLocalizedString(@"ugreen.preview.song");
    title.textAlignment = NSTextAlignmentCenter;
    title.frame = CGRectMake(0, y, w, titleH);
    [screen addSubview:title];
    y += titleH + gap - 6.f * u;

    UILabel *artist = TSUgLabel([UIFont systemFontOfSize:18.f * u], [[UIColor whiteColor] colorWithAlphaComponent:0.55f]);
    artist.text = TSLocalizedString(@"ugreen.preview.artist");
    artist.textAlignment = NSTextAlignmentCenter;
    artist.frame = CGRectMake(0, y, w, artistH);
    [screen addSubview:artist];
    y += artistH + gap;

    CGFloat barW = w * 0.52f;
    UIView *track = [[UIView alloc] initWithFrame:CGRectMake((w - barW) / 2.f, y, barW, barH)];
    track.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15f];
    track.layer.cornerRadius = barH / 2.f;
    UIView *fill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, barW * 0.38f, barH)];
    fill.backgroundColor = [UIColor whiteColor];
    fill.layer.cornerRadius = barH / 2.f;
    [track addSubview:fill];
    [screen addSubview:track];
    y += barH + gap;

    CGFloat sideIcon = 30.f * u, playIcon = 46.f * u, controlGap = (circle ? 36.f : 44.f) * u;
    CGFloat x = (w - sideIcon * 2 - playIcon - controlGap * 2) / 2.f;
    CGFloat centerY = y + controlH / 2.f;
    [screen.layer addSublayer:TSUgControlIcon(0, CGRectMake(x, centerY - sideIcon / 2.f, sideIcon, sideIcon))];
    x += sideIcon + controlGap;
    [screen.layer addSublayer:TSUgControlIcon(1, CGRectMake(x, centerY - playIcon / 2.f, playIcon, playIcon))];
    x += playIcon + controlGap;
    [screen.layer addSublayer:TSUgControlIcon(2, CGRectMake(x, centerY - sideIcon / 2.f, sideIcon, sideIcon))];
}

/** 状态页（情绪窗）：笑脸 + 时间 */
- (void)ts_buildStatusIn:(UIView *)screen u:(CGFloat)u {
    CGFloat w = screen.bounds.size.width, h = screen.bounds.size.height;
    CAGradientLayer *bg = [CAGradientLayer layer];
    bg.type = kCAGradientLayerRadial;
    bg.frame = screen.bounds;
    bg.colors = @[(__bridge id)TSUgRGB(0x0F3B2A).CGColor, (__bridge id)[UIColor blackColor].CGColor];
    bg.locations = @[@0, @0.8];
    bg.startPoint = CGPointMake(0.5f, 0.48f);
    bg.endPoint = CGPointMake(0.5f + 0.6f, 0.48f + 0.45f);
    [screen.layer insertSublayer:bg atIndex:0];

    CGFloat faceW = 170.f * u, faceH = faceW * 56.f / 120.f, timeH = 24.f * u * 1.25f, gap = 10.f * u;
    CGFloat y = (h - faceH - gap - timeH) / 2.f;
    CGFloat f = faceW / 120.f;
    UIColor *green = TSUgRGB(0x7DF0BD);
    CGRect faceFrame = CGRectMake((w - faceW) / 2.f, y, faceW, faceH);

    UIBezierPath *eyes = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(35.f * f, 11.f * f, 14.f * f, 18.f * f)];
    [eyes appendPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(71.f * f, 11.f * f, 14.f * f, 18.f * f)]];
    CAShapeLayer *eyesLayer = [CAShapeLayer layer];
    eyesLayer.frame = faceFrame;
    eyesLayer.path = eyes.CGPath;
    eyesLayer.fillColor = green.CGColor;
    [screen.layer addSublayer:eyesLayer];

    UIBezierPath *smile = [UIBezierPath bezierPath];
    [smile moveToPoint:CGPointMake(44.f * f, 38.f * f)];
    [smile addQuadCurveToPoint:CGPointMake(76.f * f, 38.f * f) controlPoint:CGPointMake(60.f * f, 50.f * f)];
    CAShapeLayer *smileLayer = [CAShapeLayer layer];
    smileLayer.frame = faceFrame;
    smileLayer.path = smile.CGPath;
    smileLayer.fillColor = [UIColor clearColor].CGColor;
    smileLayer.strokeColor = green.CGColor;
    smileLayer.lineWidth = 5.f * f;
    smileLayer.lineCap = kCALineCapRound;
    [screen.layer addSublayer:smileLayer];

    UILabel *time = TSUgLabel([TSHsdDisplay roundedFontOfSize:24.f * u weight:UIFontWeightBold], [[UIColor whiteColor] colorWithAlphaComponent:0.65f]);
    time.text = @"16:42";
    time.textAlignment = NSTextAlignmentCenter;
    time.frame = CGRectMake(0, y + faceH + gap, w, timeH);
    [screen addSubview:time];
}

/** 角标：圆屏顶部居中，其余右上角 */
- (void)ts_addBadgeIn:(UIView *)screen u:(CGFloat)u circle:(BOOL)circle {
    CGFloat w = screen.bounds.size.width, h = screen.bounds.size.height;
    UILabel *badge = TSUgLabel([UIFont systemFontOfSize:17.f * u weight:UIFontWeightBold],
                               self.badgeOn ? TSUgRGB(0x8FF0B8) : [[UIColor whiteColor] colorWithAlphaComponent:0.65f]);
    badge.text = self.badgeText;
    badge.textAlignment = NSTextAlignmentCenter;
    badge.backgroundColor = self.badgeOn ? [[TSUgreenDisplay glowGreen] colorWithAlphaComponent:0.22f] : [[UIColor whiteColor] colorWithAlphaComponent:0.12f];
    CGFloat textW = ceil([badge.text sizeWithAttributes:@{NSFontAttributeName: badge.font}].width);
    CGFloat badgeW = textW + 26.f * u, badgeH = 17.f * u * 1.25f + 8.f * u;
    badge.layer.cornerRadius = badgeH / 2.f;
    badge.clipsToBounds = YES;
    if (circle) {
        badge.frame = CGRectMake((w - badgeW) / 2.f, h * 0.13f, badgeW, badgeH);
    } else {
        badge.frame = CGRectMake(w - 22.f * u - badgeW, 20.f * u, badgeW, badgeH);
    }
    [screen addSubview:badge];
}

/** 三击提示浮层 */
- (void)ts_addOverlayIn:(UIView *)screen u:(CGFloat)u {
    TSUgreenTriplePressFunction function = self.overlayFunction.integerValue;
    UIView *overlay = [[UIView alloc] initWithFrame:screen.bounds];
    overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.92f];
    CGFloat iconSide = 56.f * u, gap = 14.f * u, labelH = 23.f * u * 1.25f;
    CGFloat y = (screen.bounds.size.height - iconSide - gap - labelH) / 2.f;
    UIImageView *icon = [[UIImageView alloc] initWithImage:TSHsdSymbol([TSUgreenDisplay tripleSymbol:function], 44.f * u, UIImageSymbolWeightSemibold)];
    icon.tintColor = TSUgRGB(0x8FF0B8);
    icon.contentMode = UIViewContentModeCenter;
    icon.frame = CGRectMake((screen.bounds.size.width - iconSide) / 2.f, y, iconSide, iconSide);
    [overlay addSubview:icon];
    UILabel *label = TSUgLabel([UIFont systemFontOfSize:23.f * u weight:UIFontWeightBold], [UIColor whiteColor]);
    label.text = [NSString stringWithFormat:TSLocalizedString(@"ugreen.preview.triple_format"), [TSUgreenDisplay tripleName:function]];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, y + iconSide + gap, screen.bounds.size.width, labelH);
    [overlay addSubview:label];
    [screen addSubview:overlay];
}

@end

#pragma mark - TSUgreenPreviewCard

static const CGFloat kTSUgPreviewPad = 14.f;
static const CGFloat kTSUgPreviewHeaderH = 20.f;
static const CGFloat kTSUgPreviewStageH = 218.f;
static const CGFloat kTSUgPreviewSpecH = 14.f;
static const CGFloat kTSUgPreviewTabsH = 34.f;

@interface TSUgreenPreviewCard ()
// 裁圆角的底（渐变与光晕）
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) CAGradientLayer *background;
@property (nonatomic, strong) CAGradientLayer *greenGlow;
@property (nonatomic, strong) CAGradientLayer *skyGlow;
// 标题与右上角标签
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tagLabel;
// 舞台：地面阴影 + 设备
@property (nonatomic, strong) UIView *stage;
@property (nonatomic, strong) CAGradientLayer *ground;
@property (nonatomic, strong) TSUgreenDeviceView *deviceView;
// 规格文字、四个视图、说明
@property (nonatomic, strong) UILabel *specLabel;
@property (nonatomic, strong) UIView *tabsView;
@property (nonatomic, strong) NSArray<UIButton *> *tabButtons;
@property (nonatomic, strong) NSArray<UIView *> *tabDots;
@property (nonatomic, strong) UILabel *captionLabel;
@end

@implementation TSUgreenPreviewCard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _spec = [TSUgreenScreenSpec specWithScreen:nil];
    _model = [[TSUgreenConfigModel alloc] init];

    self.layer.shadowColor = TSUgRGB(0x141726).CGColor;
    self.layer.shadowOpacity = 0.25f;
    self.layer.shadowRadius = 20.f;
    self.layer.shadowOffset = CGSizeMake(0, 18.f);

    _container = [[UIView alloc] init];
    _container.layer.cornerRadius = 26.f;
    _container.clipsToBounds = YES;
    [self addSubview:_container];

    _background = [CAGradientLayer layer];
    [TSUgreenDisplay applyCSSAngle:160.f toGradient:_background];
    [_container.layer addSublayer:_background];
    _greenGlow = [CAGradientLayer layer];
    _greenGlow.type = kCAGradientLayerRadial;
    _greenGlow.locations = @[@0, @0.7];
    [_container.layer addSublayer:_greenGlow];
    _skyGlow = [CAGradientLayer layer];
    _skyGlow.type = kCAGradientLayerRadial;
    _skyGlow.locations = @[@0, @0.7];
    [_container.layer addSublayer:_skyGlow];

    _titleLabel = TSUgLabel([UIFont systemFontOfSize:13.f weight:UIFontWeightSemibold], [UIColor whiteColor]);
    _titleLabel.text = TSLocalizedString(@"ugreen.preview.title");
    [_container addSubview:_titleLabel];

    _tagLabel = TSUgLabel([UIFont systemFontOfSize:11.f weight:UIFontWeightSemibold], [TSUgreenDisplay heroInk2]);
    _tagLabel.textAlignment = NSTextAlignmentCenter;
    _tagLabel.clipsToBounds = YES;
    [_container addSubview:_tagLabel];

    _stage = [[UIView alloc] init];
    [_container addSubview:_stage];
    _ground = [CAGradientLayer layer];
    _ground.type = kCAGradientLayerRadial;
    _ground.colors = @[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.67f].CGColor, (__bridge id)[UIColor clearColor].CGColor];
    _ground.startPoint = CGPointMake(0.5f, 0.5f);
    _ground.endPoint = CGPointMake(1.f, 1.f);
    [_stage.layer addSublayer:_ground];
    _deviceView = [[TSUgreenDeviceView alloc] init];
    [_stage addSubview:_deviceView];

    _specLabel = TSUgLabel([TSHsdDisplay monoFontOfSize:10.5f], [TSUgreenDisplay heroInk2]);
    _specLabel.textAlignment = NSTextAlignmentCenter;
    _specLabel.adjustsFontSizeToFitWidth = YES;
    _specLabel.minimumScaleFactor = 0.8f;
    [_container addSubview:_specLabel];

    _tabsView = [[UIView alloc] init];
    _tabsView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.07f];
    _tabsView.layer.cornerRadius = 12.f;
    [_container addSubview:_tabsView];
    NSArray<NSString *> *titles = @[TSLocalizedString(@"ugreen.preview.tab.lyrics"), TSLocalizedString(@"ugreen.preview.tab.music"),
                                    TSLocalizedString(@"ugreen.preview.tab.status"), TSLocalizedString(@"ugreen.preview.tab.stand")];
    NSMutableArray<UIButton *> *buttons = [NSMutableArray array];
    NSMutableArray<UIView *> *dots = [NSMutableArray array];
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = (NSInteger)idx;
        button.titleLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightSemibold];
        button.layer.cornerRadius = 9.f;
        [button setTitle:title forState:UIControlStateNormal];
        [button addTarget:self action:@selector(ts_tabTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabsView addSubview:button];
        [buttons addObject:button];
        UIView *dot = [[UIView alloc] init];
        dot.backgroundColor = [TSUgreenDisplay glowGreen];
        dot.layer.cornerRadius = 2.5f;
        dot.userInteractionEnabled = NO;
        [button addSubview:dot];
        [dots addObject:dot];
    }];
    _tabButtons = buttons;
    _tabDots = dots;

    _captionLabel = TSUgLabel([UIFont systemFontOfSize:12.f], [TSUgreenDisplay heroInk2]);
    _captionLabel.numberOfLines = 0;
    _captionLabel.textAlignment = NSTextAlignmentCenter;
    [_container addSubview:_captionLabel];
    return self;
}

#pragma mark - 公开方法

/** 按当前属性刷新 */
- (void)reload {
    TSUgreenConfigModel *m = self.model;
    BOOL music = (m.alwaysOnPages & TSUgreenAlwaysOnPageMusicControl) != 0;
    BOOL status = (m.alwaysOnPages & TSUgreenAlwaysOnPageStatus) != 0;

    self.tagLabel.text = self.dirty ? TSLocalizedString(@"ugreen.preview.tag.dirty") : TSLocalizedString(@"ugreen.preview.tag.synced");
    self.tagLabel.textColor = self.dirty ? TSUgRGB(0xA6F3C8) : [TSUgreenDisplay heroInk2];
    self.tagLabel.backgroundColor = self.dirty ? [[TSUgreenDisplay glowGreen] colorWithAlphaComponent:0.19f] : [[UIColor whiteColor] colorWithAlphaComponent:0.08f];

    TSUgreenDeviceView *device = self.deviceView;
    device.spec = self.spec;
    device.theme = m.lyricsTheme;
    device.lyricsColor = m.lyricsColor ?: [UIColor whiteColor];
    device.overlayFunction = self.tripleOverlay;
    device.showsLeg = (self.page == TSUgreenPreviewPageStand);
    NSString *caption = nil;
    switch (self.page) {
        case TSUgreenPreviewPageLyrics:
            device.content = TSUgreenScreenContentLyrics;
            device.badgeText = nil;
            break;
        case TSUgreenPreviewPageMusic:
            device.content = TSUgreenScreenContentMusic;
            device.badgeText = music ? TSLocalizedString(@"ugreen.preview.badge.on") : TSLocalizedString(@"ugreen.preview.badge.auto_off");
            device.badgeOn = music;
            caption = music ? TSLocalizedString(@"ugreen.preview.caption.music_on") : TSLocalizedString(@"ugreen.preview.caption.music_off");
            break;
        case TSUgreenPreviewPageStatus:
            device.content = TSUgreenScreenContentStatus;
            device.badgeText = status ? TSLocalizedString(@"ugreen.preview.badge.on") : TSLocalizedString(@"ugreen.preview.badge.auto_off");
            device.badgeOn = status;
            caption = status ? TSLocalizedString(@"ugreen.preview.caption.status_on") : TSLocalizedString(@"ugreen.preview.caption.status_off");
            break;
        case TSUgreenPreviewPageStand:
            device.content = m.isDesktopModeEnabled ? TSUgreenScreenContentStatus : TSUgreenScreenContentMusic;
            device.badgeText = m.isDesktopModeEnabled ? TSLocalizedString(@"ugreen.preview.badge.desk_on") : TSLocalizedString(@"ugreen.preview.badge.wake_only");
            device.badgeOn = m.isDesktopModeEnabled;
            caption = m.isDesktopModeEnabled ? TSLocalizedString(@"ugreen.preview.caption.stand_on") : TSLocalizedString(@"ugreen.preview.caption.stand_off");
            break;
    }
    [device reload];
    BOOL standing = (self.page == TSUgreenPreviewPageStand);
    CGAffineTransform tilt = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-8.f * M_PI / 180.f), 0, -12.f);
    device.transform = standing ? tilt : CGAffineTransformIdentity;
    self.ground.opacity = standing ? 1.f : 0.45f;

    self.specLabel.text = [self.spec specText];
    self.captionLabel.attributedText = caption ? TSUgParagraph(caption, self.captionLabel.font, [TSUgreenDisplay heroInk2], 1.2f, NSTextAlignmentCenter)
                                               : [self ts_lyricsCaption];
    NSArray<NSNumber *> *dotOn = @[@NO, @(music), @(status), @(m.isDesktopModeEnabled)];
    [self.tabButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        BOOL selected = ((NSInteger)idx == self.page);
        button.backgroundColor = selected ? [[UIColor whiteColor] colorWithAlphaComponent:0.14f] : [UIColor clearColor];
        [button setTitleColor:selected ? [UIColor whiteColor] : [TSUgreenDisplay heroInk2] forState:UIControlStateNormal];
        button.accessibilityTraits = selected ? (UIAccessibilityTraitButton | UIAccessibilityTraitSelected) : UIAccessibilityTraitButton;
        self.tabDots[idx].hidden = ![dotOn[idx] boolValue];
    }];
    [self setNeedsLayout];
}

#pragma mark - 私有方法

/** 歌词视图的说明：自定义主题带等宽颜色值 */
- (NSAttributedString *)ts_lyricsCaption {
    TSUgreenConfigModel *m = self.model;
    UIFont *font = self.captionLabel.font;
    UIColor *color = [TSUgreenDisplay heroInk2];
    if (m.lyricsTheme != TSUgreenLyricsThemeCustom) {
        NSString *text = [NSString stringWithFormat:TSLocalizedString(@"ugreen.preview.caption.lyrics_preset_format"), [TSUgreenDisplay themeName:m.lyricsTheme]];
        return TSUgParagraph(text, font, color, 1.2f, NSTextAlignmentCenter);
    }
    NSMutableAttributedString *text = [TSUgParagraph(TSLocalizedString(@"ugreen.preview.caption.lyrics_custom"), font, color, 1.2f, NSTextAlignmentCenter) mutableCopy];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [text appendAttributedString:TSUgParagraph([TSUgreenDisplay hexRGBAOfColor:m.lyricsColor], [TSHsdDisplay monoFontOfSize:12.f], color, 1.2f, NSTextAlignmentCenter)];
    return text;
}

/** 点视图标签 */
- (void)ts_tabTapped:(UIButton *)sender {
    if (self.onSelectPage) { self.onSelectPage((TSUgreenPreviewPage)sender.tag); }
}

/** 说明文字高度 */
- (CGFloat)ts_captionHeightForWidth:(CGFloat)width {
    CGRect rect = [self.captionLabel.attributedText boundingRectWithSize:CGSizeMake(width - 40.f, CGFLOAT_MAX)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return MAX(18.f, ceil(rect.size.height));
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = kTSUgPreviewPad + kTSUgPreviewHeaderH + kTSUgPreviewStageH + 2.f + kTSUgPreviewSpecH + 10.f
              + kTSUgPreviewTabsH + 10.f + [self ts_captionHeightForWidth:size.width] + 2.f + kTSUgPreviewPad;
    return CGSizeMake(size.width, h);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    self.container.frame = self.bounds;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 12.f, 12.f) cornerRadius:26.f].CGPath;

    // 底色与光晕（CGColor 需按当前深浅色解析）
    UITraitCollection *traits = self.traitCollection;
    self.background.frame = self.bounds;
    self.background.colors = @[(__bridge id)[[TSUgreenDisplay heroColor2] resolvedColorWithTraitCollection:traits].CGColor,
                               (__bridge id)[[TSUgreenDisplay heroColor] resolvedColorWithTraitCollection:traits].CGColor];
    UIColor *green = [[TSUgreenDisplay hue] resolvedColorWithTraitCollection:traits];
    UIColor *sky = [TSUgSky() resolvedColorWithTraitCollection:traits];
    self.greenGlow.frame = self.bounds;
    self.greenGlow.colors = @[(__bridge id)[green colorWithAlphaComponent:0.4f].CGColor, (__bridge id)[green colorWithAlphaComponent:0].CGColor];
    self.greenGlow.startPoint = CGPointMake(0.92f, -0.12f);
    self.greenGlow.endPoint = CGPointMake(0.92f + 240.f / MAX(w, 1), -0.12f + 170.f / MAX(h, 1));
    self.skyGlow.frame = self.bounds;
    self.skyGlow.colors = @[(__bridge id)[sky colorWithAlphaComponent:0.24f].CGColor, (__bridge id)[sky colorWithAlphaComponent:0].CGColor];
    self.skyGlow.startPoint = CGPointMake(0, 1.15f);
    self.skyGlow.endPoint = CGPointMake(220.f / MAX(w, 1), 1.15f + 160.f / MAX(h, 1));

    CGFloat y = kTSUgPreviewPad;
    CGFloat tagW = ceil([self.tagLabel.text sizeWithAttributes:@{NSFontAttributeName: self.tagLabel.font}].width) + 18.f;
    self.tagLabel.frame = CGRectMake(w - kTSUgPreviewPad - 4.f - tagW, y + 1.f, tagW, 19.f);
    self.tagLabel.layer.cornerRadius = 9.5f;
    self.titleLabel.frame = CGRectMake(kTSUgPreviewPad + 4.f, y + 2.f, CGRectGetMinX(self.tagLabel.frame) - kTSUgPreviewPad - 12.f, 16.f);
    y += kTSUgPreviewHeaderH;

    self.stage.frame = CGRectMake(kTSUgPreviewPad, y, w - kTSUgPreviewPad * 2, kTSUgPreviewStageH);
    CGFloat stageW = self.stage.bounds.size.width;
    self.ground.frame = CGRectMake(stageW / 2.f - 95.f, kTSUgPreviewStageH - 6.f - 12.f, 190.f, 12.f);
    CGSize device = [self.deviceView deviceSize];
    self.deviceView.bounds = CGRectMake(0, 0, device.width, device.height);
    self.deviceView.center = CGPointMake(stageW / 2.f, kTSUgPreviewStageH / 2.f);
    y += kTSUgPreviewStageH + 2.f;

    self.specLabel.frame = CGRectMake(kTSUgPreviewPad, y, w - kTSUgPreviewPad * 2, kTSUgPreviewSpecH);
    y += kTSUgPreviewSpecH + 10.f;

    self.tabsView.frame = CGRectMake(kTSUgPreviewPad, y, w - kTSUgPreviewPad * 2, kTSUgPreviewTabsH);
    CGFloat buttonW = (self.tabsView.bounds.size.width - 6.f - 9.f) / 4.f;
    [self.tabButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.frame = CGRectMake(3.f + idx * (buttonW + 3.f), 3.f, buttonW, kTSUgPreviewTabsH - 6.f);
        self.tabDots[idx].frame = CGRectMake(buttonW / 2.f + 16.f, 5.f, 5.f, 5.f);
    }];
    y += kTSUgPreviewTabsH + 10.f;

    self.captionLabel.frame = CGRectMake(20.f, y, w - 40.f, [self ts_captionHeightForWidth:w]);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setNeedsLayout];
}

@end

#pragma mark - 小号药丸（.pill，10.5 号）

@interface TSUgreenPillLabel : UILabel
@end

@implementation TSUgreenPillLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.font = [UIFont systemFontOfSize:10.5f weight:UIFontWeightSemibold];
    self.textAlignment = NSTextAlignmentCenter;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 8.5f;
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(ceil([self.text sizeWithAttributes:@{NSFontAttributeName: self.font}].width) + 16.f, 17.f);
}

@end

#pragma mark - 三击功能卡（.choice）

@interface TSUgreenChoiceTile : UIControl
@property (nonatomic, strong) TSHsdIconBlock *iconBlock;
@property (nonatomic, strong) UIView *radio;
@property (nonatomic, strong) UIImageView *radioCheck;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) TSUgreenPillLabel *defaultPill;
@property (nonatomic, strong) TSUgreenPillLabel *devicePill;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) BOOL showsDevicePill;
@property (nonatomic, strong) UIColor *hue;
/// 刷新选中态与颜色
- (void)ts_apply;
/// 给定宽度下的高度
- (CGFloat)heightForWidth:(CGFloat)width;
@end

@implementation TSUgreenChoiceTile

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.backgroundColor = [TSHsdDisplay card];
    self.layer.cornerRadius = 20.f;
    TSUgApplyCardShadow(self);

    _iconBlock = [[TSHsdIconBlock alloc] init];
    _iconBlock.userInteractionEnabled = NO;
    [self addSubview:_iconBlock];

    _radio = [[UIView alloc] init];
    _radio.layer.cornerRadius = 11.f;
    _radio.layer.borderWidth = 2.f;
    _radio.userInteractionEnabled = NO;
    [self addSubview:_radio];
    _radioCheck = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"checkmark", 10.f, UIImageSymbolWeightHeavy)];
    _radioCheck.contentMode = UIViewContentModeCenter;
    [_radio addSubview:_radioCheck];

    _nameLabel = TSUgLabel([UIFont systemFontOfSize:15.5f weight:UIFontWeightBold], [TSHsdDisplay ink]);
    [self addSubview:_nameLabel];
    _descLabel = TSUgLabel([UIFont systemFontOfSize:12.f], [TSHsdDisplay textSecondary]);
    _descLabel.numberOfLines = 0;
    [self addSubview:_descLabel];
    _valueLabel = TSUgLabel([TSHsdDisplay monoFontOfSize:10.5f], [TSHsdDisplay textTertiary]);
    [self addSubview:_valueLabel];

    _defaultPill = [[TSUgreenPillLabel alloc] init];
    _defaultPill.text = TSLocalizedString(@"ugreen.triple.default");
    _defaultPill.backgroundColor = [TSHsdDisplay fill];
    _defaultPill.textColor = [TSHsdDisplay textSecondary];
    [self addSubview:_defaultPill];
    _devicePill = [[TSUgreenPillLabel alloc] init];
    _devicePill.text = TSLocalizedString(@"ugreen.on_device");
    [self addSubview:_devicePill];
    return self;
}

/** 刷新选中态与颜色 */
- (void)ts_apply {
    self.iconBlock.tint = self.hue;
    self.layer.borderWidth = self.on ? 2.f : 0;
    self.layer.borderColor = [self.hue resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    self.radio.backgroundColor = self.on ? self.hue : [UIColor clearColor];
    self.radio.layer.borderColor = [(self.on ? self.hue : TSUgFill2()) resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    self.radioCheck.hidden = !self.on;
    self.radioCheck.tintColor = [TSHsdDisplay card];
    self.devicePill.hidden = !self.showsDevicePill;
    self.devicePill.textColor = self.hue;
    self.devicePill.backgroundColor = [TSHsdDisplay tint12:self.hue];
    self.accessibilityTraits = self.on ? (UIAccessibilityTraitButton | UIAccessibilityTraitSelected) : UIAccessibilityTraitButton;
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [UIView animateWithDuration:0.12 animations:^{
        self.transform = highlighted ? CGAffineTransformMakeScale(0.97f, 0.97f) : CGAffineTransformIdentity;
    }];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self ts_apply];
}

/** 给定宽度下的高度 */
- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat textW = width - 28.f;
    CGFloat nameH = ceil(self.nameLabel.font.lineHeight);
    CGFloat descH = TSUgTextHeight(self.descLabel.text, self.descLabel.font, textW, 1.15f);
    return 14.f + 40.f + 12.f + nameH + 3.f + descH + 10.f + 17.f + 14.f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, textW = w - 28.f;
    self.iconBlock.frame = CGRectMake(14.f, 14.f, 40.f, 40.f);
    self.radio.frame = CGRectMake(w - 14.f - 22.f, 14.f, 22.f, 22.f);
    self.radioCheck.frame = self.radio.bounds;
    CGFloat y = 14.f + 40.f + 12.f;
    CGFloat nameH = ceil(self.nameLabel.font.lineHeight);
    self.nameLabel.frame = CGRectMake(14.f, y, textW, nameH);
    y += nameH + 3.f;
    CGFloat descH = TSUgTextHeight(self.descLabel.text, self.descLabel.font, textW, 1.15f);
    self.descLabel.frame = CGRectMake(14.f, y, textW, descH);
    y += descH + 10.f;
    CGFloat x = 14.f;
    CGFloat valueW = ceil([self.valueLabel.text sizeWithAttributes:@{NSFontAttributeName: self.valueLabel.font}].width);
    self.valueLabel.frame = CGRectMake(x, y, valueW, 17.f);
    x += valueW + 6.f;
    for (TSUgreenPillLabel *pill in @[self.defaultPill, self.devicePill]) {
        if (pill.hidden) { continue; }
        CGSize ps = [pill sizeThatFits:CGSizeZero];
        pill.frame = CGRectMake(x, y, ps.width, ps.height);
        x += ps.width + 6.f;
    }
}

@end

#pragma mark - TSUgreenTripleChoiceView

@interface TSUgreenTripleChoiceView ()
// 两张功能卡
@property (nonatomic, strong) NSArray<TSUgreenChoiceTile *> *tiles;
@end

@implementation TSUgreenTripleChoiceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSUgreenDisplay hue];
    NSMutableArray<TSUgreenChoiceTile *> *tiles = [NSMutableArray array];
    for (NSNumber *function in [TSUgreenDisplay allTripleFunctions]) {
        TSUgreenChoiceTile *tile = [[TSUgreenChoiceTile alloc] init];
        tile.tag = function.integerValue;
        [tile addTarget:self action:@selector(ts_tileTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tile];
        [tiles addObject:tile];
    }
    _tiles = tiles;
    return self;
}

/** 按当前属性刷新 */
- (void)reload {
    BOOL modified = (self.selected != self.deviceValue);
    for (TSUgreenChoiceTile *tile in self.tiles) {
        TSUgreenTriplePressFunction function = tile.tag;
        tile.hue = self.hue;
        tile.on = (function == self.selected);
        tile.showsDevicePill = modified && function == self.deviceValue;
        tile.iconBlock.symbol = [TSUgreenDisplay tripleSymbol:function];
        tile.nameLabel.text = [TSUgreenDisplay tripleName:function];
        tile.descLabel.text = [TSUgreenDisplay tripleDescription:function];
        tile.valueLabel.text = [NSString stringWithFormat:@"= %ld", (long)function];
        tile.defaultPill.hidden = (function != TSUgreenTriplePressFunctionOnSiteRecording);
        tile.accessibilityLabel = tile.nameLabel.text;
        [tile ts_apply];
    }
    [self setNeedsLayout];
}

- (void)ts_tileTapped:(TSUgreenChoiceTile *)tile {
    if (self.onSelect) { self.onSelect((TSUgreenTriplePressFunction)tile.tag); }
}

- (CGFloat)ts_tileWidth:(CGFloat)width { return (width - 10.f) / 2.f; }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat tileW = [self ts_tileWidth:size.width], h = 0;
    for (TSUgreenChoiceTile *tile in self.tiles) { h = MAX(h, [tile heightForWidth:tileW]); }
    return CGSizeMake(size.width, h);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat tileW = [self ts_tileWidth:self.bounds.size.width], h = self.bounds.size.height;
    [self.tiles enumerateObjectsUsingBlock:^(TSUgreenChoiceTile *tile, NSUInteger idx, BOOL *stop) {
        tile.transform = CGAffineTransformIdentity;
        tile.frame = CGRectMake(idx * (tileW + 10.f), 0, tileW, h);
        tile.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:tile.bounds cornerRadius:20.f].CGPath;
    }];
}

@end

#pragma mark - 主题色块（.th）

@interface TSUgreenThemeSwatch : UIControl
@property (nonatomic, assign) TSUgreenLyricsTheme theme;
@property (nonatomic, strong) UIColor *customColor;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, assign) BOOL showsDeviceMark;
@property (nonatomic, strong) UIView *ring;
@property (nonatomic, strong) UIView *fillView;
@property (nonatomic, strong) UILabel *sampleLabel;
@property (nonatomic, strong) UIView *checkBadge;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *deviceLabel;
/// 刷新外观
- (void)ts_apply;
@end

@implementation TSUgreenThemeSwatch

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _ring = [[UIView alloc] init];
    _ring.layer.borderWidth = 2.f;
    _ring.layer.cornerRadius = 20.f;
    _ring.userInteractionEnabled = NO;
    [self addSubview:_ring];

    _fillView = [[UIView alloc] init];
    _fillView.layer.cornerRadius = 16.f;
    _fillView.layer.borderWidth = 1.f;
    _fillView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1f].CGColor;
    _fillView.clipsToBounds = YES;
    _fillView.userInteractionEnabled = NO;
    [self addSubview:_fillView];

    _sampleLabel = TSUgLabel([UIFont systemFontOfSize:15.f weight:UIFontWeightHeavy], [UIColor whiteColor]);
    _sampleLabel.text = @"Aa";
    _sampleLabel.textAlignment = NSTextAlignmentCenter;
    [_fillView addSubview:_sampleLabel];

    _checkBadge = [[UIView alloc] init];
    _checkBadge.layer.cornerRadius = 9.5f;
    _checkBadge.layer.borderWidth = 2.f;
    _checkBadge.userInteractionEnabled = NO;
    UIImageView *check = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"checkmark", 8.f, UIImageSymbolWeightHeavy)];
    check.tintColor = [UIColor whiteColor];
    check.contentMode = UIViewContentModeCenter;
    check.frame = CGRectMake(0, 0, 19.f, 19.f);
    check.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_checkBadge addSubview:check];
    [self addSubview:_checkBadge];

    _nameLabel = TSUgLabel([UIFont systemFontOfSize:12.f weight:UIFontWeightSemibold], [TSHsdDisplay textSecondary]);
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_nameLabel];
    _deviceLabel = TSUgLabel([UIFont systemFontOfSize:9.5f weight:UIFontWeightBold], [TSUgreenDisplay hue]);
    _deviceLabel.textAlignment = NSTextAlignmentCenter;
    _deviceLabel.text = TSLocalizedString(@"ugreen.on_device");
    [self addSubview:_deviceLabel];
    return self;
}

/** 刷新外观 */
- (void)ts_apply {
    UITraitCollection *traits = self.traitCollection;
    self.ring.hidden = !self.on;
    self.ring.layer.borderColor = [self.hue resolvedColorWithTraitCollection:traits].CGColor;
    self.checkBadge.hidden = !self.on;
    self.checkBadge.backgroundColor = self.hue;
    self.checkBadge.layer.borderColor = [[TSHsdDisplay card] resolvedColorWithTraitCollection:traits].CGColor;
    self.sampleLabel.textColor = [TSUgreenDisplay themeAccent:self.theme customColor:self.customColor];
    self.nameLabel.text = [TSUgreenDisplay themeName:self.theme];
    self.nameLabel.textColor = self.on ? [TSHsdDisplay ink] : [TSHsdDisplay textSecondary];
    self.deviceLabel.textColor = self.hue;
    self.deviceLabel.hidden = !self.showsDeviceMark;
    self.accessibilityLabel = self.nameLabel.text;
    self.accessibilityTraits = self.on ? (UIAccessibilityTraitButton | UIAccessibilityTraitSelected) : UIAccessibilityTraitButton;
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [UIView animateWithDuration:0.12 animations:^{
        self.fillView.transform = highlighted ? CGAffineTransformMakeScale(0.94f, 0.94f) : CGAffineTransformIdentity;
    }];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self ts_apply];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat side = self.bounds.size.width;
    self.fillView.transform = CGAffineTransformIdentity;
    self.fillView.frame = CGRectMake(0, 0, side, side);
    // 主题底色依赖尺寸，布局时重建
    for (CALayer *layer in [self.fillView.layer.sublayers copy]) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) { [layer removeFromSuperlayer]; }
    }
    [TSUgreenDisplay applyTheme:self.theme toLayer:self.fillView.layer starScale:1.f];
    self.sampleLabel.frame = self.fillView.bounds;
    self.ring.frame = CGRectInset(self.fillView.frame, -4.f, -4.f);
    self.checkBadge.frame = CGRectMake(side - 19.f + 5.f, side - 19.f + 5.f, 19.f, 19.f);
    self.nameLabel.frame = CGRectMake(-4.f, side + 6.f, side + 8.f, 15.f);
    self.deviceLabel.frame = CGRectMake(-4.f, side + 6.f + 15.f + 2.f, side + 8.f, 12.f);
}

@end

#pragma mark - 色板圆点（.pal button）

@interface TSUgreenPaletteDot : UIControl
@property (nonatomic, copy, nullable) NSString *hex;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, strong) UIView *ring;
@property (nonatomic, strong) UIView *dot;
@property (nonatomic, strong, nullable) CAGradientLayer *conic;
@property (nonatomic, strong, nullable) UIImageView *plus;
/// 设为「更多颜色」按钮
- (void)makeMoreButton;
/// 刷新外观
- (void)ts_apply;
@end

@implementation TSUgreenPaletteDot

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _ring = [[UIView alloc] init];
    _ring.layer.borderWidth = 2.f;
    _ring.layer.cornerRadius = 18.f;
    _ring.userInteractionEnabled = NO;
    [self addSubview:_ring];
    _dot = [[UIView alloc] init];
    _dot.layer.cornerRadius = 14.f;
    _dot.layer.borderWidth = 1.f;
    _dot.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.14f].CGColor;
    _dot.clipsToBounds = YES;
    _dot.userInteractionEnabled = NO;
    [self addSubview:_dot];
    return self;
}

/** 设为「更多颜色」：彩虹锥形渐变 + 加号 */
- (void)makeMoreButton {
    NSArray<NSNumber *> *hexes = @[@0xFF5A5A, @0xFFD84A, @0x5AFF8C, @0x4AD8FF, @0x7A5AFF, @0xFF5AD8, @0xFF5A5A];
    NSMutableArray *colors = [NSMutableArray array];
    for (NSNumber *hex in hexes) { [colors addObject:(__bridge id)TSUgRGB(hex.integerValue).CGColor]; }
    self.conic = [CAGradientLayer layer];
    self.conic.type = kCAGradientLayerConic;
    self.conic.colors = colors;
    self.conic.startPoint = CGPointMake(0.5f, 0.5f);
    self.conic.endPoint = CGPointMake(0.5f, 0.f);
    [self.dot.layer addSublayer:self.conic];
    self.plus = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"plus", 12.f, UIImageSymbolWeightHeavy)];
    self.plus.tintColor = [UIColor whiteColor];
    self.plus.contentMode = UIViewContentModeCenter;
    self.plus.layer.shadowColor = [UIColor blackColor].CGColor;
    self.plus.layer.shadowOpacity = 0.5f;
    self.plus.layer.shadowRadius = 2.f;
    self.plus.layer.shadowOffset = CGSizeZero;
    [self.dot addSubview:self.plus];
    self.accessibilityLabel = TSLocalizedString(@"ugreen.color.more");
}

- (void)ts_apply {
    self.ring.hidden = !self.on;
    self.ring.layer.borderColor = [[TSHsdDisplay ink] resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    if (self.hex) {
        self.dot.backgroundColor = [TSUgreenDisplay colorFromHex:self.hex];
        self.accessibilityLabel = self.hex;
    }
    self.accessibilityTraits = self.on ? (UIAccessibilityTraitButton | UIAccessibilityTraitSelected) : UIAccessibilityTraitButton;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [UIView animateWithDuration:0.12 animations:^{
        self.dot.transform = highlighted ? CGAffineTransformMakeScale(0.9f, 0.9f) : CGAffineTransformIdentity;
    }];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self ts_apply];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat side = self.bounds.size.width;
    self.dot.transform = CGAffineTransformIdentity;
    self.dot.frame = CGRectMake(0, 0, side, side);
    self.dot.layer.cornerRadius = side / 2.f;
    self.conic.frame = self.dot.bounds;
    self.plus.frame = self.dot.bounds;
    self.ring.frame = CGRectInset(self.dot.frame, -4.f, -4.f);
    self.ring.layer.cornerRadius = side / 2.f + 4.f;
}

@end

#pragma mark - TSUgreenLyricsPanel

static const CGFloat kTSUgPaletteDot = 28.f;

@interface TSUgreenLyricsPanel ()
// 五个主题
@property (nonatomic, strong) NSArray<TSUgreenThemeSwatch *> *swatches;
// 颜色行
@property (nonatomic, strong) UIControl *colorRow;
@property (nonatomic, strong) UIView *colorSwatch;
@property (nonatomic, strong) UILabel *colorTitleLabel;
@property (nonatomic, strong) UILabel *colorSubtitleLabel;
@property (nonatomic, strong) UILabel *colorValueLabel;
@property (nonatomic, strong) UIImageView *chevron;
// 色板（8 色 + 更多）
@property (nonatomic, strong) NSArray<TSUgreenPaletteDot *> *paletteDots;
@end

@implementation TSUgreenLyricsPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSUgreenDisplay hue];
    _color = [UIColor whiteColor];
    _deviceColor = [UIColor whiteColor];

    NSMutableArray<TSUgreenThemeSwatch *> *swatches = [NSMutableArray array];
    for (NSNumber *theme in [TSUgreenDisplay allThemes]) {
        TSUgreenThemeSwatch *swatch = [[TSUgreenThemeSwatch alloc] init];
        swatch.theme = theme.integerValue;
        swatch.tag = theme.integerValue;
        [swatch addTarget:self action:@selector(ts_themeTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:swatch];
        [swatches addObject:swatch];
    }
    _swatches = swatches;

    _colorRow = [[UIControl alloc] init];
    [_colorRow addTarget:self action:@selector(ts_colorRowTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_colorRow];
    _colorSwatch = [[UIView alloc] init];
    _colorSwatch.layer.cornerRadius = 10.f;
    _colorSwatch.layer.borderWidth = 1.f;
    _colorSwatch.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.12f].CGColor;
    _colorSwatch.userInteractionEnabled = NO;
    [_colorRow addSubview:_colorSwatch];
    _colorTitleLabel = TSUgLabel([UIFont systemFontOfSize:16.f weight:UIFontWeightMedium], [TSHsdDisplay ink]);
    [_colorRow addSubview:_colorTitleLabel];
    _colorSubtitleLabel = TSUgLabel([UIFont systemFontOfSize:12.5f], [TSHsdDisplay textSecondary]);
    _colorSubtitleLabel.numberOfLines = 2;
    [_colorRow addSubview:_colorSubtitleLabel];
    _colorValueLabel = TSUgLabel([TSHsdDisplay monoFontOfSize:13.f], [TSHsdDisplay textSecondary]);
    [_colorRow addSubview:_colorValueLabel];
    _chevron = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"chevron.right", 13.f, UIImageSymbolWeightSemibold)];
    _chevron.tintColor = [TSHsdDisplay textTertiary];
    _chevron.contentMode = UIViewContentModeCenter;
    [_colorRow addSubview:_chevron];

    NSMutableArray<TSUgreenPaletteDot *> *dots = [NSMutableArray array];
    for (NSString *hex in [TSUgreenDisplay paletteHexes]) {
        TSUgreenPaletteDot *dot = [[TSUgreenPaletteDot alloc] init];
        dot.hex = hex;
        [dot addTarget:self action:@selector(ts_paletteTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dot];
        [dots addObject:dot];
    }
    TSUgreenPaletteDot *more = [[TSUgreenPaletteDot alloc] init];
    [more makeMoreButton];
    [more addTarget:self action:@selector(ts_colorRowTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:more];
    [dots addObject:more];
    _paletteDots = dots;
    return self;
}

#pragma mark - 公开方法

/** 按当前属性刷新 */
- (void)reload {
    BOOL custom = (self.theme == TSUgreenLyricsThemeCustom);
    BOOL themeModified = (self.theme != self.deviceTheme);
    NSString *hex = [TSUgreenDisplay hexRGBAOfColor:self.color];
    NSString *deviceHex = [TSUgreenDisplay hexRGBAOfColor:self.deviceColor];
    BOOL colorModified = ![hex isEqualToString:deviceHex];

    for (TSUgreenThemeSwatch *swatch in self.swatches) {
        swatch.hue = self.hue;
        swatch.customColor = self.color;
        swatch.on = (swatch.theme == self.theme);
        swatch.showsDeviceMark = themeModified && swatch.theme == self.deviceTheme;
        [swatch ts_apply];
    }

    self.colorSwatch.backgroundColor = [TSUgreenDisplay colorFromHex:[hex substringToIndex:7]];
    self.colorSwatch.alpha = custom ? 1.f : 0.4f;
    UIColor *titleColor = custom ? [TSHsdDisplay ink] : [TSHsdDisplay textTertiary];
    self.colorTitleLabel.attributedText = [TSUgreenDisplay title:TSLocalizedString(@"ugreen.field.color") font:self.colorTitleLabel.font
                                                           color:titleColor modifiedDotColor:colorModified ? self.hue : nil];
    NSMutableAttributedString *subtitle = [[NSMutableAttributedString alloc]
        initWithString:custom ? TSLocalizedString(@"ugreen.color.custom_only") : TSLocalizedString(@"ugreen.color.unused")
            attributes:@{NSFontAttributeName: self.colorSubtitleLabel.font, NSForegroundColorAttributeName: [TSHsdDisplay textSecondary]}];
    if (colorModified) {
        NSString *was = [NSString stringWithFormat:TSLocalizedString(@"ugreen.was_format"), deviceHex];
        [subtitle appendAttributedString:[[NSAttributedString alloc] initWithString:was attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:12.5f weight:UIFontWeightSemibold], NSForegroundColorAttributeName: self.hue}]];
    }
    self.colorSubtitleLabel.attributedText = subtitle;
    self.colorValueLabel.text = hex;
    self.colorValueLabel.textColor = custom ? [TSHsdDisplay textSecondary] : [TSHsdDisplay textTertiary];
    self.chevron.hidden = !custom;
    self.colorRow.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", TSLocalizedString(@"ugreen.field.color"), hex];
    self.colorRow.isAccessibilityElement = YES;

    NSString *rgb = [hex substringToIndex:7];
    BOOL inPalette = [[TSUgreenDisplay paletteHexes] containsObject:rgb];
    for (TSUgreenPaletteDot *dot in self.paletteDots) {
        dot.hidden = !custom;
        dot.on = dot.hex ? [dot.hex isEqualToString:rgb] : !inPalette;
        [dot ts_apply];
    }
    [self setNeedsLayout];
}

#pragma mark - 私有方法

- (void)ts_themeTapped:(TSUgreenThemeSwatch *)swatch {
    if (self.onSelectTheme) { self.onSelectTheme((TSUgreenLyricsTheme)swatch.tag); }
}

- (void)ts_paletteTapped:(TSUgreenPaletteDot *)dot {
    if (dot.hex && self.onSelectColor) { self.onSelectColor(dot.hex); }
}

- (void)ts_colorRowTapped {
    if (self.onOpenColorSheet) { self.onOpenColorSheet(); }
}

/** 主题色块边长 */
- (CGFloat)ts_swatchSide:(CGFloat)width { return floor((width - 28.f - 32.f) / 5.f); }

/** 主题区高度 */
- (CGFloat)ts_themesHeight:(CGFloat)width { return 16.f + [self ts_swatchSide:width] + 6.f + 15.f + 2.f + 12.f + 12.f; }

/** 颜色行文字宽 */
- (CGFloat)ts_colorTextWidth:(CGFloat)width {
    CGFloat right = width - 16.f;
    if (!self.chevron.hidden) { right -= 19.f; }
    CGFloat valueW = ceil([self.colorValueLabel.text sizeWithAttributes:@{NSFontAttributeName: self.colorValueLabel.font}].width);
    return right - valueW - 13.f - 59.f;
}

/** 颜色行高度 */
- (CGFloat)ts_colorRowHeight:(CGFloat)width {
    CGFloat textW = [self ts_colorTextWidth:width];
    CGFloat titleH = ceil(self.colorTitleLabel.font.lineHeight);
    CGFloat subH = MIN(ceil([self.colorSubtitleLabel sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)].height), 36.f);
    return MAX(60.f, titleH + 3.f + subH + 24.f);
}

- (CGSize)sizeThatFits:(CGSize)size {
    BOOL custom = (self.theme == TSUgreenLyricsThemeCustom);
    CGFloat h = [self ts_themesHeight:size.width] + [self ts_colorRowHeight:size.width] + (custom ? 2.f + kTSUgPaletteDot + 16.f : 0);
    return CGSizeMake(size.width, h);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    CGFloat side = [self ts_swatchSide:w];
    CGFloat gap = (w - 28.f - side * 5) / 4.f;
    [self.swatches enumerateObjectsUsingBlock:^(TSUgreenThemeSwatch *swatch, NSUInteger idx, BOOL *stop) {
        swatch.frame = CGRectMake(14.f + idx * (side + gap), 16.f, side, side + 6.f + 15.f + 2.f + 12.f);
    }];

    CGFloat rowY = [self ts_themesHeight:w];
    CGFloat rowH = [self ts_colorRowHeight:w];
    self.colorRow.frame = CGRectMake(0, rowY, w, rowH);
    self.colorSwatch.frame = CGRectMake(16.f, (rowH - 30.f) / 2.f, 30.f, 30.f);
    CGFloat right = w - 16.f;
    if (!self.chevron.hidden) {
        self.chevron.frame = CGRectMake(right - 11.f, (rowH - 16.f) / 2.f, 16.f, 16.f);
        right -= 19.f;
    }
    CGFloat valueW = ceil([self.colorValueLabel.text sizeWithAttributes:@{NSFontAttributeName: self.colorValueLabel.font}].width);
    self.colorValueLabel.frame = CGRectMake(right - valueW, (rowH - 18.f) / 2.f, valueW, 18.f);
    CGFloat textW = [self ts_colorTextWidth:w];
    CGFloat titleH = ceil(self.colorTitleLabel.font.lineHeight);
    CGFloat subH = MIN(ceil([self.colorSubtitleLabel sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)].height), 36.f);
    CGFloat textY = (rowH - titleH - 3.f - subH) / 2.f;
    self.colorTitleLabel.frame = CGRectMake(59.f, textY, textW, titleH);
    self.colorSubtitleLabel.frame = CGRectMake(59.f, textY + titleH + 3.f, textW, subH);

    CGFloat paletteY = rowY + rowH + 2.f;
    NSUInteger count = self.paletteDots.count;
    CGFloat dotGap = count > 1 ? (w - 32.f - kTSUgPaletteDot * count) / (count - 1) : 0;
    [self.paletteDots enumerateObjectsUsingBlock:^(TSUgreenPaletteDot *dot, NSUInteger idx, BOOL *stop) {
        dot.frame = CGRectMake(16.f + idx * (kTSUgPaletteDot + dotGap), paletteY, kTSUgPaletteDot, kTSUgPaletteDot);
    }];
}

@end

#pragma mark - TSUgreenNoticeBanner

@interface TSUgreenNoticeBanner ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation TSUgreenNoticeBanner

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSUgreenDisplay hue];
    _symbol = @"info.circle";
    self.layer.cornerRadius = 16.f;
    _iconView = [[UIImageView alloc] init];
    _iconView.contentMode = UIViewContentModeCenter;
    [self addSubview:_iconView];
    _label = TSUgLabel([UIFont systemFontOfSize:12.5f], [TSHsdDisplay textSecondary]);
    _label.numberOfLines = 0;
    [self addSubview:_label];
    _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_closeButton setImage:TSHsdSymbol(@"xmark", 11.f, UIImageSymbolWeightBold) forState:UIControlStateNormal];
    _closeButton.tintColor = [TSHsdDisplay textTertiary];
    _closeButton.accessibilityLabel = TSLocalizedString(@"general.close");
    [_closeButton addTarget:self action:@selector(ts_close) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.hidden = YES;
    [self addSubview:_closeButton];
    return self;
}

- (void)setSymbol:(NSString *)symbol { _symbol = [symbol copy]; [self ts_apply]; }
- (void)setText:(NSString *)text { _text = [text copy]; [self ts_apply]; }
- (void)setWarn:(BOOL)warn { _warn = warn; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }
- (void)setOnClose:(nullable void (^)(void))onClose { _onClose = [onClose copy]; self.closeButton.hidden = (onClose == nil); [self setNeedsLayout]; }

/** 刷新外观 */
- (void)ts_apply {
    UIColor *tint = self.warn ? [TSHsdDisplay statusWarn] : self.hue;
    self.backgroundColor = [tint colorWithAlphaComponent:self.warn ? 0.11f : 0.09f];
    self.iconView.tintColor = tint;
    self.iconView.image = TSHsdSymbol(self.symbol, 15.f, UIImageSymbolWeightMedium);
    NSMutableAttributedString *text = [TSHsdRich(self.text ?: @"", self.label.font, [TSHsdDisplay textSecondary], [TSHsdDisplay ink]) mutableCopy];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.25f;
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    self.label.attributedText = text;
    [self setNeedsLayout];
}

- (void)ts_close {
    if (self.onClose) { self.onClose(); }
}

/** 文字宽度 */
- (CGFloat)ts_textWidth:(CGFloat)width { return width - 41.f - 14.f - (self.closeButton.hidden ? 0 : 22.f); }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat textH = ceil([self.label sizeThatFits:CGSizeMake([self ts_textWidth:size.width], CGFLOAT_MAX)].height);
    return CGSizeMake(size.width, textH + 24.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.iconView.frame = CGRectMake(14.f, 13.f, 17.f, 17.f);
    self.label.frame = CGRectMake(41.f, 12.f, [self ts_textWidth:w], self.bounds.size.height - 24.f);
    self.closeButton.frame = CGRectMake(w - 10.f - 26.f, 9.f, 26.f, 26.f);
}

@end

#pragma mark - TSUgreenCodeBlock

@interface TSUgreenCodeBlock ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSUgreenCodeBlock

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.backgroundColor = [TSHsdDisplay fill];
    self.layer.cornerRadius = 18.f;
    _label = TSUgLabel([TSHsdDisplay monoFontOfSize:11.5f], [TSHsdDisplay textSecondary]);
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:_label];
    return self;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.3f;
    style.lineBreakMode = NSLineBreakByCharWrapping;
    self.label.attributedText = [[NSAttributedString alloc] initWithString:text ?: @"" attributes:@{
        NSFontAttributeName: self.label.font, NSForegroundColorAttributeName: [TSHsdDisplay textSecondary], NSParagraphStyleAttributeName: style}];
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, ceil([self.label sizeThatFits:CGSizeMake(size.width - 32.f, CGFLOAT_MAX)].height) + 24.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectMake(16.f, 12.f, self.bounds.size.width - 32.f, self.bounds.size.height - 24.f);
}

@end

#pragma mark - TSUgreenSyncedPill

@interface TSUgreenSyncedPill ()
@property (nonatomic, strong) UIView *pill;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSUgreenSyncedPill

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _pill = [[UIView alloc] init];
    _pill.backgroundColor = [TSHsdDisplay fill];
    [self addSubview:_pill];
    _iconView = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"checkmark", 11.f, UIImageSymbolWeightBold)];
    _iconView.tintColor = [TSHsdDisplay statusGood];
    _iconView.contentMode = UIViewContentModeCenter;
    [_pill addSubview:_iconView];
    _label = TSUgLabel([UIFont systemFontOfSize:12.f weight:UIFontWeightSemibold], [TSHsdDisplay textSecondary]);
    [_pill addSubview:_label];
    self.hsd_spacingBefore = @(16);
    return self;
}

- (void)setText:(NSString *)text { _text = [text copy]; self.label.text = text; [self setNeedsLayout]; }

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 32.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat textW = ceil([self.label.text sizeWithAttributes:@{NSFontAttributeName: self.label.font}].width);
    CGFloat pillW = 14.f + 14.f + 7.f + textW + 14.f;
    self.pill.frame = CGRectMake((self.bounds.size.width - pillW) / 2.f, 0, pillW, 32.f);
    self.pill.layer.cornerRadius = 16.f;
    self.iconView.frame = CGRectMake(14.f, 9.f, 14.f, 14.f);
    self.label.frame = CGRectMake(14.f + 14.f + 7.f, 0, textW, 32.f);
}

@end

#pragma mark - TSUgreenLogRowView

@interface TSUgreenLogRowView ()
@property (nonatomic, strong) UIView *dot;
@property (nonatomic, strong) UILabel *methodLabel;
@property (nonatomic, strong) UILabel *argsLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation TSUgreenLogRowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _dot = [[UIView alloc] init];
    _dot.layer.cornerRadius = 3.5f;
    [self addSubview:_dot];
    _methodLabel = TSUgLabel([UIFont monospacedSystemFontOfSize:12.f weight:UIFontWeightSemibold], [TSHsdDisplay ink]);
    _methodLabel.numberOfLines = 0;
    [self addSubview:_methodLabel];
    _argsLabel = TSUgLabel([TSHsdDisplay monoFontOfSize:10.5f], [TSHsdDisplay textTertiary]);
    _argsLabel.numberOfLines = 0;
    _argsLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:_argsLabel];
    _resultLabel = TSUgLabel([TSHsdDisplay monoFontOfSize:11.f], [TSHsdDisplay textSecondary]);
    _resultLabel.textAlignment = NSTextAlignmentRight;
    _resultLabel.numberOfLines = 0;
    [self addSubview:_resultLabel];
    _timeLabel = TSUgLabel([TSHsdDisplay monoFontOfSize:10.f], [TSHsdDisplay textTertiary]);
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_timeLabel];
    return self;
}

/** 用一条调用记录配置 */
- (void)configureWithEntry:(TSHsdCallLogEntry *)entry {
    self.methodLabel.text = entry.method;
    self.argsLabel.text = entry.params;
    NSString *time = [TSUgreenDisplay clockSecondsString:entry.startedAt];
    if (!entry.finished) {
        self.dot.backgroundColor = [TSHsdDisplay statusWarn];
        self.resultLabel.text = @"…";
        self.resultLabel.textColor = [TSHsdDisplay textSecondary];
        self.timeLabel.text = time;
    } else {
        BOOL neutral = (entry.durationMs < 1 && entry.success && !entry.error);
        self.dot.backgroundColor = entry.success ? (neutral ? [TSHsdDisplay textTertiary] : [TSHsdDisplay statusGood]) : [TSHsdDisplay statusBad];
        self.resultLabel.text = entry.success ? (entry.result.length ? entry.result : @"OK") : [TSUgreenDisplay errorShortName:entry.error];
        self.resultLabel.textColor = entry.success ? [TSHsdDisplay textSecondary] : [TSHsdDisplay statusBad];
        self.timeLabel.text = entry.durationMs >= 1 ? [NSString stringWithFormat:@"%@ · %.0fms", time, entry.durationMs] : time;
    }
    [self setNeedsLayout];
}

/** 右栏宽度（最多 112） */
- (CGFloat)ts_rightWidth {
    CGFloat w1 = ceil([self.resultLabel.text sizeWithAttributes:@{NSFontAttributeName: self.resultLabel.font}].width);
    CGFloat w2 = ceil([self.timeLabel.text sizeWithAttributes:@{NSFontAttributeName: self.timeLabel.font}].width);
    return MIN(112.f, MAX(w1, w2));
}

/** 左栏宽度 */
- (CGFloat)ts_leftWidth:(CGFloat)width { return width - 16.f - 8.f - 11.f - 11.f - [self ts_rightWidth] - 16.f; }

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat lw = [self ts_leftWidth:size.width], rw = [self ts_rightWidth];
    CGFloat left = ceil([self.methodLabel sizeThatFits:CGSizeMake(lw, CGFLOAT_MAX)].height);
    if (self.argsLabel.text.length) { left += 3.f + ceil([self.argsLabel sizeThatFits:CGSizeMake(lw, CGFLOAT_MAX)].height); }
    CGFloat right = ceil([self.resultLabel sizeThatFits:CGSizeMake(rw, CGFLOAT_MAX)].height) + 2.f + 13.f;
    return CGSizeMake(size.width, MAX(left, right) + 24.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, lw = [self ts_leftWidth:w], rw = [self ts_rightWidth];
    self.dot.frame = CGRectMake(16.f, 17.f, 7.f, 7.f);
    CGFloat x = 16.f + 8.f + 11.f;
    CGFloat mh = ceil([self.methodLabel sizeThatFits:CGSizeMake(lw, CGFLOAT_MAX)].height);
    self.methodLabel.frame = CGRectMake(x, 12.f, lw, mh);
    CGFloat ah = self.argsLabel.text.length ? ceil([self.argsLabel sizeThatFits:CGSizeMake(lw, CGFLOAT_MAX)].height) : 0;
    self.argsLabel.frame = CGRectMake(x, 12.f + mh + 3.f, lw, ah);
    CGFloat rx = w - 16.f - rw;
    CGFloat rh = ceil([self.resultLabel sizeThatFits:CGSizeMake(rw, CGFLOAT_MAX)].height);
    self.resultLabel.frame = CGRectMake(rx, 12.f, rw, rh);
    self.timeLabel.frame = CGRectMake(rx, 12.f + rh + 2.f, rw, 13.f);
}

@end

#pragma mark - TSUgreenColorPreviewBlock

@interface TSUgreenColorPreviewBlock ()
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) CAGradientLayer *background;
@property (nonatomic, strong) TSUgreenDeviceView *deviceView;
@property (nonatomic, strong) UILabel *captionLabel;
@end

@implementation TSUgreenColorPreviewBlock

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _spec = [TSUgreenScreenSpec specWithScreen:nil];
    _color = [UIColor whiteColor];
    _container = [[UIView alloc] init];
    _container.layer.cornerRadius = 20.f;
    _container.clipsToBounds = YES;
    [self addSubview:_container];
    _background = [CAGradientLayer layer];
    [TSUgreenDisplay applyCSSAngle:160.f toGradient:_background];
    [_container.layer addSublayer:_background];
    _deviceView = [[TSUgreenDeviceView alloc] init];
    _deviceView.bezel = 6.f;
    _deviceView.maxScreenSize = CGSizeMake(280.f, 140.f);
    _deviceView.maxScale = 0.4f;
    _deviceView.content = TSUgreenScreenContentLyrics;
    _deviceView.theme = TSUgreenLyricsThemeCustom;
    [_container addSubview:_deviceView];
    _captionLabel = TSUgLabel([UIFont systemFontOfSize:11.f], [TSUgreenDisplay heroInk2]);
    _captionLabel.textAlignment = NSTextAlignmentCenter;
    _captionLabel.text = TSLocalizedString(@"ugreen.color.preview_caption");
    [_container addSubview:_captionLabel];
    return self;
}

- (void)setSpec:(TSUgreenScreenSpec *)spec { _spec = spec; self.deviceView.spec = spec; [self.deviceView reload]; [self setNeedsLayout]; }
- (void)setColor:(UIColor *)color { _color = color; self.deviceView.lyricsColor = color; [self.deviceView reload]; }

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, 16.f + [self.deviceView deviceSize].height + 10.f + 14.f + 12.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UITraitCollection *traits = self.traitCollection;
    self.container.frame = self.bounds;
    self.background.frame = self.bounds;
    self.background.colors = @[(__bridge id)[[TSUgreenDisplay heroColor2] resolvedColorWithTraitCollection:traits].CGColor,
                               (__bridge id)[[TSUgreenDisplay heroColor] resolvedColorWithTraitCollection:traits].CGColor];
    CGSize device = [self.deviceView deviceSize];
    self.deviceView.frame = CGRectMake((self.bounds.size.width - device.width) / 2.f, 16.f, device.width, device.height);
    self.captionLabel.frame = CGRectMake(16.f, 16.f + device.height + 10.f, self.bounds.size.width - 32.f, 14.f);
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self setNeedsLayout];
}

@end

#pragma mark - 色相滑杆（.hue）

@interface TSUgreenHueSlider : UIControl
/// 色相 0–359
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) CAGradientLayer *track;
@property (nonatomic, strong) UIView *thumb;
@end

@implementation TSUgreenHueSlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _track = [CAGradientLayer layer];
    NSMutableArray *colors = [NSMutableArray array];
    for (NSInteger hue = 0; hue <= 360; hue += 60) { [colors addObject:(__bridge id)[TSUgreenDisplay colorWithHueDegrees:hue].CGColor]; }
    _track.colors = colors;
    _track.startPoint = CGPointMake(0, 0.5f);
    _track.endPoint = CGPointMake(1, 0.5f);
    _track.cornerRadius = 7.f;
    [self.layer addSublayer:_track];
    _thumb = [[UIView alloc] init];
    _thumb.backgroundColor = [UIColor whiteColor];
    _thumb.layer.cornerRadius = 12.f;
    _thumb.layer.shadowColor = [UIColor blackColor].CGColor;
    _thumb.layer.shadowOpacity = 0.4f;
    _thumb.layer.shadowRadius = 2.5f;
    _thumb.layer.shadowOffset = CGSizeMake(0, 1.f);
    _thumb.userInteractionEnabled = NO;
    [self addSubview:_thumb];
    self.accessibilityLabel = TSLocalizedString(@"ugreen.color.hue");
    self.accessibilityTraits = UIAccessibilityTraitAdjustable;
    return self;
}

- (void)setValue:(CGFloat)value { _value = MIN(MAX(value, 0), 359.f); [self setNeedsLayout]; }

/** 触点 → 色相 */
- (void)ts_updateWithTouch:(UITouch *)touch {
    CGFloat x = [touch locationInView:self].x;
    CGFloat usable = MAX(self.bounds.size.width - 24.f, 1);
    self.value = (x - 12.f) / usable * 359.f;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ts_updateWithTouch:touch];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self ts_updateWithTouch:touch];
    return YES;
}

- (void)accessibilityIncrement { self.value = self.value + 10.f; [self sendActionsForControlEvents:UIControlEventValueChanged]; }
- (void)accessibilityDecrement { self.value = self.value - 10.f; [self sendActionsForControlEvents:UIControlEventValueChanged]; }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    self.track.frame = CGRectMake(0, (h - 14.f) / 2.f, w, 14.f);
    CGFloat x = 12.f + self.value / 359.f * MAX(w - 24.f, 0);
    self.thumb.frame = CGRectMake(x - 12.f, (h - 24.f) / 2.f, 24.f, 24.f);
}

@end

#pragma mark - TSUgreenColorPickerBlock

static const NSInteger kTSUgGridColumns = 6;

@interface TSUgreenColorPickerBlock () <UITextFieldDelegate, UIColorPickerViewControllerDelegate>
@property (nonatomic, strong) NSArray<TSUgreenPaletteDot *> *gridDots;
@property (nonatomic, strong) TSUgreenHueSlider *slider;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UILabel *fieldLabel;
@property (nonatomic, strong) UILabel *alphaLabel;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation TSUgreenColorPickerBlock

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hex = @"#FFFFFF";
    NSMutableArray<TSUgreenPaletteDot *> *dots = [NSMutableArray array];
    for (NSString *hex in [TSUgreenDisplay gridHexes]) {
        TSUgreenPaletteDot *dot = [[TSUgreenPaletteDot alloc] init];
        dot.hex = hex;
        [dot addTarget:self action:@selector(ts_gridTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dot];
        [dots addObject:dot];
    }
    _gridDots = dots;

    _slider = [[TSUgreenHueSlider alloc] init];
    [_slider addTarget:self action:@selector(ts_hueChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_slider];

    _separator = [[UIView alloc] init];
    _separator.backgroundColor = TSUgLine();
    [self addSubview:_separator];
    _fieldLabel = TSUgLabel([UIFont systemFontOfSize:12.f weight:UIFontWeightMedium], [TSHsdDisplay textTertiary]);
    _fieldLabel.text = TSLocalizedString(@"ugreen.color.hex_label");
    [self addSubview:_fieldLabel];
    _alphaLabel = TSUgLabel([UIFont systemFontOfSize:12.f weight:UIFontWeightMedium], [TSHsdDisplay textTertiary]);
    _alphaLabel.text = TSLocalizedString(@"ugreen.color.alpha_fixed");
    _alphaLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_alphaLabel];
    _textField = [[UITextField alloc] init];
    _textField.font = [UIFont monospacedSystemFontOfSize:16.f weight:UIFontWeightRegular];
    _textField.textColor = [TSHsdDisplay ink];
    _textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.spellCheckingType = UITextSpellCheckingTypeNo;
    _textField.keyboardType = UIKeyboardTypeASCIICapable;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.delegate = self;
    _textField.accessibilityLabel = TSLocalizedString(@"ugreen.color.hex_label");
    [_textField addTarget:self action:@selector(ts_textChanged) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_textField];
    [self ts_syncFromHex:YES slider:YES];
    return self;
}

- (void)setHex:(NSString *)hex {
    UIColor *color = [TSUgreenDisplay colorFromHex:hex];
    _hex = color ? [TSUgreenDisplay hexRGBOfColor:color] : @"#FFFFFF";
    [self ts_syncFromHex:YES slider:YES];
}

#pragma mark - 私有方法

/** 按 hex 同步网格选中、滑杆与输入框 */
- (void)ts_syncFromHex:(BOOL)updateField slider:(BOOL)updateSlider {
    for (TSUgreenPaletteDot *dot in self.gridDots) {
        dot.on = [dot.hex isEqualToString:self.hex];
        [dot ts_apply];
    }
    if (updateSlider) { self.slider.value = [TSUgreenDisplay hueDegreesOfColor:[TSUgreenDisplay colorFromHex:self.hex]]; }
    if (updateField) { self.textField.text = [self.hex substringFromIndex:1]; }
}

/** 通知外部 */
- (void)ts_emit {
    if (self.onChange) { self.onChange(self.hex); }
}

- (void)ts_gridTapped:(TSUgreenPaletteDot *)dot {
    _hex = dot.hex;
    [self ts_syncFromHex:YES slider:YES];
    [self ts_emit];
}

- (void)ts_hueChanged {
    _hex = [TSUgreenDisplay hexRGBOfColor:[TSUgreenDisplay colorWithHueDegrees:self.slider.value]];
    [self ts_syncFromHex:YES slider:NO];
    [self ts_emit];
}

- (void)ts_textChanged {
    NSString *text = [[self.textField.text stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    if (![self.textField.text isEqualToString:text]) { self.textField.text = text; }
    UIColor *color = (text.length == 6) ? [TSUgreenDisplay colorFromHex:text] : nil;
    if (!color) { return; }
    _hex = [@"#" stringByAppendingString:text];
    [self ts_syncFromHex:NO slider:YES];
    [self ts_emit];
}

#pragma mark - 系统取色器

/** 打开系统取色器 */
- (void)presentSystemPickerFrom:(UIViewController *)presenter {
    UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
    picker.supportsAlpha = NO;
    picker.selectedColor = [TSUgreenDisplay colorFromHex:self.hex] ?: [UIColor whiteColor];
    picker.delegate = self;
    [self.textField resignFirstResponder];
    [presenter presentViewController:picker animated:YES completion:nil];
}

/** 系统取色器选中颜色（拖动中也会回调） */
- (void)colorPickerViewController:(UIColorPickerViewController *)viewController didSelectColor:(UIColor *)color continuously:(BOOL)continuously API_AVAILABLE(ios(15.0)) {
    _hex = [TSUgreenDisplay hexRGBOfColor:color];
    [self ts_syncFromHex:YES slider:YES];
    [self ts_emit];
}

#pragma mark - UITextFieldDelegate

/** 只允许 0-9 A-F，最多 6 位（# 自动去掉） */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *next = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSCharacterSet *invalid = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"] invertedSet];
    return next.length <= 6 && [next rangeOfCharacterFromSet:invalid].location == NSNotFound;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 布局

/** 网格单元边长 */
- (CGFloat)ts_cell:(CGFloat)width { return floor((width - 32.f - 12.f * (kTSUgGridColumns - 1)) / kTSUgGridColumns); }

/** 网格区高度 */
- (CGFloat)ts_gridHeight:(CGFloat)width {
    NSInteger rows = (self.gridDots.count + kTSUgGridColumns - 1) / kTSUgGridColumns;
    return 16.f + rows * [self ts_cell:width] + (rows - 1) * 12.f + 16.f;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, [self ts_gridHeight:size.width] + 40.f + 66.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, cell = [self ts_cell:w];
    CGFloat gap = (w - 32.f - cell * kTSUgGridColumns) / (kTSUgGridColumns - 1);
    [self.gridDots enumerateObjectsUsingBlock:^(TSUgreenPaletteDot *dot, NSUInteger idx, BOOL *stop) {
        NSInteger row = idx / kTSUgGridColumns, column = idx % kTSUgGridColumns;
        dot.frame = CGRectMake(16.f + column * (cell + gap), 16.f + row * (cell + 12.f), cell, cell);
    }];
    CGFloat y = [self ts_gridHeight:w] + 2.f;
    self.slider.frame = CGRectMake(16.f, y, w - 32.f, 24.f);
    y += 24.f + 14.f;
    self.separator.frame = CGRectMake(16.f, y, w - 32.f, 1.f / [UIScreen mainScreen].scale);
    self.fieldLabel.frame = CGRectMake(16.f, y + 13.f, (w - 32.f) / 2.f, 15.f);
    self.alphaLabel.frame = CGRectMake(w / 2.f, y + 13.f, w / 2.f - 16.f, 15.f);
    self.textField.frame = CGRectMake(16.f, y + 13.f + 15.f + 6.f, w - 32.f, 22.f);
}

@end

#pragma mark - TSUgreenLinkFootView

@interface TSUgreenLinkFootView ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation TSUgreenLinkFootView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSUgreenDisplay hue];
    _label = TSUgLabel([UIFont systemFontOfSize:12.5f], [TSHsdDisplay textTertiary]);
    _label.numberOfLines = 0;
    _label.userInteractionEnabled = NO;
    [self addSubview:_label];
    self.hsd_spacingBefore = @(8);
    self.accessibilityTraits = UIAccessibilityTraitLink;
    return self;
}

- (void)setText:(NSString *)text { _text = [text copy]; [self ts_apply]; }
- (void)setLinkText:(NSString *)linkText { _linkText = [linkText copy]; [self ts_apply]; }
- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_apply]; }

/** 拼出「普通文字 + 色相链接」 */
- (void)ts_apply {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.25f;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:self.text ?: @"" attributes:@{
        NSFontAttributeName: self.label.font, NSForegroundColorAttributeName: [TSHsdDisplay textTertiary], NSParagraphStyleAttributeName: style}];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:self.linkText ?: @"" attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:12.5f weight:UIFontWeightSemibold], NSForegroundColorAttributeName: self.hue ?: [TSUgreenDisplay hue],
        NSParagraphStyleAttributeName: style}]];
    self.label.attributedText = text;
    self.accessibilityLabel = text.string;
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.6f : 1.f;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, ceil([self.label sizeThatFits:CGSizeMake(size.width - 12.f, CGFLOAT_MAX)].height));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectMake(6.f, 0, self.bounds.size.width - 12.f, self.bounds.size.height);
}

@end
