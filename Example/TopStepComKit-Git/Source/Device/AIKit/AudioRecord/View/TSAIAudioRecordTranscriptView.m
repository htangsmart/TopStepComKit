//
//  TSAIAudioRecordTranscriptView.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordTranscriptView.h"

#import "TSAIAudioRecordDraft.h"

static UIColor *TSAITranscriptColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    return [UIColor colorWithRed:red / 255.0
                           green:green / 255.0
                            blue:blue / 255.0
                           alpha:alpha];
}

@interface TSAIAudioRecordTranscriptView ()

// 转写列表视觉样式
@property (nonatomic, assign) TSAIAudioRecordTranscriptViewStyle transcriptStyle;
// 转写内容纵向容器
@property (nonatomic, strong) UIStackView *contentStackView;

@end


@implementation TSAIAudioRecordTranscriptView

#pragma mark - 生命周期

/** 使用指定样式初始化转写列表 */
- (instancetype)initWithStyle:(TSAIAudioRecordTranscriptViewStyle)style {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _transcriptStyle = style;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = UIColor.clearColor;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = YES;
        [self addSubview:self.contentStackView];
        CGFloat topInset = style == TSAIAudioRecordTranscriptViewStyleLive ? 0.0 : 14.0;
        [NSLayoutConstraint activateConstraints:@[
            [self.contentStackView.topAnchor constraintEqualToAnchor:self.contentLayoutGuide.topAnchor
                                                            constant:topInset],
            [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.contentLayoutGuide.leadingAnchor
                                                                constant:15.0],
            [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.contentLayoutGuide.trailingAnchor
                                                                 constant:-15.0],
            [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.contentLayoutGuide.bottomAnchor
                                                               constant:-15.0],
            [self.contentStackView.widthAnchor constraintEqualToAnchor:self.frameLayoutGuide.widthAnchor
                                                              constant:-30.0],
        ]];
    }
    return self;
}

#pragma mark - 公开方法

/** 使用标准化转写内容刷新列表 */
- (void)updateWithItems:(NSArray<TSAIAudioRecordTranscriptItem *> *)items
              emptyText:(NSString *)emptyText {
    for (UIView *view in self.contentStackView.arrangedSubviews.copy) {
        [self.contentStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    if (items.count == 0) {
        UILabel *emptyLabel = [self bodyLabelWithSize:12.0];
        emptyLabel.text = emptyText;
        emptyLabel.textColor = TSAITranscriptColor(156.0, 162.0, 184.0, 1.0);
        [self.contentStackView addArrangedSubview:emptyLabel];
        return;
    }
    NSMutableDictionary<NSString *, NSNumber *> *speakerIndexes = [NSMutableDictionary dictionary];
    __block NSUInteger nextSpeakerIndex = 0;
    [items enumerateObjectsUsingBlock:^(TSAIAudioRecordTranscriptItem *item,
                                        NSUInteger itemIndex,
                                        BOOL *stop) {
        (void)itemIndex;
        NSString *speakerKey = item.speakerIdentifier.length > 0
            ? item.speakerIdentifier
            : @"__unknown_speaker";
        NSNumber *speakerIndex = speakerIndexes[speakerKey];
        if (!speakerIndex) {
            speakerIndex = @(nextSpeakerIndex);
            speakerIndexes[speakerKey] = speakerIndex;
            nextSpeakerIndex += 1;
        }
        UIView *itemView = self.transcriptStyle == TSAIAudioRecordTranscriptViewStyleLive
            ? [self liveItemViewWithItem:item index:speakerIndex.unsignedIntegerValue]
            : [self resultItemViewWithItem:item index:speakerIndex.unsignedIntegerValue];
        [self.contentStackView addArrangedSubview:itemView];
    }];
    if (self.transcriptStyle == TSAIAudioRecordTranscriptViewStyleLive) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat offsetY = MAX(-self.adjustedContentInset.top,
                                  self.contentSize.height - CGRectGetHeight(self.bounds));
            [self setContentOffset:CGPointMake(0.0, offsetY) animated:YES];
        });
    }
}

