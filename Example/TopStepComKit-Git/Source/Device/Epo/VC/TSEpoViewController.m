//
//  TSEpoViewController.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/7/9.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSEpoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "TSEpoStatusCard.h"
#import "TSEpoConsoleView.h"

// ── 布局常量 ──────────────────────────────────────────────────────────────────
static const CGFloat kCardCornerR = 12.f;
static const CGFloat kCardPad     = 16.f;
static const CGFloat kGap         = 16.f;
static const CGFloat kBtnH        = 52.f;
static const CGFloat kSubBtnH     = 48.f;
static const CGFloat kRingSize    = 140.f;
static const CGFloat kRingLineW   = 8.f;

// 更新状态机
typedef NS_ENUM(NSInteger, TSEpoUpdateState) {
    TSEpoUpdateStateIdle = 0,   // 入口态
    TSEpoUpdateStatePushing,    // 更新中
};

// 待选文件对应的来源类型（文件选择器回调时区分构造哪种 source）
typedef NS_ENUM(NSInteger, TSEpoPendingSource) {
    TSEpoPendingNone = 0,
    TSEpoPendingFileURLs,
    TSEpoPendingBinFile,
};

@interface TSEpoViewController ()

@property (nonatomic, strong) UIScrollView    *scrollView;
@property (nonatomic, strong) TSEpoStatusCard *statusCard;
@property (nonatomic, strong) TSEpoConsoleView *consoleView;

// 更新区
@property (nonatomic, strong) UIView    *updateCard;
@property (nonatomic, strong) UILabel   *updateTitleLabel;
@property (nonatomic, strong) UIButton  *oneKeyButton;
@property (nonatomic, strong) UILabel   *forceLabel;
@property (nonatomic, strong) UISwitch  *forceSwitch;
@property (nonatomic, strong) UIButton  *advHeaderButton;
@property (nonatomic, strong) UILabel   *advNoteLabel;
@property (nonatomic, strong) UIButton  *customServerButton;
@property (nonatomic, strong) UIButton  *fileURLsButton;
@property (nonatomic, strong) UIButton  *binFileButton;
// 进度态
@property (nonatomic, strong) UIView       *progressContainer;
@property (nonatomic, strong) CAShapeLayer *progressRingBg;
@property (nonatomic, strong) CAShapeLayer *progressRingFg;
@property (nonatomic, strong) UILabel      *percentLabel;
@property (nonatomic, strong) UILabel      *progressStatusLabel;
@property (nonatomic, strong) UIButton     *cancelButton;

// 状态
@property (nonatomic, assign) TSEpoUpdateState   updateState;
@property (nonatomic, assign) BOOL               advExpanded;
@property (nonatomic, assign) NSInteger          currentProgress;
@property (nonatomic, assign) TSEpoPendingSource pendingSource;

@end

@implementation TSEpoViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self transitionToState:TSEpoUpdateStateIdle];
    [self fetchEpoStatus];
}

- (void)initData {
    [super initData];
    self.title       = TSLocalizedString(@"epo.page_title");
    _updateState     = TSEpoUpdateStateIdle;
    _advExpanded     = NO;
    _currentProgress = 0;
    _pendingSource   = TSEpoPendingNone;
}

- (void)setupViews {
    __weak typeof(self) weakSelf = self;
    [self.view addSubview:self.scrollView];

    // ① 状态卡片
    self.statusCard.onRefresh = ^{ [weakSelf fetchEpoStatus]; };
    self.statusCard.onClear   = ^{ [weakSelf confirmAndClearEpo]; };
    [self.scrollView addSubview:self.statusCard];

    // ② 更新区
    [self.scrollView addSubview:self.updateCard];
    [self.updateCard addSubview:self.updateTitleLabel];
    [self.updateCard addSubview:self.oneKeyButton];
    [self.updateCard addSubview:self.forceLabel];
    [self.updateCard addSubview:self.forceSwitch];
    [self.updateCard addSubview:self.advHeaderButton];
    [self.updateCard addSubview:self.advNoteLabel];
    [self.updateCard addSubview:self.customServerButton];
    [self.updateCard addSubview:self.fileURLsButton];
    [self.updateCard addSubview:self.binFileButton];
    [self.updateCard addSubview:self.progressContainer];
    [self.progressContainer.layer addSublayer:self.progressRingBg];
    [self.progressContainer.layer addSublayer:self.progressRingFg];
    [self.progressContainer addSubview:self.percentLabel];
    [self.updateCard addSubview:self.progressStatusLabel];
    [self.updateCard addSubview:self.cancelButton];

    // ③ 控制台
    [self.scrollView addSubview:self.consoleView];
}

