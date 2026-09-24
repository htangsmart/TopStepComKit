//
//  TSAIInterpreterLineCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/24.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterLineCell.h"

#import "TSAIInterpreterUtteranceUI.h"

/// 高亮底色距 cell 左右边缘的内缩
static const CGFloat kLineCellSideInset = 6.0;
/// 相邻两行之间的垂直间距（上下各一半）
static const CGFloat kLineCellRowGap = 2.0;
/// 高亮底色内部的左 / 右 / 上下内边距
static const CGFloat kLineCellPadLeft = 4.0;
static const CGFloat kLineCellPadRight = 8.0;
static const CGFloat kLineCellPadVertical = 6.0;
/// 序号栏宽度与序号到正文的间距
static const CGFloat kLineCellIndexWidth = 30.0;
static const CGFloat kLineCellIndexGap = 4.0;
/// 音频状态行高度与其到正文的间距
static const CGFloat kLineCellAudioHeight = 14.0;
static const CGFloat kLineCellAudioGap = 3.0;
/// 流式文本尾部光标字符
static NSString *const kLineCellCursorGlyph = @"▏";

@interface TSAIInterpreterLineCell ()

/// 高亮底色（最新句 / 配对句时显示）
@property (nonatomic, strong) UIView *highlightView;
/// 序号标签 `#N`
@property (nonatomic, strong) UILabel *indexLabel;
/// 正文标签（原文或译文）
@property (nonatomic, strong) UILabel *bodyLabel;
/// 音频状态标签（仅目标面板）
@property (nonatomic, strong) UILabel *audioLabel;
/// 当前绑定的角色，决定字体与布局
@property (nonatomic, assign) TSAIInterpreterLineRole role;

@end

@implementation TSAIInterpreterLineCell

#pragma mark - 生命周期

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.highlightView];
        [self.contentView addSubview:self.indexLabel];
        [self.contentView addSubview:self.bodyLabel];
        [self.contentView addSubview:self.audioLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat cellWidth = CGRectGetWidth(self.contentView.bounds);
    CGFloat cellHeight = CGRectGetHeight(self.contentView.bounds);
    CGFloat halfGap = kLineCellRowGap / 2.0;

    self.highlightView.frame = CGRectMake(kLineCellSideInset, halfGap,
                                          cellWidth - kLineCellSideInset * 2, cellHeight - kLineCellRowGap);

    CGFloat indexX = kLineCellSideInset + kLineCellPadLeft;
    CGFloat textX = indexX + kLineCellIndexWidth + kLineCellIndexGap;
    CGFloat textWidth = [[self class] textWidthForCellWidth:cellWidth];
    CGFloat y = halfGap + kLineCellPadVertical;

    CGSize textSize = [self.bodyLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)];
    self.bodyLabel.frame = CGRectMake(textX, y, textWidth, ceil(textSize.height));
    // 序号与正文首行对齐：用正文字体的行高做基准
    CGFloat firstLineHeight = self.bodyLabel.font.lineHeight;
    self.indexLabel.frame = CGRectMake(indexX, y, kLineCellIndexWidth, firstLineHeight);
    y = CGRectGetMaxY(self.bodyLabel.frame);

    if (!self.audioLabel.hidden) {
        y += kLineCellAudioGap;
        self.audioLabel.frame = CGRectMake(textX, y, textWidth, kLineCellAudioHeight);
    }
}

#pragma mark - 公开方法

- (void)bindWithUtterance:(TSAIInterpreterUtteranceUI *)utterance
                     role:(TSAIInterpreterLineRole)role
                showAudio:(BOOL)showAudio
                 isLatest:(BOOL)isLatest
                 isPaired:(BOOL)isPaired {
    self.role = role;
    self.indexLabel.text = [NSString stringWithFormat:@"#%ld", (long)utterance.index + 1];

    BOOL isSource = (role == TSAIInterpreterLineRoleSource);
    NSString *text = isSource ? utterance.originalText : utterance.translatedText;
    BOOL isFinal = isSource ? utterance.isOriginalFinal : utterance.isTranslatedFinal;
    self.bodyLabel.font = [[self class] textFontForRole:role];
    self.bodyLabel.attributedText = [[self class] attributedTextWithText:text
                                                                     role:role
                                                                  isFinal:isFinal];

    self.audioLabel.hidden = isSource || !showAudio;
    if (!self.audioLabel.hidden) {
        [self bindAudioStatusWithUtterance:utterance];
    }
    [self applyHighlightLatest:isLatest paired:isPaired];
    [self setNeedsLayout];
}

+ (CGFloat)heightForUtterance:(TSAIInterpreterUtteranceUI *)utterance
                         role:(TSAIInterpreterLineRole)role
                    showAudio:(BOOL)showAudio
                    cellWidth:(CGFloat)cellWidth {
    BOOL isSource = (role == TSAIInterpreterLineRoleSource);
    NSString *text = isSource ? utterance.originalText : utterance.translatedText;
    BOOL isFinal = isSource ? utterance.isOriginalFinal : utterance.isTranslatedFinal;
    NSAttributedString *attributed = [self attributedTextWithText:text role:role isFinal:isFinal];
    CGFloat textWidth = [self textWidthForCellWidth:cellWidth];
    CGSize textSize = [attributed boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil].size;
    CGFloat height = kLineCellRowGap + kLineCellPadVertical * 2 + ceil(textSize.height);
    if (!isSource && showAudio) {
        height += kLineCellAudioGap + kLineCellAudioHeight;
    }
    return height;
}

#pragma mark - 私有方法

