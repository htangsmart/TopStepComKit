//
//  TSAIAudioRecordHistoryVC.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordHistoryVC.h"

#import "TSAIAudioRecordDetailVC.h"
#import "TSAIAudioRecordDraftStore.h"
#import "TSAIAudioRecordGradientView.h"

static const CGFloat kTSAIAudioRecordHistoryRowHeight = 82.0;

@interface TSAIAudioRecordHistoryCell : UITableViewCell

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *durationLabel;

- (void)configureWithMetadata:(NSDictionary<NSString *, id> *)metadata;

@end

@interface TSAIAudioRecordHistoryVC ()

@property (nonatomic, strong) UITableView *historyTableView;
@property (nonatomic, copy) NSArray<NSDictionary<NSString *, id> *> *recordingMetadata;
@property (nonatomic, strong) UILabel *recordingCountLabel;
@property (nonatomic, strong) UILabel *totalDurationLabel;
@property (nonatomic, strong) TSAIAudioRecordDraftStore *draftStore;
// 右上角管理/完成按钮
@property (nonatomic, strong) UIButton *manageButton;
// 多选管理模式下的底部工具条
@property (nonatomic, strong) UIView *managementToolbar;
// 全选/取消全选
@property (nonatomic, strong) UIButton *selectAllButton;
// 删除选中项
@property (nonatomic, strong) UIButton *deleteSelectedButton;
// 列表底部约束，管理模式下让出工具条高度
@property (nonatomic, strong) NSLayoutConstraint *tableBottomConstraint;
// 无录音时的空态占位
@property (nonatomic, strong) UIView *emptyFooterView;
// 是否处于多选管理模式
@property (nonatomic, assign, getter=isManaging) BOOL managing;

@end

@implementation TSAIAudioRecordHistoryVC

#pragma mark - 生命周期

/** 初始化历史记录数据 */
- (void)initData {
    [super initData];
    self.title = @"历史录音";
    self.view.backgroundColor = [UIColor colorWithRed:245.0 / 255.0
                                                green:246.0 / 255.0
                                                 blue:251.0 / 255.0
                                                alpha:1.0];
    self.draftStore = [[TSAIAudioRecordDraftStore alloc] init];
    self.recordingMetadata = [self.draftStore loadRecordingMetadata];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleHistoryDidChange:)
                                                 name:TSAIAudioRecordHistoryDidChangeNotification
                                               object:nil];
}

/** 从详情页返回时同步最新记录 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadRecordings];
}

/** 移除通知观察 */
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** 创建历史记录页面 */
- (void)setupViews {
    self.historyTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.historyTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.historyTableView.backgroundColor = UIColor.clearColor;
    self.historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.historyTableView.showsVerticalScrollIndicator = NO;
    self.historyTableView.rowHeight = kTSAIAudioRecordHistoryRowHeight;
    self.historyTableView.estimatedRowHeight = kTSAIAudioRecordHistoryRowHeight;
    self.historyTableView.allowsMultipleSelectionDuringEditing = YES;
    self.historyTableView.dataSource = self;
    self.historyTableView.delegate = self;
    [self.historyTableView registerClass:TSAIAudioRecordHistoryCell.class
                  forCellReuseIdentifier:@"TSAIAudioRecordHistoryCell"];
    self.historyTableView.tableHeaderView = [self historyHeaderView];
    [self.view addSubview:self.historyTableView];
    self.tableBottomConstraint = [self.historyTableView.bottomAnchor
        constraintEqualToAnchor:self.view.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [self.historyTableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.historyTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:18.0],
        [self.historyTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-18.0],
        self.tableBottomConstraint,
    ]];
    [self installManagementToolbar];
    [self refreshEmptyState];

    UIColor *navigationColor = [UIColor colorWithRed:16.0 / 255.0
                                               green:20.0 / 255.0
                                                blue:45.0 / 255.0
                                               alpha:1.0];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0, 0.0, 36.0, 36.0);
    backButton.titleLabel.font = [UIFont systemFontOfSize:23.0 weight:UIFontWeightRegular];
    [backButton setTitle:@"‹" forState:UIControlStateNormal];
    [backButton setTitleColor:navigationColor forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    self.manageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.manageButton.frame = CGRectMake(0.0, 0.0, 44.0, 36.0);
    self.manageButton.tintColor = navigationColor;
    self.manageButton.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
    [self.manageButton addTarget:self
                          action:@selector(handleManage)
                forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.manageButton];
    [self refreshManageButton];
}

