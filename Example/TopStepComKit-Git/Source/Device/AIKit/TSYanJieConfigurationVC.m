#import "TSYanJieConfigurationVC.h"

#if __has_include(<TopStepAIKit/TSAIYanJie.h>)
#import <TopStepAIKit/TSAIYanJie.h>
#endif

#import "TSAppDelegate.h"

@interface TSYanJieConfigurationVC ()
// 所有输入和开关只属于当前内存页面，不读取或写入偏好文件。
@property (nonatomic, strong) NSMutableDictionary<NSString *, UITextField *> *fields;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UISwitch *> *modules;
@property (nonatomic, strong) UIScrollView *formScrollView;
@property (nonatomic, strong) UIStackView *formStack;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *applyButton;
@property (nonatomic, assign) BOOL changingSelection;
@end

@implementation TSYanJieConfigurationVC

#pragma mark - 生命周期

// 仅构造UI数据，不创建任何SDK或网络请求。
- (void)initData {
    [super initData];
    self.title = @"AI方案配置";
    self.fields = [NSMutableDictionary dictionary];
    self.modules = [NSMutableDictionary dictionary];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(selectionStatusChanged:)
        name:TSAIProviderSelectionDidChangeNotification object:UIApplication.sharedApplication.delegate];
}

// 使用现有TSBaseVC生命周期构造小型配置页。
- (void)setupViews {
    self.formScrollView = [[UIScrollView alloc] init];
    self.formScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.formScrollView];
    self.formStack = [[UIStackView alloc] init];
    self.formStack.axis = UILayoutConstraintAxisVertical;
    self.formStack.spacing = 12;
    self.formStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.formScrollView addSubview:self.formStack];
    [NSLayoutConstraint activateConstraints:@[
        [self.formStack.topAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.topAnchor constant:16],
        [self.formStack.bottomAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.bottomAnchor constant:-24],
        [self.formStack.leadingAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.leadingAnchor constant:16],
        [self.formStack.trailingAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.trailingAnchor constant:-16],
        [self.formStack.widthAnchor constraintEqualToAnchor:self.formScrollView.frameLayoutGuide.widthAnchor constant:-32]
    ]];
    UILabel *instructions = [[UILabel alloc] init];
    instructions.numberOfLines = 0;
    instructions.text = @"凭证仅保留在本次运行内存中。应用会先停用旧会话，连接真实设备后由岩界完成授权。断连保留所选方案；现有业务页只开放当前支持的能力。";
    [self.formStack addArrangedSubview:instructions];
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    [self.formStack addArrangedSubview:self.statusLabel];
#if __has_include(<TopStepAIKit/TSAIYanJie.h>)
    [self buildYanJieFields];
    self.applyButton = [self addAction:@"应用岩界配置 / 重试清理与激活" selector:@selector(applyYanJie)];
#else
    UILabel *unavailable = [[UILabel alloc] init];
    unavailable.numberOfLines = 0;
    unavailable.text = @"当前SDK未安装岩界产品。请先构建并选择岩界发布组合，再运行此入口。";
    [self.formStack addArrangedSubview:unavailable];
#endif
    [self addAction:@"恢复设备推荐的AIBuds自动选择" selector:@selector(restoreAutomaticSelection)];
    [self updateStatus];
}

// 避开当前导航栏，表单内容使用滚动容器自动布局。
- (void)layoutViews {
    CGFloat top = MAX(self.ts_navigationBarTotalHeight, self.view.safeAreaInsets.top);
    self.formScrollView.frame = CGRectMake(0, top, CGRectGetWidth(self.view.bounds),
        MAX(0, CGRectGetHeight(self.view.bounds) - top));
}

// 页面再次出现时读取当前选择状态，不重新初始化SDK。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateStatus];
}

// 页面释放时自然释放所有文本输入，不持久化凭证。
- (void)dealloc { [NSNotificationCenter.defaultCenter removeObserver:self]; }

#pragma mark - 私有方法

// 使用同一个AppDelegate入口协调所有业务页的activeContext。
- (TSAppDelegate *)selectionDelegate {
    id delegate = UIApplication.sharedApplication.delegate;
    return [delegate isKindOfClass:TSAppDelegate.class] ? delegate : nil;
}

// 状态来自AppDelegate，不根据按钮点击假报授权完成。
- (void)updateStatus {
    TSAppDelegate *delegate = [self selectionDelegate];
    self.statusLabel.text = delegate.aiProviderSelectionStatus ?: @"设备推荐的AIBuds自动选择";
}

// 凭证输入关闭自动修正和文本补全，不使用用户偏好存储。
- (void)addField:(NSString *)key title:(NSString *)title value:(NSString *)value secure:(BOOL)secure {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    [self.formStack addArrangedSubview:label];
    UITextField *field = [[UITextField alloc] init];
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.text = value;
    field.secureTextEntry = secure;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    field.spellCheckingType = UITextSpellCheckingTypeNo;
    field.textContentType = @"";
    [field.heightAnchor constraintEqualToConstant:42].active = YES;
    self.fields[key] = field;
    [self.formStack addArrangedSubview:field];
}

// 所有操作均通过明确selector触发。
- (UIButton *)addAction:(NSString *)title selector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button.heightAnchor constraintEqualToConstant:44].active = YES;
    [self.formStack addArrangedSubview:button];
    return button;
}

