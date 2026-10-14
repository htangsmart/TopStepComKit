//
//  TSHuashengdaVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHuashengdaVC.h"
#import "TSHsdCapabilityCardView.h"

#pragma mark - 功能入口

@interface TSHsdFeatureEntry : NSObject
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy) NSString *vcName;
@property (nonatomic, assign) BOOL supported;
@property (nonatomic, assign) BOOL wide;
@end
@implementation TSHsdFeatureEntry
@end

#pragma mark - Bento 瓦片（.tile）

@interface TSHsdTileView : UIControl
@property (nonatomic, strong) TSHsdIconBlock *icon;
@property (nonatomic, strong) UIImageView *chevron;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) CAShapeLayer *dashed;
@property (nonatomic, strong) UIView *skeletonA;
@property (nonatomic, strong) UIView *skeletonB;
@property (nonatomic, assign) BOOL off;
@property (nonatomic, assign) BOOL wide;
@property (nonatomic, assign) BOOL skeleton;
@property (nonatomic, copy, nullable) void (^onTap)(void);
@end

@implementation TSHsdTileView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    self.layer.cornerRadius = 22.f;
    _dashed = [CAShapeLayer layer];
    _dashed.fillColor = [UIColor clearColor].CGColor;
    _dashed.lineWidth = 1.5f;
    _dashed.lineDashPattern = @[@5, @4];
    _dashed.hidden = YES;
    [self.layer addSublayer:_dashed];
    _icon = [[TSHsdIconBlock alloc] init];
    [self addSubview:_icon];
    _chevron = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"chevron.right", 13.f, UIImageSymbolWeightSemibold)];
    _chevron.tintColor = [TSHsdDisplay textTertiary];
    _chevron.contentMode = UIViewContentModeCenter;
    [self addSubview:_chevron];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightBold];
    _titleLabel.textColor = [TSHsdDisplay ink];
    [self addSubview:_titleLabel];
    _summaryLabel = [[UILabel alloc] init];
    _summaryLabel.numberOfLines = 3;
    [self addSubview:_summaryLabel];
    _skeletonA = [[UIView alloc] init]; _skeletonA.backgroundColor = [TSHsdDisplay fill]; _skeletonA.layer.cornerRadius = 4.5f; _skeletonA.hidden = YES; [self addSubview:_skeletonA];
    _skeletonB = [[UIView alloc] init]; _skeletonB.backgroundColor = [TSHsdDisplay fill]; _skeletonB.layer.cornerRadius = 4.5f; _skeletonB.hidden = YES; [self addSubview:_skeletonB];
    [self addTarget:self action:@selector(ts_tapped) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(ts_down) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(ts_up) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    return self;
}

- (void)configureWithEntry:(TSHsdFeatureEntry *)entry summary:(nullable NSString *)summary skeleton:(BOOL)skeleton {
    self.off = !entry.supported;
    self.wide = entry.wide;
    self.skeleton = skeleton && entry.supported;
    self.icon.symbol = entry.symbol;
    self.icon.side = entry.wide ? 48.f : 40.f;
    self.icon.tint = entry.supported ? entry.color : [TSHsdDisplay textTertiary];
    self.icon.emoStyle = !entry.supported;
    self.titleLabel.text = entry.title;
    self.titleLabel.textColor = entry.supported ? [TSHsdDisplay ink] : [TSHsdDisplay textSecondary];
    NSString *text = entry.supported ? (summary ?: entry.desc) : TSLocalizedString(@"hsd.unsupported_tile");
    self.summaryLabel.attributedText = TSHsdRich(text, [UIFont systemFontOfSize:12.5f], [TSHsdDisplay textSecondary], [TSHsdDisplay ink]);
    self.summaryLabel.hidden = self.skeleton;
    self.skeletonA.hidden = self.skeletonB.hidden = !self.skeleton;
    self.chevron.hidden = !entry.supported;
    self.backgroundColor = entry.supported ? [TSHsdDisplay card] : [UIColor clearColor];
    self.dashed.hidden = entry.supported;
    self.layer.shadowColor = [UIColor colorWithRed:0x14/255.f green:0x17/255.f blue:0x26/255.f alpha:1].CGColor;
    self.layer.shadowOpacity = entry.supported ? 0.06f : 0;
    self.layer.shadowRadius = 10.f;
    self.layer.shadowOffset = CGSizeMake(0, 4.f);
    [self setNeedsLayout];
}