/** Auto Layout 已完成页面布局 */
- (void)layoutViews {
}

#pragma mark - 私有方法 - 视图

/** 创建历史记录头图 */
- (UIView *)historyHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 180.0)];
    TSAIAudioRecordGradientView *heroView = [[TSAIAudioRecordGradientView alloc]
        initWithFrame:CGRectMake(0.0, 6.0, 1.0, 144.0)];
    heroView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:heroView];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 18.0, 260.0, 28.0)];
    titleLabel.text = @"Your recordings";
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
    [heroView addSubview:titleLabel];
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 50.0, 300.0, 34.0)];
    detailLabel.text = @"录音文件保存在本机。支持播放、转写、翻译与 AI 总结。";
    detailLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.76];
    detailLabel.font = [UIFont systemFontOfSize:11.0];
    detailLabel.numberOfLines = 2;
    [heroView addSubview:detailLabel];
    self.recordingCountLabel = [self metricLabelWithFrame:CGRectMake(20.0, 96.0, 130.0, 40.0)];
    self.totalDurationLabel = [self metricLabelWithFrame:CGRectMake(190.0, 96.0, 130.0, 40.0)];
    self.totalDurationLabel.textAlignment = NSTextAlignmentRight;
    [heroView addSubview:self.recordingCountLabel];
    [heroView addSubview:self.totalDurationLabel];
    [self refreshMetrics];

    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 158.0, 200.0, 18.0)];
    sectionLabel.text = @"最近录音";
    sectionLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightBold];
    sectionLabel.textColor = [UIColor colorWithRed:16.0 / 255.0
                                             green:20.0 / 255.0
                                              blue:45.0 / 255.0
                                             alpha:1.0];
    [headerView addSubview:sectionLabel];
    UILabel *storageLabel = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 158.0, 100.0, 18.0)];
    storageLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    storageLabel.text = @"本地文件";
    storageLabel.textAlignment = NSTextAlignmentRight;
    storageLabel.font = [UIFont systemFontOfSize:10.0];
    storageLabel.textColor = [UIColor colorWithRed:156.0 / 255.0
                                             green:162.0 / 255.0
                                              blue:184.0 / 255.0
                                             alpha:1.0];
    [headerView addSubview:storageLabel];
    return headerView;
}

/** 创建头图指标标签 */
- (UILabel *)metricLabelWithFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 2;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:11.0];
    return label;
}