- (void)layoutViews {
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    if (screenW <= 0) return;

    CGFloat topInset = self.ts_navigationBarTotalHeight;
    if (topInset <= 0) topInset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = MAX(self.view.safeAreaInsets.bottom, kCardPad);
    CGFloat cardW = screenW - kCardPad * 2;

    self.scrollView.frame = CGRectMake(0, topInset, screenW, CGRectGetHeight(self.view.bounds) - topInset);

    CGFloat y = kCardPad;

    CGFloat statusH = [TSEpoStatusCard cardHeightForWidth:cardW];
    self.statusCard.frame = CGRectMake(kCardPad, y, cardW, statusH);
    y += statusH + kGap;

    CGFloat updateH = [self layoutUpdateCardAtY:y cardW:cardW];
    y += updateH + kGap;

    CGFloat consoleH = [TSEpoConsoleView cardHeight];
    self.consoleView.frame = CGRectMake(kCardPad, y, cardW, consoleH);
    y += consoleH + kCardPad + bottomInset;

    self.scrollView.contentSize = CGSizeMake(screenW, y);
}

// 更新区布局，返回卡片高度（随入口态/进度态、高级区展开与否变化）
- (CGFloat)layoutUpdateCardAtY:(CGFloat)y cardW:(CGFloat)cardW {
    CGFloat p = kCardPad;
    CGFloat innerW = cardW - p * 2;
    self.updateTitleLabel.frame = CGRectMake(p, 14.f, innerW, 18.f);
    CGFloat contentTop = 42.f;
    CGFloat cardH;

    if (self.updateState == TSEpoUpdateStatePushing) {
        CGFloat ringX = (cardW - kRingSize) / 2.f;
        self.progressContainer.frame = CGRectMake(ringX, contentTop, kRingSize, kRingSize);
        self.percentLabel.frame = self.progressContainer.bounds;
        [self layoutProgressRing];

        CGFloat statusY = contentTop + kRingSize + 12.f;
        self.progressStatusLabel.frame = CGRectMake(p, statusY, innerW, 22.f);
        CGFloat btnY = statusY + 22.f + 16.f;
        self.cancelButton.frame = CGRectMake(p, btnY, innerW, kBtnH);
        self.cancelButton.layer.cornerRadius = kBtnH / 2.f;
        cardH = btnY + kBtnH + 16.f;
    } else {
        self.oneKeyButton.frame = CGRectMake(p, contentTop, innerW, kBtnH);
        self.oneKeyButton.layer.cornerRadius = kBtnH / 2.f;

        CGFloat forceY = contentTop + kBtnH + 14.f;
        self.forceLabel.frame  = CGRectMake(p, forceY, innerW - 60.f, 40.f);
        self.forceSwitch.frame = CGRectMake(cardW - p - 51.f, forceY + 5.f, 51.f, 31.f);

        CGFloat advY = forceY + 40.f + 12.f;
        self.advHeaderButton.frame = CGRectMake(p, advY, innerW, 22.f);

        if (self.advExpanded) {
            CGFloat noteY = advY + 22.f + 6.f;
            CGSize noteSize = [self.advNoteLabel sizeThatFits:CGSizeMake(innerW, CGFLOAT_MAX)];
            self.advNoteLabel.frame = CGRectMake(p, noteY, innerW, noteSize.height);

            CGFloat sbY = noteY + noteSize.height + 10.f;
            self.customServerButton.frame = CGRectMake(p, sbY, innerW, kSubBtnH);
            self.fileURLsButton.frame     = CGRectMake(p, sbY + kSubBtnH + 10.f, innerW, kSubBtnH);
            self.binFileButton.frame      = CGRectMake(p, sbY + (kSubBtnH + 10.f) * 2, innerW, kSubBtnH);
            for (UIButton *button in @[self.customServerButton, self.fileURLsButton, self.binFileButton]) {
                button.layer.cornerRadius = kCardCornerR;
            }
            cardH = sbY + (kSubBtnH + 10.f) * 2 + kSubBtnH + 16.f;
        } else {
            cardH = advY + 22.f + 16.f;
        }
    }

    self.updateCard.frame = CGRectMake(kCardPad, y, cardW, cardH);
    self.updateCard.layer.cornerRadius = kCardCornerR;
    return cardH;
}

