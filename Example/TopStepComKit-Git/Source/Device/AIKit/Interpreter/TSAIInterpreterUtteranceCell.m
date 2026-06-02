//
//  TSAIInterpreterUtteranceCell.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterUtteranceCell.h"

@implementation TSAIInterpreterUtteranceUI
@end

@interface TSAIInterpreterUtteranceCell ()

/// 卡片容器（白底圆角）
@property (nonatomic, strong) UIView *cardView;
/// 序号标签 `#N`
@property (nonatomic, strong) UILabel *indexLabel;
/// 原文标签
@property (nonatomic, strong) UILabel *originalLabel;
/// 译文标签
@property (nonatomic, strong) UILabel *translatedLabel;
/// 音频状态标签（已播字节数 / final 标志）
@property (nonatomic, strong) UILabel *audioLabel;

@end

@implementation TSAIInterpreterUtteranceCell

#pragma mark - 生命周期

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.cardView];
        [self.cardView addSubview:self.indexLabel];
        [self.cardView addSubview:self.originalLabel];
        [self.cardView addSubview:self.translatedLabel];
        [self.cardView addSubview:self.audioLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat cardSide = 14.0;
    CGFloat width = CGRectGetWidth(self.contentView.bounds) - cardSide * 2;
    CGFloat innerPad = 12.0;
    CGFloat textWidth = width - innerPad * 2;

    CGFloat y = 10.0;
    self.indexLabel.frame = CGRectMake(innerPad, y, textWidth, 14.0);
    y += 16.0;

    CGSize origSize = [self.originalLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)];
    self.originalLabel.frame = CGRectMake(innerPad, y, textWidth, origSize.height);
    y += origSize.height + 4.0;

    CGSize transSize = [self.translatedLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)];
    self.translatedLabel.frame = CGRectMake(innerPad, y, textWidth, transSize.height);
    y += transSize.height;

    if (!self.audioLabel.hidden) {
        y += 4.0;
        self.audioLabel.frame = CGRectMake(innerPad, y, textWidth, 14.0);
        y += 14.0;
    }
    y += 10.0;

    self.cardView.frame = CGRectMake(cardSide, 4.0, width, y - 4.0);
}

#pragma mark - 公开方法

- (void)bindWithUtterance:(TSAIInterpreterUtteranceUI *)utterance
                 showAudio:(BOOL)showAudio {
    self.indexLabel.text = [NSString stringWithFormat:@"#%ld", (long)utterance.index];

    NSString *origText = utterance.originalText.length > 0 ? utterance.originalText : @"…";
    if (utterance.isOriginalFinal) {
        self.originalLabel.text = [@"✓ " stringByAppendingString:origText];
        self.originalLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        self.originalLabel.text = [@"▸ " stringByAppendingString:origText];
        self.originalLabel.textColor = [UIColor tertiaryLabelColor];
    }

    NSString *transText = utterance.translatedText.length > 0 ? utterance.translatedText : @"…";
    if (utterance.isTranslatedFinal) {
        self.translatedLabel.text = [@"✓ " stringByAppendingString:transText];
        self.translatedLabel.textColor = [UIColor labelColor];
    } else {
        self.translatedLabel.text = [@"◂ " stringByAppendingString:transText];
        self.translatedLabel.textColor = [UIColor secondaryLabelColor];
    }

    self.audioLabel.hidden = !showAudio;
    if (showAudio) {
        NSString *status = utterance.isAudioFinal ? @"done" : @"playing";
        self.audioLabel.text = [NSString stringWithFormat:@"🔊 %@ · %lu B",
                                  status, (unsigned long)utterance.audioBytes];
    }
}

+ (CGFloat)heightForUtterance:(TSAIInterpreterUtteranceUI *)utterance
                    showAudio:(BOOL)showAudio
                    cellWidth:(CGFloat)cellWidth {
    CGFloat textWidth = cellWidth - 14.0 * 2 - 12.0 * 2;
    UIFont *origFont = [UIFont systemFontOfSize:14.5];
    UIFont *transFont = [UIFont systemFontOfSize:14.5 weight:UIFontWeightMedium];
    NSString *orig = utterance.originalText.length > 0 ? utterance.originalText : @" ";
    NSString *trans = utterance.translatedText.length > 0 ? utterance.translatedText : @" ";
    CGSize origSize = [orig boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: origFont}
                                          context:nil].size;
    CGSize transSize = [trans boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: transFont}
                                            context:nil].size;
    CGFloat height = 10.0 + 16.0 + ceil(origSize.height) + 4.0 + ceil(transSize.height) + 10.0 + 4.0;
    if (showAudio) height += 4.0 + 14.0;
    return height;
}

#pragma mark - 属性（懒加载）

- (UIView *)cardView {
    if (!_cardView) {
        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        _cardView.layer.cornerRadius = 12.0;
    }
    return _cardView;
}

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont monospacedSystemFontOfSize:10.0 weight:UIFontWeightMedium];
        _indexLabel.textColor = [UIColor tertiaryLabelColor];
    }
    return _indexLabel;
}

- (UILabel *)originalLabel {
    if (!_originalLabel) {
        _originalLabel = [[UILabel alloc] init];
        _originalLabel.numberOfLines = 0;
        _originalLabel.font = [UIFont systemFontOfSize:14.5];
    }
    return _originalLabel;
}

- (UILabel *)translatedLabel {
    if (!_translatedLabel) {
        _translatedLabel = [[UILabel alloc] init];
        _translatedLabel.numberOfLines = 0;
        _translatedLabel.font = [UIFont systemFontOfSize:14.5 weight:UIFontWeightMedium];
    }
    return _translatedLabel;
}

- (UILabel *)audioLabel {
    if (!_audioLabel) {
        _audioLabel = [[UILabel alloc] init];
        _audioLabel.font = [UIFont monospacedSystemFontOfSize:10.5 weight:UIFontWeightRegular];
        _audioLabel.textColor = [UIColor tertiaryLabelColor];
    }
    return _audioLabel;
}

@end
