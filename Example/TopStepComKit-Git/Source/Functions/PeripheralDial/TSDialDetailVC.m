//
//  TSDialDetailVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSDialDetailVC.h"

static const CGFloat kDetailPad         = 32.f;
static const CGFloat kDetailBtnH        = 52.f;
static const CGFloat kDetailBtnCorner   = 14.f;
static const CGFloat kDetailImgCorner   = 16.f;
static const CGFloat kDetailToastDur    = 2.0f;
static const CGFloat kDetailFadeDur     = 0.25f;

@interface TSDialDetailVC ()

@property (nonatomic, strong) TSDialModel *dial;
@property (nonatomic, assign) BOOL        isCurrent;

@property (nonatomic, strong) UIScrollView            *scrollView;
@property (nonatomic, strong) UIView                  *imageCard;
@property (nonatomic, strong) UIImageView             *dialImageView;
@property (nonatomic, strong) UIView                  *placeholderView;
@property (nonatomic, strong) UILabel                 *placeholderLabel;
@property (nonatomic, strong) UIButton                *actionButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation TSDialDetailVC

#pragma mark - Init

- (instancetype)initWithDial:(TSDialModel *)dial isCurrent:(BOOL)isCurrent {
    self = [super init];
    if (!self) return nil;
    _dial      = dial;
    _isCurrent = isCurrent;
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDialImage];
    [self configureButton];
}

#pragma mark - Override Base Setup

/** 初始化标题 */
- (void)initData {
    [super initData];
    self.title = _dial.dialName.length ? _dial.dialName : @"表盘详情";
}

/** 构建视图层级 */
- (void)setupViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageCard];
    [self.imageCard addSubview:self.dialImageView];
    [self.imageCard addSubview:self.placeholderView];
    [self.placeholderView addSubview:self.placeholderLabel];
    [self.scrollView addSubview:self.actionButton];
    [self.view addSubview:self.loadingIndicator];
}

/** Frame 布局 */
- (void)layoutViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;
    self.scrollView.frame = CGRectMake(0, top, w, h - top);

    // 表盘图：宽占 60%，高 = 宽 × 1.42（竖向矩形表盘比例）
    CGFloat imgW = (w - kDetailPad * 2) * 0.6f;
    CGFloat imgH = imgW * 1.42f;
    CGFloat imgX = (w - imgW) / 2.f;
    self.imageCard.frame   = CGRectMake(imgX, kDetailPad, imgW, imgH);
    self.dialImageView.frame = self.imageCard.bounds;
    self.placeholderView.frame = self.imageCard.bounds;
    self.placeholderLabel.frame = CGRectInset(self.imageCard.bounds, 8, 8);

    CGFloat btnY = CGRectGetMaxY(self.imageCard.frame) + kDetailPad;
    self.actionButton.frame = CGRectMake(kDetailPad, btnY, w - kDetailPad * 2, kDetailBtnH);

    CGFloat contentH = CGRectGetMaxY(self.actionButton.frame) + kDetailPad
                       + self.view.safeAreaInsets.bottom;
    self.scrollView.contentSize = CGSizeMake(w, contentH);

    self.loadingIndicator.center = CGPointMake(w / 2.f, (h - top) / 2.f + top);
}

#pragma mark - UI Configuration

