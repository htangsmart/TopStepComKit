//
//  TSSportItemView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/17.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSSportItemView.h"
#import "TSBaseVC.h"
#import <TopStepComKit/TopStepComKit.h>

@interface TSSportItemView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *metricLabel;

@end

@implementation TSSportItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = TSColor_Background;
        self.layer.cornerRadius = 10.f;
        [self addSubview:self.iconImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.durationLabel];
        [self addSubview:self.metricLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);

    // 图标：左侧垂直居中
    CGFloat iconSize = 30.f;
    self.iconImageView.frame = CGRectMake(12.f, (h - iconSize) / 2.f, iconSize, iconSize);

    // 开始时间：右上角
    CGFloat timeW = 44.f;
    self.timeLabel.frame = CGRectMake(w - timeW - 12.f, 12.f, timeW, 16.f);

    // 运动名称：图标右侧，顶部对齐
    CGFloat nameX = CGRectGetMaxX(self.iconImageView.frame) + 10.f;
    CGFloat nameW = w - nameX - timeW - 20.f;
    self.nameLabel.frame = CGRectMake(nameX, 12.f, nameW, 18.f);

    // 指标行：名称下方，durationLabel 占满剩余宽度，metricLabel 不使用
    CGFloat metricY = h - 14.f - 15.f;
    self.durationLabel.frame = CGRectMake(nameX, metricY, w - nameX - 14.f, 15.f);
    self.metricLabel.frame = CGRectZero;
}

- (void)updateWithSummary:(TSSportSummaryModel *)summary {
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightMedium];
        self.iconImageView.image = [UIImage systemImageNamed:[self ts_iconForType:summary.type] withConfiguration:cfg];
    }
    self.iconImageView.tintColor = [self ts_colorForType:summary.type];
    self.nameLabel.text = [self ts_nameForType:summary.type];

    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"HH:mm";
    self.timeLabel.text = [fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:summary.startTime]];

    NSInteger dur = (NSInteger)summary.duration;
    NSInteger h = dur / 3600, m = (dur % 3600) / 60;
    NSString *durationStr = h > 0
        ? [NSString stringWithFormat:TSLocalizedString(@"sport.duration.hm"), (long)h, (long)m]
        : [NSString stringWithFormat:TSLocalizedString(@"sport.duration.m"), (long)m];

    NSMutableString *metrics = [NSMutableString stringWithString:durationStr];
    if (summary.calorie > 0) {
        [metrics appendFormat:@"  %.2f kcal", summary.calorie / 1000.0f];
    }
    if (summary.distance >= 10) {
        [metrics appendFormat:@" · %.2f km", summary.distance / 1000.0f];
    }
    self.durationLabel.text = metrics;
    self.metricLabel.text = @"";
}

- (NSString *)ts_iconForType:(TSSportTypeEnum)type {
    switch (type) {
        case TSSportTypeOutdoorRunning:
        case TSSportTypeIndoorRunning:
        case TSSportTypeTreadmillRunning:  return @"figure.run";
        case TSSportTypeOutdoorWalking:
        case TSSportTypeIndoorWalking:     return @"figure.walk";
        case TSSportTypeOutdoorCycling:
        case TSSportTypeIndoorCycling:
        case TSSportTypeFitnessBike:       return @"bicycle";
        case TSSportTypeClimbing:
        case TSSportTypeHiking:            return @"figure.climbing";
        case TSSportTypeYoga:              return @"figure.yoga";
        case TSSportTypeBasketball:        return @"figure.basketball";
        case TSSportTypeFootball:
        case TSSportTypeOutdoorSoccer:     return @"figure.soccer";
        case TSSportTypeSwimming:
        case TSSportTypePoolSwimming:
        case TSSportTypeOpenWaterSwimming: return @"figure.pool.swim";
        case TSSportTypeRopeSkipping:      return @"figure.jumprope";
        default:                           return @"figure.run";
    }
}

