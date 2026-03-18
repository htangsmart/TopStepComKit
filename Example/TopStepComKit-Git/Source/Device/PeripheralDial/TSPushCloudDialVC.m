//
//  TSPushCloudDialVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSPushCloudDialVC.h"
#import <TopStepComKit/TopStepComKit.h>

// 允许的扩展名（小写）
static NSArray<NSString *> *kAllowedExtensions(void) {
    return @[ @"dial", @"bin", @"zip", @"tar" ];
}

static const CGFloat kPad       = 16.f;
static const CGFloat kBtnH      = 52.f;
static const CGFloat kCardR     = 14.f;
static const CGFloat kProgressH = 44.f;
static const CGFloat kToastDur  = 1.8f;
static const CGFloat kToastFade = 0.25f;
static const CGFloat kPreviewW  = 0.6f;   // 预览宽占屏宽比例
static const CGFloat kPreviewRatio = 1.42f; // 高/宽 竖向表盘

typedef NS_ENUM(NSInteger, TSPushCloudState) {
    TSPushCloudStateNone   = 0, // 未选文件
    TSPushCloudStateReady  = 1, // 已选文件待推送
    TSPushCloudStatePushing= 2, // 推送中
    TSPushCloudStateFailed = 3, // 推送失败
};

@interface TSPushCloudDialVC () <UIDocumentPickerDelegate>

@property (nonatomic, assign) TSPushCloudState state;
@property (nonatomic, copy)   NSString         *selectedFilePath;
@property (nonatomic, copy)   NSString         *selectedFileName;

@property (nonatomic, strong) UIScrollView     *scrollView;
@property (nonatomic, strong) UIButton         *selectFileBtn;
@property (nonatomic, strong) UILabel          *hintLabel;

@property (nonatomic, strong) UIView           *previewCard;
@property (nonatomic, strong) UIImageView     *previewImageView;
@property (nonatomic, strong) UIView           *previewPlaceholder;
@property (nonatomic, strong) UILabel          *previewPlaceholderLabel;
@property (nonatomic, strong) UILabel          *fileNameLabel;
@property (nonatomic, strong) UIButton         *startPushBtn;
@property (nonatomic, strong) UIButton         *reselectFileBtn;

@property (nonatomic, strong) UIView           *progressBgView;
@property (nonatomic, strong) UIView           *progressFillView;
@property (nonatomic, strong) UILabel          *progressPercentLabel;
@property (nonatomic, strong) UILabel          *progressStatusLabel;

@property (nonatomic, strong) UIDocumentPickerViewController *documentPicker;
@end

@implementation TSPushCloudDialVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self applyState:TSPushCloudStateNone];
}

#pragma mark - Override Base Setup

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"dial.push_cloud_title");
    _state     = TSPushCloudStateNone;
}

- (void)setupViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.selectFileBtn];
    [self.scrollView addSubview:self.hintLabel];

    [self.scrollView addSubview:self.previewCard];
    [self.previewCard addSubview:self.previewImageView];
    [self.previewCard addSubview:self.previewPlaceholder];
    [self.previewPlaceholder addSubview:self.previewPlaceholderLabel];
    [self.scrollView addSubview:self.fileNameLabel];
    [self.scrollView addSubview:self.startPushBtn];
    [self.scrollView addSubview:self.reselectFileBtn];

    [self.scrollView addSubview:self.progressBgView];
    [self.progressBgView addSubview:self.progressFillView];
    [self.progressBgView addSubview:self.progressPercentLabel];
    [self.scrollView addSubview:self.progressStatusLabel];
}

- (void)layoutViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;
    self.scrollView.frame = CGRectMake(0, top, w, h - top);

    CGFloat y = kPad;
    CGFloat cardW = w - kPad * 2;

    // 选择文件按钮 + 说明
    self.selectFileBtn.frame = CGRectMake(kPad, y, cardW, kBtnH);
    y += kBtnH + 8;
    self.hintLabel.frame = CGRectMake(kPad, y, cardW, 36);
    y += 44;

    // 预览卡片（宽 60%，高按比例）
    CGFloat pw = (w - kPad * 2) * kPreviewW;
    CGFloat ph = pw * kPreviewRatio;
    CGFloat px = (w - pw) / 2.f;
    self.previewCard.frame = CGRectMake(px, y, pw, ph);
    self.previewImageView.frame = self.previewCard.bounds;
    self.previewPlaceholder.frame = self.previewCard.bounds;
    self.previewPlaceholderLabel.frame = CGRectInset(self.previewCard.bounds, 8, 8);
    y += ph + kPad;

    self.fileNameLabel.frame = CGRectMake(kPad, y, cardW, 22);
    y += 28;

    self.startPushBtn.frame = CGRectMake(kPad, y, cardW, kBtnH);
    y += kBtnH + 8;
    self.reselectFileBtn.frame = CGRectMake(kPad, y, cardW, 44);
    y += 52;

    // 进度条区域
    self.progressBgView.frame = CGRectMake(kPad, y, cardW, kProgressH);
    self.progressFillView.frame = CGRectMake(0, 0, 0, kProgressH);
    self.progressPercentLabel.frame = self.progressBgView.bounds;
    y += kProgressH + 6;
    self.progressStatusLabel.frame = CGRectMake(kPad, y, cardW, 20);
    y += 28 + self.view.safeAreaInsets.bottom;

    self.scrollView.contentSize = CGSizeMake(w, y);
}

