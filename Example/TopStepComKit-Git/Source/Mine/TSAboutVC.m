//
//  TSAboutVC.m
//  TopStepComKit_Example
//
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAboutVC.h"
#import "TSRootVC.h"

// ─── 常量 ────────────────────────────────────────────────────────────────────
static NSString *const kAboutAppName    = @"TopStep ComKit";
static NSString *const kAboutCompanyCN  = @"深圳市拓步智能大数据有限公司";
static NSString *const kAboutCompanyEN  = @"TopStep Tech Co., Ltd.";
static NSString *const kAboutWebsite    = @"maga.topstep-tech.com";
static NSString *const kAboutEmailBiz   = @"632756801@qq.com";
static NSString *const kAboutEmailTech  = @"rd@hetangsmart.com";

// Hero 卡片渐变色
#define kHeroColorTop    [UIColor colorWithRed:10/255.f  green:22/255.f  blue:40/255.f  alpha:1.f]
#define kHeroColorBottom [UIColor colorWithRed:26/255.f  green:10/255.f  blue:60/255.f  alpha:1.f]
#define kAccentBlue      [UIColor colorWithRed:74/255.f  green:158/255.f blue:255/255.f alpha:1.f]

// ─── Hero 卡片 ────────────────────────────────────────────────────────────────
@interface TSAboutHeroCard : UIView
@end

@implementation TSAboutHeroCard {
    CAEmitterLayer  *_emitter;
    CALayer         *_glowLayer;
    UIImageView     *_iconView;
    UILabel         *_appNameLabel;
    UILabel         *_versionLabel;
    UIView          *_divider;
    UILabel         *_companyCNLabel;
    UILabel         *_companyENLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = TSRadius_LG;
        self.clipsToBounds = YES;
        [self ts_setupGradient];
        [self ts_setupSubviews];
    }
    return self;
}

- (void)ts_setupGradient {
    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = self.bounds;
    grad.colors = @[
        (id)kHeroColorTop.CGColor,
        (id)kHeroColorBottom.CGColor
    ];
    grad.startPoint = CGPointMake(0, 0);
    grad.endPoint   = CGPointMake(1, 1);
    [self.layer insertSublayer:grad atIndex:0];
}

- (void)ts_setupSubviews {
    // 光晕底层
    _glowLayer = [CALayer layer];
    _glowLayer.backgroundColor = [UIColor colorWithRed:74/255.f green:158/255.f blue:255/255.f alpha:0.35f].CGColor;
    _glowLayer.cornerRadius = 47;
    [self.layer addSublayer:_glowLayer];

    // App 图标
    _iconView = [[UIImageView alloc] init];
    _iconView.layer.cornerRadius = 16;
    _iconView.clipsToBounds = YES;
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    _iconView.backgroundColor = [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:36 weight:UIImageSymbolWeightMedium];
        _iconView.image = [UIImage systemImageNamed:@"applewatch" withConfiguration:cfg];
        _iconView.tintColor = [UIColor whiteColor];
    }
    [self addSubview:_iconView];

    // App 名称
    _appNameLabel = [[UILabel alloc] init];
    _appNameLabel.text = kAboutAppName;
    _appNameLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    _appNameLabel.textColor = [UIColor whiteColor];
    _appNameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_appNameLabel];

    // 版本号
    _versionLabel = [[UILabel alloc] init];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"1.0.0";
    _versionLabel.text = [NSString stringWithFormat:@"%@ %@", TSLocalizedString(@"about.version"), version];
    _versionLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    _versionLabel.textColor = kAccentBlue;
    _versionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_versionLabel];

    // 分割线
    _divider = [[UIView alloc] init];
    _divider.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15f];
    [self addSubview:_divider];

    // 公司中文名
    _companyCNLabel = [[UILabel alloc] init];
    _companyCNLabel.text = kAboutCompanyCN;
    _companyCNLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _companyCNLabel.textColor = [UIColor whiteColor];
    _companyCNLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_companyCNLabel];

    // 公司英文名
    _companyENLabel = [[UILabel alloc] init];
    _companyENLabel.text = kAboutCompanyEN;
    _companyENLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    _companyENLabel.textColor = kAccentBlue;
    _companyENLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_companyENLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);

    // 更新渐变 frame
    CALayer *grad = self.layer.sublayers.firstObject;
    if ([grad isKindOfClass:[CAGradientLayer class]]) {
        grad.frame = self.bounds;
    }

    // 图标
    CGFloat iconSize = 70;
    CGFloat iconX = (w - iconSize) / 2;
    _iconView.frame = CGRectMake(iconX, 32, iconSize, iconSize);

    // 光晕（比图标大 8pt 四周）
    _glowLayer.frame = CGRectMake(iconX - 8, 24, iconSize + 16, iconSize + 16);

    // App 名称
    _appNameLabel.frame = CGRectMake(16, CGRectGetMaxY(_iconView.frame) + 16, w - 32, 26);

    // 版本号
    _versionLabel.frame = CGRectMake(16, CGRectGetMaxY(_appNameLabel.frame) + 4, w - 32, 18);

    // 分割线
    _divider.frame = CGRectMake(32, CGRectGetMaxY(_versionLabel.frame) + 16, w - 64, 1);

    // 公司中文名
    _companyCNLabel.frame = CGRectMake(16, CGRectGetMaxY(_divider.frame) + 14, w - 32, 20);

    // 公司英文名
    _companyENLabel.frame = CGRectMake(16, CGRectGetMaxY(_companyCNLabel.frame) + 4, w - 32, 16);
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.window) {
        [self ts_startParticles];
        [self ts_startGlowPulse];
    }
}