/// 正文可用宽度 = cell 宽 − 两侧内缩 − 左右内边距 − 序号栏
+ (CGFloat)textWidthForCellWidth:(CGFloat)cellWidth {
    CGFloat textWidth = cellWidth - kLineCellSideInset * 2 - kLineCellPadLeft - kLineCellPadRight
                        - kLineCellIndexWidth - kLineCellIndexGap;
    return MAX(textWidth, 40.0);
}

/// 源面板 16 Regular；目标面板 17 Medium（译文是主要阅读内容，略强调）
+ (UIFont *)textFontForRole:(TSAIInterpreterLineRole)role {
    if (role == TSAIInterpreterLineRoleTarget) {
        return [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
    }
    return [UIFont systemFontOfSize:16.0];
}

/// 生成正文富文本：final 用主色；流式中用次级色并追加蓝色光标
+ (nonnull NSAttributedString *)attributedTextWithText:(nullable NSString *)text
                                          role:(TSAIInterpreterLineRole)role
                                       isFinal:(BOOL)isFinal {
    UIFont *font = [self textFontForRole:role];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = (role == TSAIInterpreterLineRoleTarget) ? 4.0 : 3.0;

    NSString *body = text.length > 0 ? text : (isFinal ? @"" : @"…");
    UIColor *bodyColor = isFinal ? [UIColor labelColor] : [UIColor secondaryLabelColor];
    NSMutableAttributedString *result =
        [[NSMutableAttributedString alloc] initWithString:body
                                               attributes:@{NSFontAttributeName: font,
                                                            NSForegroundColorAttributeName: bodyColor,
                                                            NSParagraphStyleAttributeName: paragraph}];
    if (!isFinal) {
        NSAttributedString *cursor =
            [[NSAttributedString alloc] initWithString:kLineCellCursorGlyph
                                            attributes:@{NSFontAttributeName: font,
                                                         NSForegroundColorAttributeName: [UIColor systemBlueColor],
                                                         NSParagraphStyleAttributeName: paragraph}];
        [result appendAttributedString:cursor];
    }
    return result;
}

/// 音频状态：done / receiving / waiting + 已收字节数
- (void)bindAudioStatusWithUtterance:(TSAIInterpreterUtteranceUI *)utterance {
    NSString *status;
    UIColor *glyphColor;
    if (utterance.isAudioFinal) {
        status = @"done";
        glyphColor = [UIColor systemBlueColor];
    } else if (utterance.audioBytes > 0) {
        status = @"receiving";
        glyphColor = [UIColor systemOrangeColor];
    } else {
        status = utterance.isTranslatedFinal ? @"waiting" : @"";
        glyphColor = [UIColor tertiaryLabelColor];
    }
    NSString *bytesText = utterance.audioBytes > 0
        ? [NSString stringWithFormat:@" · %lu B", (unsigned long)utterance.audioBytes]
        : @"";
    NSMutableAttributedString *line = [[NSMutableAttributedString alloc] init];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:10.0
                                                                                          weight:UIImageSymbolWeightSemibold];
        UIImage *glyph = [[UIImage systemImageNamed:@"speaker.wave.2.fill" withConfiguration:cfg]
                          imageWithTintColor:glyphColor renderingMode:UIImageRenderingModeAlwaysOriginal];
        attachment.image = glyph;
        attachment.bounds = CGRectMake(0, -1.5, glyph.size.width, glyph.size.height);
        [line appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [line appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    NSString *statusText = [status stringByAppendingString:bytesText];
    [line appendAttributedString:
        [[NSAttributedString alloc] initWithString:statusText
                                        attributes:@{NSFontAttributeName: self.audioLabel.font,
                                                     NSForegroundColorAttributeName: [UIColor tertiaryLabelColor]}]];
    self.audioLabel.attributedText = line;
}

/// 配对高亮优先于最新句高亮
- (void)applyHighlightLatest:(BOOL)isLatest paired:(BOOL)isPaired {
    if (isPaired) {
        self.highlightView.hidden = NO;
        self.highlightView.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.10];
        self.highlightView.layer.borderColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.35].CGColor;
        self.highlightView.layer.borderWidth = 1.0;
    } else if (isLatest) {
        self.highlightView.hidden = NO;
        self.highlightView.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.06];
        self.highlightView.layer.borderWidth = 0.0;
    } else {
        self.highlightView.hidden = YES;
        self.highlightView.layer.borderWidth = 0.0;
    }
}

#pragma mark - 属性（懒加载）

- (UIView *)highlightView {
    if (!_highlightView) {
        _highlightView = [[UIView alloc] init];
        _highlightView.layer.cornerRadius = 10.0;
        _highlightView.hidden = YES;
        _highlightView.userInteractionEnabled = NO;
    }
    return _highlightView;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont monospacedSystemFontOfSize:10.0 weight:UIFontWeightMedium];
        _indexLabel.textColor = [UIColor tertiaryLabelColor];
        _indexLabel.textAlignment = NSTextAlignmentRight;
    }
    return _indexLabel;
}

- (UILabel *)bodyLabel {
    if (!_bodyLabel) {
        _bodyLabel = [[UILabel alloc] init];
        _bodyLabel.numberOfLines = 0;
        _bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _bodyLabel.font = [[self class] textFontForRole:TSAIInterpreterLineRoleSource];
    }
    return _bodyLabel;
}

- (UILabel *)audioLabel {
    if (!_audioLabel) {
        _audioLabel = [[UILabel alloc] init];
        _audioLabel.font = [UIFont monospacedSystemFontOfSize:11.0 weight:UIFontWeightRegular];
        _audioLabel.textColor = [UIColor tertiaryLabelColor];
        _audioLabel.hidden = YES;
    }
    return _audioLabel;
}

@end