/** 根据 isCurrent 配置按钮外观与可交互性 */
- (void)configureButton {
    if (self.isCurrent) {
        [self.actionButton setTitle:@"当前表盘" forState:UIControlStateNormal];
        [self.actionButton setTitle:@"当前表盘" forState:UIControlStateDisabled];
        [self.actionButton setTitleColor:UIColor.whiteColor forState:UIControlStateDisabled];
        self.actionButton.backgroundColor = TSColor_TextSecondary;
        self.actionButton.enabled = NO;
    } else {
        [self.actionButton setTitle:@"设置为当前表盘" forState:UIControlStateNormal];
        [self.actionButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        self.actionButton.backgroundColor = TSColor_Primary;
        self.actionButton.enabled = YES;
    }
}

/** 从 filePath 加载表盘图，无图则展示占位视图 */
- (void)loadDialImage {
    UIImage *img = nil;
    if (self.dial.filePath.length > 0) {
        img = [UIImage imageWithContentsOfFile:self.dial.filePath];
    }
    if (img) {
        self.dialImageView.image = img;
        self.dialImageView.hidden    = NO;
        self.placeholderView.hidden  = YES;
    } else {
        self.dialImageView.hidden   = YES;
        self.placeholderView.hidden = NO;
        self.placeholderLabel.text  = self.dial.dialName.length ? self.dial.dialName : @"表盘";
        self.placeholderView.backgroundColor = [self placeholderColorForType:self.dial.dialType];
    }
}

/** 根据表盘类型返回占位背景色 */
- (UIColor *)placeholderColorForType:(TSDialType)type {
    switch (type) {
        case eTSDialTypeBuiltIn:  return TSColor_Indigo;
        case eTSDialTypeCloud:    return TSColor_Primary;
        case eTSDialTypeCustomer: return TSColor_Teal;
        default:                  return TSColor_Gray;
    }
}

#pragma mark - Actions

/** 切换为当前表盘 */
- (void)onSetCurrentTapped {
    [self.loadingIndicator startAnimating];
    self.actionButton.enabled = NO;

    __weak typeof(self) wself = self;
    [[[TopStepComKit sharedInstance] dial] switchToDial:self.dial completion:^(BOOL isSuccess, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.loadingIndicator stopAnimating];
            if (isSuccess) {
                wself.isCurrent = YES;
                [wself configureButton];
                if (wself.onDialSwitched) {
                    wself.onDialSwitched(wself.dial.dialId);
                }
                [wself showSuccessToast:@"已切换为当前表盘"];
            } else {
                wself.actionButton.enabled = YES;
                [wself showAlertWithMsg:error.localizedDescription ?: @"切换失败，请重试"];
            }
        });
    }];
}

/** 成功 Toast，显示约 2 秒后淡出 */
- (void)showSuccessToast:(NSString *)message {
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = [TSColor_Success colorWithAlphaComponent:0.92f];
    toast.layer.cornerRadius = 10.f;
    toast.alpha = 0;

    UILabel *label = [[UILabel alloc] init];
    label.text          = message;
    label.textColor     = UIColor.whiteColor;
    label.font          = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;

    CGFloat maxW = CGRectGetWidth(self.view.bounds) - 80.f;
    CGSize  sz   = [label sizeThatFits:CGSizeMake(maxW - 32.f, CGFLOAT_MAX)];
    CGFloat tw   = MIN(sz.width + 32.f, maxW);
    CGFloat th   = sz.height + 20.f;
    toast.frame  = CGRectMake((CGRectGetWidth(self.view.bounds) - tw) / 2.f,
                               CGRectGetHeight(self.view.bounds) * 0.72f, tw, th);
    label.frame  = CGRectMake(16.f, 10.f, tw - 32.f, sz.height);
    [toast addSubview:label];
    [self.view addSubview:toast];

    [UIView animateWithDuration:kDetailFadeDur animations:^{ toast.alpha = 1; } completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDetailToastDur * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:kDetailFadeDur animations:^{ toast.alpha = 0; }
                            completion:^(BOOL done) { [toast removeFromSuperview]; }];
        });
    }];
}

#pragma mark - Lazy

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = TSColor_Background;
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (UIView *)imageCard {
    if (!_imageCard) {
        _imageCard = [[UIView alloc] init];
        _imageCard.layer.cornerRadius  = kDetailImgCorner;
        _imageCard.clipsToBounds       = YES;
        _imageCard.layer.shadowColor   = UIColor.blackColor.CGColor;
        _imageCard.layer.shadowOpacity = 0.12f;
        _imageCard.layer.shadowOffset  = CGSizeMake(0, 4);
        _imageCard.layer.shadowRadius  = 12.f;
        _imageCard.backgroundColor     = TSColor_Card;
    }
    return _imageCard;
}

- (UIImageView *)dialImageView {
    if (!_dialImageView) {
        _dialImageView = [[UIImageView alloc] init];
        _dialImageView.contentMode = UIViewContentModeScaleAspectFill;
        _dialImageView.clipsToBounds = YES;
    }
    return _dialImageView;
}

- (UIView *)placeholderView {
    if (!_placeholderView) {
        _placeholderView = [[UIView alloc] init];
    }
    return _placeholderView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.textColor     = [UIColor colorWithWhite:1 alpha:0.85f];
        _placeholderLabel.font          = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _placeholderLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderLabel.numberOfLines = 3;
    }
    return _placeholderLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _actionButton.layer.cornerRadius = kDetailBtnCorner;
        _actionButton.titleLabel.font    = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [_actionButton addTarget:self action:@selector(onSetCurrentTapped)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        if (@available(iOS 13.0, *)) {
            _loadingIndicator = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _loadingIndicator = [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _loadingIndicator.hidesWhenStopped = YES;
    }
    return _loadingIndicator;
}

@end
