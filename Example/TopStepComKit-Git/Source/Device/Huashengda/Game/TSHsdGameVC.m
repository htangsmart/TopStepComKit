//
//  TSHsdGameVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdGameVC.h"

static const NSInteger kTSHsdGameTypeCount = 25;
/// 随机生成：默认条数 / 可选条数
static const NSInteger kTSHsdRandomDefaultCount = 5;
/// 随机排名上限（不含边界值时取 1–99）
static const uint32_t kTSHsdRandomRankingRange = 99;
/// 撤销提示显示时长（秒）
static const NSTimeInterval kTSHsdUndoToastDuration = 4.0;

/// 骰子图标：dice.fill 需 iOS 15，更低版本退回 shuffle
static NSString *TSHsdDiceSymbolName(void) {
    if (@available(iOS 15.0, *)) { return @"dice.fill"; }
    return @"shuffle";
}

#pragma mark - 记录行（.rec）

@interface TSHsdGameRecordRowView : UIView
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) TSHsdPill *levelPill;
@end

@implementation TSHsdGameRecordRowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.font = [TSHsdDisplay roundedFontOfSize:13.f weight:UIFontWeightHeavy];
    _indexLabel.textColor = [TSHsdDisplay textSecondary];
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    _indexLabel.backgroundColor = [TSHsdDisplay fill];
    _indexLabel.layer.cornerRadius = 15.f;
    _indexLabel.clipsToBounds = YES;
    [self addSubview:_indexLabel];
    _scoreLabel = [[UILabel alloc] init];
    [self addSubview:_scoreLabel];
    _metaLabel = [[UILabel alloc] init];
    _metaLabel.font = [UIFont systemFontOfSize:12.f];
    _metaLabel.textColor = [TSHsdDisplay textSecondary];
    [self addSubview:_metaLabel];
    _levelPill = [[TSHsdPill alloc] init];
    _levelPill.style = TSHsdPillStyleHue;
    [self addSubview:_levelPill];
    return self;
}

- (void)configureIndex:(NSInteger)index record:(TSHsdGameRecordModel *)record hue:(UIColor *)hue {
    self.indexLabel.text = [NSString stringWithFormat:@"%ld", (long)index];
    NSMutableAttributedString *score = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)record.score]
        attributes:@{NSFontAttributeName: [TSHsdDisplay roundedFontOfSize:24.f weight:UIFontWeightHeavy], NSForegroundColorAttributeName: [TSHsdDisplay ink]}];
    [score appendAttributedString:[[NSAttributedString alloc] initWithString:[@" " stringByAppendingString:TSLocalizedString(@"hsd.game.score_unit")]
        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.f weight:UIFontWeightSemibold], NSForegroundColorAttributeName: [TSHsdDisplay textSecondary]}]];
    self.scoreLabel.attributedText = score;
    NSString *duration = record.duration >= 60
        ? [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.ms_format"), (long)(record.duration / 60), (long)(record.duration % 60)]
        : [NSString stringWithFormat:TSLocalizedString(@"hsd.duration.s_format"), (long)record.duration];
    NSDateComponents *c = [[NSCalendar currentCalendar] components:(NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:record.date ?: [NSDate date]];
    self.metaLabel.text = [NSString stringWithFormat:TSLocalizedString(@"hsd.game.record_meta_format"), duration, (long)c.month, (long)c.day];
    self.levelPill.hue = hue;
    self.levelPill.text = [NSString stringWithFormat:@"Lv %ld", (long)record.level];
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 14.f + 24.f + 4.f + 14.f + 14.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    self.indexLabel.frame = CGRectMake(16.f, (h - 30.f) / 2.f, 30.f, 30.f);
    CGSize ps = [self.levelPill sizeThatFits:CGSizeZero];
    self.levelPill.frame = CGRectMake(w - 16.f - ps.width, (h - 22.f) / 2.f, ps.width, 22.f);
    CGFloat x = 16.f + 30.f + 14.f;
    self.scoreLabel.frame = CGRectMake(x, 14.f, CGRectGetMinX(self.levelPill.frame) - x - 8.f, 26.f);
    self.metaLabel.frame = CGRectMake(x, 44.f, CGRectGetMinX(self.levelPill.frame) - x - 8.f, 14.f);
}

@end

#pragma mark - 趋势行（紧凑展示，点行编辑）

/// 一行：图标 | 游戏名 + 随机标 / gameType=N | 第 N 名 | 趋势箭头块
@interface TSHsdTrendRowView : UIView
@property (nonatomic, strong) TSHsdIconBlock *icon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) TSHsdPill *randomPill;
@property (nonatomic, strong) UILabel *codeLabel;
@property (nonatomic, strong) UILabel *rankLabel;
@property (nonatomic, strong) UIView *trendChip;
@property (nonatomic, strong) UIImageView *trendIcon;
@property (nonatomic, strong) UIView *highlight;
@property (nonatomic, copy, nullable) void (^onTap)(void);
- (void)configureWithTrend:(TSHsdGameRankingTrendModel *)trend random:(BOOL)random hue:(UIColor *)hue;
@end

