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
        ? [NSString stringWithFormat:@"%ld时%ld分", (long)h, (long)m]
        : [NSString stringWithFormat:@"%ld分钟", (long)m];

    NSMutableString *metrics = [NSMutableString stringWithString:durationStr];
    if (summary.calorie > 0) {
        [metrics appendFormat:@"  %ukcal", summary.calorie];
    }
    if (summary.distance >= 10) {
        [metrics appendFormat:@" · %.2fkm", summary.distance / 1000.0];
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
        case TSSportTypeOutdoorRunning:    return @"户外跑步";
        case TSSportTypeIndoorRunning:     return @"室内跑步";
        case TSSportTypeTreadmillRunning:  return @"跑步机";
        case TSSportTypeOutdoorWalking:    return @"户外健走";
        case TSSportTypeIndoorWalking:     return @"室内走路";
        case TSSportTypeOutdoorCycling:    return @"户外骑行";
        case TSSportTypeIndoorCycling:     return @"室内骑行";
        case TSSportTypeFitnessBike:       return @"健身车";
        case TSSportTypeClimbing:          return @"登山";
        case TSSportTypeHiking:            return @"徒步";
        case TSSportTypeBasketball:        return @"篮球";
        case TSSportTypeSwimming:
        case TSSportTypePoolSwimming:      return @"游泳";
        case TSSportTypeOpenWaterSwimming: return @"开放水域游泳";
        case TSSportTypeYoga:              return @"瑜伽";
        case TSSportTypeFootball:
        case TSSportTypeOutdoorSoccer:     return @"足球";
        case TSSportTypeRopeSkipping:      return @"跳绳";
        case TSSportTypeBadminton:         return @"羽毛球";
        case TSSportTypeElliptical:        return @"椭圆机";
        case TSSportTypeRowing:            return @"划船机";
        case TSSportTypeFreeTraining:      return @"自由训练";
        case TSSportTypeStrengthTraining:  return @"力量训练";
        case TSSportTypeHIIT:              return @"HIIT";
        default:                           return @"运动";
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
