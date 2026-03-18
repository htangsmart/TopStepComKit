//
//  TSMessageVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/17.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSMessageVC.h"
#import "TSMessageSwitchCell.h"
#import "TSBaseVC.h"

// ─── 消息分组数据结构 ────────────────────────────────────────────────────────

@interface TSMessageItem : NSObject
@property (nonatomic, strong) TSMessageModel *model;
@property (nonatomic, copy)   NSString       *name;
@property (nonatomic, copy)   NSString       *iconName;
@property (nonatomic, strong) UIColor        *iconColor;
@end

@implementation TSMessageItem
@end

@interface TSMessageSection : NSObject
@property (nonatomic, copy)   NSString                   *title;
@property (nonatomic, strong) NSMutableArray<TSMessageItem *> *items;
+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray<TSMessageItem *> *)items;
@end

@implementation TSMessageSection
+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray<TSMessageItem *> *)items {
    TSMessageSection *sec = [[TSMessageSection alloc] init];
    sec.title = title;
    sec.items = [items mutableCopy];
    return sec;
}
@end

// ─── 总开关 Header View ────────────────────────────────────────────────────

@interface TSMessageHeaderView : UIView
@property (nonatomic, strong) UISwitch *masterSwitch;
@property (nonatomic, copy)   void(^onMasterChanged)(BOOL isOn);
@end

@implementation TSMessageHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        UIView *card = [[UIView alloc] init];
        card.backgroundColor = TSColor_Card;
        card.layer.cornerRadius = TSRadius_MD;
        card.layer.shadowColor  = [UIColor blackColor].CGColor;
        card.layer.shadowOpacity = 0.06;
        card.layer.shadowOffset  = CGSizeMake(0, 2);
        card.layer.shadowRadius  = 8;
        [self addSubview:card];

        // 图标背景
        UIView *iconBg = [[UIView alloc] initWithFrame:CGRectMake(16, 16, 40, 40)];
        iconBg.backgroundColor = TSColor_Primary;
        iconBg.layer.cornerRadius = 10;
        [card addSubview:iconBg];

        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 24, 24)];
        iconView.image = [UIImage systemImageNamed:@"bell.fill"];
        iconView.tintColor = UIColor.whiteColor;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [iconBg addSubview:iconView];

        // 标题 + 副标题
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text      = @"消息通知";
        titleLabel.font      = TSFont_H2;
        titleLabel.textColor = TSColor_TextPrimary;
        [card addSubview:titleLabel];

        UILabel *subLabel = [[UILabel alloc] init];
        subLabel.text      = @"开启后设备将接收应用消息推送";
        subLabel.font      = TSFont_Caption;
        subLabel.textColor = TSColor_TextSecondary;
        [card addSubview:subLabel];

        // 总开关标签
        UILabel *switchLabel = [[UILabel alloc] init];
        switchLabel.text      = @"全部开启";
        switchLabel.font      = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        switchLabel.textColor = TSColor_TextSecondary;
        [card addSubview:switchLabel];

        // 总开关
        _masterSwitch = [[UISwitch alloc] init];
        _masterSwitch.onTintColor = TSColor_Primary;
        [_masterSwitch addTarget:self action:@selector(onMasterSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [card addSubview:_masterSwitch];

        // 分隔线
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = TSColor_Separator;
        [card addSubview:line];

        // layout
        CGFloat cardW = frame.size.width - 32;
        card.frame = CGRectMake(16, 12, cardW, frame.size.height - 20);

        titleLabel.frame  = CGRectMake(68, 16, cardW - 68 - 16, 22);
        subLabel.frame    = CGRectMake(68, 40, cardW - 68 - 16, 17);

        CGFloat switchW = 51, switchH = 31;
        _masterSwitch.frame = CGRectMake(cardW - 16 - switchW, card.frame.size.height - 16 - switchH, switchW, switchH);
        switchLabel.frame   = CGRectMake(16, card.frame.size.height - 16 - switchH + 5, 100, 21);

        line.frame = CGRectMake(16, card.frame.size.height - 16 - switchH - 12, cardW - 32, 0.5);
    }
    return self;
}

