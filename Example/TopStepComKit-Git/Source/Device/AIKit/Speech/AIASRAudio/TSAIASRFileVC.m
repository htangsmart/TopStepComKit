//
//  TSAIASRFileVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIASRFileVC.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "TSAIStreamTextView.h"
#import "TSAILogView.h"

@interface TSAIASRFileVC () <UIDocumentPickerDelegate>

#pragma mark - 滚动容器
/// 滚动容器，承载页面所有内容
@property (nonatomic, strong) UIScrollView *scrollView;

#pragma mark - 文件区
/// 文件区容器
@property (nonatomic, strong) UIView *fileCardView;
/// 文件名 label
@property (nonatomic, strong) UILabel *fileNameLabel;
/// 文件副标题（大小+格式）label
@property (nonatomic, strong) UILabel *fileSubLabel;
/// 选择文件按钮
@property (nonatomic, strong) UIButton *chooseFileButton;

#pragma mark - 配置区
/// 配置区容器
@property (nonatomic, strong) UIView *configCardView;
/// 「识别语言」标签
@property (nonatomic, strong) UILabel *languageTitleLabel;
/// 语言选择按钮
@property (nonatomic, strong) UIButton *languageButton;
/// 「音频格式」标签
@property (nonatomic, strong) UILabel *formatTitleLabel;
/// 音频格式选择按钮
@property (nonatomic, strong) UIButton *formatButton;

#pragma mark - 操作区
/// taskId / 状态展示 label
@property (nonatomic, strong) UILabel *taskMetaLabel;
/// 触发识别按钮
@property (nonatomic, strong) UIButton *recognizeButton;
/// 取消识别按钮
@property (nonatomic, strong) UIButton *cancelButton;

#pragma mark - 输出区
/// 流式累积识别结果
@property (nonatomic, strong) TSAIStreamTextView *streamView;
/// 日志输出
@property (nonatomic, strong) TSAILogView *logView;

#pragma mark - 状态
/// 已选择的本地音频文件 URL
@property (nonatomic, strong, nullable) NSURL *selectedFileURL;
/// 已选择文件大小（字节）
@property (nonatomic, assign) unsigned long long selectedFileSize;
/// 已选择的识别语言
@property (nonatomic, assign) TSAILanguage selectedLanguage;
/// 已选择的音频格式
@property (nonatomic, assign) TSAIAudioFormat selectedAudioFormat;
/// 当前进行中的任务 ID（nil 表示空闲）
@property (nonatomic, copy, nullable) NSString *currentTaskId;
/// 已收到的 partial 计数（仅日志用）
@property (nonatomic, assign) NSUInteger partialCount;
/// 任务开始时间，用于计算耗时
@property (nonatomic, strong, nullable) NSDate *taskStartDate;

@end

@implementation TSAIASRFileVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"ai_asr_file.title");
    self.selectedLanguage = TSAILanguageUnknown;
    self.selectedAudioFormat = TSAIAudioFormatNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupViews];
    [self refreshFileDisplay];
    [self refreshLanguageButtonTitle];
    [self refreshFormatButtonTitle];
    [self refreshButtonsForState];
    [self refreshTaskMeta];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.currentTaskId.length > 0) {
        [self.logView appendLineWithFormat:@"viewWillDisappear: auto-cancel taskId=%@", self.currentTaskId];
        [[[TopStepComKit sharedInstance] aiSpeech] cancelRecognitionWithTaskId:self.currentTaskId];
    }
}

- (void)dealloc {
    if (_currentTaskId.length > 0) {
        [[[TopStepComKit sharedInstance] aiSpeech] cancelRecognitionWithTaskId:_currentTaskId];
    }
}

#pragma mark - 私有方法 - 视图搭建

