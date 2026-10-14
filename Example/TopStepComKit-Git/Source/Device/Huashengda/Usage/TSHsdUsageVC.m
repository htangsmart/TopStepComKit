//
//  TSHsdUsageVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdUsageVC.h"

typedef NS_ENUM(NSInteger, TSHsdUsageSlotState) {
    TSHsdUsageSlotIdle = 0,
    TSHsdUsageSlotLoading,
    TSHsdUsageSlotOK,
    TSHsdUsageSlotError,
};

/// 一个分段（应用 / 游戏）的读取结果
@interface TSHsdUsageSlot : NSObject
@property (nonatomic, assign) TSHsdUsageSlotState state;
@property (nonatomic, copy, nullable) NSArray<TSHsdDailyUsageModel *> *days;
@property (nonatomic, strong, nullable) NSError *error;
@end
@implementation TSHsdUsageSlot
@end

#pragma mark - 当天总览（.sumcard）

@interface TSHsdUsageSumView : UIView
@property (nonatomic, strong) UILabel *keyLabel;
@property (nonatomic, strong) UILabel *bigLabel;
@property (nonatomic, strong) UILabel *sideLabel;
@end

@implementation TSHsdUsageSumView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _keyLabel = [[UILabel alloc] init]; _keyLabel.font = [UIFont systemFontOfSize:12.5f]; _keyLabel.textColor = [TSHsdDisplay textSecondary]; [self addSubview:_keyLabel];
    _bigLabel = [[UILabel alloc] init]; [self addSubview:_bigLabel];
    _sideLabel = [[UILabel alloc] init]; _sideLabel.numberOfLines = 2; _sideLabel.textAlignment = NSTextAlignmentRight; [self addSubview:_sideLabel];
    return self;
}

- (void)configureKey:(NSString *)key total:(NSInteger)total unit:(NSString *)unit side:(NSString *)side {
    self.keyLabel.text = key;
    NSMutableAttributedString *big = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)total]
        attributes:@{NSFontAttributeName: [TSHsdDisplay roundedFontOfSize:46.f weight:UIFontWeightHeavy], NSForegroundColorAttributeName: [TSHsdDisplay ink]}];
    [big appendAttributedString:[[NSAttributedString alloc] initWithString:[@" " stringByAppendingString:unit]
        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.f weight:UIFontWeightSemibold], NSForegroundColorAttributeName: [TSHsdDisplay textSecondary]}]];
    self.bigLabel.attributedText = big;
    self.sideLabel.attributedText = TSHsdRich(side, [UIFont systemFontOfSize:12.5f], [TSHsdDisplay textSecondary], [TSHsdDisplay ink]);
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 18.f + 16.f + 8.f + 46.f + 18.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.keyLabel.frame = CGRectMake(18.f, 18.f, w * 0.6f, 16.f);
    self.bigLabel.frame = CGRectMake(18.f, 42.f, w * 0.6f, 46.f);
    self.sideLabel.frame = CGRectMake(w * 0.5f, 50.f, w * 0.5f - 18.f, 40.f);
}

@end

#pragma mark - 条形榜（.bars / .bar）

@interface TSHsdUsageBarsView : UIView
@property (nonatomic, copy) NSArray<TSHsdUsageItem *> *items;
@property (nonatomic, assign) BOOL isApp;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, strong) NSMutableArray<UIView *> *rows;
@end

@implementation TSHsdUsageBarsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _rows = [NSMutableArray array];
    _hue = [TSHsdDisplay hueUsage];
    return self;
}

