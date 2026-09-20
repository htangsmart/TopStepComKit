//
//  TSRealtimeDanMuEditorView.m
//  TopStepComKit_Example
//

#import "TSRealtimeDanMuEditorView.h"

#import "TSDialEditorAppearance.h"
#import "TSRealtimeDanMuDraft.h"
#import "TSRootVC.h"

NSString *const kTSRealtimeDanMuFieldText = @"text";
NSString *const kTSRealtimeDanMuFieldType = @"type";
NSString *const kTSRealtimeDanMuFieldFontSize = @"fontSize";
NSString *const kTSRealtimeDanMuFieldSpeed = @"speed";
NSString *const kTSRealtimeDanMuFieldAnimation = @"animation";
NSString *const kTSRealtimeDanMuFieldYCoordinate = @"yCoordinate";
NSString *const kTSRealtimeDanMuFieldColor = @"color";
NSString *const kTSRealtimeDanMuFieldPositionRandom = @"positionRandom";

/** 快捷色板，末位之后是打开共用选色器的色轮 */
static NSArray<NSNumber *> *TSRealtimeDanMuPalette(void) {
    return @[@0xFFFFFF, @0xFF6B6B, @0xFFB454, @0xFFE66D, @0x7BD88F, @0x5AC8FA, @0xA78BFA, @0xFF8AC4];
}

@interface TSRealtimeDanMuEditorView () <UITextFieldDelegate>

@property (nonatomic, copy) NSArray<TSRealtimeDanMuDraft *> *drafts;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong, nullable) TSPeripheralScreen *screen;
/** 输入过程中只更新计数，不整块重建，避免键盘被收起 */
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) CGFloat preferredHeight;
@property (nonatomic, assign) CGFloat renderedWidth;

@end

@implementation TSRealtimeDanMuEditorView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _drafts = @[];
        _selectedIndex = 0;
    }
    return self;
}

/** 只有宽度变化才重建，输入过程中保留键盘 */
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.renderedWidth != CGRectGetWidth(self.bounds)) {
        [self renderControls];
    }
}

#pragma mark - 公开方法

- (void)configureWithDrafts:(NSArray<TSRealtimeDanMuDraft *> *)drafts
              selectedIndex:(NSUInteger)index
                     screen:(TSPeripheralScreen *)screen {
    self.drafts = drafts ?: @[];
    self.selectedIndex = index;
    self.screen = screen;
    [self renderControls];
}

- (void)endTextEditing {
    [self.textField resignFirstResponder];
}

#pragma mark - 私有方法：布局工具

- (CGFloat)screenHeight {
    CGFloat height = self.screen.screenSize.height;
    return height > 0 ? height : 448;
}

/** 分节标题，第一节之前不画分割线 */
- (CGFloat)addHeading:(NSInteger)number title:(NSString *)title atY:(CGFloat)y {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (y > 0) {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, y, width, 1)];
        separator.backgroundColor = [TSDialEditorAppearance color:0xE9EAE4];
        [self addSubview:separator];
        y += 17;
    }
    UIView *heading = [TSDialEditorAppearance heading:number title:title];
    heading.frame = CGRectMake(0, y, width, 20);
    [self addSubview:heading];
    return y;
}

/** 轻量文字按钮，与弹幕表盘编辑页保持一致 */
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

/** 标签 + 滑块 + 数值的通用一行 */
- (UISlider *)addSliderRowAtY:(CGFloat)y
                        title:(NSString *)title
                      minimum:(CGFloat)minimum
                      maximum:(CGFloat)maximum
                        value:(CGFloat)value
                          tag:(NSInteger)tag
                       action:(SEL)action
                    valueText:(NSString *)valueText {
    CGFloat width = CGRectGetWidth(self.bounds);
    UILabel *label = [TSDialEditorAppearance label:title size:11 color:0x8A9381];
    label.frame = CGRectMake(0, y, 44, 30);
    [self addSubview:label];

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(50, y, width - 50 - 66, 30)];
    slider.minimumValue = minimum;
    slider.maximumValue = maximum;
    slider.value = value;
    slider.tintColor = [TSDialEditorAppearance color:0xF16D43];
    slider.tag = tag;
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];

    UILabel *output = [TSDialEditorAppearance label:valueText size:11 color:0x8A9381];
    output.font = [UIFont monospacedDigitSystemFontOfSize:11 weight:UIFontWeightRegular];
    output.textAlignment = NSTextAlignmentRight;
    output.tag = 900 + tag;
    output.frame = CGRectMake(width - 62, y, 62, 30);
    [self addSubview:output];
    return slider;
}

