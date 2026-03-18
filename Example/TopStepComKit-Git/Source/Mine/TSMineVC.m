//
//  TSMineVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMineVC.h"
#import "TSUserInfoVC.h"
#import "TSMineItemModel.h"


// ─── 用户头像卡片 ────────────────────────────────────────────────────────
@interface TSMineHeaderView : UIView
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *idLabel;
@end

@implementation TSMineHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ts_setup];
    }
    return self;
}

/**
 * 初始化头部视图
 */
- (void)ts_setup {
    self.backgroundColor = TSColor_Card;
    self.layer.cornerRadius = TSRadius_MD;

    // 头像
    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.backgroundColor = TSColor_Primary;
    self.avatarView.layer.cornerRadius = 35;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:40 weight:UIImageSymbolWeightRegular];
        self.avatarView.image = [UIImage systemImageNamed:@"person.fill" withConfiguration:config];
        self.avatarView.tintColor = [UIColor whiteColor];
    }
    [self addSubview:self.avatarView];

    // 用户名
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.text = @"用户";
    self.nameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.nameLabel.textColor = TSColor_TextPrimary;
    [self addSubview:self.nameLabel];

    // 用户 ID
    self.idLabel = [[UILabel alloc] init];
    self.idLabel.text = @"ID: 未登录";
    self.idLabel.font = [UIFont systemFontOfSize:14];
    self.idLabel.textColor = TSColor_TextSecondary;
    [self addSubview:self.idLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);

    // 头像在左侧
    self.avatarView.frame = CGRectMake(16, 20, 70, 70);

    // 用户名在头像右侧
    CGFloat textX = CGRectGetMaxX(self.avatarView.frame) + 16;
    CGFloat textW = w - textX - 16;
    self.nameLabel.frame = CGRectMake(textX, 32, textW, 24);

    // ID 在用户名下方
    self.idLabel.frame = CGRectMake(textX, CGRectGetMaxY(self.nameLabel.frame) + 4, textW, 18);
}

@end

// ─── 设置项 Cell ─────────────────────────────────────────────────────────
@interface TSMineCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *arrowLabel;
@end

@implementation TSMineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self ts_setup];
    }
    return self;
}

/**
 * 初始化 Cell
 */
- (void)ts_setup {
    self.backgroundColor = TSColor_Card;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // 图标
    self.iconView = [[UIImageView alloc] init];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.iconView];

    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textColor = TSColor_TextPrimary;
    [self.contentView addSubview:self.titleLabel];

    // 详情文字
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:14];
    self.detailLabel.textColor = TSColor_TextSecondary;
    self.detailLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.detailLabel];

    // 箭头
    self.arrowLabel = [[UILabel alloc] init];
    self.arrowLabel.text = @"›";
    self.arrowLabel.font = [UIFont systemFontOfSize:20];
    self.arrowLabel.textColor = TSColor_TextSecondary;
    [self.contentView addSubview:self.arrowLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.contentView.bounds);
    CGFloat h = CGRectGetHeight(self.contentView.bounds);

    // 图标
    self.iconView.frame = CGRectMake(16, (h - 24) / 2, 24, 24);

    // 箭头
    self.arrowLabel.frame = CGRectMake(w - 32, (h - 24) / 2, 16, 24);

    // 详情文字
    CGFloat detailW = 120;
    self.detailLabel.frame = CGRectMake(w - 32 - detailW - 8, (h - 20) / 2, detailW, 20);

    // 标题
    CGFloat titleX = CGRectGetMaxX(self.iconView.frame) + 12;
    CGFloat titleW = CGRectGetMinX(self.detailLabel.frame) - titleX - 8;
    self.titleLabel.frame = CGRectMake(titleX, (h - 20) / 2, titleW, 20);
}

@end

// ─── 空白页面 VC ─────────────────────────────────────────────────────────
@interface TSMinePlaceholderVC : TSBaseVC
@property (nonatomic, copy) NSString *pageName;
@end