#pragma mark - 私有方法

/** 创建实时转写行 */
- (UIView *)liveItemViewWithItem:(TSAIAudioRecordTranscriptItem *)item index:(NSUInteger)index {
    UIView *container = [[UIView alloc] init];
    UILabel *speakerLabel = [self speakerLabelForItem:item index:index compact:NO];
    UILabel *timeLabel = [self timeLabelForMilliseconds:item.startTimeMilliseconds fontSize:9.0];
    UILabel *bodyLabel = [self bodyLabelWithSize:13.0];
    bodyLabel.attributedText = [self bodyTextForItem:item fontSize:13.0];
    [container addSubview:speakerLabel];
    [container addSubview:timeLabel];
    [container addSubview:bodyLabel];
    [NSLayoutConstraint activateConstraints:@[
        [speakerLabel.topAnchor constraintEqualToAnchor:container.topAnchor],
        [speakerLabel.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [speakerLabel.heightAnchor constraintEqualToConstant:21.0],
        [timeLabel.leadingAnchor constraintEqualToAnchor:speakerLabel.trailingAnchor constant:7.0],
        [timeLabel.centerYAnchor constraintEqualToAnchor:speakerLabel.centerYAnchor],
        [timeLabel.trailingAnchor constraintLessThanOrEqualToAnchor:container.trailingAnchor],
        [bodyLabel.topAnchor constraintEqualToAnchor:speakerLabel.bottomAnchor constant:5.0],
        [bodyLabel.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [bodyLabel.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [bodyLabel.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
    ]];
    return container;
}

/** 创建完成态转写行 */
- (UIView *)resultItemViewWithItem:(TSAIAudioRecordTranscriptItem *)item index:(NSUInteger)index {
    UIView *container = [[UIView alloc] init];
    UILabel *avatarLabel = [self speakerLabelForItem:item index:index compact:YES];
    UILabel *timeLabel = [self timeLabelForMilliseconds:item.startTimeMilliseconds fontSize:8.0];
    UILabel *bodyLabel = [self bodyLabelWithSize:11.0];
    bodyLabel.attributedText = [self bodyTextForItem:item fontSize:11.0];
    [container addSubview:avatarLabel];
    [container addSubview:timeLabel];
    [container addSubview:bodyLabel];
    [NSLayoutConstraint activateConstraints:@[
        [avatarLabel.topAnchor constraintEqualToAnchor:container.topAnchor],
        [avatarLabel.leadingAnchor constraintEqualToAnchor:container.leadingAnchor],
        [avatarLabel.widthAnchor constraintEqualToConstant:30.0],
        [avatarLabel.heightAnchor constraintEqualToConstant:30.0],
        [timeLabel.topAnchor constraintEqualToAnchor:container.topAnchor],
        [timeLabel.leadingAnchor constraintEqualToAnchor:avatarLabel.trailingAnchor constant:9.0],
        [timeLabel.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [bodyLabel.topAnchor constraintEqualToAnchor:timeLabel.bottomAnchor constant:3.0],
        [bodyLabel.leadingAnchor constraintEqualToAnchor:timeLabel.leadingAnchor],
        [bodyLabel.trailingAnchor constraintEqualToAnchor:container.trailingAnchor],
        [bodyLabel.bottomAnchor constraintEqualToAnchor:container.bottomAnchor],
        [bodyLabel.bottomAnchor constraintGreaterThanOrEqualToAnchor:avatarLabel.bottomAnchor],
    ]];
    return container;
}

/** 创建说话人标签或头像 */
- (UILabel *)speakerLabelForItem:(TSAIAudioRecordTranscriptItem *)item
                           index:(NSUInteger)index
                         compact:(BOOL)compact {
    BOOL usesTealStyle = index % 2 == 1;
    NSString *identifier = [self displayIdentifierForItem:item fallbackIndex:index];
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightBold];
    label.textColor = usesTealStyle
        ? TSAITranscriptColor(20.0, 138.0, 112.0, 1.0)
        : TSAITranscriptColor(79.0, 123.0, 255.0, 1.0);
    label.backgroundColor = usesTealStyle
        ? TSAITranscriptColor(31.0, 200.0, 160.0, 0.11)
        : TSAITranscriptColor(79.0, 123.0, 255.0, 0.09);
    if (compact) {
        label.text = [NSString stringWithFormat:@"S%@", identifier];
        label.layer.cornerRadius = 10.0;
    } else {
        label.text = [NSString stringWithFormat:@"  Speaker %@  ", identifier];
        label.layer.cornerRadius = 10.5;
    }
    label.layer.masksToBounds = YES;
    return label;
}

/** 将 SDK 说话人标识整理为原型中的短编号 */
- (NSString *)displayIdentifierForItem:(TSAIAudioRecordTranscriptItem *)item
                         fallbackIndex:(NSUInteger)index {
    if (item.speakerIdentifier.length == 0) {
        return [NSString stringWithFormat:@"%lu", (unsigned long)index + 1];
    }
    NSMutableString *digits = [NSMutableString string];
    NSCharacterSet *decimalSet = NSCharacterSet.decimalDigitCharacterSet;
    for (NSUInteger characterIndex = 0;
         characterIndex < item.speakerIdentifier.length;
         characterIndex++) {
        unichar character = [item.speakerIdentifier characterAtIndex:characterIndex];
        if ([decimalSet characterIsMember:character]) {
            [digits appendFormat:@"%C", character];
        }
    }
    return digits.length > 0 ? digits : item.speakerIdentifier;
}

/** 创建时间标签 */
- (UILabel *)timeLabelForMilliseconds:(NSInteger)milliseconds fontSize:(CGFloat)fontSize {
    NSInteger totalSeconds = MAX(0, milliseconds / 1000);
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont monospacedDigitSystemFontOfSize:fontSize weight:UIFontWeightRegular];
    label.textColor = TSAITranscriptColor(156.0, 162.0, 184.0, 1.0);
    label.text = [NSString stringWithFormat:@"%02ld:%02ld",
                  (long)(totalSeconds / 60),
                  (long)(totalSeconds % 60)];
    return label;
}

/** 创建正文标签 */
- (UILabel *)bodyLabelWithSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular];
    label.textColor = TSAITranscriptColor(37.0, 42.0, 66.0, 1.0);
    label.numberOfLines = 0;
    return label;
}

/** 创建带实时输入光标的正文 */
- (NSAttributedString *)bodyTextForItem:(TSAIAudioRecordTranscriptItem *)item
                               fontSize:(CGFloat)fontSize {
    NSString *text = item.text ?: @"";
    if (!item.isFinal) {
        text = [text stringByAppendingString:@"▌"];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = fontSize >= 13.0 ? 2.0 : 1.0;
    NSMutableAttributedString *bodyText = [[NSMutableAttributedString alloc]
        initWithString:text
        attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:fontSize weight:UIFontWeightRegular],
            NSForegroundColorAttributeName: TSAITranscriptColor(37.0, 42.0, 66.0, 1.0),
            NSParagraphStyleAttributeName: paragraphStyle
        }];
    if (!item.isFinal && bodyText.length > 0) {
        [bodyText addAttribute:NSForegroundColorAttributeName
                         value:TSAITranscriptColor(79.0, 123.0, 255.0, 1.0)
                         range:NSMakeRange(bodyText.length - 1, 1)];
    }
    return bodyText;
}

#pragma mark - 属性懒加载 Getter

/** 创建纵向转写容器 */
- (UIStackView *)contentStackView {
    if (!_contentStackView) {
        _contentStackView = [[UIStackView alloc] init];
        _contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
        _contentStackView.axis = UILayoutConstraintAxisVertical;
        _contentStackView.spacing = self.transcriptStyle == TSAIAudioRecordTranscriptViewStyleLive
            ? 9.0
            : 12.0;
    }
    return _contentStackView;
}

@end
