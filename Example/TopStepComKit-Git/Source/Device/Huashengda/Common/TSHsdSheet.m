//
//  TSHsdSheet.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdSheet.h"
#import "TSHsdDisplay.h"
#import "TSRootVC.h"

#pragma mark - 时间选择内容（.tpick）

@interface TSHsdTimePickView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) UILabel *bigLabel;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) UILabel *hourLabel;
@property (nonatomic, strong) UILabel *minuteLabel;
@property (nonatomic, strong) NSMutableArray<UIButton *> *quickButtons;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, assign) NSInteger minute;
@end

@implementation TSHsdTimePickView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _hue = [TSHsdDisplay hueParental];
    _quickButtons = [NSMutableArray array];
    _bigLabel = [[UILabel alloc] init];
    _bigLabel.font = [TSHsdDisplay roundedFontOfSize:52.f weight:UIFontWeightHeavy];
    _bigLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_bigLabel];
    _picker = [[UIPickerView alloc] init];
    _picker.dataSource = self;
    _picker.delegate = self;
    [self addSubview:_picker];
    _hourLabel = [[UILabel alloc] init];
    _hourLabel.text = TSLocalizedString(@"hsd.time.hour");
    _minuteLabel = [[UILabel alloc] init];
    _minuteLabel.text = TSLocalizedString(@"hsd.time.minute");
    for (UILabel *label in @[_hourLabel, _minuteLabel]) {
        label.font = [UIFont systemFontOfSize:11.5f weight:UIFontWeightSemibold];
        label.textColor = [TSHsdDisplay textTertiary];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
    }
    NSArray<NSNumber *> *quick = @[@420, @480, @720, @1080, @1260];
    for (NSNumber *value in quick) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = value.integerValue;
        [button setTitle:[TSHsdDisplay timeStringForMinute:value.integerValue] forState:UIControlStateNormal];
        [button setTitleColor:[TSHsdDisplay textSecondary] forState:UIControlStateNormal];
        button.titleLabel.font = [TSHsdDisplay roundedFontOfSize:12.5f weight:UIFontWeightSemibold];
        button.backgroundColor = [TSHsdDisplay fill];
        button.layer.cornerRadius = 14.f;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 12.f, 0, 12.f);
        [button addTarget:self action:@selector(ts_quick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.quickButtons addObject:button];
    }
    return self;
}

- (void)setHue:(UIColor *)hue { _hue = hue; self.bigLabel.textColor = hue; }

- (void)setMinute:(NSInteger)minute {
    _minute = MAX(0, MIN(minute, 1439));
    self.bigLabel.text = [TSHsdDisplay timeStringForMinute:_minute];
    [self.picker selectRow:_minute / 60 inComponent:0 animated:NO];
    [self.picker selectRow:_minute % 60 inComponent:1 animated:NO];
    [self.picker reloadAllComponents];
}

- (void)ts_quick:(UIButton *)sender {
    self.minute = sender.tag;
    [self.picker selectRow:self.minute / 60 inComponent:0 animated:YES];
    [self.picker selectRow:self.minute % 60 inComponent:1 animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 2; }
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { return component == 0 ? 24 : 60; }
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component { return 44.f; }

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UILabel *label = [view isKindOfClass:[UILabel class]] ? (UILabel *)view : [[UILabel alloc] init];
    NSInteger current = component == 0 ? self.minute / 60 : self.minute % 60;
    label.font = [TSHsdDisplay roundedFontOfSize:22.f weight:row == current ? UIFontWeightBold : UIFontWeightMedium];
    label.textColor = row == current ? [TSHsdDisplay ink] : [TSHsdDisplay textTertiary];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%02ld", (long)row];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger h = [pickerView selectedRowInComponent:0], m = [pickerView selectedRowInComponent:1];
    _minute = h * 60 + m;
    self.bigLabel.text = [TSHsdDisplay timeStringForMinute:_minute];
    [pickerView reloadAllComponents];
}

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 8.f + 56.f + 14.f + 220.f + 8.f + 16.f + 14.f + 30.f + 12.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.bigLabel.frame = CGRectMake(0, 8.f, w, 56.f);
    self.picker.frame = CGRectMake(0, 78.f, w, 220.f);
    self.hourLabel.frame = CGRectMake(0, 306.f, w / 2.f, 16.f);
    self.minuteLabel.frame = CGRectMake(w / 2.f, 306.f, w / 2.f, 16.f);
    CGFloat total = 0;
    for (UIButton *button in self.quickButtons) { [button sizeToFit]; total += ceil(button.bounds.size.width) + 6.f; }
    CGFloat x = (w - total + 6.f) / 2.f;
    for (UIButton *button in self.quickButtons) {
        CGFloat bw = ceil(button.bounds.size.width);
        button.frame = CGRectMake(x, 336.f, bw, 28.f);
        x += bw + 6.f;
    }
}