/** 安装管理模式底部工具条（默认隐藏） */
- (void)installManagementToolbar {
    self.managementToolbar = [[UIView alloc] init];
    self.managementToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    self.managementToolbar.backgroundColor = UIColor.whiteColor;
    self.managementToolbar.layer.shadowColor = UIColor.blackColor.CGColor;
    self.managementToolbar.layer.shadowOpacity = 0.06;
    self.managementToolbar.layer.shadowRadius = 8.0;
    self.managementToolbar.layer.shadowOffset = CGSizeMake(0.0, -3.0);
    self.managementToolbar.hidden = YES;
    [self.view addSubview:self.managementToolbar];

    self.selectAllButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.selectAllButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.selectAllButton.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
    self.selectAllButton.tintColor = [UIColor colorWithRed:16.0 / 255.0
                                                     green:20.0 / 255.0
                                                      blue:45.0 / 255.0
                                                     alpha:1.0];
    [self.selectAllButton addTarget:self
                             action:@selector(handleSelectAll)
                   forControlEvents:UIControlEventTouchUpInside];
    self.deleteSelectedButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteSelectedButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.deleteSelectedButton.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
    self.deleteSelectedButton.tintColor = [UIColor colorWithRed:255.0 / 255.0
                                                          green:77.0 / 255.0
                                                           blue:94.0 / 255.0
                                                          alpha:1.0];
    [self.deleteSelectedButton addTarget:self
                                  action:@selector(handleDeleteSelected)
                        forControlEvents:UIControlEventTouchUpInside];
    [self.managementToolbar addSubview:self.selectAllButton];
    [self.managementToolbar addSubview:self.deleteSelectedButton];
    [NSLayoutConstraint activateConstraints:@[
        [self.managementToolbar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.managementToolbar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.managementToolbar.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.managementToolbar.topAnchor
            constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-56.0],
        [self.selectAllButton.leadingAnchor
            constraintEqualToAnchor:self.managementToolbar.leadingAnchor constant:18.0],
        [self.selectAllButton.topAnchor constraintEqualToAnchor:self.managementToolbar.topAnchor],
        [self.selectAllButton.heightAnchor constraintEqualToConstant:56.0],
        [self.deleteSelectedButton.trailingAnchor
            constraintEqualToAnchor:self.managementToolbar.trailingAnchor constant:-18.0],
        [self.deleteSelectedButton.topAnchor constraintEqualToAnchor:self.managementToolbar.topAnchor],
        [self.deleteSelectedButton.heightAnchor constraintEqualToConstant:56.0],
    ]];
    [self refreshManagementToolbar];
}

#pragma mark - 私有方法 - 状态刷新

/** 重新加载本地录音并刷新所有依赖视图 */
- (void)reloadRecordings {
    self.recordingMetadata = [self.draftStore loadRecordingMetadata];
    [self refreshMetrics];
    [self.historyTableView reloadData];
    [self refreshEmptyState];
    if (self.isManaging && self.recordingMetadata.count == 0) {
        self.managing = NO;
        return;
    }
    [self refreshManageButton];
    [self refreshManagementToolbar];
}

/** 刷新录音数量和总时长 */
- (void)refreshMetrics {
    NSInteger totalMilliseconds = 0;
    for (NSDictionary<NSString *, id> *metadata in self.recordingMetadata) {
        totalMilliseconds += [metadata[@"durationMilliseconds"] integerValue];
    }
    NSString *recordingCount = [NSString stringWithFormat:@"%lu",
                                (unsigned long)self.recordingMetadata.count];
    self.recordingCountLabel.attributedText = [self metricTextWithValue:recordingCount
                                                                  title:@"RECORDINGS"];
    NSInteger totalMinutes = totalMilliseconds / 60000;
    NSString *totalDuration = [NSString stringWithFormat:@"%ldh %02ldm",
                               (long)(totalMinutes / 60),
                               (long)(totalMinutes % 60)];
    self.totalDurationLabel.attributedText = [self metricTextWithValue:totalDuration
                                                                 title:@"TOTAL AUDIO"];
}

/** 无录音时显示空态占位 */
- (void)refreshEmptyState {
    if (self.recordingMetadata.count > 0) {
        self.historyTableView.tableFooterView = nil;
        return;
    }
    if (!self.emptyFooterView) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 140.0)];
        UILabel *emptyLabel = [[UILabel alloc] initWithFrame:footerView.bounds];
        emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        emptyLabel.text = @"暂无录音\n完成一次 AI 录音后会保存在这里";
        emptyLabel.numberOfLines = 0;
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.font = [UIFont systemFontOfSize:13.0];
        emptyLabel.textColor = [UIColor colorWithRed:156.0 / 255.0
                                               green:162.0 / 255.0
                                                blue:184.0 / 255.0
                                               alpha:1.0];
        [footerView addSubview:emptyLabel];
        self.emptyFooterView = footerView;
    }
    self.historyTableView.tableFooterView = self.emptyFooterView;
}