- (void)onMasterSwitchChanged:(UISwitch *)sw {
    if (self.onMasterChanged) {
        self.onMasterChanged(sw.isOn);
    }
}

- (void)setMasterEnabled:(BOOL)enabled {
    _masterSwitch.enabled = enabled;
}

@end

// ─── TSMessageVC ──────────────────────────────────────────────────────────

@interface TSMessageVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView          *tableView;
@property (nonatomic, strong) TSMessageHeaderView  *headerView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) NSArray<TSMessageSection *> *sections;
@property (nonatomic, assign) BOOL                 isSyncing;

@end

@implementation TSMessageVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息通知";
    self.view.backgroundColor = TSColor_Background;

    [self ts_setupViews];
    [self ts_fetchFromDevice];
}

#pragma mark - Setup

/**
 * type → @{ name, icon, color, section }
 * 所有 TSMessageType 的展示元数据，section 用于分组排序。
 * 返回的 type 不在此表中时，归入"其他"并使用默认图标。
 */
+ (NSDictionary<NSNumber *, NSDictionary *> *)ts_metaMap {
    static NSDictionary *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#define ITEM(n, i, c, s) @{ @"name":(n), @"icon":(i), @"color":(c), @"section":(s) }
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1]
        map = @{
            // 系统通知
            @(TSMessage_Phone)            : ITEM(@"电话",              @"phone.fill",                TSColor_Success,                           @"系统通知"),
            @(TSMessage_Messages)         : ITEM(@"短信",              @"message.fill",               TSColor_Success,                           @"系统通知"),
            @(TSMessage_MissCall)         : ITEM(@"未接来电",           @"phone.arrow.down.left",      TSColor_Danger,                            @"系统通知"),
            @(TSMessage_Email)            : ITEM(@"邮件",              @"envelope.fill",              TSColor_Primary,                           @"系统通知"),
            @(TSMessage_Calendar)         : ITEM(@"日历",              @"calendar",                   TSColor_Danger,                            @"系统通知"),
            @(TSMessage_FaceTime)         : ITEM(@"FaceTime",          @"video.fill",                 TSColor_Success,                           @"系统通知"),
            // 国内社交
            @(TSMessage_WeChat)           : ITEM(@"微信",              @"message.circle.fill",        RGB(30,186,56),                            @"国内社交"),
            @(TSMessage_QQ)               : ITEM(@"QQ",                @"person.2.fill",              TSColor_Primary,                           @"国内社交"),
            @(TSMessage_Dingtalk)         : ITEM(@"钉钉",              @"bell.circle.fill",           RGB(56,143,255),                           @"国内社交"),
            @(TSMessage_Weibo)            : ITEM(@"微博",              @"globe",                      TSColor_Danger,                            @"国内社交"),
            @(TSMessage_Lark)             : ITEM(@"飞书",              @"paperplane.fill",            TSColor_Primary,                           @"国内社交"),
            @(TSMessage_Alipay)           : ITEM(@"支付宝",            @"creditcard.fill",            RGB(18,140,242),                           @"国内社交"),
            // 国际通讯
            @(TSMessage_WhatsApp)         : ITEM(@"WhatsApp",          @"message.fill",               RGB(43,184,87),                            @"国际通讯"),
            @(TSMessage_WhatsAppBusiness) : ITEM(@"WhatsApp Business", @"briefcase.fill",             RGB(43,184,87),                            @"国际通讯"),
            @(TSMessage_Telegram)         : ITEM(@"Telegram",          @"paperplane.fill",            RGB(36,153,222),                           @"国际通讯"),
            @(TSMessage_Line)             : ITEM(@"Line",              @"ellipsis.bubble.fill",       RGB(5,199,84),                             @"国际通讯"),
            @(TSMessage_Skype)            : ITEM(@"Skype",             @"phone.bubble.left.fill",     RGB(3,161,237),                            @"国际通讯"),
            @(TSMessage_Viber)            : ITEM(@"Viber",             @"phone.fill",                 TSColor_Purple,                            @"国际通讯"),
            @(TSMessage_Messenger)        : ITEM(@"Messenger",         @"message.fill",               TSColor_Primary,                           @"国际通讯"),
            @(TSMessage_KakaoTalk)        : ITEM(@"KakaoTalk",         @"bubble.left.fill",           RGB(250,222,20),                           @"国际通讯"),
            @(TSMessage_Zalo)             : ITEM(@"Zalo",              @"message.circle.fill",        RGB(0,104,183),                            @"国际通讯"),
            @(TSMessage_NateOn)           : ITEM(@"NateOn",            @"ellipsis.bubble.fill",       RGB(0,120,255),                            @"国际通讯"),
            @(TSMessage_Hike)             : ITEM(@"Hike",              @"arrow.up.message.fill",      TSColor_Success,                           @"国际通讯"),
            @(TSMessage_VK)               : ITEM(@"VK",                @"person.2.circle.fill",       RGB(70,127,196),                           @"国际通讯"),
            // 社交媒体
            @(TSMessage_Facebook)         : ITEM(@"Facebook",          @"person.2.circle.fill",       RGB(59,95,168),                            @"社交媒体"),
            @(TSMessage_Twitter)          : ITEM(@"Twitter",           @"bird.fill",                  RGB(29,161,242),                           @"社交媒体"),
            @(TSMessage_Instagram)        : ITEM(@"Instagram",         @"camera.fill",                TSColor_Pink,                              @"社交媒体"),
            @(TSMessage_Snapchat)         : ITEM(@"Snapchat",          @"camera.circle.fill",         TSColor_Warning,                           @"社交媒体"),
            @(TSMessage_Tiktok)           : ITEM(@"TikTok",            @"music.note",                 RGB(28,28,30),                             @"社交媒体"),
            @(TSMessage_YouTube)          : ITEM(@"YouTube",           @"play.rectangle.fill",        TSColor_Danger,                            @"社交媒体"),
            @(TSMessage_Discord)          : ITEM(@"Discord",           @"gamecontroller.fill",        TSColor_Indigo,                            @"社交媒体"),
            @(TSMessage_Reddit)           : ITEM(@"Reddit",            @"person.3.fill",              RGB(255,85,0),                             @"社交媒体"),
            @(TSMessage_LinkEdin)         : ITEM(@"LinkedIn",          @"network",                    RGB(0,119,181),                            @"社交媒体"),
            @(TSMessage_Pinterest)        : ITEM(@"Pinterest",         @"pin.fill",                   TSColor_Danger,                            @"社交媒体"),
            @(TSMessage_Hinge)            : ITEM(@"Hinge",             @"heart.fill",                 TSColor_Danger,                            @"社交媒体"),
            @(TSMessage_Bumble)           : ITEM(@"Bumble",            @"hexagon.fill",               TSColor_Warning,                           @"社交媒体"),
            // 工作效率
            @(TSMessage_Slack)            : ITEM(@"Slack",             @"person.2.fill",              TSColor_Purple,                            @"工作效率"),
            @(TSMessage_MicrosoftTeams)   : ITEM(@"Teams",             @"video.fill",                 TSColor_Indigo,                            @"工作效率"),
            @(TSMessage_Zoom)             : ITEM(@"Zoom",              @"video.circle.fill",          TSColor_Primary,                           @"工作效率"),
            @(TSMessage_Gmail)            : ITEM(@"Gmail",             @"envelope.fill",              TSColor_Danger,                            @"工作效率"),
            @(TSMessage_Outlook)          : ITEM(@"Outlook",           @"envelope.circle.fill",       TSColor_Primary,                           @"工作效率"),
            @(TSMessage_Yahoo)            : ITEM(@"Yahoo",             @"envelope.fill",              TSColor_Purple,                            @"工作效率"),
            @(TSMessage_Hangouts)         : ITEM(@"Hangouts",          @"phone.bubble.left.fill",     TSColor_Success,                           @"工作效率"),
            @(TSMessage_GoogleChat)       : ITEM(@"Google Chat",       @"bubble.left.and.bubble.right.fill", TSColor_Success,                    @"工作效率"),
            @(TSMessage_GoogleDrive)      : ITEM(@"Google Drive",      @"externaldrive.fill",         TSColor_Warning,                           @"工作效率"),
            @(TSMessage_GoogleMaps)       : ITEM(@"Google Maps",       @"map.fill",                   TSColor_Success,                           @"工作效率"),
            // 购物
            @(TSMessage_Amazon)           : ITEM(@"Amazon",            @"cart.fill",                  TSColor_Warning,                           @"购物"),
            @(TSMessage_Flipkart)         : ITEM(@"Flipkart",          @"bag.fill",                   RGB(39,116,228),                           @"购物"),
            @(TSMessage_Shopee)           : ITEM(@"Shopee",            @"bag.circle.fill",            RGB(238,77,45),                            @"购物"),
            @(TSMessage_Tokopedia)        : ITEM(@"Tokopedia",         @"cart.circle.fill",           RGB(66,182,74),                            @"购物"),
            @(TSMessage_Myntra)           : ITEM(@"Myntra",            @"tshirt.fill",                TSColor_Pink,                              @"购物"),
            @(TSMessage_Meesho)           : ITEM(@"Meesho",            @"bag.fill",                   TSColor_Purple,                            @"购物"),
            @(TSMessage_Zivame)           : ITEM(@"Zivame",            @"cart.fill",                  TSColor_Pink,                              @"购物"),
            @(TSMessage_Ajio)             : ITEM(@"Ajio",              @"bag.fill",                   RGB(28,28,30),                             @"购物"),
            @(TSMessage_Urbanic)          : ITEM(@"Urbanic",           @"tshirt.fill",                RGB(28,28,30),                             @"购物"),
            @(TSMessage_Nykaa)            : ITEM(@"Nykaa",             @"sparkles",                   TSColor_Pink,                              @"购物"),
            @(TSMessage_Tira)             : ITEM(@"Tira",              @"cart.badge.plus",            TSColor_Warning,                           @"购物"),
            @(TSMessage_Swiggy)           : ITEM(@"Swiggy",            @"fork.knife.circle.fill",     TSColor_Warning,                           @"购物"),
            @(TSMessage_Zomato)           : ITEM(@"Zomato",            @"fork.knife.circle.fill",     TSColor_Danger,                            @"购物"),
            // 出行与支付
            @(TSMessage_Uber)             : ITEM(@"Uber",              @"car.fill",                   RGB(28,28,30),                             @"出行与支付"),
            @(TSMessage_Ola)              : ITEM(@"Ola",               @"car.circle.fill",            RGB(17,139,78),                            @"出行与支付"),
            @(TSMessage_Lyft)             : ITEM(@"Lyft",              @"car.fill",                   TSColor_Pink,                              @"出行与支付"),
            @(TSMessage_Gojek)            : ITEM(@"Gojek",             @"motorcycle.fill",            RGB(0,171,95),                             @"出行与支付"),
            @(TSMessage_Garb)             : ITEM(@"Grab",              @"car.fill",                   RGB(0,177,79),                             @"出行与支付"),
            @(TSMessage_Phonepe)          : ITEM(@"PhonePe",           @"iphone",                     TSColor_Indigo,                            @"出行与支付"),
            @(TSMessage_Gpay)             : ITEM(@"Google Pay",        @"g.circle.fill",              TSColor_Primary,                           @"出行与支付"),
            @(TSMessage_Paytm)            : ITEM(@"Paytm",             @"indianrupeesign.circle.fill", RGB(0,145,236),                           @"出行与支付"),
            // 娱乐与健康
            @(TSMessage_YtMusic)          : ITEM(@"YouTube Music",     @"music.note.list",            TSColor_Danger,                            @"娱乐与健康"),
            @(TSMessage_AppleMusic)       : ITEM(@"Apple Music",       @"music.note",                 TSColor_Danger,                            @"娱乐与健康"),
            @(TSMessage_NetFlix)          : ITEM(@"Netflix",           @"play.tv.fill",               TSColor_Danger,                            @"娱乐与健康"),
            @(TSMessage_Hotstar)          : ITEM(@"Hotstar",           @"tv.fill",                    RGB(0,30,141),                             @"娱乐与健康"),
            @(TSMessage_AmazonPrime)      : ITEM(@"Prime Video",       @"play.circle.fill",           RGB(0,168,225),                            @"娱乐与健康"),
            @(TSMessage_Wynk)             : ITEM(@"Wynk Music",        @"headphones.circle.fill",     TSColor_Indigo,                            @"娱乐与健康"),
            @(TSMessage_Gaana)            : ITEM(@"Gaana",             @"headphones",                 TSColor_Danger,                            @"娱乐与健康"),
            @(TSMessage_Healthifyme)      : ITEM(@"HealthifyMe",       @"heart.fill",                 TSColor_Success,                           @"娱乐与健康"),
            @(TSMessage_Cultfit)          : ITEM(@"Cult.fit",          @"figure.run",                 TSColor_Success,                           @"娱乐与健康"),
            @(TSMessage_Flo)              : ITEM(@"Flo",               @"heart.circle.fill",          TSColor_Pink,                              @"娱乐与健康"),
            // 资讯与其他
            @(TSMessage_DailyHunt)        : ITEM(@"DailyHunt",         @"newspaper.fill",             TSColor_Warning,                           @"其他"),
            @(TSMessage_Inshorts)         : ITEM(@"Inshorts",          @"doc.text.fill",              RGB(28,28,30),                             @"其他"),
            @(TSMessage_ReflexApp)        : ITEM(@"ReflexApp",         @"dumbbell.fill",              TSColor_Indigo,                            @"其他"),
            @(TSMessage_MormaiiSmartwatches): ITEM(@"Mormaii",         @"applewatch",                 TSColor_Teal,                              @"其他"),
            @(TSMessage_Fastrack)         : ITEM(@"Fastrack",          @"applewatch.radiowaves.left.and.right", TSColor_Primary,                @"其他"),
            @(TSMessage_TitanSmartWorld)  : ITEM(@"Titan Smart World", @"applewatch",                 RGB(28,28,30),                             @"其他"),
            @(TSMessage_Other)            : ITEM(@"其他应用",           @"app.fill",                   TSColor_Gray,                              @"其他"),
        };
