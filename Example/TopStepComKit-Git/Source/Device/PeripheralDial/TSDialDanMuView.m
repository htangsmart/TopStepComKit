//
//  TSDialDanMuView.m
//  TopStepComKit_Example
//

#import "TSDialDanMuView.h"
#import "TSDialEditorState.h"
#import "TSDialEditorAppearance.h"

@interface TSDialDanMuView () <UITextFieldDelegate>
// 当前展示状态。
@property (nonatomic, strong) TSDialEditorState *state;
// 文字输入与计数。
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *countLabel;
// 根据宽度重新排版。
@property (nonatomic, assign) CGFloat renderedWidth;
@end

@implementation TSDialDanMuView

#pragma mark - 生命周期

// 只有宽度变化才重建，输入过程中保留键盘。
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.renderedWidth != CGRectGetWidth(self.bounds)) {
        [self renderControls];
    }
}

#pragma mark - 公开方法

// 仅选中条目变化时由宿主重新配置。
- (void)configureWithState:(TSDialEditorState *)state {
    self.state = state;
    [self renderControls];
}

#pragma mark - 私有方法

// 组装文字、方向、速度、字号、高度、选色与 GIF。
- (void)renderControls {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (!self.state || width <= 0) {
        return;
    }
    self.renderedWidth = width;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *line = self.state.textItems[self.state.selectedText];
    UIView *heading = [TSDialEditorAppearance heading:2 title:@"弹幕内容"];
    heading.frame = CGRectMake(0, 17, width, 20);
    [self addSubview:heading];
    UIButton *add = [self actionButton:@"＋ 添加一条" frame:CGRectMake(width - 88, 12, 88, 30) action:@selector(addText)];
    add.enabled = self.state.textItems.count < 3;
    add.alpha = add.enabled ? 1 : 0.35;
    for (NSUInteger index = 0; index < self.state.textItems.count; index++) {
        UIButton *chip = [self actionButton:[NSString stringWithFormat:@"弹幕 %lu", index + 1]
                                     frame:CGRectMake(index * 74, 50, 68, 29) action:@selector(selectText:)];
        chip.tag = index;
        chip.backgroundColor = [TSDialEditorAppearance color:index == self.state.selectedText ? 0xFFF0E8 : 0xF4F5EE];
        chip.layer.cornerRadius = 7;
    }
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 90, width, 42)];
    self.textField.backgroundColor = [TSDialEditorAppearance color:0xFAFAF8];
    self.textField.layer.borderColor = [TSDialEditorAppearance color:0xE9EAE4].CGColor;
    self.textField.layer.borderWidth = 1;
    self.textField.layer.cornerRadius = 11;
    self.textField.font = [UIFont systemFontOfSize:13];
    self.textField.text = line[@"text"];
    self.textField.placeholder = @"写下一句想戴在腕上的话";
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    [self.textField addTarget:self action:@selector(changeText) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.textField];
    if (self.state.textItems.count > 1) {
        [self actionButton:@"删除当前弹幕" frame:CGRectMake(0, 135, 100, 24) action:@selector(removeText)];
    } else {
        UILabel *hint = [TSDialEditorAppearance label:@"文字将转换为弹幕图片" size:10 color:0x93958E];
        hint.frame = CGRectMake(0, 136, width - 70, 20);
        [self addSubview:hint];
    }
    self.countLabel = [TSDialEditorAppearance label:[NSString stringWithFormat:@"%lu / 40", [line[@"text"] length]]
                                                 size:10 color:0x93958E];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.frame = CGRectMake(width - 65, 136, 65, 20);
    [self addSubview:self.countLabel];
    UILabel *directionLabel = [TSDialEditorAppearance label:@"滚动方向" size:12 color:0x252823];
    directionLabel.frame = CGRectMake(0, 171, 80, 32);
    [self addSubview:directionLabel];
    UISegmentedControl *direction = [[UISegmentedControl alloc] initWithItems:@[@"← 向左", @"向右 →"]];
    direction.frame = CGRectMake(width - 169, 171, 169, 32);
    direction.selectedSegmentIndex = [line[@"right"] boolValue] ? 1 : 0;
    direction.tintColor = [TSDialEditorAppearance color:0x849475];
    [direction addTarget:self action:@selector(changeDirection:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:direction];
    NSArray *fields = @[@[@"speed", @"速度", @20, @140], @[@"size", @"字号", @14, @30],
                         @[@"position", @"高度", @25, @80]];
    for (NSUInteger index = 0; index < fields.count; index++) {
        NSArray *field = fields[index];
        CGFloat top = 215 + index * 38;
        UILabel *label = [TSDialEditorAppearance label:field[1] size:11 color:0x8A9381];
        label.frame = CGRectMake(0, top, 38, 30);
        [self addSubview:label];
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(47, top, width - 94, 30)];
        slider.minimumValue = [field[2] floatValue];
        slider.maximumValue = [field[3] floatValue];
        slider.value = [line[field[0]] floatValue];
        slider.accessibilityIdentifier = field[0];
        slider.tintColor = [TSDialEditorAppearance color:0xF16D43];
        slider.tag = index;
        [slider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:slider];
        UILabel *output = [TSDialEditorAppearance label:[NSString stringWithFormat:@"%@%@", line[field[0]], index == 2 ? @"%" : @""]
                                                 size:11 color:0x8A9381];
        output.tag = 200 + index;
        output.textAlignment = NSTextAlignmentRight;
        output.frame = CGRectMake(width - 42, top, 42, 30);
        [self addSubview:output];
    }
    [self renderColorAndGIF:line];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 441, width, 1)];
    separator.backgroundColor = [TSDialEditorAppearance color:0xE9EAE4];
    [self addSubview:separator];
}

