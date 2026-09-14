//
//  TSDialTimeStyleView.m
//  TopStepComKit_Example
//

#import "TSDialTimeStyleView.h"
#import <TopStepComKit/TopStepComKit.h>
#import "TSDialEditorAppearance.h"
#import "TSDialEditorState.h"

@interface TSDialTimeStyleView ()
// 当前展示输入，不在 View 内修改。
@property (nonatomic, strong) TSDialEditorState *state;
// 可用样式。
@property (nonatomic, strong) TSCustomDialStyleConstraint *constraint;
// 渲染完成的样式图。
@property (nonatomic, copy) NSDictionary<NSNumber *, UIImage *> *images;
// 当前区块标题。
@property (nonatomic, strong) UIView *heading;
// 样式横向容器。
@property (nonatomic, strong) UIScrollView *styleScroll;
// 样式按钮。
@property (nonatomic, strong) NSMutableArray<UIButton *> *styleButtons;
// 颜色按钮。
@property (nonatomic, strong) NSMutableArray<UIButton *> *colorButtons;
// 颜色行标题。
@property (nonatomic, strong) UILabel *colorLabel;
// 时间可见开关。
@property (nonatomic, strong) UISwitch *timeSwitch;
// 标题右侧说明。
@property (nonatomic, strong) UILabel *scopeLabel;
// 分隔线。
@property (nonatomic, strong) UIView *separator;
@end

@implementation TSDialTimeStyleView

#pragma mark - 生命周期

// 根据实际容器宽度布局，彩虹入口不换行。
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.heading.frame = CGRectMake(0, 17, width, 20);
    self.scopeLabel.frame = CGRectMake(width - 115, 17, 115, 20);
    self.timeSwitch.transform = CGAffineTransformMakeScale(0.6, 0.6);
    self.timeSwitch.center = CGPointMake(width - 16, 27);
    if (self.state.draftType == TSDialDraftTypeDanMu) {
        self.scopeLabel.frame = CGRectMake(width - 110, 17, 70, 20);
    }
    self.styleScroll.frame = CGRectMake(0, 50, width, 72);
    CGFloat cardWidth = (width - 24) / 4;
    for (NSUInteger index = 0; index < self.styleButtons.count; index++) {
        UIButton *button = self.styleButtons[index];
        button.frame = CGRectMake(index * (cardWidth + 8), 0, cardWidth, 72);
        UIImageView *sample = [button viewWithTag:100];
        UILabel *caption = [button viewWithTag:101];
        sample.frame = CGRectMake(10, 10, cardWidth - 20, 32);
        caption.frame = CGRectMake(0, 46, cardWidth, 18);
    }
    self.styleScroll.contentSize = CGSizeMake(MAX(width, self.styleButtons.count * (cardWidth + 8) - 8), 72);
    self.colorLabel.frame = CGRectMake(0, 138, 60, 28);
    CGFloat spacing = width < 320 ? 27 : 32;
    CGFloat diameter = width < 320 ? 20 : 22;
    CGFloat start = width - spacing * 7 + (spacing - diameter) / 2;
    for (NSUInteger index = 0; index < self.colorButtons.count; index++) {
        UIButton *button = self.colorButtons[index];
        button.frame = CGRectMake(start + index * spacing - 4, 133, diameter + 8, 38);
        UIView *dot = [button viewWithTag:102];
        dot.frame = CGRectMake(4, (38 - diameter) / 2, diameter, diameter);
        dot.layer.cornerRadius = diameter / 2;
        UIView *ring = [button viewWithTag:103];
        ring.frame = CGRectInset(dot.frame, -3.5, -3.5);
        ring.layer.cornerRadius = CGRectGetWidth(ring.bounds) / 2;
    }
    self.separator.frame = CGRectMake(0, self.preferredHeight - 1, width, 1);
}

#pragma mark - 公开方法

