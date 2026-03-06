//
//  TSRemoteControlVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/20.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSRemoteControlVC.h"
#import <TopStepComKit/TopStepComKit.h>

static const CGFloat kCardCornerR  = 12.f;
static const CGFloat kCardPad      = 16.f;
static const CGFloat kRowH         = 56.f;
static const CGFloat kHeaderDescH  = 52.f;
static const CGFloat kToastDuration = 2.0f;
static const CGFloat kToastFadeOut  = 0.25f;

typedef NS_ENUM(NSInteger, TSRemoteAction) {
    TSRemoteActionShutdown = 0,
    TSRemoteActionRestart,
    TSRemoteActionFactoryReset,
};

@interface TSRemoteControlVC ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView       *cardView;
@property (nonatomic, strong) UILabel      *descLabel;

@property (nonatomic, strong) UIView       *rowShutdown;
@property (nonatomic, strong) UILabel      *iconShutdown;
@property (nonatomic, strong) UILabel      *titleShutdown;

@property (nonatomic, strong) UIView       *rowRestart;
@property (nonatomic, strong) UILabel      *iconRestart;
@property (nonatomic, strong) UILabel      *titleRestart;

@property (nonatomic, strong) UIView       *rowFactoryReset;
@property (nonatomic, strong) UILabel      *iconFactoryReset;
@property (nonatomic, strong) UILabel      *titleFactoryReset;
@property (nonatomic, strong) UILabel      *arrowShutdown;
@property (nonatomic, strong) UILabel      *arrowRestart;
@property (nonatomic, strong) UILabel      *arrowFactoryReset;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation TSRemoteControlVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Override Base Setup

/** 初始化标题，不添加父类 tableView */
- (void)initData {
    [super initData];
    self.title = @"远程控制";
}

/** 构建滚动容器、卡片、三行操作与无遮罩 loading */
- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.cardView];
    [self.cardView addSubview:self.descLabel];

    [self.cardView addSubview:self.rowShutdown];
    [self.rowShutdown addSubview:self.iconShutdown];
    [self.rowShutdown addSubview:self.titleShutdown];

    [self.cardView addSubview:self.rowRestart];
    [self.rowRestart addSubview:self.iconRestart];
    [self.rowRestart addSubview:self.titleRestart];

    [self.cardView addSubview:self.rowFactoryReset];
    [self.rowFactoryReset addSubview:self.iconFactoryReset];
    [self.rowFactoryReset addSubview:self.titleFactoryReset];

    [self.rowShutdown addSubview:self.arrowShutdown];
    [self.rowRestart addSubview:self.arrowRestart];
    [self.rowFactoryReset addSubview:self.arrowFactoryReset];

    [self.view addSubview:self.loadingIndicator];

    [self addTapToRow:self.rowShutdown action:TSRemoteActionShutdown];
    [self addTapToRow:self.rowRestart action:TSRemoteActionRestart];
    [self addTapToRow:self.rowFactoryReset action:TSRemoteActionFactoryReset];
}

/** Frame 布局：卡片、说明、三行、分隔线、loading 居中 */
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
    [self layoutRowView:self.rowShutdown atY:rowY cardW:cardW isLastRow:NO];
    rowY += kRowH;
    [self layoutRowView:self.rowRestart atY:rowY cardW:cardW isLastRow:NO];
    rowY += kRowH;
    [self layoutRowView:self.rowFactoryReset atY:rowY cardW:cardW isLastRow:YES];

    self.scrollView.contentSize = CGSizeMake(screenW, cardH + kCardPad * 2 + bottomInset);
    self.loadingIndicator.center = CGPointMake(screenW / 2.f, (screenH - topInset) / 2.f + topInset);
}