@end

#pragma mark - 数值滚轮配置

@implementation TSHsdValuePickConfig

- (instancetype)init {
    self = [super init];
    if (!self) { return nil; }
    _title = @"";
    _maxValue = 100;
    _quickValues = @[];
    _quickTitles = @[];
    return self;
}

- (NSInteger)clampValue:(NSInteger)value { return MAX(self.minValue, MIN(self.maxValue, value)); }

- (NSAttributedString *)attributedTextForValue:(NSInteger)value numberFont:(UIFont *)numberFont unitFont:(UIFont *)unitFont color:(UIColor *)color unitColor:(UIColor *)unitColor {
    // 片段：@[数字文字, 单位文字]
    NSMutableArray<NSArray<NSString *> *> *parts = [NSMutableArray array];
    if (self.hourMinute) {
        NSInteger h = value / 60, m = value % 60;
        if (h > 0) { [parts addObject:@[[NSString stringWithFormat:@"%ld", (long)h], TSLocalizedString(@"hsd.unit.hours")]]; }
        if (m > 0 || h == 0) { [parts addObject:@[[NSString stringWithFormat:@"%ld", (long)m], TSLocalizedString(@"hsd.unit.minutes")]]; }
    } else if (value == 0 && self.zeroText.length) {
        [parts addObject:@[self.zeroText, @""]];
    } else {
        [parts addObject:@[[NSString stringWithFormat:@"%ld", (long)value], self.unit ?: @""]];
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    [parts enumerateObjectsUsingBlock:^(NSArray<NSString *> *part, NSUInteger i, BOOL *stop) {
        if (i > 0) { [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName: unitFont}]]; }
        // 「准时」这类文字值比数字宽，字号按单位字号放大一档，避免胶囊过宽
        BOOL isWord = part[1].length == 0 && self.zeroText.length && [part[0] isEqualToString:self.zeroText];
        UIFont *nf = isWord ? [UIFont systemFontOfSize:numberFont.pointSize * 0.8f weight:UIFontWeightBold] : numberFont;
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:part[0] attributes:@{NSFontAttributeName: nf, NSForegroundColorAttributeName: color}]];
        if (part[1].length) {
            NSString *unit = [@" " stringByAppendingString:part[1]];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:unit attributes:@{NSFontAttributeName: unitFont, NSForegroundColorAttributeName: unitColor}]];
        }
    }];
    return text;
}

@end

#pragma mark - 数值滚轮内容（.vpick）

@interface TSHsdValuePickView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) TSHsdValuePickConfig *config;
@property (nonatomic, strong) UILabel *bigLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) NSArray<UILabel *> *columnLabels;
@property (nonatomic, strong) NSMutableArray<UIButton *> *quickButtons;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, assign) NSInteger value;
@end

@implementation TSHsdValuePickView

- (instancetype)initWithConfig:(TSHsdValuePickConfig *)config {
    self = [super initWithFrame:CGRectZero];
    if (!self) { return nil; }
    _config = config;
    _hue = [TSHsdDisplay hueParental];
    _quickButtons = [NSMutableArray array];
    _bigLabel = [[UILabel alloc] init];
    _bigLabel.textAlignment = NSTextAlignmentCenter;
    _bigLabel.adjustsFontSizeToFitWidth = YES;
    _bigLabel.minimumScaleFactor = 0.6f;
    [self addSubview:_bigLabel];
    _hintLabel = [[UILabel alloc] init];
    _hintLabel.font = [UIFont systemFontOfSize:12.f];
    _hintLabel.textColor = [TSHsdDisplay textTertiary];
    _hintLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_hintLabel];
    _picker = [[UIPickerView alloc] init];
    _picker.dataSource = self;
    _picker.delegate = self;
    [self addSubview:_picker];
    NSArray<NSString *> *titles = config.hourMinute ? @[TSLocalizedString(@"hsd.unit.hours"), TSLocalizedString(@"hsd.unit.minutes")] : @[config.unit ?: @""];
    NSMutableArray<UILabel *> *labels = [NSMutableArray array];
    for (NSString *title in titles) {
        UILabel *label = [[UILabel alloc] init];
        label.text = title;
        label.font = [UIFont systemFontOfSize:11.5f weight:UIFontWeightSemibold];
        label.textColor = [TSHsdDisplay textTertiary];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [labels addObject:label];
    }
    _columnLabels = labels;
    [config.quickValues enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger i, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = value.integerValue;
        [button setTitle:i < config.quickTitles.count ? config.quickTitles[i] : value.stringValue forState:UIControlStateNormal];
        button.titleLabel.font = [TSHsdDisplay roundedFontOfSize:12.5f weight:UIFontWeightSemibold];
        button.layer.cornerRadius = 14.f;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 12.f, 0, 12.f);
        [button addTarget:self action:@selector(ts_quick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.quickButtons addObject:button];
    }];
    return self;
}

