//
//  TSMakeCustomDialVC.m
//  TopStepComKit_Example
//

#import "TSMakeCustomDialVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSDialEditorVC.h"
#import "TSDialEditorState.h"
#import "TSDialEditorAppearance.h"

@interface TSMakeCustomDialVC ()
// 每种类型独立的会话。
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, TSDialEditorState *> *sessions;
@property (nonatomic, strong) TSDialEditorState *currentSession;
@property (nonatomic, strong) UIImage *installedPreview;
@property (nonatomic, assign) TSDialDraftType installedType;
// 页面部件。
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIView *summaryCard;
@property (nonatomic, strong) UIImageView *summaryImage;
@property (nonatomic, strong) UILabel *summaryStatus;
@property (nonatomic, strong) UILabel *summaryTitle;
@property (nonatomic, strong) UILabel *summaryDetail;
@property (nonatomic, strong) UIButton *resumeButton;
@property (nonatomic, strong) UILabel *sectionTitle;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, copy) NSArray<UIButton *> *typeButtons;
@property (nonatomic, assign) BOOL previousNavigationHidden;
@end

@implementation TSMakeCustomDialVC

#pragma mark - 生命周期

// 只在进入某个类型时恢复其素材，避免一次解码全部草稿。
- (void)initData {
    [super initData];
    self.sessions = [NSMutableDictionary dictionary];
    self.currentSession = [TSDialEditorState stateForType:TSDialDraftTypeSingleImage];
    self.sessions[@(self.currentSession.draftType)] = self.currentSession;
}

// 使用原型的独立导航标题。
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.previousNavigationHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self refreshSummary];
    [self refreshCapabilities];
}

// 离开功能后恢复上层导航。
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:self.previousNavigationHidden animated:animated];
}

// 容器变化后重新排版。
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

#pragma mark - 公开方法

// 入口布局：当前内容与两列类型卡片。
- (void)setupViews {
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    self.view.backgroundColor = [TSDialEditorAppearance color:0xF6F5F2];
    self.headerView = [[UIView alloc] init];
    self.titleLabel = [TSDialEditorAppearance label:@"自定义表盘" size:18 color:0x252823];
    self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setTitle:@"〈 返回" forState:UIControlStateNormal];
    self.backButton.tintColor = [TSDialEditorAppearance color:0x647757];
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.headerView];
    [self.headerView addSubview:self.titleLabel];
    [self.headerView addSubview:self.backButton];
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [TSDialEditorAppearance color:0xFAFBF7];
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.scrollView];
    self.summaryCard = [[UIView alloc] init];
    self.summaryCard.backgroundColor = [TSDialEditorAppearance color:0xEEF2E7];
    self.summaryCard.layer.cornerRadius = 20;
    self.summaryCard.layer.borderWidth = 1;
    self.summaryCard.layer.borderColor = [TSDialEditorAppearance color:0xE4E9DB].CGColor;
    [self.scrollView addSubview:self.summaryCard];
    self.summaryImage = [[UIImageView alloc] init];
    self.summaryImage.contentMode = UIViewContentModeScaleAspectFill;
    self.summaryImage.clipsToBounds = YES;
    self.summaryImage.layer.borderWidth = 5;
    self.summaryImage.layer.borderColor = [TSDialEditorAppearance color:0x35402D].CGColor;
    self.summaryStatus = [TSDialEditorAppearance label:@"当前编辑内容" size:10 color:0x789464];
    self.summaryTitle = [TSDialEditorAppearance label:@"单图表盘" size:15 color:0x252823];
    self.summaryDetail = [TSDialEditorAppearance label:@"编辑内容已保留\n可继续制作专属表盘" size:10 color:0x889B78];
    self.summaryDetail.numberOfLines = 2;
    self.resumeButton = [TSDialEditorAppearance button:@"继续编辑" primary:NO];
    [self.resumeButton addTarget:self action:@selector(resumeEditing) forControlEvents:UIControlEventTouchUpInside];
    for (UIView *view in @[self.summaryImage, self.summaryStatus, self.summaryTitle, self.summaryDetail, self.resumeButton]) {
        [self.summaryCard addSubview:view];
    }
    self.sectionTitle = [TSDialEditorAppearance label:@"选择表盘类型" size:14 color:0x252823];
    self.sectionTitle.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [self.scrollView addSubview:self.sectionTitle];
    [self buildTypeCards];
    self.hintLabel = [TSDialEditorAppearance label:@"各类型的编辑内容都会保留，可随时继续。" size:11 color:0x9BA68F];
    self.hintLabel.numberOfLines = 0;
    [self.scrollView addSubview:self.hintLabel];
    [self refreshSummary];
}