- (void)layoutProgressRing {
    CGFloat radius = (kRingSize - kRingLineW) / 2.f;
    CGPoint center = CGPointMake(kRingSize / 2.f, kRingSize / 2.f);
    CGRect pathRect = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:pathRect];
    self.progressRingBg.path = path.CGPath;
    self.progressRingFg.path = path.CGPath;
    self.progressRingBg.frame = self.progressContainer.bounds;
    self.progressRingFg.frame = self.progressContainer.bounds;
}

#pragma mark - 状态机

/**
 * 切换入口态/进度态，控制两组视图显隐并重新布局
 */
- (void)transitionToState:(TSEpoUpdateState)state {
    self.updateState = state;
    BOOL pushing = (state == TSEpoUpdateStatePushing);

    self.oneKeyButton.hidden       = pushing;
    self.forceLabel.hidden         = pushing;
    self.forceSwitch.hidden        = pushing;
    self.advHeaderButton.hidden    = pushing;
    self.advNoteLabel.hidden       = pushing || !self.advExpanded;
    self.customServerButton.hidden = pushing || !self.advExpanded;
    self.fileURLsButton.hidden     = pushing || !self.advExpanded;
    self.binFileButton.hidden      = pushing || !self.advExpanded;

    self.progressContainer.hidden   = !pushing;
    self.progressStatusLabel.hidden = !pushing;
    self.cancelButton.hidden        = !pushing;

    self.updateTitleLabel.text = pushing ? TSLocalizedString(@"epo.updating_title")
                                         : TSLocalizedString(@"epo.update_title");
    if (pushing) {
        [self updateProgressRing];
    }
    [self.view setNeedsLayout];
}

- (void)updateProgressRing {
    self.progressRingFg.strokeEnd = self.currentProgress / 100.f;
    self.percentLabel.text = [NSString stringWithFormat:@"%ld%%", (long)self.currentProgress];
}

#pragma mark - 动作

- (void)onForceSwitchChanged {
    [self.consoleView appendLog:[NSString stringWithFormat:@"forceUpdate = %@", self.forceSwitch.isOn ? @"YES" : @"NO"]
                           type:TSEpoLogTypeInfo];
}

/**
 * 展开/收起高级来源区
 */
- (void)onAdvHeaderTapped {
    self.advExpanded = !self.advExpanded;
    NSString *arrow = self.advExpanded ? @"▾" : @"▸";
    [self.advHeaderButton setTitle:[NSString stringWithFormat:@"%@ %@", arrow, TSLocalizedString(@"epo.advanced")]
                          forState:UIControlStateNormal];
    self.advNoteLabel.hidden       = !self.advExpanded;
    self.customServerButton.hidden = !self.advExpanded;
    self.fileURLsButton.hidden     = !self.advExpanded;
    self.binFileButton.hidden      = !self.advExpanded;
    [self.view setNeedsLayout];
}

- (void)onOneKeyButtonTapped {
    [self startUpdateWithSource:[TSEpoSource builtinServer] label:TSLocalizedString(@"epo.source.onekey")];
}

/**
 * 自定义服务器：弹窗输入 baseURL
 */
- (void)onCustomServerButtonTapped {
    __weak typeof(self) weakSelf = self;
    [self presentInputAlertWithTitle:TSLocalizedString(@"epo.source.custom_server")
                             message:TSLocalizedString(@"epo.custom_server.hint")
                         placeholder:@"https://epo.example.com"
                             confirm:^(NSString *text) {
        if (text.length == 0) {
            [weakSelf showToast:TSLocalizedString(@"epo.custom_server.empty") success:NO];
            return;
        }
        [weakSelf startUpdateWithSource:[TSEpoSource customServerWithBaseURL:text]
                                  label:TSLocalizedString(@"epo.source.custom_server")];
    }];
}

