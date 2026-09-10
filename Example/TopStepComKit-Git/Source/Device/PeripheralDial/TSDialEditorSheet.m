//
//  TSDialEditorSheet.m
//  TopStepComKit_Example
//

#import "TSDialEditorSheet.h"
#import "TSDialEditorAppearance.h"

@interface TSDialEditorSheet ()
// 白色面板。
@property (nonatomic, strong) UIView *panel;
// 标题与关闭。
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
// 可滚动内容，避免小屏裁掉操作。
@property (nonatomic, strong) UIScrollView *contentScroll;
@end

@implementation TSDialEditorSheet

#pragma mark - 生命周期

// 同一种容器承载图库、放大与安装状态。
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _allowsDismissal = YES;
        _horizontalContentInset = 20;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor colorWithRed:0.1 green:0.13 blue:0.09 alpha:0.4];
        _panel = [[UIView alloc] init];
        _panel.backgroundColor = UIColor.whiteColor;
        _panel.layer.cornerRadius = 24;
        _panel.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        _titleLabel = [TSDialEditorAppearance label:@"" size:16 color:0x252823];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_closeButton setTitle:@"×" forState:UIControlStateNormal];
        _closeButton.backgroundColor = [TSDialEditorAppearance color:0xF1F3ED];
        _closeButton.tintColor = [TSDialEditorAppearance color:0x929C86];
        _closeButton.layer.cornerRadius = 14.5;
        [_closeButton addTarget:self action:@selector(requestDismiss) forControlEvents:UIControlEventTouchUpInside];
        _contentScroll = [[UIScrollView alloc] init];
        _contentScroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _contentView = [[UIView alloc] init];
        _primaryButton = [TSDialEditorAppearance button:@"" primary:YES];
        _secondaryButton = [TSDialEditorAppearance button:@"" primary:NO];
        [_primaryButton addTarget:self action:@selector(primaryAction) forControlEvents:UIControlEventTouchUpInside];
        [_secondaryButton addTarget:self action:@selector(secondaryAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_panel];
        [_panel addSubview:_titleLabel];
        [_panel addSubview:_closeButton];
        [_panel addSubview:_contentScroll];
        [_contentScroll addSubview:_contentView];
        [_panel addSubview:_primaryButton];
        [_panel addSubview:_secondaryButton];
    }
    return self;
}

// 底部始终避让系统安全区。
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds), height = CGRectGetHeight(self.bounds);
    CGFloat bottom = self.safeAreaInsets.bottom;
    CGFloat footer = self.primaryButton.hidden && self.secondaryButton.hidden ? 15 : 72;
    if (self.stacksActions && !self.primaryButton.hidden && !self.secondaryButton.hidden) {
        footer = 118;
    }
    CGFloat panelHeight = MIN(height - self.safeAreaInsets.top - 20, 64 + self.contentHeight + footer + bottom);
    self.panel.frame = CGRectMake(0, height - panelHeight, width, panelHeight);
    self.titleLabel.frame = CGRectMake(20, 17, width - 90, 30);
    self.titleLabel.text = self.title;
    self.closeButton.frame = CGRectMake(width - 49, 18, 29, 29);
    self.closeButton.hidden = !self.allowsDismissal;
    CGFloat contentInset = MAX(0, self.horizontalContentInset);
    self.contentScroll.frame = CGRectMake(contentInset, 64, width - contentInset * 2, panelHeight - 64 - footer - bottom);
    self.contentView.frame = CGRectMake(0, 0, width - contentInset * 2, self.contentHeight);
    self.contentScroll.contentSize = self.contentView.bounds.size;
    CGFloat actionWidth = (width - 48) / 2;
    self.secondaryButton.frame = CGRectMake(20, panelHeight - bottom - 60, actionWidth, 44);
    self.primaryButton.frame = CGRectMake(28 + actionWidth, panelHeight - bottom - 60, actionWidth, 44);
    if (self.secondaryButton.hidden) {
        self.primaryButton.frame = CGRectMake(20, panelHeight - bottom - 60, width - 40, 44);
    } else if (self.primaryButton.hidden) {
        self.secondaryButton.frame = CGRectMake(20, panelHeight - bottom - 60, width - 40, 44);
    }
    if (self.stacksActions) {
        self.secondaryButton.backgroundColor = UIColor.clearColor;
        self.secondaryButton.layer.borderWidth = 0;
        [self.secondaryButton setTitleColor:[TSDialEditorAppearance color:0xC27455] forState:UIControlStateNormal];
        self.primaryButton.frame = CGRectMake(20, panelHeight - bottom - footer + 8, width - 40, 46);
        self.secondaryButton.frame = CGRectMake(20, panelHeight - bottom - 51, width - 40, 42);
    }
}

#pragma mark - 公开方法

// 在当前页面覆盖展示，保留底层编辑状态。
- (void)showInView:(UIView *)view {
    self.frame = view.bounds;
    [view addSubview:self];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{ self.alpha = 1; }];
}

// 关闭仅移除当前面板。
- (void)dismiss {
    [self removeFromSuperview];
    if (self.onDismiss) {
        self.onDismiss();
    }
}

#pragma mark - 私有方法

// 安装进行中禁止遮罩误关闭。
- (void)requestDismiss {
    if (self.allowsDismissal) {
        [self dismiss];
    }
}

// 主操作转发。
- (void)primaryAction {
    if (self.onPrimary) {
        self.onPrimary();
    }
}

// 次操作转发。
- (void)secondaryAction {
    if (self.onSecondary) {
        self.onSecondary();
    }
}

// 点击面板外区域关闭。
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!CGRectContainsPoint(self.panel.frame, [touches.anyObject locationInView:self])) {
        [self requestDismiss];
    }
}

@end
