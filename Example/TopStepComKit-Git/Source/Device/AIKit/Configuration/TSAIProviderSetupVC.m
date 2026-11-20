#import "TSAIProviderSetupVC.h"
#if TS_BUDS_AI_INTEGRATION_AVAILABLE

#import <TopStepAIKit/TSAIBudsConfiguration.h>
#import <TopStepAIKit/TSAIWoQiConfiguration.h>

#import "TSAIProviderSelection.h"

@interface TSAIProviderSetupVC ()
// 表单当前编辑的设备项目号。
@property (nonatomic, copy, nullable) NSString *projectIdentifier;
// 显示并切换当前项目。
@property (nonatomic, strong) UIButton *projectButton;
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

// 搭建随键盘变化的项目配置表单。
- (void)setupViews {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存配置"
        style:UIBarButtonItemStyleDone target:self action:@selector(saveSelection)];
    self.formScrollView = [[UIScrollView alloc] init];
    self.formScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.formScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.formScrollView.alwaysBounceVertical = YES;
    self.formScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.formScrollView];
    self.formStack = [[UIStackView alloc] init];
    self.formStack.axis = UILayoutConstraintAxisVertical;
    self.formStack.spacing = 14;
    self.formStack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.formScrollView addSubview:self.formStack];
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.formScrollView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor],
        [self.formScrollView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor],
        [self.formScrollView.topAnchor constraintEqualToAnchor:safeArea.topAnchor],
        [self.formScrollView.bottomAnchor constraintEqualToAnchor:self.view.keyboardLayoutGuide.topAnchor],
        [self.formStack.leadingAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.leadingAnchor constant:20],
        [self.formStack.trailingAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.trailingAnchor constant:-20],
        [self.formStack.topAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.topAnchor constant:20],
        [self.formStack.bottomAnchor constraintEqualToAnchor:self.formScrollView.contentLayoutGuide.bottomAnchor constant:-24],
        [self.formStack.widthAnchor constraintEqualToAnchor:self.formScrollView.frameLayoutGuide.widthAnchor constant:-40],
    ]];
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.text = @"按设备项目号保存 AI 配置。更换建连参数后需重连设备。";
    [self.formStack addArrangedSubview:descriptionLabel];
    self.projectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.projectButton setTitle:@"选择项目号" forState:UIControlStateNormal];
    self.projectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
    [self.projectButton.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    [self.projectButton addTarget:self action:@selector(chooseProject) forControlEvents:UIControlEventTouchUpInside];
    [self.formStack addArrangedSubview:self.projectButton];
    self.providerControl = [[UISegmentedControl alloc] initWithItems:@[@"火山", @"MLT", @"WoQi"]];
    self.providerControl.selectedSegmentIndex = 0;
    [self.providerControl addTarget:self action:@selector(updateVisibleFields) forControlEvents:UIControlEventValueChanged];
    [self.formStack addArrangedSubview:self.providerControl];
    [self addField:@"authSDK" title:@"火山 authSdk（1–5）" secure:NO];
    [self configureAuthSDKKeyboard];
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
    [self updateVisibleFields];
    NSString *projectIdentifier = [TSAIProviderSelection currentBudsConnectionProjectIdentifier];
    if (projectIdentifier.length == 0) {
        projectIdentifier = [TSAIProviderSelection lastSavedProjectIdentifier];
    }
    if (projectIdentifier.length > 0) {
        [self loadProjectIdentifier:projectIdentifier];
    }
}

// 表单通过约束布局，跳过基类的列表布局。
- (void)layoutViews {
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
    field.returnKeyType = UIReturnKeyDone;
    [field addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    [field.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    self.fields[key] = field;
    [self.formStack addArrangedSubview:field];
}

// 为没有完成键的数字键盘提供收起入口。
- (void)configureAuthSDKKeyboard {
    UITextField *authSDKField = self.fields[@"authSDK"];
    authSDKField.keyboardType = UIKeyboardTypeNumberPad;
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成"
        style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    toolbar.items = @[flexibleSpace, doneButton];
    [toolbar sizeToFit];
    authSDKField.inputAccessoryView = toolbar;
}

// 结束编辑并收起键盘。
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

// 在连接前也可以输入设备项目号并读取对应配置。
- (void)chooseProject {
    [self dismissKeyboard];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"项目号"
        message:@"输入设备信息中显示的项目号。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *field) {
        field.placeholder = @"设备项目号";
        field.text = self.projectIdentifier;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    __weak UIAlertController *weakAlert = alert;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *projectIdentifier = [weakAlert.textFields.firstObject.text
            stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        BOOL sameProject = [projectIdentifier isEqualToString:strongSelf.projectIdentifier];
        if (projectIdentifier.length > 0 && (!sameProject || strongSelf.navigationItem.prompt)) {
            [strongSelf loadProjectIdentifier:projectIdentifier];
        }
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 切换项目时清除上一个项目的表单值；首次选新项目时保留已输入的草稿。
- (void)loadProjectIdentifier:(NSString *)projectIdentifier {
    NSError *error = nil;
    TSAIProviderSelection *selection = [TSAIProviderSelection savedSelectionForProjectIdentifier:projectIdentifier
                                                                                           error:&error];
    self.navigationItem.prompt = error.localizedDescription;
    BOOL keepDraft = self.projectIdentifier.length == 0 && !selection && !error;
    self.projectIdentifier = projectIdentifier;
    NSString *projectTitle = [NSString stringWithFormat:@"项目号：%@", projectIdentifier];
    [self.projectButton setTitle:projectTitle forState:UIControlStateNormal];
    if (!keepDraft) {
        [self loadSelection:selection];
        [self updateVisibleFields];
    }
}

// 原样回填指定项目的配置，密钥控件保持安全输入。
- (void)loadSelection:(nullable TSAIProviderSelection *)selection {
    for (UITextField *field in self.fields.allValues) {
        field.text = nil;
    }
    self.providerControl.selectedSegmentIndex = 0;
    self.stagingSwitch.on = NO;
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
    [self dismissKeyboard];
    NSInteger selected = self.providerControl.selectedSegmentIndex;
    for (NSString *key in @[@"authSDK", @"product", @"environment"]) { self.fields[key].hidden = selected != 0; }
    self.fields[@"channel"].hidden = selected != 1;
    self.stagingRow.hidden = selected != 1;
    self.fields[@"appKey"].hidden = selected != 2;
    self.fields[@"appSecret"].hidden = selected != 2;
}

// 根据保存结果提示当前连接重新鉴权或重连后生效。
- (void)saveSelection {
    if (self.projectIdentifier.length == 0) {
        [self chooseProject];
        return;
    }
    [self dismissKeyboard];
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
    TSAIProviderSelectionSaveResult result = [TSAIProviderSelection saveSelection:selection
        forProjectIdentifier:self.projectIdentifier error:&error];
    if (result == TSAIProviderSelectionSaveResultFailed) {
        [self showAlertWithMsg:error.localizedDescription];
        return;
    }
    self.navigationItem.prompt = nil;
    if (result == TSAIProviderSelectionSaveResultReauthenticating) {
        [self showAlertWithMsg:@"已保存，正在使用当前连接重新鉴权。"];
    } else if (result == TSAIProviderSelectionSaveResultRequiresReconnect) {
        [self showAlertWithMsg:@"已保存。建连参数已变更，重连设备后生效。"];
    } else {
        [self showAlertWithMsg:@"已保存，连接该项目设备后生效。"];
    }
}

@end
#endif
