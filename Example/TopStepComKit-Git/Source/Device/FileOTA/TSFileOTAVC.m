//
//  TSFileOTAVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/17.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSFileOTAVC.h"
#import <QuartzCore/QuartzCore.h>

// ── 布局常量 ──────────────────────────────────────────────────────────────────
static const CGFloat kCardCornerR   = 12.f;
static const CGFloat kCardPad       = 16.f;
static const CGFloat kRingSize      = 140.f;   // 圆环外径
static const CGFloat kRingLineW     = 8.f;     // 圆环线宽
static const CGFloat kBtnH         = 52.f;

// 四态枚举
typedef NS_ENUM(NSInteger, TSOTAState) {
    TSOTAStateIdle      = 0,  // 空闲，等待选择文件
    TSOTAStateUpgrading,      // 升级中
    TSOTAStateSuccess,        // 成功
    TSOTAStateFailure,        // 失败（含取消）
};

@interface TSFileOTAVC () <UIDocumentPickerDelegate>

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIView        *cardView;

// 空闲态
@property (nonatomic, strong) UILabel       *descLabel;
@property (nonatomic, strong) UIButton      *selectButton;

// 升级态：圆环 + 中间百分比 + 状态文案 + 取消按钮
@property (nonatomic, strong) UIView        *progressRingContainer;
@property (nonatomic, strong) CAShapeLayer   *progressRingBg;
@property (nonatomic, strong) CAShapeLayer   *progressRingFg;
@property (nonatomic, strong) UILabel       *percentLabel;
@property (nonatomic, strong) UILabel       *statusLabel;
@property (nonatomic, strong) UIButton      *cancelButton;

// 成功态
@property (nonatomic, strong) UILabel       *successIconLabel;
@property (nonatomic, strong) UILabel       *successTextLabel;
@property (nonatomic, strong) UIButton      *retryButton;

// 失败态
@property (nonatomic, strong) UILabel       *failureIconLabel;
@property (nonatomic, strong) UILabel       *failureTextLabel;
@property (nonatomic, strong) UIButton      *retryAfterFailButton;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UIDocumentPickerViewController *documentPicker;

@property (nonatomic, assign) TSOTAState    otaState;
@property (nonatomic, assign) NSInteger     currentProgress;
/// 失败/取消时完整错误信息，用于 Toast 展示
@property (nonatomic, copy)   NSString     *lastErrorMessage;

@end

@implementation TSFileOTAVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self transitionToState:TSOTAStateIdle];
}

#pragma mark - Override Base Setup

- (void)initData {
    [super initData];
    self.title   = @"文件 OTA 升级";
    _otaState    = TSOTAStateIdle;
    _currentProgress = 0;
}

- (void)setupViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.cardView];

    [self.cardView addSubview:self.descLabel];
    [self.cardView addSubview:self.selectButton];

    [self.cardView addSubview:self.progressRingContainer];
    [self.progressRingContainer.layer addSublayer:self.progressRingBg];
    [self.progressRingContainer.layer addSublayer:self.progressRingFg];
    [self.progressRingContainer addSubview:self.percentLabel];
    [self.cardView addSubview:self.statusLabel];
    [self.cardView addSubview:self.cancelButton];

    [self.cardView addSubview:self.successIconLabel];
    [self.cardView addSubview:self.successTextLabel];
    [self.cardView addSubview:self.retryButton];

    [self.cardView addSubview:self.failureIconLabel];
    [self.cardView addSubview:self.failureTextLabel];
    [self.cardView addSubview:self.retryAfterFailButton];

    [self.view addSubview:self.loadingIndicator];
}

- (void)layoutViews {
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);
    if (screenW <= 0) return;

    CGFloat topInset = self.ts_navigationBarTotalHeight;
    if (topInset <= 0) topInset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = MAX(self.view.safeAreaInsets.bottom, kCardPad);

    self.scrollView.frame = CGRectMake(0, topInset, screenW, screenH - topInset);

    CGFloat cardW = screenW - kCardPad * 2;
    CGFloat cardH = 320.f;
    self.cardView.frame = CGRectMake(kCardPad, kCardPad, cardW, cardH);
    self.cardView.layer.cornerRadius = kCardCornerR;

    // 各态布局
    [self layoutIdleWithCardW:cardW cardH:cardH];
    [self layoutUpgradingWithCardW:cardW cardH:cardH];
    [self layoutResultWithCardW:cardW cardH:cardH];

    self.scrollView.contentSize = CGSizeMake(screenW, cardH + kCardPad * 2 + bottomInset);
    self.loadingIndicator.center = CGPointMake(screenW / 2.f, (screenH - topInset) / 2.f + topInset);
}