@implementation TSHsdTrendRowView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _highlight = [[UIView alloc] init];
    _highlight.backgroundColor = [TSHsdDisplay fill];
    _highlight.hidden = YES;
    [self addSubview:_highlight];
    _icon = [[TSHsdIconBlock alloc] init]; _icon.side = 36.f; _icon.emoStyle = YES; [self addSubview:_icon];
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:14.5f weight:UIFontWeightSemibold];
    _nameLabel.textColor = [TSHsdDisplay ink];
    [self addSubview:_nameLabel];
    _randomPill = [[TSHsdPill alloc] init];
    _randomPill.style = TSHsdPillStyleHue;
    _randomPill.text = TSLocalizedString(@"hsd.game.random");
    _randomPill.hidden = YES;
    [self addSubview:_randomPill];
    _codeLabel = [[UILabel alloc] init];
    _codeLabel.font = [TSHsdDisplay monoFontOfSize:11.5f];
    _codeLabel.textColor = [TSHsdDisplay textTertiary];
    [self addSubview:_codeLabel];
    _rankLabel = [[UILabel alloc] init];
    _rankLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_rankLabel];
    _trendChip = [[UIView alloc] init];
    _trendChip.layer.cornerRadius = 9.f;
    [self addSubview:_trendChip];
    _trendIcon = [[UIImageView alloc] init];
    _trendIcon.contentMode = UIViewContentModeCenter;
    [_trendChip addSubview:_trendIcon];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ts_tapped)]];
    return self;
}

- (void)configureWithTrend:(TSHsdGameRankingTrendModel *)trend random:(BOOL)random hue:(UIColor *)hue {
    self.icon.symbol = [TSHsdDisplay symbolForGameType:trend.gameType];
    self.nameLabel.text = [TSHsdDisplay gameName:trend.gameType];
    self.randomPill.hue = hue;
    self.randomPill.hidden = !random;
    self.codeLabel.text = [NSString stringWithFormat:@"gameType=%ld", (long)trend.gameType];

    UIColor *secondary = [TSHsdDisplay textSecondary];
    NSMutableAttributedString *rank = [[NSMutableAttributedString alloc] initWithString:TSLocalizedString(@"hsd.game.rank_prefix")
        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f], NSForegroundColorAttributeName: secondary}];
    [rank appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %ld ", (long)trend.ranking]
        attributes:@{NSFontAttributeName: [TSHsdDisplay roundedFontOfSize:18.f weight:UIFontWeightBold], NSForegroundColorAttributeName: [TSHsdDisplay ink]}]];
    [rank appendAttributedString:[[NSAttributedString alloc] initWithString:TSLocalizedString(@"hsd.game.rank_unit")
        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f], NSForegroundColorAttributeName: secondary}]];
    self.rankLabel.attributedText = rank;

    NSString *symbol = @"minus";
    UIColor *color = secondary;
    UIColor *background = [TSHsdDisplay fill];
    if (trend.trend == TSHsdRankingTrendUp) {
        symbol = @"arrow.up"; color = [TSHsdDisplay statusGood]; background = [TSHsdDisplay tint12:color];
    } else if (trend.trend == TSHsdRankingTrendDown) {
        symbol = @"arrow.down"; color = [TSHsdDisplay statusBad]; background = [TSHsdDisplay tint12:color];
    }
    self.trendIcon.image = TSHsdSymbol(symbol, 14.f, UIImageSymbolWeightBold);
    self.trendIcon.tintColor = color;
    self.trendChip.backgroundColor = background;
    [self setNeedsLayout];
}

- (void)ts_tapped {
    if (!self.onTap) { return; }
    self.highlight.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ self.highlight.hidden = YES; });
    self.onTap();
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 12.f + 36.f + 12.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    self.highlight.frame = self.bounds;
    self.icon.frame = CGRectMake(14.f, (h - 36.f) / 2.f, 36.f, 36.f);
    self.trendChip.frame = CGRectMake(w - 14.f - 30.f, (h - 30.f) / 2.f, 30.f, 30.f);
    self.trendIcon.frame = self.trendChip.bounds;
    CGFloat rankW = ceil([self.rankLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 24.f)].width);
    self.rankLabel.frame = CGRectMake(CGRectGetMinX(self.trendChip.frame) - 11.f - rankW, (h - 24.f) / 2.f, rankW, 24.f);
    CGFloat x = CGRectGetMaxX(self.icon.frame) + 11.f;
    CGFloat metaMax = CGRectGetMinX(self.rankLabel.frame) - 11.f - x;
    CGFloat top = (h - 20.f - 2.f - 14.f) / 2.f;
    if (self.randomPill.hidden) {
        self.nameLabel.frame = CGRectMake(x, top, metaMax, 20.f);
    } else {
        CGSize ps = [self.randomPill sizeThatFits:CGSizeZero];
        CGFloat nameW = MIN(ceil([self.nameLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20.f)].width), metaMax - ps.width - 6.f);
        self.nameLabel.frame = CGRectMake(x, top, MAX(0, nameW), 20.f);
        self.randomPill.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + 6.f, top - 1.f, ps.width, 22.f);
    }
    self.codeLabel.frame = CGRectMake(x, top + 22.f, metaMax, 14.f);
}

@end

#pragma mark - 趋势编辑行（排名数字框 + 降 / 平 / 升）

@interface TSHsdTrendEditView : UIView
@property (nonatomic, strong) TSHsdNumBox *rankBox;
@property (nonatomic, strong) TSHsdSegView *trendSeg;
@end

