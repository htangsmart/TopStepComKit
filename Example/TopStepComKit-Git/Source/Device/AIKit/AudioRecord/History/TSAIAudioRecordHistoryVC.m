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
    self.historyTableView.dataSource = self;
    self.historyTableView.delegate = self;
    [self.historyTableView registerClass:TSAIAudioRecordHistoryCell.class
                  forCellReuseIdentifier:@"TSAIAudioRecordHistoryCell"];
    self.historyTableView.tableHeaderView = [self historyHeaderView];
    [self.view addSubview:self.historyTableView];
    [NSLayoutConstraint activateConstraints:@[
        [self.historyTableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.historyTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:18.0],
        [self.historyTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-18.0],
        [self.historyTableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

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

    UIButton *manageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    manageButton.frame = CGRectMake(0.0, 0.0, 36.0, 36.0);
    manageButton.tintColor = [UIColor colorWithRed:16.0 / 255.0
                                             green:20.0 / 255.0
                                              blue:45.0 / 255.0
                                             alpha:1.0];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *configuration =
            [UIImageSymbolConfiguration configurationWithPointSize:19.0 weight:UIImageSymbolWeightRegular];
        [manageButton setImage:[UIImage systemImageNamed:@"checklist" withConfiguration:configuration]
                      forState:UIControlStateNormal];
    } else {
        [manageButton setTitle:@"☷" forState:UIControlStateNormal];
    }
    [manageButton addTarget:self action:@selector(handleManage) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:manageButton];
}

/** Auto Layout 已完成页面布局 */
- (void)layoutViews {
}

#pragma mark - 私有方法

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

/** 返回 AI 录音页面 */
- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 进入历史录音管理模式 */
- (void)handleManage {
    [self showAlertWithMsg:@"已进入多选管理模式"];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary<NSString *, id> *metadata = self.recordingMetadata[indexPath.row];
    TSAIAudioRecordDraftStore *draftStore = self.draftStore;
    tableView.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    // 旧版 PCM 首次打开需要封装 WAV，文件操作放到后台执行。
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSError *audioError = nil;
        NSURL *audioFileURL = [draftStore audioFileURLForMetadata:metadata error:&audioError];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            strongSelf.historyTableView.userInteractionEnabled = YES;
            if (strongSelf.navigationController.topViewController != strongSelf) {
                return;
            }
            if (!audioFileURL) {
                TSLog(@"[TSAIAudioRecordHistoryVC] 准备录音文件失败: %@", audioError);
                strongSelf.recordingMetadata = [draftStore loadRecordingMetadata];
                [strongSelf refreshMetrics];
                [strongSelf.historyTableView reloadData];
                [strongSelf showAlertWithMsg:@"音频文件无法读取或转换"];
                return;
            }
            TSAIAudioRecordDetailVC *detailViewController = [[TSAIAudioRecordDetailVC alloc]
                initWithMetadata:metadata
                audioFileURL:audioFileURL];
            [strongSelf.navigationController pushViewController:detailViewController animated:YES];
        });
    });
}

@end

@implementation TSAIAudioRecordHistoryCell

#pragma mark - 生命周期

/** 创建历史记录单元格 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    self.statusLabel.text = isIncomplete ? @"等待 AI 处理" : @"已完成转写 · AI 总结可用";
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
