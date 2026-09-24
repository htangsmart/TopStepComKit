//
//  TSHsdBaseVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"
#import "TSHsdCallLogVC.h"
#import <objc/runtime.h>

@interface TSHsdBaseVC ()
@property (nonatomic, strong) TSHsdDock *dock;
@property (nonatomic, strong) TSHsdStackView *stack;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TSHsdChipsRow *chipsRow;
@property (nonatomic, strong) UIButton *logButton;
@property (nonatomic, strong) UIView *logDot;
@property (nonatomic, assign) CGFloat keyboardOverlap;
@end

@implementation TSHsdBaseVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    if (!_hue) { _hue = [TSHsdDisplay hueParental]; }
    _showsReloadButton = YES;
}

- (void)setupViews {
    // 不用基类的表格：整页是 UIScrollView + 积木堆叠
    [self.sourceTableview removeFromSuperview];

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    [self.view addSubview:self.scrollView];

    self.stack = [[TSHsdStackView alloc] init];
    [self.scrollView addSubview:self.stack];

    self.chipsRow = [[TSHsdChipsRow alloc] init];

    if (self.usesDock) {
        [self.view addSubview:self.dock];
    }
    [self ts_setupNavItems];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ts_logDidChange) name:TSHsdCallLogDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ts_keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self render];
    [self reload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    [self ts_logDidChange];
    [self refreshDock];
    self.navigationController.interactivePopGestureRecognizer.enabled = !self.isDirty;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    UIViewController *top = self.navigationController.topViewController;
    if (top != self && ![top isKindOfClass:[TSHsdBaseVC class]]) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutViews {
    // 滚动区铺满整页，由系统按导航栏（含大标题）自动调整内容内边距
    self.scrollView.frame = self.view.bounds;
    [self ts_layoutStack];
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    if (self.usesDock) {
        CGFloat barH = [TSHsdDock barHeight];
        self.dock.frame = CGRectMake(14.f, self.view.bounds.size.height - bottomInset - 20.f - barH, self.view.bounds.size.width - 28.f, barH);
    }
    [self ts_updateScrollInsets];
}

- (void)ts_layoutStack {
    CGFloat w = self.scrollView.bounds.size.width;
    CGFloat h = [self.stack sizeThatFits:CGSizeMake(w, CGFLOAT_MAX)].height;
    self.stack.frame = CGRectMake(0, 0, w, h);
    self.scrollView.contentSize = CGSizeMake(w, h);
}

- (void)ts_updateScrollInsets {
    // 安全区由 contentInsetAdjustmentBehavior 自动补，这里只加保存条 / 键盘占位
    CGFloat bottom = 0;
    if (self.usesDock && self.dock.state != TSHsdDockStateHidden) { bottom = 20.f + [TSHsdDock barHeight] + 12.f; }
    bottom = MAX(bottom, self.keyboardOverlap);
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, bottom, 0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
}

#pragma mark - 导航栏

- (void)ts_setupNavItems {
    NSMutableArray<UIBarButtonItem *> *items = [NSMutableArray array];

    self.logButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.logButton.frame = CGRectMake(0, 0, 32.f, 32.f);
    [self.logButton setImage:TSHsdSymbol(@"terminal", 17.f, UIImageSymbolWeightMedium) forState:UIControlStateNormal];
    [self.logButton addTarget:self action:@selector(ts_openLog) forControlEvents:UIControlEventTouchUpInside];
    self.logDot = [[UIView alloc] initWithFrame:CGRectMake(23.f, 3.f, 7.f, 7.f)];
    self.logDot.backgroundColor = [TSHsdDisplay statusBad];
    self.logDot.layer.cornerRadius = 3.5f;
    self.logDot.hidden = YES;
    [self.logButton addSubview:self.logDot];
    [items addObject:[[UIBarButtonItem alloc] initWithCustomView:self.logButton]];

    if (self.showsReloadButton) {
        [items addObject:[[UIBarButtonItem alloc] initWithImage:TSHsdSymbol(@"arrow.clockwise", 16.f, UIImageSymbolWeightMedium) style:UIBarButtonItemStylePlain target:self action:@selector(ts_reloadTapped)]];
    }
    self.navigationItem.rightBarButtonItems = items;

    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:TSHsdSymbol(@"chevron.left", 17.f, UIImageSymbolWeightSemibold) style:UIBarButtonItemStylePlain target:self action:@selector(handleBack)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)handleBack {
    if (!self.isDirty) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"hsd.discard.title")
                                                                   message:TSLocalizedString(@"hsd.discard.message")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.continue_editing") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.discard") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        weakSelf.dirty = NO;
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)ts_reloadTapped {
    if (!self.isDirty) { [self reload]; return; }
    __weak typeof(self) weakSelf = self;
    [self confirmTitle:TSLocalizedString(@"hsd.reload.title") message:TSLocalizedString(@"hsd.reload.message")
          confirmTitle:TSLocalizedString(@"hsd.reload.confirm") destructive:YES handler:^{
        weakSelf.dirty = NO;
        [weakSelf reload];
    }];
}