#if __has_include(<TopStepAIKit/TSAIYanJie.h>)
// 已安装模块与当前内存快照决定开关，不依据设备推荐推断厂商。
- (void)buildYanJieFields {
    TSAIYanJieConfiguration *saved = [[self selectionDelegate] yanJieConfigurationSnapshot];
    TSAIYanJieConfiguration *configuration = saved ?: [[TSAIYanJieConfiguration alloc] init];
    [self addField:@"accessKey" title:@"岩界AK" value:configuration.accessKey secure:YES];
    [self addField:@"userId" title:@"已入库的SDK userId" value:configuration.userIdentifier secure:NO];
    [self addField:@"sn" title:@"云记录设备sn" value:configuration.historyDeviceSerialNumber secure:NO];
    [self addField:@"baseURL" title:@"云记录HTTPS Base URL" value:configuration.historyBaseURL.absoluteString secure:NO];
    [self addField:@"bearer" title:@"云记录Bearer（不含前缀）" value:configuration.historyBearerToken secure:YES];
    [self addField:@"platformUser" title:@"云记录zgUserId" value:configuration.historyPlatformUserIdentifier secure:NO];
    [self addField:@"voice" title:@"可选SDK音色名（空值使用当前语言默认映射）" value:configuration.voiceName secure:NO];
    NSSet *installed = [TSAIYanJieConfiguration installedModuleTypes];
    NSSet *selected = saved != nil ? saved.enabledModules : [NSSet setWithArray:
        @[@(TSAIYanJieModuleTypeAgent), @(TSAIYanJieModuleTypeTextTranslation)]];
    NSArray *descriptors = @[
        @[@(TSAIYanJieModuleTypeAgent), @"文字问答与图片理解"],
        @[@(TSAIYanJieModuleTypeTextTranslation), @"文本翻译"],
        @[@(TSAIYanJieModuleTypeASR), @"ASR识别"], @[@(TSAIYanJieModuleTypeNativeChat), @"原生语音聊天"],
        @[@(TSAIYanJieModuleTypeInterpreter), @"原生同传"], @[@(TSAIYanJieModuleTypeNativeTTS), @"原生语音播报"],
        @[@(TSAIYanJieModuleTypeMeeting), @"会议创建"], @[@(TSAIYanJieModuleTypeCloudHistory), @"云记录"]
    ];
    for (NSArray *descriptor in descriptors) {
        UILabel *label = [[UILabel alloc] init];
        label.text = descriptor[1];
        UISwitch *control = [[UISwitch alloc] init];
        control.enabled = [installed containsObject:descriptor[0]];
        control.on = control.enabled && [selected containsObject:descriptor[0]];
        self.modules[descriptor[0]] = control;
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:@[label, control]];
        row.distribution = UIStackViewDistributionEqualSpacing;
        [self.formStack addArrangedSubview:row];
    }
}
#endif

// 参数修改必须先走完整的Context失活，不在旧SDK实例上替换身份。
#if __has_include(<TopStepAIKit/TSAIYanJie.h>)
- (void)applyYanJie {
    if (self.changingSelection) { return; }
    TSAppDelegate *delegate = [self selectionDelegate];
    if (delegate == nil) { [self showAlertWithMsg:@"应用尚未初始化"]; return; }
    TSAIYanJieConfiguration *configuration = [delegate yanJieConfigurationSnapshot] ?: [[TSAIYanJieConfiguration alloc] init];
    configuration.accessKey = self.fields[@"accessKey"].text ?: @"";
    configuration.userIdentifier = self.fields[@"userId"].text ?: @"";
    configuration.historyDeviceSerialNumber = self.fields[@"sn"].text ?: @"";
    configuration.historyBearerToken = self.fields[@"bearer"].text ?: @"";
    configuration.historyPlatformUserIdentifier = self.fields[@"platformUser"].text ?: @"";
    configuration.historyBaseURL = [NSURL URLWithString:self.fields[@"baseURL"].text ?: @""];
    configuration.voiceName = self.fields[@"voice"].text ?: @"";
    NSMutableSet *selected = [NSMutableSet set];
    for (NSNumber *module in self.modules) {
        if (self.modules[module].enabled && self.modules[module].on) { [selected addObject:module]; }
    }
    configuration.enabledModules = selected;
    self.changingSelection = YES;
    self.applyButton.enabled = NO;
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    [delegate selectYanJieConfiguration:configuration completion:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.changingSelection = NO;
        strongSelf.applyButton.enabled = YES;
        [strongSelf updateStatus];
        if (!success) { [strongSelf showAlertWithMsg:error.localizedDescription ?: @"岩界选择失败，可重试"]; }
    }];
}
#endif

// 自动选择是用户明确操作，断连不会触发本入口。
- (void)restoreAutomaticSelection {
    if (self.changingSelection) { return; }
    TSAppDelegate *delegate = [self selectionDelegate];
    if (delegate == nil) { [self showAlertWithMsg:@"应用尚未初始化"]; return; }
    self.changingSelection = YES;
    __weak typeof(self) weakSelf = self;
    [delegate selectAutomaticAIProviderWithCompletion:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.changingSelection = NO;
        [strongSelf updateStatus];
        if (!success) { [strongSelf showAlertWithMsg:error.localizedDescription ?: @"自动选择失败，可重试"]; }
        else {
            for (UITextField *field in strongSelf.fields.allValues) { field.text = @""; }
        }
    }];
}

#pragma mark - 通知回调

// 状态通知不带正文、凭证或厂商原始报文。
- (void)selectionStatusChanged:(NSNotification *)notification { [self updateStatus]; }

@end
