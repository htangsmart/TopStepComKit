//
//  TSHeartRateChartView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/3/6.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

// 导入头文件 | Import header file
#import "TSHeartRateChartView.h"
// 导入SDK框架，用于访问心率数据模型 | Import SDK framework for heart rate data models
#import <TopStepComKit/TopStepComKit.h>
// 导入基础视图控制器，用于访问主题颜色和样式常量 | Import base view controller for theme colors and style constants
#import "TSBaseVC.h"

// 图表固定高度：120点 | Chart fixed height: 120 points
static const CGFloat kChartHeight = 120.f;
// 柱状图柱子之间的间距：2点 | Spacing between bars in bar chart: 2 points
static const CGFloat kBarSpacing = 2.f;
// 最多显示的数据点数量：60个（超过此数量会进行采样） | Maximum number of data points to display: 60 (sampling occurs if exceeded)
static const NSInteger kMaxDataPoints = 60;

// 类扩展，定义私有实例变量 | Class extension defining private instance variables
@implementation TSHeartRateChartView {
    // 运动摘要数据，包含最大心率等统计信息 | Sport summary data containing max heart rate and other statistics
    TSSportSummaryModel *_summary;
    // 心率数据点数组，每个元素包含时间戳和心率值 | Array of heart rate data points, each containing timestamp and heart rate value
    NSArray<TSHRValueItem *> *_heartRateItems;
    // 图表容器视图，所有图表元素都添加到此视图中 | Chart container view, all chart elements are added to this view
    UIView *_chartContainer;
}

// 初始化方法：使用指定的frame创建图表视图 | Initialization method: create chart view with specified frame
- (instancetype)initWithFrame:(CGRect)frame {
    // 调用父类初始化方法 | Call superclass initialization method
    self = [super initWithFrame:frame];
    // 如果初始化失败，返回nil | If initialization fails, return nil
    if (!self) return nil;

    // 设置默认图表类型为柱状图 | Set default chart type to bar chart
    _chartType = TSChartTypeBar;
    // 创建图表容器视图 | Create chart container view
    _chartContainer = [[UIView alloc] init];
    // 将容器视图添加到当前视图 | Add container view to current view
    [self addSubview:_chartContainer];

    // 返回初始化完成的实例 | Return initialized instance
    return self;
}

// 配置图表数据：设置运动摘要和心率数据点 | Configure chart data: set sport summary and heart rate data points
- (void)configureWithSummary:(TSSportSummaryModel *)summary heartRateItems:(NSArray<TSHRValueItem *> *)heartRateItems {
    // 保存运动摘要数据（包含最大心率等统计信息） | Save sport summary data (contains max heart rate and other statistics)
    _summary = summary;
    // 保存心率数据点数组 | Save heart rate data points array
    _heartRateItems = heartRateItems;
    // 标记视图需要重新布局，触发layoutSubviews方法 | Mark view as needing layout, triggering layoutSubviews method
    [self setNeedsLayout];
}

// 切换图表类型：在柱状图和折线图之间切换 | Switch chart type: toggle between bar chart and line chart
- (void)switchChartType {
    // 三元运算符切换图表类型：如果当前是柱状图则切换为折线图，否则切换为柱状图 | Ternary operator to toggle chart type: if currently bar chart, switch to line chart, otherwise switch to bar chart
    _chartType = (_chartType == TSChartTypeBar) ? TSChartTypeLine : TSChartTypeBar;
    // 标记视图需要重新布局，触发重绘 | Mark view as needing layout, triggering redraw
    [self setNeedsLayout];
}