- (void)ts_tapped { if (self.onTap) { self.onTap(); } }
- (void)ts_down { if (!self.off) { [UIView animateWithDuration:0.14 animations:^{ self.transform = CGAffineTransformMakeScale(0.975f, 0.975f); }]; } }
- (void)ts_up { [UIView animateWithDuration:0.14 animations:^{ self.transform = CGAffineTransformIdentity; }]; }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    self.dashed.frame = self.bounds;
    self.dashed.strokeColor = TSAdaptiveColor([UIColor colorWithRed:0xE1/255.f green:0xE4/255.f blue:0xEE/255.f alpha:1], [UIColor colorWithRed:0x2A/255.f green:0x2F/255.f blue:0x40/255.f alpha:1]).CGColor;
    self.dashed.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0.75f, 0.75f) cornerRadius:22.f].CGPath;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:22.f].CGPath;
    if (self.wide) {
        self.icon.frame = CGRectMake(15.f, (h - 48.f) / 2.f, 48.f, 48.f);
        self.chevron.frame = CGRectMake(w - 15.f - 16.f, (h - 16.f) / 2.f, 16.f, 16.f);
        CGFloat x = 15.f + 48.f + 13.f, tw = CGRectGetMinX(self.chevron.frame) - x - 8.f;
        CGFloat sh = MIN(36.f, ceil([self.summaryLabel sizeThatFits:CGSizeMake(tw, CGFLOAT_MAX)].height));
        CGFloat block = 20.f + 4.f + sh;
        self.titleLabel.frame = CGRectMake(x, (h - block) / 2.f, tw, 20.f);
        self.summaryLabel.frame = CGRectMake(x, CGRectGetMaxY(self.titleLabel.frame) + 4.f, tw, sh);
        return;
    }
    self.icon.frame = CGRectMake(15.f, 15.f, 40.f, 40.f);
    self.chevron.frame = CGRectMake(w - 15.f - 16.f, 15.f, 16.f, 16.f);
    self.titleLabel.frame = CGRectMake(15.f, 15.f + 40.f + 12.f, w - 30.f, 20.f);
    CGFloat sy = CGRectGetMaxY(self.titleLabel.frame) + 4.f;
    CGFloat sh = MIN(54.f, ceil([self.summaryLabel sizeThatFits:CGSizeMake(w - 30.f, CGFLOAT_MAX)].height));
    self.summaryLabel.frame = CGRectMake(15.f, sy, w - 30.f, sh);
    self.skeletonA.frame = CGRectMake(15.f, sy + 4.f, 88.f, 9.f);
    self.skeletonB.frame = CGRectMake(15.f, sy + 19.f, 56.f, 9.f);
}

@end

#pragma mark - Bento 网格（.bento）

@interface TSHsdBentoView : UIView
@property (nonatomic, copy) NSArray<TSHsdTileView *> *tiles;
@end

@implementation TSHsdBentoView

- (void)setTiles:(NSArray<TSHsdTileView *> *)tiles {
    for (UIView *t in _tiles) { [t removeFromSuperview]; }
    _tiles = [tiles copy];
    for (UIView *t in tiles) { [self addSubview:t]; }
    [self setNeedsLayout];
}

- (CGFloat)ts_tileHeightForWidth:(CGFloat)tileW {
    CGFloat h = 132.f;
    for (TSHsdTileView *tile in self.tiles) {
        if (tile.wide) { continue; }
        CGFloat sh = MIN(54.f, ceil([tile.summaryLabel sizeThatFits:CGSizeMake(tileW - 30.f, CGFLOAT_MAX)].height));
        h = MAX(h, 15.f + 40.f + 12.f + 20.f + 4.f + sh + 15.f);
    }
    return h;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat tileW = (size.width - 12.f) / 2.f;
    CGFloat tileH = [self ts_tileHeightForWidth:tileW];
    CGFloat y = 0; NSInteger col = 0;
    for (TSHsdTileView *tile in self.tiles) {
        if (tile.wide) {
            if (col == 1) { y += tileH + 12.f; col = 0; }
            y += 80.f + 12.f;
        } else {
            if (col == 1) { y += tileH + 12.f; col = 0; } else { col = 1; }
        }
    }
    if (col == 1) { y += tileH + 12.f; }
    return CGSizeMake(size.width, MAX(0, y - 12.f));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, tileW = (w - 12.f) / 2.f;
    CGFloat tileH = [self ts_tileHeightForWidth:tileW];
    CGFloat y = 0; NSInteger col = 0;
    for (TSHsdTileView *tile in self.tiles) {
        if (tile.wide) {
            if (col == 1) { y += tileH + 12.f; col = 0; }
            tile.frame = CGRectMake(0, y, w, 80.f);
            y += 80.f + 12.f;
        } else {
            tile.frame = CGRectMake(col * (tileW + 12.f), y, tileW, tileH);
            if (col == 1) { y += tileH + 12.f; col = 0; } else { col = 1; }
        }
    }
}