/** 右上角按钮：无记录时隐藏，管理中显示“完成” */
- (void)refreshManageButton {
    self.manageButton.hidden = self.recordingMetadata.count == 0;
    [self.manageButton setTitle:self.isManaging ? @"完成" : @"管理" forState:UIControlStateNormal];
}

/** 工具条：按选中数量刷新全选与删除按钮 */
- (void)refreshManagementToolbar {
    NSUInteger selectedCount = self.historyTableView.indexPathsForSelectedRows.count;
    BOOL allSelected = self.recordingMetadata.count > 0 && selectedCount == self.recordingMetadata.count;
    [self.selectAllButton setTitle:allSelected ? @"取消全选" : @"全选" forState:UIControlStateNormal];
    NSString *deleteTitle = selectedCount > 0
        ? [NSString stringWithFormat:@"删除 (%lu)", (unsigned long)selectedCount]
        : @"删除";
    [self.deleteSelectedButton setTitle:deleteTitle forState:UIControlStateNormal];
    self.deleteSelectedButton.enabled = selectedCount > 0;
}

/** 进入/退出多选管理模式 */
- (void)setManaging:(BOOL)managing {
    if (_managing == managing) {
        return;
    }
    _managing = managing;
    if (!managing) {
        for (NSIndexPath *indexPath in self.historyTableView.indexPathsForSelectedRows) {
            [self.historyTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    [self.historyTableView setEditing:managing animated:YES];
    self.managementToolbar.hidden = !managing;
    self.tableBottomConstraint.constant = managing
        ? -(56.0 + self.view.safeAreaInsets.bottom)
        : 0.0;
    [self refreshManageButton];
    [self refreshManagementToolbar];
}

/** 创建与 HTML 字号一致的头图指标文本 */
- (NSAttributedString *)metricTextWithValue:(NSString *)value title:(NSString *)title {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
        initWithString:[NSString stringWithFormat:@"%@\n%@", value, title]];
    NSRange valueRange = NSMakeRange(0, value.length);
    [text addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold]
                 range:valueRange];
    [text addAttribute:NSFontAttributeName
                 value:[UIFont systemFontOfSize:11.0 weight:UIFontWeightRegular]
                 range:NSMakeRange(value.length + 1, title.length)];
    [text addAttribute:NSForegroundColorAttributeName
                 value:UIColor.whiteColor
                 range:NSMakeRange(0, text.length)];
    return text;
}

#pragma mark - 私有方法 - 删除

/** 二次确认后删除指定录音 */
- (void)confirmDeleteRecordingsWithIdentifiers:(NSArray<NSString *> *)recordIdentifiers {
    if (recordIdentifiers.count == 0) {
        return;
    }
    NSString *title = recordIdentifiers.count == 1
        ? @"删除这条录音？"
        : [NSString stringWithFormat:@"删除选中的 %lu 条录音？", (unsigned long)recordIdentifiers.count];
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:title
        message:@"音频与转写内容将一并删除，且无法恢复。"
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"删除"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(__unused UIAlertAction *action) {
        [weakSelf deleteRecordingsWithIdentifiers:recordIdentifiers];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

/** 调用本地存储删除并刷新列表 */
- (void)deleteRecordingsWithIdentifiers:(NSArray<NSString *> *)recordIdentifiers {
    NSError *error = nil;
    NSUInteger deletedCount = [self.draftStore deleteRecordingsWithIdentifiers:recordIdentifiers
                                                                         error:&error];
    [self reloadRecordings];
    if (deletedCount < recordIdentifiers.count) {
        [self showAlertWithMsg:error.localizedDescription ?: @"部分录音删除失败"];
    }
}

/** 返回指定行的录音标识 */
- (NSString *)recordIdentifierAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= (NSInteger)self.recordingMetadata.count) {
        return nil;
    }
    return [self.recordingMetadata[indexPath.row][@"recordIdentifier"] description];
}

#pragma mark - 事件响应

/** 返回 AI 录音页面 */
- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 切换多选管理模式 */
- (void)handleManage {
    self.managing = !self.isManaging;
}

/** 全选或取消全选 */
- (void)handleSelectAll {
    BOOL allSelected = self.historyTableView.indexPathsForSelectedRows.count == self.recordingMetadata.count;
    for (NSInteger row = 0; row < (NSInteger)self.recordingMetadata.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        if (allSelected) {
            [self.historyTableView deselectRowAtIndexPath:indexPath animated:NO];
        } else {
            [self.historyTableView selectRowAtIndexPath:indexPath
                                               animated:NO
                                         scrollPosition:UITableViewScrollPositionNone];
        }
    }
    [self refreshManagementToolbar];
}

/** 删除当前选中的录音 */
- (void)handleDeleteSelected {
    NSMutableArray<NSString *> *recordIdentifiers = [NSMutableArray array];
    for (NSIndexPath *indexPath in self.historyTableView.indexPathsForSelectedRows) {
        NSString *recordIdentifier = [self recordIdentifierAtIndexPath:indexPath];
        if (recordIdentifier.length > 0) {
            [recordIdentifiers addObject:recordIdentifier];
        }
    }
    [self confirmDeleteRecordingsWithIdentifiers:recordIdentifiers];
}

/** 本地录音被重命名或删除后刷新列表 */
- (void)handleHistoryDidChange:(NSNotification *)notification {
    if (!self.isViewLoaded) {
        return;
    }
    [self reloadRecordings];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recordingMetadata.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSAIAudioRecordHistoryCell *cell = [tableView
        dequeueReusableCellWithIdentifier:@"TSAIAudioRecordHistoryCell"
        forIndexPath:indexPath];
    [cell configureWithMetadata:self.recordingMetadata[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

/** 使用历史页专属行高，避免继承 TSBaseVC 的默认 60pt 行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTSAIAudioRecordHistoryRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isManaging) {
        [self refreshManagementToolbar];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary<NSString *, id> *metadata = self.recordingMetadata[indexPath.row];
    NSURL *audioFileURL = [self.draftStore audioFileURLForMetadata:metadata error:nil];
    if (!audioFileURL) {
        [self reloadRecordings];
        return;
    }
    TSAIAudioRecordDetailVC *detailViewController = [[TSAIAudioRecordDetailVC alloc]
        initWithMetadata:metadata
        audioFileURL:audioFileURL];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isManaging) {
        [self refreshManagementToolbar];
    }
}

/** 非管理模式下支持左滑删除单条 */
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isManaging) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    UIContextualAction *deleteAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleDestructive
        title:@"删除"
        handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL)) {
            NSString *recordIdentifier = [weakSelf recordIdentifierAtIndexPath:indexPath];
            completionHandler(NO);
            if (recordIdentifier.length > 0) {
                [weakSelf confirmDeleteRecordingsWithIdentifiers:@[recordIdentifier]];
            }
        }];
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}

