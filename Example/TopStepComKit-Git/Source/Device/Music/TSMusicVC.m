//
//  TSMusicVC.m
//  TopStepComKit-Git_Example
//
//  Created by 磐石 on 2026/5/8.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMusicVC.h"
#import <TopStepComKit/TopStepComKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

static const CGFloat kPad             = 16.f;
static const CGFloat kCornerRadius    = 12.f;
static const CGFloat kBottomBarHeight = 88.f;
static const CGFloat kControlPanelH   = 168.f;
static const CGFloat kCellHeight      = 64.f;
static const CGFloat kToastDuration   = 1.6f;
static const CGFloat kToastFade       = 0.2f;

static NSString *const kMusicCellId = @"TSMusicCell";

@interface TSMusicVC () <UITableViewDataSource, UITableViewDelegate, UIDocumentPickerDelegate>

// 控制面板
@property (nonatomic, strong) UIView    *controlPanel;
@property (nonatomic, strong) UIButton  *prevButton;
@property (nonatomic, strong) UIButton  *playPauseButton;
@property (nonatomic, strong) UIButton  *nextButton;
@property (nonatomic, strong) UIImageView *volumeMinIcon;
@property (nonatomic, strong) UIImageView *volumeMaxIcon;
@property (nonatomic, strong) UISlider  *volumeSlider;
@property (nonatomic, strong) UIButton  *volumeMinusButton;
@property (nonatomic, strong) UIButton  *muteButton;
@property (nonatomic, strong) UIButton  *volumePlusButton;

// 列表
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel     *emptyLabel;

// 底部栏（空闲态 / 推送态切换）
@property (nonatomic, strong) UIView         *bottomBar;
@property (nonatomic, strong) UIButton       *pushButton;
@property (nonatomic, strong) UIView         *progressPanel;
@property (nonatomic, strong) UILabel        *progressLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton       *cancelPushButton;

// 数据 / 状态
@property (nonatomic, strong) NSMutableArray<TSMusicModel *> *dataSource;
@property (nonatomic, assign) BOOL      isPlaying;
@property (nonatomic, assign) BOOL      isMuted;
@property (nonatomic, assign) NSInteger currentVolume;
@property (nonatomic, assign) BOOL      isPushing;
@property (nonatomic, assign) BOOL      isCanceling;
@property (nonatomic, assign) NSInteger lastVolumeBeforeSlide;
@property (nonatomic, copy)   NSString *pushingTempFilePath;
@property (nonatomic, copy)   NSString *pushingTitle;

@end

@implementation TSMusicVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadMusicList];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController && self.isPushing) {
        TSLog(@"[TSMusicVC] cancelPushMusic: -> (leaving page while pushing)");
        [self.musicInterface cancelPushMusic:^(BOOL success, NSError * _Nullable error) {
            TSLog(@"[TSMusicVC] cancelPushMusic: <- success=%d, error=%@",
                  success, error.localizedDescription);
        }];
    }
}

- (void)dealloc {
    [self cleanupTempFile];
}

#pragma mark - Override Base Setup

- (void)initData {
    [super initData];
    self.title = @"Music";
    _dataSource     = [NSMutableArray array];
    _isPlaying      = NO;
    _isMuted        = NO;
    _currentVolume  = 50;
    _isPushing      = NO;
    _isCanceling    = NO;
}

- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;

    [self.view addSubview:self.controlPanel];
    [self.controlPanel addSubview:self.prevButton];
    [self.controlPanel addSubview:self.playPauseButton];
    [self.controlPanel addSubview:self.nextButton];
    [self.controlPanel addSubview:self.volumeMinIcon];
    [self.controlPanel addSubview:self.volumeMaxIcon];
    [self.controlPanel addSubview:self.volumeSlider];
    [self.controlPanel addSubview:self.volumeMinusButton];
    [self.controlPanel addSubview:self.muteButton];
    [self.controlPanel addSubview:self.volumePlusButton];

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.emptyLabel];

    [self.view addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.pushButton];
    [self.bottomBar addSubview:self.progressPanel];
    [self.progressPanel addSubview:self.progressLabel];
    [self.progressPanel addSubview:self.progressView];
    [self.progressPanel addSubview:self.cancelPushButton];

    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                             target:self
                                                                             action:@selector(onRefreshTapped)];
    self.navigationItem.rightBarButtonItem = refresh;
}