// ─── 粒子系统 ─────────────────────────────────────────────────────────────────
- (void)ts_startParticles {
    if (_emitter) return;
    _emitter = [CAEmitterLayer layer];
    _emitter.frame = self.bounds;
    _emitter.emitterShape  = kCAEmitterLayerRectangle;
    _emitter.emitterPosition = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    _emitter.emitterSize   = self.bounds.size;
    _emitter.renderMode    = kCAEmitterLayerAdditive;

    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    cell.name            = @"particle";
    cell.birthRate       = 3.0f;
    cell.lifetime        = 8.0f;
    cell.lifetimeRange   = 3.0f;
    cell.velocity        = 12.0f;
    cell.velocityRange   = 8.0f;
    cell.emissionRange   = M_PI * 2;
    cell.scale           = 0.015f;
    cell.scaleRange      = 0.01f;
    cell.alphaSpeed      = -0.04f;
    cell.color           = [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor;
    cell.contents        = (id)[self ts_circleImage].CGImage;

    _emitter.emitterCells = @[cell];
    [self.layer insertSublayer:_emitter atIndex:1];
}

- (UIImage *)ts_circleImage {
    CGFloat size = 6;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, size, size));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

// ─── 光晕脉冲 ─────────────────────────────────────────────────────────────────
- (void)ts_startGlowPulse {
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulse.fromValue  = @(0.6f);
    pulse.toValue    = @(0.0f);
    pulse.duration   = 2.5f;
    pulse.repeatCount = HUGE_VALF;
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    pulse.autoreverses = YES;
    [_glowLayer addAnimation:pulse forKey:@"glowPulse"];
}

@end

// ─── 信息行视图 ───────────────────────────────────────────────────────────────
@interface TSAboutInfoRow : UIView
- (instancetype)initWithIcon:(NSString *)iconName title:(NSString *)title content:(NSString *)content;
@end

@implementation TSAboutInfoRow {
    UIImageView *_iconView;
    UILabel     *_titleLabel;
    UILabel     *_contentLabel;
}

- (instancetype)initWithIcon:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
    self = [super init];
    if (self) {
        self.backgroundColor = TSColor_Card;

        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.tintColor = TSColor_Primary;
        if (@available(iOS 13.0, *)) {
            _iconView.image = [UIImage systemImageNamed:iconName];
        }
        [self addSubview:_iconView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = title;
        _titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
        _titleLabel.textColor = TSColor_TextSecondary;
        [self addSubview:_titleLabel];

        _contentLabel = [[UILabel alloc] init];
        _contentLabel.text = content;
        _contentLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        _contentLabel.textColor = TSColor_TextPrimary;
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    _iconView.frame    = CGRectMake(16, (CGRectGetHeight(self.bounds) - 22) / 2, 22, 22);
    _titleLabel.frame  = CGRectMake(50, 10, w - 66, 16);
    _contentLabel.frame = CGRectMake(50, CGRectGetMaxY(_titleLabel.frame) + 2, w - 66, 20);
}

@end

// ─── TSAboutVC ────────────────────────────────────────────────────────────────
@interface TSAboutVC ()
@property (nonatomic, strong) UIScrollView    *scrollView;
@property (nonatomic, strong) TSAboutHeroCard *heroCard;
@end

@implementation TSAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TSLocalizedString(@"about.title");
    self.view.backgroundColor = TSColor_Background;
    [self ts_setupViews];
    [self ts_layoutViews];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self ts_layoutViews];
}

