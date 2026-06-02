//
//  TSAITranslateVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAITranslateVC.h"
#import "TSAIStreamTextView.h"
#import "TSAILogView.h"

/// 输入文本最大字符数
static const NSUInteger kTSAITranslateMaxChars = 5000;

@interface TSAITranslateVC () <UITextViewDelegate>

#pragma mark - 滚动容器
/// 滚动容器，承载页面所有内容
@property (nonatomic, strong) UIScrollView *scrollView;

#pragma mark - 输入区
/// 源文本输入框
@property (nonatomic, strong) UITextView *inputTextView;
/// 输入占位 label（UITextView 没有原生 placeholder）
@property (nonatomic, strong) UILabel *placeholderLabel;
/// 字符计数 label
@property (nonatomic, strong) UILabel *charCountLabel;
/// 输入框右上角：一键填示例
@property (nonatomic, strong) UIButton *exampleButton;
/// 输入框右上角：清空输入框
@property (nonatomic, strong) UIButton *inputClearButton;

#pragma mark - Pair Bar
/// Pair Bar 容器
@property (nonatomic, strong) UIView *pairBarView;
/// 源语言按钮
@property (nonatomic, strong) UIButton *sourceLanguageButton;
/// 互换按钮
@property (nonatomic, strong) UIButton *swapButton;
/// 目标语言按钮
@property (nonatomic, strong) UIButton *targetLanguageButton;

#pragma mark - 操作区
/// 触发翻译按钮
@property (nonatomic, strong) UIButton *translateButton;
/// 取消翻译按钮
@property (nonatomic, strong) UIButton *cancelButton;

#pragma mark - 输出区
/// 流式译文展示
@property (nonatomic, strong) TSAIStreamTextView *streamView;
/// 日志展示
@property (nonatomic, strong) TSAILogView *logView;

#pragma mark - 状态
/// 当前选中的源语言
@property (nonatomic, assign) TSAILanguage selectedSourceLanguage;
/// 当前选中的目标语言
@property (nonatomic, assign) TSAILanguage selectedTargetLanguage;
/// 当前进行中的任务 ID（nil 表示空闲）
@property (nonatomic, copy, nullable) NSString *currentTaskId;
/// 已收到的 partial 计数（仅日志用）
@property (nonatomic, assign) NSUInteger partialCount;

@end

@implementation TSAITranslateVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"ai_translate.title");
    self.selectedSourceLanguage = TSAILanguageAuto;
    self.selectedTargetLanguage = TSAILanguageEnglishUS;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupViews];
    [self refreshLanguageButtons];
    [self refreshSwapButtonState];
    [self refreshButtonsForState];
    [self refreshCharCount];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.currentTaskId.length > 0) {
        [self.logView appendLineWithFormat:@"viewWillDisappear: auto-cancel taskId=%@", self.currentTaskId];
        [[[TopStepComKit sharedInstance] aiTranslate] cancelTranslationWithTaskId:self.currentTaskId];
    }
}

- (void)dealloc {
    if (_currentTaskId.length > 0) {
        [[[TopStepComKit sharedInstance] aiTranslate] cancelTranslationWithTaskId:_currentTaskId];
    }
}

#pragma mark - 私有方法 - 视图搭建

/// 添加所有子视图
- (void)setupViews {
    [self.view addSubview:self.scrollView];

    [self.scrollView addSubview:self.inputTextView];
    [self.inputTextView addSubview:self.placeholderLabel];
    [self.inputTextView addSubview:self.exampleButton];
    [self.inputTextView addSubview:self.inputClearButton];
    [self.scrollView addSubview:self.charCountLabel];
    [self.scrollView addSubview:self.pairBarView];
    [self.pairBarView addSubview:self.sourceLanguageButton];
    [self.pairBarView addSubview:self.swapButton];
    [self.pairBarView addSubview:self.targetLanguageButton];
    [self.scrollView addSubview:self.translateButton];
    [self.scrollView addSubview:self.cancelButton];
    [self.scrollView addSubview:self.streamView];
    [self.scrollView addSubview:self.logView];
}