@implementation TSHsdTrendEditView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _rankBox = [[TSHsdNumBox alloc] init];
    _rankBox.prefix = TSLocalizedString(@"hsd.game.rank_prefix");
    _rankBox.unit = TSLocalizedString(@"hsd.game.rank_unit");
    _rankBox.minValue = 0; _rankBox.maxValue = TSHsdGameRankingMax;
    [self addSubview:_rankBox];
    _trendSeg = [[TSHsdSegView alloc] init];
    TSHsdSegItem *down = [TSHsdSegItem itemWithTitle:[TSHsdDisplay trendName:TSHsdRankingTrendDown] symbol:@"arrow.down"]; down.onColor = [TSHsdDisplay statusBad];
    TSHsdSegItem *flat = [TSHsdSegItem itemWithTitle:[TSHsdDisplay trendName:TSHsdRankingTrendUnchanged] symbol:@"minus"];
    TSHsdSegItem *up = [TSHsdSegItem itemWithTitle:[TSHsdDisplay trendName:TSHsdRankingTrendUp] symbol:@"arrow.up"]; up.onColor = [TSHsdDisplay statusGood];
    _trendSeg.items = @[down, flat, up];
    [self addSubview:_trendSeg];
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 40.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    CGSize rs = [self.rankBox sizeThatFits:CGSizeZero];
    self.rankBox.frame = CGRectMake(0, (h - 36.f) / 2.f, rs.width, 36.f);
    CGFloat segX = CGRectGetMaxX(self.rankBox.frame) + 10.f;
    self.trendSeg.frame = CGRectMake(segX, 0, w - segX, h);
}

@end

#pragma mark - 双列按钮（添加游戏 / 填充 25 个）

@interface TSHsdTwoButtonsView : UIView
@property (nonatomic, strong) TSHsdGhostAddButton *left;
@property (nonatomic, strong) TSHsdGhostAddButton *right;
@end

@implementation TSHsdTwoButtonsView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _left = [[TSHsdGhostAddButton alloc] init]; [self addSubview:_left];
    _right = [[TSHsdGhostAddButton alloc] init]; [self addSubview:_right];
    return self;
}
- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 50.f); }
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = (self.bounds.size.width - 10.f) / 2.f;
    self.left.frame = CGRectMake(0, 0, w, 50.f);
    self.right.frame = CGRectMake(w + 10.f, 0, w, 50.f);
}
@end

#pragma mark - 撤销提示（随机生成后显示）

@interface TSHsdUndoToastView : UIView
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *undoButton;
@property (nonatomic, copy, nullable) void (^onUndo)(void);
- (void)showInView:(UIView *)view bottom:(CGFloat)bottom message:(NSString *)message;
- (void)hide;
@end

@implementation TSHsdUndoToastView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.backgroundColor = [[UIColor colorWithRed:0x14/255.f green:0x17/255.f blue:0x26/255.f alpha:1] colorWithAlphaComponent:0.94f];
    self.layer.cornerRadius = 14.f;
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.font = [UIFont systemFontOfSize:13.5f weight:UIFontWeightMedium];
    _messageLabel.textColor = [UIColor whiteColor];
    [self addSubview:_messageLabel];
    _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _undoButton.titleLabel.font = [UIFont systemFontOfSize:13.5f weight:UIFontWeightBold];
    [_undoButton setTitle:TSLocalizedString(@"hsd.game.random_undo") forState:UIControlStateNormal];
    [_undoButton setTitleColor:[UIColor colorWithRed:1.f green:0x9C/255.f blue:0xC3/255.f alpha:1] forState:UIControlStateNormal];
    _undoButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10.f, 0, 10.f);
    [_undoButton addTarget:self action:@selector(ts_undoTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_undoButton];
    return self;
}

- (void)ts_undoTapped {
    if (self.onUndo) { self.onUndo(); }
    [self hide];
}

- (void)showInView:(UIView *)view bottom:(CGFloat)bottom message:(NSString *)message {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    self.messageLabel.text = message;
    CGFloat textW = ceil([self.messageLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20.f)].width);
    CGFloat buttonW = ceil([self.undoButton sizeThatFits:CGSizeZero].width);
    CGFloat w = MIN(14.f + textW + 6.f + buttonW + 4.f, view.bounds.size.width - 32.f);
    self.frame = CGRectMake((view.bounds.size.width - w) / 2.f, bottom - 44.f, w, 44.f);
    self.messageLabel.frame = CGRectMake(14.f, 0, w - 14.f - buttonW - 10.f, 44.f);
    self.undoButton.frame = CGRectMake(w - buttonW - 4.f, 0, buttonW, 44.f);
    if (self.superview != view) { [view addSubview:self]; }
    [view bringSubviewToFront:self];
    self.alpha = 0;
    self.transform = CGAffineTransformMakeTranslation(0, 10.f);
    [UIView animateWithDuration:0.22 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    }];
    [self performSelector:@selector(hide) withObject:nil afterDelay:kTSHsdUndoToastDuration];
}

- (void)hide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    if (!self.superview) { return; }
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(0, 10.f);
    } completion:^(BOOL finished) {
        if (self.alpha == 0) { [self removeFromSuperview]; }
    }];
}

@end

#pragma mark - TSHsdGameVC

