//
//  TSSportDetailVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/6.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSSportDetailVC.h"
#import "TSHeartRateChartView.h"
#import <TopStepComKit/TopStepComKit.h>

static const CGFloat kCardPad = 16.f;
static const CGFloat kCardSpacing = 12.f;

@interface TSSportDetailVC ()

@property (nonatomic, strong) TSSportModel *sport;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TSHeartRateChartView *chartView;

@end

@implementation TSSportDetailVC

- (instancetype)initWithSport:(TSSportModel *)sport {
    self = [super init];
    if (!self) return nil;
    _sport = sport;
    return self;
}

#pragma mark - Override Base Setup

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"sport.detail.title");
}

- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;

    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = TSColor_Background;
    _scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:_scrollView];

    [self buildContentViews];
}

- (void)layoutViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;

    _scrollView.frame = CGRectMake(0, top, w, h - top);

    // 重新布局内容
    [self layoutContentViews];
}

- (void)buildContentViews {
    TSSportSummaryModel *summary = _sport.summary;
    CGFloat w = CGRectGetWidth(self.view.bounds);
    if (w <= 0) w = [UIScreen mainScreen].bounds.size.width;
    CGFloat cardW = w - kCardPad * 2;
    CGFloat y = kCardSpacing;

    // ① 顶部概览卡片
    UIView *overviewCard = [self createOverviewCard:cardW];
    overviewCard.frame = CGRectMake(kCardPad, y, cardW, 140);
    [_scrollView addSubview:overviewCard];
    y += 140 + kCardSpacing;

    // ② 核心数据卡片
    UIView *metricsCard = [self createMetricsCard:cardW];
    metricsCard.frame = CGRectMake(kCardPad, y, cardW, 120);
    [_scrollView addSubview:metricsCard];
    y += 120 + kCardSpacing;

    // ③ 心率分析卡片
    if (summary.avgHrValue > 0) {
        // 计算心率卡片高度：标题(30) + 心率统计(60) + 图表(130) + 5个区间(44*5) + 底部间距(16)
        CGFloat hrCardH = kCardPad + 30 + 60 + 130 + (44 * 5) + kCardPad;
        UIView *hrCard = [self createHeartRateCard:cardW];
        hrCard.frame = CGRectMake(kCardPad, y, cardW, hrCardH);
        [_scrollView addSubview:hrCard];
        y += hrCardH + kCardSpacing;
    }

    // ④ 游泳专属数据
    if ([self isSwimmingSport:summary.type]) {
        UIView *swimCard = [self createSwimCard:cardW];
        swimCard.frame = CGRectMake(kCardPad, y, cardW, 100);
        [_scrollView addSubview:swimCard];
        y += 100 + kCardSpacing;
    }

    y += self.view.safeAreaInsets.bottom;
    _scrollView.contentSize = CGSizeMake(w, y);
}

- (void)layoutContentViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat cardW = w - kCardPad * 2;
    CGFloat y = kCardSpacing;

    for (UIView *subview in _scrollView.subviews) {
        CGFloat h = CGRectGetHeight(subview.frame);
        subview.frame = CGRectMake(kCardPad, y, cardW, h);
        y += h + kCardSpacing;
    }

    y += self.view.safeAreaInsets.bottom;
    _scrollView.contentSize = CGSizeMake(w, y);
}

#pragma mark - Card Builders

- (UIView *)createOverviewCard:(CGFloat)width {
    UIView *card = [self createCard];
    TSSportSummaryModel *summary = _sport.summary;

    // 运动图标
    UILabel *iconLabel = [[UILabel alloc] init];
    iconLabel.text = [self sportTypeIcon:summary.type];
    iconLabel.font = [UIFont systemFontOfSize:40];
    iconLabel.textAlignment = NSTextAlignmentCenter;
    iconLabel.frame = CGRectMake(0, 20, width, 50);
    [card addSubview:iconLabel];

    // 运动类型
    UILabel *typeLabel = [[UILabel alloc] init];
    typeLabel.text = [self sportTypeName:summary.type];
    typeLabel.font = TSFont_H1;
    typeLabel.textColor = TSColor_TextPrimary;
    typeLabel.textAlignment = NSTextAlignmentCenter;
    typeLabel.frame = CGRectMake(0, 75, width, 24);
    [card addSubview:typeLabel];

    // 日期时间
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = TSLocalizedString(@"sport.detail.date_format");
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:summary.startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:summary.endTime];
    fmt.dateFormat = @"HH:mm";
    NSString *timeRange = [NSString stringWithFormat:@"%@ - %@",
                          [fmt stringFromDate:startDate],
                          [fmt stringFromDate:endDate]];

    fmt.dateFormat = TSLocalizedString(@"sport.detail.date_only_format");
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.text = [NSString stringWithFormat:@"%@ %@",
                     [fmt stringFromDate:startDate], timeRange];
    dateLabel.font = TSFont_Caption;
    dateLabel.textColor = TSColor_TextSecondary;
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.frame = CGRectMake(0, 102, width, 16);
    [card addSubview:dateLabel];

    return card;
}

