//
//  TSAIQADeviceRoundCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQADeviceRoundCell.h"

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAIQABadgeLabel.h"
#import "TSAIQADeviceRound.h"
#import "TSAIQATheme.h"

static NSString * const kTSAIQADeviceStreamingCursor = @"▍";

@interface TSAIQADeviceRoundCell ()

// 卡片容器
@property (nonatomic, strong) UIView *card;
@property (nonatomic, strong) UIStackView *cardStack;

// 头部
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UILabel *identifierLabel;
@property (nonatomic, strong) TSAIQABadgeLabel *badge;

// 问题段
@property (nonatomic, strong) UIView *questionSection;
@property (nonatomic, strong) UILabel *questionTitleLabel;
@property (nonatomic, strong) UILabel *questionLabel;

// 回答段
@property (nonatomic, strong) UIView *answerSection;
@property (nonatomic, strong) UILabel *answerTitleLabel;
@property (nonatomic, strong) UILabel *answerLabel;

// 播放条
@property (nonatomic, strong) UIView *playbackStrip;
@property (nonatomic, strong) UILabel *playbackLabel;

@end

@implementation TSAIQADeviceRoundCell

#pragma mark - 生命周期

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self setupViews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 公开方法

/** 绑定轮次并刷新 */
- (void)applyRound:(TSAIQADeviceRound *)round playbackText:(NSString *)playbackText {
    self.indexLabel.text = [NSString stringWithFormat:@"第 %lu 轮", (unsigned long)round.index];
    self.identifierLabel.text = [NSString stringWithFormat:@"%@ · #%ld",
                                 round.roundIdentifier, (long)round.sequence];
    [self applyBadgeForPhase:round.phase];

    BOOL questionStreaming = (round.phase == TSAIDeviceQuestionAnswerPhaseQuestion);
    self.questionLabel.attributedText =
        [self attributedTextWithString:round.question.length > 0 ? round.question : @"等待设备语音…"
                                 color:round.question.length > 0 ? TSAIQATextSecondaryColor() : TSAIQATextTertiaryColor()
                                cursor:questionStreaming];

    BOOL answerStreaming = (round.phase == TSAIDeviceQuestionAnswerPhaseAnswer);
    if (round.answer.length > 0 || answerStreaming) {
        self.answerLabel.attributedText = [self attributedTextWithString:round.answer ?: @""
                                                                   color:TSAIQATextPrimaryColor()
                                                                  cursor:answerStreaming];
    } else if (round.phase == TSAIDeviceQuestionAnswerPhaseFailed) {
        NSString *reason = [NSString stringWithFormat:@"event.error · %@ (%ld) %@",
                            round.error.domain ?: @"", (long)round.error.code,
                            round.error.localizedDescription ?: @""];
        self.answerLabel.attributedText = [self attributedTextWithString:reason
                                                                   color:TSAIQADangerColor()
                                                                  cursor:NO];
    } else if (round.phase == TSAIDeviceQuestionAnswerPhaseCancelled) {
        self.answerLabel.attributedText = [self attributedTextWithString:round.error.localizedDescription.length > 0
                                                                          ? [NSString stringWithFormat:@"已取消 · %@", round.error.localizedDescription]
                                                                          : @"已取消"
                                                                   color:TSAIQATextTertiaryColor()
                                                                  cursor:NO];
    } else {
        self.answerLabel.attributedText = [self attributedTextWithString:@"等待 phase → Answer"
                                                                   color:TSAIQATextTertiaryColor()
                                                                  cursor:NO];
    }

    self.playbackStrip.hidden = (playbackText.length == 0);
    self.playbackLabel.text = playbackText;
    self.card.alpha = (round.phase == TSAIDeviceQuestionAnswerPhaseCancelled) ? 0.78 : 1.0;
}

#pragma mark - 私有方法