@end

#pragma mark - TSHuashengdaVC

@interface TSHuashengdaVC ()
@property (nonatomic, strong) TSHsdCapabilityCardView *capabilityCard;
@property (nonatomic, copy) NSArray<NSString *> *groupTitles;
@property (nonatomic, copy) NSArray<NSArray<TSHsdFeatureEntry *> *> *groups;
/// 设备卡能力条的顺序
@property (nonatomic, copy) NSArray<TSHsdFeatureEntry *> *capabilityOrder;
/// 摘要缓存：key → 模型 / NSNull（读取失败）；不存在表示未读
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *hubCache;
@property (nonatomic, assign) BOOL hubLoading;
@end

@implementation TSHuashengdaVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"device.menu.huashengda");
    self.hue = [TSHsdDisplay hueParental];
    self.usesDock = NO;
    self.showsReloadButton = YES;
    self.chips = @[@"TSHuashengdaInterface", TSLocalizedString(@"hsd.overview.chip")];
    self.hubCache = [NSMutableDictionary dictionary];
    [self ts_buildEntries];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 回到本页重新判断一次能力：真机上能力数据在连接后才完整
    [self ts_buildEntries];
    [self render];
}

- (void)reload {
    [self ts_buildEntries];
    [self.hubCache removeAllObjects];
    [self render];
    [self ts_loadHub];
}

#pragma mark - 入口

- (TSHsdFeatureEntry *)ts_entryWithKey:(NSString *)key title:(NSString *)title shortName:(NSString *)shortName desc:(NSString *)desc
                                symbol:(NSString *)symbol color:(UIColor *)color vcName:(NSString *)vcName supported:(BOOL)supported wide:(BOOL)wide {
    TSHsdFeatureEntry *e = [[TSHsdFeatureEntry alloc] init];
    e.key = key; e.title = title; e.shortName = shortName; e.desc = desc;
    e.symbol = symbol; e.color = color; e.vcName = vcName; e.supported = supported; e.wide = wide;
    return e;
}