// 页面始终是 iPhone 单列信息架构。
- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds), top = self.view.safeAreaInsets.top;
    self.headerView.frame = CGRectMake(0, top, width, 49);
    self.backButton.frame = CGRectMake(18, 0, 65, 49);
    self.titleLabel.frame = CGRectMake(85, 0, width - 170, 49);
    self.scrollView.frame = CGRectMake(0, top + 49, width, CGRectGetHeight(self.view.bounds) - top - 49);
    CGFloat contentWidth = width - 44;
    self.summaryCard.frame = CGRectMake(22, 25, contentWidth, 182);
    BOOL round = [TopStepComKit sharedInstance].connectedPeripheral.screenInfo.shape == eTSPeriphShapeCircle;
    self.summaryImage.frame = round ? CGRectMake(18, 33, 116, 116) : CGRectMake(18, 25, 106, 132);
    self.summaryImage.layer.cornerRadius = round ? 58 : 28;
    CGFloat infoLeft = round ? 151 : 141;
    self.summaryStatus.frame = CGRectMake(infoLeft, 24, contentWidth - infoLeft - 12, 20);
    self.summaryTitle.frame = CGRectMake(infoLeft, 46, contentWidth - infoLeft - 12, 25);
    self.summaryDetail.frame = CGRectMake(infoLeft, 75, contentWidth - infoLeft - 12, 38);
    self.resumeButton.frame = CGRectMake(infoLeft, 125, 86, 33);
    self.sectionTitle.frame = CGRectMake(22, 236, contentWidth, 20);
    CGFloat cardWidth = (contentWidth - 12) / 2;
    NSUInteger visibleIndex = 0;
    for (UIButton *button in self.typeButtons) {
        if (button.hidden) {
            continue;
        }
        button.frame = CGRectMake(22 + (visibleIndex % 2) * (cardWidth + 12),
                                 271 + (visibleIndex / 2) * 132, cardWidth, 120);
        [button viewWithTag:100].frame = CGRectMake(17, 17, 22, 22);
        [button viewWithTag:101].frame = CGRectMake(17, 49, cardWidth - 34, 22);
        [button viewWithTag:102].frame = CGRectMake(17, 82, cardWidth - 34, 20);
        visibleIndex++;
    }
    CGFloat end = 271 + ((visibleIndex + 1) / 2) * 132;
    self.hintLabel.frame = CGRectMake(22, end + 8, contentWidth, 50);
    self.scrollView.contentSize = CGSizeMake(width, end + 80 + self.view.safeAreaInsets.bottom);
}

#pragma mark - 私有方法