/** 组装视图层级 */
- (void)setupViews {
    [self.contentView addSubview:self.card];
    [self.card addSubview:self.cardStack];

    [self.headerView addSubview:self.indexLabel];
    [self.headerView addSubview:self.identifierLabel];
    [self.headerView addSubview:self.badge];

    [self.questionSection addSubview:self.questionTitleLabel];
    [self.questionSection addSubview:self.questionLabel];
    [self.answerSection addSubview:self.answerTitleLabel];
    [self.answerSection addSubview:self.answerLabel];
    [self.playbackStrip addSubview:self.playbackLabel];

    [self.cardStack addArrangedSubview:self.headerView];
    [self.cardStack addArrangedSubview:self.questionSection];
    [self.cardStack addArrangedSubview:self.answerSection];
    [self.cardStack addArrangedSubview:self.playbackStrip];
}

/** 建立约束 */
- (void)setupConstraints {
    UIView *content = self.contentView;
    for (UIView *view in @[self.card, self.cardStack, self.indexLabel, self.identifierLabel, self.badge,
                           self.questionTitleLabel, self.questionLabel, self.answerTitleLabel,
                           self.answerLabel, self.playbackLabel]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    NSLayoutConstraint *bottom = [self.card.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-12.0];
    bottom.priority = UILayoutPriorityRequired - 1;

    [NSLayoutConstraint activateConstraints:@[
        [self.card.topAnchor constraintEqualToAnchor:content.topAnchor],
        [self.card.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:16.0],
        [self.card.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-16.0],
        bottom,

        [self.cardStack.topAnchor constraintEqualToAnchor:self.card.topAnchor],
        [self.cardStack.bottomAnchor constraintEqualToAnchor:self.card.bottomAnchor],
        [self.cardStack.leadingAnchor constraintEqualToAnchor:self.card.leadingAnchor],
        [self.cardStack.trailingAnchor constraintEqualToAnchor:self.card.trailingAnchor],

        [self.headerView.heightAnchor constraintEqualToConstant:40.0],
        [self.indexLabel.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:14.0],
        [self.indexLabel.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
        [self.identifierLabel.leadingAnchor constraintEqualToAnchor:self.indexLabel.trailingAnchor constant:8.0],
        [self.identifierLabel.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
        [self.badge.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-14.0],
        [self.badge.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
        [self.badge.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.identifierLabel.trailingAnchor constant:8.0],

        [self.questionTitleLabel.topAnchor constraintEqualToAnchor:self.questionSection.topAnchor constant:10.0],
        [self.questionTitleLabel.leadingAnchor constraintEqualToAnchor:self.questionSection.leadingAnchor constant:14.0],
        [self.questionTitleLabel.trailingAnchor constraintEqualToAnchor:self.questionSection.trailingAnchor constant:-14.0],
        [self.questionLabel.topAnchor constraintEqualToAnchor:self.questionTitleLabel.bottomAnchor constant:4.0],
        [self.questionLabel.leadingAnchor constraintEqualToAnchor:self.questionSection.leadingAnchor constant:14.0],
        [self.questionLabel.trailingAnchor constraintEqualToAnchor:self.questionSection.trailingAnchor constant:-14.0],
        [self.questionLabel.bottomAnchor constraintEqualToAnchor:self.questionSection.bottomAnchor constant:-10.0],

        [self.answerTitleLabel.topAnchor constraintEqualToAnchor:self.answerSection.topAnchor constant:10.0],
        [self.answerTitleLabel.leadingAnchor constraintEqualToAnchor:self.answerSection.leadingAnchor constant:14.0],
        [self.answerTitleLabel.trailingAnchor constraintEqualToAnchor:self.answerSection.trailingAnchor constant:-14.0],
        [self.answerLabel.topAnchor constraintEqualToAnchor:self.answerTitleLabel.bottomAnchor constant:4.0],
        [self.answerLabel.leadingAnchor constraintEqualToAnchor:self.answerSection.leadingAnchor constant:14.0],
        [self.answerLabel.trailingAnchor constraintEqualToAnchor:self.answerSection.trailingAnchor constant:-14.0],
        [self.answerLabel.bottomAnchor constraintEqualToAnchor:self.answerSection.bottomAnchor constant:-10.0],

        [self.playbackLabel.topAnchor constraintEqualToAnchor:self.playbackStrip.topAnchor constant:9.0],
        [self.playbackLabel.bottomAnchor constraintEqualToAnchor:self.playbackStrip.bottomAnchor constant:-9.0],
        [self.playbackLabel.leadingAnchor constraintEqualToAnchor:self.playbackStrip.leadingAnchor constant:14.0],
        [self.playbackLabel.trailingAnchor constraintEqualToAnchor:self.playbackStrip.trailingAnchor constant:-14.0],
    ]];
}

/** 按阶段刷新徽标 */
- (void)applyBadgeForPhase:(TSAIDeviceQuestionAnswerPhase)phase {
    switch (phase) {
        case TSAIDeviceQuestionAnswerPhaseQuestion:
            [self.badge applyText:@"提问中" style:TSAIQABadgeStyleLive];
            break;
        case TSAIDeviceQuestionAnswerPhaseAnswer:
            [self.badge applyText:@"回答中" style:TSAIQABadgeStyleLive];
            break;
        case TSAIDeviceQuestionAnswerPhaseCompleted:
            [self.badge applyText:@"Completed" style:TSAIQABadgeStyleSuccess];
            break;
        case TSAIDeviceQuestionAnswerPhaseFailed:
            [self.badge applyText:@"Failed" style:TSAIQABadgeStyleDanger];
            break;
        case TSAIDeviceQuestionAnswerPhaseCancelled:
            [self.badge applyText:@"Cancelled" style:TSAIQABadgeStyleIdle];
            break;
    }
}

/** 生成带行距与可选流式光标的正文 */
- (NSAttributedString *)attributedTextWithString:(NSString *)string
                                           color:(UIColor *)color
                                          cursor:(BOOL)cursor {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 4.0;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
        initWithString:string ?: @""
            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                         NSForegroundColorAttributeName: color,
                         NSParagraphStyleAttributeName: paragraph}];
    if (cursor) {
        [text appendAttributedString:[[NSAttributedString alloc]
            initWithString:kTSAIQADeviceStreamingCursor
                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                             NSForegroundColorAttributeName: TSAIQATintColor()}]];
    }
    return text;
}

/** 创建分段标题（前置圆点用 ● 字符着色） */
- (UILabel *)makeSectionTitleWithText:(NSString *)text dotColor:(UIColor *)dotColor {
    UILabel *label = [[UILabel alloc] init];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
        initWithString:@"● "
            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:8.0],
                         NSForegroundColorAttributeName: dotColor,
                         NSBaselineOffsetAttributeName: @1.5}];
    [title appendAttributedString:[[NSAttributedString alloc]
        initWithString:text
            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10.0 weight:UIFontWeightBold],
                         NSForegroundColorAttributeName: TSAIQATextTertiaryColor(),
                         NSKernAttributeName: @1.0}]];
    label.attributedText = title;
    return label;
}

