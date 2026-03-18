//
//  TSStressDayChartView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSStressDayChartView.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSBaseVC.h"

// 内边距
static const CGFloat kPaddingLeft = 36.f;
static const CGFloat kPaddingRight = 8.f;
static const CGFloat kPaddingTop = 12.f;
static const CGFloat kPaddingBottom = 24.f;

// Y 轴范围（压力值范围）
static const CGFloat kMaxValue = 100.f;
static const CGFloat kMinValue = 0.f;

@interface TSStressDayChartView ()

@property (nonatomic, strong) NSArray<TSStressValueItem *> *items;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation TSStressDayChartView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

/**
 * 初始化视图
 */
- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = YES;

    _chartType = TSStressChartTypeBar;

    [self addSubview:self.emptyLabel];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    self.emptyLabel.frame = self.bounds;
}

#pragma mark - 公开方法

/**
 * 配置图表数据
 */
- (void)configureWithItems:(NSArray<TSStressValueItem *> *)items date:(NSDate *)date {
    self.items = items;
    self.date = date;

    self.emptyLabel.hidden = (items.count > 0);

    [self setNeedsDisplay];
}

/**
 * 设置图表类型
 */
- (void)setChartType:(TSStressChartType)chartType {
    if (_chartType != chartType) {
        _chartType = chartType;
        [self setNeedsDisplay];
    }
}

#pragma mark - 绘制

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) return;

    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);

    // 绘制坐标系
    [self drawAxisInContext:ctx width:w height:h];

    // 绘制数据
    if (self.items.count > 0) {
        if (self.chartType == TSStressChartTypeBar) {
            [self drawBarChartInContext:ctx width:w height:h];
        } else {
            [self drawLineChartInContext:ctx width:w height:h];
        }
    }
}

/**
 * 绘制坐标系
 */
- (void)drawAxisInContext:(CGContextRef)ctx width:(CGFloat)w height:(CGFloat)h {
    CGFloat chartW = w - kPaddingLeft - kPaddingRight;
    CGFloat chartH = h - kPaddingTop - kPaddingBottom;

    // Y 轴参考线（5条：0、25、50、75、100）
    NSArray *yValues = @[@100, @75, @50, @25, @0];
    for (NSNumber *val in yValues) {
        CGFloat ratio = ([val floatValue] - kMinValue) / (kMaxValue - kMinValue);
        CGFloat y = kPaddingTop + chartH * (1 - ratio);

        // 绘制虚线
        CGContextSetStrokeColorWithColor(ctx, [TSColor_Separator CGColor]);
        CGContextSetLineWidth(ctx, 0.5);
        CGFloat dash[] = {2, 2};
        CGContextSetLineDash(ctx, 0, dash, 2);
        CGContextMoveToPoint(ctx, kPaddingLeft, y);
        CGContextAddLineToPoint(ctx, kPaddingLeft + chartW, y);
        CGContextStrokePath(ctx);
        CGContextSetLineDash(ctx, 0, NULL, 0);

        // 绘制 Y 轴标签
        NSString *text = [NSString stringWithFormat:@"%d", [val intValue]];
        NSDictionary *attrs = @{
            NSFontAttributeName: [UIFont systemFontOfSize:10],
            NSForegroundColorAttributeName: TSColor_TextSecondary
        };
        CGSize textSize = [text sizeWithAttributes:attrs];
        [text drawAtPoint:CGPointMake(kPaddingLeft - textSize.width - 4, y - textSize.height / 2) withAttributes:attrs];
    }

    // X 轴时间标签（5个：0:00、6:00、12:00、18:00、24:00）
    NSArray *hours = @[@0, @6, @12, @18, @24];
    for (NSNumber *hour in hours) {
        CGFloat ratio = [hour floatValue] / 24.0;
        CGFloat x = kPaddingLeft + chartW * ratio;

        NSString *text = [NSString stringWithFormat:@"%d:00", [hour intValue]];
        NSDictionary *attrs = @{
            NSFontAttributeName: [UIFont systemFontOfSize:10],
            NSForegroundColorAttributeName: TSColor_TextSecondary
        };
        CGSize textSize = [text sizeWithAttributes:attrs];
        [text drawAtPoint:CGPointMake(x - textSize.width / 2, h - kPaddingBottom + 4) withAttributes:attrs];
    }
}

/**
 * 绘制柱状图
 */