- (void)layoutViews {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    if (w <= 0) return;

    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) top = self.view.safeAreaInsets.top;

    // 控制面板
    self.controlPanel.frame = CGRectMake(kPad, top + 8.f, w - kPad * 2, kControlPanelH);
    [self layoutControlPanel];

    // 底部栏
    CGFloat bottomSafe = self.view.safeAreaInsets.bottom;
    CGFloat barH = kBottomBarHeight + bottomSafe;
    self.bottomBar.frame = CGRectMake(0, h - barH, w, barH);
    self.pushButton.frame      = CGRectMake(kPad, 12.f, w - kPad * 2, kBottomBarHeight - 24.f);
    self.progressPanel.frame   = self.bottomBar.bounds;
    self.progressLabel.frame   = CGRectMake(kPad, 8.f, w - kPad * 2, 18.f);
    self.progressView.frame    = CGRectMake(kPad, 30.f, w - kPad * 2, 6.f);
    self.cancelPushButton.frame = CGRectMake(kPad, 44.f, w - kPad * 2, 32.f);

    // 列表
    CGFloat tableTop = CGRectGetMaxY(self.controlPanel.frame) + 12.f;
    CGFloat tableH   = CGRectGetMinY(self.bottomBar.frame) - tableTop;
    self.tableView.frame  = CGRectMake(0, tableTop, w, tableH);
    self.emptyLabel.frame = CGRectMake(kPad, tableTop + 40.f, w - kPad * 2, 24.f);
}

- (void)layoutControlPanel {
    CGFloat w = CGRectGetWidth(self.controlPanel.bounds);
    CGFloat btn = 56.f;
    CGFloat playSize = 64.f;

    CGFloat playX = (w - playSize) / 2.f;
    self.playPauseButton.frame = CGRectMake(playX, 12.f, playSize, playSize);
    self.prevButton.frame = CGRectMake(playX - btn - 24.f, 12.f + (playSize - btn) / 2.f, btn, btn);
    self.nextButton.frame = CGRectMake(playX + playSize + 24.f, 12.f + (playSize - btn) / 2.f, btn, btn);

    CGFloat sliderY = 92.f;
    CGFloat iconSize = 18.f;
    self.volumeMinIcon.frame = CGRectMake(kPad, sliderY, iconSize, iconSize);
    self.volumeMaxIcon.frame = CGRectMake(w - kPad - iconSize, sliderY, iconSize, iconSize);
    self.volumeSlider.frame  = CGRectMake(kPad + iconSize + 8.f, sliderY - 6.f,
                                          w - (kPad + iconSize + 8.f) * 2, 30.f);

    CGFloat btnY = 130.f;
    CGFloat btnW = (w - kPad * 2 - 16.f) / 3.f;
    CGFloat btnH = 30.f;
    self.volumeMinusButton.frame = CGRectMake(kPad, btnY, btnW, btnH);
    self.muteButton.frame        = CGRectMake(kPad + btnW + 8.f, btnY, btnW, btnH);
    self.volumePlusButton.frame  = CGRectMake(kPad + (btnW + 8.f) * 2, btnY, btnW, btnH);
}

#pragma mark - 私有方法

/// 取音乐接口
- (id<TSMusicInterface>)musicInterface {
    return [TopStepComKit sharedInstance].music;
}

/// 拉取设备音乐列表
- (void)reloadMusicList {
    if (!self.musicInterface) {
        [self showToast:@"Music interface unavailable"];
        return;
    }
    TSLog(@"[TSMusicVC] fetchAllMusics: ->");
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [self.musicInterface fetchAllMusics:^(NSArray<TSMusicModel *> * _Nullable musics, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSMusicVC] fetchAllMusics: <- count=%lu, error=%@",
              (unsigned long)musics.count, error.localizedDescription);
        [self hideLoading];
        if (error) {
            [self showToast:error.localizedDescription ?: @"Failed to fetch music list"];
        }
        [self.dataSource removeAllObjects];
        if (musics.count > 0) {
            [self.dataSource addObjectsFromArray:musics];
        }
        [self.tableView reloadData];
        [self updateEmptyState];
    }];
}

