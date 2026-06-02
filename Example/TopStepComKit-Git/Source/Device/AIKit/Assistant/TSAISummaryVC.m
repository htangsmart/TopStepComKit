//
//  TSAISummaryVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAISummaryVC.h"
#import "TSAIStreamTextView.h"
#import "TSAILogView.h"

#pragma mark - 状态机

typedef NS_ENUM(NSInteger, TSAISummaryState) {
    TSAISummaryStateIdle = 0,
    TSAISummaryStateRunning,
    TSAISummaryStateDone,
    TSAISummaryStateCancelled,
    TSAISummaryStateFailed,
    TSAISummaryStateUnsupported,
};

#pragma mark - VC

@interface TSAISummaryVC () <UITextViewDelegate>

// AI 助手实例
@property (nonatomic, strong, nullable) id<TSAIAssistantInterface> assistant;
// 当前进行中的任务 ID（nil 表示空闲）
@property (nonatomic, copy, nullable) NSString *currentTaskId;
// 收到的 partial 计数（仅日志用）
@property (nonatomic, assign) NSUInteger partialCount;

// 滚动容器，承载页面所有内容
@property (nonatomic, strong) UIScrollView *scrollView;

// 输入卡片
@property (nonatomic, strong) UIView      *inputCard;
@property (nonatomic, strong) UILabel     *inputTitleLabel;
@property (nonatomic, strong) UIButton    *sampleButton;
@property (nonatomic, strong) UITextView  *inputTextView;
@property (nonatomic, strong) UILabel     *inputPlaceholderLabel;
@property (nonatomic, strong) UILabel     *charCountLabel;

// 主按钮（生成总结 / 总结中…+菊花），自管 label + indicator，避免 UIButton 默认布局重叠
@property (nonatomic, strong) UIButton    *primaryButton;
@property (nonatomic, strong) UILabel     *primaryButtonLabel;
@property (nonatomic, strong) UIActivityIndicatorView *primaryButtonIndicator;

// 取消按钮（仅 Running 时 enabled）
@property (nonatomic, strong) UIButton    *cancelButton;

// 流式输出区右上角的状态徽章（Done/Cancelled/Failed 时显示，Idle/Running 隐藏）
@property (nonatomic, strong) UIView      *resultAccessoryView;
@property (nonatomic, strong) UIView      *statusBadge;
@property (nonatomic, strong) UILabel     *statusLabel;
@property (nonatomic, strong) UILabel     *durationLabel;

// 流式输出区
@property (nonatomic, strong) TSAIStreamTextView *streamView;

// 日志区
@property (nonatomic, strong) TSAILogView *logView;

// 状态
@property (nonatomic, assign) TSAISummaryState currentState;

@end

@implementation TSAISummaryVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"ai_summary.title");
    self.assistant = [[TopStepComKit sharedInstance] aiAssistant];
    if (self.assistant && [self.assistant isSupport]) {
        self.currentState = TSAISummaryStateIdle;
    } else {
        self.currentState = TSAISummaryStateUnsupported;
    }
}