- (void)ts_openLog {
    [self.navigationController pushViewController:[[TSHsdCallLogVC alloc] init] animated:YES];
}

- (void)ts_logDidChange {
    self.logDot.hidden = ![TSHsdCallLog shared].lastCallFailed;
}

#pragma mark - 子类实现

- (NSArray<UIView *> *)buildBlocks { return @[]; }
- (void)reload {}
- (void)save {}

- (TSHsdDockState)dockState {
    if (self.isSaving) { return TSHsdDockStateSaving; }
    if (!self.connected) { return TSHsdDockStateOffline; }
    return self.isDirty ? TSHsdDockStateDirty : TSHsdDockStateHidden;
}

- (NSString *)dockButtonTitle { return TSLocalizedString(@"hsd.save.to_watch"); }
- (nullable NSString *)dockSmall { return nil; }

#pragma mark - 渲染

- (void)render {
    NSArray<UIView *> *content = [self buildBlocks];   // 先构建，子类可能在其中更新 chips
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];
    if (self.chips.count) {
        self.chipsRow.hue = self.hue;
        self.chipsRow.chips = self.chips;
        [blocks addObject:self.chipsRow];
    }
    [blocks addObjectsFromArray:content];
    [self.stack setBlocks:blocks];
    [self ts_layoutStack];
    [self refreshDock];
}

- (void)refreshDock {
    if (!self.usesDock) { return; }
    self.dock.buttonTitle = [self dockButtonTitle];
    self.dock.small = [self dockSmall];
    self.dock.buttonEnabled = !self.invalid;
    self.dock.state = [self dockState];
    [self ts_updateScrollInsets];
}

#pragma mark - 状态

- (void)setDirty:(BOOL)dirty {
    _dirty = dirty;
    // 只在本页可见时接管侧滑返回，离开时恢复（见 viewWillAppear / viewWillDisappear）
    if (self.navigationController.topViewController == self) {
        self.navigationController.interactivePopGestureRecognizer.enabled = !dirty;
    }
    [self refreshDock];
}

- (void)setSaving:(BOOL)saving { _saving = saving; [self refreshDock]; }
- (void)setInvalid:(BOOL)invalid { _invalid = invalid; [self refreshDock]; }
- (nullable id<TSHuashengdaInterface>)hsd { return [TopStepComKit sharedInstance].huashengda; }
- (BOOL)connected { return [TopStepComKit sharedInstance].connectedPeripheral != nil; }

#pragma mark - 积木工厂

- (TSHsdSecView *)sec:(NSString *)title right:(nullable NSString *)right {
    TSHsdSecView *sec = [[TSHsdSecView alloc] init];
    sec.title = title;
    sec.rightText = right;
    return sec;
}