/// 计算并应用所有子视图 frame
- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat padding = 12.0;
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;

    // 滚动容器：占据导航栏下方到屏幕底部
    self.scrollView.frame = CGRectMake(0, topOffset, width, height - topOffset);

    CGFloat y = padding;

    // 输入框
    self.inputTextView.frame = CGRectMake(padding, y, width - padding * 2, 110.0);

    // 输入框右上角浮动按钮：Example | Clear
    CGFloat floatBtnHeight = 24.0;
    CGFloat floatBtnY = 8.0;
    CGFloat inputClearWidth = 50.0;
    CGFloat exampleWidth = 70.0;
    CGFloat innerRightPadding = 8.0;
    self.inputClearButton.frame = CGRectMake(CGRectGetWidth(self.inputTextView.bounds) - innerRightPadding - inputClearWidth,
                                              floatBtnY,
                                              inputClearWidth,
                                              floatBtnHeight);
    self.exampleButton.frame = CGRectMake(CGRectGetMinX(self.inputClearButton.frame) - 6.0 - exampleWidth,
                                           floatBtnY,
                                           exampleWidth,
                                           floatBtnHeight);

    // placeholder（避开右上角浮动按钮）
    self.placeholderLabel.frame = CGRectMake(6, 8,
                                              CGRectGetMinX(self.exampleButton.frame) - 6 - 6, 20);

    y = CGRectGetMaxY(self.inputTextView.frame) + 4.0;

    // 字符计数
    self.charCountLabel.frame = CGRectMake(padding, y, width - padding * 2, 16.0);
    y = CGRectGetMaxY(self.charCountLabel.frame) + padding;

    // Pair Bar
    CGFloat pairBarHeight = 60.0;
    self.pairBarView.frame = CGRectMake(padding, y, width - padding * 2, pairBarHeight);
    CGFloat innerPadding = 8.0;
    CGFloat swapSize = 44.0;
    CGFloat barInnerY = (pairBarHeight - 44.0) / 2.0;
    CGFloat sideWidth = (CGRectGetWidth(self.pairBarView.bounds) - swapSize - innerPadding * 4) / 2.0;
    self.sourceLanguageButton.frame = CGRectMake(innerPadding, barInnerY, sideWidth, 44.0);
    self.swapButton.frame = CGRectMake(CGRectGetMaxX(self.sourceLanguageButton.frame) + innerPadding,
                                        (pairBarHeight - swapSize) / 2.0,
                                        swapSize, swapSize);
    self.targetLanguageButton.frame = CGRectMake(CGRectGetMaxX(self.swapButton.frame) + innerPadding,
                                                  barInnerY, sideWidth, 44.0);
    y = CGRectGetMaxY(self.pairBarView.frame) + padding;

    // Translate / Cancel
    CGFloat buttonHeight = 44.0;
    CGFloat buttonWidth = (width - padding * 3) / 2.0;
    self.translateButton.frame = CGRectMake(padding, y, buttonWidth, buttonHeight);
    self.cancelButton.frame = CGRectMake(CGRectGetMaxX(self.translateButton.frame) + padding,
                                          y, buttonWidth, buttonHeight);
    y = CGRectGetMaxY(self.translateButton.frame) + padding;

    // Translation + Logs 使用固定高度，使内容可超过屏幕从而触发滚动
    CGFloat streamHeight = 260.0;
    CGFloat logHeight = 220.0;
    self.streamView.frame = CGRectMake(padding, y, width - padding * 2, streamHeight);
    self.logView.frame = CGRectMake(padding,
                                     CGRectGetMaxY(self.streamView.frame) + padding,
                                     width - padding * 2,
                                     logHeight);
    y = CGRectGetMaxY(self.logView.frame) + padding;

    self.scrollView.contentSize = CGSizeMake(width, y + bottomInset);
}