- (UISegmentedControl *)addSegmentAtY:(CGFloat)y items:(NSArray<NSString *> *)items
                             selected:(NSInteger)selected action:(SEL)action {
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:items];
    segment.frame = CGRectMake(0, y, CGRectGetWidth(self.bounds), 32);
    segment.selectedSegmentIndex = selected;
    segment.tintColor = [TSDialEditorAppearance color:0x849475];
    [segment addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [self addSubview:segment];
    return segment;
}

#pragma mark - 私有方法：渲染

- (void)renderControls {
    CGFloat width = CGRectGetWidth(self.bounds);
    if (width <= 0 || self.drafts.count == 0 || self.selectedIndex >= self.drafts.count) {
        return;
    }
    self.renderedWidth = width;
    for (UIView *view in [self.subviews copy]) {
        [view removeFromSuperview];
    }
    TSRealtimeDanMuDraft *draft = self.drafts[self.selectedIndex];
    CGFloat y = 0;

    y = [self renderQueueSectionAtY:y];
    y = [self renderTextSectionAtY:y draft:draft];
    y = [self renderOwnerSectionAtY:y draft:draft];
    y = [self renderAppearanceSectionAtY:y draft:draft];
    y = [self renderPositionSectionAtY:y draft:draft];
    y = [self renderAnimationSectionAtY:y draft:draft];

    self.preferredHeight = y + 8;
}

/** 01 队列：chip 选择、添加、删除 */
- (CGFloat)renderQueueSectionAtY:(CGFloat)y {
    CGFloat width = CGRectGetWidth(self.bounds);
    y = [self addHeading:1 title:TSLocalizedString(@"realtime_danmu.section.queue") atY:y];

    UIButton *add = [self actionButton:TSLocalizedString(@"realtime_danmu.queue.add")
                                 frame:CGRectMake(width - 92, y - 5, 92, 30)
                                action:@selector(addDraft)];
    add.enabled = self.drafts.count < kTSRealtimeDanMuMaxDraftCount;
    add.alpha = add.enabled ? 1 : 0.35;
    y += 32;

    for (NSUInteger index = 0; index < self.drafts.count; index++) {
        UIButton *chip = [self actionButton:[NSString stringWithFormat:@"%lu", (unsigned long)index + 1]
                                      frame:CGRectMake(index * 65, y, 60, 29)
                                     action:@selector(selectDraft:)];
        chip.tag = index;
        chip.backgroundColor = [TSDialEditorAppearance
            color:index == self.selectedIndex ? 0xFFF0E8 : 0xF4F5EE];
        chip.layer.cornerRadius = 7;
        [chip setTitle:[NSString stringWithFormat:TSLocalizedString(@"realtime_danmu.queue.item"),
                        (long)(index + 1)] forState:UIControlStateNormal];
    }
    y += 37;

    if (self.drafts.count > 1) {
        [self actionButton:TSLocalizedString(@"realtime_danmu.queue.remove")
                     frame:CGRectMake(0, y, 110, 22)
                    action:@selector(removeDraft)];
    } else {
        UILabel *hint = [TSDialEditorAppearance label:TSLocalizedString(@"realtime_danmu.queue.hint")
                                                 size:10 color:0x93958E];
        hint.frame = CGRectMake(0, y, width, 22);
        [self addSubview:hint];
    }
    return y + 30;
}

