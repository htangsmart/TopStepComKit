//
//  TSSportCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/6.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSSportCell.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSBaseVC.h"

static const CGFloat kCellPadding = 16.f;
static const CGFloat kColorBarWidth = 4.f;
static const CGFloat kIconSize = 24.f;

@implementation TSSportCell {
    UIView  *_cardView;
    UIView  *_colorBar;
    UILabel *_iconLabel;
    UILabel *_typeLabel;
    UILabel *_timeLabel;

    UILabel *_durationValueLabel;
    UILabel *_durationTitleLabel;
    UILabel *_distanceValueLabel;
    UILabel *_distanceTitleLabel;
    UILabel *_calorieValueLabel;
    UILabel *_calorieTitleLabel;

    UILabel *_heartRateLabel;
    UILabel *_paceLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.backgroundColor = UIColor.clearColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self setupViews];

    return self;
}

- (void)setupViews {
    // 卡片容器
    _cardView = [[UIView alloc] init];
    _cardView.backgroundColor = TSColor_Card;
    _cardView.layer.cornerRadius = TSRadius_MD;
    _cardView.layer.shadowColor = UIColor.blackColor.CGColor;
    _cardView.layer.shadowOpacity = 0.06f;
    _cardView.layer.shadowOffset = CGSizeMake(0, 2);
    _cardView.layer.shadowRadius = 6.f;
    [self.contentView addSubview:_cardView];

    // 左侧彩色竖条
    _colorBar = [[UIView alloc] init];
    _colorBar.layer.cornerRadius = 2.f;
    [_cardView addSubview:_colorBar];

    // 运动图标
    _iconLabel = [[UILabel alloc] init];
    _iconLabel.font = [UIFont systemFontOfSize:20];
    _iconLabel.textAlignment = NSTextAlignmentCenter;
    [_cardView addSubview:_iconLabel];

    // 运动类型
    _typeLabel = [[UILabel alloc] init];
    _typeLabel.font = TSFont_H2;
    _typeLabel.textColor = TSColor_TextPrimary;
    [_cardView addSubview:_typeLabel];

    // 时间段
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = TSFont_Caption;
    _timeLabel.textColor = TSColor_TextSecondary;
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [_cardView addSubview:_timeLabel];

    // 三个核心指标
    _durationValueLabel = [self createValueLabel];
    _durationTitleLabel = [self createTitleLabel:@"时长"];
    _distanceValueLabel = [self createValueLabel];
    _distanceTitleLabel = [self createTitleLabel:@"距离"];
    _calorieValueLabel = [self createValueLabel];
    _calorieTitleLabel = [self createTitleLabel:@"消耗"];

    [_cardView addSubview:_durationValueLabel];
    [_cardView addSubview:_durationTitleLabel];
    [_cardView addSubview:_distanceValueLabel];
    [_cardView addSubview:_distanceTitleLabel];
    [_cardView addSubview:_calorieValueLabel];
    [_cardView addSubview:_calorieTitleLabel];

    // 次要指标
    _heartRateLabel = [self createSecondaryLabel];
    _paceLabel = [self createSecondaryLabel];
    [_cardView addSubview:_heartRateLabel];
    [_cardView addSubview:_paceLabel];
}