/// 列表为空时显示空文案
- (void)updateEmptyState {
    BOOL empty = self.dataSource.count == 0;
    self.emptyLabel.hidden = !empty;
    self.tableView.hidden  = empty;
}

/// 弹出系统文件选择器（仅音频）
- (void)presentDocumentPicker {
    NSArray *types = @[ (NSString *)kUTTypeAudio ];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types
                                                                                                     inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

/// 把所选文件 copy 到沙盒 tmp 并发起推送
- (void)startPushWithFileURL:(NSURL *)url {
    NSString *fileName = url.lastPathComponent;
    NSString *tmpDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TSMusicPush"];
    [[NSFileManager defaultManager] createDirectoryAtPath:tmpDir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *destPath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",
                                                                  [[NSUUID UUID] UUIDString], fileName]];

    BOOL accessing = [url startAccessingSecurityScopedResource];
    NSError *err = nil;
    BOOL ok = [[NSFileManager defaultManager] copyItemAtURL:url
                                                      toURL:[NSURL fileURLWithPath:destPath]
                                                      error:&err];
    if (accessing) [url stopAccessingSecurityScopedResource];

    if (!ok) {
        [self showToast:err.localizedDescription ?: @"Copy failed"];
        return;
    }

    NSString *title = [fileName stringByDeletingPathExtension];
    TSMusicModel *music = [[TSMusicModel alloc] init];
    music.title    = title;
    music.filePath = destPath;

    self.pushingTempFilePath = destPath;
    self.pushingTitle        = title;
    self.isPushing           = YES;
    self.isCanceling         = NO;
    [self switchBottomToPushing];
    [self setControlsEnabled:NO];
    [self updateProgress:0];

    TSLog(@"[TSMusicVC] pushMusic: -> title=%@, filePath=%@", title, destPath);
    __weak typeof(self) weakSelf = self;
    [self.musicInterface pushMusic:music
        progress:^(TSFileTransferStatus state, NSInteger progress) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            TSLog(@"[TSMusicVC] pushMusic: progress state=%ld, progress=%ld%%",
                  (long)state, (long)progress);
            [self updateProgress:progress];
        }
        success:^(TSFileTransferStatus state) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            TSLog(@"[TSMusicVC] pushMusic: <- success state=%ld", (long)state);
            [self handlePushFinishedWithSuccess:YES canceled:NO error:nil];
        }
        failure:^(TSFileTransferStatus state, NSError * _Nullable error) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            BOOL canceled = (state == eTSFileTransferStatusCanceled);
            TSLog(@"[TSMusicVC] pushMusic: <- failure state=%ld, canceled=%d, error=%@",
                  (long)state, canceled, error.localizedDescription);
            [self handlePushFinishedWithSuccess:NO canceled:canceled error:error];
        }];
}

/// 推送结束（成功/失败/取消）统一收尾
- (void)handlePushFinishedWithSuccess:(BOOL)success canceled:(BOOL)canceled error:(NSError *)error {
    self.isPushing   = NO;
    self.isCanceling = NO;
    [self switchBottomToIdle];
    [self setControlsEnabled:YES];
    [self cleanupTempFile];

    if (success) {
        [self showToast:@"Push success"];
        [self reloadMusicList];
    } else if (canceled) {
        [self showToast:@"Canceled"];
    } else {
        [self showToast:error.localizedDescription ?: @"Push failed"];
    }
}

/// 切换底部栏到「推送中」形态
- (void)switchBottomToPushing {
    self.pushButton.hidden    = YES;
    self.progressPanel.hidden = NO;
    self.cancelPushButton.enabled = YES;
    [self.cancelPushButton setTitle:@"Cancel push" forState:UIControlStateNormal];
}

/// 切换底部栏到「空闲」形态
- (void)switchBottomToIdle {
    self.pushButton.hidden    = NO;
    self.progressPanel.hidden = YES;
}

/// 刷新进度文案与进度条
- (void)updateProgress:(NSInteger)progress {
    NSInteger p = MAX(0, MIN(100, progress));
    self.progressLabel.text = [NSString stringWithFormat:@"Pushing  %@  %ld%%",
                               self.pushingTitle ?: @"", (long)p];
    [self.progressView setProgress:p / 100.f animated:YES];
}

