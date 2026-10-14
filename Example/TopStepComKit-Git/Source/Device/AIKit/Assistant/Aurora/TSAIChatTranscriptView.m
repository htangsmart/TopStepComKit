//
//  TSAIChatTranscriptView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIChatTranscriptView.h"

#import "TSAIChatTheme.h"

/// 一行记录：问题（ink3/600）或回答（ink，左竖条）
@interface TSAIChatTranscriptRow : UIView
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) CAGradientLayer *barLayer;
@property (nonatomic, strong) UIView *cursor;
@property (nonatomic, strong) UIView *dots;
@property (nonatomic, assign) BOOL isAnswer;
@property (nonatomic, assign) BOOL entered;
- (CGFloat)heightForWidth:(CGFloat)width;
@end

@implementation TSAIChatTranscriptRow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] init];
        _label.numberOfLines = 0;
        [self addSubview:_label];
        _barLayer = [CAGradientLayer layer];
        _barLayer.colors = @[(id)TSAIChatSkyColor().CGColor, (id)TSAIChatMintColor().CGColor];
        _barLayer.startPoint = CGPointMake(0.5, 0);
        _barLayer.endPoint = CGPointMake(0.5, 1);
        _barLayer.cornerRadius = 1.5;
        _barLayer.hidden = YES;
        [self.layer addSublayer:_barLayer];
        _cursor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 16)];
        _cursor.layer.cornerRadius = 1;
        _cursor.hidden = YES;
        [self addSubview:_cursor];
        _dots = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 31, 17)];
        NSArray<UIColor *> *colors = @[TSAIChatVioletColor(), TSAIChatSkyColor(), TSAIChatMintColor()];
        for (NSInteger index = 0; index < 3; index++) {
            UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(index * 12, 5, 7, 7)];
            dot.backgroundColor = colors[index];
            dot.layer.cornerRadius = 3.5;
            [_dots addSubview:dot];
        }
        _dots.hidden = YES;
        [self addSubview:_dots];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat inset = self.isAnswer ? 14 : 0;
    CGSize textSize = [self.label sizeThatFits:CGSizeMake(width - inset - 8, CGFLOAT_MAX)];
    self.label.frame = CGRectMake(inset, 0, width - inset - 8, ceil(textSize.height));
    self.barLayer.frame = CGRectMake(0, 4, 3, MAX(0, CGRectGetHeight(self.bounds) - 8));
    self.barLayer.hidden = !self.isAnswer;
    CGFloat textWidth = ceil(textSize.width);
    self.cursor.frame = CGRectMake(inset + MIN(textWidth, width - inset - 8) + 3, CGRectGetHeight(self.label.frame) - 19, 2, 16);
    self.dots.frame = CGRectMake(inset, 2, 31, 17);
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat inset = self.isAnswer ? 14 : 0;
    if (!self.dots.hidden) return 21;
    return ceil([self.label sizeThatFits:CGSizeMake(width - inset - 8, CGFLOAT_MAX)].height);
}

@end

@interface TSAIChatTranscriptView ()

// roundId → 问题行 / 回答行
@property (nonatomic, strong) NSMutableDictionary<NSString *, TSAIChatTranscriptRow *> *questionRows;
@property (nonatomic, strong) NSMutableDictionary<NSString *, TSAIChatTranscriptRow *> *answerRows;
// 当前顺序
@property (nonatomic, strong) NSMutableArray<TSAIChatTranscriptRow *> *orderedRows;
// 空态
@property (nonatomic, strong) UILabel *emptyLabel;
// 光标定时器
@property (nonatomic, strong, nullable) NSTimer *cursorTimer;

@end

@implementation TSAIChatTranscriptView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceVertical = YES;
        self.showsVerticalScrollIndicator = NO;
        _questionRows = [NSMutableDictionary dictionary];
        _answerRows = [NSMutableDictionary dictionary];
        _orderedRows = [NSMutableArray array];
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.font = TSAIChatFont(13, UIFontWeightRegular);
        _emptyLabel.textColor = TSAIChatInk3Color();
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_emptyLabel];
    }
    return self;
}

- (void)dealloc {
    [_cursorTimer invalidate];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat contentWidth = width - 44;
    CGFloat y = 44;
    for (TSAIChatTranscriptRow *row in self.orderedRows) {
        CGFloat height = [row heightForWidth:contentWidth];
        row.frame = CGRectMake(22, y, contentWidth, height);
        y += height + 14;
    }
    self.contentSize = CGSizeMake(width, MAX(CGRectGetHeight(self.bounds), y - 14 + 16));
    self.emptyLabel.frame = CGRectMake(22, (CGRectGetHeight(self.bounds) - 20) / 2, contentWidth, 20);
    self.emptyLabel.hidden = self.orderedRows.count > 0;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    [self updateCursorTimer];
}

#pragma mark - 公开方法

- (void)setEmptyText:(NSString *)emptyText {
    _emptyText = [emptyText copy];
    self.emptyLabel.text = emptyText ?: @"";
}