- (void)setupViews {
    [self.view addSubview:self.scrollView];

    [self.scrollView addSubview:self.inputCard];
    [self.inputCard addSubview:self.inputTitleLabel];
    [self.inputCard addSubview:self.sampleButton];
    [self.inputCard addSubview:self.inputTextView];
    [self.inputTextView addSubview:self.inputPlaceholderLabel];
    [self.inputCard addSubview:self.charCountLabel];

    [self.scrollView addSubview:self.primaryButton];
    [self.primaryButton addSubview:self.primaryButtonIndicator];
    [self.primaryButton addSubview:self.primaryButtonLabel];
    [self.scrollView addSubview:self.cancelButton];

    // 组装结果区右上角附件视图
    [self.resultAccessoryView addSubview:self.statusBadge];
    [self.statusBadge addSubview:self.statusLabel];
    [self.resultAccessoryView addSubview:self.durationLabel];
    self.streamView.accessoryView = self.resultAccessoryView;

    [self.scrollView addSubview:self.streamView];
    [self.scrollView addSubview:self.logView];

    [self refreshUIForState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 离开页面时自动取消进行中任务，避免 VC 销毁后回调悬挂
    if (self.currentTaskId.length > 0 && self.assistant) {
        [self.assistant cancelSummarizeWithTaskId:self.currentTaskId];
        self.currentTaskId = nil;
    }
}

- (void)dealloc {
    if (_currentTaskId.length > 0 && _assistant) {
        [_assistant cancelSummarizeWithTaskId:_currentTaskId];
    }
}

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;

    CGFloat margin = TSSpacing_MD;
    CGFloat fullWidth = CGRectGetWidth(self.view.bounds);
    CGFloat fullHeight = CGRectGetHeight(self.view.bounds);
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    CGFloat contentWidth = fullWidth - margin * 2;

    CGFloat buttonHeight = 48.f;
    CGFloat gap = TSSpacing_SM;

    // 各模块使用固定高度，使内容可超过屏幕从而触发滚动
    CGFloat inputHeight  = 220.f;
    CGFloat streamHeight = 260.f;
    CGFloat logHeight    = 220.f;

    // 滚动容器：占据导航栏下方到屏幕底部
    self.scrollView.frame = CGRectMake(0, topOffset, fullWidth, fullHeight - topOffset);

    CGFloat y = margin;

    // 输入卡片
    self.inputCard.frame = CGRectMake(margin, y, contentWidth, inputHeight);
    {
        CGFloat pad = TSSpacing_SM;
        CGFloat headerH = 22.f;
        self.inputTitleLabel.frame = CGRectMake(pad, pad, contentWidth - 80.f - pad * 2, headerH);
        self.sampleButton.frame    = CGRectMake(contentWidth - 80.f - pad, pad, 80.f, headerH);

        CGFloat charLabelH = 18.f;
        CGFloat textY = pad + headerH + TSSpacing_XS;
        CGFloat textH = inputHeight - textY - charLabelH - pad;
        self.inputTextView.frame = CGRectMake(pad, textY, contentWidth - pad * 2, textH);
        self.inputPlaceholderLabel.frame = CGRectMake(TSSpacing_XS, TSSpacing_XS,
                                                      CGRectGetWidth(self.inputTextView.bounds) - TSSpacing_XS * 2,
                                                      20.f);
        self.charCountLabel.frame = CGRectMake(pad,
                                                inputHeight - charLabelH - pad / 2.f,
                                                contentWidth - pad * 2,
                                                charLabelH);
    }
    y += inputHeight + gap;

    // 双按钮平级：primary 左 60%，cancel 右 40%
    CGFloat primaryWidth = (contentWidth - gap) * 0.62f;
    CGFloat cancelWidth  = contentWidth - gap - primaryWidth;
    self.primaryButton.frame = CGRectMake(margin, y, primaryWidth, buttonHeight);
    self.cancelButton.frame  = CGRectMake(margin + primaryWidth + gap, y, cancelWidth, buttonHeight);
    [self layoutPrimaryButtonContent];
    y += buttonHeight + gap;

    // 流式输出
    self.streamView.frame = CGRectMake(margin, y, contentWidth, streamHeight);
    [self layoutResultAccessory];
    y += streamHeight + gap;

    // 日志
    self.logView.frame = CGRectMake(margin, y, contentWidth, logHeight);
    y += logHeight + margin;

    self.scrollView.contentSize = CGSizeMake(fullWidth, y + bottomInset);
}

/// 布局结果区右上角的徽章 + duration
- (void)layoutResultAccessory {
    CGFloat badgeH = 22.f;
    CGFloat badgeW = 80.f;
    CGFloat durationW = 64.f;
    CGFloat innerGap = 6.f;

    BOOL showBadge = !self.statusBadge.hidden;
    BOOL showDuration = !self.durationLabel.hidden;

    CGFloat totalW = 0;
    if (showBadge)    totalW += badgeW;
    if (showDuration) totalW += (totalW > 0 ? innerGap : 0) + durationW;
    if (totalW <= 0) totalW = 1.f;  // 占位避免 0 宽度

    self.resultAccessoryView.frame = CGRectMake(0, 0, totalW, badgeH);

    CGFloat x = 0;
    if (showBadge) {
        self.statusBadge.frame = CGRectMake(x, 0, badgeW, badgeH);
        self.statusBadge.layer.cornerRadius = badgeH / 2.f;
        self.statusLabel.frame = self.statusBadge.bounds;
        x += badgeW + innerGap;
    }
    if (showDuration) {
        self.durationLabel.frame = CGRectMake(x, 0, durationW, badgeH);
    }
    [self.streamView setNeedsLayout];
}