- (void)layoutRowView:(UIView *)row atY:(CGFloat)y cardW:(CGFloat)cardW isLastRow:(BOOL)isLastRow {
    row.frame = CGRectMake(0, y, cardW, kRowH);
    CGFloat iconX = kCardPad;
    CGFloat arrowW = 20.f;
    CGFloat rightPad = kCardPad + arrowW;
    CGFloat titleW = cardW - iconX - 32.f - rightPad;
    if (row == self.rowShutdown) {
        self.iconShutdown.frame = CGRectMake(iconX, (kRowH - 24.f) / 2.f, 24.f, 24.f);
        self.titleShutdown.frame = CGRectMake(iconX + 32.f, 0, titleW, kRowH);
        self.arrowShutdown.frame = CGRectMake(cardW - rightPad, (kRowH - 20.f) / 2.f, arrowW, 20.f);
    } else if (row == self.rowRestart) {
        self.iconRestart.frame = CGRectMake(iconX, (kRowH - 24.f) / 2.f, 24.f, 24.f);
        self.titleRestart.frame = CGRectMake(iconX + 32.f, 0, titleW, kRowH);
        self.arrowRestart.frame = CGRectMake(cardW - rightPad, (kRowH - 20.f) / 2.f, arrowW, 20.f);
    } else {
        self.iconFactoryReset.frame = CGRectMake(iconX, (kRowH - 24.f) / 2.f, 24.f, 24.f);
        self.titleFactoryReset.frame = CGRectMake(iconX + 32.f, 0, titleW, kRowH);
        self.arrowFactoryReset.frame = CGRectMake(cardW - rightPad, (kRowH - 20.f) / 2.f, arrowW, 20.f);
    }
    UIView *line = [row viewWithTag:999];
    if (line) {
        line.hidden = isLastRow;
        line.frame = CGRectMake(kCardPad, kRowH - 0.5f, cardW - kCardPad * 2, 0.5f);
    }
}

- (void)addTapToRow:(UIView *)row action:(TSRemoteAction)action {
    row.tag = action;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rowTapped:)];
    [row addGestureRecognizer:tap];
    row.userInteractionEnabled = YES;
}

#pragma mark - Actions

/** 点击某行：弹出确认框（表中文案），确定后执行对应操作 */
- (void)rowTapped:(UITapGestureRecognizer *)gesture {
    TSRemoteAction action = (TSRemoteAction)gesture.view.tag;
    switch (action) {
        case TSRemoteActionShutdown: {
            [self showConfirmWithTitle:@"关机确认"
                              message:@"确定要关闭设备吗？设备将断开连接。"
                           completion:^{ [self performShutdown]; }];
            break;
        }
        case TSRemoteActionRestart: {
            [self showConfirmWithTitle:@"重启确认"
                              message:@"确定要重启设备吗？设备将短暂断开后重新启动。"
                           completion:^{ [self performRestart]; }];
            break;
        }
        case TSRemoteActionFactoryReset: {
            [self showConfirmWithTitle:@"恢复出厂设置确认"
                              message:@"将清除设备内所有数据且不可恢复，确定要继续吗？"
                           completion:^{ [self performFactoryReset]; }];
            break;
        }
    }
}

/** 显示系统确认弹窗，确定后执行 completion */
- (void)showConfirmWithTitle:(NSString *)title message:(NSString *)message completion:(void (^)(void))completion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (completion) completion();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/** 显示无遮罩 loading，调关机接口；成功则 toast 后 pop，失败仅 toast */
- (void)performShutdown {
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] remoteControl] shutdownDevice:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            weakSelf.scrollView.userInteractionEnabled = YES;
            if (success) {
                [weakSelf showToast:@"设备已关闭" success:YES popAfterDismiss:YES];
            } else {
                [weakSelf showToast:error.localizedDescription ?: @"关闭设备失败" success:NO popAfterDismiss:NO];
            }
        });
    }];
}

/** 显示无遮罩 loading，调重启接口；成功则 toast 后 pop，失败仅 toast */
- (void)performRestart {
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] remoteControl] restartDevice:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            weakSelf.scrollView.userInteractionEnabled = YES;
            if (success) {
                [weakSelf showToast:@"设备已重启" success:YES popAfterDismiss:YES];
            } else {
                [weakSelf showToast:error.localizedDescription ?: @"重启设备失败" success:NO popAfterDismiss:NO];
            }
        });
    }];
}