- (UIView *)createMetricsCard:(CGFloat)width {
    UIView *card = [self createCard];
    TSSportSummaryModel *summary = _sport.summary;

    CGFloat itemW = (width - kCardPad * 2) / 3.f;
    CGFloat y = kCardPad;

    // 第一行：距离、消耗、配速
    [self addMetricToCard:card
                        x:kCardPad
                        y:y
                    width:itemW
                    value:[NSString stringWithFormat:@"%.2f", summary.distance / 1000.f]
                     unit:@"km"
                    title:TSLocalizedString(@"sport.detail.distance")];

    [self addMetricToCard:card
                        x:kCardPad + itemW
                        y:y
                    width:itemW
                    value:[NSString stringWithFormat:@"%.2f", summary.calorie / 1000.f]
                     unit:@"kcal"
                    title:TSLocalizedString(@"sport.detail.calories")];

    // 配速需要同时满足：有配速数据且有距离数据
    if (summary.avgPace > 0 && summary.distance > 0) {
        int minutes = (int)(summary.avgPace / 60);
        int seconds = (int)summary.avgPace % 60;
        [self addMetricToCard:card
                            x:kCardPad + itemW * 2
                            y:y
                        width:itemW
                        value:[NSString stringWithFormat:@"%d'%02d\"", minutes, seconds]
                         unit:@""
                        title:TSLocalizedString(@"sport.detail.avg_pace")];
    }

    // 第二行：步数、步频、步幅
    y += 50;
    if (summary.steps > 0) {
        [self addMetricToCard:card
                            x:kCardPad
                            y:y
                        width:itemW
                        value:[NSString stringWithFormat:@"%u", summary.steps]
                         unit:@""
                        title:TSLocalizedString(@"sport.detail.steps")];
    }

    if (summary.avgCadence > 0) {
        [self addMetricToCard:card
                            x:kCardPad + itemW
                            y:y
                        width:itemW
                        value:[NSString stringWithFormat:@"%u", summary.avgCadence]
                         unit:TSLocalizedString(@"sport.detail.cadence_unit")
                        title:TSLocalizedString(@"sport.detail.avg_cadence")];
    }

    return card;
}