- (void)setHue:(UIColor *)hue { _hue = hue; [self ts_refreshTexts]; }

- (void)setValue:(NSInteger)value {
    _value = [self.config clampValue:value];
    [self ts_selectRowsAnimated:NO];
    [self ts_refreshTexts];
}

#pragma mark 行 ↔ 值

- (NSInteger)ts_rowForComponent:(NSInteger)component {
    if (self.config.hourMinute) { return component == 0 ? self.value / 60 : self.value % 60; }
    return self.value - self.config.minValue;
}

- (void)ts_selectRowsAnimated:(BOOL)animated {
    for (NSInteger c = 0; c < [self numberOfComponentsInPickerView:self.picker]; c++) {
        [self.picker selectRow:[self ts_rowForComponent:c] inComponent:c animated:animated];
    }
    [self.picker reloadAllComponents];
}

- (void)ts_refreshTexts {
    self.bigLabel.attributedText = [self.config attributedTextForValue:self.value
                                                            numberFont:[TSHsdDisplay roundedFontOfSize:52.f weight:UIFontWeightHeavy]
                                                              unitFont:[UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold]
                                                                 color:self.hue
                                                             unitColor:[self.hue colorWithAlphaComponent:0.8f]];
    self.hintLabel.text = self.config.hintBlock ? self.config.hintBlock(self.value) : nil;
    for (UIButton *button in self.quickButtons) {
        BOOL on = button.tag == self.value;
        [button setTitleColor:on ? self.hue : [TSHsdDisplay textSecondary] forState:UIControlStateNormal];
        button.backgroundColor = on ? [self.hue colorWithAlphaComponent:0.13f] : [TSHsdDisplay fill];
    }
}

- (void)ts_quick:(UIButton *)sender {
    _value = [self.config clampValue:sender.tag];
    [self ts_selectRowsAnimated:YES];
    [self ts_refreshTexts];
}

#pragma mark UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return self.config.hourMinute ? 2 : 1; }

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.config.hourMinute) { return component == 0 ? self.config.maxValue / 60 + 1 : 60; }
    return MAX(1, self.config.maxValue - self.config.minValue + 1);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component { return 44.f; }

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    UILabel *label = [view isKindOfClass:[UILabel class]] ? (UILabel *)view : [[UILabel alloc] init];
    BOOL current = row == [self ts_rowForComponent:component];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = current ? [TSHsdDisplay ink] : [TSHsdDisplay textTertiary];
    NSInteger value = self.config.hourMinute ? row : self.config.minValue + row;
    if (!self.config.hourMinute && value == 0 && self.config.zeroText.length) {
        label.font = [UIFont systemFontOfSize:19.f weight:current ? UIFontWeightBold : UIFontWeightMedium];
        label.text = self.config.zeroText;
    } else {
        label.font = [TSHsdDisplay roundedFontOfSize:22.f weight:current ? UIFontWeightBold : UIFontWeightMedium];
        label.text = (self.config.hourMinute && component == 1) ? [NSString stringWithFormat:@"%02ld", (long)value] : [NSString stringWithFormat:@"%ld", (long)value];
    }
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger picked;
    if (self.config.hourMinute) {
        NSInteger h = [pickerView selectedRowInComponent:0], m = [pickerView selectedRowInComponent:1];
        picked = h * 60 + m;
    } else {
        picked = self.config.minValue + row;
    }
    NSInteger clamped = [self.config clampValue:picked];
    _value = clamped;
    // 时 / 分组合越界（如 10 小时 30 分、0 小时 0 分）时，把滚轮拨回合法值
    if (clamped != picked) { [self ts_selectRowsAnimated:YES]; } else { [pickerView reloadAllComponents]; }
    [self ts_refreshTexts];
}

#pragma mark 布局

