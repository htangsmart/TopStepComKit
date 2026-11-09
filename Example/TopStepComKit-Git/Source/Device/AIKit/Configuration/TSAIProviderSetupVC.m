#import "TSAIProviderSetupVC.h"
#if TS_BUDS_AI_INTEGRATION_AVAILABLE

#import <TopStepAIKit/TSAIBudsConfiguration.h>
#import <TopStepAIKit/TSAIWoQiConfiguration.h>

#import "TSAIProviderSelection.h"
#import "TSDeviceCoordinator.h"

@interface TSAIProviderSetupVC ()
// 三种已接入的配置；不为尚未确认 SDK 的方案创建空 Provider。
@property (nonatomic, strong) UISegmentedControl *providerControl;
// 只有取得文档或真机证据后才勾选；不由供应商或设备名称推断格式。
@property (nonatomic, strong) UISwitch *verifiedPCMSwitch;
@property (nonatomic, strong) UIScrollView *formScrollView;
@property (nonatomic, strong) UIStackView *formStack;
@property (nonatomic, strong) NSMutableDictionary<NSString *, UITextField *> *fields;
@property (nonatomic, strong) UISwitch *stagingSwitch;
@property (nonatomic, strong) UIView *stagingRow;
@end

@implementation TSAIProviderSetupVC

#pragma mark - 生命周期

// 编辑控件中的草稿，保存前不改变运行配置。
- (void)initData {
    [super initData];
    self.title = @"Buds AI 配置";
    self.fields = [NSMutableDictionary dictionary];
}

// 复用基础页面；表单不把凭证写入本地存储。
- (void)setupViews {
    self.formScrollView = [[UIScrollView alloc] init];
    self.formScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.formScrollView];
    self.formStack = [[UIStackView alloc] init];
    self.formStack.axis = UILayoutConstraintAxisVertical;
    self.formStack.spacing = 14;
    self.formStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.formScrollView addSubview:self.formStack];
    [NSLayoutConstraint activateConstraints:@[
        [self.formStack.leadingAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.leadingAnchor constant:20],
        [self.formStack.trailingAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.trailingAnchor constant:-20],
        [self.formStack.topAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.topAnchor constant:20],
        [self.formStack.bottomAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.bottomAnchor constant:-24],
        [self.formStack.widthAnchor constraintEqualToAnchor:self.formScrollView.frameLayoutGuide.widthAnchor constant:-40],
    ]];
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.text = @"连接前配置 AI 方案，保存后连接或重连设备。凭证仅保留本次运行。";
    [self.formStack addArrangedSubview:descriptionLabel];
    self.providerControl = [[UISegmentedControl alloc] initWithItems:@[@"火山", @"MLT", @"WoQi"]];
    self.providerControl.selectedSegmentIndex = 0;
    [self.providerControl addTarget:self action:@selector(updateVisibleFields) forControlEvents:UIControlEventValueChanged];
    [self.formStack addArrangedSubview:self.providerControl];
    [self addField:@"authSDK" title:@"火山 authSdk（1–5）" secure:NO];
    self.fields[@"authSDK"].keyboardType = UIKeyboardTypeNumberPad;
    [self addField:@"product" title:@"火山 productId" secure:NO];
    [self addField:@"environment" title:@"火山 ppeEnv（可选）" secure:NO];
    [self addField:@"channel" title:@"MLT channelId" secure:NO];
    UIStackView *stagingRow = [[UIStackView alloc] init];
    stagingRow.axis = UILayoutConstraintAxisHorizontal;
    UILabel *stagingLabel = [[UILabel alloc] init];
    stagingLabel.text = @"MLT 测试环境";
    self.stagingSwitch = [[UISwitch alloc] init];
    [stagingRow addArrangedSubview:stagingLabel];
    [stagingRow addArrangedSubview:self.stagingSwitch];
    self.stagingRow = stagingRow;
    [self.formStack addArrangedSubview:stagingRow];
    [self addField:@"appKey" title:@"WoQi appKey" secure:YES];
    [self addField:@"appSecret" title:@"WoQi appSecret" secure:YES];
    UILabel *bundleLabel = [[UILabel alloc] init];
    bundleLabel.numberOfLines = 0;
    bundleLabel.text = [NSString stringWithFormat:@"Bundle ID：%@", NSBundle.mainBundle.bundleIdentifier];
    [self.formStack addArrangedSubview:bundleLabel];
    UILabel *pcmLabel = [[UILabel alloc] init];
    pcmLabel.numberOfLines = 0;
    pcmLabel.text = @"仅在已核实 PCM 为 16 kHz / 单声道 / signed 16-bit little-endian，且停止后无旧请求尾包进入下一请求时开启。当前暂无这些协议依据，请保持关闭；SCO 独立判定。";
    [self.formStack addArrangedSubview:pcmLabel];
    self.verifiedPCMSwitch = [[UISwitch alloc] init];
    self.verifiedPCMSwitch.accessibilityLabel = @"已核实原生 PCM 格式";
    [self.formStack addArrangedSubview:self.verifiedPCMSwitch];
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [saveButton setTitle:@"保存配置" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveSelection) forControlEvents:UIControlEventTouchUpInside];
    [self.formStack addArrangedSubview:saveButton];
    [self loadCurrentSelection];
    [self updateVisibleFields];
}

