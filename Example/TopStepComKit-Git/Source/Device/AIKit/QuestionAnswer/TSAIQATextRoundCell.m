//
//  TSAIQATextRoundCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIQATextRoundCell.h"

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAIQABadgeLabel.h"
#import "TSAIQATextRound.h"
#import "TSAIQATheme.h"

static NSString * const kTSAIQAStreamingCursor = @"▍";

@interface TSAIQATextRoundCell ()

// 绑定的轮次
@property (nonatomic, strong, nullable) TSAIQATextRound *round;

// 问题气泡
@property (nonatomic, strong) UIView *questionBubble;
@property (nonatomic, strong) CAGradientLayer *questionGradient;
@property (nonatomic, strong) UILabel *questionLabel;

// 答案卡片
@property (nonatomic, strong) UIView *answerCard;
@property (nonatomic, strong) UIStackView *cardStack;
@property (nonatomic, strong) UIStackView *headerRow;
@property (nonatomic, strong) UILabel *avatarLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *questionIdLabel;
@property (nonatomic, strong) TSAIQABadgeLabel *badge;
@property (nonatomic, strong) UIStackView *thinkingRow;
@property (nonatomic, strong) UIActivityIndicatorView *thinkingIndicator;
@property (nonatomic, strong) UILabel *thinkingLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIView *errorBox;
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIView *footerSeparator;
@property (nonatomic, strong) UIStackView *footerRow;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UIButton *copyButton;
@property (nonatomic, strong) UIButton *retryButton;

@end

@implementation TSAIQATextRoundCell

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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.questionGradient.frame = self.questionBubble.bounds;
}

#pragma mark - 公开方法

/** 绑定轮次并刷新 */
- (void)applyRound:(TSAIQATextRound *)round {
    self.round = round;
    self.questionLabel.text = [self questionTextForRound:round];
    self.questionIdLabel.text = round.questionId ?: @"";
    [self applyBadgeForState:round.state];
    [self applyBodyForRound:round];
    [self applyErrorForRound:round];
    [self applyFooterForRound:round];
}

#pragma mark - 私有方法 - 构建

/** 组装视图层级 */
- (void)setupViews {
    [self.contentView addSubview:self.questionBubble];
    [self.questionBubble.layer insertSublayer:self.questionGradient atIndex:0];
    [self.questionBubble addSubview:self.questionLabel];

    [self.contentView addSubview:self.answerCard];
    [self.answerCard addSubview:self.cardStack];

    [self.headerRow addArrangedSubview:self.avatarLabel];
    [self.headerRow addArrangedSubview:self.nameLabel];
    [self.headerRow addArrangedSubview:self.questionIdLabel];
    UIView *spacer = [[UIView alloc] init];
    [spacer setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.headerRow addArrangedSubview:spacer];
    [self.headerRow addArrangedSubview:self.badge];

    [self.thinkingRow addArrangedSubview:self.thinkingIndicator];
    [self.thinkingRow addArrangedSubview:self.thinkingLabel];

    [self.errorBox addSubview:self.errorLabel];

    [self.footerRow addArrangedSubview:self.metaLabel];
    [self.footerRow addArrangedSubview:self.copyButton];
    [self.footerRow addArrangedSubview:self.retryButton];

    [self.cardStack addArrangedSubview:self.headerRow];
    [self.cardStack addArrangedSubview:self.thinkingRow];
    [self.cardStack addArrangedSubview:self.bodyLabel];
    [self.cardStack addArrangedSubview:self.errorBox];
    [self.cardStack addArrangedSubview:self.footerSeparator];
    [self.cardStack addArrangedSubview:self.footerRow];
}