/// 布局主按钮内部：[ 菊花(可选) + gap ] + 居中文字；indicator 与 label 不会重叠
- (void)layoutPrimaryButtonContent {
    CGFloat buttonW = CGRectGetWidth(self.primaryButton.bounds);
    CGFloat buttonH = CGRectGetHeight(self.primaryButton.bounds);
    if (buttonW <= 0 || buttonH <= 0) return;

    CGFloat indicatorSize = 16.f;
    CGFloat innerGap = 8.f;

    self.primaryButtonLabel.font = TSFont_H2;
    CGSize textSize = [(self.primaryButtonLabel.text ?: @"")
                       sizeWithAttributes:@{NSFontAttributeName: TSFont_H2}];
    CGFloat textW = ceilf((float)textSize.width);

    BOOL showIndicator = !self.primaryButtonIndicator.hidden;
    CGFloat groupW = showIndicator ? (indicatorSize + innerGap + textW) : textW;
    groupW = MIN(groupW, buttonW - 16.f);
    CGFloat startX = (buttonW - groupW) / 2.f;

    if (showIndicator) {
        self.primaryButtonIndicator.frame = CGRectMake(startX,
                                                        (buttonH - indicatorSize) / 2.f,
                                                        indicatorSize, indicatorSize);
        self.primaryButtonLabel.frame = CGRectMake(startX + indicatorSize + innerGap,
                                                    0,
                                                    groupW - indicatorSize - innerGap,
                                                    buttonH);
    } else {
        self.primaryButtonLabel.frame = CGRectMake(startX, 0, groupW, buttonH);
    }
}

#pragma mark - 公开方法 / 状态机

/// 切换状态并刷新 UI
- (void)setCurrentState:(TSAISummaryState)currentState {
    _currentState = currentState;
    [self refreshUIForState];
}

#pragma mark - 私有方法

