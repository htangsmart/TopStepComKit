//
//  TSRealtimeDanMuVC.m
//  TopStepComKit_Example
//

#import "TSRealtimeDanMuVC.h"

#import "TSDialColorPickerVC.h"
#import "TSDialEditorAppearance.h"
#import "TSRealtimeDanMuDraft.h"
#import "TSRealtimeDanMuEditorView.h"
#import "TSRealtimeDanMuLogView.h"
#import "TSRealtimeDanMuPreviewView.h"

@interface TSRealtimeDanMuVC ()

/** 顶部自定义导航 */
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *statusPill;
@property (nonatomic, strong) UIView *statusDot;
@property (nonatomic, strong) UILabel *statusLabel;
/** 预览与不支持蒙层 */
@property (nonatomic, strong) TSRealtimeDanMuPreviewView *previewView;
@property (nonatomic, strong) UIView *unsupportedOverlay;
/** 编辑区与日志区 */
@property (nonatomic, strong) UIScrollView *editorScroll;
@property (nonatomic, strong) TSRealtimeDanMuEditorView *editorView;
@property (nonatomic, strong) TSRealtimeDanMuLogView *logView;
/** 吸底操作 */
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIButton *primaryButton;
/** 状态 */
@property (nonatomic, strong) NSMutableArray<TSRealtimeDanMuDraft *> *drafts;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL previousNavigationHidden;

@end

@implementation TSRealtimeDanMuVC

#pragma mark - 生命周期

- (void)initData {
    self.view.backgroundColor = [TSDialEditorAppearance color:0xF6F5F2];
    TSRealtimeDanMuDraft *first = [TSRealtimeDanMuDraft defaultDraft];
    first.text = TSLocalizedString(@"realtime_danmu.sample.text");
    self.drafts = [NSMutableArray arrayWithObject:first];
    self.selectedIndex = 0;
}

/** 与弹幕表盘编辑页一致：隐藏系统导航，使用自绘 Header */
- (void)setupViews {
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];

    [self.view addSubview:self.headerView];
    [self.headerView addSubview:self.backButton];
    [self.headerView addSubview:self.titleLabel];
    [self.headerView addSubview:self.statusPill];
    [self.statusPill addSubview:self.statusDot];
    [self.statusPill addSubview:self.statusLabel];

    [self.view addSubview:self.previewView];
    [self.view addSubview:self.unsupportedOverlay];
    [self.view addSubview:self.editorScroll];
    [self.editorScroll addSubview:self.editorView];
    [self.editorScroll addSubview:self.logView];
    [self.view addSubview:self.footerView];
    [self.footerView addSubview:self.clearButton];
    [self.footerView addSubview:self.primaryButton];

    [self bindEditorEvents];
    [self reloadAll];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.previousNavigationHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.previewView resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.previewView suspend];
    [self.navigationController setNavigationBarHidden:self.previousNavigationHidden animated:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)dealloc {
    [_previewView suspend];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 公开方法

/** 固定 Header、预览与底栏，中间独立滚动 */
- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat top = self.view.safeAreaInsets.top;
    CGFloat bottom = self.keyboardHeight > 0 ? self.keyboardHeight : self.view.safeAreaInsets.bottom;

    self.headerView.frame = CGRectMake(0, top, width, 49);
    self.backButton.frame = CGRectMake(18, 0, 65, 49);
    CGFloat pillWidth = MIN(width * 0.42,
                            [self.statusLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20)].width + 26);
    self.statusPill.frame = CGRectMake(width - 18 - pillWidth, 13, pillWidth, 23);
    self.statusDot.frame = CGRectMake(9, 9, 5, 5);
    self.statusLabel.frame = CGRectMake(18, 0, pillWidth - 24, 23);
    self.titleLabel.frame = CGRectMake(90, 0, MAX(0.f, width - 100 - pillWidth), 49);

    CGFloat previewHeight = (height <= 730 || self.keyboardHeight > 0) ? 262 : 312;
    self.previewView.frame = CGRectMake(0, top + 49, width, previewHeight);
    self.unsupportedOverlay.frame = self.previewView.frame;

    CGFloat footerTop = height - bottom - 67;
    self.footerView.frame = CGRectMake(0, footerTop, width, 67 + self.view.safeAreaInsets.bottom);
    if (self.clearButton.hidden) {
        self.primaryButton.frame = CGRectMake(18, 12, width - 36, 46);
    } else {
        self.clearButton.frame = CGRectMake(18, 12, 88, 46);
        self.primaryButton.frame = CGRectMake(116, 12, width - 134, 46);
    }

    CGFloat scrollTop = top + 49 + previewHeight;
    self.editorScroll.frame = CGRectMake(0, scrollTop, width, MAX(0.f, footerTop - scrollTop));

    // 与预览区留出间距，避免弹幕队列紧贴预览底部的渐变块
    CGFloat editorTop = 16;
    CGFloat contentWidth = width - 40;
    self.editorView.frame = CGRectMake(20, editorTop, contentWidth, MAX(1.f, self.editorView.preferredHeight));
    [self.editorView layoutIfNeeded];
    CGFloat editorHeight = self.editorView.preferredHeight;
    self.editorView.frame = CGRectMake(20, editorTop, contentWidth, editorHeight);
    self.logView.frame = CGRectMake(20, editorTop + editorHeight + 10, contentWidth, self.logView.preferredHeight);
    self.editorScroll.contentSize = CGSizeMake(width, CGRectGetMaxY(self.logView.frame) + 20);
}