#undef ITEM
#undef RGB
    });
    return map;
}

// 分组展示顺序
+ (NSArray<NSString *> *)ts_sectionOrder {
    return @[@"系统通知", @"国内社交", @"国际通讯", @"社交媒体", @"工作效率", @"购物", @"出行与支付", @"娱乐与健康", @"其他"];
}

/**
 * 根据 SDK 返回的模型列表动态构建分组
 */
- (void)ts_buildSectionsFromModels:(NSArray<TSMessageModel *> *)models {
    NSDictionary *metaMap    = [TSMessageVC ts_metaMap];
    NSArray      *order      = [TSMessageVC ts_sectionOrder];

    // section title → items（有序）
    NSMutableDictionary<NSString *, NSMutableArray<TSMessageItem *> *> *buckets = [NSMutableDictionary dictionary];
    for (NSString *title in order) {
        buckets[title] = [NSMutableArray array];
    }

    for (TSMessageModel *model in models) {
        if (model.type == TSMessage_Total) continue;

        NSDictionary *meta    = metaMap[@(model.type)];
        NSString *name        = meta[@"name"]    ?: [NSString stringWithFormat:@"App(%ld)", (long)model.type];
        NSString *iconName    = meta[@"icon"]    ?: @"app.fill";
        UIColor  *iconColor   = meta[@"color"]   ?: TSColor_Gray;
        NSString *sectionTitle = meta[@"section"] ?: @"其他";

        // 确保 bucket 存在（处理 meta 里新 section 名）
        if (!buckets[sectionTitle]) {
            buckets[sectionTitle] = [NSMutableArray array];
        }

        TSMessageItem *item = [[TSMessageItem alloc] init];
        item.model     = model;
        item.name      = name;
        item.iconName  = iconName;
        item.iconColor = iconColor;
        [buckets[sectionTitle] addObject:item];
    }

    // 按 order 顺序组装 sections，过滤空分组
    NSMutableArray<TSMessageSection *> *sections = [NSMutableArray array];
    for (NSString *title in order) {
        NSArray *items = buckets[title];
        if (items.count > 0) {
            [sections addObject:[TSMessageSection sectionWithTitle:title items:items]];
        }
    }
    // order 之外的多余分组追加到末尾
    for (NSString *title in buckets) {
        if (![order containsObject:title] && buckets[title].count > 0) {
            [sections addObject:[TSMessageSection sectionWithTitle:title items:buckets[title]]];
        }
    }
    self.sections = [sections copy];
}