/// 根据当前状态刷新按钮 / 徽章 / 占位符
- (void)refreshUIForState {
    BOOL hasInput = [self trimmedInputText].length > 0;
    BOOL supported = (self.currentState != TSAISummaryStateUnsupported);

    // ── 主按钮：Idle/Done/Cancelled/Failed → 蓝底「生成总结」；Running → 白底蓝边「总结中…」+菊花
    NSString *title = nil;
    UIColor  *titleColor = nil;
    UIColor  *bgColor = nil;
    UIColor  *borderColor = nil;
    BOOL primaryEnabled = NO;
    BOOL showIndicator = NO;
    BOOL cancelEnabled = NO;

    switch (self.currentState) {
        case TSAISummaryStateIdle:
        case TSAISummaryStateDone:
        case TSAISummaryStateCancelled:
        case TSAISummaryStateFailed:
            title          = TSLocalizedString(@"ai_summary.summarize");
            titleColor     = [UIColor whiteColor];
            bgColor        = TSColor_Primary;
            borderColor    = nil;
            primaryEnabled = supported && hasInput;
            cancelEnabled  = NO;
            break;
        case TSAISummaryStateRunning:
            title          = TSLocalizedString(@"ai_summary.status_running");
            titleColor     = TSColor_Primary;
            bgColor        = TSColor_Card;
            borderColor    = TSColor_Primary;
            primaryEnabled = NO;        // Running 期间主按钮 disable，取消改由 cancel 按钮触发
            cancelEnabled  = YES;
            showIndicator  = YES;
            break;
        case TSAISummaryStateUnsupported:
            title          = TSLocalizedString(@"ai_summary.summarize");
            titleColor     = [UIColor whiteColor];
            bgColor        = TSColor_Primary;
            borderColor    = nil;
            primaryEnabled = NO;
            cancelEnabled  = NO;
            break;
    }
    self.primaryButtonLabel.text      = title;
    self.primaryButtonLabel.textColor = primaryEnabled ? titleColor : [titleColor colorWithAlphaComponent:0.5f];
    self.primaryButton.backgroundColor    = bgColor;
    self.primaryButton.layer.borderWidth  = borderColor ? 1.f : 0.f;
    self.primaryButton.layer.borderColor  = borderColor.CGColor;
    self.primaryButton.enabled = primaryEnabled;
    self.primaryButton.alpha   = primaryEnabled ? 1.f : 0.5f;

    self.primaryButtonIndicator.hidden = !showIndicator;
    if (showIndicator) {
        self.primaryButtonIndicator.color = TSColor_Primary;
        [self.primaryButtonIndicator startAnimating];
    } else {
        [self.primaryButtonIndicator stopAnimating];
    }

    self.cancelButton.enabled = cancelEnabled;
    self.cancelButton.alpha   = cancelEnabled ? 1.f : 0.4f;

    [self layoutPrimaryButtonContent];

    // ── 输入区是否可编辑
    self.inputTextView.editable = supported;
    self.sampleButton.enabled = supported;
    self.sampleButton.alpha = supported ? 1.f : 0.4f;

    // ── 结果区右上角徽章：仅 Done/Cancelled/Failed/Unsupported 显示
    BOOL showBadge = NO;
    NSString *statusText = nil;
    UIColor  *badgeColor = TSColor_TextSecondary;
    BOOL showDuration = NO;

    switch (self.currentState) {
        case TSAISummaryStateDone:
            statusText = TSLocalizedString(@"ai_summary.status_done");
            badgeColor = TSColor_Success;
            showBadge = YES;
            showDuration = YES;
            break;
        case TSAISummaryStateCancelled:
            statusText = TSLocalizedString(@"ai_summary.status_cancelled");
            badgeColor = TSColor_Warning;
            showBadge = YES;
            break;
        case TSAISummaryStateFailed:
            statusText = TSLocalizedString(@"ai_summary.status_failed");
            badgeColor = TSColor_Danger;
            showBadge = YES;
            break;
        case TSAISummaryStateUnsupported:
            statusText = TSLocalizedString(@"ai_summary.status_unsupported");
            badgeColor = TSColor_TextSecondary;
            showBadge = YES;
            break;
        case TSAISummaryStateIdle:
        case TSAISummaryStateRunning:
            showBadge = NO;
            break;
    }
    self.statusLabel.text = statusText;
    self.statusBadge.backgroundColor = [badgeColor colorWithAlphaComponent:0.15f];
    self.statusLabel.textColor = badgeColor;
    self.statusBadge.hidden = !showBadge;
    self.durationLabel.hidden = !showDuration;

    [self.view setNeedsLayout];
    [self.streamView setNeedsLayout];
}