- (CGFloat)ts_quickHeightForWidth:(CGFloat)width {
    if (self.quickButtons.count == 0) { return 0; }
    NSInteger lines = 1;
    CGFloat x = 0;
    for (UIButton *button in self.quickButtons) {
        CGFloat bw = ceil([button sizeThatFits:CGSizeMake(CGFLOAT_MAX, 28.f)].width);
        if (x > 0 && x + bw > width) { lines++; x = 0; }
        x += bw + 6.f;
    }
    return lines * 28.f + (lines - 1) * 8.f;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat quick = [self ts_quickHeightForWidth:size.width - 32.f];
    return CGSizeMake(size.width, 8.f + 56.f + 4.f + 16.f + 10.f + 220.f + 8.f + 16.f + (quick > 0 ? 14.f + quick : 0) + 12.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.bigLabel.frame = CGRectMake(16.f, 8.f, w - 32.f, 56.f);
    self.hintLabel.frame = CGRectMake(16.f, 68.f, w - 32.f, 16.f);
    CGFloat pickerW = self.config.hourMinute ? w : MIN(w, 220.f);
    self.picker.frame = CGRectMake((w - pickerW) / 2.f, 94.f, pickerW, 220.f);
    CGFloat labelY = 94.f + 220.f + 8.f;
    if (self.columnLabels.count == 2) {
        self.columnLabels[0].frame = CGRectMake(0, labelY, w / 2.f, 16.f);
        self.columnLabels[1].frame = CGRectMake(w / 2.f, labelY, w / 2.f, 16.f);
    } else {
        self.columnLabels.firstObject.frame = CGRectMake(0, labelY, w, 16.f);
    }
    // 快捷值：按行居中换行
    CGFloat maxW = w - 32.f, y = labelY + 16.f + 14.f;
    NSMutableArray<NSMutableArray<UIButton *> *> *lines = [NSMutableArray arrayWithObject:[NSMutableArray array]];
    CGFloat x = 0;
    for (UIButton *button in self.quickButtons) {
        CGFloat bw = ceil([button sizeThatFits:CGSizeMake(CGFLOAT_MAX, 28.f)].width);
        if (x > 0 && x + bw > maxW) { [lines addObject:[NSMutableArray array]]; x = 0; }
        [lines.lastObject addObject:button];
        x += bw + 6.f;
    }
    for (NSArray<UIButton *> *line in lines) {
        CGFloat total = 0;
        for (UIButton *button in line) { total += ceil([button sizeThatFits:CGSizeMake(CGFLOAT_MAX, 28.f)].width) + 6.f; }
        CGFloat bx = (w - total + 6.f) / 2.f;
        for (UIButton *button in line) {
            CGFloat bw = ceil([button sizeThatFits:CGSizeMake(CGFLOAT_MAX, 28.f)].width);
            button.frame = CGRectMake(bx, y, bw, 28.f);
            bx += bw + 6.f;
        }
        y += 28.f + 8.f;
    }
}

@end

#pragma mark - 网格瓦片（.types / .type）

@interface TSHsdGridView : UIView
@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, copy) NSArray<NSString *> *symbols;
@property (nonatomic, copy) NSArray<NSNumber *> *indexes;
@property (nonatomic, assign) NSInteger selected;
@property (nonatomic, strong) UIColor *hue;
@property (nonatomic, copy, nullable) void (^onPick)(NSInteger index);
@property (nonatomic, strong) NSMutableArray<UIControl *> *tiles;
@end

@implementation TSHsdGridView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _tiles = [NSMutableArray array];
    _hue = [TSHsdDisplay hueParental];
    return self;
}

- (void)reloadTiles {
    for (UIControl *tile in self.tiles) { [tile removeFromSuperview]; }
    [self.tiles removeAllObjects];
    [self.titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger i, BOOL *stop) {
        UIControl *tile = [[UIControl alloc] init];
        tile.tag = i;
        tile.backgroundColor = [TSHsdDisplay card];
        tile.layer.cornerRadius = 16.f;
        tile.layer.shadowColor = [UIColor colorWithRed:0x14/255.f green:0x17/255.f blue:0x26/255.f alpha:1].CGColor;
        tile.layer.shadowOpacity = 0.06f; tile.layer.shadowRadius = 8.f; tile.layer.shadowOffset = CGSizeMake(0, 3.f);
        BOOL on = self.indexes[i].integerValue == self.selected;
        tile.layer.borderWidth = on ? 2.f : 0;
        tile.layer.borderColor = self.hue.CGColor;
        UILabel *index = [[UILabel alloc] init];
        index.font = [TSHsdDisplay monoFontOfSize:9.f];
        index.textColor = [TSHsdDisplay textTertiary];
        index.text = [NSString stringWithFormat:@"%@", self.indexes[i]];
        index.textAlignment = NSTextAlignmentRight;
        index.tag = 1001;
        [tile addSubview:index];
        UIImageView *icon = [[UIImageView alloc] initWithImage:TSHsdSymbol(self.symbols[i], 22.f, UIImageSymbolWeightMedium)];
        icon.tintColor = on ? self.hue : [TSHsdDisplay ink];
        icon.contentMode = UIViewContentModeCenter;
        icon.tag = 1002;
        [tile addSubview:icon];
        UILabel *name = [[UILabel alloc] init];
        name.font = [UIFont systemFontOfSize:12.f weight:UIFontWeightMedium];
        name.textColor = on ? self.hue : [TSHsdDisplay ink];
        name.text = title;
        name.textAlignment = NSTextAlignmentCenter;
        name.adjustsFontSizeToFitWidth = YES;
        name.minimumScaleFactor = 0.8f;
        name.tag = 1003;
        [tile addSubview:name];
        [tile addTarget:self action:@selector(ts_tapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tile];
        [self.tiles addObject:tile];
    }];
    [self setNeedsLayout];
}