// 阻止 TSBaseVC 的 sourceTableview 被创建和添加到视图（否则两个 tableView 共享同一 dataSource，Cell 未注册会崩溃）
- (void)setupViews {}
- (void)layoutViews {}

- (void)ts_setupViews {
    // Header
    _headerView = [[TSMessageHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 130)];
    __weak typeof(self) weakSelf = self;
    _headerView.onMasterChanged = ^(BOOL isOn) {
        [weakSelf ts_applyMasterSwitch:isOn];
    };

    // TableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    _tableView.backgroundColor = TSColor_Background;
    _tableView.separatorColor  = TSColor_Separator;
    _tableView.tableHeaderView = _headerView;
    [_tableView registerClass:[TSMessageSwitchCell class] forCellReuseIdentifier:@"TSMessageSwitchCell"];
    if (@available(iOS 15.0, *)) {
        _tableView.sectionHeaderTopPadding = 0;
    }
    [self.view addSubview:_tableView];

    // Loading
    _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _loadingView.color = TSColor_Primary;
    _loadingView.hidesWhenStopped = YES;
    [self.view addSubview:_loadingView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _tableView.frame = self.view.bounds;
    _loadingView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
}

#pragma mark - Fetch

- (void)ts_fetchFromDevice {
    [self ts_setLoadingState:YES];
    __weak typeof(self) weakSelf = self;

    [[[TopStepComKit sharedInstance] message] getMessageEnableList:^(NSArray<TSMessageModel *> *notifications, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf ts_setLoadingState:NO];
            if (error || notifications.count == 0) {
                [weakSelf ts_showToast:@"获取失败，请重试" success:NO];
                return;
            }
            [weakSelf ts_buildSectionsFromModels:notifications];
            [weakSelf.tableView reloadData];
            [weakSelf ts_refreshMasterSwitch];
        });
    }];
}