/// 删除推送临时文件
- (void)cleanupTempFile {
    if (self.pushingTempFilePath.length > 0) {
        [[NSFileManager defaultManager] removeItemAtPath:self.pushingTempFilePath error:nil];
        self.pushingTempFilePath = nil;
    }
}

/// 整体启用/禁用播放与音量控件
- (void)setControlsEnabled:(BOOL)enabled {
    self.prevButton.enabled        = enabled;
    self.playPauseButton.enabled   = enabled;
    self.nextButton.enabled        = enabled;
    self.volumeSlider.enabled      = enabled;
    self.volumeMinusButton.enabled = enabled;
    self.muteButton.enabled        = enabled;
    self.volumePlusButton.enabled  = enabled;
}

/// 同步播放按钮图标
- (void)refreshPlayPauseIcon {
    NSString *symbol = self.isPlaying ? @"pause.circle.fill" : @"play.circle.fill";
    UIImage *img = nil;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:56 weight:UIImageSymbolWeightRegular];
        img = [UIImage systemImageNamed:symbol withConfiguration:cfg];
    }
    [self.playPauseButton setImage:img forState:UIControlStateNormal];
}

/// 同步静音按钮文案
- (void)refreshMuteTitle {
    [self.muteButton setTitle:(self.isMuted ? @"Unmute" : @"Mute") forState:UIControlStateNormal];
}

/// 时长格式化 mm:ss / h:mm:ss
- (NSString *)formatDuration:(NSTimeInterval)seconds {
    NSInteger total = (NSInteger)seconds;
    NSInteger h = total / 3600;
    NSInteger m = (total % 3600) / 60;
    NSInteger s = total % 60;
    if (h > 0) return [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)h, (long)m, (long)s];
    return [NSString stringWithFormat:@"%ld:%02ld", (long)m, (long)s];
}

/// 简易 toast
- (void)showToast:(NSString *)msg {
    if (msg.length == 0) return;
    UIView *toast = [[UIView alloc] init];
    toast.backgroundColor = [UIColor colorWithWhite:0.15f alpha:0.9f];
    toast.layer.cornerRadius = 10.f;
    toast.alpha = 0;

    UILabel *label = [[UILabel alloc] init];
    label.text = msg;
    label.textColor = UIColor.whiteColor;
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;

    CGFloat maxW = CGRectGetWidth(self.view.bounds) - 80.f;
    CGSize sz = [label sizeThatFits:CGSizeMake(maxW - 32, CGFLOAT_MAX)];
    CGFloat tw = MIN(sz.width + 32, maxW);
    CGFloat th = sz.height + 20.f;
    toast.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - tw) / 2.f,
                             CGRectGetHeight(self.view.bounds) * 0.7f, tw, th);
    label.frame = CGRectMake(16, 10, tw - 32, sz.height);
    [toast addSubview:label];
    [self.view addSubview:toast];

    [UIView animateWithDuration:kToastFade animations:^{ toast.alpha = 1; } completion:^(BOOL _) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kToastDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:kToastFade animations:^{ toast.alpha = 0; } completion:^(BOOL __) {
                [toast removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - 事件响应

- (void)onRefreshTapped {
    [self reloadMusicList];
}

- (void)onPlayPauseTapped {
    if (!self.musicInterface) return;
    BOOL targetPlay = !self.isPlaying;
    self.playPauseButton.enabled = NO;
    TSLog(@"[TSMusicVC] %@ ->", targetPlay ? @"playMusic:" : @"pauseMusic:");
    __weak typeof(self) weakSelf = self;
    TSCompletionBlock completion = ^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSMusicVC] %@ <- success=%d, error=%@",
              targetPlay ? @"playMusic:" : @"pauseMusic:",
              success, error.localizedDescription);
        self.playPauseButton.enabled = YES;
        if (success) {
            self.isPlaying = targetPlay;
            [self refreshPlayPauseIcon];
        } else {
            [self showToast:error.localizedDescription ?: @"Operation failed"];
        }
    };
    if (targetPlay) {
        [self.musicInterface playMusic:completion];
    } else {
        [self.musicInterface pauseMusic:completion];
    }
}

