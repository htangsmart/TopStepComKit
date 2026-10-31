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

// 布局常量：高度计算与 layoutSubviews 共用同一套数值，保证行高与内容严格一致
static const CGFloat kTSAIQADeviceCardHorizontalInset = 16.0;
static const CGFloat kTSAIQADeviceCardBottomSpacing = 12.0;
static const CGFloat kTSAIQADeviceHeaderHeight = 40.0;
static const CGFloat kTSAIQADeviceContentInset = 14.0;
static const CGFloat kTSAIQADeviceSectionVerticalInset = 10.0;
static const CGFloat kTSAIQADeviceTitleSpacing = 4.0;
static const CGFloat kTSAIQADevicePlaybackVerticalInset = 9.0;

@interface TSAIQADeviceRoundCell ()

// 卡片容器
@property (nonatomic, strong) UIView *card;

// 头部
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *headerLine;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UILabel *identifierLabel;
@property (nonatomic, strong) TSAIQABadgeLabel *badge;

// 问题段
@property (nonatomic, strong) UILabel *questionTitleLabel;
@property (nonatomic, strong) UILabel *questionLabel;

// 回答段
@property (nonatomic, strong) UIView *answerLine;
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
        // 内容只在本行范围内绘制，避免任何高度偏差导致卡片互相覆盖
        self.contentView.clipsToBounds = YES;
        self.clipsToBounds = YES;
        [self setupViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutContent];
}

#pragma mark - 公开方法

/** 绑定轮次并刷新 */
- (void)applyRound:(TSAIQADeviceRound *)round playbackText:(NSString *)playbackText {
    self.indexLabel.text = [NSString stringWithFormat:@"第 %lu 轮", (unsigned long)round.index];
    self.identifierLabel.text = [NSString stringWithFormat:@"%@ · #%ld",
                                 round.roundIdentifier ?: @"", (long)round.sequence];
    [self applyBadgeForPhase:round.phase];

    self.questionLabel.attributedText = [[self class] questionTextForRound:round];
    self.answerLabel.attributedText = [[self class] answerTextForRound:round];

    self.playbackStrip.hidden = (playbackText.length == 0);
    self.playbackLabel.text = playbackText;
    self.card.alpha = (round.phase == TSAIDeviceQuestionAnswerPhaseCancelled) ? 0.78 : 1.0;
    [self setNeedsLayout];
}

/** 按内容计算行高（与 layoutContent 使用同一套布局规则） */
+ (CGFloat)heightForRound:(TSAIQADeviceRound *)round playbackText:(NSString *)playbackText width:(CGFloat)width {
    CGFloat textWidth = [self textWidthForCellWidth:width];
    if (textWidth <= 0) {
        return 0;
    }
    CGFloat titleHeight = [self sectionTitleHeight];
    CGFloat questionHeight = [self heightOfAttributedText:[self questionTextForRound:round] width:textWidth];
    CGFloat answerHeight = [self heightOfAttributedText:[self answerTextForRound:round] width:textWidth];

    CGFloat height = kTSAIQADeviceHeaderHeight;
    height += kTSAIQADeviceSectionVerticalInset * 2 + titleHeight + kTSAIQADeviceTitleSpacing + questionHeight;
    height += kTSAIQADeviceSectionVerticalInset * 2 + titleHeight + kTSAIQADeviceTitleSpacing + answerHeight;
    if (playbackText.length > 0) {
        height += kTSAIQADevicePlaybackVerticalInset * 2 +
            [self heightOfText:playbackText font:[self playbackFont] width:textWidth];
    }
    height += kTSAIQADeviceCardBottomSpacing;
    return ceil(height);
}

#pragma mark - 私有方法 - 文本

/** 问题正文：识别出的问题优先展示，未识别时显示占位 */
+ (NSAttributedString *)questionTextForRound:(TSAIQADeviceRound *)round {
    BOOL questionStreaming = (round.phase == TSAIDeviceQuestionAnswerPhaseQuestion);
    BOOL hasQuestion = (round.question.length > 0);
    NSString *placeholder = questionStreaming ? @"正在识别手表语音…" : @"未识别到问题";
    return [self attributedTextWithString:hasQuestion ? round.question : placeholder
                                    color:hasQuestion ? TSAIQATextPrimaryColor() : TSAIQATextTertiaryColor()
                                   cursor:questionStreaming && hasQuestion];
}