- (void)ts_tapped:(UIControl *)sender { if (self.onPick) { self.onPick(self.indexes[sender.tag].integerValue); } }

- (CGFloat)ts_tileHeight { return 74.f; }

- (CGSize)sizeThatFits:(CGSize)size {
    NSInteger rows = (NSInteger)ceil(self.tiles.count / 4.0);
    return CGSizeMake(size.width, rows * [self ts_tileHeight] + MAX(0, rows - 1) * 8.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat tw = (self.bounds.size.width - 8.f * 3) / 4.f, th = [self ts_tileHeight];
    [self.tiles enumerateObjectsUsingBlock:^(UIControl *tile, NSUInteger i, BOOL *stop) {
        NSInteger col = i % 4, row = i / 4;
        tile.frame = CGRectMake(col * (tw + 8.f), row * (th + 8.f), tw, th);
        [tile viewWithTag:1001].frame = CGRectMake(tw - 30.f, 5.f, 23.f, 12.f);
        [tile viewWithTag:1002].frame = CGRectMake(0, 12.f, tw, 30.f);
        [tile viewWithTag:1003].frame = CGRectMake(2.f, 46.f, tw - 4.f, 18.f);
    }];
}

@end

#pragma mark - 金币大步进（.bigstep）

@interface TSHsdBigStepView : UIView
@property (nonatomic, assign) NSInteger value;
@property (nonatomic, strong) UIImageView *coinView;
@property (nonatomic, strong) UIButton *minus;
@property (nonatomic, strong) UIButton *plus;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) NSMutableArray<UIButton *> *presets;
@end

@implementation TSHsdBigStepView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _presets = [NSMutableArray array];
    _coinView = [[UIImageView alloc] initWithImage:TSHsdSymbol(@"dollarsign.circle.fill", 48.f, UIImageSymbolWeightMedium)];
    _coinView.tintColor = [TSHsdDisplay hueTask];
    _coinView.contentMode = UIViewContentModeCenter;
    [self addSubview:_coinView];
    _minus = [self ts_round:@"minus" delta:-1];
    _plus = [self ts_round:@"plus" delta:1];
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.font = [TSHsdDisplay roundedFontOfSize:46.f weight:UIFontWeightHeavy];
    _valueLabel.textColor = [TSHsdDisplay ink];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_valueLabel];
    NSArray<NSArray *> *presets = @[@[@"+5", @5], @[@"+10", @10], @[@"−5", @-5], @[TSLocalizedString(@"hsd.coins.zero"), @0]];
    for (NSArray *preset in presets) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = [preset[1] integerValue];
        [button setTitle:preset[0] forState:UIControlStateNormal];
        [button setTitleColor:[TSHsdDisplay textSecondary] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightSemibold];
        button.backgroundColor = [TSHsdDisplay fill];
        button.layer.cornerRadius = 13.f;
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 12.f, 0, 12.f);
        [button addTarget:self action:@selector(ts_preset:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.presets addObject:button];
    }
    return self;
}