- (void)reloadRows {
    for (UIView *row in self.rows) { [row removeFromSuperview]; }
    [self.rows removeAllObjects];
    NSInteger max = self.items.firstObject.count ?: 1;
    [self.items enumerateObjectsUsingBlock:^(TSHsdUsageItem *item, NSUInteger i, BOOL *stop) {
        UIView *row = [[UIView alloc] init];
        UILabel *rank = [[UILabel alloc] init];
        rank.tag = 1001; rank.font = [TSHsdDisplay roundedFontOfSize:11.f weight:UIFontWeightBold]; rank.textColor = [TSHsdDisplay textTertiary]; rank.textAlignment = NSTextAlignmentCenter;
        rank.text = [NSString stringWithFormat:@"%lu", (unsigned long)(i + 1)];
        [row addSubview:rank];
        TSHsdIconBlock *icon = [[TSHsdIconBlock alloc] init];
        icon.tag = 1002; icon.side = 30.f; icon.emoStyle = YES;
        icon.symbol = self.isApp ? [TSHsdDisplay symbolForApp:item.type] : [TSHsdDisplay symbolForGameType:item.type];
        [row addSubview:icon];
        UILabel *name = [[UILabel alloc] init];
        name.tag = 1003; name.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium]; name.textColor = [TSHsdDisplay ink];
        name.text = self.isApp ? [TSHsdDisplay appName:item.type] : [TSHsdDisplay gameName:item.type];
        [row addSubview:name];
        UIView *bar = [[UIView alloc] init];
        bar.tag = 1004; bar.backgroundColor = self.hue;
        bar.layer.cornerRadius = 4.f; bar.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
        bar.layer.name = [NSString stringWithFormat:@"%f", (double)item.count / (double)max];
        [row addSubview:bar];
        UILabel *count = [[UILabel alloc] init];
        count.tag = 1005; count.font = [TSHsdDisplay roundedFontOfSize:14.f weight:UIFontWeightBold]; count.textColor = [TSHsdDisplay ink]; count.textAlignment = NSTextAlignmentRight;
        count.text = [NSString stringWithFormat:@"%ld", (long)item.count];
        [row addSubview:count];
        [self addSubview:row];
        [self.rows addObject:row];
    }];
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 8.f * 2 + self.rows.count * 44.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    [self.rows enumerateObjectsUsingBlock:^(UIView *row, NSUInteger i, BOOL *stop) {
        row.frame = CGRectMake(0, 8.f + i * 44.f, w, 44.f);
        CGFloat x = 16.f;
        [row viewWithTag:1001].frame = CGRectMake(x, 0, 18.f, 44.f); x += 18.f + 9.f;
        [row viewWithTag:1002].frame = CGRectMake(x, 7.f, 30.f, 30.f); x += 30.f + 9.f;
        [row viewWithTag:1003].frame = CGRectMake(x, 0, 84.f, 44.f); x += 84.f + 9.f;
        CGFloat countW = 28.f;
        CGFloat trackW = w - 16.f - countW - 9.f - x;
        UIView *bar = [row viewWithTag:1004];
        CGFloat ratio = bar.layer.name.doubleValue;
        bar.frame = CGRectMake(x, 17.f, MAX(4.f, trackW * ratio), 10.f);
        [row viewWithTag:1005].frame = CGRectMake(w - 16.f - countW, 0, countW, 44.f);
    }];
}

@end

#pragma mark - TSHsdUsageVC

@interface TSHsdUsageVC ()
@property (nonatomic, assign) BOOL showingGame;
@property (nonatomic, assign) NSInteger dayIndex;
@property (nonatomic, strong) TSHsdUsageSlot *appSlot;
@property (nonatomic, strong) TSHsdUsageSlot *gameSlot;
@end

@implementation TSHsdUsageVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.usage");
    self.hue = [TSHsdDisplay hueUsage];
    self.usesDock = NO;
    self.chips = @[@"bit33", TSLocalizedString(@"hsd.usage.chip")];
    self.appSlot = [[TSHsdUsageSlot alloc] init];
    self.gameSlot = [[TSHsdUsageSlot alloc] init];
}

- (TSHsdUsageSlot *)ts_currentSlot { return self.showingGame ? self.gameSlot : self.appSlot; }

#pragma mark - 读取

- (void)reload {
    self.dayIndex = 0;
    [self ts_loadGame:self.showingGame completion:nil];
}

- (void)ts_loadGame:(BOOL)game completion:(nullable void (^)(TSHsdUsageSlot *slot))completion {
    TSHsdUsageSlot *slot = game ? self.gameSlot : self.appSlot;
    slot.state = TSHsdUsageSlotLoading;
    [self render];
    NSString *method = game ? @"huashengda.fetchGameUsage:" : @"huashengda.fetchAppUsage:";
    TSHsdCallLogEntry *entry = [self beginCall:method params:nil];
    __weak typeof(self) weakSelf = self;
    TSHsdDailyUsageResultBlock handler = ^(NSArray<TSHsdDailyUsageModel *> *days, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            if (error || !days) {
                [self finishCall:entry success:NO error:error result:nil];
                slot.state = TSHsdUsageSlotError;
                slot.error = error;
            } else {
                [self finishCall:entry success:YES error:nil result:[NSString stringWithFormat:@"%lu days", (unsigned long)days.count]];
                slot.state = TSHsdUsageSlotOK;
                slot.days = days;
            }
            [self render];
            if (completion) { completion(slot); }
        }];
    };
    if (game) { [self.hsd fetchGameUsage:handler]; } else { [self.hsd fetchAppUsage:handler]; }
}