/** 回答正文：按阶段展示流式回答、失败原因或等待提示 */
+ (NSAttributedString *)answerTextForRound:(TSAIQADeviceRound *)round {
    BOOL answerStreaming = (round.phase == TSAIDeviceQuestionAnswerPhaseAnswer);
    if (round.answer.length > 0) {
        return [self attributedTextWithString:round.answer
                                        color:TSAIQATextPrimaryColor()
                                       cursor:answerStreaming];
    }
    switch (round.phase) {
        case TSAIDeviceQuestionAnswerPhaseAnswer:
            return [self attributedTextWithString:@"正在生成回答…" color:TSAIQATextTertiaryColor() cursor:YES];
        case TSAIDeviceQuestionAnswerPhaseFailed: {
            NSString *reason = round.error.localizedDescription.length > 0
                ? [NSString stringWithFormat:@"回答失败 · %@ (%ld)", round.error.localizedDescription, (long)round.error.code]
                : @"回答失败";
            return [self attributedTextWithString:reason color:TSAIQADangerColor() cursor:NO];
        }
        case TSAIDeviceQuestionAnswerPhaseCancelled: {
            NSString *text = round.error.localizedDescription.length > 0
                ? [NSString stringWithFormat:@"已取消 · %@", round.error.localizedDescription]
                : @"已取消";
            return [self attributedTextWithString:text color:TSAIQATextTertiaryColor() cursor:NO];
        }
        case TSAIDeviceQuestionAnswerPhaseCompleted:
            return [self attributedTextWithString:@"本轮没有返回回答文字" color:TSAIQATextTertiaryColor() cursor:NO];
        case TSAIDeviceQuestionAnswerPhaseQuestion:
            break;
    }
    return [self attributedTextWithString:@"等待问题识别完成…" color:TSAIQATextTertiaryColor() cursor:NO];
}

/** 生成带行距与可选流式光标的正文 */
+ (NSAttributedString *)attributedTextWithString:(NSString *)string
                                           color:(UIColor *)color
                                          cursor:(BOOL)cursor {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 4.0;
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    UIFont *font = [UIFont systemFontOfSize:14.0];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
        initWithString:string ?: @""
            attributes:@{NSFontAttributeName: font,
                         NSForegroundColorAttributeName: color,
                         NSParagraphStyleAttributeName: paragraph}];
    if (cursor) {
        [text appendAttributedString:[[NSAttributedString alloc]
            initWithString:kTSAIQADeviceStreamingCursor
                attributes:@{NSFontAttributeName: font,
                             NSForegroundColorAttributeName: TSAIQATintColor(),
                             NSParagraphStyleAttributeName: paragraph}]];
    }
    return text;
}

/** 分段标题（前置圆点用 ● 字符着色） */
+ (NSAttributedString *)sectionTitleWithText:(NSString *)text dotColor:(UIColor *)dotColor {
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
    return title;
}

+ (UIFont *)playbackFont {
    return [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold];
}

#pragma mark - 私有方法 - 尺寸

+ (CGFloat)textWidthForCellWidth:(CGFloat)width {
    return width - kTSAIQADeviceCardHorizontalInset * 2 - kTSAIQADeviceContentInset * 2;
}

+ (CGFloat)sectionTitleHeight {
    static CGFloat height = 0;
    if (height <= 0) {
        NSAttributedString *title = [self sectionTitleWithText:@"问题 · QUESTION" dotColor:TSAIQAQuestionColor()];
        height = [self heightOfAttributedText:title width:CGFLOAT_MAX];
    }
    return height;
}

+ (CGFloat)heightOfAttributedText:(NSAttributedString *)text width:(CGFloat)width {
    if (text.length == 0 || width <= 0) {
        return 0;
    }
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     context:nil];
    return ceil(CGRectGetHeight(rect));
}

+ (CGFloat)heightOfText:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    if (text.length == 0) {
        return 0;
    }
    return [self heightOfAttributedText:[[NSAttributedString alloc] initWithString:text
                                                                        attributes:@{NSFontAttributeName: font}]
                                  width:width];
}

#pragma mark - 私有方法 - 布局

/** 组装视图层级 */
- (void)setupViews {
    [self.contentView addSubview:self.card];
    [self.card addSubview:self.headerView];
    [self.headerView addSubview:self.headerLine];
    [self.headerView addSubview:self.indexLabel];
    [self.headerView addSubview:self.identifierLabel];
    [self.headerView addSubview:self.badge];

    [self.card addSubview:self.questionTitleLabel];
    [self.card addSubview:self.questionLabel];
    [self.card addSubview:self.answerLine];
    [self.card addSubview:self.answerTitleLabel];
    [self.card addSubview:self.answerLabel];
    [self.card addSubview:self.playbackStrip];
    [self.playbackStrip addSubview:self.playbackLabel];
}