/** 建立约束 */
- (void)setupConstraints {
    UIView *content = self.contentView;
    self.questionBubble.translatesAutoresizingMaskIntoConstraints = NO;
    self.questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.answerCard.translatesAutoresizingMaskIntoConstraints = NO;
    self.cardStack.translatesAutoresizingMaskIntoConstraints = NO;
    self.errorLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *bottom = [self.answerCard.bottomAnchor constraintEqualToAnchor:content.bottomAnchor
                                                                              constant:-12.0];
    bottom.priority = UILayoutPriorityRequired - 1;
    [NSLayoutConstraint activateConstraints:@[
        [self.questionBubble.topAnchor constraintEqualToAnchor:content.topAnchor constant:8.0],
        [self.questionBubble.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-16.0],
        [self.questionBubble.leadingAnchor constraintGreaterThanOrEqualToAnchor:content.leadingAnchor constant:72.0],

        [self.questionLabel.topAnchor constraintEqualToAnchor:self.questionBubble.topAnchor constant:11.0],
        [self.questionLabel.bottomAnchor constraintEqualToAnchor:self.questionBubble.bottomAnchor constant:-11.0],
        [self.questionLabel.leadingAnchor constraintEqualToAnchor:self.questionBubble.leadingAnchor constant:14.0],
        [self.questionLabel.trailingAnchor constraintEqualToAnchor:self.questionBubble.trailingAnchor constant:-14.0],

        [self.answerCard.topAnchor constraintEqualToAnchor:self.questionBubble.bottomAnchor constant:10.0],
        [self.answerCard.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:16.0],
        [self.answerCard.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-36.0],
        bottom,

        [self.cardStack.topAnchor constraintEqualToAnchor:self.answerCard.topAnchor constant:12.0],
        [self.cardStack.bottomAnchor constraintEqualToAnchor:self.answerCard.bottomAnchor constant:-10.0],
        [self.cardStack.leadingAnchor constraintEqualToAnchor:self.answerCard.leadingAnchor constant:14.0],
        [self.cardStack.trailingAnchor constraintEqualToAnchor:self.answerCard.trailingAnchor constant:-14.0],

        [self.avatarLabel.widthAnchor constraintEqualToConstant:24.0],
        [self.avatarLabel.heightAnchor constraintEqualToConstant:24.0],
        [self.footerSeparator.heightAnchor constraintEqualToConstant:1.0],
        [self.copyButton.widthAnchor constraintEqualToConstant:40.0],
        [self.retryButton.widthAnchor constraintEqualToConstant:40.0],

        [self.errorLabel.topAnchor constraintEqualToAnchor:self.errorBox.topAnchor constant:10.0],
        [self.errorLabel.bottomAnchor constraintEqualToAnchor:self.errorBox.bottomAnchor constant:-10.0],
        [self.errorLabel.leadingAnchor constraintEqualToAnchor:self.errorBox.leadingAnchor constant:12.0],
        [self.errorLabel.trailingAnchor constraintEqualToAnchor:self.errorBox.trailingAnchor constant:-12.0],
    ]];
}

#pragma mark - 私有方法 - 刷新

/** 问题气泡文本：语音轮次带来源前缀，识别中显示占位 */
- (NSString *)questionTextForRound:(TSAIQATextRound *)round {
    NSString *prefix = nil;
    switch (round.source) {
        case TSAIQARoundSourcePhoneMic: prefix = @"🎙 "; break;
        case TSAIQARoundSourceHeadset:  prefix = @"🎧 "; break;
        case TSAIQARoundSourceText:     prefix = nil; break;
    }
    NSString *question = round.question ?: @"";
    if (round.state == TSAIQATextRoundStateRecognizing) {
        question = question.length > 0 ? [question stringByAppendingString:@" ▍"] : @"正在识别问题…";
    }
    return prefix ? [prefix stringByAppendingString:question] : question;
}

/** 按状态刷新徽标 */
- (void)applyBadgeForState:(TSAIQATextRoundState)state {
    switch (state) {
        case TSAIQATextRoundStateRecognizing:
            [self.badge applyText:@"识别中" style:TSAIQABadgeStyleLive];
            break;
        case TSAIQATextRoundStatePending:
            [self.badge applyText:@"连接中" style:TSAIQABadgeStyleLive];
            break;
        case TSAIQATextRoundStateAnswering:
            [self.badge applyText:@"回答中" style:TSAIQABadgeStyleLive];
            break;
        case TSAIQATextRoundStateCompleted:
            [self.badge applyText:@"已完成" style:TSAIQABadgeStyleSuccess];
            break;
        case TSAIQATextRoundStateFailed:
            [self.badge applyText:@"失败" style:TSAIQABadgeStyleDanger];
            break;
        case TSAIQATextRoundStateCancelled:
            [self.badge applyText:@"已取消" style:TSAIQABadgeStyleIdle];
            break;
    }
}