/** 02 内容：文本与 UTF-8 字节计数 */
- (CGFloat)renderTextSectionAtY:(CGFloat)y draft:(TSRealtimeDanMuDraft *)draft {
    CGFloat width = CGRectGetWidth(self.bounds);
    y = [self addHeading:2 title:TSLocalizedString(@"realtime_danmu.section.content") atY:y];
    y += 32;

    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, y, width, 42)];
    self.textField.backgroundColor = [TSDialEditorAppearance color:0xFAFAF8];
    self.textField.layer.borderColor = [TSDialEditorAppearance color:0xE9EAE4].CGColor;
    self.textField.layer.borderWidth = 1;
    self.textField.layer.cornerRadius = 11;
    self.textField.font = [UIFont systemFontOfSize:13];
    self.textField.text = draft.text;
    self.textField.placeholder = TSLocalizedString(@"realtime_danmu.content.placeholder");
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.delegate = self;
    self.textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    [self.textField addTarget:self action:@selector(changeText) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:self.textField];
    y += 49;

    UILabel *hint = [TSDialEditorAppearance label:TSLocalizedString(@"realtime_danmu.content.hint")
                                             size:10 color:0x93958E];
    hint.frame = CGRectMake(0, y, width - 110, 16);
    [self addSubview:hint];

    self.countLabel = [TSDialEditorAppearance label:@"" size:10 color:0x93958E];
    self.countLabel.font = [UIFont monospacedDigitSystemFontOfSize:10 weight:UIFontWeightRegular];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.frame = CGRectMake(width - 110, y, 110, 16);
    [self addSubview:self.countLabel];
    [self refreshCountLabel];

    return y + 24;
}

/** 03 归属：我的 / 好友 */
- (CGFloat)renderOwnerSectionAtY:(CGFloat)y draft:(TSRealtimeDanMuDraft *)draft {
    y = [self addHeading:3 title:TSLocalizedString(@"realtime_danmu.section.owner") atY:y];
    y += 32;
    [self addSegmentAtY:y
                  items:@[TSLocalizedString(@"realtime_danmu.owner.mine"),
                          TSLocalizedString(@"realtime_danmu.owner.friend")]
               selected:draft.type == TSDanMuTypeFriend ? 1 : 0
                 action:@selector(changeOwner:)];
    return y + 40;
}

/** 04 外观：颜色、字号、速度 */
- (CGFloat)renderAppearanceSectionAtY:(CGFloat)y draft:(TSRealtimeDanMuDraft *)draft {
    CGFloat width = CGRectGetWidth(self.bounds);
    y = [self addHeading:4 title:TSLocalizedString(@"realtime_danmu.section.appearance") atY:y];
    y += 32;

    UILabel *colorLabel = [TSDialEditorAppearance label:TSLocalizedString(@"realtime_danmu.appearance.color")
                                                   size:11 color:0x8A9381];
    colorLabel.frame = CGRectMake(0, y, 44, 30);
    [self addSubview:colorLabel];

    NSArray<NSNumber *> *palette = TSRealtimeDanMuPalette();
    NSString *currentHex = [TSDialEditorAppearance hexFromColor:draft.color];
    BOOL custom = YES;
    CGFloat available = width - 50;
    CGFloat spacing = MAX(4.f, (available - (CGFloat)(palette.count + 1) * 26.f) / (CGFloat)palette.count);

    for (NSUInteger index = 0; index < palette.count; index++) {
        NSString *hex = [NSString stringWithFormat:@"%06lX", (unsigned long)palette[index].unsignedIntegerValue];
        BOOL selected = [hex isEqualToString:currentHex];
        if (selected) {
            custom = NO;
        }
        UIButton *swatch = [self actionButton:@"" frame:CGRectMake(50 + index * (26 + spacing), y + 2, 26, 26)
                                       action:@selector(selectPaletteColor:)];
        swatch.tag = index;
        swatch.backgroundColor = [TSDialEditorAppearance color:palette[index].unsignedIntegerValue];
        swatch.layer.cornerRadius = 13;
        swatch.layer.borderWidth = selected ? 2 : 0.5;
        swatch.layer.borderColor = selected ? [TSDialEditorAppearance color:0xF16D43].CGColor
                                            : [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    }

    // 色轮：当前色不在快捷色板内时显示该色并描边，否则看不出自定义色是否生效
    UIButton *wheel = [self actionButton:@"" frame:CGRectMake(50 + palette.count * (26 + spacing), y + 2, 26, 26)
                                  action:@selector(chooseColor)];
    wheel.layer.cornerRadius = 13;
    wheel.clipsToBounds = NO;
    UIImageView *wheelImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    wheelImage.image = [TSDialEditorAppearance colorWheel];
    wheelImage.layer.cornerRadius = 13;
    wheelImage.clipsToBounds = YES;
    wheelImage.userInteractionEnabled = NO;
    [wheel addSubview:wheelImage];
    if (custom) {
        wheel.layer.borderWidth = 2;
        wheel.layer.borderColor = [TSDialEditorAppearance color:0xF16D43].CGColor;
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(6, 6, 14, 14)];
        dot.backgroundColor = draft.color;
        dot.layer.cornerRadius = 7;
        dot.layer.borderWidth = 1.5;
        dot.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.82].CGColor;
        dot.userInteractionEnabled = NO;
        [wheel addSubview:dot];
    }
    y += 38;

    [self addSliderRowAtY:y
                    title:TSLocalizedString(@"realtime_danmu.appearance.font_size")
                  minimum:kTSRealtimeDanMuMinFontSize
                  maximum:kTSRealtimeDanMuMaxFontSize
                    value:draft.fontSize
                      tag:0
                   action:@selector(changeFontSize:)
                valueText:[NSString stringWithFormat:@"%d px", (int)draft.fontSize]];
    y += 38;

    [self addSliderRowAtY:y
                    title:TSLocalizedString(@"realtime_danmu.appearance.speed")
                  minimum:kTSRealtimeDanMuMinSpeed
                  maximum:kTSRealtimeDanMuMaxSpeed
                    value:draft.speed
                      tag:1
                   action:@selector(changeSpeed:)
                valueText:[NSString stringWithFormat:@"%d px/s", (int)draft.speed]];
    return y + 38;
}