- (void)onFileURLsButtonTapped {
    self.pendingSource = TSEpoPendingFileURLs;
    [self presentDocumentPicker];
}

- (void)onBinFileButtonTapped {
    self.pendingSource = TSEpoPendingBinFile;
    [self presentDocumentPicker];
}

- (void)onCancelButtonTapped {
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] epo] cancelEpoUpdate:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.consoleView appendLog:@"cancelEpoUpdate · 已取消" type:TSEpoLogTypeError];
            [weakSelf showToast:TSLocalizedString(@"epo.canceled") success:NO];
            [weakSelf transitionToState:TSEpoUpdateStateIdle];
        });
    }];
}

/**
 * 清除设备 EPO（调试），二次确认后执行
 */
- (void)confirmAndClearEpo {
    __weak typeof(self) weakSelf = self;
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"epo.clear.confirm_title")
                                                                  message:TSLocalizedString(@"epo.clear.confirm_msg")
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"epo.cancel")
                                              style:UIAlertActionStyleCancel handler:nil]];
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"epo.clear.confirm_ok")
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
        [[[TopStepComKit sharedInstance] epo] clearEpo:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [weakSelf.consoleView appendLog:@"clearEpo · 成功" type:TSEpoLogTypeInfo];
                    [weakSelf showToast:TSLocalizedString(@"epo.clear.done") success:YES];
                    [weakSelf.statusCard renderUnknown];
                } else {
                    [weakSelf.consoleView appendLog:[NSString stringWithFormat:@"clearEpo · 失败 %@", error.localizedDescription ?: @""] type:TSEpoLogTypeError];
                    [weakSelf showToast:error.localizedDescription ?: TSLocalizedString(@"epo.clear.fail") success:NO];
                }
            });
        }];
    }]];
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - EPO 核心

/**
 * 统一更新入口：所有来源都走 updateEpoWithSource:forceUpdate:progress:success:failure:
 */
- (void)startUpdateWithSource:(TSEpoSource *)source label:(NSString *)label {
    BOOL force = self.forceSwitch.isOn;
    [self.consoleView appendLog:[NSString stringWithFormat:@"updateEpoWithSource: %@ forceUpdate:%@", label, force ? @"YES" : @"NO"]
                           type:TSEpoLogTypeInfo];

    self.currentProgress = 0;
    [self transitionToState:TSEpoUpdateStatePushing];
    self.progressStatusLabel.text = TSLocalizedString(@"epo.status.preparing");

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] epo] updateEpoWithSource:source
        forceUpdate:force
        progress:^(TSFileTransferStatus state, NSInteger progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.currentProgress = progress;
                [weakSelf updateProgressRing];
                weakSelf.progressStatusLabel.text = [NSString stringWithFormat:@"%@ %ld%%", TSLocalizedString(@"epo.status.updating"), (long)progress];
            });
        }
        success:^(TSFileTransferStatus state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.consoleView appendLog:[NSString stringWithFormat:@"%@ · success（EPO 已生效）", label] type:TSEpoLogTypeSuccess];
                [weakSelf showToast:TSLocalizedString(@"epo.update.success") success:YES];
                [weakSelf transitionToState:TSEpoUpdateStateIdle];
                [weakSelf fetchEpoStatus];
            });
        }
        failure:^(TSFileTransferStatus state, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf handleUpdateFailureWithState:state error:error label:label];
            });
        }];
}

/**
 * 失败回调分流：eTSErrorNotNecessary 视为成功（已是最新），取消/真失败各自处理
 */