- (void)ts_buildEntries {
    id<TSHuashengdaInterface> hsd = self.hsd;
    // 家长模式有两个版本：进阶版（isSupportParentalControl，NPK）走 TSHsdParentalControlVC；基础版（isSupportParentalMode，FitCloud）走 TSHsdParentalModeVC
    BOOL parentalControl = [hsd isSupportParentalControl];
    TSHsdFeatureEntry *parental = [self ts_entryWithKey:@"parental" title:TSLocalizedString(@"hsd.parental") shortName:TSLocalizedString(@"hsd.parental.short") desc:TSLocalizedString(@"hsd.parental.sub")
                                               symbol:@"shield.fill" color:[TSHsdDisplay hueParental] vcName:parentalControl ? @"TSHsdParentalControlVC" : @"TSHsdParentalModeVC"
                                            supported:parentalControl || [hsd isSupportParentalMode] wide:NO];
    TSHsdFeatureEntry *classroom = [self ts_entryWithKey:@"classroom" title:TSLocalizedString(@"hsd.classroom") shortName:TSLocalizedString(@"hsd.classroom.short") desc:TSLocalizedString(@"hsd.classroom.sub")
                                                symbol:@"graduationcap.fill" color:[TSHsdDisplay hueClassroom] vcName:@"TSHsdClassroomModeVC" supported:[hsd isSupportClassroomMode] wide:NO];
    TSHsdFeatureEntry *task = [self ts_entryWithKey:@"taskInfo" title:TSLocalizedString(@"hsd.task") shortName:TSLocalizedString(@"hsd.task.short") desc:TSLocalizedString(@"hsd.task.sub")
                                           symbol:@"checklist" color:[TSHsdDisplay hueTask] vcName:@"TSHsdTaskVC" supported:[hsd isSupportTaskReward] wide:NO];
    TSHsdFeatureEntry *habit = [self ts_entryWithKey:@"habits" title:TSLocalizedString(@"hsd.habit") shortName:TSLocalizedString(@"hsd.habit.short") desc:TSLocalizedString(@"hsd.habit.sub")
                                            symbol:@"leaf.fill" color:[TSHsdDisplay hueHabit] vcName:@"TSHsdHabitVC" supported:[hsd isSupportHabit] wide:NO];
    TSHsdFeatureEntry *usage = [self ts_entryWithKey:@"" title:TSLocalizedString(@"hsd.usage") shortName:TSLocalizedString(@"hsd.usage.short") desc:TSLocalizedString(@"hsd.usage.sub")
                                            symbol:@"chart.bar.fill" color:[TSHsdDisplay hueUsage] vcName:@"TSHsdUsageVC" supported:[hsd isSupportUsageStatistics] wide:NO];
    TSHsdFeatureEntry *game = [self ts_entryWithKey:@"" title:TSLocalizedString(@"hsd.game") shortName:TSLocalizedString(@"hsd.game.short") desc:TSLocalizedString(@"hsd.game.sub")
                                           symbol:@"gamecontroller.fill" color:[TSHsdDisplay hueGame] vcName:@"TSHsdGameVC" supported:[hsd isSupportGame] wide:NO];
    TSHsdFeatureEntry *ice = [self ts_entryWithKey:@"ice" title:TSLocalizedString(@"hsd.ice") shortName:TSLocalizedString(@"hsd.ice.short") desc:TSLocalizedString(@"hsd.ice.sub")
                                          symbol:@"cross.case.fill" color:[TSHsdDisplay hueIce] vcName:@"TSHsdIceVC" supported:[hsd isSupportIce] wide:YES];
    self.groupTitles = @[TSLocalizedString(@"hsd.group.control"), TSLocalizedString(@"hsd.group.growth"), TSLocalizedString(@"hsd.group.insight"), TSLocalizedString(@"hsd.group.safety")];
    self.groups = @[@[parental, classroom], @[task, habit], @[usage, game], @[ice]];
    self.capabilityOrder = @[ice, parental, classroom, task, habit, usage, game];
}

- (NSArray<TSHsdFeatureEntry *> *)ts_allEntries {
    NSMutableArray<TSHsdFeatureEntry *> *all = [NSMutableArray array];
    for (NSArray *group in self.groups) { [all addObjectsFromArray:group]; }
    return all;
}

#pragma mark - 摘要预读

/// 顺序读取 4 个轻量接口生成卡片摘要；读过的不重复读；某个失败只影响那一张卡
- (void)ts_loadHub {
    if (self.hubLoading) { return; }
    NSArray<NSString *> *order = @[@"parental", @"classroom", @"taskInfo", @"habits"];
    NSString *next = nil;
    for (NSString *key in order) {
        TSHsdFeatureEntry *entry = [self ts_entryForKey:key];
        if (entry.supported && !self.hubCache[key]) { next = key; break; }
    }
    if (!next) { return; }
    self.hubLoading = YES;
    __weak typeof(self) weakSelf = self;
    void (^done)(id, NSError *, NSString *) = ^(id model, NSError *error, NSString *summary) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            self.hubCache[next] = (error || !model) ? [NSNull null] : model;
            self.hubLoading = NO;
            [self render];
            [self ts_loadHub];
        }];
    };
    if ([next isEqualToString:@"parental"] && [self.hsd isSupportParentalControl]) {
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchParentalControl:" params:TSLocalizedString(@"hsd.log.hub_summary")];
        [self.hsd fetchParentalControl:^(TSHsdParentalControlModel *model, NSError *error) {
            [weakSelf finishCall:entry success:(error == nil && model) error:error result:nil];
            done(model, error, nil);
        }];
    } else if ([next isEqualToString:@"parental"]) {
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchParentalMode:" params:TSLocalizedString(@"hsd.log.hub_summary")];
        [self.hsd fetchParentalMode:^(TSHsdParentalModeModel *model, NSError *error) {
            [weakSelf finishCall:entry success:(error == nil && model) error:error result:nil];
            done(model, error, nil);
        }];
    } else if ([next isEqualToString:@"classroom"]) {
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchClassroomMode:" params:TSLocalizedString(@"hsd.log.hub_summary")];
        [self.hsd fetchClassroomMode:^(TSHsdClassroomModeModel *model, NSError *error) {
            [weakSelf finishCall:entry success:(error == nil && model) error:error result:nil];
            done(model, error, nil);
        }];
    } else if ([next isEqualToString:@"taskInfo"]) {
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchTaskInfo:" params:TSLocalizedString(@"hsd.log.hub_summary")];
        [self.hsd fetchTaskInfo:^(TSHsdTaskInfoModel *model, NSError *error) {
            [weakSelf finishCall:entry success:(error == nil && model) error:error result:model ? [NSString stringWithFormat:@"%lu tasks · coins %ld", (unsigned long)model.tasks.count, (long)model.totalCoins] : nil];
            done(model, error, nil);
        }];
    } else {
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.fetchHabits:" params:TSLocalizedString(@"hsd.log.hub_summary")];
        [self.hsd fetchHabits:^(NSArray<TSHsdHabitModel *> *habits, NSError *error) {
            [weakSelf finishCall:entry success:(error == nil && habits) error:error result:habits ? [NSString stringWithFormat:@"%lu habits", (unsigned long)habits.count] : nil];
            done(habits, error, nil);
        }];
    }
}