- (UIButton *)ts_round:(NSString *)symbol delta:(NSInteger)delta {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = delta;
    [button setImage:TSHsdSymbol(symbol, 16.f, UIImageSymbolWeightBold) forState:UIControlStateNormal];
    button.tintColor = [TSHsdDisplay ink];
    button.backgroundColor = [TSHsdDisplay fill];
    button.layer.cornerRadius = 22.f;
    [button addTarget:self action:@selector(ts_step:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)setValue:(NSInteger)value { _value = MAX(0, MIN(9999, value)); self.valueLabel.text = [NSString stringWithFormat:@"%ld", (long)_value]; }
- (void)ts_step:(UIButton *)sender { self.value = self.value + sender.tag; }
- (void)ts_preset:(UIButton *)sender { self.value = sender.tag == 0 ? 0 : self.value + sender.tag; }

- (CGSize)sizeThatFits:(CGSize)size { return CGSizeMake(size.width, 22.f + 54.f + 14.f + 48.f + 14.f + 26.f + 20.f); }

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width;
    self.coinView.frame = CGRectMake((w - 54.f) / 2.f, 22.f, 54.f, 54.f);
    CGFloat y = 90.f;
    self.valueLabel.frame = CGRectMake((w - 96.f) / 2.f, y, 96.f, 48.f);
    self.minus.frame = CGRectMake((w - 96.f) / 2.f - 22.f - 44.f, y + 2.f, 44.f, 44.f);
    self.plus.frame = CGRectMake((w + 96.f) / 2.f + 22.f, y + 2.f, 44.f, 44.f);
    CGFloat total = 0;
    for (UIButton *button in self.presets) { [button sizeToFit]; total += ceil(button.bounds.size.width) + 6.f; }
    CGFloat x = (w - total + 6.f) / 2.f;
    for (UIButton *button in self.presets) {
        CGFloat bw = ceil(button.bounds.size.width);
        button.frame = CGRectMake(x, y + 62.f, bw, 26.f);
        x += bw + 6.f;
    }
}

@end

#pragma mark - 差异表（table.diff）

@interface TSHsdDiffTableView : UIView
@property (nonatomic, copy) NSArray<TSHsdDiffItem *> *items;
@property (nonatomic, strong) NSMutableArray<UIView *> *rowViews;
@end

@implementation TSHsdDiffTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) { return nil; }
    _rowViews = [NSMutableArray array];
    return self;
}

- (void)setItems:(NSArray<TSHsdDiffItem *> *)items {
    _items = [items copy];
    for (UIView *row in self.rowViews) { [row removeFromSuperview]; }
    [self.rowViews removeAllObjects];
    NSArray<NSString *> *headers = @[TSLocalizedString(@"hsd.diff.col.field"), TSLocalizedString(@"hsd.diff.col.sent"), TSLocalizedString(@"hsd.diff.col.read")];
    [self.rowViews addObject:[self ts_rowWithTexts:headers header:YES bad:NO]];
    for (TSHsdDiffItem *item in items) {
        [self.rowViews addObject:[self ts_rowWithTexts:@[item.field, item.sent, item.read] header:NO bad:YES]];
    }
    for (UIView *row in self.rowViews) { [self addSubview:row]; }
    [self setNeedsLayout];
}

- (UIView *)ts_rowWithTexts:(NSArray<NSString *> *)texts header:(BOOL)header bad:(BOOL)bad {
    UIView *row = [[UIView alloc] init];
    for (NSUInteger i = 0; i < 3; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.tag = 10 + i;
        label.numberOfLines = 0;
        label.text = texts[i];
        if (header) {
            label.font = [UIFont systemFontOfSize:11.5f weight:UIFontWeightSemibold];
            label.textColor = [TSHsdDisplay textTertiary];
        } else if (i == 0) {
            label.font = [TSHsdDisplay monoFontOfSize:11.5f];
            label.textColor = [TSHsdDisplay ink];
        } else if (i == 1) {
            label.font = [UIFont systemFontOfSize:12.5f];
            label.textColor = [TSHsdDisplay textSecondary];
        } else {
            label.font = [UIFont systemFontOfSize:12.5f weight:UIFontWeightBold];
            label.textColor = [TSHsdDisplay statusBad];
        }
        [row addSubview:label];
    }
    if (!header) {
        UIView *line = [[UIView alloc] init];
        line.tag = 20;
        line.backgroundColor = TSAdaptiveColor([[UIColor blackColor] colorWithAlphaComponent:0.06], [[UIColor whiteColor] colorWithAlphaComponent:0.08]);
        [row addSubview:line];
    }
    return row;
}

- (CGFloat)ts_rowHeight:(UIView *)row width:(CGFloat)width {
    CGFloat colW = (width - 24.f * 3) / 3.f;
    CGFloat h = 0;
    for (NSUInteger i = 0; i < 3; i++) {
        UILabel *label = [row viewWithTag:10 + i];
        h = MAX(h, ceil([label sizeThatFits:CGSizeMake(colW, CGFLOAT_MAX)].height));
    }
    return h + 20.f;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat h = 0;
    for (UIView *row in self.rowViews) { h += [self ts_rowHeight:row width:size.width]; }
    return CGSizeMake(size.width, h);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.bounds.size.width, colW = (w - 24.f * 3) / 3.f, y = 0;
    for (UIView *row in self.rowViews) {
        CGFloat h = [self ts_rowHeight:row width:w];
        row.frame = CGRectMake(0, y, w, h);
        for (NSUInteger i = 0; i < 3; i++) {
            [row viewWithTag:10 + i].frame = CGRectMake(12.f + i * (colW + 24.f), 10.f, colW, h - 20.f);
        }
        [row viewWithTag:20].frame = CGRectMake(0, 0, w, 1.f / [UIScreen mainScreen].scale);
        y += h;
    }
}

