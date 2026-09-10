//
//  TSDialMaterialView.m
//  TopStepComKit_Example
//

#import "TSDialMaterialView.h"
#import "TSDialEditorState.h"
#import "TSDialEditorAppearance.h"

@interface TSDialMaterialView ()
// 只读展示输入。
@property (nonatomic, strong) TSDialEditorState *state;
@property (nonatomic, copy) NSDictionary *limits;
@property (nonatomic, copy) NSArray<UIImage *> *thumbnails;
// 当前内容节点。
@property (nonatomic, strong) UIView *heading;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIView *body;
@property (nonatomic, strong) UIView *separator;
// 视频拖动中只更新数值，不重建滑杆。
@property (nonatomic, strong) UISlider *startSlider;
@property (nonatomic, strong) UISlider *endSlider;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UILabel *clipLabel;
@end

@implementation TSDialMaterialView

#pragma mark - 生命周期

// 宽度改变才重建素材布局。
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    self.heading.frame = CGRectMake(0, 17, width, 20);
    self.countLabel.frame = CGRectMake(width - 90, 17, 90, 20);
    BOOL widthChanged = CGRectGetWidth(self.body.bounds) != width;
    self.body.frame = CGRectMake(0, 50, width, self.preferredHeight - 69);
    self.separator.frame = CGRectMake(0, self.preferredHeight - 1, width, 1);
    if (widthChanged) {
        [self renderBody];
    }
}

#pragma mark - 公开方法

// 根据类型加载当前编辑器实际需要的控件。
- (void)configureWithState:(TSDialEditorState *)state limits:(NSDictionary *)limits thumbnails:(NSArray<UIImage *> *)thumbnails {
    self.state = state;
    self.limits = limits;
    self.thumbnails = thumbnails;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    NSString *title = state.draftType == TSDialDraftTypeMultipleImage ? @"照片与顺序" :
        state.draftType == TSDialDraftTypeVideo ? @"视频片段" : @"表盘背景";
    self.heading = [TSDialEditorAppearance heading:1 title:title];
    self.countLabel = [TSDialEditorAppearance label:@"" size:10 color:0x93958E];
    self.countLabel.textAlignment = NSTextAlignmentRight;
    self.countLabel.text = state.draftType == TSDialDraftTypeMultipleImage ?
        [NSString stringWithFormat:@"%lu / %@ 张", state.images.count, limits[@"maxImages"]] :
        state.draftType == TSDialDraftTypeVideo ? [NSString stringWithFormat:@"%.1f 秒", state.videoEnd - state.videoStart] : @"1 张照片";
    self.body = [[UIView alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(self.bounds), self.preferredHeight - 69)];
    self.separator = [[UIView alloc] init];
    self.separator.backgroundColor = [TSDialEditorAppearance color:0xE9EAE4];
    for (UIView *view in @[self.heading, self.countLabel, self.body, self.separator]) {
        [self addSubview:view];
    }
    [self renderBody];
    [self setNeedsLayout];
}

// 素材区高度与原型结构相符。
- (CGFloat)preferredHeight {
    switch (self.state.draftType) {
        case TSDialDraftTypeMultipleImage: return 254;
        case TSDialDraftTypeVideo: return 340;
        default: return 138;
    }
}

#pragma mark - 私有方法

// 局部重建不影响外部滚动容器与键盘。
- (void)renderBody {
    for (UIView *view in self.body.subviews) {
        [view removeFromSuperview];
    }
    if (CGRectGetWidth(self.body.bounds) <= 0 || self.state.images.count == 0) {
        return;
    }
    if (self.state.draftType == TSDialDraftTypeMultipleImage) {
        [self renderAlbum];
    } else {
        [self renderSingleMaterial];
        if (self.state.draftType == TSDialDraftTypeVideo) {
            [self renderVideoControls];
        }
    }
}

// 小操作按钮共用外观。
- (UIButton *)smallButton:(NSString *)title frame:(CGRect)frame action:(SEL)action {
    UIButton *button = [TSDialEditorAppearance button:title primary:NO];
    button.frame = frame;
    button.backgroundColor = UIColor.whiteColor;
    button.titleLabel.font = [UIFont systemFontOfSize:10];
    button.layer.cornerRadius = 7;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.body addSubview:button];
    return button;
}