- (void)ts_setupViews {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = TSColor_Background;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];

    // Hero 卡片
    self.heroCard = [[TSAboutHeroCard alloc] initWithFrame:CGRectZero];
    [self.scrollView addSubview:self.heroCard];

    // 信息卡片容器
    UIView *infoCard = [self ts_buildInfoCard];
    infoCard.tag = 100;
    [self.scrollView addSubview:infoCard];

    // 版权卡片
    UIView *copyrightCard = [self ts_buildCopyrightCard];
    copyrightCard.tag = 101;
    [self.scrollView addSubview:copyrightCard];
}

- (UIView *)ts_buildInfoCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = TSColor_Card;
    card.layer.cornerRadius = TSRadius_MD;
    card.clipsToBounds = YES;

    NSArray *rows = @[
        @[@"globe", TSLocalizedString(@"about.website"),   kAboutWebsite],
        @[@"envelope.fill", TSLocalizedString(@"about.email_biz"), kAboutEmailBiz],
        @[@"envelope.fill", TSLocalizedString(@"about.email_tech"), kAboutEmailTech],
    ];

    CGFloat rowH = 52;
    for (NSInteger i = 0; i < rows.count; i++) {
        NSArray *row = rows[i];
        TSAboutInfoRow *rowView = [[TSAboutInfoRow alloc] initWithIcon:row[0] title:row[1] content:row[2]];
        rowView.frame = CGRectMake(0, i * rowH, 0, rowH);
        rowView.tag = 200 + i;
        [card addSubview:rowView];

        if (i < rows.count - 1) {
            UIView *sep = [[UIView alloc] init];
            sep.backgroundColor = TSColor_Separator;
            sep.tag = 300 + i;
            [card addSubview:sep];
        }
    }
    return card;
}

- (UIView *)ts_buildCopyrightCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = TSColor_Card;
    card.layer.cornerRadius = TSRadius_MD;
    card.clipsToBounds = YES;

    UILabel *label = [[UILabel alloc] init];
    label.text = TSLocalizedString(@"about.copyright");
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    label.textColor = TSColor_TextSecondary;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.tag = 400;
    [card addSubview:label];
    return card;
}

- (void)ts_layoutViews {
    CGFloat safeTop = self.view.safeAreaInsets.top;
    CGFloat navH = self.navigationController ? self.navigationController.navigationBar.frame.size.height : 0;
    CGFloat top = safeTop + navH;
    if (top < 1) top = 88;

    CGFloat vw = CGRectGetWidth(self.view.bounds);
    CGFloat sw = vw;
    self.scrollView.frame = CGRectMake(0, top, sw, CGRectGetHeight(self.view.bounds) - top);

    CGFloat margin = 16;
    CGFloat cardW  = sw - margin * 2;
    CGFloat heroH  = 260;
    self.heroCard.frame = CGRectMake(margin, margin, cardW, heroH);

    // 信息卡片
    UIView *infoCard = [self.scrollView viewWithTag:100];
    CGFloat rowH = 52;
    CGFloat infoH = rowH * 3;
    infoCard.frame = CGRectMake(margin, CGRectGetMaxY(self.heroCard.frame) + 16, cardW, infoH);

    // 信息行 & 分割线布局
    for (NSInteger i = 0; i < 3; i++) {
        UIView *row = [infoCard viewWithTag:200 + i];
        row.frame = CGRectMake(0, i * rowH, cardW, rowH);
        if (i < 2) {
            UIView *sep = [infoCard viewWithTag:300 + i];
            sep.frame = CGRectMake(50, (i + 1) * rowH - 0.5, cardW - 50, 0.5);
        }
    }

    // 版权卡片
    UIView *copyrightCard = [self.scrollView viewWithTag:101];
    CGFloat copyrightH = 52;
    copyrightCard.frame = CGRectMake(margin, CGRectGetMaxY(infoCard.frame) + 16, cardW, copyrightH);

    UILabel *copyrightLabel = [copyrightCard viewWithTag:400];
    copyrightLabel.frame = CGRectMake(16, 0, cardW - 32, copyrightH);

    CGFloat totalH = CGRectGetMaxY(copyrightCard.frame) + 32;
    self.scrollView.contentSize = CGSizeMake(sw, totalH);
}

@end