@end

#pragma mark - TSHsdSheet

@interface TSHsdSheet ()
@property (nonatomic, copy) NSString *sheetTitle;
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, copy) NSArray<UIView *> *blocks;
@property (nonatomic, copy, nullable) void (^onButton)(void);
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TSHsdStackView *stack;
@property (nonatomic, assign) BOOL presentedOnce;
/// 面板是否处于收起（屏幕外）状态；布局按此状态摆放，动画只改这个状态
@property (nonatomic, assign) BOOL panelHidden;
@end

@implementation TSHsdSheet

+ (instancetype)sheetWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle blocks:(NSArray<UIView *> *)blocks onButton:(nullable void (^)(void))onButton {
    TSHsdSheet *sheet = [[TSHsdSheet alloc] init];
    sheet.sheetTitle = title;
    sheet.buttonTitle = buttonTitle;
    sheet.blocks = blocks;
    sheet.onButton = onButton;
    sheet.modalPresentationStyle = UIModalPresentationOverFullScreen;
    sheet.panelHidden = YES;
    return sheet;
}

+ (void)presentTimeFrom:(UIViewController *)presenter title:(NSString *)title minute:(NSInteger)minute hue:(UIColor *)hue onPick:(void (^)(NSInteger))onPick {
    TSHsdTimePickView *pick = [[TSHsdTimePickView alloc] init];
    pick.hue = hue;
    pick.minute = minute;
    __block TSHsdSheet *sheet = nil;
    sheet = [self sheetWithTitle:title buttonTitle:TSLocalizedString(@"general.done") blocks:@[pick] onButton:^{
        NSInteger picked = pick.minute;
        [sheet dismiss];
        if (onPick) { onPick(picked); }
    }];
    [sheet presentFrom:presenter];
}

+ (void)presentValueFrom:(UIViewController *)presenter config:(TSHsdValuePickConfig *)config value:(NSInteger)value hue:(UIColor *)hue onPick:(void (^)(NSInteger))onPick {
    TSHsdValuePickView *pick = [[TSHsdValuePickView alloc] initWithConfig:config];
    pick.hue = hue;
    pick.value = value;
    __block TSHsdSheet *sheet = nil;
    sheet = [self sheetWithTitle:config.title buttonTitle:TSLocalizedString(@"general.done") blocks:@[pick] onButton:^{
        NSInteger picked = pick.value;
        [sheet dismiss];
        if (onPick) { onPick(picked); }
    }];
    [sheet presentFrom:presenter];
}

+ (void)presentGridFrom:(UIViewController *)presenter title:(NSString *)title buttonTitle:(NSString *)buttonTitle titles:(NSArray<NSString *> *)titles symbols:(NSArray<NSString *> *)symbols indexes:(NSArray<NSNumber *> *)indexes selected:(NSInteger)selected hue:(UIColor *)hue footNote:(nullable NSString *)footNote onPick:(void (^)(NSInteger))onPick {
    TSHsdGridView *grid = [[TSHsdGridView alloc] init];
    grid.hue = hue;
    grid.titles = titles; grid.symbols = symbols; grid.indexes = indexes; grid.selected = selected;
    [grid reloadTiles];
    NSMutableArray<UIView *> *blocks = [NSMutableArray arrayWithObject:grid];
    if (footNote.length) { TSHsdFootView *foot = [[TSHsdFootView alloc] init]; foot.text = footNote; [blocks addObject:foot]; }
    __block TSHsdSheet *sheet = nil;
    sheet = [self sheetWithTitle:title buttonTitle:buttonTitle blocks:blocks onButton:^{ [sheet dismiss]; }];
    grid.onPick = ^(NSInteger index) {
        [sheet dismiss];
        if (onPick) { onPick(index); }
    };
    [sheet presentFrom:presenter];
}

+ (void)presentCoinsFrom:(UIViewController *)presenter value:(NSInteger)value hue:(UIColor *)hue onDone:(void (^)(NSInteger))onDone {
    TSHsdBigStepView *step = [[TSHsdBigStepView alloc] init];
    step.value = value;
    TSHsdCardView *card = [[TSHsdCardView alloc] init];
    card.rows = @[step];
    TSHsdFootView *foot = [[TSHsdFootView alloc] init];
    foot.text = TSLocalizedString(@"hsd.coins.sheet_foot");
    __block TSHsdSheet *sheet = nil;
    sheet = [self sheetWithTitle:TSLocalizedString(@"hsd.coins.adjust_title") buttonTitle:TSLocalizedString(@"general.done") blocks:@[card, foot] onButton:^{
        NSInteger v = step.value;
        [sheet dismiss];
        if (onDone) { onDone(v); }
    }];
    [sheet presentFrom:presenter];
}