/// 取 trimmed 后的输入文本
- (NSString *)trimmedInputText {
    NSString *text = self.inputTextView.text ?: @"";
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/// 刷新字符数与占位符显隐
- (void)refreshInputAffordances {
    NSInteger length = (NSInteger)self.inputTextView.text.length;
    self.charCountLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_summary.chars_fmt"), (long)length];
    self.inputPlaceholderLabel.hidden = (length > 0);
}

/// 把错误信息以红字 + 淡红底直接展示到流式输出区
- (void)showErrorInStreamView:(NSError *)error {
    NSString *detail = [NSString stringWithFormat:TSLocalizedString(@"ai_summary.failed_fmt"),
                        error.domain ?: @"-",
                        (long)error.code,
                        error.localizedDescription ?: @"-"];
    self.streamView.textColor = TSColor_Danger;
    self.streamView.contentBackgroundColor = [TSColor_Danger colorWithAlphaComponent:0.12f];
    self.streamView.text = detail;
}

/// 把流式输出区恢复成默认配色（每次新一轮总结开始前调用）
- (void)resetStreamViewAppearance {
    self.streamView.textColor = nil;
    self.streamView.contentBackgroundColor = nil;
}

#pragma mark - 事件

/// 点击「示例」按钮
- (void)onSampleButtonTapped {
    self.inputTextView.text = TSLocalizedString(@"ai_summary.sample_text");
    [self refreshInputAffordances];
    [self refreshUIForState];
}

/// 主按钮点击 = 触发总结（Running 期间已 disabled，不会进入此路径）
- (void)onPrimaryButtonTapped {
    [self triggerSummarize];
}

/// 取消按钮点击 = 触发取消（仅 Running 期间 enabled）
- (void)onCancelButtonTapped {
    [self triggerCancel];
}

/// 触发总结：调用 SDK，回调切主线程喂 streamView / logView / duration
- (void)triggerSummarize {
    if (![self.assistant isSupport]) {
        [self.logView appendLine:TSLocalizedString(@"ai_summary.toast_unavailable")];
        return;
    }
    NSString *source = [self trimmedInputText];
    if (source.length == 0) {
        [self.logView appendLine:TSLocalizedString(@"ai_summary.toast_empty_input")];
        return;
    }

    [self.inputTextView resignFirstResponder];
    [self.streamView reset];
    [self resetStreamViewAppearance];
    self.durationLabel.text = nil;
    self.partialCount = 0;
    [self.logView appendLineWithFormat:@"▶ summarize, len=%ld", (long)source.length];
    self.currentState = TSAISummaryStateRunning;

    __weak typeof(self) weakSelf = self;
    NSString *taskId = [self.assistant summarizeText:source
                                      onPartialResult:^(TSAISummaryPartialResult *partial) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            // 校验 taskId 一致，避免上一个任务的迟到回调污染 UI
            if (![partial.taskId isEqualToString:strongSelf.currentTaskId]) return;
            strongSelf.partialCount += 1;
            strongSelf.streamView.text = partial.text ?: @"";
            [strongSelf.logView appendLineWithFormat:@"  partial #%lu len=%lu",
                (unsigned long)strongSelf.partialCount,
                (unsigned long)partial.text.length];
        });
    }
                                           completion:^(TSAISummaryResult * _Nullable result,
                                                        NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            // 校验 taskId 一致
            NSString *callbackTaskId = result.taskId ?: strongSelf.currentTaskId;
            if (callbackTaskId.length > 0 && strongSelf.currentTaskId.length > 0
                && ![callbackTaskId isEqualToString:strongSelf.currentTaskId]) return;

            if (error) {
                BOOL isCancel = (error.code == eTSErrorUserCancelled);
                strongSelf.currentState = isCancel ? TSAISummaryStateCancelled : TSAISummaryStateFailed;
                if (isCancel) {
                    [strongSelf.logView appendLineWithFormat:@"✕ cancelled: %@", error.localizedDescription ?: @""];
                } else {
                    [strongSelf showErrorInStreamView:error];
                    [strongSelf.logView appendLineWithFormat:@"✕ failed: domain=%@ code=%ld msg=%@",
                        error.domain, (long)error.code, error.localizedDescription ?: @""];
                }
            } else {
                strongSelf.streamView.text = result.text ?: @"";
                strongSelf.durationLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_summary.duration_fmt"), result.duration];
                strongSelf.currentState = TSAISummaryStateDone;
                [strongSelf.logView appendLineWithFormat:@"✓ done, duration=%.2fs, len=%lu",
                    result.duration, (unsigned long)result.text.length];
            }
            strongSelf.currentTaskId = nil;
        });
    }];

    self.currentTaskId = taskId;
    [self.logView appendLineWithFormat:@"  taskId=%@", taskId];
}

/// 触发取消：通过 taskId 转发到 SDK，最终 completion 回调会以 cancel error 回来
- (void)triggerCancel {
    if (self.currentTaskId.length == 0) return;
    [self.logView appendLineWithFormat:@"▶ cancel taskId=%@", self.currentTaskId];
    [self.assistant cancelSummarizeWithTaskId:self.currentTaskId];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self refreshInputAffordances];
    [self refreshUIForState];
}

#pragma mark - 属性（懒加载）

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _scrollView;
}

- (UIView *)inputCard {
    if (!_inputCard) {
        _inputCard = [[UIView alloc] init];
        _inputCard.backgroundColor = TSColor_Card;
        _inputCard.layer.cornerRadius = TSRadius_MD;
    }
    return _inputCard;
}

- (UILabel *)inputTitleLabel {
    if (!_inputTitleLabel) {
        _inputTitleLabel = [[UILabel alloc] init];
        _inputTitleLabel.font = TSFont_H2;
        _inputTitleLabel.textColor = TSColor_TextPrimary;
        _inputTitleLabel.text = TSLocalizedString(@"ai_summary.source");
    }
    return _inputTitleLabel;
}