- (nullable TSHsdFeatureEntry *)ts_entryForKey:(NSString *)key {
    for (TSHsdFeatureEntry *e in [self ts_allEntries]) { if ([e.key isEqualToString:key]) { return e; } }
    return nil;
}

/// 卡片摘要文案（<b> 段加粗）；nil 表示用默认描述
- (nullable NSString *)ts_summaryForEntry:(TSHsdFeatureEntry *)entry skeleton:(BOOL *)skeleton {
    *skeleton = NO;
    if ([entry.key isEqualToString:@"ice"]) {
        NSDate *sent = [TSHsdLocalCache iceSentDate];
        if (!sent) { return nil; }
        return [NSString stringWithFormat:TSLocalizedString(@"hsd.overview.ice_sent_format"), (unsigned long)[TSHsdLocalCache iceLabels].count, [TSHsdDisplay clockString:sent]];
    }
    if (!entry.key.length) { return nil; }
    id cached = self.hubCache[entry.key];
    if (!cached) { *skeleton = YES; return nil; }
    if (cached == [NSNull null]) { return TSLocalizedString(@"hsd.overview.summary_failed"); }
    if ([entry.key isEqualToString:@"parental"] && [cached isKindOfClass:TSHsdParentalControlModel.class]) {
        TSHsdParentalControlModel *m = cached;
        if (!m.isEnabled) { return TSLocalizedString(@"hsd.overview.not_enabled"); }
        NSUInteger active = 0;
        for (TSHsdParentalControlItemModel *item in m.items) { if (item.isEnabled) { active++; } }
        return active ? [NSString stringWithFormat:TSLocalizedString(@"hsd.overview.pc_on_format"), (long)active] : TSLocalizedString(@"hsd.overview.pc_on_none");
    }
    if ([entry.key isEqualToString:@"parental"]) {
        TSHsdParentalModeModel *m = cached;
        if (!m.isEnabled) { return TSLocalizedString(@"hsd.overview.not_enabled"); }
        return m.isGameDurationEnabled
            ? [NSString stringWithFormat:TSLocalizedString(@"hsd.overview.parental_on_game_format"), [TSHsdDisplay timeStringForMinute:m.gameStartMinute], [TSHsdDisplay timeStringForMinute:m.gameEndMinute]]
            : TSLocalizedString(@"hsd.overview.parental_on_nolimit");
    }
    if ([entry.key isEqualToString:@"classroom"]) {
        TSHsdClassroomModeModel *m = cached;
        if (!m.isEnabled) { return TSLocalizedString(@"hsd.overview.not_enabled"); }
        return [NSString stringWithFormat:@"<b>%@</b> %@–%@", [TSHsdDisplay repeatString:m.repeatOptions], [TSHsdDisplay timeStringForMinute:m.startMinute], [TSHsdDisplay timeStringForMinute:m.endMinute]];
    }
    if ([entry.key isEqualToString:@"taskInfo"]) {
        TSHsdTaskInfoModel *m = cached;
        return [NSString stringWithFormat:TSLocalizedString(@"hsd.overview.task_format"), (unsigned long)m.tasks.count, (long)m.totalCoins];
    }
    if ([entry.key isEqualToString:@"habits"]) {
        NSArray<TSHsdHabitModel *> *list = cached;
        NSUInteger ongoing = 0;
        for (TSHsdHabitModel *h in list) { if (h.state == TSHsdHabitStateOngoing) { ongoing++; } }
        return [NSString stringWithFormat:TSLocalizedString(@"hsd.overview.habit_format"), (unsigned long)list.count, (unsigned long)ongoing];
    }
    return nil;
}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    __weak typeof(self) weakSelf = self;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];

    // 设备卡
    TSPeripheral *peripheral = [TopStepComKit sharedInstance].connectedPeripheral;
    NSMutableArray<TSHsdCapabilityItem *> *items = [NSMutableArray array];
    for (TSHsdFeatureEntry *e in self.capabilityOrder) {
        [items addObject:[TSHsdCapabilityItem itemWithName:e.title shortName:e.shortName supported:e.supported]];
    }
    self.capabilityCard.deviceName = peripheral.systemInfo.bleName.length ? peripheral.systemInfo.bleName : @"NPK";
    self.capabilityCard.connected = (peripheral != nil);
    self.capabilityCard.statusText = peripheral ? TSLocalizedString(@"hsd.cap.connected") : TSLocalizedString(@"hsd.cap.disconnected");
    self.capabilityCard.items = items;
    [blocks addObject:self.capabilityCard];

    // 四组 Bento
    [self.groups enumerateObjectsUsingBlock:^(NSArray<TSHsdFeatureEntry *> *group, NSUInteger gi, BOOL *stop) {
        [blocks addObject:[self sec:self.groupTitles[gi] right:nil]];
        NSMutableArray<TSHsdTileView *> *tiles = [NSMutableArray array];
        for (TSHsdFeatureEntry *entry in group) {
            TSHsdTileView *tile = [[TSHsdTileView alloc] init];
            BOOL skeleton = NO;
            NSString *summary = [self ts_summaryForEntry:entry skeleton:&skeleton];
            [tile configureWithEntry:entry summary:summary skeleton:skeleton];
            tile.onTap = ^{ [weakSelf ts_open:entry]; };
            [tiles addObject:tile];
        }
        TSHsdBentoView *bento = [[TSHsdBentoView alloc] init];
        bento.tiles = tiles;
        [blocks addObject:bento];
    }];

    // 验证
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.group.verify") right:nil]];
    TSHsdRowView *tools = [self row];
    tools.symbol = @"testtube.2";
    tools.iconColor = [TSHsdDisplay hueTools];
    tools.title = TSLocalizedString(@"hsd.tools");
    tools.subtitle = TSLocalizedString(@"hsd.tools.sub");
    tools.showsChevron = YES;
    tools.onTap = ^{ [weakSelf ts_pushClassNamed:@"TSHsdBoundaryToolsVC" title:TSLocalizedString(@"hsd.tools")]; };
    [blocks addObject:[self card:@[tools]]];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.overview.footer")]];

    [self ts_loadHub];
    return blocks;
}

#pragma mark - 跳转

- (void)ts_open:(TSHsdFeatureEntry *)entry {
    if (!entry.supported) {
        [self showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"hsd.unsupported_alert_format"), entry.title]];
        return;
    }
    [self ts_pushClassNamed:entry.vcName title:entry.title];
}

- (void)ts_pushClassNamed:(NSString *)vcName title:(NSString *)title {
    Class cls = NSClassFromString(vcName);
    if (!cls) {
        [self showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"hsd.page_pending_format"), title]];
        return;
    }
    UIViewController *vc = [[cls alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载

- (TSHsdCapabilityCardView *)capabilityCard {
    if (!_capabilityCard) {
        _capabilityCard = [[TSHsdCapabilityCardView alloc] init];
        __weak typeof(self) weakSelf = self;
        _capabilityCard.onToggle = ^(BOOL expanded) {
            [UIView animateWithDuration:0.25 animations:^{
                [weakSelf.stack setNeedsLayout];
                [weakSelf.stack layoutIfNeeded];
                [weakSelf layoutViews];
            }];
        };
    }
    return _capabilityCard;
}

@end