/** 刷新正文：等待态显示指示器，其余显示累计答案并高亮增量 */
- (void)applyBodyForRound:(TSAIQATextRound *)round {
    BOOL pending = (round.state == TSAIQATextRoundStatePending ||
                    round.state == TSAIQATextRoundStateRecognizing);
    self.thinkingRow.hidden = !pending;
    self.thinkingLabel.text = round.state == TSAIQATextRoundStateRecognizing
        ? @"等待问题识别完成…"
        : @"等待 onStartAnswering…";
    if (pending) {
        [self.thinkingIndicator startAnimating];
    } else {
        [self.thinkingIndicator stopAnimating];
    }
    self.bodyLabel.hidden = pending || round.answer.length == 0;
    if (self.bodyLabel.hidden) {
        self.bodyLabel.attributedText = nil;
        return;
    }

    NSString *answer = round.answer ?: @"";
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 4.0;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
        initWithString:answer
            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                         NSForegroundColorAttributeName: TSAIQATextPrimaryColor(),
                         NSParagraphStyleAttributeName: paragraph}];

    NSString *delta = round.deltaText;
    if (round.state == TSAIQATextRoundStateAnswering && delta.length > 0 &&
        delta.length <= answer.length && [answer hasSuffix:delta]) {
        NSRange deltaRange = NSMakeRange(answer.length - delta.length, delta.length);
        [text addAttribute:NSBackgroundColorAttributeName
                     value:[TSAIQATintColor() colorWithAlphaComponent:0.18]
                     range:deltaRange];
    }
    if (round.state == TSAIQATextRoundStateAnswering) {
        [text appendAttributedString:[[NSAttributedString alloc]
            initWithString:kTSAIQAStreamingCursor
                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                             NSForegroundColorAttributeName: TSAIQATintColor()}]];
    }
    if (round.playbackText.length > 0) {
        [text appendAttributedString:[[NSAttributedString alloc]
            initWithString:[NSString stringWithFormat:@"\n\n🔊 %@", round.playbackText]
                attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                             NSForegroundColorAttributeName: TSAIQATextTertiaryColor()}]];
    }
    self.bodyLabel.attributedText = text;
}

/** 刷新错误 / 取消说明 */
- (void)applyErrorForRound:(TSAIQATextRound *)round {
    if (round.state == TSAIQATextRoundStateFailed) {
        self.errorBox.hidden = NO;
        self.errorBox.backgroundColor = [TSAIQADangerColor() colorWithAlphaComponent:0.06];
        self.errorLabel.textColor = [UIColor colorWithRed:0xB8 / 255.0 green:0x28 / 255.0 blue:0x3A / 255.0 alpha:1.0];
        self.errorLabel.text = [NSString stringWithFormat:@"completion(error) · %@ (%ld)\n%@",
                                round.error.domain ?: @"", (long)round.error.code,
                                round.error.localizedDescription ?: @"未收到终态结果"];
        self.answerCard.layer.borderColor = [TSAIQADangerColor() colorWithAlphaComponent:0.35].CGColor;
    } else if (round.state == TSAIQATextRoundStateCancelled) {
        self.errorBox.hidden = NO;
        self.errorBox.backgroundColor = [UIColor colorWithWhite:0 alpha:0.04];
        self.errorLabel.textColor = TSAIQATextSecondaryColor();
        self.errorLabel.text = @"已取消 · cancelQuestionAnswerWithTaskId: 已丢弃后续回调";
        self.answerCard.layer.borderColor = TSAIQALineColor().CGColor;
    } else {
        self.errorBox.hidden = YES;
        self.answerCard.layer.borderColor = TSAIQALineColor().CGColor;
    }
    self.answerCard.alpha = (round.state == TSAIQATextRoundStateCancelled) ? 0.78 : 1.0;
}

