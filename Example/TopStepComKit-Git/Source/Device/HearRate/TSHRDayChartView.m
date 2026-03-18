//
//  TSHRDayChartView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHRDayChartView.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSBaseVC.h"

// 图表内边距
static const CGFloat kPaddingLeft   = 36.f; // 左侧留给Y轴标签
static const CGFloat kPaddingRight  = 8.f;
static const CGFloat kPaddingTop    = 12.f;
static const CGFloat kPaddingBottom = 24.f; // 底部留给X轴标签

@implementation TSHRDayChartView {
    NSArray<TSHRValueItem *> *_items;
    NSDate *_date;
    UIView *_chartArea;       // 实际绘图区域
    CAShapeLayer *_lineLayer; // 折线图层
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    _chartType = TSHRChartTypeBar;

    _chartArea = [[UIView alloc] init];
    _chartArea.clipsToBounds = YES;
    [self addSubview:_chartArea];

    return self;
}

- (void)configureWithItems:(NSArray<TSHRValueItem *> *)items date:(NSDate *)date {
    _items = items;
    _date  = date;
    [self setNeedsLayout];
}

- (void)setChartType:(TSHRChartType)chartType {
    _chartType = chartType;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);

    _chartArea.frame = CGRectMake(kPaddingLeft, kPaddingTop,
                                  w - kPaddingLeft - kPaddingRight,
                                  h - kPaddingTop - kPaddingBottom);
    [self redraw];
}

#pragma mark - 绘制入口

- (void)redraw {
    // 清空旧内容
    for (UIView *v in self.subviews) {
        if (v != _chartArea) [v removeFromSuperview];
    }
    for (UIView *v in _chartArea.subviews) {
        [v removeFromSuperview];
    }
    _chartArea.layer.sublayers = nil;

    if (_items.count == 0) {
        [self drawEmptyState];
        return;
    }

    // Y 轴固定生理范围，避免数据波动导致视觉跳动
    UInt8 yMax = 200;
    UInt8 yMin = 40;

    [self drawYAxisWithMax:yMax min:yMin];
    [self drawXAxis];

    if (_chartType == TSHRChartTypeBar) {
        [self drawBarChartWithMax:yMax min:yMin];
    } else {
        [self drawLineChartWithMax:yMax min:yMin];
    }
}

#pragma mark - 空状态

- (void)drawEmptyState {
    UILabel *label = [[UILabel alloc] init];
    label.text = TSLocalizedString(@"chart.empty.heart_rate");
    label.font = TSFont_Body;
    label.textColor = TSColor_TextSecondary;
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = self.bounds;
    [self addSubview:label];
}

#pragma mark - 坐标轴

- (void)drawYAxisWithMax:(UInt8)yMax min:(UInt8)yMin {
    CGFloat h = CGRectGetHeight(_chartArea.bounds);

    // 绘制3条水平参考线：顶、中、底
    NSArray<NSNumber *> *values = @[@(yMax), @((yMax + yMin) / 2), @(yMin)];
    for (NSNumber *val in values) {
        CGFloat ratio = (val.intValue - yMin) / (float)(yMax - yMin);
        CGFloat y = h - ratio * h;

        // 参考线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(_chartArea.bounds), 0.5)];
        line.backgroundColor = TSColor_Separator;
        [_chartArea addSubview:line];

        // Y轴标签
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%d", val.intValue];
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = TSColor_TextSecondary;
        label.textAlignment = NSTextAlignmentRight;
        label.frame = CGRectMake(0, kPaddingTop + y - 7, kPaddingLeft - 4, 14);
        [self addSubview:label];
    }
}

- (void)drawXAxis {
    CGFloat w = CGRectGetWidth(_chartArea.bounds);
    CGFloat chartBottom = kPaddingTop + CGRectGetHeight(_chartArea.bounds);

    // 显示 0、6、12、18、24 五个时间刻度
    NSArray<NSNumber *> *hours = @[@0, @6, @12, @18, @24];
    for (NSNumber *hour in hours) {
        CGFloat ratio = hour.floatValue / 24.0;
        CGFloat x = kPaddingLeft + ratio * w;

        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%02d:00", hour.intValue == 24 ? 0 : hour.intValue];
        if (hour.intValue == 24) label.text = @"24:00";
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = TSColor_TextSecondary;
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectMake(x - 20, chartBottom + 4, 40, 14);
        [self addSubview:label];
    }
}

#pragma mark - 柱状图（按小时聚合）