+ (void)presentDiffFrom:(UIViewController *)presenter items:(NSArray<TSHsdDiffItem *> *)items {
    TSHsdBannerView *banner = [[TSHsdBannerView alloc] init];
    banner.warn = YES;
    banner.text = TSLocalizedString(@"hsd.diff.intro");
    TSHsdDiffTableView *table = [[TSHsdDiffTableView alloc] init];
    table.items = items;
    TSHsdCardView *card = [[TSHsdCardView alloc] init];
    card.rows = @[table];
    TSHsdFootView *foot = [[TSHsdFootView alloc] init];
    foot.text = TSLocalizedString(@"hsd.diff.foot");
    __block TSHsdSheet *sheet = nil;
    sheet = [self sheetWithTitle:[NSString stringWithFormat:TSLocalizedString(@"hsd.diff.title_format"), (long)items.count]
                     buttonTitle:TSLocalizedString(@"general.got_it") blocks:@[banner, card, foot] onButton:^{ [sheet dismiss]; }];
    [sheet presentFrom:presenter];
}

- (void)presentFrom:(UIViewController *)presenter {
    // 不用系统转场：自己做「遮罩淡入 + 面板从底部滑上」（见 viewDidAppear），关闭时反向
    [presenter presentViewController:self animated:NO completion:nil];
}

- (void)dismiss {
    if (self.panelHidden) { return; }
    self.panelHidden = YES;
    [UIView animateWithDuration:0.22 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.dimView.alpha = 0;
        [self ts_layoutPanel];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            // 打破 sheet ↔ onButton / blocks 之间的引用环
            self.onButton = nil;
            self.blocks = nil;
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.presentedOnce) { return; }
    self.presentedOnce = YES;
    self.dimView.alpha = 0;
    [self ts_layoutPanel];   // 先摆到屏幕外
    self.panelHidden = NO;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.5 options:0 animations:^{
        self.dimView.alpha = 1;
        [self ts_layoutPanel];
    } completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.dimView = [[UIView alloc] init];
    self.dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.38f];
    self.dimView.alpha = 0;   // 出现动画里淡入
    [self.dimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    [self.view addSubview:self.dimView];

    self.panel = [[UIView alloc] init];
    self.panel.backgroundColor = TSColor_Background;
    self.panel.layer.cornerRadius = 30.f;
    self.panel.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    self.panel.clipsToBounds = YES;
    [self.view addSubview:self.panel];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:19.f weight:UIFontWeightBold];
    self.titleLabel.textColor = [TSHsdDisplay ink];
    self.titleLabel.text = self.sheetTitle;
    [self.panel addSubview:self.titleLabel];

    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.button setTitle:self.buttonTitle forState:UIControlStateNormal];
    self.button.titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
    [self.button setTitleColor:[TSHsdDisplay ink] forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(ts_buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:self.button];

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.panel addSubview:self.scrollView];
    self.stack = [[TSHsdStackView alloc] init];
    self.stack.topInset = 4.f;
    self.stack.bottomInset = 34.f;
    [self.stack setBlocks:self.blocks];
    [self.scrollView addSubview:self.stack];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.dimView.frame = self.view.bounds;
    [self ts_layoutPanel];
}

/// 面板高度由内容决定（最多 84% 屏高）；panelHidden 时整体放到屏幕底部之外。只改 frame，不用 transform，
/// 这样动画过程中再触发布局也不会把面板摆错位置
- (void)ts_layoutPanel {
    CGRect bounds = self.view.bounds;
    CGFloat w = bounds.size.width;
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat contentH = [self.stack sizeThatFits:CGSizeMake(w, CGFLOAT_MAX)].height;
    CGFloat headerH = 56.f;
    CGFloat panelH = MIN(bounds.size.height * 0.84f, headerH + contentH + bottomInset);
    CGFloat y = self.panelHidden ? bounds.size.height : bounds.size.height - panelH;
    self.panel.frame = CGRectMake(0, y, w, panelH);
    self.titleLabel.frame = CGRectMake(22.f, 10.f, w - 120.f, 36.f);
    [self.button sizeToFit];
    self.button.frame = CGRectMake(w - 18.f - self.button.bounds.size.width - 8.f, 10.f, self.button.bounds.size.width + 8.f, 36.f);
    self.scrollView.frame = CGRectMake(0, headerH, w, panelH - headerH);
    self.stack.frame = CGRectMake(0, 0, w, contentH);
    self.scrollView.contentSize = CGSizeMake(w, contentH + bottomInset);
}

- (void)ts_buttonTapped {
    if (self.onButton) { self.onButton(); } else { [self dismiss]; }
}

@end