@interface TSHsdGameVC ()
@property (nonatomic, assign) BOOL showingTrends;
@property (nonatomic, assign) NSInteger gameType;
/// 记录读取状态：0 加载中 / 1 有数据 / 2 失败
@property (nonatomic, assign) NSInteger recordState;
@property (nonatomic, copy, nullable) NSArray<TSHsdGameRecordModel *> *records;
@property (nonatomic, strong, nullable) NSError *recordError;
/// 排名趋势草稿（只写）
@property (nonatomic, strong) NSMutableArray<TSHsdGameRankingTrendModel *> *trends;
/// 随机生成、尚未发送的游戏类型（行上显示「随机」标签）
@property (nonatomic, strong) NSMutableSet<NSNumber *> *randomGameTypes;
/// 随机生成条数（面板里选）
@property (nonatomic, assign) NSInteger randomCount;
/// 随机生成时混入排名 0 / 255
@property (nonatomic, assign) BOOL randomIncludesEdge;
/// 本次刚生成、需要做入场动画的游戏类型
@property (nonatomic, strong) NSMutableSet<NSNumber *> *freshGameTypes;
/// 本次 render 中对应 freshGameTypes 的行
@property (nonatomic, strong) NSMutableArray<UIView *> *freshRows;
/// 「排名与趋势」分区标题（用于骰子动画）
@property (nonatomic, weak) TSHsdSecView *trendsSec;
/// 撤销快照：生成前的列表 / 随机标记 / dirty
@property (nonatomic, copy, nullable) NSArray<TSHsdGameRankingTrendModel *> *undoTrends;
@property (nonatomic, copy, nullable) NSSet<NSNumber *> *undoRandomGameTypes;
@property (nonatomic, assign) BOOL undoDirty;
@property (nonatomic, strong) TSHsdUndoToastView *undoToast;
@end

@implementation TSHsdGameVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.game");
    self.hue = [TSHsdDisplay hueGame];
    self.usesDock = YES;
    self.chips = @[@"bit34", TSLocalizedString(@"hsd.game.chip")];
    self.gameType = TSHsdGameType2048;
    self.trends = [NSMutableArray array];
    self.randomGameTypes = [NSMutableSet set];
    self.freshGameTypes = [NSMutableSet set];
    self.freshRows = [NSMutableArray array];
    self.randomCount = kTSHsdRandomDefaultCount;
    NSArray<TSHsdGameRankingTrendModel *> *cached = [TSHsdLocalCache rankingTrends];
    for (TSHsdGameRankingTrendModel *m in cached) { [self.trends addObject:[m copy]]; }
}

- (void)setupViews {
    [super setupViews];
    self.dock.offlineText = TSLocalizedString(@"hsd.dock.offline_send");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_undoToast hide];
}

#pragma mark - 保存条（只写）

- (TSHsdDockState)dockState {
    if (!self.showingTrends) { return TSHsdDockStateHidden; }
    if (self.isSaving) { return TSHsdDockStateSaving; }
    if (!self.connected) { return TSHsdDockStateOffline; }
    return TSHsdDockStateWriteOnly;
}

- (NSString *)dockButtonTitle {
    return [NSString stringWithFormat:TSLocalizedString(@"hsd.dock.send_format"), (unsigned long)self.trends.count];
}

- (nullable NSString *)dockSmall {
    NSDate *sent = [TSHsdLocalCache rankingTrendsSentDate];
    return sent ? [NSString stringWithFormat:TSLocalizedString(@"hsd.dock.last_sent_format"), [TSHsdDisplay clockString:sent]] : TSLocalizedString(@"hsd.dock.never_sent");
}

#pragma mark - 读取记录

- (void)reload {
    if (!self.showingTrends) { [self ts_loadRecords]; } else { [self render]; }
}

- (void)ts_loadRecords {
    self.recordState = 0;
    [self render];
    NSInteger type = self.gameType;
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchGameTopRecordsWithType:completion:" params:[NSString stringWithFormat:@"gameType=%ld（%@）", (long)type, [TSHsdDisplay gameName:type]]];
    __weak typeof(self) weakSelf = self;
    [self.hsd fetchGameTopRecordsWithType:(TSHsdGameType)type completion:^(NSArray<TSHsdGameRecordModel *> *records, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            [self finishCall:entry success:(error == nil && records != nil) error:error result:records ? [NSString stringWithFormat:@"%lu records", (unsigned long)records.count] : nil];
            if (self.gameType != type) { return; }   // 用户已切换游戏，忽略旧结果
            if (error || !records) {
                self.recordState = 2;
                self.recordError = error;
            } else {
                self.recordState = 1;
                self.records = records;
            }
            [self render];
        }];
    }];
}

#pragma mark - 发送趋势