#pragma mark - 私有方法 - 状态刷新

/// 根据当前是否有进行中任务刷新按钮启用状态
- (void)refreshButtonsForState {
    BOOL translating = (self.currentTaskId.length > 0);
    self.translateButton.enabled = !translating;
    self.translateButton.alpha = translating ? 0.4 : 1.0;
    self.cancelButton.enabled = translating;
    self.cancelButton.alpha = translating ? 1.0 : 0.4;
    self.inputTextView.editable = !translating;
    self.sourceLanguageButton.enabled = !translating;
    self.targetLanguageButton.enabled = !translating;
    self.exampleButton.enabled = !translating;
    self.inputClearButton.enabled = !translating;
    if (translating) {
        self.swapButton.enabled = NO;
        self.swapButton.alpha = 0.4;
    } else {
        [self refreshSwapButtonState];
    }
}

/// 刷新两个语言按钮的当前显示
- (void)refreshLanguageButtons {
    [self.sourceLanguageButton setTitle:[self displayNameForLanguage:self.selectedSourceLanguage]
                               forState:UIControlStateNormal];
    [self.targetLanguageButton setTitle:[self displayNameForLanguage:self.selectedTargetLanguage]
                               forState:UIControlStateNormal];
}

/// 刷新 Swap 按钮可用性（source 为 Auto 时禁用）
- (void)refreshSwapButtonState {
    BOOL canSwap = (self.selectedSourceLanguage != TSAILanguageAuto &&
                    self.selectedSourceLanguage != TSAILanguageUnknown);
    self.swapButton.enabled = canSwap;
    self.swapButton.alpha = canSwap ? 1.0 : 0.4;
}

/// 刷新输入框字符计数显示，超限标红
- (void)refreshCharCount {
    NSUInteger len = self.inputTextView.text.length;
    self.charCountLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_translate.chars_fmt"),
                                 (unsigned long)len, (unsigned long)kTSAITranslateMaxChars];
    self.charCountLabel.textColor = (len > kTSAITranslateMaxChars)
        ? [UIColor systemRedColor] : [UIColor secondaryLabelColor];
    self.placeholderLabel.hidden = (len > 0);
}

/// 把检测到的语言信息附加到译文区标题
- (void)applyDetectedLanguage:(TSAILanguage)language {
    NSString *suffix;
    if (language == TSAILanguageUnknown || language == TSAILanguageAuto) {
        suffix = @"";
    } else {
        NSString *code = [TSAILanguageMapper bcp47CodeForLanguage:language];
        suffix = code.length > 0
            ? [NSString stringWithFormat:TSLocalizedString(@"ai_translate.detected_fmt"), code]
            : @"";
    }
    self.streamView.title = [TSLocalizedString(@"ai_translate.translation_title")
                                stringByAppendingString:suffix];
}

#pragma mark - 私有方法 - 按钮事件

/// Example 按钮：一次性把示例文本填进输入框
- (void)onExampleTap {
    self.inputTextView.text = TSLocalizedString(@"ai_translate.sample_text");
    [self refreshCharCount];
}

/// Clear 按钮（输入框右上角）：清空输入框
- (void)onInputClearTap {
    self.inputTextView.text = @"";
    [self refreshCharCount];
}

/// Source 语言按钮点击
- (void)onSourceLanguageTap {
    NSArray<NSNumber *> *list = [self supportedSourceLanguages];
    __weak typeof(self) weakSelf = self;
    [self presentLanguagePickerWithTitle:TSLocalizedString(@"ai_translate.sheet_select_source")
                               languages:list
                                selected:self.selectedSourceLanguage
                                handler:^(TSAILanguage language) {
        weakSelf.selectedSourceLanguage = language;
        [weakSelf refreshLanguageButtons];
        [weakSelf refreshSwapButtonState];
    }];
}