#pragma mark - 属性（懒加载）

- (UIView *)card {
    if (!_card) {
        _card = [[UIView alloc] init];
        _card.backgroundColor = [UIColor whiteColor];
        _card.layer.cornerRadius = 18.0;
        _card.layer.borderWidth = 1.0;
        _card.layer.borderColor = TSAIQALineColor().CGColor;
        _card.layer.masksToBounds = YES;
    }
    return _card;
}

- (UIStackView *)cardStack {
    if (!_cardStack) {
        _cardStack = [[UIStackView alloc] init];
        _cardStack.axis = UILayoutConstraintAxisVertical;
        _cardStack.alignment = UIStackViewAlignmentFill;
    }
    return _cardStack;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor colorWithRed:0xFA / 255.0 green:0xFA / 255.0 blue:0xFD / 255.0 alpha:1.0];
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = TSAIQALineColor();
        line.translatesAutoresizingMaskIntoConstraints = NO;
        [_headerView addSubview:line];
        [NSLayoutConstraint activateConstraints:@[
            [line.leadingAnchor constraintEqualToAnchor:_headerView.leadingAnchor],
            [line.trailingAnchor constraintEqualToAnchor:_headerView.trailingAnchor],
            [line.bottomAnchor constraintEqualToAnchor:_headerView.bottomAnchor],
            [line.heightAnchor constraintEqualToConstant:1.0],
        ]];
    }
    return _headerView;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold];
        _indexLabel.textColor = TSAIQATextPrimaryColor();
    }
    return _indexLabel;
}