// 卡片的顺序、图标、文案直接对应 HTML。
- (void)buildTypeCards {
    NSArray *titles = @[@"单图表盘", @"多图表盘", @"视频表盘", @"弹幕表盘"];
    NSArray *details = @[@"一张照片，一个好时刻", @"多张照片，依次轮播",
                         @"将喜欢的片段戴在腕上", @"文字滚动，让心情动起来"];
    NSArray *icons = @[@"photo", @"album", @"video", @"danmu"];
    NSMutableArray *buttons = [NSMutableArray array];
    for (NSUInteger index = 0; index < 4; index++) {
        UIButton *button = [TSDialEditorAppearance button:@"" primary:NO];
        button.tag = index + TSDialDraftTypeSingleImage;
        button.backgroundColor = UIColor.whiteColor;
        button.layer.cornerRadius = 16;
        button.accessibilityLabel = titles[index];
        UIImageView *icon = [[UIImageView alloc] initWithImage:[TSDialEditorAppearance icon:icons[index]]];
        icon.tag = 100;
        icon.tintColor = [TSDialEditorAppearance color:0x7D916D];
        UILabel *title = [TSDialEditorAppearance label:titles[index] size:14 color:0x252823];
        title.tag = 101;
        UILabel *detail = [TSDialEditorAppearance label:details[index] size:10 color:0x9CA48F];
        detail.tag = 102;
        detail.adjustsFontSizeToFitWidth = YES;
        [button addSubview:icon];
        [button addSubview:title];
        [button addSubview:detail];
        [button addTarget:self action:@selector(openType:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        [buttons addObject:button];
    }
    self.typeButtons = buttons;
}

// 不把编辑中的变化覆盖到已安装快照。
- (void)refreshSummary {
    TSDialDraftType type = self.installedPreview ? self.installedType : self.currentSession.draftType;
    NSArray *titles = @[@"单图表盘", @"多图表盘", @"视频表盘", @"弹幕表盘"];
    self.summaryImage.image = self.installedPreview ?: self.currentSession.images.firstObject[@"image"];
    self.summaryTitle.text = titles[type - TSDialDraftTypeSingleImage];
    self.summaryStatus.text = self.installedPreview ? @"已设为当前表盘" : @"当前编辑内容";
    self.summaryDetail.text = self.installedPreview ? @"安装成功\n可返回编辑或选择其他类型" : @"编辑内容已保留\n可继续制作专属表盘";
}

// 统一能力决定入口可见性，不直接访问 Provider。
- (void)refreshCapabilities {
    TSDialCapability *capability = [[TopStepComKit sharedInstance].dial dialCapability];
    BOOL connected = [TopStepComKit sharedInstance].connectedPeripheral != nil;
    NSArray *supported = @[@(capability.supportsCustom), @(capability.supportsSlideshow),
                           @(capability.supportsVideo && capability.maxVideoDuration > 0), @(capability.supportsDanMu)];
    for (NSUInteger index = 0; index < self.typeButtons.count; index++) {
        self.typeButtons[index].hidden = !connected || !capability.supportsCustom || ![supported[index] boolValue];
    }
    self.resumeButton.enabled = connected && capability.supportsCustom;
    self.hintLabel.text = !connected ? @"连接手表后，可查看支持的表盘类型。" :
        !capability.supportsCustom ? @"当前设备不支持自定义表盘。" : @"各类型的编辑内容都会保留，可随时继续。";
    [self.view setNeedsLayout];
}

// 进入一种编辑会话。
- (void)openType:(UIButton *)sender {
    [self openEditorForType:sender.tag];
}

// 恢复指定类型，不依赖视图控件传递路由。
- (void)openEditorForType:(TSDialDraftType)type {
    TSDialEditorState *state = self.sessions[@(type)];
    if (!state) {
        state = [TSDialEditorState stateForType:type];
        self.sessions[@(type)] = state;
    }
    self.currentSession = state;
    TSDialEditorVC *editor = [[TSDialEditorVC alloc] initWithState:state];
    __weak typeof(self) weakSelf = self;
    editor.onPushSuccess = ^{
        if (weakSelf.onPushSuccess) {
            weakSelf.onPushSuccess();
        }
    };
    editor.onInstalledPreview = ^(UIImage *image) {
        weakSelf.installedPreview = image;
        weakSelf.installedType = type;
    };
    [self.navigationController pushViewController:editor animated:YES];
}

// 已安装卡的继续编辑回到原来的类型草稿。
- (void)resumeEditing {
    [self openEditorForType:self.installedPreview ? self.installedType : self.currentSession.draftType];
}

// 离开功能返回现有列表。
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