// 布局子视图：系统在需要更新布局时自动调用此方法 | Layout subviews: system automatically calls this method when layout update is needed
- (void)layoutSubviews {
    // 调用父类的布局方法 | Call superclass layout method
    [super layoutSubviews];

    // 设置图表容器的frame：从(0,0)开始，宽度为当前视图宽度，高度为固定的120点 | Set chart container frame: starting at (0,0), width is current view width, height is fixed 120 points
    _chartContainer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), kChartHeight);

    // 清除旧的绘制内容，准备重新绘制 | Clear old drawing content, prepare for redrawing
    // 遍历容器中的所有子视图 | Iterate through all subviews in container
    for (UIView *subview in _chartContainer.subviews) {
        // 从父视图中移除每个子视图 | Remove each subview from parent view
        [subview removeFromSuperview];
    }
    // 清除所有图层（用于清除折线图的CAShapeLayer） | Clear all layers (used to clear line chart's CAShapeLayer)
    _chartContainer.layer.sublayers = nil;

    // 数据验证：如果心率数据为空或数量为0，直接返回不绘制 | Data validation: if heart rate data is nil or count is 0, return without drawing
    if (!_heartRateItems || _heartRateItems.count == 0) return;

    // 根据当前图表类型选择绘制方法 | Choose drawing method based on current chart type
    if (_chartType == TSChartTypeBar) {
        // 绘制柱状图 | Draw bar chart
        [self drawBarChart];
    } else {
        // 绘制折线图 | Draw line chart
        [self drawLineChart];
    }
}

// 绘制柱状图：将心率数据以垂直柱子的形式可视化 | Draw bar chart: visualize heart rate data as vertical bars
- (void)drawBarChart {
    // 采样数据（如果数据点太多）：调用采样方法将数据点数量限制在60个以内 | Sample data (if too many data points): call sampling method to limit data points to 60 or less
    NSArray<TSHRValueItem *> *sampledData = [self sampleHeartRateData:_heartRateItems maxPoints:kMaxDataPoints];

    // 如果采样后数据为空，直接返回 | If sampled data is empty, return directly
    if (sampledData.count == 0) return;

    // 找到最大和最小心率值用于归一化：初始化最大值为0，最小值为255（UInt8的最大值） | Find max and min heart rate values for normalization: initialize max to 0, min to 255 (max value of UInt8)
    UInt8 maxHR = 0;
    UInt8 minHR = 255;
    // 遍历采样后的数据 | Iterate through sampled data
    for (TSHRValueItem *item in sampledData) {
        // 只考虑有效的心率值（大于0） | Only consider valid heart rate values (greater than 0)
        if (item.hrValue > 0) {
            // 如果当前心率值大于最大值，更新最大值 | If current heart rate value is greater than max, update max
            if (item.hrValue > maxHR) maxHR = item.hrValue;
            // 如果当前心率值小于最小值，更新最小值 | If current heart rate value is less than min, update min
            if (item.hrValue < minHR) minHR = item.hrValue;
        }
    }

    // 如果所有心率值都是0，使用默认范围（60-100 bpm）防止除零错误 | If all heart rate values are 0, use default range (60-100 bpm) to prevent division by zero
    if (maxHR == 0 && minHR == 255) {
        // 设置默认最大值为100 bpm | Set default max value to 100 bpm
        maxHR = 100;
        // 设置默认最小值为60 bpm | Set default min value to 60 bpm
        minHR = 60;
    }

    // 确保有合理的范围：如果最大值等于最小值，将最大值增加10以避免除零 | Ensure reasonable range: if max equals min, increase max by 10 to avoid division by zero
    if (maxHR == minHR) {
        // 最大值 = 最小值 + 10 | Max value = min value + 10
        maxHR = minHR + 10;
    }

    // 获取容器视图的宽度 | Get container view width
    CGFloat w = CGRectGetWidth(_chartContainer.bounds);
    // 计算每个柱子的宽度：(总宽度 - 所有间距的总宽度) / 柱子数量 | Calculate width of each bar: (total width - total spacing width) / number of bars
    CGFloat barWidth = (w - kBarSpacing * (sampledData.count + 1)) / sampledData.count;
    // 确保柱子宽度至少为1点 | Ensure bar width is at least 1 point
    if (barWidth < 1) barWidth = 1;

    // 初始化x坐标为第一个间距 | Initialize x coordinate to first spacing
    CGFloat x = kBarSpacing;
    // 计算图表绘制区域的高度：总高度减去底部20点的空间（用于显示标签） | Calculate chart drawing area height: total height minus 20 points at bottom (for labels)
    CGFloat chartAreaHeight = kChartHeight - 20;

    // 遍历采样后的数据，为每个数据点绘制柱子 | Iterate through sampled data, draw bar for each data point
    for (TSHRValueItem *item in sampledData) {
        // 跳过无效的心率值（值为0） | Skip invalid heart rate values (value is 0)
        if (item.hrValue == 0) {
            // 移动x坐标到下一个柱子的位置 | Move x coordinate to next bar position
            x += barWidth + kBarSpacing;
            // 跳过当前循环，不绘制柱子 | Skip current iteration, don't draw bar
            continue;
        }

        // 计算柱子高度（归一化到图表区域）：将心率值映射到0-1范围 | Calculate bar height (normalized to chart area): map heart rate value to 0-1 range
        CGFloat normalizedValue = (item.hrValue - minHR) / (float)(maxHR - minHR);
        // 柱子高度 = 归一化值 × 图表区域高度 | Bar height = normalized value × chart area height
        CGFloat barHeight = normalizedValue * chartAreaHeight;
        // 确保柱子高度至少为2点（即使是最小值也要可见） | Ensure bar height is at least 2 points (even minimum value should be visible)
        if (barHeight < 2) barHeight = 2;

        // 计算柱子的y坐标：从底部向上绘制 | Calculate bar's y coordinate: draw from bottom upward
        CGFloat y = kChartHeight - barHeight - 10;

        // 创建柱子视图 | Create bar view
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(x, y, barWidth, barHeight)];
        // 根据心率值设置柱子颜色（不同心率区间使用不同颜色） | Set bar color based on heart rate value (different colors for different heart rate zones)
        bar.backgroundColor = [self colorForHeartRate:item.hrValue];
        // 如果柱子宽度足够（≥4点），设置圆角使其更美观 | If bar width is sufficient (≥4 points), set corner radius for better appearance
        if (barWidth >= 4) {
            // 设置圆角半径为2点 | Set corner radius to 2 points
            bar.layer.cornerRadius = 2.f;
        }
        // 将柱子添加到容器视图 | Add bar to container view
        [_chartContainer addSubview:bar];

        // 移动x坐标到下一个柱子的位置 | Move x coordinate to next bar position
        x += barWidth + kBarSpacing;
    }

    // 添加最大值和最小值标签到图表 | Add max and min value labels to chart
    [self addValueLabelsWithMax:maxHR min:minHR];
}