- (void)onPrevTapped {
    if (!self.musicInterface) return;
    self.prevButton.enabled = NO;
    TSLog(@"[TSMusicVC] playPreviousMusic: ->");
    __weak typeof(self) weakSelf = self;
    [self.musicInterface playPreviousMusic:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSMusicVC] playPreviousMusic: <- success=%d, error=%@",
              success, error.localizedDescription);
        self.prevButton.enabled = YES;
        if (!success) [self showToast:error.localizedDescription ?: @"Operation failed"];
    }];
}

- (void)onNextTapped {
    if (!self.musicInterface) return;
    self.nextButton.enabled = NO;
    TSLog(@"[TSMusicVC] playNextMusic: ->");
    __weak typeof(self) weakSelf = self;
    [self.musicInterface playNextMusic:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSMusicVC] playNextMusic: <- success=%d, error=%@",
              success, error.localizedDescription);
        self.nextButton.enabled = YES;
        if (!success) [self showToast:error.localizedDescription ?: @"Operation failed"];
    }];
}

- (void)onVolumeMinusTapped {
    if (!self.musicInterface) return;
    self.volumeMinusButton.enabled = NO;
    TSLog(@"[TSMusicVC] decreaseVolume: ->");
    __weak typeof(self) weakSelf = self;
    [self.musicInterface decreaseVolume:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSMusicVC] decreaseVolume: <- success=%d, error=%@",
              success, error.localizedDescription);
        self.volumeMinusButton.enabled = YES;
        if (!success) [self showToast:error.localizedDescription ?: @"Operation failed"];
    }];
}

- (void)onVolumePlusTapped {
    if (!self.musicInterface) return;
    self.volumePlusButton.enabled = NO;
    TSLog(@"[TSMusicVC] increaseVolume: ->");
    __weak typeof(self) weakSelf = self;
    [self.musicInterface increaseVolume:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSMusicVC] increaseVolume: <- success=%d, error=%@",
              success, error.localizedDescription);
        self.volumePlusButton.enabled = YES;
        if (!success) [self showToast:error.localizedDescription ?: @"Operation failed"];
    }];
}

- (void)onMuteTapped {
    if (!self.musicInterface) return;
    BOOL targetMute = !self.isMuted;
    self.muteButton.enabled = NO;
    TSLog(@"[TSMusicVC] %@ ->", targetMute ? @"muteVolume:" : @"unmuteVolume:");
    __weak typeof(self) weakSelf = self;
    TSCompletionBlock completion = ^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSMusicVC] %@ <- success=%d, error=%@",
              targetMute ? @"muteVolume:" : @"unmuteVolume:",
              success, error.localizedDescription);
        self.muteButton.enabled = YES;
        if (success) {
            self.isMuted = targetMute;
            [self refreshMuteTitle];
        } else {
            [self showToast:error.localizedDescription ?: @"Operation failed"];
        }
    };
    if (targetMute) {
        [self.musicInterface muteVolume:completion];
    } else {
        [self.musicInterface unmuteVolume:completion];
    }
}

- (void)onVolumeSliderTouchDown {
    self.lastVolumeBeforeSlide = self.currentVolume;
}

- (void)onVolumeSliderTouchUp {
    if (!self.musicInterface) return;
    NSInteger value = (NSInteger)roundf(self.volumeSlider.value);
    self.volumeSlider.enabled = NO;
    TSLog(@"[TSMusicVC] setVolume:%ld ->", (long)value);
    __weak typeof(self) weakSelf = self;
    [self.musicInterface setVolume:value completion:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        TSLog(@"[TSMusicVC] setVolume:%ld <- success=%d, error=%@",
              (long)value, success, error.localizedDescription);
        self.volumeSlider.enabled = YES;
        if (success) {
            self.currentVolume = value;
        } else {
            self.volumeSlider.value = self.lastVolumeBeforeSlide;
            [self showToast:error.localizedDescription ?: @"Operation failed"];
        }
    }];
}

- (void)onPushTapped {
    if (self.isPushing) return;
    [self presentDocumentPicker];
}