- (void)handleUpdateFailureWithState:(TSFileTransferStatus)state error:(NSError *)error label:(NSString *)label {
    if (error.code == eTSErrorNotNecessary) {
        // 当天已更新，星历已是最新，按成功处理，不向用户报错
        [self.consoleView appendLog:@"failure: eTSErrorNotNecessary（当成功处理，已是最新）" type:TSEpoLogTypeWarning];
        [self showToast:TSLocalizedString(@"epo.update.not_necessary") success:YES];
        [self transitionToState:TSEpoUpdateStateIdle];
        [self fetchEpoStatus];
        return;
    }

    if (state == eTSFileTransferStatusCanceled) {
        [self.consoleView appendLog:@"failure · 已取消" type:TSEpoLogTypeError];
        [self showToast:TSLocalizedString(@"epo.canceled") success:NO];
        [self transitionToState:TSEpoUpdateStateIdle];
        return;
    }

    NSString *msg = error.localizedDescription ?: TSLocalizedString(@"epo.update.fail");
    [self.consoleView appendLog:[NSString stringWithFormat:@"%@ · failure code=%ld %@", label, (long)error.code, msg] type:TSEpoLogTypeError];
    [self showToast:msg success:NO];
    [self transitionToState:TSEpoUpdateStateIdle];
}

/**
 * 查询设备 EPO 时间信息，有效性由状态卡片依 validDate 计算
 */
- (void)fetchEpoStatus {
    [self.consoleView appendLog:@"fetchEpoTimeInfo · 查询中" type:TSEpoLogTypeInfo];
    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] epo] fetchEpoTimeInfo:^(TSEpoTimeInfo * _Nullable info, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!info || error) {
                [weakSelf.consoleView appendLog:[NSString stringWithFormat:@"fetchEpoTimeInfo · 未知 %@", error.localizedDescription ?: @""] type:TSEpoLogTypeInfo];
                [weakSelf.statusCard renderUnknown];
                return;
            }
            [weakSelf.statusCard renderWithInfo:info];
            [weakSelf.consoleView appendLog:@"fetchEpoTimeInfo · 成功" type:TSEpoLogTypeSuccess];
        });
    }];
}

#pragma mark - UIDocumentPickerDelegate

- (void)presentDocumentPicker {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"]
                                                                                                   inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) {
        [self showToast:TSLocalizedString(@"epo.no_file") success:NO];
        self.pendingSource = TSEpoPendingNone;
        return;
    }

    if (self.pendingSource == TSEpoPendingBinFile) {
        NSString *path = urls.firstObject.path;
        [self.consoleView appendLog:[NSString stringWithFormat:@"binFile: %@", path.lastPathComponent] type:TSEpoLogTypeInfo];
        [self startUpdateWithSource:[TSEpoSource binFile:path] label:TSLocalizedString(@"epo.source.bin_file")];
    } else if (self.pendingSource == TSEpoPendingFileURLs) {
        // demo：所选文件按顺序依次绑定 GPS/GLO/GALILEO... 星座类型
        NSMutableArray<NSNumber *> *types = [NSMutableArray array];
        for (NSUInteger idx = 0; idx < urls.count; idx++) {
            [types addObject:@(idx)];
        }
        [self.consoleView appendLog:[NSString stringWithFormat:@"fileURLs: %lu 个文件 + 星座类型", (unsigned long)urls.count] type:TSEpoLogTypeInfo];
        [self startUpdateWithSource:[TSEpoSource fileURLs:urls types:types] label:TSLocalizedString(@"epo.source.file_urls")];
    }
    self.pendingSource = TSEpoPendingNone;
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    self.pendingSource = TSEpoPendingNone;
}

#pragma mark - 弹窗与 Toast

/**
 * 单输入框弹窗，确定时回调输入内容
 */
- (void)presentInputAlertWithTitle:(NSString *)title
                           message:(NSString *)message
                       placeholder:(NSString *)placeholder
                           confirm:(void(^)(NSString *text))confirm {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                  message:message
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = placeholder;
        textField.text = placeholder;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"epo.cancel")
                                              style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"epo.start")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        NSString *text = [alert.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (confirm) confirm(text ?: @"");
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 顶部轻提示（复用 FileOTA 风格）
 */
- (void)showToast:(NSString *)message success:(BOOL)success {
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = success
        ? [TSColor_Success colorWithAlphaComponent:0.92f]
        : [[UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1.f] colorWithAlphaComponent:0.88f];
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

    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1.f; } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 0; } completion:^(BOOL done) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - 属性（懒加载）

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = TSColor_Background;
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (TSEpoStatusCard *)statusCard {
    if (!_statusCard) {
        _statusCard = [[TSEpoStatusCard alloc] initWithFrame:CGRectZero];
    }
    return _statusCard;
}

