//
//  TSRemoteControlVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSRemoteControlVC.h"
#import <TopStepComKit/TopStepComKit.h>

static const CGFloat kCardCornerR   = 12.f;
static const CGFloat kCardPad       = 16.f;
static const CGFloat kRowH          = 56.f;
static const CGFloat kHeaderDescH   = 52.f;
static const CGFloat kToastDuration = 2.0f;
static const CGFloat kToastFadeOut  = 0.25f;

typedef NS_ENUM(NSInteger, TSRemoteAction) {
    TSRemoteActionShutdown     = 0,
    TSRemoteActionRestart,
    TSRemoteActionFactoryReset,
};

@interface TSRemoteControlVC ()

// 滚动容器
@property (nonatomic, strong) UIScrollView *scrollView;
// 操作卡片
@property (nonatomic, strong) UIView *cardView;
// 顶部说明文字
@property (nonatomic, strong) UILabel *descLabel;

// 关机行
@property (nonatomic, strong) UIView *rowShutdown;
@property (nonatomic, strong) UILabel *iconShutdown;
@property (nonatomic, strong) UILabel *titleShutdown;
@property (nonatomic, strong) UILabel *arrowShutdown;

// 重启行
@property (nonatomic, strong) UIView *rowRestart;
@property (nonatomic, strong) UILabel *iconRestart;
@property (nonatomic, strong) UILabel *titleRestart;
@property (nonatomic, strong) UILabel *arrowRestart;

// 恢复出厂设置行
@property (nonatomic, strong) UIView *rowFactoryReset;
@property (nonatomic, strong) UILabel *iconFactoryReset;
@property (nonatomic, strong) UILabel *titleFactoryReset;
@property (nonatomic, strong) UILabel *arrowFactoryReset;

// 无遮罩加载指示器
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation TSRemoteControlVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 公开方法

/**
 * 初始化标题，不添加父类 tableView
 */
- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"remote_control.title");
}

/**
 * 构建滚动容器、卡片、三行操作与无遮罩 loading
 */
- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.cardView];
    [self.cardView addSubview:self.descLabel];

    [self.cardView addSubview:self.rowShutdown];
    [self.rowShutdown addSubview:self.iconShutdown];
    [self.rowShutdown addSubview:self.titleShutdown];
    [self.rowShutdown addSubview:self.arrowShutdown];

    [self.cardView addSubview:self.rowRestart];
    [self.rowRestart addSubview:self.iconRestart];
    [self.rowRestart addSubview:self.titleRestart];
    [self.rowRestart addSubview:self.arrowRestart];

    [self.cardView addSubview:self.rowFactoryReset];
    [self.rowFactoryReset addSubview:self.iconFactoryReset];
    [self.rowFactoryReset addSubview:self.titleFactoryReset];
    [self.rowFactoryReset addSubview:self.arrowFactoryReset];

    [self.view addSubview:self.loadingIndicator];

    [self addTapToRow:self.rowShutdown action:TSRemoteActionShutdown];
    [self addTapToRow:self.rowRestart action:TSRemoteActionRestart];
    [self addTapToRow:self.rowFactoryReset action:TSRemoteActionFactoryReset];
}

/**
 * Frame 布局：卡片、说明、三行、分隔线、loading 居中
 */
- (void)layoutViews {
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);
    if (screenW <= 0) return;

    CGFloat topInset = self.ts_navigationBarTotalHeight;
    if (topInset <= 0) topInset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = MAX(self.view.safeAreaInsets.bottom, kCardPad);

    self.scrollView.frame = CGRectMake(0, topInset, screenW, screenH - topInset);

    CGFloat cardW = screenW - kCardPad * 2;
    CGFloat cardH = kHeaderDescH + kRowH * 3;
    self.cardView.frame = CGRectMake(kCardPad, kCardPad, cardW, cardH);
    self.cardView.layer.cornerRadius = kCardCornerR;

    self.descLabel.frame = CGRectMake(kCardPad, 12.f, cardW - kCardPad * 2, kHeaderDescH - 16.f);

    CGFloat rowY = kHeaderDescH;
    [self layoutRow:self.rowShutdown icon:self.iconShutdown title:self.titleShutdown arrow:self.arrowShutdown atY:rowY cardW:cardW isLastRow:NO];
    rowY += kRowH;
    [self layoutRow:self.rowRestart icon:self.iconRestart title:self.titleRestart arrow:self.arrowRestart atY:rowY cardW:cardW isLastRow:NO];
    rowY += kRowH;
    [self layoutRow:self.rowFactoryReset icon:self.iconFactoryReset title:self.titleFactoryReset arrow:self.arrowFactoryReset atY:rowY cardW:cardW isLastRow:YES];

    self.scrollView.contentSize = CGSizeMake(screenW, cardH + kCardPad * 2 + bottomInset);
    self.loadingIndicator.center = CGPointMake(screenW / 2.f, (screenH - topInset) / 2.f + topInset);
}