@end

@implementation TSAIAudioRecordHistoryCell

#pragma mark - 生命周期

/** 创建历史记录单元格 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        // 保留默认选中样式以便管理模式显示多选勾选，选中背景透明避免灰色高亮
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = UIColor.clearColor;
        self.cardView = [[UIView alloc] init];
        self.cardView.backgroundColor = UIColor.whiteColor;
        self.cardView.layer.cornerRadius = 17.0;
        self.cardView.layer.shadowColor = UIColor.blackColor.CGColor;
        self.cardView.layer.shadowOpacity = 0.06;
        self.cardView.layer.shadowRadius = 8.0;
        self.cardView.layer.shadowOffset = CGSizeMake(0.0, 3.0);
        [self.contentView addSubview:self.cardView];
        self.iconLabel = [self labelWithFont:[UIFont systemFontOfSize:19.0]
                                      color:[UIColor colorWithRed:79.0 / 255.0
                                                           green:123.0 / 255.0
                                                            blue:255.0 / 255.0
                                                           alpha:1.0]];
        self.iconLabel.text = @"♫";
        self.iconLabel.textAlignment = NSTextAlignmentCenter;
        self.iconLabel.backgroundColor = [UIColor colorWithRed:79.0 / 255.0
                                                         green:123.0 / 255.0
                                                          blue:255.0 / 255.0
                                                         alpha:0.09];
        self.iconLabel.layer.cornerRadius = 14.0;
        self.iconLabel.layer.masksToBounds = YES;
        self.titleLabel = [self labelWithFont:[UIFont systemFontOfSize:14.0 weight:UIFontWeightBold]
                                       color:[UIColor colorWithRed:16.0 / 255.0
                                                            green:20.0 / 255.0
                                                             blue:45.0 / 255.0
                                                            alpha:1.0]];
        self.dateLabel = [self secondaryLabelWithFontSize:10.0];
        self.statusLabel = [self labelWithFont:[UIFont systemFontOfSize:10.0 weight:UIFontWeightBold]
                                        color:[UIColor colorWithRed:79.0 / 255.0
                                                             green:123.0 / 255.0
                                                              blue:255.0 / 255.0
                                                             alpha:1.0]];
        self.durationLabel = [self secondaryLabelWithFontSize:11.0];
        self.durationLabel.textAlignment = NSTextAlignmentRight;
        for (UIView *view in @[self.iconLabel, self.titleLabel, self.dateLabel,
                              self.statusLabel, self.durationLabel]) {
            [self.cardView addSubview:view];
        }
    }
    return self;
}

/** 布局历史记录单元格 */
- (void)layoutSubviews {
    [super layoutSubviews];
    self.cardView.frame = CGRectInset(self.contentView.bounds, 0.0, 5.0);
    self.iconLabel.frame = CGRectMake(14.0, 14.0, 44.0, 44.0);
    CGFloat copyWidth = MAX(80.0, CGRectGetWidth(self.cardView.bounds) - 152.0);
    self.titleLabel.frame = CGRectMake(70.0, 12.0, copyWidth, 19.0);
    self.dateLabel.frame = CGRectMake(70.0, 32.0, copyWidth, 14.0);
    self.statusLabel.frame = CGRectMake(70.0, 50.0, copyWidth, 14.0);
    self.durationLabel.frame = CGRectMake(CGRectGetWidth(self.cardView.bounds) - 72.0,
                                          27.0, 58.0, 18.0);
}