#pragma mark - 私有方法：SDK 访问

- (id<TSRealtimeDanMuInterface>)danMuInterface {
    return TopStepComKit.sharedInstance.realtimeDanMu;
}

- (BOOL)isFeatureSupported {
    id<TSRealtimeDanMuInterface> interface = [self danMuInterface];
    return interface != nil && [interface isSupport];
}

/** 直接暴露 Provider 类名，一眼看出落到哪个实现 */
- (NSString *)providerName {
    id<TSRealtimeDanMuInterface> interface = [self danMuInterface];
    return interface ? NSStringFromClass([interface class]) : @"-";
}

#pragma mark - 私有方法：刷新

- (void)reloadAll {
    [self refreshStatusPill];
    [self refreshFooter];

    TSPeripheralScreen *screen = TopStepComKit.sharedInstance.connectedPeripheral.screenInfo;
    self.previewView.screen = screen;
    [self.previewView reloadWithDrafts:self.drafts];
    [self.editorView configureWithDrafts:self.drafts selectedIndex:self.selectedIndex screen:screen];

    BOOL supported = [self isFeatureSupported];
    self.unsupportedOverlay.hidden = supported;
    self.editorView.userInteractionEnabled = supported;
    self.editorView.alpha = supported ? 1 : 0.4;

    [self.view setNeedsLayout];
}

/** 只改预览，不重建编辑区，避免输入时键盘被收起 */
- (void)reloadPreviewOnly {
    [self.previewView reloadWithDrafts:self.drafts];
    [self refreshFooter];
}

- (void)refreshStatusPill {
    BOOL connected = TopStepComKit.sharedInstance.connectedPeripheral != nil;
    BOOL supported = [self isFeatureSupported];
    NSString *state = !connected ? TSLocalizedString(@"realtime_danmu.state.disconnected")
                                 : (supported ? TSLocalizedString(@"realtime_danmu.state.supported")
                                              : TSLocalizedString(@"realtime_danmu.state.unsupported"));
    self.statusLabel.text = [NSString stringWithFormat:@"%@ · %@", state, [self providerName]];
    self.statusLabel.textColor = [TSDialEditorAppearance color:supported ? 0x3D7A4B : 0x7C8078];
    self.statusPill.backgroundColor = [TSDialEditorAppearance color:supported ? 0xE7F2E6 : 0xEDEDE8];
    self.statusDot.backgroundColor = [TSDialEditorAppearance color:supported ? 0x4C9A5B : 0xA8ADA3];
}

/** 不支持时主按钮改为「仍然调用一次」，这是验证不支持返回的唯一入口 */
- (void)refreshFooter {
    BOOL supported = [self isFeatureSupported];
    self.clearButton.hidden = !supported;
    if (supported) {
        [self.primaryButton setTitle:[NSString stringWithFormat:
                                      TSLocalizedString(@"realtime_danmu.action.send"),
                                      (long)self.drafts.count]
                            forState:UIControlStateNormal];
        self.primaryButton.enabled = [self hasOnlyValidTexts];
        self.primaryButton.backgroundColor = [TSDialEditorAppearance
            color:self.primaryButton.enabled ? 0xF16D43 : 0xE3C3B6];
    } else {
        [self.primaryButton setTitle:TSLocalizedString(@"realtime_danmu.action.send_anyway")
                            forState:UIControlStateNormal];
        self.primaryButton.enabled = YES;
        self.primaryButton.backgroundColor = [TSDialEditorAppearance color:0x7C8078];
    }
}