#pragma mark - State

- (void)applyState:(TSPushCloudState)state {
    self.state = state;
    BOOL none   = (state == TSPushCloudStateNone);
    BOOL ready  = (state == TSPushCloudStateReady);
    BOOL pushing= (state == TSPushCloudStatePushing);
    BOOL failed = (state == TSPushCloudStateFailed);

    self.selectFileBtn.hidden  = !none;
    self.hintLabel.hidden      = !none;

    self.previewCard.hidden    = none;
    self.fileNameLabel.hidden  = none;
    self.startPushBtn.hidden   = none;
    self.reselectFileBtn.hidden= none;

    self.progressBgView.hidden = !pushing;
    self.progressStatusLabel.hidden = !pushing;

    if (none) return;

    if (ready || failed) {
        self.startPushBtn.hidden = NO;
        [self.startPushBtn setTitle:(failed ? TSLocalizedString(@"dial.restart") : TSLocalizedString(@"dial.start_push")) forState:UIControlStateNormal];
        self.startPushBtn.enabled = YES;
        self.progressPercentLabel.text = @"";
        self.progressFillView.frame = CGRectMake(0, 0, 0, kProgressH);
    }
    if (pushing) {
        self.startPushBtn.enabled = NO;
    }
}

#pragma mark - File Picker

/** 允许的扩展名 */
- (BOOL)isAllowedExtension:(NSString *)pathExtension {
    NSString *ext = pathExtension.lowercaseString;
    for (NSString *e in kAllowedExtensions()) {
        if ([ext isEqualToString:e]) return YES;
    }
    return NO;
}

/** 仅允许 .dial / .bin / .zip / .tar，使用 UTI 限制后系统文件选择器只显示这些类型 */
- (void)openFilePicker {
    NSArray *types = @[
        @"com.topstep.dial",        // .dial，在 Info.plist UTImportedTypeDeclarations 中声明
        @"com.topstep.bin-dial",    // .bin
        @"public.zip-archive",      // .zip
        @"public.tar-archive"       // .tar
    ];
    self.documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
    self.documentPicker.delegate = self;
    self.documentPicker.allowsMultipleSelection = NO;
    self.documentPicker.title = TSLocalizedString(@"dial.select_file");
    [self presentViewController:self.documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) return;
    NSURL *url = urls.firstObject;
    NSString *ext = url.pathExtension.lowercaseString;
    if (![self isAllowedExtension:ext]) {
        [self showAlertWithMsg:TSLocalizedString(@"dial.select_file_hint")];
        return;
    }

    NSString *fileName = url.lastPathComponent;
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *destPath = [docPath stringByAppendingPathComponent:fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
    }

    BOOL started = [url startAccessingSecurityScopedResource];
    @try {
        NSError *err = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:url toURL:[NSURL fileURLWithPath:destPath] error:&err]) {
            [self showAlertWithMsg:err.localizedDescription ?: TSLocalizedString(@"dial.copy_failed")];
            return;
        }
        self.selectedFilePath = destPath;
        self.selectedFileName = fileName;
        [self updatePreviewFromFileName:fileName];
        self.fileNameLabel.text = fileName;
        [self applyState:TSPushCloudStateReady];
    } @finally {
        if (started) [url stopAccessingSecurityScopedResource];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
}

/** 根据文件名从工程查找预览图，找不到则占位 + 文件名 */
- (void)updatePreviewFromFileName:(NSString *)fileName {
    NSString *nameWithoutExt = [fileName stringByDeletingPathExtension];
    UIImage *img = nil;
    NSArray *exts = @[ @"", @".png", @".jpg", @".jpeg" ];
    for (NSString *e in exts) {
        NSString *key = e.length ? [nameWithoutExt stringByAppendingString:e] : nameWithoutExt;
        img = [UIImage imageNamed:key];
        if (img) break;
    }
    if (img) {
        self.previewImageView.image = img;
        self.previewImageView.hidden = NO;
        self.previewPlaceholder.hidden = YES;
    } else {
        self.previewImageView.hidden = YES;
        self.previewPlaceholder.hidden = NO;
        self.previewPlaceholderLabel.text = nameWithoutExt.length ? nameWithoutExt : TSLocalizedString(@"dial.default_dial_name");
        self.previewPlaceholder.backgroundColor = [TSColor_Primary colorWithAlphaComponent:0.2f];
    }
}