// 照片和视频共用素材摘要。
- (void)renderSingleMaterial {
    CGFloat width = CGRectGetWidth(self.body.bounds);
    BOOL video = self.state.draftType == TSDialDraftTypeVideo;
    NSDictionary *record = self.state.images.firstObject;
    UIImageView *thumbnail = [[UIImageView alloc] initWithImage:record[@"image"]];
    thumbnail.frame = CGRectMake(0, 0, 59, 69);
    thumbnail.layer.cornerRadius = 11;
    thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    thumbnail.clipsToBounds = YES;
    [self.body addSubview:thumbnail];
    UILabel *name = [TSDialEditorAppearance label:video ? self.state.videoName : record[@"name"] size:12 color:0x252823];
    name.frame = CGRectMake(70, 0, width - 140, 18);
    UILabel *description = [TSDialEditorAppearance label:video ? @"本机视频 · 可循环预览选段" : @"已按表盘比例填充"
                                                   size:10 color:0x93958E];
    description.frame = CGRectMake(70, 22, width - 130, 17);
    [self.body addSubview:name];
    [self.body addSubview:description];
    CGFloat buttonWidth = video ? 76 : MIN(76, (width - 142) / 2);
    [self smallButton:video ? @"替换视频" : @"替换照片" frame:CGRectMake(70, 40, buttonWidth, 29) action:@selector(replaceMaterial)];
    if (!video) {
        [self smallButton:@"调整画面" frame:CGRectMake(77 + buttonWidth, 40, buttonWidth, 29) action:@selector(cropMaterial)];
        UIButton *gallery = [self smallButton:@"背景库" frame:CGRectMake(width - 58, 0, 58, 69) action:@selector(replaceMaterial)];
        gallery.layer.cornerRadius = 11;
        gallery.tintColor = [TSDialEditorAppearance color:0x8B9481];
        gallery.layer.borderWidth = 0;
        CAShapeLayer *border = [CAShapeLayer layer];
        border.frame = gallery.bounds;
        border.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(gallery.bounds, 0.5, 0.5) cornerRadius:11].CGPath;
        border.fillColor = UIColor.clearColor.CGColor;
        border.strokeColor = [TSDialEditorAppearance color:0xCBD0BD].CGColor;
        border.lineDashPattern = @[@3, @2];
        [gallery.layer addSublayer:border];
    }
}