/// Target 语言按钮点击
- (void)onTargetLanguageTap {
    NSArray<NSNumber *> *list = [self supportedTargetLanguages];
    __weak typeof(self) weakSelf = self;
    [self presentLanguagePickerWithTitle:TSLocalizedString(@"ai_translate.sheet_select_target")
                               languages:list
                                selected:self.selectedTargetLanguage
                                handler:^(TSAILanguage language) {
        weakSelf.selectedTargetLanguage = language;
        [weakSelf refreshLanguageButtons];
    }];
}

/// Swap 按钮：翻转动画 + 互换源/目标
- (void)onSwapTap {
    if (self.selectedSourceLanguage == TSAILanguageAuto ||
        self.selectedSourceLanguage == TSAILanguageUnknown) {
        return;
    }
    TSAILanguage newSource = self.selectedTargetLanguage;
    TSAILanguage newTarget = self.selectedSourceLanguage;
    self.selectedSourceLanguage = newSource;
    self.selectedTargetLanguage = newTarget;

    [UIView transitionWithView:self.pairBarView
                      duration:0.25
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^{
        [self refreshLanguageButtons];
    } completion:^(BOOL finished) {
        [self refreshSwapButtonState];
    }];
}

/// Translate 按钮：前置校验通过后发起请求
- (void)onTranslateTap {
    NSString *text = [self.inputTextView.text stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (text.length == 0) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_translate.toast_empty_input")];
        return;
    }
    if (self.inputTextView.text.length > kTSAITranslateMaxChars) {
        [self showAlertWithMsg:[NSString stringWithFormat:TSLocalizedString(@"ai_translate.toast_too_long_fmt"),
                                 (unsigned long)kTSAITranslateMaxChars]];
        return;
    }
    if (self.selectedTargetLanguage == TSAILanguageAuto ||
        self.selectedTargetLanguage == TSAILanguageUnknown) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_translate.toast_no_target")];
        return;
    }
    if (self.selectedSourceLanguage != TSAILanguageAuto &&
        self.selectedSourceLanguage == self.selectedTargetLanguage) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_translate.toast_same_lang")];
        return;
    }

    id<TSAITranslateInterface> translate = [[TopStepComKit sharedInstance] aiTranslate];
    if (translate == nil) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_translate.toast_unavailable")];
        return;
    }

    [self.streamView reset];
    self.streamView.textColor = nil;
    self.streamView.contentBackgroundColor = nil;
    [self applyDetectedLanguage:TSAILanguageUnknown];
    self.partialCount = 0;

    TSAITranslateConfig *config = [TSAITranslateConfig configWithSourceLanguage:self.selectedSourceLanguage
                                                                  targetLanguage:self.selectedTargetLanguage];

    [self.logView appendLineWithFormat:@"[translate] start text.len=%lu source=%@ target=%@",
        (unsigned long)text.length,
        [self displayNameForLanguage:self.selectedSourceLanguage],
        [self displayNameForLanguage:self.selectedTargetLanguage]];

    __weak typeof(self) weakSelf = self;
    NSString *taskId = [translate translateText:text
                                          config:config
                                 onPartialResult:^(TSAITranslatePartialResult *partial) {
        [weakSelf handlePartialResult:partial];
    }
                                      completion:^(TSAITranslateResult * _Nullable result, NSError * _Nullable error) {
        [weakSelf handleCompletionWithResult:result error:error];
    }];

    self.currentTaskId = taskId;
    [self.logView appendLineWithFormat:@"  taskId=%@", taskId];
    [self refreshButtonsForState];
}