- (BOOL)hasOnlyValidTexts {
    for (TSRealtimeDanMuDraft *draft in self.drafts) {
        if (draft.text.length == 0 || [draft textByteLength] > kTSRealtimeDanMuMaxTextBytes) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 私有方法：编辑事件

- (void)bindEditorEvents {
    __weak typeof(self) weakSelf = self;

    self.editorView.onSelectDraft = ^(NSUInteger index) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || index >= strongSelf.drafts.count) {
            return;
        }
        strongSelf.selectedIndex = index;
        [strongSelf reloadAll];
    };

    self.editorView.onAddDraft = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || strongSelf.drafts.count >= kTSRealtimeDanMuMaxDraftCount) {
            return;
        }
        [strongSelf.drafts addObject:[TSRealtimeDanMuDraft defaultDraft]];
        strongSelf.selectedIndex = strongSelf.drafts.count - 1;
        [strongSelf reloadAll];
    };

    self.editorView.onRemoveDraft = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || strongSelf.drafts.count <= 1) {
            return;
        }
        [strongSelf.drafts removeObjectAtIndex:strongSelf.selectedIndex];
        strongSelf.selectedIndex = strongSelf.selectedIndex > 0 ? strongSelf.selectedIndex - 1 : 0;
        [strongSelf reloadAll];
    };

    self.editorView.onChooseColor = ^{
        [weakSelf chooseColor];
    };

    self.editorView.onValueChanged = ^(NSString *field, id value) {
        [weakSelf applyField:field value:value];
    };
}

/** 滑块与文本只刷预览；结构性变更才整块重建 */
- (void)applyField:(NSString *)field value:(id)value {
    if (self.selectedIndex >= self.drafts.count) {
        return;
    }
    TSRealtimeDanMuDraft *draft = self.drafts[self.selectedIndex];
    BOOL structural = NO;

    if ([field isEqualToString:kTSRealtimeDanMuFieldText]) {
        draft.text = value;
    } else if ([field isEqualToString:kTSRealtimeDanMuFieldFontSize]) {
        draft.fontSize = (UInt8)[value integerValue];
    } else if ([field isEqualToString:kTSRealtimeDanMuFieldSpeed]) {
        draft.speed = (UInt8)[value integerValue];
    } else if ([field isEqualToString:kTSRealtimeDanMuFieldYCoordinate]) {
        draft.yCoordinate = [value integerValue];
    } else if ([field isEqualToString:kTSRealtimeDanMuFieldType]) {
        draft.type = (TSDanMuType)[value integerValue];
        structural = YES;
    } else if ([field isEqualToString:kTSRealtimeDanMuFieldAnimation]) {
        draft.animation = (TSDanMuAnimation)[value integerValue];
        structural = YES;
    } else if ([field isEqualToString:kTSRealtimeDanMuFieldColor]) {
        draft.color = value;
        structural = YES;
    } else if ([field isEqualToString:kTSRealtimeDanMuFieldPositionRandom]) {
        if ([value boolValue]) {
            [draft useRandomPosition];
        } else {
            CGFloat screenHeight = TopStepComKit.sharedInstance.connectedPeripheral.screenInfo.screenSize.height;
            draft.yCoordinate = lround((screenHeight > 0 ? screenHeight : 448) / 3.0);
        }
        structural = YES;
    }

    if (structural) {
        [self reloadAll];
    } else {
        [self reloadPreviewOnly];
    }
}

/** 复用自定义表盘那套共用选色器，取消不回传、确定才写回 */
- (void)chooseColor {
    if (self.selectedIndex >= self.drafts.count) {
        return;
    }
    NSUInteger index = self.selectedIndex;
    NSString *subtitle = [NSString stringWithFormat:TSLocalizedString(@"realtime_danmu.color.subtitle"),
                          (long)(index + 1)];
    TSDialColorPickerVC *picker = [[TSDialColorPickerVC alloc] initWithColor:self.drafts[index].color
                                                                    subtitle:subtitle];
    __weak typeof(self) weakSelf = self;
    picker.onConfirm = ^(UIColor *color) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || index >= strongSelf.drafts.count) {
            return;
        }
        strongSelf.drafts[index].color = color;
        [strongSelf reloadAll];
    };
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 私有方法：接口调用

- (NSArray<TSDanMuItem *> *)danMuItems {
    NSMutableArray<TSDanMuItem *> *items = [NSMutableArray arrayWithCapacity:self.drafts.count];
    for (TSRealtimeDanMuDraft *draft in self.drafts) {
        [items addObject:[draft danMuItem]];
    }
    return items;
}