// 相册按顺序编辑，边界操作直接禁用。
- (void)renderAlbum {
    CGFloat width = CGRectGetWidth(self.body.bounds);
    UIScrollView *strip = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, 81)];
    strip.showsHorizontalScrollIndicator = NO;
    [self.body addSubview:strip];
    for (NSUInteger index = 0; index < self.state.images.count; index++) {
        NSDictionary *record = self.state.images[index];
        UIButton *image = [UIButton buttonWithType:UIButtonTypeCustom];
        image.frame = CGRectMake(index * 70, 0, 63, 76);
        image.tag = index;
        image.layer.cornerRadius = 10;
        image.clipsToBounds = YES;
        image.layer.borderWidth = index == self.state.selectedImage ? 2 : 0;
        image.layer.borderColor = [TSDialEditorAppearance color:0xF16D43].CGColor;
        [image setImage:record[@"image"] forState:UIControlStateNormal];
        image.imageView.contentMode = UIViewContentModeScaleAspectFill;
        image.accessibilityLabel = [NSString stringWithFormat:@"预览第 %lu 张：%@", index + 1, record[@"name"]];
        [image addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
        [strip addSubview:image];
        UIButton *remove = [UIButton buttonWithType:UIButtonTypeCustom];
        remove.frame = CGRectMake(index * 70 + 39, 1, 23, 23);
        remove.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
        remove.layer.cornerRadius = 11.5;
        remove.tag = index;
        [remove setTitle:@"×" forState:UIControlStateNormal];
        remove.accessibilityLabel = [NSString stringWithFormat:@"删除第 %lu 张", index + 1];
        [remove addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [strip addSubview:remove];
        UILabel *number = [TSDialEditorAppearance label:[NSString stringWithFormat:@"%lu", index + 1] size:9 color:0x252823];
        number.frame = CGRectMake(index * 70 + 6, 55, 17, 16);
        number.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85];
        number.textAlignment = NSTextAlignmentCenter;
        [strip addSubview:number];
    }
    UIButton *add = [TSDialEditorAppearance button:@"＋\n添加照片" primary:NO];
    add.titleLabel.numberOfLines = 2;
    add.titleLabel.textAlignment = NSTextAlignmentCenter;
    add.titleLabel.font = [UIFont systemFontOfSize:10];
    add.frame = CGRectMake(self.state.images.count * 70, 0, 58, 76);
    add.enabled = self.state.images.count < [self.limits[@"maxImages"] unsignedIntegerValue];
    add.alpha = add.enabled ? 1 : 0.35;
    [add addTarget:self action:@selector(addImages) forControlEvents:UIControlEventTouchUpInside];
    [strip addSubview:add];
    strip.contentSize = CGSizeMake(CGRectGetMaxX(add.frame), 81);
    [strip scrollRectToVisible:CGRectMake(self.state.selectedImage * 70, 0, 63, 76) animated:NO];
    UILabel *selection = [TSDialEditorAppearance label:[NSString stringWithFormat:@"第 %lu 张 · %@",
        self.state.selectedImage + 1, self.state.images[self.state.selectedImage][@"name"]] size:9 color:0x93958E];
    selection.frame = CGRectMake(0, 86, MAX(40, width - 190), 29);
    [self.body addSubview:selection];
    UIButton *before = [self smallButton:@"前移" frame:CGRectMake(width - 180, 86, 55, 29) action:@selector(moveBefore)];
    UIButton *after = [self smallButton:@"后移" frame:CGRectMake(width - 118, 86, 55, 29) action:@selector(moveAfter)];
    before.enabled = self.state.selectedImage > 0;
    after.enabled = self.state.selectedImage + 1 < self.state.images.count;
    before.alpha = before.enabled ? 1 : 0.35;
    after.alpha = after.enabled ? 1 : 0.35;
    UIButton *crop = [self smallButton:@"" frame:CGRectMake(width - 56, 86, 56, 29) action:@selector(cropMaterial)];
    [crop setImage:[TSDialEditorAppearance icon:@"crop"] forState:UIControlStateNormal];
    crop.imageEdgeInsets = UIEdgeInsetsMake(7, 20, 7, 20);
    crop.accessibilityLabel = @"调整当前照片";
    UILabel *intervalLabel = [TSDialEditorAppearance label:@"轮播间隔" size:12 color:0x252823];
    intervalLabel.frame = CGRectMake(0, 130, 80, 32);
    [self.body addSubview:intervalLabel];
    UISegmentedControl *interval = [[UISegmentedControl alloc] initWithItems:@[@"3 秒", @"5 秒", @"10 秒"]];
    interval.frame = CGRectMake(width - 192, 130, 192, 32);
    interval.selectedSegmentIndex = [@[@3, @5, @10] indexOfObject:@(self.state.interval)];
    interval.tintColor = [TSDialEditorAppearance color:0x849475];
    [interval addTarget:self action:@selector(changeInterval:) forControlEvents:UIControlEventValueChanged];
    [self.body addSubview:interval];
    UILabel *hint = [TSDialEditorAppearance label:@"每张照片按顺序播放，时间样式统一应用。" size:10 color:0x959B8B];
    hint.frame = CGRectMake(0, 173, width, 18);
    [self.body addSubview:hint];
}

// 视频片段保留原型的开始、结束双滑杆。
- (void)renderVideoControls {
    CGFloat width = CGRectGetWidth(self.body.bounds);
    UIView *filmstrip = [[UIView alloc] initWithFrame:CGRectMake(0, 83, width, 42)];
    filmstrip.layer.cornerRadius = 8;
    filmstrip.clipsToBounds = YES;
    filmstrip.layer.borderWidth = 2;
    filmstrip.layer.borderColor = [TSDialEditorAppearance color:0xE99468].CGColor;
    for (NSUInteger index = 0; index < 7; index++) {
        UIImage *frame = index < self.thumbnails.count ? self.thumbnails[index] : self.state.images.firstObject[@"image"];
        UIImageView *image = [[UIImageView alloc] initWithImage:frame];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
        image.frame = CGRectMake(index * width / 7, 0, width / 7, 42);
        [filmstrip addSubview:image];
    }
    [self.body addSubview:filmstrip];
    UILabel *title = [TSDialEditorAppearance label:@"选取片段" size:10 color:0x93958E];
    title.frame = CGRectMake(0, 133, 70, 20);
    [self.body addSubview:title];
    self.clipLabel = [TSDialEditorAppearance label:@"" size:10 color:0x93958E];
    self.clipLabel.textAlignment = NSTextAlignmentRight;
    self.clipLabel.frame = CGRectMake(width - 150, 133, 150, 20);
    [self.body addSubview:self.clipLabel];
    self.startSlider = [[UISlider alloc] init];
    self.endSlider = [[UISlider alloc] init];
    self.startSlider.minimumValue = 0;
    self.startSlider.maximumValue = MAX(0.1, self.state.videoDuration - 0.2);
    self.endSlider.minimumValue = 0.2;
    self.endSlider.maximumValue = MAX(0.2, self.state.videoDuration);
    self.startSlider.value = self.state.videoStart;
    self.endSlider.value = self.state.videoEnd;
    NSArray *sliders = @[self.startSlider, self.endSlider];
    for (NSUInteger index = 0; index < sliders.count; index++) {
        UISlider *slider = sliders[index];
        slider.frame = CGRectMake(46, 158 + index * 38, width - 93, 32);
        slider.tintColor = [TSDialEditorAppearance color:0xF16D43];
        slider.enabled = self.state.videoURL != nil;
        [slider addTarget:self action:@selector(changeTrim:) forControlEvents:UIControlEventValueChanged];
        UILabel *label = [TSDialEditorAppearance label:index ? @"结束" : @"开始" size:11 color:0x8A9381];
        label.frame = CGRectMake(0, 158 + index * 38, 40, 32);
        [self.body addSubview:label];
        [self.body addSubview:slider];
    }
    self.startLabel = [TSDialEditorAppearance label:@"" size:10 color:0x8A9381];
    self.endLabel = [TSDialEditorAppearance label:@"" size:10 color:0x8A9381];
    self.startLabel.frame = CGRectMake(width - 40, 158, 40, 32);
    self.endLabel.frame = CGRectMake(width - 40, 196, 40, 32);
    self.startLabel.textAlignment = self.endLabel.textAlignment = NSTextAlignmentRight;
    [self.body addSubview:self.startLabel];
    [self.body addSubview:self.endLabel];
    UILabel *hint = [TSDialEditorAppearance label:[NSString stringWithFormat:@"当前设备：片段最长 %@ 秒。", self.limits[@"maxDuration"]]
                                           size:10 color:0x959B8B];
    hint.frame = CGRectMake(0, 244, width, 22);
    [self.body addSubview:hint];
    [self updateTrimLabels];
}