/// 添加所有子视图
- (void)setupViews {
    [self.view addSubview:self.scrollView];

    [self.scrollView addSubview:self.fileCardView];
    [self.fileCardView addSubview:self.fileNameLabel];
    [self.fileCardView addSubview:self.fileSubLabel];
    [self.fileCardView addSubview:self.chooseFileButton];

    [self.scrollView addSubview:self.configCardView];
    [self.configCardView addSubview:self.languageTitleLabel];
    [self.configCardView addSubview:self.languageButton];
    [self.configCardView addSubview:self.formatTitleLabel];
    [self.configCardView addSubview:self.formatButton];

    [self.scrollView addSubview:self.taskMetaLabel];
    [self.scrollView addSubview:self.recognizeButton];
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

    // 文件卡片
    CGFloat fileCardHeight = 96.0;
    self.fileCardView.frame = CGRectMake(padding, y, width - padding * 2, fileCardHeight);
    self.fileNameLabel.frame = CGRectMake(12, 10, CGRectGetWidth(self.fileCardView.bounds) - 24, 20);
    self.fileSubLabel.frame  = CGRectMake(12, 30, CGRectGetWidth(self.fileCardView.bounds) - 24, 16);
    self.chooseFileButton.frame = CGRectMake(12, 52,
                                              CGRectGetWidth(self.fileCardView.bounds) - 24, 36);
    y = CGRectGetMaxY(self.fileCardView.frame) + padding;

    // 配置卡片
    CGFloat configRowHeight = 44.0;
    CGFloat configCardHeight = configRowHeight * 2 + 1;
    self.configCardView.frame = CGRectMake(padding, y, width - padding * 2, configCardHeight);
    CGFloat configWidth = CGRectGetWidth(self.configCardView.bounds);
    CGFloat labelWidth = 120.0;
    self.languageTitleLabel.frame = CGRectMake(12, 0, labelWidth, configRowHeight);
    self.languageButton.frame = CGRectMake(labelWidth + 12, 6,
                                             configWidth - labelWidth - 24, configRowHeight - 12);
    self.formatTitleLabel.frame = CGRectMake(12, configRowHeight + 1, labelWidth, configRowHeight);
    self.formatButton.frame = CGRectMake(labelWidth + 12, configRowHeight + 1 + 6,
                                           configWidth - labelWidth - 24, configRowHeight - 12);
    y = CGRectGetMaxY(self.configCardView.frame) + padding;

    // 任务 meta
    self.taskMetaLabel.frame = CGRectMake(padding, y, width - padding * 2, 18);
    y = CGRectGetMaxY(self.taskMetaLabel.frame) + 6;

    // Recognize / Cancel
    CGFloat buttonHeight = 44.0;
    CGFloat buttonWidth = (width - padding * 3) / 2.0;
    self.recognizeButton.frame = CGRectMake(padding, y, buttonWidth, buttonHeight);
    self.cancelButton.frame = CGRectMake(CGRectGetMaxX(self.recognizeButton.frame) + padding,
                                           y, buttonWidth, buttonHeight);
    y = CGRectGetMaxY(self.recognizeButton.frame) + padding;

    // 流式 + 日志 使用固定高度，使内容可超过屏幕从而触发滚动
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

#pragma mark - 私有方法 - UI 状态刷新

/// 文件区显示：未选 → 占位文案；已选 → 文件名 + 大小/格式
- (void)refreshFileDisplay {
    if (self.selectedFileURL == nil) {
        self.fileNameLabel.text = TSLocalizedString(@"ai_asr_file.file_empty");
        self.fileNameLabel.textColor = [UIColor secondaryLabelColor];
        self.fileSubLabel.text = TSLocalizedString(@"ai_asr_file.file_empty_sub");
    } else {
        self.fileNameLabel.text = self.selectedFileURL.lastPathComponent;
        self.fileNameLabel.textColor = [UIColor labelColor];
        NSString *sizeText = [self readableSize:self.selectedFileSize];
        NSString *fmtHint = [self inferredFormatHintForURL:self.selectedFileURL];
        self.fileSubLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_file.file_meta_fmt"),
                                    sizeText, fmtHint];
    }
}