/** 05 位置：随机 / 指定，量程跟随真实屏幕高度 */
- (CGFloat)renderPositionSectionAtY:(CGFloat)y draft:(TSRealtimeDanMuDraft *)draft {
    y = [self addHeading:5 title:TSLocalizedString(@"realtime_danmu.section.position") atY:y];
    y += 32;

    BOOL random = [draft isRandomPosition];
    [self addSegmentAtY:y
                  items:@[TSLocalizedString(@"realtime_danmu.position.random"),
                          TSLocalizedString(@"realtime_danmu.position.fixed")]
               selected:random ? 0 : 1
                 action:@selector(changePositionMode:)];
    y += 40;

    if (!random) {
        [self addSliderRowAtY:y
                        title:TSLocalizedString(@"realtime_danmu.position.y")
                      minimum:0
                      maximum:MAX(1.f, [self screenHeight] - 1)
                        value:draft.yCoordinate
                          tag:2
                       action:@selector(changeYCoordinate:)
                    valueText:[NSString stringWithFormat:@"y = %ld", (long)draft.yCoordinate]];
        y += 38;
    }
    return y;
}

/** 06 动画：四张等宽卡片 */
- (CGFloat)renderAnimationSectionAtY:(CGFloat)y draft:(TSRealtimeDanMuDraft *)draft {
    CGFloat width = CGRectGetWidth(self.bounds);
    y = [self addHeading:6 title:TSLocalizedString(@"realtime_danmu.section.animation") atY:y];
    y += 32;

    NSArray<NSString *> *symbols = @[@"—", @"♥", @"🎂", @"🎉"];
    NSArray<NSString *> *titles = @[TSLocalizedString(@"realtime_danmu.animation.none"),
                                    TSLocalizedString(@"realtime_danmu.animation.heart"),
                                    TSLocalizedString(@"realtime_danmu.animation.birthday1"),
                                    TSLocalizedString(@"realtime_danmu.animation.birthday2")];
    CGFloat cardWidth = (width - 24) / 4;

    for (NSUInteger index = 0; index < titles.count; index++) {
        BOOL selected = (TSDanMuAnimation)index == draft.animation;
        UIButton *card = [self actionButton:@""
                                      frame:CGRectMake(index * (cardWidth + 8), y, cardWidth, 58)
                                     action:@selector(changeAnimation:)];
        card.tag = index;
        card.backgroundColor = [TSDialEditorAppearance color:selected ? 0xFFF0E8 : 0xFAFAF8];
        card.layer.cornerRadius = 11;
        card.layer.borderWidth = 1;
        card.layer.borderColor = selected ? [TSDialEditorAppearance color:0xF16D43].CGColor
                                          : [TSDialEditorAppearance color:0xE5E8DF].CGColor;

        UILabel *symbol = [TSDialEditorAppearance label:symbols[index] size:18 color:0x252823];
        symbol.textAlignment = NSTextAlignmentCenter;
        symbol.frame = CGRectMake(0, 10, cardWidth, 22);
        symbol.userInteractionEnabled = NO;
        [card addSubview:symbol];

        UILabel *name = [TSDialEditorAppearance label:titles[index] size:10
                                                color:selected ? 0x252823 : 0x8A9381];
        name.textAlignment = NSTextAlignmentCenter;
        name.frame = CGRectMake(0, 34, cardWidth, 16);
        name.userInteractionEnabled = NO;
        [card addSubview:name];
    }
    return y + 66;
}