- (UILabel *)createValueLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    label.textColor = TSColor_TextPrimary;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UILabel *)createTitleLabel:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = TSFont_Caption;
    label.textColor = TSColor_TextSecondary;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UILabel *)createSecondaryLabel {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = TSColor_TextSecondary;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)configureWithSport:(TSSportModel *)sport {
    TSSportSummaryModel *summary = sport.summary;

    // 运动类型和图标
    _typeLabel.text = [self sportTypeName:summary.type];
    _iconLabel.text = [self sportTypeIcon:summary.type];
    _colorBar.backgroundColor = [self sportTypeColor:summary.type];

    // 时间段
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm";
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:summary.startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:summary.endTime];
    _timeLabel.text = [NSString stringWithFormat:@"%@ - %@",
                       [fmt stringFromDate:startDate],
                       [fmt stringFromDate:endDate]];

    // 时长
    _durationValueLabel.text = [self formatDuration:summary.duration];

    // 距离
    if (summary.distance > 0) {
        _distanceValueLabel.text = [NSString stringWithFormat:@"%.2f km", summary.distance / 1000.f];
    } else {
        _distanceValueLabel.text = @"--";
    }

    // 卡路里
    if (summary.calorie > 0) {
        _calorieValueLabel.text = [NSString stringWithFormat:@"%.2f kcal", summary.calorie / 1000.f];
    } else {
        _calorieValueLabel.text = @"--";
    }

    // 心率
    if (summary.avgHrValue > 0) {
        _heartRateLabel.text = [NSString stringWithFormat:@"❤️ 平均心率 %u bpm", summary.avgHrValue];
    } else {
        _heartRateLabel.text = @"";
    }

    // 配速（需要同时有配速数据和距离数据）
    if (summary.avgPace > 0 && summary.distance > 0) {
        int minutes = (int)(summary.avgPace / 60);
        int seconds = (int)summary.avgPace % 60;
        _paceLabel.text = [NSString stringWithFormat:@"配速 %d'%02d\"/km", minutes, seconds];
    } else {
        _paceLabel.text = @"";
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat w = CGRectGetWidth(self.contentView.bounds);
    CGFloat cardW = w - kCellPadding * 2;

    // 计算卡片实际需要的高度
    CGFloat cardH = kCellPadding + kIconSize + TSSpacing_MD + 36 + TSSpacing_SM + 16 + kCellPadding;

    _cardView.frame = CGRectMake(kCellPadding, TSSpacing_SM, cardW, cardH);

    // 左侧彩色竖条
    _colorBar.frame = CGRectMake(0, kCellPadding, kColorBarWidth, cardH - kCellPadding * 2);

    // 顶部：图标 + 类型 + 时间
    CGFloat x = kColorBarWidth + TSSpacing_MD;
    _iconLabel.frame = CGRectMake(x, kCellPadding, kIconSize, kIconSize);
    x += kIconSize + TSSpacing_SM;

    CGFloat timeW = 100;
    _typeLabel.frame = CGRectMake(x, kCellPadding, cardW - x - timeW - kCellPadding, kIconSize);
    _timeLabel.frame = CGRectMake(cardW - timeW - kCellPadding, kCellPadding, timeW, kIconSize);

    // 三个核心指标（等宽分布）
    CGFloat y = kCellPadding + kIconSize + TSSpacing_MD;
    CGFloat metricW = (cardW - kColorBarWidth - kCellPadding * 2) / 3.f;
    x = kColorBarWidth + kCellPadding;

    _durationValueLabel.frame = CGRectMake(x, y, metricW, 20);
    _durationTitleLabel.frame = CGRectMake(x, y + 22, metricW, 14);

    x += metricW;
    _distanceValueLabel.frame = CGRectMake(x, y, metricW, 20);
    _distanceTitleLabel.frame = CGRectMake(x, y + 22, metricW, 14);

    x += metricW;
    _calorieValueLabel.frame = CGRectMake(x, y, metricW, 20);
    _calorieTitleLabel.frame = CGRectMake(x, y + 22, metricW, 14);

    // 次要指标（心率左对齐，配速居中全宽）
    y = y + 36 + TSSpacing_SM;
    x = kColorBarWidth + kCellPadding;
    CGFloat secondaryTotalW = cardW - kColorBarWidth - kCellPadding * 2;
    CGFloat secondaryW = secondaryTotalW / 2.f;
    _heartRateLabel.frame = CGRectMake(x, y, secondaryW, 16);
    _paceLabel.frame = CGRectMake(x, y, secondaryTotalW, 16);
}

#pragma mark - Helpers

- (NSString *)formatDuration:(double)seconds {
    int hours = (int)(seconds / 3600);
    int minutes = (int)((seconds - hours * 3600) / 60);
    int secs = (int)seconds % 60;

    if (hours > 0) {
        return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, secs];
    } else {
        return [NSString stringWithFormat:@"%d:%02d", minutes, secs];
    }
}

- (NSString *)sportTypeName:(TSSportTypeEnum)type {
    switch (type) {
        case TSSportTypeOutdoorRunning: return @"户外跑步";
        case TSSportTypeIndoorRunning: return @"室内跑步";
        case TSSportTypeOutdoorWalking: return @"户外健走";
        case TSSportTypeOutdoorCycling: return @"户外骑行";
        case TSSportTypeIndoorCycling: return @"室内骑行";
        case TSSportTypeSwimming: return @"游泳";
        case TSSportTypePoolSwimming: return @"泳池游泳";
        case TSSportTypeBasketball: return @"篮球";
        case TSSportTypeFootball: return @"足球";
        case TSSportTypeBadminton: return @"羽毛球";
        case TSSportTypeYoga: return @"瑜伽";
        case TSSportTypeRopeSkipping: return @"跳绳";
        case TSSportTypeClimbing: return @"登山";
        case TSSportTypeHiking: return @"徒步";
        default: return @"运动";
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

- (UIColor *)sportTypeColor:(TSSportTypeEnum)type {
    if (type == TSSportTypeOutdoorRunning || type == TSSportTypeIndoorRunning) {
        return TSColor_Warning; // 橙色
    } else if (type == TSSportTypeOutdoorCycling || type == TSSportTypeIndoorCycling) {
        return TSColor_Primary; // 蓝色
    } else if (type == TSSportTypeSwimming || type == TSSportTypePoolSwimming) {
        return TSColor_Teal; // 青色
    } else if (type == TSSportTypeBasketball || type == TSSportTypeFootball || type == TSSportTypeBadminton) {
        return TSColor_Success; // 绿色
    } else if (type == TSSportTypeYoga) {
        return TSColor_Purple; // 紫色
    }
    return TSColor_Gray;
}

@end