#pragma mark - 私有方法

/**
 * 布局单行视图及其子视图
 */
- (void)layoutRow:(UIView *)row icon:(UILabel *)icon title:(UILabel *)title arrow:(UILabel *)arrow atY:(CGFloat)y cardW:(CGFloat)cardW isLastRow:(BOOL)isLastRow {
    row.frame = CGRectMake(0, y, cardW, kRowH);
    CGFloat iconX  = kCardPad;
    CGFloat arrowW = 20.f;
    CGFloat rightPad = kCardPad + arrowW;
    CGFloat titleW = cardW - iconX - 32.f - rightPad;

    icon.frame  = CGRectMake(iconX, (kRowH - 24.f) / 2.f, 24.f, 24.f);
    title.frame = CGRectMake(iconX + 32.f, 0, titleW, kRowH);
    arrow.frame = CGRectMake(cardW - rightPad, (kRowH - 20.f) / 2.f, arrowW, 20.f);

    UIView *line = [row viewWithTag:999];
    if (line) {
        line.hidden = isLastRow;
        line.frame  = CGRectMake(kCardPad, kRowH - 0.5f, cardW - kCardPad * 2, 0.5f);
    }
}

/**
 * 为行视图绑定点击手势
 */
- (void)addTapToRow:(UIView *)row action:(TSRemoteAction)action {
    row.tag = action;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRowTapped:)];
    [row addGestureRecognizer:tap];
    row.userInteractionEnabled = YES;
}

/**
 * 点击某行：弹出确认框，确定后执行对应操作
 */
- (void)onRowTapped:(UITapGestureRecognizer *)gesture {
    TSRemoteAction action = (TSRemoteAction)gesture.view.tag;
    switch (action) {
        case TSRemoteActionShutdown: {
            [self showConfirmWithTitle:TSLocalizedString(@"remote_control.shutdown_confirm")
                              message:TSLocalizedString(@"remote_control.shutdown_msg")
                           completion:^{ [self performAction:action successMessage:TSLocalizedString(@"remote_control.shutdown_success") failureMessage:TSLocalizedString(@"remote_control.shutdown_failed")]; }];
            break;
        }
        case TSRemoteActionRestart: {
            [self showConfirmWithTitle:TSLocalizedString(@"remote_control.restart_confirm")
                              message:TSLocalizedString(@"remote_control.restart_msg")
                           completion:^{ [self performAction:action successMessage:TSLocalizedString(@"remote_control.restart_success") failureMessage:TSLocalizedString(@"remote_control.restart_failed")]; }];
            break;
        }
        case TSRemoteActionFactoryReset: {
            [self showConfirmWithTitle:TSLocalizedString(@"remote_control.reset_confirm")
                              message:TSLocalizedString(@"remote_control.reset_msg")
                           completion:^{ [self performAction:action successMessage:TSLocalizedString(@"remote_control.reset_success") failureMessage:TSLocalizedString(@"remote_control.reset_failed")]; }];
            break;
        }
    }
}

/**
 * 显示确认弹窗，确定后执行 completion
 */
- (void)showConfirmWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(void))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.confirm") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        if (completion) completion();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 * 执行远程操作，成功后 toast 并 pop，失败仅 toast
 */
- (void)performAction:(TSRemoteAction)action successMessage:(NSString *)successMsg failureMessage:(NSString *)failureMsg {
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    void (^completion)(BOOL, NSError * _Nullable) = ^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            weakSelf.scrollView.userInteractionEnabled = YES;
            if (success) {
                [weakSelf showToast:successMsg success:YES popAfterDismiss:YES];
            } else {
                [weakSelf showToast:error.localizedDescription ?: failureMsg success:NO popAfterDismiss:NO];
            }
        });
    };

    id<TSRemoteControlInterface> remote = [[TopStepComKit sharedInstance] remoteControl];
    switch (action) {
        case TSRemoteActionShutdown:     [remote shutdownDevice:completion];     break;
        case TSRemoteActionRestart:      [remote restartDevice:completion];      break;
        case TSRemoteActionFactoryReset: [remote factoryResetDevice:completion]; break;
    }
}

/**
 * 底部浮层 toast，显示约 2 秒后淡出，popAfterDismiss 时淡出完成后 pop
 */