// 保持导航和安全区域的既有布局行为。
- (void)layoutViews {
    CGFloat top = MAX(self.ts_navigationBarTotalHeight, self.view.safeAreaInsets.top);
    self.formScrollView.frame = CGRectMake(0, top, self.view.bounds.size.width, self.view.bounds.size.height - top);
}

#pragma mark - 私有方法

// 显示字段标签，同时关闭自动补全以免改变授权内容。
- (void)addField:(NSString *)key title:(NSString *)title secure:(BOOL)secure {
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = title;
    field.accessibilityLabel = title;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.secureTextEntry = secure;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [field.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    self.fields[key] = field;
    [self.formStack addArrangedSubview:field];
}

// 原样回填配置；密钥控件使用安全输入。
- (void)loadCurrentSelection {
    TSAIProviderSelection *selection = [TSAIProviderSelection currentSelection];
    self.verifiedPCMSwitch.on = selection.chatPCMFormat == TSBudsAIChatPCMFormatSigned16LittleEndianMono16kHz;
    if (selection.providerType == TSAIProviderTypeAIWoQi) {
        self.providerControl.selectedSegmentIndex = 2;
        TSAIWoQiConfiguration *configuration = (id)selection.providerConfiguration;
        self.fields[@"appKey"].text = configuration.appKey;
        self.fields[@"appSecret"].text = configuration.appSecret;
    } else if (selection.providerType == TSAIProviderTypeAIBuds) {
        TSAIBudsConfiguration *configuration = (id)selection.providerConfiguration;
        self.providerControl.selectedSegmentIndex = configuration.preferredVendor == TSAIBudsVendorTypeMltCloud ? 1 : 0;
        self.fields[@"authSDK"].text = configuration.starBurstAuthSDK.stringValue;
        self.fields[@"product"].text = configuration.starBurstProductId;
        self.fields[@"environment"].text = configuration.starBurstPPEEnvironment;
        self.fields[@"channel"].text = configuration.mltCloudChannelId;
        self.stagingSwitch.on = configuration.mltCloudStagingEnvironment;
    }
}

// 切换方案只改变表单，不切换已激活 Context。
- (void)updateVisibleFields {
    NSInteger selected = self.providerControl.selectedSegmentIndex;
    for (NSString *key in @[@"authSDK", @"product", @"environment"]) { self.fields[key].hidden = selected != 0; }
    self.fields[@"channel"].hidden = selected != 1;
    self.stagingRow.hidden = selected != 1;
    self.fields[@"appKey"].hidden = selected != 2;
    self.fields[@"appSecret"].hidden = selected != 2;
}

// 原生连接参数冻结后不可原地替换，保存的新配置在下一次连接生效。
- (void)saveSelection {
    [self.view endEditing:YES];
    TSAIProviderType type = TSAIProviderTypeAIBuds;
    id<NSCopying> configuration;
    if (self.providerControl.selectedSegmentIndex == 2) {
        TSAIWoQiConfiguration *woqi = [[TSAIWoQiConfiguration alloc] init];
        woqi.appKey = self.fields[@"appKey"].text ?: @"";
        woqi.appSecret = self.fields[@"appSecret"].text ?: @"";
        configuration = woqi;
        type = TSAIProviderTypeAIWoQi;
    } else {
        BOOL isCloud = self.providerControl.selectedSegmentIndex == 1;
        TSAIBudsConfiguration *aibuds = [TSAIBudsConfiguration configurationWithPreferredVendor:
            isCloud ? TSAIBudsVendorTypeMltCloud : TSAIBudsVendorTypeStarBurst];
        if (isCloud) {
            aibuds.mltCloudChannelId = self.fields[@"channel"].text;
            aibuds.mltCloudStagingEnvironment = self.stagingSwitch.on;
        } else {
            NSString *mode = self.fields[@"authSDK"].text;
            if ([@[@"1", @"2", @"3", @"4", @"5"] containsObject:mode]) {
                aibuds.starBurstAuthSDK = @(mode.integerValue);
            }
            aibuds.starBurstProductId = self.fields[@"product"].text;
            NSString *environment = self.fields[@"environment"].text;
            aibuds.starBurstPPEEnvironment = environment.length > 0 ? environment : nil;
        }
        configuration = aibuds;
    }
    TSBudsAIChatPCMFormat format = self.verifiedPCMSwitch.on
        ? TSBudsAIChatPCMFormatSigned16LittleEndianMono16kHz : TSBudsAIChatPCMFormatUnknown;
    TSAIProviderSelection *selection = [[TSAIProviderSelection alloc] initWithProviderType:type
        configuration:configuration chatPCMFormat:format];
    NSError *error = nil;
    if (![TSAIProviderSelection applySelection:selection error:&error]) {
        [self showAlertWithMsg:error.localizedDescription];
        return;
    }
    [self showAlertWithMsg:@"已保存，请连接或重连设备后进入 AI 功能。"];
}

@end
#endif