- (void)drawLineChart {
    // 采样数据
    NSArray<TSHRValueItem *> *sampledData = [self sampleHeartRateData:_heartRateItems maxPoints:kMaxDataPoints];

    if (sampledData.count == 0) return;

    // 找到最大和最小心率值
    UInt8 maxHR = 0;
    UInt8 minHR = 255;
    for (TSHRValueItem *item in sampledData) {
        if (item.hrValue > 0) {  // 只考虑有效的心率值
            if (item.hrValue > maxHR) maxHR = item.hrValue;
            if (item.hrValue < minHR) minHR = item.hrValue;
        }
    }

    // 如果所有心率值都是0，使用默认范围
    if (maxHR == 0 && minHR == 255) {
        maxHR = 100;
        minHR = 60;
    }

    // 确保有合理的范围
    if (maxHR == minHR) {
        maxHR = minHR + 10;
    }

    // 如果只有一个数据点，特殊处理
    if (sampledData.count == 1) {
        TSHRValueItem *item = sampledData[0];
        if (item.hrValue > 0) {
            CGFloat w = CGRectGetWidth(_chartContainer.bounds);
            CGFloat x = w / 2.0;
            CGFloat normalizedValue = (item.hrValue - minHR) / (float)(maxHR - minHR);
            CGFloat y = kChartHeight - 10 - (normalizedValue * (kChartHeight - 20));

            // 只显示一个数据点
            UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(x - 3, y - 3, 6, 6)];
            dot.backgroundColor = [self colorForHeartRate:item.hrValue];
            dot.layer.cornerRadius = 3;
            [_chartContainer addSubview:dot];
        }
        [self addValueLabelsWithMax:maxHR min:minHR];
        return;
    }

    CGFloat w = CGRectGetWidth(_chartContainer.bounds);
    CGFloat spacing = w / (sampledData.count - 1);
    CGFloat chartAreaHeight = kChartHeight - 20;

    UIBezierPath *path = [UIBezierPath bezierPath];
    BOOL firstPoint = YES;

    for (NSInteger i = 0; i < sampledData.count; i++) {
        TSHRValueItem *item = sampledData[i];

        // 跳过无效的心率值
        if (item.hrValue == 0) continue;

        CGFloat x = i * spacing;

        // 归一化心率值到图表高度
        CGFloat normalizedValue = (item.hrValue - minHR) / (float)(maxHR - minHR);
        CGFloat y = kChartHeight - 10 - (normalizedValue * chartAreaHeight);

        if (firstPoint) {
            [path moveToPoint:CGPointMake(x, y)];
            firstPoint = NO;
        } else {
            [path addLineToPoint:CGPointMake(x, y)];
        }

        // 数据点
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(x - 3, y - 3, 6, 6)];
        dot.backgroundColor = [self colorForHeartRate:item.hrValue];
        dot.layer.cornerRadius = 3;
        [_chartContainer addSubview:dot];
    }

    // 只有在有有效路径时才绘制线条
    if (!firstPoint) {
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.path = path.CGPath;
        lineLayer.strokeColor = TSColor_Primary.CGColor;
        lineLayer.fillColor = UIColor.clearColor.CGColor;
        lineLayer.lineWidth = 2.f;
        [_chartContainer.layer addSublayer:lineLayer];
    }

    // 添加最大值和最小值标签
    [self addValueLabelsWithMax:maxHR min:minHR];
}