/// Cancel 按钮：调用 SDK 取消，等 completion 回调统一收尾
- (void)onCancelTap {
    if (self.currentTaskId.length == 0) return;
    [self.logView appendLineWithFormat:@"[translate] cancel requested taskId=%@", self.currentTaskId];
    self.cancelButton.enabled = NO;
    self.cancelButton.alpha = 0.4;
    [[[TopStepComKit sharedInstance] aiTranslate] cancelTranslationWithTaskId:self.currentTaskId];
}

#pragma mark - 私有方法 - 翻译回调

/// 处理 partial：覆盖译文、更新检测语言、写日志
- (void)handlePartialResult:(TSAITranslatePartialResult *)partial {
    if (![partial.taskId isEqualToString:self.currentTaskId]) return;
    self.partialCount += 1;
    self.streamView.text = partial.text;
    [self applyDetectedLanguage:partial.detectedSourceLanguage];
    [self.logView appendLineWithFormat:@"  partial #%lu len=%lu detect=%@ isFinal=%@",
        (unsigned long)self.partialCount,
        (unsigned long)partial.text.length,
        [self displayNameForLanguage:partial.detectedSourceLanguage],
        partial.isFinal ? @"YES" : @"NO"];
}

/// 处理 completion：成功 / 失败 / 取消统一收尾
- (void)handleCompletionWithResult:(TSAITranslateResult * _Nullable)result
                              error:(NSError * _Nullable)error {
    NSString *finishedTaskId = result.taskId ?: self.currentTaskId;
    if (finishedTaskId.length > 0 && ![finishedTaskId isEqualToString:self.currentTaskId]) {
        return;
    }

    if (error) {
        BOOL isCancel = (error.code == eTSErrorUserCancelled);
        NSString *titleKey = isCancel ? @"ai_translate.cancelled_hint" : @"ai_translate.failed_hint";
        UIColor *accentColor = isCancel ? [UIColor systemOrangeColor] : [UIColor systemRedColor];
        NSString *detail = [NSString stringWithFormat:TSLocalizedString(@"ai_translate.error_fmt"),
                              error.domain ?: @"-",
                              (long)error.code,
                              error.localizedDescription ?: @"-"];
        self.streamView.title = TSLocalizedString(titleKey);
        self.streamView.textColor = accentColor;
        self.streamView.contentBackgroundColor = [accentColor colorWithAlphaComponent:0.12f];
        self.streamView.text = detail;

        [self.logView appendLineWithFormat:@"[translate] %@ domain=%@ code=%ld msg=%@",
            isCancel ? @"cancelled" : @"error",
            error.domain, (long)error.code, error.localizedDescription];
    } else if (result) {
        self.streamView.textColor = nil;
        self.streamView.contentBackgroundColor = nil;
        self.streamView.text = result.translatedText;
        [self applyDetectedLanguage:result.detectedSourceLanguage];
        [self.logView appendLineWithFormat:@"[translate] success translated.len=%lu detect=%@",
            (unsigned long)result.translatedText.length,
            [self displayNameForLanguage:result.detectedSourceLanguage]];
    }

    self.currentTaskId = nil;
    [self refreshButtonsForState];
}

#pragma mark - 私有方法 - 语言选择器

/// 弹出 ActionSheet 选择语言
- (void)presentLanguagePickerWithTitle:(NSString *)title
                              languages:(NSArray<NSNumber *> *)languages
                               selected:(TSAILanguage)selected
                                handler:(void (^)(TSAILanguage language))handler {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:title
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSNumber *box in languages) {
        TSAILanguage language = (TSAILanguage)box.integerValue;
        NSString *name = [self displayNameForLanguage:language];
        NSString *display = (language == selected) ? [name stringByAppendingString:@"  ✓"] : name;
        UIAlertAction *action = [UIAlertAction actionWithTitle:display
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull a) {
            if (handler) handler(language);
        }];
        [sheet addAction:action];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];

    if (sheet.popoverPresentationController) {
        sheet.popoverPresentationController.sourceView = self.view;
        sheet.popoverPresentationController.sourceRect =
            CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 0, 0);
    }
    [self presentViewController:sheet animated:YES completion:nil];
}

