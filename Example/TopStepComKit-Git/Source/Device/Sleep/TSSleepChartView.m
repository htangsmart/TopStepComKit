//
//  TSSleepChartView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/16.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSSleepChartView.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSBaseVC.h"

// 内边距
static const CGFloat kPaddingLeft = 40.f;
static const CGFloat kPaddingRight = 8.f;
static const CGFloat kPaddingTop = 20.f;
static const CGFloat kPaddingBottom = 20.f;

// 睡眠阶段高度
static const CGFloat kStageHeight = 20.f;
static const CGFloat kStageSpacing = 4.f;

@interface TSSleepChartView ()

@property (nonatomic, strong) NSArray<TSSleepDetailItem *> *items;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) UILabel *emptyLabel;

@end

@implementation TSSleepChartView

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
- (void)configureWithItems:(NSArray<TSSleepDetailItem *> *)items date:(NSDate *)date {
    self.items = items;
    self.date = date;

    self.emptyLabel.hidden = (items.count > 0);

    [self setNeedsDisplay];
}

#pragma mark - 绘制

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) return;

    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);

    // 绘制时间轴
    [self drawTimeAxisInContext:ctx width:w height:h];

    // 绘制睡眠阶段
    if (self.items.count > 0) {
        [self drawSleepStagesInContext:ctx width:w height:h];
    }
}

/**
 * 绘制时间轴
 */
- (void)drawTimeAxisInContext:(CGContextRef)ctx width:(CGFloat)w height:(CGFloat)h {
    CGFloat chartW = w - kPaddingLeft - kPaddingRight;

    // 绘制时间刻度（20:00、23:00、02:00、05:00、08:00、11:00、14:00、17:00、20:00）
    NSArray *hours = @[@20, @23, @2, @5, @8, @11, @14, @17, @20];

    for (NSInteger i = 0; i < hours.count; i++) {
        NSInteger hour = [hours[i] integerValue];
        CGFloat ratio = i / 8.0;  // 8个间隔
        CGFloat x = kPaddingLeft + chartW * ratio;

        // 绘制刻度线
        CGContextSetStrokeColorWithColor(ctx, [TSColor_Separator CGColor]);
        CGContextSetLineWidth(ctx, 0.5);
        CGContextMoveToPoint(ctx, x, kPaddingTop);
        CGContextAddLineToPoint(ctx, x, h - kPaddingBottom);
        CGContextStrokePath(ctx);

        // 绘制时间标签
        NSString *text = [NSString stringWithFormat:@"%02ld:00", (long)hour];
        NSDictionary *attrs = @{
            NSFontAttributeName: [UIFont systemFontOfSize:10],
            NSForegroundColorAttributeName: TSColor_TextSecondary
        };
        CGSize textSize = [text sizeWithAttributes:attrs];
        [text drawAtPoint:CGPointMake(x - textSize.width / 2, h - kPaddingBottom + 4) withAttributes:attrs];
    }

    // 绘制阶段标签（左侧）
    NSArray *stageLabels = @[@"深睡", @"浅睡", @"REM", @"清醒"];
    CGFloat totalStageHeight = 4 * kStageHeight + 3 * kStageSpacing;
    CGFloat startY = kPaddingTop + (h - kPaddingTop - kPaddingBottom - totalStageHeight) / 2;

    for (NSInteger i = 0; i < stageLabels.count; i++) {
        CGFloat y = startY + i * (kStageHeight + kStageSpacing);
        NSString *text = stageLabels[i];
        NSDictionary *attrs = @{
            NSFontAttributeName: [UIFont systemFontOfSize:11 weight:UIFontWeightMedium],
            NSForegroundColorAttributeName: TSColor_TextSecondary
        };
        CGSize textSize = [text sizeWithAttributes:attrs];
        [text drawAtPoint:CGPointMake(kPaddingLeft - textSize.width - 8, y + (kStageHeight - textSize.height) / 2) withAttributes:attrs];
    }
}

/**
 * 绘制睡眠阶段
 */
- (void)drawSleepStagesInContext:(CGContextRef)ctx width:(CGFloat)w height:(CGFloat)h {
    CGFloat chartW = w - kPaddingLeft - kPaddingRight;
    CGFloat totalStageHeight = 4 * kStageHeight + 3 * kStageSpacing;
    CGFloat startY = kPaddingTop + (h - kPaddingTop - kPaddingBottom - totalStageHeight) / 2;

    // 计算睡眠日的时间范围（20:00 → 次日 20:00）
    NSTimeInterval sleepDayStart = [self sleepDayStartTime:self.date];
    NSTimeInterval sleepDayDuration = 24 * 3600;

    for (TSSleepDetailItem *item in self.items) {
        // 计算时间位置
        CGFloat startRatio = (item.startTime - sleepDayStart) / sleepDayDuration;
        CGFloat endRatio = (item.endTime - sleepDayStart) / sleepDayDuration;

        // 限制在 0-1 范围内
        startRatio = MAX(0, MIN(1, startRatio));
        endRatio = MAX(0, MIN(1, endRatio));

        if (endRatio <= startRatio) continue;

        CGFloat x = kPaddingLeft + chartW * startRatio;
        CGFloat blockWidth = chartW * (endRatio - startRatio);

        // 根据阶段确定 Y 位置
        CGFloat y = 0;
        switch (item.stage) {
            case TSSleepStageDeep:
                y = startY;
                break;
            case TSSleepStageLight:
                y = startY + kStageHeight + kStageSpacing;
                break;
            case TSSleepStageREM:
                y = startY + 2 * (kStageHeight + kStageSpacing);
                break;
            case TSSleepStageAwake:
                y = startY + 3 * (kStageHeight + kStageSpacing);
                break;
        }

        // 绘制色块
        UIColor *color = [self colorForStage:item.stage];
        CGContextSetFillColorWithColor(ctx, [color CGColor]);
        CGContextFillRect(ctx, CGRectMake(x, y, blockWidth, kStageHeight));
    }
}

#pragma mark - 辅助方法

/**
 * 根据睡眠阶段获取颜色
 */
- (UIColor *)colorForStage:(TSSleepStage)stage {
    switch (stage) {
        case TSSleepStageDeep:
            return [UIColor colorWithRed:0x1E/255.0 green:0x3A/255.0 blue:0x8A/255.0 alpha:1.0];  // 深蓝
        case TSSleepStageLight:
            return [UIColor colorWithRed:0x60/255.0 green:0xA5/255.0 blue:0xFA/255.0 alpha:1.0];  // 浅蓝
        case TSSleepStageREM:
            return [UIColor colorWithRed:0xA8/255.0 green:0x55/255.0 blue:0xF7/255.0 alpha:1.0];  // 紫色
        case TSSleepStageAwake:
            return [UIColor colorWithRed:0xD1/255.0 green:0xD5/255.0 blue:0xDB/255.0 alpha:1.0];  // 浅灰
        default:
            return [UIColor grayColor];
    }
}

/**
 * 获取睡眠日的开始时间（20:00）
 */
- (NSTimeInterval)sleepDayStartTime:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    components.hour = 20;
    components.minute = 0;
    components.second = 0;
    NSDate *sleepDayStart = [calendar dateFromComponents:components];
    return [sleepDayStart timeIntervalSince1970];
}

#pragma mark - 懒加载

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = @"暂无睡眠数据";
        _emptyLabel.font = [UIFont systemFontOfSize:14];
        _emptyLabel.textColor = TSColor_TextSecondary;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}

@end