- (void)layoutIdleWithCardW:(CGFloat)cardW cardH:(CGFloat)cardH {
    self.descLabel.frame = CGRectMake(kCardPad, 24.f, cardW - kCardPad * 2, 48.f);
    self.selectButton.frame = CGRectMake(kCardPad, cardH - kBtnH - 24.f, cardW - kCardPad * 2, kBtnH);
    self.selectButton.layer.cornerRadius = kBtnH / 2.f;
}

- (void)layoutUpgradingWithCardW:(CGFloat)cardW cardH:(CGFloat)cardH {
    CGFloat ringX = (cardW - kRingSize) / 2.f;
    self.progressRingContainer.frame = CGRectMake(ringX, 24.f, kRingSize, kRingSize);
    self.percentLabel.frame = self.progressRingContainer.bounds;

    CGFloat radius = (kRingSize - kRingLineW) / 2.f;
    CGPoint center = CGPointMake(kRingSize / 2.f, kRingSize / 2.f);
    CGRect pathRect = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
    self.progressRingBg.path = path.CGPath;
    self.progressRingFg.path = path.CGPath;

    self.progressRingBg.frame = self.progressRingContainer.bounds;
    self.progressRingFg.frame = self.progressRingContainer.bounds;

    self.statusLabel.frame = CGRectMake(kCardPad, 24.f + kRingSize + 12.f, cardW - kCardPad * 2, 24.f);
    self.cancelButton.frame = CGRectMake(kCardPad, cardH - kBtnH - 24.f, cardW - kCardPad * 2, kBtnH);
    self.cancelButton.layer.cornerRadius = kBtnH / 2.f;
}

- (void)layoutResultWithCardW:(CGFloat)cardW cardH:(CGFloat)cardH {
    CGFloat iconY = 48.f;
    self.successIconLabel.frame = CGRectMake(0, iconY, cardW, 56.f);
    self.failureIconLabel.frame = CGRectMake(0, iconY, cardW, 56.f);

    CGFloat textY = iconY + 56.f + 8.f;
    self.successTextLabel.frame = CGRectMake(kCardPad, textY, cardW - kCardPad * 2, 28.f);
    self.failureTextLabel.frame = CGRectMake(kCardPad, textY, cardW - kCardPad * 2, 28.f);

    CGFloat btnY = cardH - kBtnH - 24.f;
    self.retryButton.frame = CGRectMake(kCardPad, btnY, cardW - kCardPad * 2, kBtnH);
    self.retryButton.layer.cornerRadius = kBtnH / 2.f;
    self.retryAfterFailButton.frame = CGRectMake(kCardPad, btnY, cardW - kCardPad * 2, kBtnH);
    self.retryAfterFailButton.layer.cornerRadius = kBtnH / 2.f;
}

#pragma mark - State

- (void)transitionToState:(TSOTAState)state {
    self.otaState = state;

    self.descLabel.hidden           = (state != TSOTAStateIdle);
    self.selectButton.hidden        = (state != TSOTAStateIdle);

    self.progressRingContainer.hidden = (state != TSOTAStateUpgrading);
    self.statusLabel.hidden          = (state != TSOTAStateUpgrading);
    self.cancelButton.hidden         = (state != TSOTAStateUpgrading);

    self.successIconLabel.hidden    = (state != TSOTAStateSuccess);
    self.successTextLabel.hidden    = (state != TSOTAStateSuccess);
    self.retryButton.hidden         = (state != TSOTAStateSuccess);

    self.failureIconLabel.hidden    = (state != TSOTAStateFailure);
    self.failureTextLabel.hidden    = (state != TSOTAStateFailure);
    self.retryAfterFailButton.hidden = (state != TSOTAStateFailure);

    if (state == TSOTAStateUpgrading) {
        [self updateProgressRing];
    }
}

- (void)updateProgressRing {
    CGFloat ratio = self.currentProgress / 100.f;
    self.progressRingFg.strokeEnd = ratio;
    self.percentLabel.text = [NSString stringWithFormat:@"%ld%%", (long)self.currentProgress];
}

#pragma mark - Actions

- (void)selectButtonTapped {
    NSArray *types = @[@"public.data"];
    self.documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
    self.documentPicker.delegate = self;
    self.documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:self.documentPicker animated:YES completion:nil];
}