/// 源语言可选列表（含 Auto）
- (NSArray<NSNumber *> *)supportedSourceLanguages {
    return @[
        @(TSAILanguageAuto),
        @(TSAILanguageChineseSimplified),
        @(TSAILanguageChineseTraditional),
        @(TSAILanguageEnglishUS),
        @(TSAILanguageEnglishUK),
        @(TSAILanguageJapanese),
        @(TSAILanguageKorean),
        @(TSAILanguageFrench),
        @(TSAILanguageGerman),
        @(TSAILanguageSpanish),
        @(TSAILanguageRussian),
    ];
}

/// 目标语言可选列表（不含 Auto）
- (NSArray<NSNumber *> *)supportedTargetLanguages {
    return @[
        @(TSAILanguageChineseSimplified),
        @(TSAILanguageChineseTraditional),
        @(TSAILanguageEnglishUS),
        @(TSAILanguageEnglishUK),
        @(TSAILanguageJapanese),
        @(TSAILanguageKorean),
        @(TSAILanguageFrench),
        @(TSAILanguageGerman),
        @(TSAILanguageSpanish),
        @(TSAILanguageRussian),
    ];
}

/// 获取语言展示名（本地化）
- (NSString *)displayNameForLanguage:(TSAILanguage)language {
    switch (language) {
        case TSAILanguageAuto:               return TSLocalizedString(@"ai_translate.lang.auto");
        case TSAILanguageChineseSimplified:  return TSLocalizedString(@"ai_translate.lang.zh_cn");
        case TSAILanguageChineseTraditional: return TSLocalizedString(@"ai_translate.lang.zh_tw");
        case TSAILanguageEnglishUS:          return TSLocalizedString(@"ai_translate.lang.en_us");
        case TSAILanguageEnglishUK:          return TSLocalizedString(@"ai_translate.lang.en_gb");
        case TSAILanguageJapanese:           return TSLocalizedString(@"ai_translate.lang.ja");
        case TSAILanguageKorean:             return TSLocalizedString(@"ai_translate.lang.ko");
        case TSAILanguageFrench:             return TSLocalizedString(@"ai_translate.lang.fr");
        case TSAILanguageGerman:             return TSLocalizedString(@"ai_translate.lang.de");
        case TSAILanguageSpanish:            return TSLocalizedString(@"ai_translate.lang.es");
        case TSAILanguageRussian:            return TSLocalizedString(@"ai_translate.lang.ru");
        case TSAILanguageUnknown:
        default:                             return TSLocalizedString(@"ai_translate.lang.unknown");
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self refreshCharCount];
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

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] init];
        _inputTextView.font = [UIFont systemFontOfSize:15.0];
        _inputTextView.delegate = self;
        _inputTextView.layer.cornerRadius = 8.0;
        _inputTextView.layer.borderColor = [UIColor systemGray4Color].CGColor;
        _inputTextView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
        _inputTextView.textContainerInset = UIEdgeInsetsMake(36, 4, 8, 4);
        _inputTextView.alwaysBounceVertical = YES;
    }
    return _inputTextView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.text = TSLocalizedString(@"ai_translate.input_placeholder");
        _placeholderLabel.textColor = [UIColor placeholderTextColor];
        _placeholderLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _placeholderLabel;
}

- (UILabel *)charCountLabel {
    if (!_charCountLabel) {
        _charCountLabel = [[UILabel alloc] init];
        _charCountLabel.font = [UIFont systemFontOfSize:11.0];
        _charCountLabel.textAlignment = NSTextAlignmentRight;
        _charCountLabel.textColor = [UIColor secondaryLabelColor];
    }
    return _charCountLabel;
}