/** 刷新底部元信息与操作按钮 */
- (void)applyFooterForRound:(TSAIQATextRound *)round {
    BOOL pending = (round.state == TSAIQATextRoundStatePending ||
                    round.state == TSAIQATextRoundStateRecognizing);
    self.footerSeparator.hidden = pending;
    self.footerRow.hidden = pending;
    if (pending) {
        return;
    }
    NSString *durationText = round.duration > 0
        ? [NSString stringWithFormat:@"%.1fs", round.duration]
        : @"…";
    NSString *voiceText = round.voiceDuration > 0
        ? [NSString stringWithFormat:@" · 录音 %.1fs", round.voiceDuration]
        : @"";
    self.metaLabel.text = [NSString stringWithFormat:@"%@ · %@ · %@ · %lu 字%@",
                           round.taskId.length > 0 ? round.taskId : @"task –",
                           round.questionId ?: @"qid –",
                           durationText,
                           (unsigned long)round.answer.length,
                           voiceText];
    self.copyButton.hidden = (round.answer.length == 0);
    self.retryButton.hidden = ![round isTerminal] || round.question.length == 0;
}

#pragma mark - 事件

/** 复制答案 */
- (void)onCopyTapped {
    if (self.round) {
        [self.delegate textRoundCell:self didTapCopyForRound:self.round];
    }
}

/** 重新提问 */
- (void)onRetryTapped {
    if (self.round) {
        [self.delegate textRoundCell:self didTapRetryForRound:self.round];
    }
}

#pragma mark - 属性（懒加载）

- (UIView *)questionBubble {
    if (!_questionBubble) {
        _questionBubble = [[UIView alloc] init];
        _questionBubble.layer.cornerRadius = 18.0;
        _questionBubble.layer.masksToBounds = YES;
        if (@available(iOS 11.0, *)) {
            _questionBubble.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
        }
    }
    return _questionBubble;
}

- (CAGradientLayer *)questionGradient {
    if (!_questionGradient) {
        _questionGradient = [CAGradientLayer layer];
        _questionGradient.colors = @[(id)TSAIQATintColor().CGColor,
                                     (id)[UIColor colorWithRed:0xF0 / 255.0 green:0x6B / 255.0 blue:0xA5 / 255.0 alpha:1.0].CGColor];
        _questionGradient.startPoint = CGPointMake(0, 0);
        _questionGradient.endPoint = CGPointMake(1, 1);
    }
    return _questionGradient;
}

- (UILabel *)questionLabel {
    if (!_questionLabel) {
        _questionLabel = [[UILabel alloc] init];
        _questionLabel.font = [UIFont systemFontOfSize:14.0];
        _questionLabel.textColor = [UIColor whiteColor];
        _questionLabel.numberOfLines = 0;
    }
    return _questionLabel;
}

- (UIView *)answerCard {
    if (!_answerCard) {
        _answerCard = [[UIView alloc] init];
        _answerCard.backgroundColor = [UIColor whiteColor];
        _answerCard.layer.cornerRadius = 18.0;
        _answerCard.layer.borderWidth = 1.0;
        _answerCard.layer.borderColor = TSAIQALineColor().CGColor;
        TSAIQAApplyCardShadow(_answerCard.layer);
    }
    return _answerCard;
}

- (UIStackView *)cardStack {
    if (!_cardStack) {
        _cardStack = [[UIStackView alloc] init];
        _cardStack.axis = UILayoutConstraintAxisVertical;
        _cardStack.spacing = 8.0;
        _cardStack.alignment = UIStackViewAlignmentFill;
    }
    return _cardStack;
}

- (UIStackView *)headerRow {
    if (!_headerRow) {
        _headerRow = [[UIStackView alloc] init];
        _headerRow.axis = UILayoutConstraintAxisHorizontal;
        _headerRow.spacing = 8.0;
        _headerRow.alignment = UIStackViewAlignmentCenter;
    }
    return _headerRow;
}

- (UILabel *)avatarLabel {
    if (!_avatarLabel) {
        _avatarLabel = [[UILabel alloc] init];
        _avatarLabel.text = @"AI";
        _avatarLabel.font = [UIFont systemFontOfSize:10.0 weight:UIFontWeightBold];
        _avatarLabel.textColor = [UIColor whiteColor];
        _avatarLabel.textAlignment = NSTextAlignmentCenter;
        _avatarLabel.backgroundColor = TSAIQATintColor();
        _avatarLabel.layer.cornerRadius = 8.0;
        _avatarLabel.layer.masksToBounds = YES;
    }
    return _avatarLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"AI";
        _nameLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold];
        _nameLabel.textColor = TSAIQATextPrimaryColor();
    }
    return _nameLabel;
}