// 根据操作端维护有效区间和设备时长上限。
- (void)changeTrim:(UISlider *)sender {
    NSTimeInterval start = round(self.startSlider.value * 10) / 10;
    NSTimeInterval end = round(self.endSlider.value * 10) / 10;
    NSTimeInterval maximum = [self.limits[@"maxDuration"] doubleValue];
    if (sender == self.startSlider) {
        start = MIN(start, self.state.videoDuration - 0.2);
        end = MIN(self.state.videoDuration, MAX(start + 0.2, end));
        end = MIN(end, start + maximum);
    } else {
        end = MAX(0.2, end);
        start = MAX(0, MIN(start, end - 0.2));
        start = MAX(start, end - maximum);
    }
    self.startSlider.value = start;
    self.endSlider.value = end;
    [self updateTrimLabels];
    if (self.onTrimChanged) {
        self.onTrimChanged(start, end);
    }
}

// 更新时长，不销毁当前正在拖动的控件。
- (void)updateTrimLabels {
    self.startLabel.text = [NSString stringWithFormat:@"%.1fs", self.startSlider.value];
    self.endLabel.text = [NSString stringWithFormat:@"%.1fs", self.endSlider.value];
    self.clipLabel.text = [NSString stringWithFormat:@"%.1f — %.1f 秒", self.startSlider.value, self.endSlider.value];
    self.countLabel.text = [NSString stringWithFormat:@"%.1f 秒", self.endSlider.value - self.startSlider.value];
}

// 替换入口由宿主呈现选择器。
- (void)replaceMaterial {
    if (self.state.draftType == TSDialDraftTypeVideo) {
        if (self.onChooseVideo) {
            self.onChooseVideo();
        }
    } else if (self.onChoosePhotos) {
        self.onChoosePhotos(NO);
    }
}

// 添加相册照片。
- (void)addImages {
    if (self.onChoosePhotos) {
        self.onChoosePhotos(YES);
    }
}

// 重新构图当前图片。
- (void)cropMaterial {
    if (self.onCrop) {
        self.onCrop();
    }
}

// 显示一张相册图片。
- (void)selectImage:(UIButton *)sender {
    if (self.onSelectImage) {
        self.onSelectImage(sender.tag);
    }
}

// 删除一张相册图片。
- (void)deleteImage:(UIButton *)sender {
    if (self.onDeleteImage) {
        self.onDeleteImage(sender.tag);
    }
}

// 当前图片前移。
- (void)moveBefore {
    if (self.onMoveImage) {
        self.onMoveImage(-1);
    }
}

// 当前图片后移。
- (void)moveAfter {
    if (self.onMoveImage) {
        self.onMoveImage(1);
    }
}

// 间隔保留秒语义，造包阶段再转毫秒。
- (void)changeInterval:(UISegmentedControl *)sender {
    if (self.onIntervalChanged) {
        self.onIntervalChanged([@[@3, @5, @10][sender.selectedSegmentIndex] integerValue]);
    }
}

@end