// 公用 View 只读取状态，通过事件交给宿主处理选择。
- (void)configureWithState:(TSDialEditorState *)state
               constraint:(TSCustomDialStyleConstraint *)constraint
                   images:(NSDictionary<NSNumber *,UIImage *> *)images {
    self.state = state;
    self.constraint = constraint;
    self.images = images;
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    BOOL danMu = state.draftType == TSDialDraftTypeDanMu;
    self.heading = [TSDialEditorAppearance heading:danMu ? 3 : 2 title:@"时间样式"];
    [self addSubview:self.heading];
    [self addSubview:self.styleScroll];
    [self addSubview:self.colorLabel];
    [self addSubview:self.scopeLabel];
    [self addSubview:self.timeSwitch];
    [self addSubview:self.separator];
    self.scopeLabel.text = danMu ? @"显示时间" : @"所有背景共用";
    self.scopeLabel.hidden = !danMu && state.draftType != TSDialDraftTypeMultipleImage;
    self.timeSwitch.hidden = !danMu;
    self.timeSwitch.on = state.showsTime;
    self.styleScroll.hidden = !state.showsTime;
    self.colorLabel.hidden = !state.showsTime || !constraint.allowColorTint;
    [self rebuildStyles];
    [self rebuildColors];
    [self setNeedsLayout];
}

// 关闭时间只保留带开关的标题。
- (CGFloat)preferredHeight {
    return !self.state.showsTime ? 56 : self.constraint.allowColorTint ? 185 : 142;
}

#pragma mark - 私有方法