#pragma mark - 重置

- (void)ts_reset {
    __weak typeof(self) weakSelf = self;
    [self confirmTitle:TSLocalizedString(@"hsd.usage.reset_confirm") message:TSLocalizedString(@"hsd.usage.reset_confirm_msg")
          confirmTitle:TSLocalizedString(@"hsd.usage.reset") destructive:YES handler:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        [self showLoading];
        TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.resetUsageStatistics:" params:nil];
        [self.hsd resetUsageStatistics:^(BOOL isSuccess, NSError *error) {
            [weakSelf onMain:^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) { return; }
                [self hideLoading];
                if (!isSuccess) {
                    [self finishCall:entry success:NO error:error result:nil];
                    [self alertError:error title:TSLocalizedString(@"hsd.usage.reset_failed")];
                    return;
                }
                [self finishCall:entry success:YES error:nil result:nil];
                // 重置后自动重新拉取两类并汇报（D-33 / D-37）
                self.dayIndex = 0;
                [self ts_loadGame:NO completion:^(TSHsdUsageSlot *appSlot) {
                    [weakSelf ts_loadGame:YES completion:^(TSHsdUsageSlot *gameSlot) {
                        [weakSelf toast:[NSString stringWithFormat:TSLocalizedString(@"hsd.usage.reset_report_format"),
                                         [weakSelf ts_reportForSlot:appSlot], [weakSelf ts_reportForSlot:gameSlot]]];
                    }];
                }];
            }];
        }];
    }];
}

- (NSString *)ts_reportForSlot:(TSHsdUsageSlot *)slot {
    if (slot.state != TSHsdUsageSlotOK) { return TSLocalizedString(@"general.load_failed"); }
    if (slot.days.count == 0) { return TSLocalizedString(@"hsd.usage.cleared"); }
    return [NSString stringWithFormat:TSLocalizedString(@"hsd.usage.still_days_format"), (unsigned long)slot.days.count];
}

#pragma mark - 积木