/** 纯 frame 布局，与 heightForRound:playbackText:width: 一一对应 */
- (void)layoutContent {
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    CGFloat cardWidth = MAX(0, width - kTSAIQADeviceCardHorizontalInset * 2);
    CGFloat textWidth = MAX(0, cardWidth - kTSAIQADeviceContentInset * 2);
    CGFloat titleHeight = [[self class] sectionTitleHeight];

    // 头部
    self.headerView.frame = CGRectMake(0, 0, cardWidth, kTSAIQADeviceHeaderHeight);
    self.headerLine.frame = CGRectMake(0, kTSAIQADeviceHeaderHeight - 1.0, cardWidth, 1.0);
    CGSize badgeSize = [self.badge intrinsicContentSize];
    self.badge.frame = CGRectMake(cardWidth - kTSAIQADeviceContentInset - badgeSize.width,
                                  (kTSAIQADeviceHeaderHeight - badgeSize.height) / 2.0,
                                  badgeSize.width, badgeSize.height);
    CGSize indexSize = [self.indexLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, kTSAIQADeviceHeaderHeight)];
    self.indexLabel.frame = CGRectMake(kTSAIQADeviceContentInset,
                                       (kTSAIQADeviceHeaderHeight - indexSize.height) / 2.0,
                                       ceil(indexSize.width), ceil(indexSize.height));
    CGFloat identifierX = CGRectGetMaxX(self.indexLabel.frame) + 8.0;
    CGFloat identifierWidth = MAX(0, CGRectGetMinX(self.badge.frame) - 8.0 - identifierX);
    self.identifierLabel.frame = CGRectMake(identifierX, 0, identifierWidth, kTSAIQADeviceHeaderHeight);

    // 问题段
    CGFloat y = kTSAIQADeviceHeaderHeight + kTSAIQADeviceSectionVerticalInset;
    self.questionTitleLabel.frame = CGRectMake(kTSAIQADeviceContentInset, y, textWidth, titleHeight);
    y += titleHeight + kTSAIQADeviceTitleSpacing;
    CGFloat questionHeight = [[self class] heightOfAttributedText:self.questionLabel.attributedText width:textWidth];
    self.questionLabel.frame = CGRectMake(kTSAIQADeviceContentInset, y, textWidth, questionHeight);
    y += questionHeight + kTSAIQADeviceSectionVerticalInset;

    // 回答段
    self.answerLine.frame = CGRectMake(kTSAIQADeviceContentInset, y, textWidth, 1.0);
    y += kTSAIQADeviceSectionVerticalInset;
    self.answerTitleLabel.frame = CGRectMake(kTSAIQADeviceContentInset, y, textWidth, titleHeight);
    y += titleHeight + kTSAIQADeviceTitleSpacing;
    CGFloat answerHeight = [[self class] heightOfAttributedText:self.answerLabel.attributedText width:textWidth];
    self.answerLabel.frame = CGRectMake(kTSAIQADeviceContentInset, y, textWidth, answerHeight);
    y += answerHeight + kTSAIQADeviceSectionVerticalInset;

    // 播放条
    if (!self.playbackStrip.hidden) {
        CGFloat playbackHeight = [[self class] heightOfText:self.playbackLabel.text
                                                       font:[[self class] playbackFont]
                                                      width:textWidth];
        self.playbackStrip.frame = CGRectMake(0, y, cardWidth, playbackHeight + kTSAIQADevicePlaybackVerticalInset * 2);
        self.playbackLabel.frame = CGRectMake(kTSAIQADeviceContentInset, kTSAIQADevicePlaybackVerticalInset,
                                              textWidth, playbackHeight);
        y = CGRectGetMaxY(self.playbackStrip.frame);
    }

    self.card.frame = CGRectMake(kTSAIQADeviceCardHorizontalInset, 0, cardWidth, ceil(y));
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

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor colorWithRed:0xFA / 255.0 green:0xFA / 255.0 blue:0xFD / 255.0 alpha:1.0];
    }
    return _headerView;
}

- (UIView *)headerLine {
    if (!_headerLine) {
        _headerLine = [[UIView alloc] init];
        _headerLine.backgroundColor = TSAIQALineColor();
    }
    return _headerLine;
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
    }
    return _identifierLabel;
}

- (TSAIQABadgeLabel *)badge {
    if (!_badge) {
        _badge = [[TSAIQABadgeLabel alloc] init];
    }
    return _badge;
}

- (UILabel *)questionTitleLabel {
    if (!_questionTitleLabel) {
        _questionTitleLabel = [[UILabel alloc] init];
        _questionTitleLabel.attributedText = [[self class] sectionTitleWithText:@"问题 · QUESTION"
                                                                       dotColor:TSAIQAQuestionColor()];
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

- (UIView *)answerLine {
    if (!_answerLine) {
        _answerLine = [[UIView alloc] init];
        _answerLine.backgroundColor = TSAIQALineColor();
    }
    return _answerLine;
}

- (UILabel *)answerTitleLabel {
    if (!_answerTitleLabel) {
        _answerTitleLabel = [[UILabel alloc] init];
        _answerTitleLabel.attributedText = [[self class] sectionTitleWithText:@"回答 · ANSWER"
                                                                     dotColor:TSAIQATintColor()];
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
        _playbackLabel.font = [[self class] playbackFont];
        _playbackLabel.textColor = TSAIQADeepTintColor();
        _playbackLabel.numberOfLines = 0;
    }
    return _playbackLabel;
}

@end