// 样式卡使用真实 SDK 图片，选择时回传真实样式 ID。
- (void)rebuildStyles {
    for (UIView *subview in self.styleScroll.subviews) {
        [subview removeFromSuperview];
    }
    self.styleButtons = [NSMutableArray array];
    NSArray *captions = @[@"经典", @"纤细", @"叠字", @"数字"];
    for (TSCustomDialStyleOption *option in self.constraint.styles) {
        BOOL selected = option.style == self.state.timeStyle;
        UIButton *button = [TSDialEditorAppearance button:@"" primary:NO];
        button.tag = option.style;
        button.layer.cornerRadius = 11;
        button.backgroundColor = [TSDialEditorAppearance color:selected ? 0xFFF6F1 : 0xF3F5EE];
        button.layer.borderColor = [TSDialEditorAppearance color:selected ? 0xF16D43 : 0xE7E9E2].CGColor;
        button.layer.borderWidth = selected ? 1.5 : 1;
        UIImageView *sample = [[UIImageView alloc] initWithImage:self.images[@(option.style)]];
        if (self.constraint.allowColorTint) {
            sample.image = [sample.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            sample.tintColor = [TSDialEditorAppearance color:0x4B5844];
        }
        sample.contentMode = UIViewContentModeScaleAspectFit;
        sample.tag = 100;
        NSUInteger index = self.styleButtons.count;
        NSString *title = index < captions.count ? captions[index] : [NSString stringWithFormat:@"样式 %lu", index + 1];
        UILabel *caption = [TSDialEditorAppearance label:title size:10 color:selected ? 0xBC7050 : 0x9B9E92];
        caption.tag = 101;
        caption.textAlignment = NSTextAlignmentCenter;
        button.accessibilityLabel = title;
        button.accessibilityTraits = UIAccessibilityTraitButton | (selected ? UIAccessibilityTraitSelected : 0);
        [button addSubview:sample];
        [button addSubview:caption];
        [button addTarget:self action:@selector(selectStyle:) forControlEvents:UIControlEventTouchUpInside];
        [self.styleScroll addSubview:button];
        [self.styleButtons addObject:button];
    }
}

// 最后一个按钮只绘制彩虹圆点，透明扩大点击范围。
- (void)rebuildColors {
    self.colorButtons = [NSMutableArray array];
    NSArray *colors = @[@"FFFFFF", @"263528", @"F5E7B4", @"FFB287", @"D8EDBC", @"C7E5EF"];
    NSArray *names = @[@"白色", @"墨黑", @"奶油", @"杏橙", @"浅绿", @"淡蓝", @"自定义时间颜色"];
    for (NSUInteger index = 0; index < 7; index++) {
        BOOL custom = index == 6;
        BOOL selected = custom ? self.state.customTimeColor :
            !self.state.customTimeColor && [self.state.timeColor isEqualToString:colors[index]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        button.accessibilityLabel = names[index];
        button.accessibilityTraits = UIAccessibilityTraitButton | (selected ? UIAccessibilityTraitSelected : 0);
        UIView *dot = custom ? [[UIImageView alloc] initWithImage:[TSDialEditorAppearance colorWheel]] :
            [[UIView alloc] init];
        dot.tag = 102;
        dot.userInteractionEnabled = NO;
        if (!custom) {
            dot.backgroundColor = [TSDialEditorAppearance colorFromHex:colors[index]];
            dot.layer.borderWidth = 0.5;
            dot.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.07].CGColor;
        }
        UIView *ring = [[UIView alloc] init];
        ring.tag = 103;
        ring.userInteractionEnabled = NO;
        ring.layer.borderWidth = selected ? 1 : 0;
        ring.layer.borderColor = [TSDialEditorAppearance color:0xAAB29E].CGColor;
        [button addSubview:ring];
        [button addSubview:dot];
        button.hidden = self.colorLabel.hidden;
        [button addTarget:self action:@selector(selectColor:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.colorButtons addObject:button];
    }
}

// 样式选择仅通知宿主。
- (void)selectStyle:(UIButton *)sender {
    if (self.onStyleSelected) {
        self.onStyleSelected(sender.tag);
    }
}

// 自定义选色和预设选色使用不同事件。
- (void)selectColor:(UIButton *)sender {
    NSArray *colors = @[@"FFFFFF", @"263528", @"F5E7B4", @"FFB287", @"D8EDBC", @"C7E5EF"];
    if (sender.tag == 6) {
        if (self.onCustomColorRequested) {
            self.onCustomColorRequested();
        }
    } else if (self.onColorSelected && sender.tag >= 0 && sender.tag < colors.count) {
        self.onColorSelected(colors[sender.tag]);
    }
}

// 时间开关不清空之前的样式或位置。
- (void)toggleTime:(UISwitch *)sender {
    if (self.onVisibilityChanged) {
        self.onVisibilityChanged(sender.on);
    }
}

#pragma mark - 属性懒加载

// 样式多于四个时横向查看。
- (UIScrollView *)styleScroll {
    if (!_styleScroll) {
        _styleScroll = [[UIScrollView alloc] init];
        _styleScroll.showsHorizontalScrollIndicator = NO;
    }
    return _styleScroll;
}

// 同行左侧标签。
- (UILabel *)colorLabel {
    if (!_colorLabel) {
        _colorLabel = [TSDialEditorAppearance label:@"时间颜色" size:12 color:0x848C7A];
    }
    return _colorLabel;
}

// 标题旁的作用域说明。
- (UILabel *)scopeLabel {
    if (!_scopeLabel) {
        _scopeLabel = [TSDialEditorAppearance label:@"" size:10 color:0x93958E];
        _scopeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _scopeLabel;
}

// 弹幕专用可见开关。
- (UISwitch *)timeSwitch {
    if (!_timeSwitch) {
        _timeSwitch = [[UISwitch alloc] init];
        _timeSwitch.onTintColor = [TSDialEditorAppearance color:0x849475];
        [_timeSwitch addTarget:self action:@selector(toggleTime:) forControlEvents:UIControlEventValueChanged];
    }
    return _timeSwitch;
}

// 区块间细线。
- (UIView *)separator {
    if (!_separator) {
        _separator = [[UIView alloc] init];
        _separator.backgroundColor = [TSDialEditorAppearance color:0xE9EAE4];
    }
    return _separator;
}

@end