@implementation TSMinePlaceholderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.pageName ?: @"功能";
    self.view.backgroundColor = TSColor_Background;

    // 图标
    UIImageView *iconView = [[UIImageView alloc] init];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:80 weight:UIImageSymbolWeightLight];
        iconView.image = [UIImage systemImageNamed:@"hammer.fill" withConfiguration:config];
        iconView.tintColor = TSColor_TextSecondary;
    }
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:iconView];

    // 文字
    UILabel *label = [[UILabel alloc] init];
    label.text = @"功能开发中...";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = TSColor_TextSecondary;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];

    // 布局（居中）
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);
    CGFloat centerY = screenH / 2;

    iconView.frame = CGRectMake((screenW - 100) / 2, centerY - 80, 100, 100);
    label.frame = CGRectMake(0, centerY + 30, screenW, 30);
}

/**
 * 覆写父类，禁止添加 sourceTableview
 */
- (void)setupViews {
}

/**
 * 覆写父类，禁止父类布局
 */
- (void)layoutViews {
}

@end

// ─── TSMineVC ────────────────────────────────────────────────────────────
@interface TSMineVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TSMineHeaderView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<TSMineItemModel *> *> *dataSource;
@end

@implementation TSMineVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ts_initData];
    [self ts_initViews];
}

#pragma mark - 覆写 TSBaseVC 基类方法

/**
 * 覆写父类，禁止添加 sourceTableview
 */
- (void)setupViews {
}

/**
 * 覆写父类，禁止父类布局
 */
- (void)layoutViews {
}

#pragma mark - 初始化

/**
 * 初始化数据
 */
- (void)ts_initData {
    self.title = @"我的";
    self.view.backgroundColor = TSColor_Background;

    // 构建数据源
    self.dataSource = @[
        // 第一组：账户相关
        @[
            [TSMineItemModel itemWithIcon:@"person.crop.circle" title:@"个人资料" detail:@"" action:@"userInfo"],
            [TSMineItemModel itemWithIcon:@"heart.fill" title:@"健康数据" detail:@"" action:@"health"],
        ],
        // 第二组：应用设置
        @[
            [TSMineItemModel itemWithIcon:@"bell.fill" title:@"消息通知" detail:@"已开启" action:@"notification"],
            [TSMineItemModel itemWithIcon:@"globe" title:@"语言设置" detail:@"简体中文" action:@"language"],
        ],
        // 第三组：其他
        @[
            [TSMineItemModel itemWithIcon:@"info.circle.fill" title:@"关于我们" detail:@"" action:@"about"],
            [TSMineItemModel itemWithIcon:@"doc.text.fill" title:@"隐私政策" detail:@"" action:@"privacy"],
            [TSMineItemModel itemWithIcon:@"star.fill" title:@"给我们评分" detail:@"" action:@"rate"],
        ],
    ];
}

/**
 * 初始化视图
 */
- (void)ts_initViews {
    // ScrollView
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = TSColor_Background;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];

    // 头部卡片
    self.headerView = [[TSMineHeaderView alloc] initWithFrame:CGRectMake(16, 16, CGRectGetWidth(self.view.bounds) - 32, 110)];
    [self.scrollView addSubview:self.headerView];

    // TableView
    CGFloat tableY = CGRectGetMaxY(self.headerView.frame) + 16;
    CGFloat tableH = 56 * 7 + 8 + 16 * 2;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableY, CGRectGetWidth(self.view.bounds), tableH) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = TSColor_Background;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorColor = TSColor_Separator;
    self.tableView.scrollEnabled = NO;
    [self.tableView registerClass:[TSMineCell class] forCellReuseIdentifier:@"TSMineCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.scrollView addSubview:self.tableView];

    // 设置 scrollView contentSize
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetMaxY(self.tableView.frame) + 20);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSMineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TSMineCell" forIndexPath:indexPath];
    TSMineItemModel *item = self.dataSource[indexPath.section][indexPath.row];

    cell.titleLabel.text = item.title;
    cell.detailLabel.text = item.detail;

    // 设置图标
    if (@available(iOS 13.0, *)) {
        UIImage *icon = [UIImage systemImageNamed:item.iconName];
        cell.iconView.image = icon;
        cell.iconView.tintColor = TSColor_Primary;
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 8 : 16;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = TSColor_Background;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TSMineItemModel *item = self.dataSource[indexPath.section][indexPath.row];

    if ([item.action isEqualToString:@"userInfo"]) {
        // 跳转到个人资料页
        TSUserInfoVC *vc = [[TSUserInfoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        // 其他功能跳转到空白页
        TSMinePlaceholderVC *vc = [[TSMinePlaceholderVC alloc] init];
        vc.pageName = item.title;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