// 弹幕颜色使用当前色圆点加“选择颜色”入口。
- (void)renderColorAndGIF:(NSDictionary *)line {
    CGFloat width = CGRectGetWidth(self.bounds);
    UILabel *colorLabel = [TSDialEditorAppearance label:@"文字颜色" size:12 color:0x252823];
    colorLabel.frame = CGRectMake(0, 337, 100, 35);
    [self addSubview:colorLabel];
    UIButton *colorButton = [self actionButton:@"选择颜色 ⌃" frame:CGRectMake(width - 104, 337, 104, 35)
                                      action:@selector(chooseColor)];
    colorButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIView *swatch = [[UIView alloc] initWithFrame:CGRectMake(0, 6, 24, 24)];
    swatch.backgroundColor = [TSDialEditorAppearance colorFromHex:line[@"color"]];
    swatch.layer.cornerRadius = 12;
    swatch.layer.borderWidth = 0.5;
    swatch.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    swatch.userInteractionEnabled = NO;
    [colorButton addSubview:swatch];
    UILabel *gifLabel = [TSDialEditorAppearance label:@"关联 GIF  可选" size:12 color:0x252823];
    gifLabel.frame = CGRectMake(0, 386, 105, 34);
    [self addSubview:gifLabel];
    BOOL hasGIF = [line[@"gif"] length] > 0;
    if (hasGIF) {
        [self actionButton:@"移除" frame:CGRectMake(width - 152, 386, 48, 34) action:@selector(removeGIF)];
    }
    UIButton *gif = [self actionButton:hasGIF ? @"＋ 替换 GIF" : @"＋ 添加 GIF"
                                frame:CGRectMake(width - 97, 386, 97, 34) action:@selector(chooseGIF)];
    gif.layer.borderWidth = 1;
    gif.layer.borderColor = [TSDialEditorAppearance color:0xE2E4DB].CGColor;
    gif.layer.cornerRadius = 7;
}

// 轻量文字操作按钮。
- (UIButton *)actionButton:(NSString *)title frame:(CGRect)frame action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:11];
    button.tintColor = [TSDialEditorAppearance color:0xA96D4C];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

// 输入法组词完成后限制长度，避免截断组合字符。
- (void)changeText {
    if (self.textField.markedTextRange) {
        return;
    }
    NSString *text = self.textField.text ?: @"";
    while (text.length > 40) {
        NSRange last = [text rangeOfComposedCharacterSequenceAtIndex:text.length - 1];
        text = [text substringToIndex:last.location];
    }
    self.textField.text = text;
    self.countLabel.text = [NSString stringWithFormat:@"%lu / 40", text.length];
    if (self.onValueChanged) {
        self.onValueChanged(@"text", text);
    }
}

// 速度步进为 10，字号和高度步进为 1。
- (void)changeSlider:(UISlider *)sender {
    NSInteger value = sender.tag == 0 ? lround(sender.value / 10) * 10 : lround(sender.value);
    sender.value = value;
    UILabel *output = (UILabel *)[self viewWithTag:200 + sender.tag];
    output.text = [NSString stringWithFormat:@"%ld%@", (long)value, sender.tag == 2 ? @"%" : @""];
    if (self.onValueChanged) {
        self.onValueChanged(sender.accessibilityIdentifier, @(value));
    }
}

// 方向映射成独立字段。
- (void)changeDirection:(UISegmentedControl *)sender {
    if (self.onValueChanged) {
        self.onValueChanged(@"right", @(sender.selectedSegmentIndex == 1));
    }
}

// 选中一条弹幕。
- (void)selectText:(UIButton *)sender {
    if (self.onSelectText) {
        self.onSelectText(sender.tag);
    }
}

// 添加弹幕。
- (void)addText {
    if (self.onAddText) {
        self.onAddText();
    }
}

// 删除当前弹幕。
- (void)removeText {
    if (self.onRemoveText) {
        self.onRemoveText();
    }
}

// 请求颜色选择器。
- (void)chooseColor {
    if (self.onChooseColor) {
        self.onChooseColor();
    }
}

// 请求 GIF 文件选择器。
- (void)chooseGIF {
    if (self.onChooseGIF) {
        self.onChooseGIF();
    }
}

// 移除当前 GIF。
- (void)removeGIF {
    if (self.onRemoveGIF) {
        self.onRemoveGIF();
    }
}

#pragma mark - UITextFieldDelegate

// 完成输入收键盘。
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