#pragma mark - Push

- (void)startPush {
    if (!self.selectedFilePath.length) return;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.selectedFilePath]) {
        [self showAlertWithMsg:TSLocalizedString(@"dial.file_not_exist")];
        return;
    }

    TSDialModel *dial = [[TSDialModel alloc] init];
    dial.dialId   = [NSString stringWithFormat:@"cloud_%ld", (long)[[NSDate date] timeIntervalSince1970]];
    dial.dialName = self.selectedFileName.length ? [self.selectedFileName stringByDeletingPathExtension] : TSLocalizedString(@"dial.cloud_dial_name");
    dial.dialType = eTSDialTypeCloud;
    dial.filePath = self.selectedFilePath;

    [self applyState:TSPushCloudStatePushing];
    self.progressFillView.frame = CGRectMake(0, 0, 0, kProgressH);
    self.progressPercentLabel.text = @"0%";
    self.progressStatusLabel.text = TSLocalizedString(@"dial.pushing_status");

    __weak typeof(self) wself = self;
    [[[TopStepComKit sharedInstance] dial] installDownloadedCloudDial:dial
        progressBlock:^(TSDialPushResult result, NSInteger progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself updateProgress:progress];
            });
        }
        completion:^(TSDialPushResult result, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result == eTSDialPushResultSuccess) {
                    [wself handlePushSuccess];
                } else {
                    [wself handlePushFailed:error];
                }
            });
        }];
}

- (void)updateProgress:(NSInteger)progress {
    if (self.state != TSPushCloudStatePushing) return;
    CGFloat w = CGRectGetWidth(self.progressBgView.bounds);
    CGFloat fillW = w * (progress / 100.f);
    self.progressFillView.frame = CGRectMake(0, 0, fillW, kProgressH);
    self.progressPercentLabel.text = [NSString stringWithFormat:@"%ld%%", (long)progress];
}

- (void)handlePushSuccess {
    __weak typeof(self) wself = self;
    [self showSuccessToast:TSLocalizedString(@"dial.push_success_toast") completion:^{
        if (wself.onPushSuccess) wself.onPushSuccess();
        [wself.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)handlePushFailed:(NSError *)error {
    [self showToast:error.localizedDescription ?: TSLocalizedString(@"dial.push_failed_toast") success:NO];
    [self applyState:TSPushCloudStateFailed];
}

- (void)showSuccessToast:(NSString *)msg completion:(void (^)(void))completion {
    [self showToast:msg success:YES completion:completion];
}

- (void)showToast:(NSString *)msg success:(BOOL)success {
    [self showToast:msg success:success completion:nil];
}

- (void)showToast:(NSString *)msg success:(BOOL)success completion:(nullable void (^)(void))completion {
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = success ? [TSColor_Success colorWithAlphaComponent:0.92f] : [UIColor colorWithWhite:0.2 alpha:0.88f];
    toast.layer.cornerRadius = 10.f;
    toast.alpha = 0;

    UILabel *lb = [[UILabel alloc] init];
    lb.text = msg;
    lb.textColor = UIColor.whiteColor;
    lb.font = [UIFont systemFontOfSize:14];
    lb.textAlignment = NSTextAlignmentCenter;

    CGFloat maxW = CGRectGetWidth(self.view.bounds) - 80.f;
    CGSize sz = [lb sizeThatFits:CGSizeMake(maxW - 32, CGFLOAT_MAX)];
    CGFloat tw = MIN(sz.width + 32, maxW);
    CGFloat th = sz.height + 20;
    toast.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - tw) / 2.f, CGRectGetHeight(self.view.bounds) * 0.72f, tw, th);
    lb.frame = CGRectMake(16, 10, tw - 32, sz.height);
    [toast addSubview:lb];
    [self.view addSubview:toast];

    [UIView animateWithDuration:kToastFade animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kToastDur * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:kToastFade animations:^{ toast.alpha = 0; } completion:^(BOOL __) {
                [toast removeFromSuperview];
                if (completion) completion();
            }];
        });
    }];
}

#pragma mark - Actions

- (void)onSelectFileTapped {
    [self openFilePicker];
}

- (void)onStartPushTapped {
    [self startPush];
}

- (void)onReselectFileTapped {
    [self openFilePicker];
}