- (NSString *)ts_nameForType:(TSSportTypeEnum)type {
    switch (type) {
        case TSSportTypeOutdoorRunning:    return TSLocalizedString(@"sport.type.outdoor_running");
        case TSSportTypeIndoorRunning:     return TSLocalizedString(@"sport.type.indoor_running");
        case TSSportTypeTreadmillRunning:  return TSLocalizedString(@"sport.type.treadmill");
        case TSSportTypeOutdoorWalking:    return TSLocalizedString(@"sport.type.outdoor_walking");
        case TSSportTypeIndoorWalking:     return TSLocalizedString(@"sport.type.indoor_walking");
        case TSSportTypeOutdoorCycling:    return TSLocalizedString(@"sport.type.outdoor_cycling");
        case TSSportTypeIndoorCycling:     return TSLocalizedString(@"sport.type.indoor_cycling");
        case TSSportTypeFitnessBike:       return TSLocalizedString(@"sport.type.fitness_bike");
        case TSSportTypeClimbing:          return TSLocalizedString(@"sport.type.climbing");
        case TSSportTypeHiking:            return TSLocalizedString(@"sport.type.hiking");
        case TSSportTypeBasketball:        return TSLocalizedString(@"sport.type.basketball");
        case TSSportTypeSwimming:
        case TSSportTypePoolSwimming:      return TSLocalizedString(@"sport.type.swimming");
        case TSSportTypeOpenWaterSwimming: return TSLocalizedString(@"sport.type.open_water_swim");
        case TSSportTypeYoga:              return TSLocalizedString(@"sport.type.yoga");
        case TSSportTypeFootball:
        case TSSportTypeOutdoorSoccer:     return TSLocalizedString(@"sport.type.football");
        case TSSportTypeRopeSkipping:      return TSLocalizedString(@"sport.type.rope_skipping");
        case TSSportTypeBadminton:         return TSLocalizedString(@"sport.type.badminton");
        case TSSportTypeElliptical:        return TSLocalizedString(@"sport.type.elliptical");
        case TSSportTypeRowing:            return TSLocalizedString(@"sport.type.rowing");
        case TSSportTypeFreeTraining:      return TSLocalizedString(@"sport.type.free_training");
        case TSSportTypeStrengthTraining:  return TSLocalizedString(@"sport.type.strength_training");
        case TSSportTypeHIIT:              return @"HIIT";
        default:                           return TSLocalizedString(@"sport.type.default");
    }
}

- (UIColor *)ts_colorForType:(TSSportTypeEnum)type {
    switch (type) {
        case TSSportTypeOutdoorRunning:
        case TSSportTypeIndoorRunning:
        case TSSportTypeTreadmillRunning:  return TSColor_Warning;
        case TSSportTypeOutdoorWalking:
        case TSSportTypeIndoorWalking:     return TSColor_Success;
        case TSSportTypeOutdoorCycling:
        case TSSportTypeIndoorCycling:
        case TSSportTypeFitnessBike:       return TSColor_Primary;
        case TSSportTypeSwimming:
        case TSSportTypePoolSwimming:
        case TSSportTypeOpenWaterSwimming: return TSColor_Teal;
        case TSSportTypeYoga:              return TSColor_Purple;
        default:                           return TSColor_Gray;
    }
}

#pragma mark - 懒加载

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightSemibold];
        _nameLabel.textColor = TSColor_TextPrimary;
    }
    return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12.f];
        _timeLabel.textColor = TSColor_TextSecondary;
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:12.f];
        _durationLabel.textColor = TSColor_TextSecondary;
    }
    return _durationLabel;
}

- (UILabel *)metricLabel {
    if (!_metricLabel) {
        _metricLabel = [[UILabel alloc] init];
        _metricLabel.font = [UIFont systemFontOfSize:12.f];
        _metricLabel.textColor = TSColor_TextSecondary;
    }
    return _metricLabel;
}

@end