- (UIView *)createHeartRateCard:(CGFloat)width {
    UIView *card = [self createCard];
    TSSportSummaryModel *summary = _sport.summary;

    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TSLocalizedString(@"sport.detail.hr_analysis");
    titleLabel.font = TSFont_H2;
    titleLabel.textColor = TSColor_TextPrimary;
    titleLabel.frame = CGRectMake(kCardPad, kCardPad, width - kCardPad * 2, 22);
    [card addSubview:titleLabel];

    // 切换按钮
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [switchBtn setTitle:TSLocalizedString(@"sport.detail.switch_btn") forState:UIControlStateNormal];
    switchBtn.titleLabel.font = TSFont_Caption;
    switchBtn.frame = CGRectMake(width - 60, kCardPad, 50, 22);
    [switchBtn addTarget:self action:@selector(onSwitchChartType) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:switchBtn];

    // 心率统计
    CGFloat y = kCardPad + 30;
    CGFloat itemW = (width - kCardPad * 2) / 3.f;

    [self addMetricToCard:card x:kCardPad y:y width:itemW
                    value:[NSString stringWithFormat:@"%u", summary.avgHrValue]
                     unit:@"bpm" title:TSLocalizedString(@"sport.detail.average")];
    [self addMetricToCard:card x:kCardPad + itemW y:y width:itemW
                    value:[NSString stringWithFormat:@"%u", summary.maxHrValue]
                     unit:@"bpm" title:TSLocalizedString(@"sport.detail.max")];
    [self addMetricToCard:card x:kCardPad + itemW * 2 y:y width:itemW
                    value:[NSString stringWithFormat:@"%u", summary.minHrValue]
                     unit:@"bpm" title:TSLocalizedString(@"sport.detail.min")];

    // 心率图表
    y += 60;
    _chartView = [[TSHeartRateChartView alloc] init];
    _chartView.frame = CGRectMake(kCardPad, y, width - kCardPad * 2, 120);
    [_chartView configureWithSummary:summary heartRateItems:_sport.heartRateItems];
    [card addSubview:_chartView];

    // 心率区间详情
    y += 130;
    NSArray *zones = @[
        @{@"name": TSLocalizedString(@"sport.detail.zone.warmup"), @"duration": @(summary.warmHrDuration), @"ratio": @(summary.warmHrRatio), @"color": TSColor_Gray},
        @{@"name": TSLocalizedString(@"sport.detail.zone.fat_burn"), @"duration": @(summary.fatBurnHrDuration), @"ratio": @(summary.fatBurnHrRatio), @"color": TSColor_Primary},
        @{@"name": TSLocalizedString(@"sport.detail.zone.aerobic"), @"duration": @(summary.aerobicHrDuration), @"ratio": @(summary.aerobicHrRatio), @"color": TSColor_Success},
        @{@"name": TSLocalizedString(@"sport.detail.zone.anaerobic"), @"duration": @(summary.anaerobicHrDuration), @"ratio": @(summary.anaerobicHrRatio), @"color": TSColor_Warning},
        @{@"name": TSLocalizedString(@"sport.detail.zone.extreme"), @"duration": @(summary.extremeHrDuration), @"ratio": @(summary.extremeHrRatio), @"color": TSColor_Danger}
    ];

    for (NSDictionary *zone in zones) {
        UInt32 duration = [zone[@"duration"] unsignedIntValue];
        UInt8 ratio = [zone[@"ratio"] unsignedCharValue];
        UIColor *color = zone[@"color"];
        NSString *name = zone[@"name"];

        // 容器视图
        UIView *zoneContainer = [[UIView alloc] initWithFrame:CGRectMake(kCardPad, y, width - kCardPad * 2, 40)];
        [card addSubview:zoneContainer];

        // 左侧：彩色圆点 + 名称
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(0, 12, 8, 8)];
        dot.backgroundColor = color;
        dot.layer.cornerRadius = 4;
        [zoneContainer addSubview:dot];

        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = name;
        nameLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        nameLabel.textColor = TSColor_TextPrimary;
        nameLabel.frame = CGRectMake(14, 0, 80, 32);
        [zoneContainer addSubview:nameLabel];

        // 中间：进度条
        CGFloat progressBarX = 100;
        CGFloat progressBarW = width - kCardPad * 2 - progressBarX - 60;

        // 进度条背景
        UIView *progressBg = [[UIView alloc] initWithFrame:CGRectMake(progressBarX, 10, progressBarW, 12)];
        progressBg.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.f];
        progressBg.layer.cornerRadius = 6;
        progressBg.clipsToBounds = YES;
        [zoneContainer addSubview:progressBg];

        // 进度条填充
        CGFloat fillWidth = progressBarW * (ratio / 100.f);
        if (fillWidth > 0) {
            UIView *progressFill = [[UIView alloc] initWithFrame:CGRectMake(0, 0, fillWidth, 12)];
            progressFill.backgroundColor = color;
            [progressBg addSubview:progressFill];
        }

        // 右侧：百分比标签
        UILabel *percentLabel = [[UILabel alloc] init];
        percentLabel.text = [NSString stringWithFormat:@"%u%%", ratio];
        percentLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        percentLabel.textColor = color;
        percentLabel.textAlignment = NSTextAlignmentRight;
        percentLabel.frame = CGRectMake(progressBarX + progressBarW + 8, 0, 50, 32);
        [zoneContainer addSubview:percentLabel];

        // 底部：时长标签（小字灰色）
        UILabel *durationLabel = [[UILabel alloc] init];
        durationLabel.text = [self formatDuration:duration];
        durationLabel.font = TSFont_Caption;
        durationLabel.textColor = TSColor_TextSecondary;
        durationLabel.frame = CGRectMake(14, 24, 200, 14);
        [zoneContainer addSubview:durationLabel];

        y += 44;
    }

    return card;
}

- (UIView *)createSwimCard:(CGFloat)width {
    UIView *card = [self createCard];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TSLocalizedString(@"sport.detail.swim_data");
    titleLabel.font = TSFont_H2;
    titleLabel.textColor = TSColor_TextPrimary;
    titleLabel.frame = CGRectMake(kCardPad, kCardPad, width - kCardPad * 2, 22);
    [card addSubview:titleLabel];

    // TODO: 从 sportItems 中提取游泳数据
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = TSLocalizedString(@"sport.detail.swim_hint");
    hintLabel.font = TSFont_Caption;
    hintLabel.textColor = TSColor_TextSecondary;
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.frame = CGRectMake(kCardPad, 50, width - kCardPad * 2, 30);
    [card addSubview:hintLabel];

    return card;
}