#pragma mark - Master Switch

- (void)ts_applyMasterSwitch:(BOOL)isOn {
    for (TSMessageSection *section in self.sections) {
        for (TSMessageItem *item in section.items) {
            item.model.enable = isOn;
        }
    }
    [self.tableView reloadData];
    [self ts_syncToDevice];
}

- (void)ts_refreshMasterSwitch {
    BOOL allOn = YES;
    for (TSMessageSection *section in self.sections) {
        for (TSMessageItem *item in section.items) {
            if (!item.model.isEnable) { allOn = NO; break; }
        }
        if (!allOn) break;
    }
    [UIView setAnimationsEnabled:NO];
    _headerView.masterSwitch.on = allOn;
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - Sync

- (void)ts_syncToDevice {
    self.isSyncing = YES;
    [_headerView setMasterEnabled:NO];

    NSMutableArray<TSMessageModel *> *list = [NSMutableArray array];
    for (TSMessageSection *section in self.sections) {
        for (TSMessageItem *item in section.items) {
            [list addObject:item.model];
        }
    }

    __weak typeof(self) weakSelf = self;
    [[[TopStepComKit sharedInstance] message] setMessageEnableList:list
                                                       completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isSyncing = NO;
            [weakSelf.headerView setMasterEnabled:YES];
            if (success) {
                [weakSelf ts_showToast:@"同步成功" success:YES];
            } else {
                [weakSelf ts_showToast:@"同步失败，请重试" success:NO];
            }
        });
    }];
}