#pragma mark - 公开方法

/** 使用本地元数据刷新单元格 */
- (void)configureWithMetadata:(NSDictionary<NSString *, id> *)metadata {
    self.titleLabel.text = [metadata[@"title"] description].length > 0
        ? [metadata[@"title"] description]
        : @"现场录音";
    NSTimeInterval timestamp = [metadata[@"startTimestamp"] doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    self.dateLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
    BOOL isIncomplete = [metadata[@"isIncomplete"] boolValue];
    self.statusLabel.text = isIncomplete ? @"录音中断 · 已保存已录内容" : @"已完成转写 · AI 总结可用";
    NSInteger totalSeconds = [metadata[@"durationMilliseconds"] integerValue] / 1000;
    self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",
                               (long)(totalSeconds / 60),
                               (long)(totalSeconds % 60)];
}

#pragma mark - 私有方法

/** 创建基础文本标签 */
- (UILabel *)labelWithFont:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    return label;
}

/** 创建次要信息标签 */
- (UILabel *)secondaryLabelWithFontSize:(CGFloat)fontSize {
    return [self labelWithFont:[UIFont monospacedSystemFontOfSize:fontSize weight:UIFontWeightRegular]
                         color:[UIColor colorWithRed:156.0 / 255.0
                                              green:162.0 / 255.0
                                               blue:184.0 / 255.0
                                              alpha:1.0]];
}

@end