- (void)updateWithRounds:(NSArray<TSAIChatRoundModel *> *)rounds thinking:(BOOL)thinking {
    NSMutableArray<TSAIChatTranscriptRow *> *ordered = [NSMutableArray array];
    NSMutableSet<NSString *> *liveIds = [NSMutableSet set];
    NSMutableArray<TSAIChatTranscriptRow *> *newRows = [NSMutableArray array];

    for (TSAIChatRoundModel *round in rounds) {
        [liveIds addObject:round.roundId];
        BOOL inProgress = [round isInProgress];
        if (round.question.length > 0) {
            TSAIChatTranscriptRow *questionRow = self.questionRows[round.roundId];
            if (!questionRow) {
                questionRow = [[TSAIChatTranscriptRow alloc] init];
                questionRow.isAnswer = NO;
                self.questionRows[round.roundId] = questionRow;
                [self addSubview:questionRow];
                [newRows addObject:questionRow];
            }
            questionRow.label.attributedText = [self textWithString:round.question
                                                               font:TSAIChatFont(16, UIFontWeightSemibold)
                                                              color:TSAIChatInk3Color()];
            questionRow.cursor.backgroundColor = TSAIChatInk3Color();
            questionRow.cursor.hidden = !(inProgress && !round.questionFinal);
            questionRow.dots.hidden = YES;
            [ordered addObject:questionRow];
        }
        // 执行不了的指令意图（如播放音乐）收口后没有回答：用「已识别：… · 当前设备暂不支持」占回答位
        BOOL showsNotice = round.answer.length == 0 && round.state == TSAIChatRoundStateError &&
                           round.intentStatus == TSAIChatRoundIntentStatusUnsupported && round.errorBodyText.length > 0;
        NSString *answerText = showsNotice ? round.errorBodyText : round.answer;
        BOOL showAnswerRow = answerText.length > 0 || (inProgress && thinking && round.question.length > 0);
        if (showAnswerRow) {
            TSAIChatTranscriptRow *answerRow = self.answerRows[round.roundId];
            if (!answerRow) {
                answerRow = [[TSAIChatTranscriptRow alloc] init];
                answerRow.isAnswer = YES;
                self.answerRows[round.roundId] = answerRow;
                [self addSubview:answerRow];
                [newRows addObject:answerRow];
            }
            BOOL showDots = answerText.length == 0;
            answerRow.dots.hidden = !showDots;
            answerRow.label.hidden = showDots;
            answerRow.label.attributedText = [self textWithString:answerText ?: @""
                                                             font:TSAIChatFont(16, UIFontWeightRegular)
                                                            color:showsNotice ? TSAIChatInk2Color() : TSAIChatInkColor()];
            answerRow.cursor.backgroundColor = TSAIChatSkyColor();
            answerRow.cursor.hidden = !(inProgress && !showDots && !round.answerFinal);
            [ordered addObject:answerRow];
        }
    }

    for (NSString *roundId in [self.questionRows allKeys]) {
        if (![liveIds containsObject:roundId]) {
            [self.questionRows[roundId] removeFromSuperview];
            [self.questionRows removeObjectForKey:roundId];
        }
    }
    for (NSString *roundId in [self.answerRows allKeys]) {
        if (![liveIds containsObject:roundId]) {
            [self.answerRows[roundId] removeFromSuperview];
            [self.answerRows removeObjectForKey:roundId];
        }
    }

    self.orderedRows = ordered;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    for (TSAIChatTranscriptRow *row in newRows) {
        if (!row.entered) {
            row.entered = YES;
            TSAIChatPopIn(row, 0.4, 0);
        }
    }
    [self updateCursorTimer];
    [self scrollToBottomAnimated:YES];
}

- (void)clear {
    for (UIView *row in self.orderedRows) [row removeFromSuperview];
    for (UIView *row in self.questionRows.allValues) [row removeFromSuperview];
    for (UIView *row in self.answerRows.allValues) [row removeFromSuperview];
    [self.orderedRows removeAllObjects];
    [self.questionRows removeAllObjects];
    [self.answerRows removeAllObjects];
    [self setNeedsLayout];
}

#pragma mark - 私有方法

/// 16pt 行高 1.55
- (NSAttributedString *)textWithString:(NSString *)string font:(UIFont *)font color:(UIColor *)color {
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineSpacing = 16 * 0.55 - 3;
    return [[NSAttributedString alloc] initWithString:string
                                           attributes:@{NSFontAttributeName: font,
                                                        NSForegroundColorAttributeName: color,
                                                        NSParagraphStyleAttributeName: paragraph}];
}

/// 新行自动滚到底
- (void)scrollToBottomAnimated:(BOOL)animated {
    CGFloat bottom = self.contentSize.height - CGRectGetHeight(self.bounds);
    if (bottom > 0) {
        [self setContentOffset:CGPointMake(0, bottom) animated:animated];
    }
}

/// 光标闪烁
- (void)updateCursorTimer {
    BOOL needs = NO;
    for (TSAIChatTranscriptRow *row in self.orderedRows) {
        if (!row.cursor.hidden) { needs = YES; break; }
    }
    if (needs && self.window) {
        if (!self.cursorTimer) {
            self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                target:self
                                                              selector:@selector(onCursorTick)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    } else {
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
    }
}

#pragma mark - 事件

- (void)onCursorTick {
    for (TSAIChatTranscriptRow *row in self.orderedRows) {
        if (!row.cursor.hidden) row.cursor.alpha = row.cursor.alpha > 0.5 ? 0 : 1;
    }
}

@end