- (TSHsdFootView *)foot:(NSString *)text {
    TSHsdFootView *foot = [[TSHsdFootView alloc] init];
    foot.text = text;
    return foot;
}

- (TSHsdBannerView *)banner:(NSString *)text warn:(BOOL)warn {
    TSHsdBannerView *banner = [[TSHsdBannerView alloc] init];
    banner.warn = warn;
    banner.text = text;
    return banner;
}

- (TSHsdCardView *)card:(NSArray<UIView *> *)rows {
    TSHsdCardView *card = [[TSHsdCardView alloc] init];
    card.rows = rows;
    return card;
}

- (TSHsdCardView *)readOnlyGroup:(NSArray<UIView *> *)rows {
    TSHsdCardView *card = [[TSHsdCardView alloc] init];
    card.readOnlyStyle = YES;
    card.rows = rows;
    return card;
}

- (TSHsdRowView *)row {
    TSHsdRowView *row = [[TSHsdRowView alloc] init];
    row.hue = self.hue;
    return row;
}

- (TSHsdRowView *)switchRowWithSymbol:(nullable NSString *)symbol color:(nullable UIColor *)color title:(NSString *)title subtitle:(nullable NSString *)subtitle on:(BOOL)on onToggle:(void (^)(BOOL))onToggle {
    TSHsdRowView *row = [self row];
    row.symbol = symbol;
    row.iconColor = color;
    row.title = title;
    row.subtitle = subtitle;
    UISwitch *toggle = [[UISwitch alloc] init];
    toggle.on = on;
    toggle.onTintColor = self.hue;
    [toggle addTarget:self action:@selector(ts_switchChanged:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(toggle, @selector(ts_switchChanged:), onToggle, OBJC_ASSOCIATION_COPY_NONATOMIC);
    row.rightView = toggle;
    return row;
}

- (void)ts_switchChanged:(UISwitch *)sender {
    void (^onToggle)(BOOL) = objc_getAssociatedObject(sender, @selector(ts_switchChanged:));
    if (onToggle) { onToggle(sender.isOn); }
}

- (TSHsdRowView *)valueRowWithSymbol:(nullable NSString *)symbol color:(nullable UIColor *)color title:(NSString *)title value:(nullable NSString *)value onTap:(nullable void (^)(void))onTap {
    TSHsdRowView *row = [self row];
    row.symbol = symbol;
    row.iconColor = color;
    row.title = title;
    TSHsdValueLabel *label = [[TSHsdValueLabel alloc] init];
    label.text = value;
    row.rightView = label;
    row.showsChevron = (onTap != nil);
    row.onTap = onTap;
    return row;
}

- (TSHsdRowView *)timeRowWithTitle:(NSString *)title minute:(NSInteger)minute onPick:(void (^)(NSInteger))onPick {
    TSHsdRowView *row = [self row];
    row.title = title;
    TSHsdTimeBox *box = [[TSHsdTimeBox alloc] init];
    box.hue = self.hue;
    box.minute = minute;
    __weak typeof(self) weakSelf = self;
    box.onTap = ^{ [weakSelf pickTime:title minute:minute onPick:onPick]; };
    row.rightView = box;
    return row;
}

- (TSHsdRowView *)pickRowWithTitle:(NSString *)title subtitle:(nullable NSString *)subtitle config:(TSHsdValuePickConfig *)config value:(NSInteger)value onPick:(void (^)(NSInteger))onPick {
    if (!config.title.length) { config.title = title; }
    TSHsdRowView *row = [self row];
    row.title = title;
    row.subtitle = subtitle;
    TSHsdValueBox *box = [[TSHsdValueBox alloc] init];
    box.hue = self.hue;
    box.valueText = [config attributedTextForValue:value
                                        numberFont:[TSHsdDisplay roundedFontOfSize:16.f weight:UIFontWeightSemibold]
                                          unitFont:[UIFont systemFontOfSize:12.f weight:UIFontWeightSemibold]
                                             color:self.hue
                                         unitColor:[self.hue colorWithAlphaComponent:0.8f]];
    __weak typeof(self) weakSelf = self;
    box.onTap = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        [self dismissKeyboard];
        [TSHsdSheet presentValueFrom:self config:config value:value hue:self.hue onPick:onPick];
    };
    row.rightView = box;
    return row;
}

- (TSHsdRowView *)numRowWithTitle:(NSString *)title subtitle:(nullable NSString *)subtitle value:(NSInteger)value unit:(NSString *)unit min:(NSInteger)min max:(NSInteger)max onChange:(void (^)(NSInteger))onChange {
    TSHsdRowView *row = [self row];
    row.title = title;
    row.subtitle = subtitle;
    TSHsdNumBox *box = [[TSHsdNumBox alloc] init];
    box.minValue = min;
    box.maxValue = max;
    box.unit = unit;
    box.value = value;
    box.onChange = onChange;
    row.rightView = box;
    return row;
}

- (TSHsdFieldView *)fieldWithLabel:(NSString *)label text:(nullable NSString *)text maxBytes:(NSUInteger)maxBytes placeholder:(nullable NSString *)placeholder onChange:(void (^)(NSString *))onChange {
    TSHsdFieldView *field = [[TSHsdFieldView alloc] init];
    field.hue = self.hue;
    field.label = label;
    field.maxBytes = maxBytes;
    field.placeholder = placeholder;
    field.text = text;
    field.onChange = onChange;
    return field;
}

- (TSHsdWeekdayView *)weekdays:(TSAlarmRepeat)repeat presets:(NSArray<TSHsdWeekdayPreset *> *)presets onChange:(void (^)(TSAlarmRepeat))onChange {
    TSHsdWeekdayView *view = [[TSHsdWeekdayView alloc] init];
    view.hue = self.hue;
    view.presets = presets;
    view.repeat = repeat;
    view.onChange = onChange;
    return view;
}

- (TSHsdTimelineView *)timelineFrom:(NSInteger)start to:(NSInteger)end caption:(NSString *)caption {
    TSHsdTimelineView *view = [[TSHsdTimelineView alloc] init];
    view.hue = self.hue;
    view.caption = caption;
    view.startMinute = start;
    view.endMinute = end;
    return view;
}

- (TSHsdDuoTimeView *)duoStart:(NSInteger)start end:(NSInteger)end onStart:(void (^)(NSInteger))onStart onEnd:(void (^)(NSInteger))onEnd {
    TSHsdDuoTimeView *duo = [[TSHsdDuoTimeView alloc] init];
    duo.hue = self.hue;
    duo.startMinute = start;
    duo.endMinute = end;
    __weak typeof(self) weakSelf = self;
    duo.onTapStart = ^{ [weakSelf pickTime:TSLocalizedString(@"hsd.time.start") minute:start onPick:onStart]; };
    duo.onTapEnd = ^{ [weakSelf pickTime:TSLocalizedString(@"hsd.time.end") minute:end onPick:onEnd]; };
    return duo;
}

- (TSHsdStateLabel *)stateLabel:(NSString *)text color:(UIColor *)color {
    TSHsdStateLabel *label = [[TSHsdStateLabel alloc] init];
    [label setText:text color:color];
    return label;
}

- (TSHsdLoadingView *)loadingBlock:(nullable NSString *)text {
    TSHsdLoadingView *view = [[TSHsdLoadingView alloc] init];
    view.hue = self.hue;
    view.text = text ?: TSLocalizedString(@"hsd.loading.watch");
    return view;
}

- (TSHsdEmptyView *)emptyWithSymbol:(NSString *)symbol title:(NSString *)title text:(nullable NSString *)text code:(nullable NSString *)code {
    TSHsdEmptyView *empty = [[TSHsdEmptyView alloc] init];
    empty.hue = self.hue;
    empty.symbol = symbol;
    empty.title = title;
    empty.text = text;
    empty.code = code;
    return empty;
}

- (TSHsdCardView *)errorBlock:(nullable NSError *)error retry:(nullable void (^)(void))retry {
    BOOL fragments = [TSHsdErrorText isMissingFragmentsError:error];
    TSHsdEmptyView *empty = [self emptyWithSymbol:fragments ? @"square.stack.3d.up.slash" : @"wifi.slash"
                                            title:fragments ? TSLocalizedString(@"hsd.error.fragments_title") : TSLocalizedString(@"general.load_failed")
                                             text:[TSHsdErrorText messageForError:error]
                                             code:[TSHsdErrorText detailForError:error]];
    empty.hue = fragments ? [TSHsdDisplay statusWarn] : [TSHsdDisplay statusBad];
    if (retry) {
        empty.actionSymbol = @"arrow.clockwise";
        empty.actionTitle = TSLocalizedString(@"general.retry");
        empty.onAction = retry;
    }
    return [self card:@[empty]];
}

- (void)pickTime:(NSString *)title minute:(NSInteger)minute onPick:(void (^)(NSInteger))onPick {
    [self dismissKeyboard];
    [TSHsdSheet presentTimeFrom:self title:title minute:minute hue:self.hue onPick:onPick];
}

#pragma mark - 工具

- (TSHsdCallLogEntry *)beginCall:(NSString *)method params:(nullable NSString *)params {
    return [[TSHsdCallLog shared] begin:method params:params];
}

- (void)finishCall:(TSHsdCallLogEntry *)entry success:(BOOL)success error:(nullable NSError *)error result:(nullable NSString *)result {
    [[TSHsdCallLog shared] finish:entry success:success error:error result:result];
}

- (void)toast:(NSString *)message {
    [self ts_showToast:message];
}

- (void)confirmTitle:(NSString *)title message:(nullable NSString *)message confirmTitle:(NSString *)confirmTitle destructive:(BOOL)destructive handler:(void (^)(void))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:confirmTitle style:destructive ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (handler) { handler(); }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)askTitle:(NSString *)title message:(nullable NSString *)message buttons:(NSArray<NSString *> *)buttons destructiveIndex:(NSInteger)destructiveIndex handler:(void (^)(NSInteger))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [buttons enumerateObjectsUsingBlock:^(NSString *button, NSUInteger idx, BOOL *stop) {
        UIAlertActionStyle style = idx == 0 ? UIAlertActionStyleCancel : ((NSInteger)idx == destructiveIndex ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault);
        [alert addAction:[UIAlertAction actionWithTitle:button style:style handler:^(UIAlertAction *action) {
            if (handler) { handler(idx); }
        }]];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertError:(nullable NSError *)error title:(nullable NSString *)title {
    NSString *message = [NSString stringWithFormat:@"%@\n\n%@", [TSHsdErrorText messageForError:error], [TSHsdErrorText detailForError:error]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title ?: TSLocalizedString(@"general.hint") message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.got_it") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onMain:(void (^)(void))block {
    if ([NSThread isMainThread]) { block(); } else { dispatch_async(dispatch_get_main_queue(), block); }
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)ts_keyboardWillChange:(NSNotification *)notification {
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect local = [self.view convertRect:endFrame fromView:nil];
    CGFloat overlap = self.view.bounds.size.height - local.origin.y;
    self.keyboardOverlap = overlap > 0 ? overlap - self.view.safeAreaInsets.bottom + 12.f : 0;
    [self ts_updateScrollInsets];
}

#pragma mark - 懒加载

- (TSHsdDock *)dock {
    if (!_dock) {
        _dock = [[TSHsdDock alloc] init];
        __weak typeof(self) weakSelf = self;
        _dock.onTap = ^{
            [weakSelf dismissKeyboard];
            [weakSelf save];
        };
    }
    return _dock;
}

@end