- (UILabel *)identifierLabel {
    if (!_identifierLabel) {
        _identifierLabel = [[UILabel alloc] init];
        _identifierLabel.font = TSAIQAMonoFont(10.5);
        _identifierLabel.textColor = TSAIQATextTertiaryColor();
        _identifierLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_identifierLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                                          forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _identifierLabel;
}

- (TSAIQABadgeLabel *)badge {
    if (!_badge) {
        _badge = [[TSAIQABadgeLabel alloc] init];
    }
    return _badge;
}

- (UIView *)questionSection {
    if (!_questionSection) {
        _questionSection = [[UIView alloc] init];
    }
    return _questionSection;
}

- (UILabel *)questionTitleLabel {
    if (!_questionTitleLabel) {
        _questionTitleLabel = [self makeSectionTitleWithText:@"问题 · QUESTION" dotColor:TSAIQAQuestionColor()];
    }
    return _questionTitleLabel;
}

- (UILabel *)questionLabel {
    if (!_questionLabel) {
        _questionLabel = [[UILabel alloc] init];
        _questionLabel.numberOfLines = 0;
    }
    return _questionLabel;
}

- (UIView *)answerSection {
    if (!_answerSection) {
        _answerSection = [[UIView alloc] init];
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = TSAIQALineColor();
        line.translatesAutoresizingMaskIntoConstraints = NO;
        [_answerSection addSubview:line];
        [NSLayoutConstraint activateConstraints:@[
            [line.leadingAnchor constraintEqualToAnchor:_answerSection.leadingAnchor constant:14.0],
            [line.trailingAnchor constraintEqualToAnchor:_answerSection.trailingAnchor constant:-14.0],
            [line.topAnchor constraintEqualToAnchor:_answerSection.topAnchor],
            [line.heightAnchor constraintEqualToConstant:1.0],
        ]];
    }
    return _answerSection;
}

- (UILabel *)answerTitleLabel {
    if (!_answerTitleLabel) {
        _answerTitleLabel = [self makeSectionTitleWithText:@"回答 · ANSWER" dotColor:TSAIQATintColor()];
    }
    return _answerTitleLabel;
}

- (UILabel *)answerLabel {
    if (!_answerLabel) {
        _answerLabel = [[UILabel alloc] init];
        _answerLabel.numberOfLines = 0;
    }
    return _answerLabel;
}

- (UIView *)playbackStrip {
    if (!_playbackStrip) {
        _playbackStrip = [[UIView alloc] init];
        _playbackStrip.backgroundColor = TSAIQASoftTintColor();
        _playbackStrip.hidden = YES;
    }
    return _playbackStrip;
}

- (UILabel *)playbackLabel {
    if (!_playbackLabel) {
        _playbackLabel = [[UILabel alloc] init];
        _playbackLabel.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold];
        _playbackLabel.textColor = TSAIQADeepTintColor();
        _playbackLabel.numberOfLines = 0;
    }
    return _playbackLabel;
}

@end