/** 先跑模型自校验，命中直接红字提示，省掉一次无谓的 BLE 往返 */
- (void)sendDanMu {
    [self.editorView endTextEditing];
    BOOL supported = [self isFeatureSupported];

    if (supported) {
        for (NSUInteger index = 0; index < self.drafts.count; index++) {
            NSError *error = [self.drafts[index] validate];
            if (error) {
                [self.logView appendSuccess:NO
                                     action:[NSString stringWithFormat:
                                             TSLocalizedString(@"realtime_danmu.log.action.send"),
                                             (long)self.drafts.count]
                                     detail:[NSString stringWithFormat:@"#%lu %@",
                                             (unsigned long)(index + 1), error.localizedDescription]];
                return;
            }
        }
    }

    NSString *action = [NSString stringWithFormat:TSLocalizedString(@"realtime_danmu.log.action.send"),
                        (long)self.drafts.count];
    NSDate *startDate = NSDate.date;
    [TSLoadingHUD showIn:self.view message:nil];
    __weak typeof(self) weakSelf = self;
    [[self danMuInterface] addDanMuItems:[self danMuItems] completion:^(BOOL isSuccess, NSError *error) {
        [weakSelf finishCall:action success:isSuccess error:error startDate:startDate];
    }];
}

- (void)chooseClearScope {
    [self.editorView endTextEditing];
    UIAlertController *sheet = [UIAlertController
        alertControllerWithTitle:TSLocalizedString(@"realtime_danmu.clear.title")
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray<NSString *> *titles = @[TSLocalizedString(@"realtime_danmu.clear.all"),
                                    TSLocalizedString(@"realtime_danmu.clear.mine"),
                                    TSLocalizedString(@"realtime_danmu.clear.friend")];
    TSDanMuClearScope scopes[] = {TSDanMuClearScopeAll, TSDanMuClearScopeMine, TSDanMuClearScopeFriend};
    __weak typeof(self) weakSelf = self;
    for (NSUInteger index = 0; index < titles.count; index++) {
        TSDanMuClearScope scope = scopes[index];
        NSString *title = titles[index];
        [sheet addAction:[UIAlertAction actionWithTitle:title
                                                  style:UIAlertActionStyleDefault
                                                handler:^(__unused UIAlertAction *unused) {
            [weakSelf clearWithScope:scope title:title];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"realtime_danmu.clear.cancel")
                                              style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.sourceView = self.clearButton;
    sheet.popoverPresentationController.sourceRect = self.clearButton.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)clearWithScope:(TSDanMuClearScope)scope title:(NSString *)title {
    NSString *action = [NSString stringWithFormat:TSLocalizedString(@"realtime_danmu.log.action.clear"), title];
    NSDate *startDate = NSDate.date;
    [TSLoadingHUD showIn:self.view message:nil];
    __weak typeof(self) weakSelf = self;
    [[self danMuInterface] clearDanMuWithScope:scope completion:^(BOOL isSuccess, NSError *error) {
        [weakSelf finishCall:action success:isSuccess error:error startDate:startDate];
    }];
}

/** 统一落日志：成功记耗时，失败记描述与错误码 */
- (void)finishCall:(NSString *)action
           success:(BOOL)success
             error:(NSError *)error
         startDate:(NSDate *)startDate {
    [TSLoadingHUD hideIn:self.view];
    NSInteger elapsed = (NSInteger)llround([NSDate.date timeIntervalSinceDate:startDate] * 1000);
    NSString *detail = success
        ? [NSString stringWithFormat:@"%ld ms", (long)elapsed]
        : [NSString stringWithFormat:@"%@ (code %ld)",
           error.localizedDescription ?: TSLocalizedString(@"realtime_danmu.log.unknown_error"),
           (long)error.code];
    [self.logView appendSuccess:success action:action detail:detail];
    [self.view setNeedsLayout];
}

#pragma mark - 私有方法：其他

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 键盘弹出时抬起底栏并压缩预览 */
- (void)keyboardChanged:(NSNotification *)notification {
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect local = [self.view convertRect:frame fromView:nil];
    self.keyboardHeight = CGRectGetHeight(CGRectIntersection(self.view.bounds, local));
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self layoutViews];
    }];
}

#pragma mark - 懒加载

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
    }
    return _headerView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_backButton setTitle:TSLocalizedString(@"realtime_danmu.back") forState:UIControlStateNormal];
        _backButton.tintColor = [TSDialEditorAppearance color:0x647757];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [TSDialEditorAppearance label:TSLocalizedString(@"realtime_danmu.title") size:18 color:0x252823];
        _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)statusPill {
    if (!_statusPill) {
        _statusPill = [[UIView alloc] init];
        _statusPill.layer.cornerRadius = 7;
        _statusPill.clipsToBounds = YES;
    }
    return _statusPill;
}