- (TSEpoConsoleView *)consoleView {
    if (!_consoleView) {
        _consoleView = [[TSEpoConsoleView alloc] initWithFrame:CGRectZero];
    }
    return _consoleView;
}

- (UIView *)updateCard {
    if (!_updateCard) {
        _updateCard = [[UIView alloc] init];
        _updateCard.backgroundColor = TSColor_Card;
        _updateCard.layer.shadowColor = [UIColor blackColor].CGColor;
        _updateCard.layer.shadowOpacity = 0.05f;
        _updateCard.layer.shadowOffset = CGSizeMake(0, 2);
        _updateCard.layer.shadowRadius = 6.f;
    }
    return _updateCard;
}

- (UILabel *)updateTitleLabel {
    if (!_updateTitleLabel) {
        _updateTitleLabel = [[UILabel alloc] init];
        _updateTitleLabel.text = TSLocalizedString(@"epo.update_title");
        _updateTitleLabel.font = TSFont_Body;
        _updateTitleLabel.textColor = TSColor_TextSecondary;
    }
    return _updateTitleLabel;
}

- (UIButton *)oneKeyButton {
    if (!_oneKeyButton) {
        _oneKeyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_oneKeyButton setTitle:TSLocalizedString(@"epo.source.onekey") forState:UIControlStateNormal];
        [_oneKeyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _oneKeyButton.titleLabel.font = TSFont_H2;
        _oneKeyButton.backgroundColor = TSColor_Primary;
        [_oneKeyButton addTarget:self action:@selector(onOneKeyButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _oneKeyButton;
}

- (UILabel *)forceLabel {
    if (!_forceLabel) {
        _forceLabel = [[UILabel alloc] init];
        _forceLabel.numberOfLines = 2;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:TSLocalizedString(@"epo.force_update")
            attributes:@{NSFontAttributeName: TSFont_Body, NSForegroundColorAttributeName: TSColor_TextPrimary}];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingString:TSLocalizedString(@"epo.force_update.hint")]
            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.f], NSForegroundColorAttributeName: TSColor_TextSecondary}]];
        _forceLabel.attributedText = text;
    }
    return _forceLabel;
}