- (NSArray<UIView *> *)buildBlocks {
    __weak typeof(self) weakSelf = self;
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];

    TSHsdSegView *seg = [[TSHsdSegView alloc] init];
    seg.items = @[[TSHsdSegItem itemWithTitle:TSLocalizedString(@"hsd.usage.app") symbol:nil], [TSHsdSegItem itemWithTitle:TSLocalizedString(@"hsd.usage.game") symbol:nil]];
    seg.selectedIndex = self.showingGame ? 1 : 0;
    seg.onChange = ^(NSInteger index) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { return; }
        self.showingGame = (index == 1);
        self.dayIndex = 0;
        if ([self ts_currentSlot].state == TSHsdUsageSlotIdle) { [self ts_loadGame:self.showingGame completion:nil]; } else { [self render]; }
    };
    [blocks addObject:seg];

    TSHsdUsageSlot *slot = [self ts_currentSlot];
    BOOL isApp = !self.showingGame;
    if (slot.state == TSHsdUsageSlotIdle || slot.state == TSHsdUsageSlotLoading) {
        [blocks addObject:[self loadingBlock:nil]];
        return blocks;
    }
    if (slot.state == TSHsdUsageSlotError) {
        [blocks addObject:[self errorBlock:slot.error retry:^{ [weakSelf ts_loadGame:weakSelf.showingGame completion:nil]; }]];
        return blocks;
    }
    NSArray<TSHsdDailyUsageModel *> *days = slot.days;
    if (!days.count) {
        [blocks addObject:[self card:@[[self emptyWithSymbol:@"tray" title:TSLocalizedString(@"hsd.usage.empty_title")
                                                          text:[NSString stringWithFormat:TSLocalizedString(@"hsd.usage.empty_text_format"), isApp ? TSLocalizedString(@"hsd.usage.app") : TSLocalizedString(@"hsd.usage.game")] code:nil]]]];
        return blocks;
    }

    // 日期条
    NSInteger dayIndex = MIN(self.dayIndex, (NSInteger)days.count - 1);
    TSHsdDailyUsageModel *day = days[dayIndex];
    [blocks addObject:[self sec:TSLocalizedString(@"hsd.usage.sec.date") right:[NSString stringWithFormat:TSLocalizedString(@"hsd.usage.kept_days_format"), (unsigned long)days.count]]];
    NSMutableArray<NSString *> *titles = [NSMutableArray array], *smalls = [NSMutableArray array];
    NSMutableArray<UIColor *> *dots = [NSMutableArray array];
    BOOL anyInferred = NO;
    for (TSHsdDailyUsageModel *d in days) {
        [titles addObject:[TSHsdDisplay dayLabelForOffset:d.dayOffset date:d.date]];
        BOOL device = (d.dateSource == TSHsdUsageDateSourceDevice);
        [smalls addObject:device ? TSLocalizedString(@"hsd.usage.source.device") : TSLocalizedString(@"hsd.usage.source.inferred")];
        [dots addObject:device ? [TSHsdDisplay statusGood] : [TSHsdDisplay statusWarn]];
        if (!device) { anyInferred = YES; }
    }
    TSHsdHScrollPicker *picker = [[TSHsdHScrollPicker alloc] init];
    picker.hue = self.hue;
    [picker setItemsWithTitles:titles smalls:smalls dotColors:dots symbols:nil];
    picker.selectedIndex = dayIndex;
    picker.onChange = ^(NSInteger index) { weakSelf.dayIndex = index; [weakSelf render]; };
    [blocks addObject:picker];
    if (anyInferred) { [blocks addObject:[self banner:TSLocalizedString(@"hsd.usage.banner_inferred") warn:YES]]; }

    // 当天内容
    NSArray<TSHsdUsageItem *> *items = [day.items sortedArrayUsingComparator:^NSComparisonResult(TSHsdUsageItem *a, TSHsdUsageItem *b) {
        return [@(b.count) compare:@(a.count)];
    }];
    TSHsdDangerLink *reset = [[TSHsdDangerLink alloc] init];
    reset.title = TSLocalizedString(@"hsd.usage.reset");
    reset.enabled = self.connected;
    reset.onTap = ^{ [weakSelf ts_reset]; };
    TSHsdFootView *resetFoot = [self foot:TSLocalizedString(@"hsd.usage.foot_reset")];

    if (!items.count) {
        [blocks addObject:[self card:@[[self emptyWithSymbol:@"moon.zzz.fill" title:TSLocalizedString(@"hsd.usage.empty_day_title") text:TSLocalizedString(@"hsd.usage.empty_day_text")
                                                          code:[NSString stringWithFormat:@"dayOffset %ld · items = []", (long)day.dayOffset]]]]];
        [blocks addObject:reset];
        [blocks addObject:resetFoot];
        return blocks;
    }
    NSInteger total = 0;
    for (TSHsdUsageItem *item in items) { total += item.count; }
    NSString *topName = isApp ? [TSHsdDisplay appName:items.firstObject.type] : [TSHsdDisplay gameName:items.firstObject.type];
    TSHsdUsageSumView *sum = [[TSHsdUsageSumView alloc] init];
    [sum configureKey:[NSString stringWithFormat:@"%@ · dayOffset %ld", [TSHsdDisplay dayLabelForOffset:day.dayOffset date:day.date], (long)day.dayOffset]
                total:total unit:TSLocalizedString(@"hsd.usage.times_unit")
                 side:[NSString stringWithFormat:TSLocalizedString(@"hsd.usage.side_format"), (unsigned long)items.count,
                       isApp ? TSLocalizedString(@"hsd.usage.app_unit") : TSLocalizedString(@"hsd.usage.game_unit"), topName]];
    [blocks addObject:[self card:@[sum]]];

    [blocks addObject:[self sec:TSLocalizedString(@"hsd.usage.sec.sorted") right:nil]];
    TSHsdUsageBarsView *bars = [[TSHsdUsageBarsView alloc] init];
    bars.hue = self.hue;
    bars.isApp = isApp;
    bars.items = items;
    [bars reloadRows];
    [blocks addObject:[self card:@[bars]]];
    [blocks addObject:[self foot:TSLocalizedString(@"hsd.usage.foot_count")]];
    [blocks addObject:reset];
    [blocks addObject:resetFoot];
    return blocks;
}

@end