- (void)onCancelPushTapped {
    if (!self.isPushing || self.isCanceling) return;
    self.isCanceling = YES;
    self.cancelPushButton.enabled = NO;
    [self.cancelPushButton setTitle:@"Canceling…" forState:UIControlStateNormal];
    TSLog(@"[TSMusicVC] cancelPushMusic: ->");
    [self.musicInterface cancelPushMusic:^(BOOL success, NSError * _Nullable error) {
        TSLog(@"[TSMusicVC] cancelPushMusic: <- success=%d, error=%@",
              success, error.localizedDescription);
    }];
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMusicCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kMusicCellId];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    TSMusicModel *music = self.dataSource[indexPath.row];
    cell.textLabel.text = music.title.length > 0 ? music.title : @"(Unknown)";
    NSString *artist = music.artist.length > 0 ? music.artist : @"-";
    NSString *duration = music.duration > 0 ? [self formatDuration:music.duration] : @"--:--";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@   %@", artist, duration];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    __weak typeof(self) weakSelf = self;
    UIContextualAction *delete = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive
        title:@"Delete"
        handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { completionHandler(NO); return; }
            [self confirmDeleteAtIndexPath:indexPath completion:completionHandler];
        }];
    return [UISwipeActionsConfiguration configurationWithActions:@[ delete ]];
}

- (void)confirmDeleteAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(BOOL))completion {
    if (indexPath.row >= (NSInteger)self.dataSource.count) { completion(NO); return; }
    TSMusicModel *music = self.dataSource[indexPath.row];
    NSString *msg = [NSString stringWithFormat:@"Delete \"%@\"?", music.title ?: @""];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull a) {
        completion(NO);
    }]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull a) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { completion(NO); return; }
        completion(YES);
        [self showLoading];
        TSLog(@"[TSMusicVC] deleteMusic: -> musicId=%@, title=%@", music.musicId, music.title);
        [self.musicInterface deleteMusic:music completion:^(BOOL success, NSError * _Nullable error) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            TSLog(@"[TSMusicVC] deleteMusic: <- success=%d, error=%@",
                  success, error.localizedDescription);
            [self hideLoading];
            if (success) {
                [self showToast:@"Deleted"];
                [self reloadMusicList];
            } else {
                [self showToast:error.localizedDescription ?: @"Delete failed"];
            }
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) return;
    [self startPushWithFileURL:urls.firstObject];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
}

#pragma mark - 属性懒加载

- (UIView *)controlPanel {
    if (!_controlPanel) {
        _controlPanel = [[UIView alloc] init];
        _controlPanel.backgroundColor = TSColor_Card;
        _controlPanel.layer.cornerRadius = kCornerRadius;
    }
    return _controlPanel;
}