- (void)showToast:(NSString *)message success:(BOOL)success popAfterDismiss:(BOOL)popAfterDismiss {
    UIView *toast = [[UIView alloc] init];
    UIColor *bgColor = success
        ? [TSColor_Success colorWithAlphaComponent:0.92f]
        : [[UIColor colorWithRed:50/255.f green:50/255.f blue:50/255.f alpha:1.f] colorWithAlphaComponent:0.88f];
    toast.backgroundColor = bgColor;
    toast.layer.cornerRadius = 10.f;
    toast.alpha = 0;

    UILabel *label = [[UILabel alloc] init];
    label.text          = message;
    label.textColor     = [UIColor whiteColor];
    label.font          = [UIFont systemFontOfSize:14.f];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    CGFloat maxW   = CGRectGetWidth(self.view.bounds) - 80.f;
    CGSize size    = [label sizeThatFits:CGSizeMake(maxW - 32.f, CGFLOAT_MAX)];
    CGFloat toastW = MIN(size.width + 32.f, maxW);
    CGFloat toastH = size.height + 20.f;
    toast.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - toastW) / 2.f,
                              CGRectGetHeight(self.view.bounds) * 0.72f, toastW, toastH);
    label.frame = CGRectMake(16.f, 10.f, toastW - 32.f, size.height);
    [toast addSubview:label];
    [self.view addSubview:toast];

    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1.0f; } completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kToastDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:kToastFadeOut animations:^{ toast.alpha = 0; } completion:^(BOOL done) {
                [toast removeFromSuperview];
                if (popAfterDismiss && weakSelf.navigationController) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
        });
    }];
}

/**
 * 创建行容器视图（含分隔线）
 */
- (UIView *)makeRowView {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = [UIColor clearColor];
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = TSColor_Separator;
    line.tag = 999;
    [row addSubview:line];
    return row;
}

/**
 * 创建 emoji 图标 label
 */
- (UILabel *)makeIconLabel:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text      = text;
    l.font      = [UIFont systemFontOfSize:20.f];
    l.textColor = TSColor_TextPrimary;
    return l;
}

/**
 * 创建行标题 label
 */
- (UILabel *)makeTitleLabel:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text      = text;
    l.font      = TSFont_Body;
    l.textColor = TSColor_TextPrimary;
    return l;
}

/**
 * 创建右箭头 label
 */
- (UILabel *)makeArrowLabel {
    UILabel *l = [[UILabel alloc] init];
    l.text      = @"›";
    l.font      = [UIFont systemFontOfSize:22.f weight:UIFontWeightLight];
    l.textColor = TSColor_TextSecondary;
    return l;
}

#pragma mark - 属性（懒加载）

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor    = TSColor_Background;
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor      = TSColor_Card;
        _cardView.layer.shadowColor    = [UIColor blackColor].CGColor;
        _cardView.layer.shadowOpacity  = 0.05f;
        _cardView.layer.shadowOffset   = CGSizeMake(0, 2);
        _cardView.layer.shadowRadius   = 6.f;
    }
    return _cardView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text          = TSLocalizedString(@"remote_control.warning");
        _descLabel.font          = TSFont_Body;
        _descLabel.textColor     = TSColor_TextSecondary;
        _descLabel.numberOfLines = 0;
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

- (UIView *)rowShutdown {
    if (!_rowShutdown) { _rowShutdown = [self makeRowView]; }
    return _rowShutdown;
}

- (UILabel *)iconShutdown {
    if (!_iconShutdown) { _iconShutdown = [self makeIconLabel:@"⏻"]; }
    return _iconShutdown;
}

- (UILabel *)titleShutdown {
    if (!_titleShutdown) { _titleShutdown = [self makeTitleLabel:TSLocalizedString(@"remote_control.shutdown")]; }
    return _titleShutdown;
}

- (UILabel *)arrowShutdown {
    if (!_arrowShutdown) { _arrowShutdown = [self makeArrowLabel]; }
    return _arrowShutdown;
}

- (UIView *)rowRestart {
    if (!_rowRestart) { _rowRestart = [self makeRowView]; }
    return _rowRestart;
}

- (UILabel *)iconRestart {
    if (!_iconRestart) { _iconRestart = [self makeIconLabel:@"↻"]; }
    return _iconRestart;
}

- (UILabel *)titleRestart {
    if (!_titleRestart) { _titleRestart = [self makeTitleLabel:TSLocalizedString(@"remote_control.restart")]; }
    return _titleRestart;
}

- (UILabel *)arrowRestart {
    if (!_arrowRestart) { _arrowRestart = [self makeArrowLabel]; }
    return _arrowRestart;
}

- (UIView *)rowFactoryReset {
    if (!_rowFactoryReset) { _rowFactoryReset = [self makeRowView]; }
    return _rowFactoryReset;
}

- (UILabel *)iconFactoryReset {
    if (!_iconFactoryReset) { _iconFactoryReset = [self makeIconLabel:@"⚙"]; }
    return _iconFactoryReset;
}

- (UILabel *)titleFactoryReset {
    if (!_titleFactoryReset) { _titleFactoryReset = [self makeTitleLabel:TSLocalizedString(@"remote_control.factory_reset")]; }
    return _titleFactoryReset;
}

- (UILabel *)arrowFactoryReset {
    if (!_arrowFactoryReset) { _arrowFactoryReset = [self makeArrowLabel]; }
    return _arrowFactoryReset;
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