/** 超过 128 字节时标红，宿主据此禁用发送 */
- (void)refreshCountLabel {
    if (self.selectedIndex >= self.drafts.count) {
        return;
    }
    NSUInteger bytes = [self.drafts[self.selectedIndex] textByteLength];
    BOOL over = bytes > kTSRealtimeDanMuMaxTextBytes;
    self.countLabel.text = [NSString stringWithFormat:TSLocalizedString(@"realtime_danmu.content.count"),
                            (long)bytes, (long)kTSRealtimeDanMuMaxTextBytes];
    self.countLabel.textColor = over ? [TSDialEditorAppearance color:0xD2553C]
                                     : [TSDialEditorAppearance color:0x93958E];
}

#pragma mark - 私有方法：事件

- (void)selectDraft:(UIButton *)sender {
    [self endTextEditing];
    if (self.onSelectDraft) {
        self.onSelectDraft((NSUInteger)sender.tag);
    }
}

- (void)addDraft {
    [self endTextEditing];
    if (self.onAddDraft) {
        self.onAddDraft();
    }
}

- (void)removeDraft {
    [self endTextEditing];
    if (self.onRemoveDraft) {
        self.onRemoveDraft();
    }
}

- (void)chooseColor {
    [self endTextEditing];
    if (self.onChooseColor) {
        self.onChooseColor();
    }
}

/** 输入法组词期间不处理，避免截断组合字符 */
- (void)changeText {
    if (self.textField.markedTextRange) {
        return;
    }
    [self notifyField:kTSRealtimeDanMuFieldText value:self.textField.text ?: @""];
    [self refreshCountLabel];
}

- (void)changeOwner:(UISegmentedControl *)sender {
    [self notifyField:kTSRealtimeDanMuFieldType
                value:@(sender.selectedSegmentIndex == 1 ? TSDanMuTypeFriend : TSDanMuTypeMine)];
}

/** 字号步进 2 */
- (void)changeFontSize:(UISlider *)sender {
    NSInteger value = lround(sender.value / 2) * 2;
    sender.value = value;
    [self updateSliderOutput:sender.tag text:[NSString stringWithFormat:@"%ld px", (long)value]];
    [self notifyField:kTSRealtimeDanMuFieldFontSize value:@(value)];
}

/** 速度步进 10 */
- (void)changeSpeed:(UISlider *)sender {
    NSInteger value = lround(sender.value / 10) * 10;
    sender.value = value;
    [self updateSliderOutput:sender.tag text:[NSString stringWithFormat:@"%ld px/s", (long)value]];
    [self notifyField:kTSRealtimeDanMuFieldSpeed value:@(value)];
}

- (void)changeYCoordinate:(UISlider *)sender {
    NSInteger value = lround(sender.value);
    sender.value = value;
    [self updateSliderOutput:sender.tag text:[NSString stringWithFormat:@"y = %ld", (long)value]];
    [self notifyField:kTSRealtimeDanMuFieldYCoordinate value:@(value)];
}

/** 与 Y 滑块分开上报：模式切换会增删滑块，需要宿主整块重建 */
- (void)changePositionMode:(UISegmentedControl *)sender {
    [self notifyField:kTSRealtimeDanMuFieldPositionRandom value:@(sender.selectedSegmentIndex == 0)];
}

- (void)selectPaletteColor:(UIButton *)sender {
    NSArray<NSNumber *> *palette = TSRealtimeDanMuPalette();
    if ((NSUInteger)sender.tag >= palette.count) {
        return;
    }
    [self notifyField:kTSRealtimeDanMuFieldColor
                value:[TSDialEditorAppearance color:palette[sender.tag].unsignedIntegerValue]];
}

- (void)changeAnimation:(UIButton *)sender {
    [self notifyField:kTSRealtimeDanMuFieldAnimation value:@(sender.tag)];
}

- (void)updateSliderOutput:(NSInteger)tag text:(NSString *)text {
    UILabel *output = (UILabel *)[self viewWithTag:900 + tag];
    if ([output isKindOfClass:UILabel.class]) {
        output.text = text;
    }
}

- (void)notifyField:(NSString *)field value:(id)value {
    if (self.onValueChanged) {
        self.onValueChanged(field, value);
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