- (void)cancelButtonTapped {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] firmwareUpgrade] cancelFirmwareUpgrade:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.lastErrorMessage = error.localizedDescription ?: @"升级已取消";
            [weakSelf transitionToState:TSOTAStateFailure];
            [weakSelf showToast:weakSelf.lastErrorMessage success:NO];
        });
    }];
}

- (void)retryButtonTapped {
    [self transitionToState:TSOTAStateIdle];
}

- (void)retryAfterFailButtonTapped {
    [self transitionToState:TSOTAStateIdle];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) {
        [self showToast:@"未选择文件" success:NO];
        return;
    }
    NSURL *fileURL = urls.firstObject;
    NSString *filePath = fileURL.path;
    [self startOTAWithFilePath:filePath];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {}

#pragma mark - OTA

- (void)startOTAWithFilePath:(NSString *)filePath {
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    TSFileTransferModel *model = [TSFileTransferModel modelWithLocalFilePath:filePath];
    __weak typeof(self) weakSelf = self;

    [[[TopStepComKit sharedInstance] firmwareUpgrade] checkFirmwareUpgradeConditions:model completion:^(BOOL canUpgrade, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            weakSelf.scrollView.userInteractionEnabled = YES;

            if (!canUpgrade) {
                [weakSelf showToast:error.localizedDescription ?: @"无法升级" success:NO];
                return;
            }

            [weakSelf transitionToState:TSOTAStateUpgrading];
            weakSelf.currentProgress = 0;
            [weakSelf updateProgressRing];
            weakSelf.statusLabel.text = @"升级中...";

            [[[TopStepComKit sharedInstance] firmwareUpgrade] startFirmwareUpgrade:model
                progress:^(TSFileTransferStatus state, NSInteger progress) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.currentProgress = (NSInteger)progress;
                        [weakSelf updateProgressRing];
                        weakSelf.statusLabel.text = [NSString stringWithFormat:@"升级中... %ld%%", (long)progress];
                    });
                }
                success:^(TSFileTransferStatus state) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf transitionToState:TSOTAStateSuccess];
                        [weakSelf showToast:@"升级成功" success:YES];
                    });
                }
                failure:^(TSFileTransferStatus state, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.lastErrorMessage = error.localizedDescription ?: (state == eTSFileTransferStatusCanceled ? @"升级已取消" : @"升级失败");
                        [weakSelf transitionToState:TSOTAStateFailure];
                        [weakSelf showToast:weakSelf.lastErrorMessage success:NO];
                    });
                }];
        });
    }];
}

#pragma mark - Toast