- (UIButton *)exampleButton {
    if (!_exampleButton) {
        _exampleButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_exampleButton setTitle:TSLocalizedString(@"ai_translate.btn_example")
                         forState:UIControlStateNormal];
        _exampleButton.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
        [_exampleButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        _exampleButton.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.10];
        _exampleButton.layer.cornerRadius = 12.0;
        [_exampleButton addTarget:self action:@selector(onExampleTap)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _exampleButton;
}

- (UIButton *)inputClearButton {
    if (!_inputClearButton) {
        _inputClearButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_inputClearButton setTitle:TSLocalizedString(@"ai_translate.btn_clear")
                            forState:UIControlStateNormal];
        _inputClearButton.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
        [_inputClearButton setTitleColor:[UIColor secondaryLabelColor] forState:UIControlStateNormal];
        _inputClearButton.backgroundColor = [UIColor systemGray6Color];
        _inputClearButton.layer.cornerRadius = 12.0;
        [_inputClearButton addTarget:self action:@selector(onInputClearTap)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    return _inputClearButton;
}

- (UIView *)pairBarView {
    if (!_pairBarView) {
        _pairBarView = [[UIView alloc] init];
        _pairBarView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
        _pairBarView.layer.cornerRadius = 12.0;
    }
    return _pairBarView;
}

- (UIButton *)sourceLanguageButton {
    if (!_sourceLanguageButton) {
        _sourceLanguageButton = [self pairLanguageButtonWithAction:@selector(onSourceLanguageTap)];
    }
    return _sourceLanguageButton;
}

- (UIButton *)targetLanguageButton {
    if (!_targetLanguageButton) {
        _targetLanguageButton = [self pairLanguageButtonWithAction:@selector(onTargetLanguageTap)];
    }
    return _targetLanguageButton;
}

- (UIButton *)swapButton {
    if (!_swapButton) {
        _swapButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _swapButton.backgroundColor = [UIColor whiteColor];
        _swapButton.layer.cornerRadius = 22.0;
        _swapButton.layer.borderWidth = 1.5;
        _swapButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
        _swapButton.tintColor = [UIColor systemBlueColor];
        if (@available(iOS 13.0, *)) {
            UIImage *icon = [UIImage systemImageNamed:@"arrow.left.arrow.right"];
            [_swapButton setImage:icon forState:UIControlStateNormal];
        } else {
            [_swapButton setTitle:@"⇄" forState:UIControlStateNormal];
            _swapButton.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightSemibold];
            [_swapButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        }
        [_swapButton addTarget:self action:@selector(onSwapTap)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _swapButton;
}

/// 构造 Pair Bar 中源/目标语言按钮的共用样式
- (UIButton *)pairLanguageButtonWithAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 10.0;
    button.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    button.layer.borderColor = [UIColor systemGray4Color].CGColor;
    button.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    [button setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (TSAIStreamTextView *)streamView {
    if (!_streamView) {
        _streamView = [[TSAIStreamTextView alloc] init];
        _streamView.title = TSLocalizedString(@"ai_translate.translation_title");
    }
    return _streamView;
}

- (TSAILogView *)logView {
    if (!_logView) {
        _logView = [[TSAILogView alloc] init];
    }
    return _logView;
}

- (UIButton *)translateButton {
    if (!_translateButton) {
        _translateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_translateButton setTitle:TSLocalizedString(@"ai_translate.btn_translate")
                          forState:UIControlStateNormal];
        _translateButton.backgroundColor = [UIColor systemBlueColor];
        [_translateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _translateButton.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
        _translateButton.layer.cornerRadius = 8.0;
        [_translateButton addTarget:self action:@selector(onTranslateTap)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _translateButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:TSLocalizedString(@"ai_translate.btn_cancel")
                       forState:UIControlStateNormal];
        _cancelButton.backgroundColor = [UIColor systemRedColor];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
        _cancelButton.layer.cornerRadius = 8.0;
        [_cancelButton addTarget:self action:@selector(onCancelTap)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

@end
