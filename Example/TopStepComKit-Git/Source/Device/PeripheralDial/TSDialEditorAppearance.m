//
//  TSDialEditorAppearance.m
//  TopStepComKit_Example
//

#import "TSDialEditorAppearance.h"

@implementation TSDialEditorAppearance

#pragma mark - 公开方法

// 转换原型 RGB 色值。
+ (UIColor *)color:(NSUInteger)value {
    return [UIColor colorWithRed:((value >> 16) & 255) / 255.0
                           green:((value >> 8) & 255) / 255.0 blue:(value & 255) / 255.0 alpha:1];
}

// 读取不透明颜色。
+ (UIColor *)colorFromHex:(NSString *)hex {
    unsigned int value = 0xFFFFFF;
    [[NSScanner scannerWithString:[hex stringByReplacingOccurrencesOfString:@"#" withString:@""]] scanHexInt:&value];
    return [self color:value];
}

// 将系统颜色统一转换到 RGB。
+ (NSString *)hexFromColor:(UIColor *)color {
    CGFloat red = 1, green = 1, blue = 1, alpha = 1;
    if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        CGFloat white = 1;
        [color getWhite:&white alpha:&alpha];
        red = green = blue = white;
    }
    return [NSString stringWithFormat:@"%02X%02X%02X", (int)round(red * 255),
            (int)round(green * 255), (int)round(blue * 255)];
}

// 创建原型字体标签。
+ (UILabel *)label:(NSString *)text size:(CGFloat)size color:(NSUInteger)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = [self color:color];
    return label;
}

// 创建主次操作按钮。
+ (UIButton *)button:(NSString *)title primary:(BOOL)primary {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:primary ? UIColor.whiteColor : [self color:0x252823] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:primary ? 14 : 12
                                            weight:primary ? UIFontWeightSemibold : UIFontWeightRegular];
    button.backgroundColor = [self color:primary ? 0xF16D43 : 0xF7F8F3];
    button.layer.cornerRadius = 12;
    button.layer.borderColor = [self color:0xE5E8DF].CGColor;
    button.layer.borderWidth = primary ? 0 : 1;
    return button;
}

// 组合编号和标题。
+ (UIView *)heading:(NSInteger)number title:(NSString *)title {
    UIView *heading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    UILabel *numberLabel = [self label:[NSString stringWithFormat:@"%02ld", (long)number] size:10 color:0xA8AD9F];
    numberLabel.frame = CGRectMake(0, 0, 25, 20);
    UILabel *titleLabel = [self label:title size:14 color:0x252823];
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    titleLabel.frame = CGRectMake(25, 0, 240, 20);
    [heading addSubview:numberLabel];
    [heading addSubview:titleLabel];
    return heading;
}

// 图标直接使用 HTML 矢量源导出的资源。
+ (UIImage *)icon:(NSString *)name {
    return [[UIImage imageNamed:[@"ts_dial_icon_" stringByAppendingString:name]]
            imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

// 色轮始终保持彩虹色，不用当前选色覆盖。
+ (UIImage *)colorWheel {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(20, 20)];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        NSArray<NSNumber *> *colors = @[@0xBFA6EF, @0xD49FE2, @0xEFA5C8, @0xEDB795,
                                       @0xDFCF81, @0xBED695, @0x9AD8C2, @0x96CDE8];
        for (NSInteger index = 0; index < 360; index++) {
            CGFloat ratio = index / 360.0 * colors.count;
            NSUInteger current = (NSUInteger)floor(ratio);
            UIColor *start = [self color:colors[current].unsignedIntegerValue];
            UIColor *end = [self color:colors[(current + 1) % colors.count].unsignedIntegerValue];
            CGFloat red, green, blue, alpha, endRed, endGreen, endBlue;
            [start getRed:&red green:&green blue:&blue alpha:&alpha];
            [end getRed:&endRed green:&endGreen blue:&endBlue alpha:&alpha];
            CGFloat blend = ratio - current;
            [[UIColor colorWithRed:red + (endRed - red) * blend green:green + (endGreen - green) * blend
                              blue:blue + (endBlue - blue) * blend alpha:1] setFill];
            UIBezierPath *slice = [UIBezierPath bezierPath];
            [slice moveToPoint:CGPointMake(10, 10)];
            [slice addArcWithCenter:CGPointMake(10, 10) radius:10 startAngle:(index - 90) * M_PI / 180
                          endAngle:(index - 88.5) * M_PI / 180 clockwise:YES];
            [slice closePath];
            [slice fill];
        }
    }];
}

// 输出 scale=1 的完整填充图片。
+ (UIImage *)fillImage:(UIImage *)image size:(CGSize)size {
    if (size.width <= 0 || size.height <= 0 || image.size.width <= 0 || image.size.height <= 0) {
        return image;
    }
    CGFloat scale = MAX(size.width / image.size.width, size.height / image.size.height);
    CGSize scaled = CGSizeMake(image.size.width * scale, image.size.height * scale);
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = 1;
    format.opaque = YES;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [UIColor.blackColor setFill];
        UIRectFill((CGRect){CGPointZero, size});
        [image drawInRect:CGRectMake((size.width - scaled.width) / 2, (size.height - scaled.height) / 2,
                                    scaled.width, scaled.height)];
    }];
}

@end