- (void)save {
    if (!self.hsd) { [self toast:TSLocalizedString(@"hsd.error.not_support")]; return; }
    if (self.trends.count == 0) { [self toast:TSLocalizedString(@"hsd.game.trends_empty_send")]; return; }
    NSArray<TSHsdGameRankingTrendModel *> *sent = [[NSArray alloc] initWithArray:self.trends copyItems:YES];
    self.saving = YES;
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setGameRankingTrends:completion:" params:[NSString stringWithFormat:@"trends=%lu", (unsigned long)sent.count]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setGameRankingTrends:sent completion:^(BOOL isSuccess, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            self.saving = NO;
            if (!isSuccess) {
                [self finishCall:entry success:NO error:error result:nil];
                [self alertError:error title:TSLocalizedString(@"hsd.send.failed")];
                return;
            }
            [self finishCall:entry success:YES error:nil result:nil];
            [TSHsdLocalCache saveRankingTrends:sent];
            [self.randomGameTypes removeAllObjects];
            [self ts_clearUndo];
            self.dirty = NO;
            [self render];
            [self toast:[NSString stringWithFormat:TSLocalizedString(@"hsd.game.trends_sent_format"), (unsigned long)sent.count]];
        }];
    }];
}

#pragma mark - 趋势编辑

- (void)ts_addTrend {
    NSMutableSet<NSNumber *> *used = [NSMutableSet set];
    for (TSHsdGameRankingTrendModel *t in self.trends) { [used addObject:@(t.gameType)]; }
    NSMutableArray<NSString *> *titles = [NSMutableArray array], *symbols = [NSMutableArray array];
    NSMutableArray<NSNumber *> *indexes = [NSMutableArray array];
    for (NSInteger g = 0; g < kTSHsdGameTypeCount; g++) {
        if ([used containsObject:@(g)]) { continue; }
        [titles addObject:[TSHsdDisplay gameName:g]];
        [symbols addObject:[TSHsdDisplay symbolForGameType:g]];
        [indexes addObject:@(g)];
    }
    __weak typeof(self) weakSelf = self;
    [TSHsdSheet presentGridFrom:self title:TSLocalizedString(@"hsd.game.add_game") buttonTitle:TSLocalizedString(@"general.cancel")
                         titles:titles symbols:symbols indexes:indexes selected:-1 hue:self.hue footNote:nil onPick:^(NSInteger index) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        TSHsdGameRankingTrendModel *m = [[TSHsdGameRankingTrendModel alloc] init];
        m.gameType = (TSHsdGameType)index;
        m.ranking = 1;
        m.trend = TSHsdRankingTrendUnchanged;
        [self.trends addObject:m];
        self.dirty = YES;
        [self render];
    }];
}

/// 点行：底部面板编辑排名 / 趋势，或移除；改动即时写回草稿
- (void)ts_editTrend:(TSHsdGameRankingTrendModel *)trend {
    __weak typeof(self) weakSelf = self;
    TSHsdTrendEditView *editor = [[TSHsdTrendEditView alloc] init];
    editor.rankBox.value = trend.ranking;
    editor.rankBox.onChange = ^(NSInteger value) {
        trend.ranking = value;
        weakSelf.dirty = YES;
        [weakSelf render];
    };
    editor.trendSeg.selectedIndex = MAX(0, MIN(2, (NSInteger)trend.trend));
    editor.trendSeg.onChange = ^(NSInteger index) {
        trend.trend = (TSHsdRankingTrend)index;
        weakSelf.dirty = YES;
        [weakSelf render];
    };
    TSHsdDangerLink *remove = [[TSHsdDangerLink alloc] init];
    remove.title = TSLocalizedString(@"hsd.game.trend_remove");
    remove.hsd_spacingBefore = @(12);

    __block TSHsdSheet *sheet = nil;
    sheet = [TSHsdSheet sheetWithTitle:[TSHsdDisplay gameName:trend.gameType]
                           buttonTitle:TSLocalizedString(@"general.done")
                                blocks:@[[self foot:[NSString stringWithFormat:@"gameType=%ld", (long)trend.gameType]], editor, remove]
                              onButton:^{ [sheet dismiss]; }];
    remove.onTap = ^{
        [sheet dismiss];
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        [self.trends removeObject:trend];
        [self.randomGameTypes removeObject:@(trend.gameType)];
        self.dirty = YES;
        [self render];
    };
    [sheet presentFrom:self];
}

/// 填充 25 个游戏的测试数据（D-36）
- (void)ts_fillTrends {
    [self.trends removeAllObjects];
    [self.randomGameTypes removeAllObjects];
    [self ts_clearUndo];
    for (NSInteger g = 0; g < kTSHsdGameTypeCount; g++) {
        TSHsdGameRankingTrendModel *m = [[TSHsdGameRankingTrendModel alloc] init];
        m.gameType = (TSHsdGameType)g;
        m.ranking = (g * 7) % 100 + 1;
        m.trend = (TSHsdRankingTrend)(g % 3);
        [self.trends addObject:m];
    }
    self.dirty = YES;
    [self render];
}

#pragma mark - 随机生成

/// 点「随机」：列表为空直接生成；已有数据弹出面板选择替换 / 追加
- (void)ts_randomTapped {
    if (self.trends.count == 0) {
        [self ts_generateRandomReplacing:YES];
        return;
    }
    [self ts_presentRandomSheet];
}

