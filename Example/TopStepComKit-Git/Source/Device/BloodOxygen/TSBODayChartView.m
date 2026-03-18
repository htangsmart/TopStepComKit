//
//  TSBODayChartView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSBODayChartView.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSBaseVC.h"

// 内边距
static const CGFloat kPaddingLeft = 36.f;
static const CGFloat kPaddingRight = 8.f;
static const CGFloat kPaddingTop = 12.f;
static const CGFloat kPaddingBottom = 24.f;

// Y 轴范围（血氧正常范围）
static const CGFloat kMaxValue = 100.f;
static const CGFloat kMinValue = 80.f;

@interface TSBODayChartView ()

@property (nonatomic, strong) NSArray<TSBOValueItem *> *items;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation TSBODayChartView

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

    _chartType = TSBOChartTypeBar;

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
- (void)configureWithItems:(NSArray<TSBOValueItem *> *)items date:(NSDate *)date {
    self.items = items;
    self.date = date;

    self.emptyLabel.hidden = (items.count > 0);

    [self setNeedsDisplay];
}

/**
 * 设置图表类型
 */
- (void)setChartType:(TSBOChartType)chartType {
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
        if (self.chartType == TSBOChartTypeBar) {
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

    // Y 轴参考线（3条：100%、90%、80%）
    NSArray *yValues = @[@100, @90, @80];
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
        NSString *text = [NSString stringWithFormat:@"%d%%", [val intValue]];
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

    for (TSBOValueItem *item in self.items) {
        if (item.oxyValue > 0) {
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
            for (TSBOValueItem *item in hourItems) {
                sum += item.oxyValue;
            }
            CGFloat avgValue = sum / (CGFloat)hourItems.count;

            // 计算柱子高度
            CGFloat ratio = (avgValue - kMinValue) / (kMaxValue - kMinValue);
            ratio = MAX(0, MIN(1, ratio));
            CGFloat barHeight = chartH * ratio;
            CGFloat y = kPaddingTop + chartH - barHeight;

            // 获取颜色
            UIColor *color = [self colorForBloodOxygen:avgValue];

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
    for (TSBOValueItem *item in self.items) {
        if (item.oxyValue > 0) {
            [validItems addObject:item];
        }
    }

    if (validItems.count == 0) return;

    [validItems sortUsingComparator:^NSComparisonResult(TSBOValueItem *obj1, TSBOValueItem *obj2) {
        return [@(obj1.startTime) compare:@(obj2.startTime)];
    }];

    // 计算时间范围
    NSTimeInterval dayStart = [self startOfDay:self.date];
    NSTimeInterval dayDuration = 24 * 3600;

    // 创建路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    BOOL isFirst = YES;

    for (TSBOValueItem *item in validItems) {
        CGFloat xRatio = (item.startTime - dayStart) / dayDuration;
        xRatio = MAX(0, MIN(1, xRatio));

        CGFloat yRatio = (item.oxyValue - kMinValue) / (kMaxValue - kMinValue);
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
    CGContextSetStrokeColorWithColor(ctx, [TSColor_Danger CGColor]);
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextAddPath(ctx, path.CGPath);
    CGContextStrokePath(ctx);

    // 绘制数据点
    for (TSBOValueItem *item in validItems) {
        CGFloat xRatio = (item.startTime - dayStart) / dayDuration;
        xRatio = MAX(0, MIN(1, xRatio));

        CGFloat yRatio = (item.oxyValue - kMinValue) / (kMaxValue - kMinValue);
        yRatio = MAX(0, MIN(1, yRatio));

        CGFloat x = kPaddingLeft + chartW * xRatio;
        CGFloat y = kPaddingTop + chartH * (1 - yRatio);

        CGContextSetFillColorWithColor(ctx, [TSColor_Danger CGColor]);
        CGContextFillEllipseInRect(ctx, CGRectMake(x - 3, y - 3, 6, 6));
    }
}

/**
 * 绘制渐变柱子
 */
- (void)drawGradientBarInContext:(CGContextRef)ctx rect:(CGRect)rect color:(UIColor *)color {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];

    CGFloat colors[] = {
        r, g, b, a,
        r, g, b, a * 0.4
    };

    CGFloat locations[] = {0.0, 1.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);

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
 * 根据血氧值获取颜色
 */
- (UIColor *)colorForBloodOxygen:(CGFloat)value {
    if (value >= 95) {
        return TSColor_Success;  // 绿色 - 正常
    } else if (value >= 90) {
        return TSColor_Warning;  // 橙色 - 偏低
    } else {
        return TSColor_Danger;   // 红色 - 异常
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
        _emptyLabel.text = @"暂无血氧数据";
        _emptyLabel.font = [UIFont systemFontOfSize:14];
        _emptyLabel.textColor = TSColor_TextSecondary;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}

@end