- (void)drawBarChartInContext:(CGContextRef)ctx width:(CGFloat)w height:(CGFloat)h {
    CGFloat chartW = w - kPaddingLeft - kPaddingRight;
    CGFloat chartH = h - kPaddingTop - kPaddingBottom;

    // 按小时聚合数据
    NSMutableDictionary *hourMap = [NSMutableDictionary dictionary];
    NSTimeInterval dayStart = [self startOfDay:self.date];

    for (TSStressValueItem *item in self.items) {
        if (item.stressValue > 0) {
            NSInteger hour = (NSInteger)((item.startTime - dayStart) / 3600) % 24;
            if (hour >= 0 && hour < 24) {
                NSString *key = @(hour).stringValue;
                NSMutableArray *arr = hourMap[key];
                if (!arr) {
                    arr = [NSMutableArray array];
                    hourMap[key] = arr;
                }
                [arr addObject:item];
            }
        }
    }

    // 绘制 24 个柱子
    CGFloat barSpacing = 3;
    CGFloat barWidth = (chartW - 23 * barSpacing) / 24.0;

    for (NSInteger hour = 0; hour < 24; hour++) {
        CGFloat x = kPaddingLeft + hour * (barWidth + barSpacing);

        NSString *key = @(hour).stringValue;
        NSArray *hourItems = hourMap[key];

        if (hourItems.count > 0) {
            // 计算平均值
            NSInteger sum = 0;
            for (TSStressValueItem *item in hourItems) {
                sum += item.stressValue;
            }
            CGFloat avgValue = sum / (CGFloat)hourItems.count;

            // 计算柱子高度
            CGFloat ratio = (avgValue - kMinValue) / (kMaxValue - kMinValue);
            ratio = MAX(0, MIN(1, ratio));
            CGFloat barHeight = chartH * ratio;
            CGFloat y = kPaddingTop + chartH - barHeight;

            // 获取颜色
            UIColor *color = [self colorForStress:avgValue];

            // 绘制渐变柱子
            CGRect barRect = CGRectMake(x, y, barWidth, barHeight);
            [self drawGradientBarInContext:ctx rect:barRect color:color];
        } else {
            // 无数据时绘制占位细线
            CGFloat y = kPaddingTop + chartH - 2;
            CGContextSetFillColorWithColor(ctx, [TSColor_Separator CGColor]);
            CGContextFillRect(ctx, CGRectMake(x, y, barWidth, 2));
        }
    }
}

/**
 * 绘制折线图
 */
- (void)drawLineChartInContext:(CGContextRef)ctx width:(CGFloat)w height:(CGFloat)h {
    CGFloat chartW = w - kPaddingLeft - kPaddingRight;
    CGFloat chartH = h - kPaddingTop - kPaddingBottom;

    // 过滤有效数据点并排序
    NSMutableArray *validItems = [NSMutableArray array];
    for (TSStressValueItem *item in self.items) {
        if (item.stressValue > 0) {
            [validItems addObject:item];
        }
    }

    if (validItems.count == 0) return;

    [validItems sortUsingComparator:^NSComparisonResult(TSStressValueItem *obj1, TSStressValueItem *obj2) {
        return [@(obj1.startTime) compare:@(obj2.startTime)];
    }];

    // 计算时间范围
    NSTimeInterval dayStart = [self startOfDay:self.date];
    NSTimeInterval dayDuration = 24 * 3600;

    // 创建路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    BOOL isFirst = YES;

    for (TSStressValueItem *item in validItems) {
        CGFloat xRatio = (item.startTime - dayStart) / dayDuration;
        xRatio = MAX(0, MIN(1, xRatio));

        CGFloat yRatio = (item.stressValue - kMinValue) / (kMaxValue - kMinValue);
        yRatio = MAX(0, MIN(1, yRatio));

        CGFloat x = kPaddingLeft + chartW * xRatio;
        CGFloat y = kPaddingTop + chartH * (1 - yRatio);

        if (isFirst) {
            [path moveToPoint:CGPointMake(x, y)];
            isFirst = NO;
        } else {
            [path addLineToPoint:CGPointMake(x, y)];
        }
    }

    // 绘制折线
    CGContextSetStrokeColorWithColor(ctx, [TSColor_Primary CGColor]);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextAddPath(ctx, path.CGPath);
    CGContextStrokePath(ctx);

    // 绘制数据点
    for (TSStressValueItem *item in validItems) {
        CGFloat xRatio = (item.startTime - dayStart) / dayDuration;
        xRatio = MAX(0, MIN(1, xRatio));

        CGFloat yRatio = (item.stressValue - kMinValue) / (kMaxValue - kMinValue);
        yRatio = MAX(0, MIN(1, yRatio));

        CGFloat x = kPaddingLeft + chartW * xRatio;
        CGFloat y = kPaddingTop + chartH * (1 - yRatio);

        // 绘制圆点
        CGContextSetFillColorWithColor(ctx, [TSColor_Primary CGColor]);
        CGContextFillEllipseInRect(ctx, CGRectMake(x - 3, y - 3, 6, 6));
    }
}

/**
 * 绘制渐变柱子
 */
- (void)drawGradientBarInContext:(CGContextRef)ctx rect:(CGRect)rect color:(UIColor *)color {
    if (CGRectGetHeight(rect) < 1) return;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    // 顶部颜色
    CGFloat r1, g1, b1, a1;
    [color getRed:&r1 green:&g1 blue:&b1 alpha:&a1];

    // 底部颜色（40% 透明度）
    CGFloat components[] = {
        r1, g1, b1, a1,
        r1, g1, b1, a1 * 0.4
    };

    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);

    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, rect);
    CGContextClip(ctx);

    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));

    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);

    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

#pragma mark - 辅助方法

/**
 * 根据压力值获取颜色
 */
- (UIColor *)colorForStress:(CGFloat)value {
    if (value >= 76) {
        return TSColor_Danger;   // 红色 - 高压
    } else if (value >= 51) {
        return TSColor_Warning;  // 橙色 - 偏高
    } else if (value >= 26) {
        return TSColor_Success;  // 绿色 - 正常
    } else {
        return TSColor_Primary;  // 蓝色 - 放松
    }
}

/**
 * 获取日期的开始时间戳
 */
- (NSTimeInterval)startOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDate *startOfDay = [calendar dateFromComponents:components];
    return [startOfDay timeIntervalSince1970];
}

#pragma mark - 懒加载

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = @"暂无压力数据";
        _emptyLabel.font = [UIFont systemFontOfSize:14];
        _emptyLabel.textColor = TSColor_TextSecondary;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}

@end