/** 显示无遮罩 loading，调恢复出厂设置接口；成功则 toast 后 pop，失败仅 toast */
- (void)performFactoryReset {
    [self.loadingIndicator startAnimating];
    self.scrollView.userInteractionEnabled = NO;

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] remoteControl] factoryResetDevice:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            weakSelf.scrollView.userInteractionEnabled = YES;
            if (success) {
                [weakSelf showToast:@"设备已恢复出厂设置" success:YES popAfterDismiss:YES];
            } else {
                [weakSelf showToast:error.localizedDescription ?: @"恢复出厂设置失败" success:NO popAfterDismiss:NO];
            }
        });
    }];
}

#pragma mark - Toast

/** 底部浮层 toast，显示约 2 秒后淡出，popAfterDismiss 时在淡出完成后再 pop */
- (void)showToast:(NSString *)message success:(BOOL)success popAfterDismiss:(BOOL)popAfterDismiss {
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
        _descLabel.text = @"请谨慎操作，执行后设备将断开连接。";
        _descLabel.font = TSFont_Body;
        _descLabel.textColor = TSColor_TextSecondary;
        _descLabel.numberOfLines = 0;
        _descLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _descLabel;
}

- (UIView *)rowShutdown {
    if (!_rowShutdown) {
        _rowShutdown = [self makeRowWithIcon:@"⏻" title:@"关机"];
    }
    return _rowShutdown;
}

- (UILabel *)iconShutdown {
    if (!_iconShutdown) { _iconShutdown = [self makeIconLabel:@"⏻"]; }
    return _iconShutdown;
}

- (UILabel *)titleShutdown {
    if (!_titleShutdown) { _titleShutdown = [self makeTitleLabel:@"关机"]; }
    return _titleShutdown;
}

- (UIView *)rowRestart {
    if (!_rowRestart) {
        _rowRestart = [self makeRowWithIcon:@"↻" title:@"重启"];
    }
    return _rowRestart;
}

- (UILabel *)iconRestart {
    if (!_iconRestart) { _iconRestart = [self makeIconLabel:@"↻"]; }
    return _iconRestart;
}

- (UILabel *)titleRestart {
    if (!_titleRestart) { _titleRestart = [self makeTitleLabel:@"重启"]; }
    return _titleRestart;
}

- (UIView *)rowFactoryReset {
    if (!_rowFactoryReset) {
        _rowFactoryReset = [self makeRowWithIcon:@"⚙" title:@"恢复出厂设置"];
    }
    return _rowFactoryReset;
}

- (UILabel *)iconFactoryReset {
    if (!_iconFactoryReset) { _iconFactoryReset = [self makeIconLabel:@"⚙"]; }
    return _iconFactoryReset;
}

- (UILabel *)titleFactoryReset {
    if (!_titleFactoryReset) { _titleFactoryReset = [self makeTitleLabel:@"恢复出厂设置"]; }
    return _titleFactoryReset;
}

- (UILabel *)arrowShutdown {
    if (!_arrowShutdown) { _arrowShutdown = [self makeArrowLabel]; }
    return _arrowShutdown;
}

- (UILabel *)arrowRestart {
    if (!_arrowRestart) { _arrowRestart = [self makeArrowLabel]; }
    return _arrowRestart;
}

- (UILabel *)arrowFactoryReset {
    if (!_arrowFactoryReset) { _arrowFactoryReset = [self makeArrowLabel]; }
    return _arrowFactoryReset;
}

- (UIView *)makeRowWithIcon:(NSString *)icon title:(NSString *)title {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = [UIColor clearColor];
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = TSColor_Separator;
    line.tag = 999;
    [row addSubview:line];
    (void)icon;
    (void)title;
    return row;
}

- (UILabel *)makeIconLabel:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text = text;
    l.font = [UIFont systemFontOfSize:20.f];
    l.textColor = TSColor_TextPrimary;
    return l;
}

- (UILabel *)makeTitleLabel:(NSString *)text {
    UILabel *l = [[UILabel alloc] init];
    l.text = text;
    l.font = TSFont_Body;
    l.textColor = TSColor_TextPrimary;
    return l;
}

- (UILabel *)makeArrowLabel {
    UILabel *l = [[UILabel alloc] init];
    l.text = @"›";
    l.font = [UIFont systemFontOfSize:22.f weight:UIFontWeightLight];
    l.textColor = TSColor_TextSecondary;
    return l;
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