- (void)ts_presentRandomSheet {
    __weak typeof(self) weakSelf = self;
    NSArray<NSNumber *> *counts = @[@3, @5, @10, @25];

    TSHsdSecView *countSec = [self sec:TSLocalizedString(@"hsd.game.random_count")
                                 right:[NSString stringWithFormat:TSLocalizedString(@"hsd.game.random_existing_format"), (unsigned long)self.trends.count, (unsigned long)TSHsdGameRankingTrendMaxCount]];
    TSHsdSegView *countSeg = [[TSHsdSegView alloc] init];
    NSMutableArray<TSHsdSegItem *> *items = [NSMutableArray array];
    for (NSNumber *n in counts) { [items addObject:[TSHsdSegItem itemWithTitle:n.stringValue symbol:nil]]; }
    countSeg.items = items;
    NSUInteger countIndex = [counts indexOfObject:@(self.randomCount)];
    countSeg.selectedIndex = countIndex == NSNotFound ? 1 : (NSInteger)countIndex;

    TSHsdRowView *edgeRow = [self switchRowWithSymbol:@"arrow.up.and.down" color:self.hue
                                                title:TSLocalizedString(@"hsd.game.random_edge")
                                             subtitle:TSLocalizedString(@"hsd.game.random_edge_sub")
                                                   on:self.randomIncludesEdge
                                             onToggle:^(BOOL on) { weakSelf.randomIncludesEdge = on; }];
    TSHsdCardView *edgeCard = [self card:@[edgeRow]];

    TSHsdCTAButton *replaceButton = [[TSHsdCTAButton alloc] init];
    TSHsdCTAButton *appendButton = [[TSHsdCTAButton alloc] init];
    appendButton.raised = YES;
    replaceButton.hsd_spacingBefore = @(16);
    appendButton.hsd_spacingBefore = @(10);

    __weak TSHsdCTAButton *weakReplace = replaceButton;
    __weak TSHsdCTAButton *weakAppend = appendButton;
    void (^refreshButtons)(void) = ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        [weakReplace setTitle:[NSString stringWithFormat:TSLocalizedString(@"hsd.game.random_replace_format"), (long)self.randomCount] symbol:TSHsdDiceSymbolName()];
        NSUInteger appendable = [self ts_appendableCount];
        weakAppend.enabled = appendable > 0;
        NSString *appendTitle = appendable == 0
            ? TSLocalizedString(@"hsd.game.random_append_none")
            : [NSString stringWithFormat:TSLocalizedString(@"hsd.game.random_append_format"), (long)appendable];
        [weakAppend setTitle:appendTitle symbol:appendable == 0 ? nil : @"plus"];
    };
    refreshButtons();
    countSeg.onChange = ^(NSInteger index) {
        if (index < 0 || index >= (NSInteger)counts.count) { return; }
        weakSelf.randomCount = counts[index].integerValue;
        refreshButtons();
    };

    __block TSHsdSheet *sheet = nil;
    sheet = [TSHsdSheet sheetWithTitle:TSLocalizedString(@"hsd.game.random_title")
                           buttonTitle:TSLocalizedString(@"general.cancel")
                                blocks:@[countSec, countSeg, edgeCard, replaceButton, appendButton]
                              onButton:^{ [sheet dismiss]; }];
    replaceButton.onTap = ^{
        [sheet dismiss];
        [weakSelf ts_generateRandomReplacing:YES];
    };
    appendButton.onTap = ^{
        [sheet dismiss];
        [weakSelf ts_generateRandomReplacing:NO];
    };
    [sheet presentFrom:self];
}

/// 追加模式下实际能生成的条数：受总数上限与未使用的游戏数限制
- (NSUInteger)ts_appendableCount {
    NSMutableSet<NSNumber *> *used = [NSMutableSet set];
    for (TSHsdGameRankingTrendModel *t in self.trends) { [used addObject:@(t.gameType)]; }
    NSInteger room = (NSInteger)TSHsdGameRankingTrendMaxCount - (NSInteger)self.trends.count;
    NSInteger unused = kTSHsdGameTypeCount - (NSInteger)used.count;
    return (NSUInteger)MAX(0, MIN(self.randomCount, MIN(room, unused)));
}

/// 生成随机排名：游戏不重复（排除 excluded），排名 1–99 偏向靠前，趋势等概率
- (NSArray<TSHsdGameRankingTrendModel *> *)ts_randomTrendsWithCount:(NSUInteger)count excluding:(NSSet<NSNumber *> *)excluded {
    NSMutableArray<NSNumber *> *pool = [NSMutableArray array];
    for (NSInteger g = 0; g < kTSHsdGameTypeCount; g++) {
        if (![excluded containsObject:@(g)]) { [pool addObject:@(g)]; }
    }
    for (NSUInteger i = pool.count; i > 1; i--) {
        [pool exchangeObjectAtIndex:i - 1 withObjectAtIndex:arc4random_uniform((uint32_t)i)];
    }
    NSUInteger n = MIN(count, pool.count);
    NSMutableArray<TSHsdGameRankingTrendModel *> *result = [NSMutableArray arrayWithCapacity:n];
    for (NSUInteger i = 0; i < n; i++) {
        TSHsdGameRankingTrendModel *m = [[TSHsdGameRankingTrendModel alloc] init];
        m.gameType = (TSHsdGameType)pool[i].integerValue;
        // 取两个随机数中较小的：名次更集中在前面，像真实数据
        m.ranking = MIN(arc4random_uniform(kTSHsdRandomRankingRange), arc4random_uniform(kTSHsdRandomRankingRange)) + 1;
        m.trend = (TSHsdRankingTrend)arc4random_uniform(3);
        [result addObject:m];
    }
    if (self.randomIncludesEdge && result.count > 0) {
        result.firstObject.ranking = 0;
        if (result.count > 1) { result.lastObject.ranking = TSHsdGameRankingMax; }
    }
    return result;
}