#pragma mark - Actions

- (void)onSwitchChartType {
    [_chartView switchChartType];
}

#pragma mark - Helpers

- (UIView *)createCard {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = TSColor_Card;
    card.layer.cornerRadius = TSRadius_MD;
    card.layer.shadowColor = UIColor.blackColor.CGColor;
    card.layer.shadowOpacity = 0.06f;
    card.layer.shadowOffset = CGSizeMake(0, 2);
    card.layer.shadowRadius = 6.f;
    return card;
}

- (void)addMetricToCard:(UIView *)card
                      x:(CGFloat)x
                      y:(CGFloat)y
                  width:(CGFloat)width
                  value:(NSString *)value
                   unit:(NSString *)unit
                  title:(NSString *)title {
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    valueLabel.textColor = TSColor_TextPrimary;
    valueLabel.textAlignment = NSTextAlignmentCenter;

    if (unit.length > 0) {
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", value, unit]];
        [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(value.length + 1, unit.length)];
        valueLabel.attributedText = attr;
    } else {
        valueLabel.text = value;
    }

    valueLabel.frame = CGRectMake(x, y, width, 24);
    [card addSubview:valueLabel];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = TSFont_Caption;
    titleLabel.textColor = TSColor_TextSecondary;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.frame = CGRectMake(x, y + 26, width, 14);
    [card addSubview:titleLabel];
}

- (NSString *)formatDuration:(UInt32)seconds {
    int minutes = seconds / 60;
    int secs = seconds % 60;
    return [NSString stringWithFormat:TSLocalizedString(@"sport.detail.pace_format"), minutes, secs];
}

- (NSString *)sportTypeName:(TSSportTypeEnum)type {
    switch (type) {
        case TSSportTypeOutdoorRunning: return TSLocalizedString(@"sport.type.outdoor_running");
        case TSSportTypeIndoorRunning: return TSLocalizedString(@"sport.type.indoor_running");
        case TSSportTypeOutdoorWalking: return TSLocalizedString(@"sport.type.outdoor_walking");
        case TSSportTypeOutdoorCycling: return TSLocalizedString(@"sport.type.outdoor_cycling");
        case TSSportTypeIndoorCycling: return TSLocalizedString(@"sport.type.indoor_cycling");
        case TSSportTypeSwimming: return TSLocalizedString(@"sport.type.swimming");
        case TSSportTypePoolSwimming: return TSLocalizedString(@"sport.type.swimming");
        case TSSportTypeBasketball: return TSLocalizedString(@"sport.type.basketball");
        case TSSportTypeFootball: return TSLocalizedString(@"sport.type.football");
        case TSSportTypeBadminton: return TSLocalizedString(@"sport.type.badminton");
        case TSSportTypeYoga: return TSLocalizedString(@"sport.type.yoga");
        case TSSportTypeRopeSkipping: return TSLocalizedString(@"sport.type.rope_skipping");
        case TSSportTypeClimbing: return TSLocalizedString(@"sport.type.climbing");
        case TSSportTypeHiking: return TSLocalizedString(@"sport.type.hiking");
        default: return TSLocalizedString(@"sport.type.default");
    }
}

- (NSString *)sportTypeIcon:(TSSportTypeEnum)type {
    if (type == TSSportTypeOutdoorRunning || type == TSSportTypeIndoorRunning) {
        return @"🏃";
    } else if (type == TSSportTypeOutdoorCycling || type == TSSportTypeIndoorCycling) {
        return @"🚴";
    } else if (type == TSSportTypeSwimming || type == TSSportTypePoolSwimming) {
        return @"🏊";
    } else if (type == TSSportTypeBasketball || type == TSSportTypeFootball || type == TSSportTypeBadminton) {
        return @"🏀";
    } else if (type == TSSportTypeYoga) {
        return @"🧘";
    } else if (type == TSSportTypeRopeSkipping) {
        return @"🪢";
    } else if (type == TSSportTypeClimbing || type == TSSportTypeHiking) {
        return @"⛰️";
    }
    return @"💪";
}

- (BOOL)isSwimmingSport:(TSSportTypeEnum)type {
    return type == TSSportTypeSwimming || type == TSSportTypePoolSwimming || type == TSSportTypeOpenWaterSwimming;
}

@end