- (UISwitch *)forceSwitch {
    if (!_forceSwitch) {
        _forceSwitch = [[UISwitch alloc] init];
        _forceSwitch.on = YES;   // 用户手动点击语义，默认强制更新
        _forceSwitch.onTintColor = TSColor_Success;
        [_forceSwitch addTarget:self action:@selector(onForceSwitchChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _forceSwitch;
}

- (UIButton *)advHeaderButton {
    if (!_advHeaderButton) {
        _advHeaderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_advHeaderButton setTitle:[NSString stringWithFormat:@"▸ %@", TSLocalizedString(@"epo.advanced")] forState:UIControlStateNormal];
        [_advHeaderButton setTitleColor:TSColor_TextPrimary forState:UIControlStateNormal];
        _advHeaderButton.titleLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightSemibold];
        _advHeaderButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_advHeaderButton addTarget:self action:@selector(onAdvHeaderTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _advHeaderButton;
}

- (UILabel *)advNoteLabel {
    if (!_advNoteLabel) {
        _advNoteLabel = [[UILabel alloc] init];
        _advNoteLabel.text = TSLocalizedString(@"epo.advanced.note");
        _advNoteLabel.font = [UIFont systemFontOfSize:11.f];
        _advNoteLabel.textColor = TSColor_Warning;
        _advNoteLabel.numberOfLines = 0;
        _advNoteLabel.hidden = YES;
    }
    return _advNoteLabel;
}

- (UIButton *)customServerButton {
    if (!_customServerButton) {
        _customServerButton = [self makeSubButtonWithTitle:TSLocalizedString(@"epo.source.custom_server")
                                                  subtitle:@"customServerWithBaseURL:"
                                                    action:@selector(onCustomServerButtonTapped)];
        _customServerButton.hidden = YES;
    }
    return _customServerButton;
}

- (UIButton *)fileURLsButton {
    if (!_fileURLsButton) {
        _fileURLsButton = [self makeSubButtonWithTitle:TSLocalizedString(@"epo.source.file_urls")
                                              subtitle:@"fileURLs:types:"
                                                action:@selector(onFileURLsButtonTapped)];
        _fileURLsButton.hidden = YES;
    }
    return _fileURLsButton;
}

- (UIButton *)binFileButton {
    if (!_binFileButton) {
        _binFileButton = [self makeSubButtonWithTitle:TSLocalizedString(@"epo.source.bin_file")
                                             subtitle:@"binFile:"
                                               action:@selector(onBinFileButtonTapped)];
        _binFileButton.hidden = YES;
    }
    return _binFileButton;
}

- (UIView *)progressContainer {
    if (!_progressContainer) {
        _progressContainer = [[UIView alloc] init];
        _progressContainer.backgroundColor = [UIColor clearColor];
        _progressContainer.hidden = YES;
    }
    return _progressContainer;
}

- (CAShapeLayer *)progressRingBg {
    if (!_progressRingBg) {
        _progressRingBg = [CAShapeLayer layer];
        _progressRingBg.fillColor = [UIColor clearColor].CGColor;
        _progressRingBg.strokeColor = TSColor_Separator.CGColor;
        _progressRingBg.lineWidth = kRingLineW;
        _progressRingBg.strokeEnd = 1.f;
    }
    return _progressRingBg;
}

- (CAShapeLayer *)progressRingFg {
    if (!_progressRingFg) {
        _progressRingFg = [CAShapeLayer layer];
        _progressRingFg.fillColor = [UIColor clearColor].CGColor;
        _progressRingFg.strokeColor = TSColor_Primary.CGColor;
        _progressRingFg.lineWidth = kRingLineW;
        _progressRingFg.lineCap = kCALineCapRound;
        _progressRingFg.strokeEnd = 0.f;
        _progressRingFg.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
    }
    return _progressRingFg;
}

- (UILabel *)percentLabel {
    if (!_percentLabel) {
        _percentLabel = [[UILabel alloc] init];
        _percentLabel.font = [UIFont systemFontOfSize:30.f weight:UIFontWeightSemibold];
        _percentLabel.textColor = TSColor_TextPrimary;
        _percentLabel.textAlignment = NSTextAlignmentCenter;
        _percentLabel.text = @"0%";
    }
    return _percentLabel;
}

- (UILabel *)progressStatusLabel {
    if (!_progressStatusLabel) {
        _progressStatusLabel = [[UILabel alloc] init];
        _progressStatusLabel.font = TSFont_Body;
        _progressStatusLabel.textColor = TSColor_TextSecondary;
        _progressStatusLabel.textAlignment = NSTextAlignmentCenter;
        _progressStatusLabel.hidden = YES;
    }
    return _progressStatusLabel;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:TSLocalizedString(@"epo.cancel") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:TSColor_Danger forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = TSFont_H2;
        _cancelButton.backgroundColor = [UIColor clearColor];
        _cancelButton.layer.borderWidth = 1.f;
        _cancelButton.layer.borderColor = TSColor_Separator.CGColor;
        _cancelButton.hidden = YES;
        [_cancelButton addTarget:self action:@selector(onCancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

#pragma mark - 私有工厂

/**
 * 创建高级来源的次级按钮（左对齐，主标题 + 灰色副标题）
 */
- (UIButton *)makeSubButtonWithTitle:(NSString *)title subtitle:(NSString *)subtitle action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.borderWidth = 1.f;
    button.layer.borderColor = TSColor_Separator.CGColor;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 14.f, 0, 14.f);

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title
        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium],
                     NSForegroundColorAttributeName: TSColor_TextPrimary}];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:[@"\n" stringByAppendingString:subtitle]
        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11.f],
                     NSForegroundColorAttributeName: TSColor_TextSecondary}]];
    button.titleLabel.numberOfLines = 2;
    [button setAttributedTitle:text forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