#pragma mark - Helper Methods

- (NSArray<TSHRValueItem *> *)sampleHeartRateData:(NSArray<TSHRValueItem *> *)data maxPoints:(NSInteger)maxPoints {
    if (data.count <= maxPoints) {
        return data;
    }

    // 均匀采样，确保包含第一个和最后一个数据点
    NSMutableArray *sampledData = [NSMutableArray array];

    // 添加第一个数据点
    [sampledData addObject:data[0]];

    // 采样中间的数据点
    if (maxPoints > 2) {
        CGFloat step = (CGFloat)(data.count - 1) / (maxPoints - 1);
        for (NSInteger i = 1; i < maxPoints - 1; i++) {
            NSInteger index = (NSInteger)(i * step);
            if (index < data.count) {
                [sampledData addObject:data[index]];
            }
        }
    }

    // 添加最后一个数据点
    if (data.count > 1) {
        [sampledData addObject:data[data.count - 1]];
    }

    return sampledData;
}

- (UIColor *)colorForHeartRate:(UInt8)hrValue {
    // 根据心率值返回对应的颜色
    if (_summary && _summary.maxHrValue > 0) {
        // 使用summary中的心率区间阈值来判断
        if (hrValue >= _summary.maxHrValue * 0.9) {
            return TSColor_Danger; // 极限区间
        } else if (hrValue >= _summary.maxHrValue * 0.8) {
            return TSColor_Warning; // 无氧区间
        } else if (hrValue >= _summary.maxHrValue * 0.7) {
            return TSColor_Success; // 有氧区间
        } else if (hrValue >= _summary.maxHrValue * 0.6) {
            return TSColor_Primary; // 脂肪燃烧
        } else {
            return TSColor_Gray; // 热身区间
        }
    }

    // 如果没有summary或maxHrValue为0，使用通用的心率区间判断
    if (hrValue >= 170) {
        return TSColor_Danger;
    } else if (hrValue >= 150) {
        return TSColor_Warning;
    } else if (hrValue >= 130) {
        return TSColor_Success;
    } else if (hrValue >= 110) {
        return TSColor_Primary;
    } else {
        return TSColor_Gray;
    }
}

- (void)addValueLabelsWithMax:(UInt8)maxHR min:(UInt8)minHR {
    // 最大值标签
    UILabel *maxLabel = [[UILabel alloc] init];
    maxLabel.text = [NSString stringWithFormat:@"%u", maxHR];
    maxLabel.font = [UIFont systemFontOfSize:10];
    maxLabel.textColor = TSColor_TextSecondary;
    maxLabel.frame = CGRectMake(0, 0, 30, 12);
    [_chartContainer addSubview:maxLabel];

    // 最小值标签
    UILabel *minLabel = [[UILabel alloc] init];
    minLabel.text = [NSString stringWithFormat:@"%u", minHR];
    minLabel.font = [UIFont systemFontOfSize:10];
    minLabel.textColor = TSColor_TextSecondary;
    minLabel.frame = CGRectMake(0, kChartHeight - 20, 30, 12);
    [_chartContainer addSubview:minLabel];
}

@end