- (UIButton *)sampleButton {
    if (!_sampleButton) {
        _sampleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_sampleButton setTitle:TSLocalizedString(@"ai_summary.sample") forState:UIControlStateNormal];
        _sampleButton.titleLabel.font = TSFont_Caption;
        [_sampleButton setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _sampleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_sampleButton addTarget:self
                          action:@selector(onSampleButtonTapped)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _sampleButton;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] init];
        _inputTextView.delegate = self;
        _inputTextView.font = TSFont_Body;
        _inputTextView.textColor = TSColor_TextPrimary;
        _inputTextView.backgroundColor = TSColor_Background;
        _inputTextView.layer.cornerRadius = TSRadius_SM;
        _inputTextView.textContainerInset = UIEdgeInsetsMake(TSSpacing_XS, TSSpacing_XS, TSSpacing_XS, TSSpacing_XS);
        _inputTextView.alwaysBounceVertical = YES;
    }
    return _inputTextView;
}

- (UILabel *)inputPlaceholderLabel {
    if (!_inputPlaceholderLabel) {
        _inputPlaceholderLabel = [[UILabel alloc] init];
        _inputPlaceholderLabel.font = TSFont_Body;
        _inputPlaceholderLabel.textColor = TSColor_TextSecondary;
        _inputPlaceholderLabel.text = TSLocalizedString(@"ai_summary.source_placeholder");
        _inputPlaceholderLabel.userInteractionEnabled = NO;
    }
    return _inputPlaceholderLabel;
}

- (UILabel *)charCountLabel {
    if (!_charCountLabel) {
        _charCountLabel = [[UILabel alloc] init];
        _charCountLabel.font = TSFont_Caption;
        _charCountLabel.textColor = TSColor_TextSecondary;
        _charCountLabel.textAlignment = NSTextAlignmentRight;
        _charCountLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_summary.chars_fmt"), (long)0];
    }
    return _charCountLabel;
}

- (UIButton *)primaryButton {
    if (!_primaryButton) {
        _primaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _primaryButton.layer.cornerRadius = TSRadius_SM;
        _primaryButton.layer.masksToBounds = YES;
        [_primaryButton addTarget:self
                           action:@selector(onPrimaryButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _primaryButton;
}

- (UILabel *)primaryButtonLabel {
    if (!_primaryButtonLabel) {
        _primaryButtonLabel = [[UILabel alloc] init];
        _primaryButtonLabel.font = TSFont_H2;
        _primaryButtonLabel.textAlignment = NSTextAlignmentLeft;
        _primaryButtonLabel.userInteractionEnabled = NO;
    }
    return _primaryButtonLabel;
}

- (UIActivityIndicatorView *)primaryButtonIndicator {
    if (!_primaryButtonIndicator) {
        if (@available(iOS 13.0, *)) {
            _primaryButtonIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _primaryButtonIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _primaryButtonIndicator.hidesWhenStopped = YES;
        _primaryButtonIndicator.userInteractionEnabled = NO;
    }
    return _primaryButtonIndicator;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:TSLocalizedString(@"ai_summary.cancel") forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = TSFont_H2;
        [_cancelButton setTitleColor:TSColor_Danger forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [TSColor_Danger colorWithAlphaComponent:0.10f];
        _cancelButton.layer.cornerRadius = TSRadius_SM;
        [_cancelButton addTarget:self
                          action:@selector(onCancelButtonTapped)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIView *)resultAccessoryView {
    if (!_resultAccessoryView) {
        _resultAccessoryView = [[UIView alloc] init];
    }
    return _resultAccessoryView;
}

- (UIView *)statusBadge {
    if (!_statusBadge) {
        _statusBadge = [[UIView alloc] init];
        _statusBadge.layer.masksToBounds = YES;
    }
    return _statusBadge;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = TSFont_Caption;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = TSFont_Caption;
        _durationLabel.textColor = TSColor_TextSecondary;
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.hidden = YES;
    }
    return _durationLabel;
}

- (TSAIStreamTextView *)streamView {
    if (!_streamView) {
        _streamView = [[TSAIStreamTextView alloc] init];
        _streamView.title = TSLocalizedString(@"ai_summary.summary_streaming");
    }
    return _streamView;
}

- (TSAILogView *)logView {
    if (!_logView) {
        _logView = [[TSAILogView alloc] init];
    }
    return _logView;
}

@end