/// 语言按钮文字
- (void)refreshLanguageButtonTitle {
    NSString *title = (self.selectedLanguage == TSAILanguageUnknown)
        ? TSLocalizedString(@"ai_asr_file.lang.unset")
        : [self displayNameForLanguage:self.selectedLanguage];
    [self.languageButton setTitle:title forState:UIControlStateNormal];
    UIColor *border = (self.selectedLanguage == TSAILanguageUnknown)
        ? [UIColor systemRedColor] : [UIColor systemGray4Color];
    self.languageButton.layer.borderColor = border.CGColor;
}

/// 音频格式按钮文字
- (void)refreshFormatButtonTitle {
    [self.formatButton setTitle:[self displayNameForAudioFormat:self.selectedAudioFormat]
                        forState:UIControlStateNormal];
}

/// 根据当前是否有进行中任务刷新所有按钮可用性
- (void)refreshButtonsForState {
    BOOL recognizing = (self.currentTaskId.length > 0);
    BOOL pcmMissingFmt = (self.selectedFileURL != nil
                          && [self.selectedFileURL.pathExtension.lowercaseString isEqualToString:@"pcm"]
                          && self.selectedAudioFormat == TSAIAudioFormatNone);
    BOOL canRecognize = !recognizing
                        && self.selectedFileURL != nil
                        && self.selectedLanguage != TSAILanguageUnknown
                        && !pcmMissingFmt;

    self.recognizeButton.enabled = canRecognize;
    self.recognizeButton.alpha = canRecognize ? 1.0 : 0.4;
    self.cancelButton.enabled = recognizing;
    self.cancelButton.alpha = recognizing ? 1.0 : 0.4;

    self.chooseFileButton.enabled = !recognizing;
    self.chooseFileButton.alpha = recognizing ? 0.4 : 1.0;
    self.languageButton.enabled = !recognizing;
    self.languageButton.alpha = recognizing ? 0.4 : 1.0;
    self.formatButton.enabled = !recognizing;
    self.formatButton.alpha = recognizing ? 0.4 : 1.0;
}

/// 任务 meta 行：显示状态 + taskId
- (void)refreshTaskMeta {
    if (self.currentTaskId.length > 0) {
        NSString *shortId = [self shortIdForTaskId:self.currentTaskId];
        self.taskMetaLabel.text = [NSString stringWithFormat:@"%@ · %@",
                                     TSLocalizedString(@"ai_asr_file.status_recognizing"),
                                     [NSString stringWithFormat:TSLocalizedString(@"ai_asr_file.taskid_fmt"), shortId]];
        self.taskMetaLabel.textColor = [UIColor systemBlueColor];
    } else {
        self.taskMetaLabel.text = TSLocalizedString(@"ai_asr_file.status_idle");
        self.taskMetaLabel.textColor = [UIColor secondaryLabelColor];
    }
}

#pragma mark - 私有方法 - 按钮事件