#pragma mark - Loading State

- (void)ts_setLoadingState:(BOOL)loading {
    if (loading) {
        [_loadingView startAnimating];
        _tableView.alpha = 0.4;
        _tableView.userInteractionEnabled = NO;
    } else {
        [_loadingView stopAnimating];
        _tableView.alpha = 1.0;
        _tableView.userInteractionEnabled = YES;
    }
}

#pragma mark - Toast

- (void)ts_showToast:(NSString *)message success:(BOOL)success {
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = success ? TSColor_Success : TSColor_Danger;
    toast.layer.cornerRadius = 20;
    toast.alpha = 0;
    toast.clipsToBounds = YES;

    UIImageView *icon = [[UIImageView alloc] init];
    icon.image = [UIImage systemImageNamed:success ? @"checkmark.circle.fill" : @"xmark.circle.fill"];
    icon.tintColor = UIColor.whiteColor;
    icon.contentMode = UIViewContentModeScaleAspectFit;

    UILabel *label = [[UILabel alloc] init];
    label.text      = message;
    label.font      = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    label.textColor = UIColor.whiteColor;

    [toast addSubview:icon];
    [toast addSubview:label];
    [self.view addSubview:toast];

    // 计算宽度
    CGFloat iconSize = 20;
    CGSize textSize  = [label sizeThatFits:CGSizeMake(300, 40)];
    CGFloat toastW   = iconSize + 8 + textSize.width + 32;
    CGFloat toastH   = 40;
    CGFloat safeBottom = self.view.safeAreaInsets.bottom;
    toast.frame = CGRectMake((self.view.bounds.size.width - toastW) / 2,
                             self.view.bounds.size.height - safeBottom - toastH - 16,
                             toastW, toastH);
    icon.frame  = CGRectMake(12, 10, iconSize, iconSize);
    label.frame = CGRectMake(CGRectGetMaxX(icon.frame) + 8, 0, textSize.width, toastH);

    [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 1; } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{ toast.alpha = 0; } completion:^(BOOL done) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSMessageSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TSMessageSwitchCell" forIndexPath:indexPath];
    TSMessageItem *item = self.sections[indexPath.section].items[indexPath.row];
    [cell configureWithModel:item.model
                    iconName:item.iconName
                   iconColor:item.iconColor
                        name:item.name];
    [cell setEnabled:!self.isSyncing];

    __weak typeof(self) weakSelf = self;
    __weak TSMessageItem *weakItem = item;
    cell.onSwitchChanged = ^(BOOL isOn) {
        weakItem.model.enable = isOn;
        [weakSelf ts_refreshMasterSwitch];
        [weakSelf ts_syncToDevice];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
    }
    header.textLabel.text  = self.sections[section].title;
    header.textLabel.font  = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    header.textLabel.textColor = TSColor_TextSecondary;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