- (UIView *)statusDot {
    if (!_statusDot) {
        _statusDot = [[UIView alloc] init];
        _statusDot.layer.cornerRadius = 2.5;
    }
    return _statusDot;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [TSDialEditorAppearance label:@"" size:10 color:0x3D7A4B];
        _statusLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.minimumScaleFactor = 0.7;
    }
    return _statusLabel;
}

- (TSRealtimeDanMuPreviewView *)previewView {
    if (!_previewView) {
        _previewView = [[TSRealtimeDanMuPreviewView alloc] init];
    }
    return _previewView;
}

/** 不支持时盖在预览上的说明卡 */
- (UIView *)unsupportedOverlay {
    if (!_unsupportedOverlay) {
        _unsupportedOverlay = [[UIView alloc] init];
        _unsupportedOverlay.backgroundColor = [[TSDialEditorAppearance color:0xF6F5F2] colorWithAlphaComponent:0.88];

        UIView *card = [[UIView alloc] init];
        card.backgroundColor = UIColor.whiteColor;
        card.layer.cornerRadius = 16;
        card.layer.borderWidth = 1;
        card.layer.borderColor = [TSDialEditorAppearance color:0xE9EAE4].CGColor;
        card.translatesAutoresizingMaskIntoConstraints = NO;
        [_unsupportedOverlay addSubview:card];

        UILabel *title = [TSDialEditorAppearance label:TSLocalizedString(@"realtime_danmu.unsupported.title")
                                                  size:13.5 color:0x252823];
        title.font = [UIFont systemFontOfSize:13.5 weight:UIFontWeightSemibold];
        title.textAlignment = NSTextAlignmentCenter;
        title.numberOfLines = 0;
        title.translatesAutoresizingMaskIntoConstraints = NO;
        [card addSubview:title];

        UILabel *detail = [TSDialEditorAppearance label:TSLocalizedString(@"realtime_danmu.unsupported.detail")
                                                   size:11.5 color:0x93958E];
        detail.textAlignment = NSTextAlignmentCenter;
        detail.numberOfLines = 0;
        detail.translatesAutoresizingMaskIntoConstraints = NO;
        [card addSubview:detail];

        [NSLayoutConstraint activateConstraints:@[
            [card.centerXAnchor constraintEqualToAnchor:_unsupportedOverlay.centerXAnchor],
            [card.centerYAnchor constraintEqualToAnchor:_unsupportedOverlay.centerYAnchor],
            [card.leadingAnchor constraintEqualToAnchor:_unsupportedOverlay.leadingAnchor constant:46],
            [title.topAnchor constraintEqualToAnchor:card.topAnchor constant:18],
            [title.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:16],
            [title.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-16],
            [detail.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:6],
            [detail.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
            [detail.trailingAnchor constraintEqualToAnchor:title.trailingAnchor],
            [detail.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-18]
        ]];
    }
    return _unsupportedOverlay;
}

- (UIScrollView *)editorScroll {
    if (!_editorScroll) {
        _editorScroll = [[UIScrollView alloc] init];
        _editorScroll.alwaysBounceVertical = YES;
        _editorScroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _editorScroll;
}

- (TSRealtimeDanMuEditorView *)editorView {
    if (!_editorView) {
        _editorView = [[TSRealtimeDanMuEditorView alloc] init];
    }
    return _editorView;
}

- (TSRealtimeDanMuLogView *)logView {
    if (!_logView) {
        _logView = [[TSRealtimeDanMuLogView alloc] init];
    }
    return _logView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = UIColor.whiteColor;
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1000, 1)];
        separator.backgroundColor = [TSDialEditorAppearance color:0xE7EADE];
        [_footerView addSubview:separator];
        _footerView.clipsToBounds = YES;
    }
    return _footerView;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = [TSDialEditorAppearance button:TSLocalizedString(@"realtime_danmu.action.clear") primary:NO];
        [_clearButton addTarget:self action:@selector(chooseClearScope) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clearButton;
}

- (UIButton *)primaryButton {
    if (!_primaryButton) {
        _primaryButton = [TSDialEditorAppearance button:@"" primary:YES];
        [_primaryButton addTarget:self action:@selector(sendDanMu) forControlEvents:UIControlEventTouchUpInside];
    }
    return _primaryButton;
}

@end