- (void)ts_generateRandomReplacing:(BOOL)replace {
    NSMutableSet<NSNumber *> *excluded = [NSMutableSet set];
    NSUInteger count = (NSUInteger)self.randomCount;
    if (!replace) {
        for (TSHsdGameRankingTrendModel *t in self.trends) { [excluded addObject:@(t.gameType)]; }
        count = [self ts_appendableCount];
    }
    NSArray<TSHsdGameRankingTrendModel *> *generated = [self ts_randomTrendsWithCount:count excluding:excluded];
    if (generated.count == 0) {
        [self toast:TSLocalizedString(@"hsd.game.random_append_none")];
        return;
    }
    // 撤销快照
    self.undoTrends = [[NSArray alloc] initWithArray:self.trends copyItems:YES];
    self.undoRandomGameTypes = [self.randomGameTypes copy];
    self.undoDirty = self.dirty;

    if (replace) {
        [self.trends removeAllObjects];
        [self.randomGameTypes removeAllObjects];
    }
    [self.freshGameTypes removeAllObjects];
    for (TSHsdGameRankingTrendModel *m in generated) {
        [self.trends addObject:m];
        [self.randomGameTypes addObject:@(m.gameType)];
        [self.freshGameTypes addObject:@(m.gameType)];
    }
    self.dirty = YES;
    [self render];
    [self ts_playGenerateAnimation];
    TSLog(@"[TSHsdGameVC] random trends %@: %lu (edge=%d)", replace ? @"replace" : @"append", (unsigned long)generated.count, self.randomIncludesEdge);
    [self ts_showUndoToast:[NSString stringWithFormat:TSLocalizedString(@"hsd.game.random_done_format"), (unsigned long)generated.count]];
}