- (void)showToast:(NSString *)message success:(BOOL)success {
    UIView *toast = [[UIView alloc] init];
    UIColor *bgColor = success
        ? [TSColor_Success colorWithAlphaComponent:0.92f]
        : [[UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1.f] colorWithAlphaComponent:0.88f];
    toast.backgroundColor = bgColor;
    toast.layer.cornerRadius = 10.f;
    toast.alpha = 0;

    UILabel *label = [[UILabel alloc] init];
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    CGFloat maxW = CGRectGetWidth(self.view.bounds) - 80.f;
    CGSize size = [label sizeThatFits:CGSizeMake(maxW - 32.f, CGFLOAT_MAX)];
    CGFloat toastW = MIN(size.width + 32.f, maxW);
    CGFloat toastH = size.height + 20.f;
    toast.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - toastW) / 2.f,
                              CGRectGetHeight(self.view.bounds) * 0.72f, toastW, toastH);
    label.frame = CGRectMake(16.f, 10.f, toastW - 32.f, size.height);
    [toast addSubview:label];
    [self.view addSubview:toast];

    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1.0f; } completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 0; } completion:^(BOOL done) {
                [toast removeFromSuperview];
            }];
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

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = TSColor_Card;
        _cardView.layer.shadowColor = [UIColor blackColor].CGColor;
        _cardView.layer.shadowOpacity = 0.05f;
        _cardView.layer.shadowOffset = CGSizeMake(0, 2);
        _cardView.layer.shadowRadius = 6.f;
    }
    return _cardView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = @"从「文件」App 选择固件包后开始升级，升级过程中请勿断开设备。";
        _descLabel.font = TSFont_Body;
        _descLabel.textColor = TSColor_TextSecondary;
        _descLabel.numberOfLines = 0;
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setTitle:@"选择固件并升级" forState:UIControlStateNormal];
        [_selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _selectButton.titleLabel.font = TSFont_H2;
        _selectButton.backgroundColor = TSColor_Primary;
        [_selectButton addTarget:self action:@selector(selectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}

- (UIView *)progressRingContainer {
    if (!_progressRingContainer) {
        _progressRingContainer = [[UIView alloc] init];
        _progressRingContainer.backgroundColor = [UIColor clearColor];
    }
    return _progressRingContainer;
}

- (CAShapeLayer *)progressRingBg {
    if (!_progressRingBg) {
        _progressRingBg = [CAShapeLayer layer];
        _progressRingBg.fillColor = [UIColor clearColor].CGColor;
        _progressRingBg.strokeColor = TSColor_Separator.CGColor;
        _progressRingBg.lineWidth = kRingLineW;
        _progressRingBg.strokeEnd = 1.0f;
    }
    return _progressRingBg;
}

- (CAShapeLayer *)progressRingFg {
    if (!_progressRingFg) {
        _progressRingFg = [CAShapeLayer layer];
        _progressRingFg.fillColor = [UIColor clearColor].CGColor;
        _progressRingFg.strokeColor = TSColor_Primary.CGColor;
        _progressRingFg.lineWidth = kRingLineW;
        _progressRingFg.strokeEnd = 0.f;
        _progressRingFg.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
    }
    return _progressRingFg;
}

- (UILabel *)percentLabel {
    if (!_percentLabel) {
        _percentLabel = [[UILabel alloc] init];
        _percentLabel.font = [UIFont systemFontOfSize:28.f weight:UIFontWeightSemibold];
        _percentLabel.textColor = TSColor_TextPrimary;
        _percentLabel.textAlignment = NSTextAlignmentCenter;
        _percentLabel.text = @"0%";
    }
    return _percentLabel;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = TSFont_Body;
        _statusLabel.textColor = TSColor_TextSecondary;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.text = @"升级中...";
    }
    return _statusLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"取消升级" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = TSFont_Body;
        _cancelButton.backgroundColor = [UIColor clearColor];
        _cancelButton.layer.borderColor = TSColor_Primary.CGColor;
        _cancelButton.layer.borderWidth = 1.5f;
        [_cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UILabel *)successIconLabel {
    if (!_successIconLabel) {
        _successIconLabel = [[UILabel alloc] init];
        _successIconLabel.text = @"✓";
        _successIconLabel.font = [UIFont systemFontOfSize:48.f weight:UIFontWeightLight];
        _successIconLabel.textColor = TSColor_Success;
        _successIconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _successIconLabel;
}

- (UILabel *)successTextLabel {
    if (!_successTextLabel) {
        _successTextLabel = [[UILabel alloc] init];
        _successTextLabel.text = @"升级成功";
        _successTextLabel.font = TSFont_H2;
        _successTextLabel.textColor = TSColor_TextPrimary;
        _successTextLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _successTextLabel;
}

- (UIButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryButton setTitle:@"再次升级" forState:UIControlStateNormal];
        [_retryButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _retryButton.titleLabel.font = TSFont_Body;
        _retryButton.backgroundColor = [UIColor clearColor];
        _retryButton.layer.borderColor = TSColor_Primary.CGColor;
        _retryButton.layer.borderWidth = 1.5f;
        [_retryButton addTarget:self action:@selector(retryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryButton;
}

- (UILabel *)failureIconLabel {
    if (!_failureIconLabel) {
        _failureIconLabel = [[UILabel alloc] init];
        _failureIconLabel.text = @"✗";
        _failureIconLabel.font = [UIFont systemFontOfSize:48.f weight:UIFontWeightLight];
        _failureIconLabel.textColor = TSColor_Danger;
        _failureIconLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _failureIconLabel;
}

- (UILabel *)failureTextLabel {
    if (!_failureTextLabel) {
        _failureTextLabel = [[UILabel alloc] init];
        _failureTextLabel.text = @"升级失败";
        _failureTextLabel.font = TSFont_H2;
        _failureTextLabel.textColor = TSColor_TextPrimary;
        _failureTextLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _failureTextLabel;
}

- (UIButton *)retryAfterFailButton {
    if (!_retryAfterFailButton) {
        _retryAfterFailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryAfterFailButton setTitle:@"重试" forState:UIControlStateNormal];
        [_retryAfterFailButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _retryAfterFailButton.titleLabel.font = TSFont_H2;
        _retryAfterFailButton.backgroundColor = TSColor_Primary;
        [_retryAfterFailButton addTarget:self action:@selector(retryAfterFailButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryAfterFailButton;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        if (@available(iOS 13.0, *)) {
            _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _loadingIndicator.hidesWhenStopped = YES;
    }
    return _loadingIndicator;
}

@end