/// Choose 按钮：弹出系统文件选择器（仅音频）
- (void)onChooseFileTap {
    NSArray *types = @[ (NSString *)kUTTypeAudio ];
    UIDocumentPickerViewController *picker =
        [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types
                                                                 inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

/// 语言按钮：弹 ActionSheet 选语言（不含 Auto/Unknown，文件 ASR 必须事先指定）
- (void)onLanguageButtonTap {
    NSArray<NSNumber *> *list = @[
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

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ai_asr_file.sheet_select_lang")
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    for (NSNumber *box in list) {
        TSAILanguage language = (TSAILanguage)box.integerValue;
        NSString *name = [self displayNameForLanguage:language];
        NSString *display = (language == self.selectedLanguage) ? [name stringByAppendingString:@"  ✓"] : name;
        [sheet addAction:[UIAlertAction actionWithTitle:display
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.selectedLanguage = language;
            [weakSelf refreshLanguageButtonTitle];
            [weakSelf refreshButtonsForState];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    if (sheet.popoverPresentationController) {
        sheet.popoverPresentationController.sourceView = self.languageButton;
        sheet.popoverPresentationController.sourceRect = self.languageButton.bounds;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}

/// 格式按钮：弹 ActionSheet 选音频格式
- (void)onFormatButtonTap {
    NSArray<NSNumber *> *list = @[
        @(TSAIAudioFormatNone),
        @(TSAIAudioFormatPcm),
        @(TSAIAudioFormatOpus),
        @(TSAIAudioFormatMp3),
        @(TSAIAudioFormatWav),
    ];

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:TSLocalizedString(@"ai_asr_file.sheet_select_fmt")
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    for (NSNumber *box in list) {
        TSAIAudioFormat fmt = (TSAIAudioFormat)box.integerValue;
        NSString *name = [self displayNameForAudioFormat:fmt];
        NSString *display = (fmt == self.selectedAudioFormat) ? [name stringByAppendingString:@"  ✓"] : name;
        [sheet addAction:[UIAlertAction actionWithTitle:display
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.selectedAudioFormat = fmt;
            [weakSelf refreshFormatButtonTitle];
            [weakSelf refreshButtonsForState];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    if (sheet.popoverPresentationController) {
        sheet.popoverPresentationController.sourceView = self.formatButton;
        sheet.popoverPresentationController.sourceRect = self.formatButton.bounds;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}

/// Recognize 按钮：前置校验通过后发起请求
- (void)onRecognizeTap {
    if (self.selectedFileURL == nil) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_asr_file.toast_no_file")];
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.selectedFileURL.path]) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_asr_file.toast_file_missing")];
        return;
    }
    if (self.selectedLanguage == TSAILanguageUnknown || self.selectedLanguage == TSAILanguageAuto) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_asr_file.toast_no_language")];
        return;
    }
    if ([self.selectedFileURL.pathExtension.lowercaseString isEqualToString:@"pcm"]
        && self.selectedAudioFormat == TSAIAudioFormatNone) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_asr_file.toast_pcm_need_fmt")];
        return;
    }

    id<TSAISpeechInterface> speech = [[TopStepComKit sharedInstance] aiSpeech];
    if (speech == nil) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_asr_file.toast_unavailable")];
        return;
    }

    [self.streamView reset];
    self.streamView.title = TSLocalizedString(@"ai_asr_file.section_stream");
    self.streamView.textColor = nil;
    self.streamView.contentBackgroundColor = nil;
    self.partialCount = 0;
    self.taskStartDate = [NSDate date];

    TSAIASRFileConfig *config = [TSAIASRFileConfig configWithLanguage:self.selectedLanguage];
    config.audioFormat = self.selectedAudioFormat;

    [self.logView appendLineWithFormat:@"[asr-file] start file=%@ lang=%@ fmt=%@",
        self.selectedFileURL.lastPathComponent,
        [self displayNameForLanguage:self.selectedLanguage],
        [self displayNameForAudioFormat:self.selectedAudioFormat]];

    __weak typeof(self) weakSelf = self;
    NSString *taskId = [speech recognizeSpeechWithFileURL:self.selectedFileURL
                                                    config:config
                                            onPartialResult:^(TSAIASRPartialResult *partial) {
        [weakSelf handlePartialResult:partial];
    }
                                                completion:^(TSAIASRResult * _Nullable result, NSError * _Nullable error) {
        [weakSelf handleCompletionWithResult:result error:error];
    }];

    self.currentTaskId = taskId;
    [self.logView appendLineWithFormat:@"  taskId=%@", taskId];
    [self refreshButtonsForState];
    [self refreshTaskMeta];
}

/// Cancel 按钮：调用 SDK 取消，等 completion 回调统一收尾
- (void)onCancelTap {
    if (self.currentTaskId.length == 0) return;
    [self.logView appendLineWithFormat:@"[asr-file] cancel requested taskId=%@", self.currentTaskId];
    self.cancelButton.enabled = NO;
    self.cancelButton.alpha = 0.4;
    [[[TopStepComKit sharedInstance] aiSpeech] cancelRecognitionWithTaskId:self.currentTaskId];
}

#pragma mark - 私有方法 - SDK 回调

/// 处理 partial：累积文本直接覆盖到 streamView
- (void)handlePartialResult:(TSAIASRPartialResult *)partial {
    if (![partial.taskId isEqualToString:self.currentTaskId]) return;
    self.partialCount += 1;
    self.streamView.text = partial.text;
    [self.logView appendLineWithFormat:@"  partial #%lu s#%ld f#%ld final=%@ len=%lu",
        (unsigned long)self.partialCount,
        (long)partial.sentenceNo,
        (long)partial.fragmentNo,
        partial.isSentenceFinal ? @"Y" : @"N",
        (unsigned long)partial.text.length];
}

/// 处理 completion：成功 / 失败 / 取消统一收尾
- (void)handleCompletionWithResult:(TSAIASRResult * _Nullable)result
                              error:(NSError * _Nullable)error {
    NSString *finishedTaskId = result.taskId ?: self.currentTaskId;
    if (finishedTaskId.length > 0 && ![finishedTaskId isEqualToString:self.currentTaskId]) {
        return;
    }

    NSTimeInterval elapsed = self.taskStartDate
        ? -[self.taskStartDate timeIntervalSinceNow] : 0;

    if (error) {
        BOOL isCancel = (error.code == eTSErrorUserCancelled);
        NSString *titleKey = isCancel ? @"ai_asr_file.cancelled_hint" : @"ai_asr_file.failed_hint";
        UIColor *accentColor = isCancel ? [UIColor systemOrangeColor] : [UIColor systemRedColor];
        NSString *detail = [NSString stringWithFormat:TSLocalizedString(@"ai_asr_file.error_fmt"),
                              error.domain ?: @"-",
                              (long)error.code,
                              error.localizedDescription ?: @"-"];
        self.streamView.title = TSLocalizedString(titleKey);
        self.streamView.textColor = accentColor;
        self.streamView.contentBackgroundColor = [accentColor colorWithAlphaComponent:0.12f];
        self.streamView.text = detail;

        [self.logView appendLineWithFormat:@"[asr-file] %@ domain=%@ code=%ld msg=%@",
            isCancel ? @"cancelled" : @"error",
            error.domain, (long)error.code, error.localizedDescription];
    } else if (result) {
        self.streamView.title = TSLocalizedString(@"ai_asr_file.section_stream");
        self.streamView.textColor = nil;
        self.streamView.contentBackgroundColor = nil;
        self.streamView.text = result.text;
        [self.logView appendLineWithFormat:@"[asr-file] success len=%lu duration=%.2fs (elapsed=%.2fs)",
            (unsigned long)result.text.length,
            result.duration,
            elapsed];
    }

    self.currentTaskId = nil;
    self.taskStartDate = nil;
    [self refreshButtonsForState];
    [self refreshTaskMeta];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) return;
    NSURL *picked = urls.firstObject;

    // import 模式下系统会拷贝到沙盒，无需 startAccessingSecurityScopedResource，但拿大小需要 NSFileManager
    NSError *attrErr = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:picked.path error:&attrErr];
    self.selectedFileURL = picked;
    self.selectedFileSize = attrs ? [attrs[NSFileSize] unsignedLongLongValue] : 0;
    [self refreshFileDisplay];
    [self refreshButtonsForState];
    [self.logView appendLineWithFormat:@"[asr-file] picked file=%@ size=%llu",
        picked.lastPathComponent, self.selectedFileSize];
}

#pragma mark - 私有方法 - 工具

/// 获取语言展示名（本地化）
- (NSString *)displayNameForLanguage:(TSAILanguage)language {
    switch (language) {
        case TSAILanguageChineseSimplified:  return TSLocalizedString(@"ai_asr_file.lang.zh_cn");
        case TSAILanguageChineseTraditional: return TSLocalizedString(@"ai_asr_file.lang.zh_tw");
        case TSAILanguageEnglishUS:          return TSLocalizedString(@"ai_asr_file.lang.en_us");
        case TSAILanguageEnglishUK:          return TSLocalizedString(@"ai_asr_file.lang.en_gb");
        case TSAILanguageJapanese:           return TSLocalizedString(@"ai_asr_file.lang.ja");
        case TSAILanguageKorean:             return TSLocalizedString(@"ai_asr_file.lang.ko");
        case TSAILanguageFrench:             return TSLocalizedString(@"ai_asr_file.lang.fr");
        case TSAILanguageGerman:             return TSLocalizedString(@"ai_asr_file.lang.de");
        case TSAILanguageSpanish:            return TSLocalizedString(@"ai_asr_file.lang.es");
        case TSAILanguageRussian:            return TSLocalizedString(@"ai_asr_file.lang.ru");
        case TSAILanguageAuto:
        case TSAILanguageUnknown:
        default:                             return TSLocalizedString(@"ai_asr_file.lang.unset");
    }
}

/// 获取音频格式展示名（本地化）
- (NSString *)displayNameForAudioFormat:(TSAIAudioFormat)format {
    switch (format) {
        case TSAIAudioFormatPcm:  return TSLocalizedString(@"ai_asr_file.fmt.pcm");
        case TSAIAudioFormatOpus: return TSLocalizedString(@"ai_asr_file.fmt.opus");
        case TSAIAudioFormatMp3:  return TSLocalizedString(@"ai_asr_file.fmt.mp3");
        case TSAIAudioFormatWav:  return TSLocalizedString(@"ai_asr_file.fmt.wav");
        case TSAIAudioFormatNone:
        case TSAIAudioFormatUnknown:
        default:                  return TSLocalizedString(@"ai_asr_file.fmt.none");
    }
}

/// 根据扩展名推断格式提示文字
- (NSString *)inferredFormatHintForURL:(NSURL *)url {
    NSString *ext = url.pathExtension.lowercaseString;
    if ([ext isEqualToString:@"mp3"])  return TSLocalizedString(@"ai_asr_file.fmt.mp3");
    if ([ext isEqualToString:@"wav"])  return TSLocalizedString(@"ai_asr_file.fmt.wav");
    if ([ext isEqualToString:@"opus"]) return TSLocalizedString(@"ai_asr_file.fmt.opus");
    if ([ext isEqualToString:@"pcm"])  return TSLocalizedString(@"ai_asr_file.fmt.pcm");
    return ext.length > 0 ? ext.uppercaseString : @"-";
}

/// 字节数 → 可读字符串
- (NSString *)readableSize:(unsigned long long)bytes {
    if (bytes == 0) return @"0 B";
    if (bytes < 1024)            return [NSString stringWithFormat:@"%llu B", bytes];
    if (bytes < 1024 * 1024)     return [NSString stringWithFormat:@"%.1f KB", bytes / 1024.0];
    if (bytes < 1024ULL * 1024 * 1024) return [NSString stringWithFormat:@"%.1f MB", bytes / (1024.0 * 1024.0)];
    return [NSString stringWithFormat:@"%.2f GB", bytes / (1024.0 * 1024.0 * 1024.0)];
}

/// 截短 taskId，便于日志展示
- (NSString *)shortIdForTaskId:(NSString *)taskId {
    if (taskId.length <= 8) return taskId;
    return [NSString stringWithFormat:@"%@…%@",
              [taskId substringToIndex:4],
              [taskId substringFromIndex:taskId.length - 4]];
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

- (UIView *)fileCardView {
    if (!_fileCardView) {
        _fileCardView = [self cardContainer];
    }
    return _fileCardView;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] init];
        _fileNameLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
        _fileNameLabel.textColor = [UIColor secondaryLabelColor];
    }
    return _fileNameLabel;
}

- (UILabel *)fileSubLabel {
    if (!_fileSubLabel) {
        _fileSubLabel = [[UILabel alloc] init];
        _fileSubLabel.font = [UIFont systemFontOfSize:12.0];
        _fileSubLabel.textColor = [UIColor tertiaryLabelColor];
    }
    return _fileSubLabel;
}

- (UIButton *)chooseFileButton {
    if (!_chooseFileButton) {
        _chooseFileButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_chooseFileButton setTitle:TSLocalizedString(@"ai_asr_file.btn_choose")
                            forState:UIControlStateNormal];
        _chooseFileButton.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
        [_chooseFileButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        _chooseFileButton.backgroundColor = [[UIColor systemBlueColor] colorWithAlphaComponent:0.10];
        _chooseFileButton.layer.cornerRadius = 8.0;
        [_chooseFileButton addTarget:self action:@selector(onChooseFileTap)
                    forControlEvents:UIControlEventTouchUpInside];
    }
    return _chooseFileButton;
}

- (UIView *)configCardView {
    if (!_configCardView) {
        _configCardView = [self cardContainer];
    }
    return _configCardView;
}

- (UILabel *)languageTitleLabel {
    if (!_languageTitleLabel) {
        _languageTitleLabel = [[UILabel alloc] init];
        _languageTitleLabel.font = [UIFont systemFontOfSize:14.0];
        _languageTitleLabel.textColor = [UIColor labelColor];
        _languageTitleLabel.text = TSLocalizedString(@"ai_asr_file.label_language");
    }
    return _languageTitleLabel;
}

- (UIButton *)languageButton {
    if (!_languageButton) {
        _languageButton = [self pickerButtonWithAction:@selector(onLanguageButtonTap)];
    }
    return _languageButton;
}

- (UILabel *)formatTitleLabel {
    if (!_formatTitleLabel) {
        _formatTitleLabel = [[UILabel alloc] init];
        _formatTitleLabel.font = [UIFont systemFontOfSize:14.0];
        _formatTitleLabel.textColor = [UIColor labelColor];
        _formatTitleLabel.text = TSLocalizedString(@"ai_asr_file.label_format");
    }
    return _formatTitleLabel;
}

- (UIButton *)formatButton {
    if (!_formatButton) {
        _formatButton = [self pickerButtonWithAction:@selector(onFormatButtonTap)];
    }
    return _formatButton;
}

- (UILabel *)taskMetaLabel {
    if (!_taskMetaLabel) {
        _taskMetaLabel = [[UILabel alloc] init];
        _taskMetaLabel.font = [UIFont systemFontOfSize:12.0];
        _taskMetaLabel.textColor = [UIColor secondaryLabelColor];
    }
    return _taskMetaLabel;
}

- (UIButton *)recognizeButton {
    if (!_recognizeButton) {
        _recognizeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_recognizeButton setTitle:TSLocalizedString(@"ai_asr_file.btn_recognize")
                          forState:UIControlStateNormal];
        _recognizeButton.backgroundColor = [UIColor systemBlueColor];
        [_recognizeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _recognizeButton.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
        _recognizeButton.layer.cornerRadius = 8.0;
        [_recognizeButton addTarget:self action:@selector(onRecognizeTap)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _recognizeButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelButton setTitle:TSLocalizedString(@"ai_asr_file.btn_cancel")
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

- (TSAIStreamTextView *)streamView {
    if (!_streamView) {
        _streamView = [[TSAIStreamTextView alloc] init];
        _streamView.title = TSLocalizedString(@"ai_asr_file.section_stream");
    }
    return _streamView;
}

- (TSAILogView *)logView {
    if (!_logView) {
        _logView = [[TSAILogView alloc] init];
    }
    return _logView;
}

/// 卡片通用容器
- (UIView *)cardContainer {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    card.layer.cornerRadius = 12.0;
    return card;
}

/// 配置区下拉按钮共用样式
- (UIButton *)pickerButtonWithAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 8.0;
    button.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
    button.layer.borderColor = [UIColor systemGray4Color].CGColor;
    button.titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium];
    [button setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