- (UILabel *)questionIdLabel {
    if (!_questionIdLabel) {
        _questionIdLabel = [[UILabel alloc] init];
        _questionIdLabel.font = TSAIQAMonoFont(10.5);
        _questionIdLabel.textColor = TSAIQATextTertiaryColor();
    }
    return _questionIdLabel;
}

- (TSAIQABadgeLabel *)badge {
    if (!_badge) {
        _badge = [[TSAIQABadgeLabel alloc] init];
    }
    return _badge;
}

- (UIStackView *)thinkingRow {
    if (!_thinkingRow) {
        _thinkingRow = [[UIStackView alloc] init];
        _thinkingRow.axis = UILayoutConstraintAxisHorizontal;
        _thinkingRow.spacing = 8.0;
        _thinkingRow.alignment = UIStackViewAlignmentCenter;
    }
    return _thinkingRow;
}

- (UIActivityIndicatorView *)thinkingIndicator {
    if (!_thinkingIndicator) {
        _thinkingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _thinkingIndicator.color = TSAIQATintColor();
        _thinkingIndicator.hidesWhenStopped = NO;
    }
    return _thinkingIndicator;
}

- (UILabel *)thinkingLabel {
    if (!_thinkingLabel) {
        _thinkingLabel = [[UILabel alloc] init];
        _thinkingLabel.text = @"等待服务开始回答 · onStartAnswering";
        _thinkingLabel.font = [UIFont systemFontOfSize:13.0];
        _thinkingLabel.textColor = TSAIQATextTertiaryColor();
    }
    return _thinkingLabel;
}

- (UILabel *)bodyLabel {
    if (!_bodyLabel) {
        _bodyLabel = [[UILabel alloc] init];
        _bodyLabel.numberOfLines = 0;
        _bodyLabel.font = [UIFont systemFontOfSize:14.0];
        _bodyLabel.textColor = TSAIQATextPrimaryColor();
    }
    return _bodyLabel;
}

- (UIView *)errorBox {
    if (!_errorBox) {
        _errorBox = [[UIView alloc] init];
        _errorBox.layer.cornerRadius = 12.0;
        _errorBox.hidden = YES;
    }
    return _errorBox;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.numberOfLines = 0;
        _errorLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _errorLabel;
}

- (UIView *)footerSeparator {
    if (!_footerSeparator) {
        _footerSeparator = [[UIView alloc] init];
        _footerSeparator.backgroundColor = TSAIQALineColor();
    }
    return _footerSeparator;
}

- (UIStackView *)footerRow {
    if (!_footerRow) {
        _footerRow = [[UIStackView alloc] init];
        _footerRow.axis = UILayoutConstraintAxisHorizontal;
        _footerRow.spacing = 6.0;
        _footerRow.alignment = UIStackViewAlignmentCenter;
    }
    return _footerRow;
}

- (UILabel *)metaLabel {
    if (!_metaLabel) {
        _metaLabel = [[UILabel alloc] init];
        _metaLabel.font = TSAIQAMonoFont(10.0);
        _metaLabel.textColor = TSAIQATextTertiaryColor();
        _metaLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_metaLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                                    forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _metaLabel;
}

- (UIButton *)copyButton {
    if (!_copyButton) {
        _copyButton = [self makeFooterButtonWithTitle:@"复制" action:@selector(onCopyTapped)];
    }
    return _copyButton;
}

- (UIButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [self makeFooterButtonWithTitle:@"重问" action:@selector(onRetryTapped)];
    }
    return _retryButton;
}

/** 创建底部小按钮 */
- (UIButton *)makeFooterButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold];
    [button setTitleColor:TSAIQADeepTintColor() forState:UIControlStateNormal];
    button.backgroundColor = TSAIQASoftTintColor();
    button.layer.cornerRadius = 8.0;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button.heightAnchor constraintEqualToConstant:26.0].active = YES;
    return button;
}

@end