- (UIButton *)prevButton {
    if (!_prevButton) {
        _prevButton = [self circleControlButtonWithSymbol:@"backward.fill" pointSize:28.f];
        [_prevButton addTarget:self action:@selector(onPrevTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prevButton;
}

- (UIButton *)playPauseButton {
    if (!_playPauseButton) {
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _playPauseButton.tintColor = TSColor_Primary;
        [_playPauseButton addTarget:self action:@selector(onPlayPauseTapped) forControlEvents:UIControlEventTouchUpInside];
        if (@available(iOS 13.0, *)) {
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:56 weight:UIImageSymbolWeightRegular];
            [_playPauseButton setImage:[UIImage systemImageNamed:@"play.circle.fill" withConfiguration:cfg] forState:UIControlStateNormal];
        }
    }
    return _playPauseButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [self circleControlButtonWithSymbol:@"forward.fill" pointSize:28.f];
        [_nextButton addTarget:self action:@selector(onNextTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIButton *)circleControlButtonWithSymbol:(NSString *)symbol pointSize:(CGFloat)size {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.tintColor = TSColor_Primary;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:size weight:UIImageSymbolWeightRegular];
        [btn setImage:[UIImage systemImageNamed:symbol withConfiguration:cfg] forState:UIControlStateNormal];
    }
    return btn;
}

- (UIImageView *)volumeMinIcon {
    if (!_volumeMinIcon) {
        _volumeMinIcon = [[UIImageView alloc] init];
        _volumeMinIcon.tintColor = TSColor_TextSecondary;
        _volumeMinIcon.contentMode = UIViewContentModeScaleAspectFit;
        if (@available(iOS 13.0, *)) {
            _volumeMinIcon.image = [UIImage systemImageNamed:@"speaker.fill"];
        }
    }
    return _volumeMinIcon;
}

- (UIImageView *)volumeMaxIcon {
    if (!_volumeMaxIcon) {
        _volumeMaxIcon = [[UIImageView alloc] init];
        _volumeMaxIcon.tintColor = TSColor_TextSecondary;
        _volumeMaxIcon.contentMode = UIViewContentModeScaleAspectFit;
        if (@available(iOS 13.0, *)) {
            _volumeMaxIcon.image = [UIImage systemImageNamed:@"speaker.wave.3.fill"];
        }
    }
    return _volumeMaxIcon;
}

- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        _volumeSlider = [[UISlider alloc] init];
        _volumeSlider.minimumValue = 0;
        _volumeSlider.maximumValue = 100;
        _volumeSlider.value = 50;
        _volumeSlider.tintColor = TSColor_Primary;
        [_volumeSlider addTarget:self action:@selector(onVolumeSliderTouchDown)
                forControlEvents:UIControlEventTouchDown];
        [_volumeSlider addTarget:self action:@selector(onVolumeSliderTouchUp)
                forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    }
    return _volumeSlider;
}

- (UIButton *)volumeMinusButton {
    if (!_volumeMinusButton) {
        _volumeMinusButton = [self pillButtonWithTitle:@"−"];
        [_volumeMinusButton addTarget:self action:@selector(onVolumeMinusTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _volumeMinusButton;
}

- (UIButton *)muteButton {
    if (!_muteButton) {
        _muteButton = [self pillButtonWithTitle:@"Mute"];
        [_muteButton addTarget:self action:@selector(onMuteTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteButton;
}

- (UIButton *)volumePlusButton {
    if (!_volumePlusButton) {
        _volumePlusButton = [self pillButtonWithTitle:@"+"];
        [_volumePlusButton addTarget:self action:@selector(onVolumePlusTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _volumePlusButton;
}

- (UIButton *)pillButtonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.layer.cornerRadius = 14.f;
    btn.layer.borderWidth = 1.f;
    btn.layer.borderColor = TSColor_Primary.CGColor;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:TSColor_Primary forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    return btn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = TSColor_Background;
        _tableView.separatorInset = UIEdgeInsetsMake(0, kPad, 0, kPad);
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = @"No music yet. Tap below to push.";
        _emptyLabel.font = TSFont_Caption;
        _emptyLabel.textColor = TSColor_TextSecondary;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] init];
        _bottomBar.backgroundColor = TSColor_Card;
    }
    return _bottomBar;
}

- (UIButton *)pushButton {
    if (!_pushButton) {
        _pushButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _pushButton.backgroundColor = TSColor_Primary;
        _pushButton.layer.cornerRadius = kCornerRadius;
        [_pushButton setTitle:@"+ Pick & push music" forState:UIControlStateNormal];
        [_pushButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _pushButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        [_pushButton addTarget:self action:@selector(onPushTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pushButton;
}

- (UIView *)progressPanel {
    if (!_progressPanel) {
        _progressPanel = [[UIView alloc] init];
        _progressPanel.hidden = YES;
    }
    return _progressPanel;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont systemFontOfSize:13];
        _progressLabel.textColor = TSColor_TextPrimary;
    }
    return _progressLabel;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = TSColor_Primary;
    }
    return _progressView;
}

- (UIButton *)cancelPushButton {
    if (!_cancelPushButton) {
        _cancelPushButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _cancelPushButton.layer.cornerRadius = 8.f;
        _cancelPushButton.layer.borderWidth = 1.f;
        _cancelPushButton.layer.borderColor = [UIColor systemRedColor].CGColor;
        [_cancelPushButton setTitle:@"Cancel push" forState:UIControlStateNormal];
        [_cancelPushButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
        _cancelPushButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [_cancelPushButton addTarget:self action:@selector(onCancelPushTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelPushButton;
}

@end