/// 骰子转一圈 + 新行依次滑入
- (void)ts_playGenerateAnimation {
    UIView *icon = self.trendsSec.actionButton.imageView;
    if (icon) {
        CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        spin.fromValue = @0;
        spin.toValue = @(M_PI * 2);
        spin.duration = 0.5;
        spin.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [icon.layer addAnimation:spin forKey:@"hsd.dice"];
    }
    [self.freshRows enumerateObjectsUsingBlock:^(UIView *row, NSUInteger i, BOOL *stop) {
        row.alpha = 0;
        row.transform = CGAffineTransformMakeTranslation(0, 8.f);
        [UIView animateWithDuration:0.36 delay:0.045 * i usingSpringWithDamping:0.82 initialSpringVelocity:0.4 options:0 animations:^{
            row.alpha = 1;
            row.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
    [self.freshRows removeAllObjects];
    [self.freshGameTypes removeAllObjects];
}

- (void)ts_showUndoToast:(NSString *)message {
    __weak typeof(self) weakSelf = self;
    self.undoToast.onUndo = ^{ [weakSelf ts_undoRandom]; };
    CGFloat bottom = self.view.bounds.size.height - self.view.safeAreaInsets.bottom - 16.f;
    if (self.dock.superview && !self.dock.hidden) {
        bottom = CGRectGetMinY([self.dock convertRect:self.dock.bounds toView:self.view]) - 12.f;
    }
    [self.undoToast showInView:self.view bottom:bottom message:message];
}

- (void)ts_undoRandom {
    if (!self.undoTrends) { return; }
    [self.trends setArray:self.undoTrends];
    [self.randomGameTypes setSet:self.undoRandomGameTypes ?: [NSSet set]];
    self.dirty = self.undoDirty;
    [self ts_clearUndo];
    [self render];
}

- (void)ts_clearUndo {
    self.undoTrends = nil;
    self.undoRandomGameTypes = nil;
    [_undoToast hide];
}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    __weak typeof(self) weakSelf = self;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];

    TSHsdSegView *seg = [[TSHsdSegView alloc] init];
    seg.items = @[[TSHsdSegItem itemWithTitle:TSLocalizedString(@"hsd.game.tab.records") symbol:@"trophy.fill"],
                  [TSHsdSegItem itemWithTitle:TSLocalizedString(@"hsd.game.tab.trends") symbol:@"chart.bar.fill"]];
    seg.selectedIndex = self.showingTrends ? 1 : 0;
    seg.onChange = ^(NSInteger index) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        self.showingTrends = (index == 1);
        if (!self.showingTrends && self.recordState == 0 && !self.records) { [self ts_loadRecords]; } else { [self render]; }
    };
    [blocks addObject:seg];

    if (!self.showingTrends) {
        [self ts_buildRecords:blocks];
    } else {
        [self ts_buildTrends:blocks];
    }
    return blocks;
}

- (void)ts_buildRecords:(NSMutableArray<UIView *> *)blocks {
    __weak typeof(self) weakSelf = self;
    NSMutableArray<NSString *> *titles = [NSMutableArray array], *symbols = [NSMutableArray array];
    for (NSInteger g = 0; g < kTSHsdGameTypeCount; g++) {
        [titles addObject:[TSHsdDisplay gameName:g]];
        [symbols addObject:[TSHsdDisplay symbolForGameType:g]];
    }
    TSHsdHScrollPicker *games = [[TSHsdHScrollPicker alloc] init];
    games.tileStyle = YES;
    games.hue = self.hue;
    [games setItemsWithTitles:titles smalls:nil dotColors:nil symbols:symbols];
    games.selectedIndex = self.gameType;
    games.onChange = ^(NSInteger index) {
        weakSelf.gameType = index;
        weakSelf.records = nil;
        [weakSelf ts_loadRecords];
    };
    [blocks addObject:games];

    if (self.recordState == 0) { [blocks addObject:[self loadingBlock:nil]]; return; }
    if (self.recordState == 2) { [blocks addObject:[self errorBlock:self.recordError retry:^{ [weakSelf ts_loadRecords]; }]]; return; }
    if (!self.records.count) {
        [blocks addObject:[self card:@[[self emptyWithSymbol:@"trophy.fill" title:TSLocalizedString(@"hsd.game.no_record_title") text:TSLocalizedString(@"hsd.game.no_record_text")
                                                          code:[NSString stringWithFormat:@"gameType %ld", (long)self.gameType]]]]];
        return;
    }
    [blocks addObject:[self sec:[TSHsdDisplay gameName:self.gameType] right:[NSString stringWithFormat:TSLocalizedString(@"hsd.game.records_right_format"), (unsigned long)self.records.count]]];
    NSMutableArray<UIView *> *rows = [NSMutableArray array];
    [self.records enumerateObjectsUsingBlock:^(TSHsdGameRecordModel *record, NSUInteger i, BOOL *stop) {
        TSHsdGameRecordRowView *row = [[TSHsdGameRecordRowView alloc] init];
        [row configureIndex:i + 1 record:record hue:self.hue];
        [rows addObject:row];
    }];
    [blocks addObject:[self card:rows]];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.game.records_foot")]];
}

- (void)ts_buildTrends:(NSMutableArray<UIView *> *)blocks {
    __weak typeof(self) weakSelf = self;
    NSDate *sentAt = [TSHsdLocalCache rankingTrendsSentDate];
    NSString *bannerText = sentAt
        ? [NSString stringWithFormat:TSLocalizedString(@"hsd.write_only.banner_sent_format"), [TSHsdDisplay fullDateString:sentAt]]
        : TSLocalizedString(@"hsd.write_only.banner_never");
    [blocks addObject:[self banner:bannerText warn:NO]];
    self.invalid = (self.trends.count == 0);   // 0 条时禁用发送：SDK 对空数组返回参数错误
    TSHsdSecView *trendsSec = [self sec:TSLocalizedString(@"hsd.game.sec.trends") right:[NSString stringWithFormat:@"%lu / %lu", (unsigned long)self.trends.count, (unsigned long)TSHsdGameRankingTrendMaxCount]];
    trendsSec.hue = self.hue;
    trendsSec.actionSymbol = TSHsdDiceSymbolName();
    trendsSec.actionTitle = TSLocalizedString(@"hsd.game.random");
    trendsSec.onAction = ^{ [weakSelf ts_randomTapped]; };
    self.trendsSec = trendsSec;
    [blocks addObject:trendsSec];

    if (self.trends.count) {
        NSMutableArray<UIView *> *rows = [NSMutableArray array];
        [self.trends enumerateObjectsUsingBlock:^(TSHsdGameRankingTrendModel *t, NSUInteger i, BOOL *stop) {
            TSHsdTrendRowView *row = [[TSHsdTrendRowView alloc] init];
            [row configureWithTrend:t random:[self.randomGameTypes containsObject:@(t.gameType)] hue:self.hue];
            if ([self.freshGameTypes containsObject:@(t.gameType)]) { [self.freshRows addObject:row]; }
            row.onTap = ^{ [weakSelf ts_editTrend:t]; };
            [rows addObject:row];
        }];
        [blocks addObject:[self card:rows]];
    } else {
        TSHsdEmptyView *empty = [self emptyWithSymbol:@"chart.bar.fill" title:TSLocalizedString(@"hsd.game.trends_empty_title") text:TSLocalizedString(@"hsd.game.trends_empty_text") code:nil];
        empty.actionSymbol = TSHsdDiceSymbolName();
        empty.actionTitle = [NSString stringWithFormat:TSLocalizedString(@"hsd.game.random_empty_format"), (long)self.randomCount];
        empty.onAction = ^{ [weakSelf ts_generateRandomReplacing:YES]; };
        [blocks addObject:[self card:@[empty]]];
    }

    TSHsdTwoButtonsView *buttons = [[TSHsdTwoButtonsView alloc] init];
    buttons.left.title = TSLocalizedString(@"hsd.game.add_game");
    buttons.left.enabled = self.trends.count < kTSHsdGameTypeCount;
    buttons.left.onTap = ^{ [weakSelf ts_addTrend]; };
    buttons.right.symbol = @"sparkles";
    buttons.right.title = TSLocalizedString(@"hsd.game.fill_25");
    buttons.right.onTap = ^{ [weakSelf ts_fillTrends]; };
    [blocks addObject:buttons];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.game.trends_foot")]];
}

#pragma mark - 懒加载

- (TSHsdUndoToastView *)undoToast {
    if (!_undoToast) {
        _undoToast = [[TSHsdUndoToastView alloc] init];
    }
    return _undoToast;
}

@end