- (void)drawBarChartWithMax:(UInt8)yMax min:(UInt8)yMin {
    CGFloat w = CGRectGetWidth(_chartArea.bounds);
    CGFloat h = CGRectGetHeight(_chartArea.bounds);

    // 按小时聚合：计算每小时的平均心率
    NSMutableDictionary<NSNumber *, NSMutableArray<NSNumber *> *> *hourMap = [NSMutableDictionary dictionary];
    NSCalendar *calendar = [NSCalendar currentCalendar];

    for (TSHRValueItem *item in _items) {
        if (item.hrValue == 0) continue;
        NSDate *itemDate = [NSDate dateWithTimeIntervalSince1970:item.startTime];
        NSInteger hour = [calendar component:NSCalendarUnitHour fromDate:itemDate];
        if (!hourMap[@(hour)]) hourMap[@(hour)] = [NSMutableArray array];
        [hourMap[@(hour)] addObject:@(item.hrValue)];
    }

    CGFloat totalSpacing = 23 * 3;
    CGFloat barWidth = (w - totalSpacing) / 24.0;
    if (barWidth < 1) barWidth = 1;

    for (NSInteger hour = 0; hour < 24; hour++) {
        CGFloat x = hour * (barWidth + 3);
        NSArray<NSNumber *> *values = hourMap[@(hour)];

        if (values.count == 0) {
            // 无数据：绘制占位细线
            UIView *placeholder = [[UIView alloc] initWithFrame:CGRectMake(x, h - 3, barWidth, 3)];
            placeholder.backgroundColor = TSColor_Separator;
            placeholder.layer.cornerRadius = 1.5;
            [_chartArea addSubview:placeholder];
            continue;
        }

        // 计算均值
        CGFloat sum = 0;
        for (NSNumber *v in values) sum += v.floatValue;
        CGFloat avg = sum / values.count;

        CGFloat ratio = (avg - yMin) / (float)(yMax - yMin);
        ratio = MAX(0, MIN(1, ratio));
        CGFloat barH = MAX(4, ratio * h);
        CGFloat y = h - barH;

        // 渐变柱子
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(x, y, barWidth, barH)];
        bar.layer.cornerRadius = MIN(barWidth / 2.0, 4);
        bar.layer.masksToBounds = YES;

        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, barWidth, barH);
        gradient.cornerRadius = bar.layer.cornerRadius;

        UIColor *topColor = [self colorForHeartRate:(UInt8)avg];
        UIColor *bottomColor = [topColor colorWithAlphaComponent:0.4];
        gradient.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
        gradient.startPoint = CGPointMake(0.5, 0);
        gradient.endPoint = CGPointMake(0.5, 1);

        [bar.layer addSublayer:gradient];
        [_chartArea addSubview:bar];
    }
}

#pragma mark - 折线图（按精确时间位置）

- (void)drawLineChartWithMax:(UInt8)yMax min:(UInt8)yMin {
    CGFloat w = CGRectGetWidth(_chartArea.bounds);
    CGFloat h = CGRectGetHeight(_chartArea.bounds);

    // 计算当天0点时间戳
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startOfDay = [calendar startOfDayForDate:_date];
    NSTimeInterval dayStart = [startOfDay timeIntervalSince1970];
    NSTimeInterval dayDuration = 24 * 3600.0;

    // 过滤有效数据点并按时间排序
    NSArray<TSHRValueItem *> *validItems = [_items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TSHRValueItem *item, NSDictionary *bindings) {
        return item.hrValue > 0;
    }]];
    validItems = [validItems sortedArrayUsingComparator:^NSComparisonResult(TSHRValueItem *a, TSHRValueItem *b) {
        return a.startTime < b.startTime ? NSOrderedAscending : NSOrderedDescending;
    }];

    if (validItems.count == 0) return;

    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = kCGLineJoinRound;
    BOOL firstPoint = YES;

    for (TSHRValueItem *item in validItems) {
        CGFloat xRatio = (item.startTime - dayStart) / dayDuration;
        xRatio = MAX(0, MIN(1, xRatio));
        CGFloat yRatio = (item.hrValue - yMin) / (float)(yMax - yMin);
        yRatio = MAX(0, MIN(1, yRatio));

        CGFloat x = xRatio * w;
        CGFloat y = h - yRatio * h;

        if (firstPoint) {
            [path moveToPoint:CGPointMake(x, y)];
            firstPoint = NO;
        } else {
            [path addLineToPoint:CGPointMake(x, y)];
        }
    }

    if (!firstPoint) {
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.path = path.CGPath;
        lineLayer.strokeColor = TSColor_Primary.CGColor;
        lineLayer.fillColor = UIColor.clearColor.CGColor;
        lineLayer.lineWidth = 1.5;
        lineLayer.lineJoin = kCALineJoinRound;
        [_chartArea.layer insertSublayer:lineLayer atIndex:0];
    }
}

#pragma mark - 心率颜色

- (UIColor *)colorForHeartRate:(UInt8)hrValue {
    if (hrValue >= 170) return TSColor_Danger;
    if (hrValue >= 150) return TSColor_Warning;
    if (hrValue >= 130) return TSColor_Success;
    if (hrValue >= 110) return TSColor_Primary;
    return TSColor_Teal;
}

@end