#pragma mark - Lazy

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = TSColor_Background;
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (UIButton *)selectFileBtn {
    if (!_selectFileBtn) {
        _selectFileBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _selectFileBtn.backgroundColor = TSColor_Primary;
        _selectFileBtn.layer.cornerRadius = kCardR;
        [_selectFileBtn setTitle:TSLocalizedString(@"dial.select_file") forState:UIControlStateNormal];
        [_selectFileBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _selectFileBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [_selectFileBtn addTarget:self action:@selector(onSelectFileTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectFileBtn;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.text = TSLocalizedString(@"dial.select_file_hint");
        _hintLabel.font = TSFont_Caption;
        _hintLabel.textColor = TSColor_TextSecondary;
        _hintLabel.numberOfLines = 2;
    }
    return _hintLabel;
}

- (UIView *)previewCard {
    if (!_previewCard) {
        _previewCard = [[UIView alloc] init];
        _previewCard.backgroundColor = TSColor_Card;
        _previewCard.layer.cornerRadius = kCardR;
        _previewCard.layer.shadowColor = UIColor.blackColor.CGColor;
        _previewCard.layer.shadowOpacity = 0.08f;
        _previewCard.layer.shadowOffset = CGSizeMake(0, 2);
        _previewCard.layer.shadowRadius = 8.f;
    }
    return _previewCard;
}

- (UIImageView *)previewImageView {
    if (!_previewImageView) {
        _previewImageView = [[UIImageView alloc] init];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.clipsToBounds = YES;
    }
    return _previewImageView;
}

- (UIView *)previewPlaceholder {
    if (!_previewPlaceholder) {
        _previewPlaceholder = [[UIView alloc] init];
    }
    return _previewPlaceholder;
}

- (UILabel *)previewPlaceholderLabel {
    if (!_previewPlaceholderLabel) {
        _previewPlaceholderLabel = [[UILabel alloc] init];
        _previewPlaceholderLabel.font = TSFont_Body;
        _previewPlaceholderLabel.textColor = TSColor_TextSecondary;
        _previewPlaceholderLabel.textAlignment = NSTextAlignmentCenter;
        _previewPlaceholderLabel.numberOfLines = 3;
    }
    return _previewPlaceholderLabel;
}

- (UILabel *)fileNameLabel {
    if (!_fileNameLabel) {
        _fileNameLabel = [[UILabel alloc] init];
        _fileNameLabel.font = TSFont_Caption;
        _fileNameLabel.textColor = TSColor_TextSecondary;
    }
    return _fileNameLabel;
}

- (UIButton *)startPushBtn {
    if (!_startPushBtn) {
        _startPushBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _startPushBtn.backgroundColor = TSColor_Primary;
        _startPushBtn.layer.cornerRadius = kCardR;
        [_startPushBtn setTitle:TSLocalizedString(@"dial.start_push") forState:UIControlStateNormal];
        [_startPushBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _startPushBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [_startPushBtn addTarget:self action:@selector(onStartPushTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startPushBtn;
}

- (UIButton *)reselectFileBtn {
    if (!_reselectFileBtn) {
        _reselectFileBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_reselectFileBtn setTitle:TSLocalizedString(@"dial.reselect_file") forState:UIControlStateNormal];
        [_reselectFileBtn setTitleColor:TSColor_Primary forState:UIControlStateNormal];
        _reselectFileBtn.titleLabel.font = TSFont_Body;
        [_reselectFileBtn addTarget:self action:@selector(onReselectFileTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reselectFileBtn;
}

- (UIView *)progressBgView {
    if (!_progressBgView) {
        _progressBgView = [[UIView alloc] init];
        _progressBgView.backgroundColor = [TSColor_Primary colorWithAlphaComponent:0.15f];
        _progressBgView.layer.cornerRadius = 8.f;
        _progressBgView.clipsToBounds = YES;
    }
    return _progressBgView;
}

- (UIView *)progressFillView {
    if (!_progressFillView) {
        _progressFillView = [[UIView alloc] init];
        _progressFillView.backgroundColor = TSColor_Primary;
        _progressFillView.layer.cornerRadius = 8.f;
    }
    return _progressFillView;
}

- (UILabel *)progressPercentLabel {
    if (!_progressPercentLabel) {
        _progressPercentLabel = [[UILabel alloc] init];
        _progressPercentLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        _progressPercentLabel.textColor = TSColor_TextPrimary;
        _progressPercentLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _progressPercentLabel;
}

- (UILabel *)progressStatusLabel {
    if (!_progressStatusLabel) {
        _progressStatusLabel = [[UILabel alloc] init];
        _progressStatusLabel.font = TSFont_Caption;
        _progressStatusLabel.textColor = TSColor_TextSecondary;
    }
    return _progressStatusLabel;
}

@end
