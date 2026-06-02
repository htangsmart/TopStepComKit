//
//  TSAITTSPlaybackView.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/19.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAITTSPlaybackView.h"

#import <AVFoundation/AVFoundation.h>

#import "TSRootVC.h"

#pragma mark - 常量

/// 波形柱子数量
static const NSInteger kTSAITTSWaveformBarCount = 28;
/// 进度刷新间隔（秒）
static const NSTimeInterval kTSAITTSProgressTickInterval = 0.1;

#pragma mark - View

@interface TSAITTSPlaybackView () <AVAudioPlayerDelegate>

// 元信息（taskId / 耗时 / 字节 / 采样率 / 格式）
@property (nonatomic, strong) UIView    *metaContainer;
@property (nonatomic, strong) UILabel   *taskIdLabel;
@property (nonatomic, strong) UILabel   *durationLabel;
@property (nonatomic, strong) UILabel   *bytesLabel;
@property (nonatomic, strong) UILabel   *sampleRateLabel;
@property (nonatomic, strong) UILabel   *formatLabel;

// 波形
@property (nonatomic, strong) UIView                       *waveformView;
@property (nonatomic, strong) NSMutableArray<UIView *>     *waveformBars;
@property (nonatomic, strong, nullable) CADisplayLink      *waveformDisplayLink;

// 进度
@property (nonatomic, strong) UILabel *progressTimeLabel;
@property (nonatomic, strong) UILabel *progressTotalLabel;
@property (nonatomic, strong) UIView  *progressBar;
@property (nonatomic, strong) UIView  *progressBarFill;

// 操作按钮
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIButton *stopButton;

// 空态 / 错误条
@property (nonatomic, strong) UILabel *emptyHintLabel;
@property (nonatomic, strong) UIView  *errorBanner;
@property (nonatomic, strong) UILabel *errorTitleLabel;
@property (nonatomic, strong) UILabel *errorDetailLabel;

// 状态
@property (nonatomic, assign, readwrite) TSAITTSPlaybackMode mode;
@property (nonatomic, strong, nullable) TSAITTSResult *currentResult;
@property (nonatomic, assign) NSTimeInterval synthesizeDurationMs;

// 播放器
@property (nonatomic, strong, nullable) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong, nullable) NSURL         *audioPlayerFileURL;
@property (nonatomic, strong, nullable) NSTimer       *playProgressTimer;

@end

@implementation TSAITTSPlaybackView

#pragma mark - 生命周期

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubviews];
        [self buildWaveformBars];
        self.mode = TSAITTSPlaybackModeEmpty;
        [self refreshVisibility];
    }
    return self;
}

- (void)dealloc {
    [_waveformDisplayLink invalidate];
    [_playProgressTimer invalidate];
    [_audioPlayer stop];
    if (_audioPlayerFileURL) {
        [[NSFileManager defaultManager] removeItemAtURL:_audioPlayerFileURL error:nil];
    }
}

- (void)setupSubviews {
    [self addSubview:self.emptyHintLabel];
    [self addSubview:self.errorBanner];
    [self.errorBanner addSubview:self.errorTitleLabel];
    [self.errorBanner addSubview:self.errorDetailLabel];

    [self addSubview:self.metaContainer];
    [self.metaContainer addSubview:self.taskIdLabel];
    [self.metaContainer addSubview:self.durationLabel];
    [self.metaContainer addSubview:self.bytesLabel];
    [self.metaContainer addSubview:self.sampleRateLabel];
    [self.metaContainer addSubview:self.formatLabel];

    [self addSubview:self.waveformView];

    [self addSubview:self.progressTimeLabel];
    [self addSubview:self.progressTotalLabel];
    [self addSubview:self.progressBar];
    [self.progressBar addSubview:self.progressBarFill];

    [self addSubview:self.playPauseButton];
    [self addSubview:self.stopButton];
}

#pragma mark - 公开方法

- (void)showEmptyWithHint:(NSString *)hint {
    [self stopPlayback];
    self.currentResult = nil;
    self.emptyHintLabel.text = hint ?: @"";
    self.mode = TSAITTSPlaybackModeEmpty;
    [self refreshVisibility];
}

- (void)showReadyWithResult:(TSAITTSResult *)result synthesizeDurationMs:(NSTimeInterval)synthesizeDurationMs {
    [self stopPlayback];
    self.currentResult = result;
    self.synthesizeDurationMs = synthesizeDurationMs;
    [self refreshMetaLabels];
    self.mode = TSAITTSPlaybackModeReady;
    [self refreshVisibility];
    [self refreshProgressBarFill];
}

- (void)showErrorWithTitle:(NSString *)title detail:(NSString *)detail accentColor:(UIColor *)accentColor {
    [self stopPlayback];
    self.errorTitleLabel.text = title ?: @"";
    self.errorDetailLabel.text = detail ?: @"";
    UIColor *finalColor = accentColor ?: TSColor_Danger;
    self.errorTitleLabel.textColor = finalColor;
    self.errorDetailLabel.textColor = finalColor;
    self.errorBanner.backgroundColor = [finalColor colorWithAlphaComponent:0.12f];
    self.mode = TSAITTSPlaybackModeError;
    [self refreshVisibility];
}

- (BOOL)startPlayback {
    [self tearDownAudioPlayer];

    TSAITTSResult *r = self.currentResult;
    if (r.audioData.length == 0) return NO;

    NSData *playableData = nil;
    NSString *extension = nil;
    if (r.audioFormat == TSAIAudioFormatPcm) {
        NSInteger sampleRate = (r.sampleRate > 0) ? r.sampleRate : 16000;
        playableData = [self wrapPCMAsWav:r.audioData sampleRate:sampleRate channels:1 bitsPerSample:16];
        extension = @"wav";
    } else if (r.audioFormat == TSAIAudioFormatWav) {
        playableData = r.audioData;
        extension = @"wav";
    } else if (r.audioFormat == TSAIAudioFormatMp3) {
        playableData = r.audioData;
        extension = @"mp3";
    } else {
        // Opus / Unknown / None：AVAudioPlayer 无法直接解码
        return NO;
    }

    NSString *filename = [NSString stringWithFormat:@"tts_%@.%@", [[NSUUID UUID] UUIDString], extension];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filename]];
    if (![playableData writeToURL:fileURL options:NSDataWritingAtomic error:nil]) return NO;

    NSError *playerError = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&playerError];
    if (!player) {
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
        return NO;
    }
    player.delegate = self;
    [player prepareToPlay];
    [player play];

    self.audioPlayer = player;
    self.audioPlayerFileURL = fileURL;
    self.playProgressTimer = [NSTimer scheduledTimerWithTimeInterval:kTSAITTSProgressTickInterval
                                                              target:self
                                                            selector:@selector(onPlayProgressTick:)
                                                            userInfo:nil
                                                             repeats:YES];

    self.mode = TSAITTSPlaybackModePlaying;
    [self refreshVisibility];
    [self startWaveformAnimation];
    [self refreshProgressBarFill];
    return YES;
}

- (void)pausePlayback {
    if (!self.audioPlayer.isPlaying) return;
    [self.audioPlayer pause];
    [self.playProgressTimer invalidate];
    self.playProgressTimer = nil;
    [self stopWaveformAnimation];
    self.mode = TSAITTSPlaybackModePaused;
    [self refreshVisibility];
}

- (void)resumePlayback {
    if (self.audioPlayer.isPlaying) return;
    [self.audioPlayer play];
    self.playProgressTimer = [NSTimer scheduledTimerWithTimeInterval:kTSAITTSProgressTickInterval
                                                              target:self
                                                            selector:@selector(onPlayProgressTick:)
                                                            userInfo:nil
                                                             repeats:YES];
    [self startWaveformAnimation];
    self.mode = TSAITTSPlaybackModePlaying;
    [self refreshVisibility];
}

- (void)stopPlayback {
    [self tearDownAudioPlayer];
    [self stopWaveformAnimation];
    if (self.currentResult) {
        self.mode = TSAITTSPlaybackModeReady;
    }
    [self refreshVisibility];
    [self refreshProgressBarFill];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    if (width <= 0 || height <= 0) return;

    // 空态 / 错误条 铺满整个区域
    self.emptyHintLabel.frame = self.bounds;
    self.errorBanner.frame = self.bounds;
    {
        CGFloat pad = 10.f;
        self.errorTitleLabel.frame = CGRectMake(pad, pad, width - pad * 2, 18.f);
        self.errorDetailLabel.frame = CGRectMake(pad,
                                                  CGRectGetMaxY(self.errorTitleLabel.frame) + 2.f,
                                                  width - pad * 2,
                                                  height - 18.f - pad * 2 - 2.f);
    }

    // Ready / Playing / Paused 模式：meta + 波形 + 进度 + 按钮
    CGFloat metaH = 20.f;
    self.metaContainer.frame = CGRectMake(0, 0, width, metaH);
    [self layoutMetaLabels];

    CGFloat waveformY = CGRectGetMaxY(self.metaContainer.frame) + TSSpacing_XS;
    CGFloat waveformH = 48.f;
    self.waveformView.frame = CGRectMake(0, waveformY, width, waveformH);
    [self layoutWaveformBars];

    CGFloat progressY = CGRectGetMaxY(self.waveformView.frame) + TSSpacing_XS;
    CGFloat progressRowH = 16.f;
    CGFloat timeW = 40.f;
    self.progressTimeLabel.frame = CGRectMake(0, progressY, timeW, progressRowH);
    self.progressTotalLabel.frame = CGRectMake(width - timeW, progressY, timeW, progressRowH);
    CGFloat progressBarH = 4.f;
    self.progressBar.frame = CGRectMake(timeW + 6.f,
                                         progressY + (progressRowH - progressBarH) / 2.f,
                                         width - timeW * 2 - 12.f,
                                         progressBarH);
    self.progressBar.layer.cornerRadius = progressBarH / 2.f;
    [self refreshProgressBarFill];

    CGFloat btnY = CGRectGetMaxY(self.progressBar.frame) + TSSpacing_SM;
    CGFloat btnH = 32.f;
    BOOL stopVisible = (self.mode == TSAITTSPlaybackModePlaying || self.mode == TSAITTSPlaybackModePaused);
    if (stopVisible) {
        CGFloat playW = (width - TSSpacing_SM) * 0.62f;
        CGFloat stopW = width - TSSpacing_SM - playW;
        self.playPauseButton.frame = CGRectMake(0, btnY, playW, btnH);
        self.stopButton.frame = CGRectMake(playW + TSSpacing_SM, btnY, stopW, btnH);
    } else {
        self.playPauseButton.frame = CGRectMake(0, btnY, width, btnH);
    }
}

/// 元信息 5 个 label 等宽分布
- (void)layoutMetaLabels {
    CGFloat width = CGRectGetWidth(self.metaContainer.bounds);
    CGFloat height = CGRectGetHeight(self.metaContainer.bounds);
    NSArray<UILabel *> *labels = @[self.taskIdLabel, self.durationLabel, self.bytesLabel,
                                    self.sampleRateLabel, self.formatLabel];
    CGFloat itemW = width / labels.count;
    [labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        label.frame = CGRectMake(idx * itemW, 0, itemW, height);
    }];
}

/// 创建 28 根波形柱子
- (void)buildWaveformBars {
    if (self.waveformBars.count > 0) return;
    self.waveformBars = [NSMutableArray arrayWithCapacity:kTSAITTSWaveformBarCount];
    for (NSInteger i = 0; i < kTSAITTSWaveformBarCount; i++) {
        UIView *bar = [[UIView alloc] init];
        bar.backgroundColor = TSColor_Primary;
        bar.alpha = 0.35f;
        bar.layer.cornerRadius = 1.5f;
        [self.waveformView addSubview:bar];
        [self.waveformBars addObject:bar];
    }
}

/// 波形柱子按 sin + 偏移生成静态高度
- (void)layoutWaveformBars {
    CGFloat width = CGRectGetWidth(self.waveformView.bounds);
    CGFloat height = CGRectGetHeight(self.waveformView.bounds);
    if (width <= 0 || height <= 0 || self.waveformBars.count == 0) return;
    NSInteger barCount = self.waveformBars.count;
    CGFloat gap = 2.f;
    CGFloat barW = (width - gap * (barCount - 1)) / barCount;
    for (NSInteger i = 0; i < barCount; i++) {
        UIView *bar = self.waveformBars[i];
        CGFloat ratio = 0.5f + 0.4f * sin((double)i / barCount * M_PI * 2);
        CGFloat extra = ((i * 7) % 10) / 30.f;
        CGFloat h = MAX(4.f, height * (ratio + extra) * 0.9f);
        bar.frame = CGRectMake(i * (barW + gap), (height - h) / 2.f, barW, h);
    }
}

#pragma mark - 私有方法 - 显隐 / 文案

/// 按当前 mode 切换子视图显隐
- (void)refreshVisibility {
    BOOL showEmpty = (self.mode == TSAITTSPlaybackModeEmpty);
    BOOL showError = (self.mode == TSAITTSPlaybackModeError);
    BOOL showResult = (self.mode == TSAITTSPlaybackModeReady
                       || self.mode == TSAITTSPlaybackModePlaying
                       || self.mode == TSAITTSPlaybackModePaused);

    self.emptyHintLabel.hidden = !showEmpty;
    self.errorBanner.hidden = !showError;
    self.metaContainer.hidden = !showResult;
    self.waveformView.hidden = !showResult;
    self.progressBar.hidden = !showResult;
    self.progressTimeLabel.hidden = !showResult;
    self.progressTotalLabel.hidden = !showResult;
    self.playPauseButton.hidden = !showResult;

    BOOL stopVisible = (self.mode == TSAITTSPlaybackModePlaying || self.mode == TSAITTSPlaybackModePaused);
    self.stopButton.hidden = !stopVisible;

    NSString *playTitle = nil;
    if (self.mode == TSAITTSPlaybackModePlaying) {
        playTitle = TSLocalizedString(@"ai_tts.pause");
    } else if (self.mode == TSAITTSPlaybackModePaused) {
        playTitle = TSLocalizedString(@"ai_tts.resume");
    } else {
        playTitle = TSLocalizedString(@"ai_tts.play");
    }
    [self.playPauseButton setTitle:playTitle forState:UIControlStateNormal];

    [self setNeedsLayout];
}

/// 把当前 result 写入元信息标签
- (void)refreshMetaLabels {
    TSAITTSResult *r = self.currentResult;
    if (!r) return;
    NSString *taskShort = (r.taskId.length > 8) ? [r.taskId substringToIndex:8] : (r.taskId ?: @"");
    self.taskIdLabel.text = [taskShort stringByAppendingString:@"…"];
    self.durationLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_tts.duration_fmt"), self.synthesizeDurationMs];
    CGFloat kb = (CGFloat)r.audioData.length / 1024.f;
    self.bytesLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_tts.bytes_fmt"), kb];
    self.sampleRateLabel.text = [NSString stringWithFormat:TSLocalizedString(@"ai_tts.samplerate_fmt"), (long)r.sampleRate];
    self.formatLabel.text = [self displayNameForFormat:r.audioFormat];
}

- (NSString *)displayNameForFormat:(TSAIAudioFormat)format {
    switch (format) {
        case TSAIAudioFormatPcm:  return @"PCM";
        case TSAIAudioFormatOpus: return @"Opus";
        case TSAIAudioFormatMp3:  return @"MP3";
        case TSAIAudioFormatWav:  return @"WAV";
        case TSAIAudioFormatNone: return @"--";
        case TSAIAudioFormatUnknown:
        default:                  return @"?";
    }
}

#pragma mark - 私有方法 - 进度 / 波形动画

/// 刷新进度条填充 + 时间标签
- (void)refreshProgressBarFill {
    CGFloat total = self.audioPlayer ? (CGFloat)self.audioPlayer.duration : 0.f;
    CGFloat current = self.audioPlayer ? (CGFloat)self.audioPlayer.currentTime : 0.f;
    CGFloat progress = (total > 0.001f) ? (current / total) : 0.f;
    progress = MAX(0.f, MIN(1.f, progress));
    CGFloat fillW = CGRectGetWidth(self.progressBar.bounds) * progress;
    self.progressBarFill.frame = CGRectMake(0, 0, fillW, CGRectGetHeight(self.progressBar.bounds));
    self.progressTimeLabel.text = [self formatSeconds:current];
    self.progressTotalLabel.text = [self formatSeconds:total];
}

- (NSString *)formatSeconds:(NSTimeInterval)sec {
    NSInteger total = (NSInteger)sec;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(total / 60), (long)(total % 60)];
}

/// 启动波形动画（CADisplayLink，30fps）
- (void)startWaveformAnimation {
    [self stopWaveformAnimation];
    self.waveformDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onWaveformTick:)];
    self.waveformDisplayLink.preferredFramesPerSecond = 30;
    [self.waveformDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

/// 停止波形动画并复位透明度
- (void)stopWaveformAnimation {
    [self.waveformDisplayLink invalidate];
    self.waveformDisplayLink = nil;
    for (UIView *bar in self.waveformBars) {
        bar.alpha = 0.35f;
    }
}

- (void)onWaveformTick:(CADisplayLink *)link {
    NSTimeInterval t = link.timestamp;
    for (NSInteger i = 0; i < self.waveformBars.count; i++) {
        UIView *bar = self.waveformBars[i];
        CGFloat phase = t * 4.f + i * 0.25f;
        CGFloat alpha = 0.35f + 0.65f * (0.5f + 0.5f * sin(phase));
        bar.alpha = alpha;
    }
}

#pragma mark - 私有方法 - 播放器底层

/// 释放 AVAudioPlayer 与临时文件
- (void)tearDownAudioPlayer {
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    [self.playProgressTimer invalidate];
    self.playProgressTimer = nil;
    if (self.audioPlayerFileURL) {
        [[NSFileManager defaultManager] removeItemAtURL:self.audioPlayerFileURL error:nil];
        self.audioPlayerFileURL = nil;
    }
}

- (void)onPlayProgressTick:(NSTimer *)timer {
    [self refreshProgressBarFill];
}

/// 把裸 PCM 包成 WAV：写 44 字节 RIFF/WAVE 头
- (NSData *)wrapPCMAsWav:(NSData *)pcm sampleRate:(NSInteger)sampleRate channels:(NSInteger)channels bitsPerSample:(NSInteger)bitsPerSample {
    NSMutableData *wav = [NSMutableData dataWithCapacity:pcm.length + 44];
    uint32_t dataSize = (uint32_t)pcm.length;
    uint32_t byteRate = (uint32_t)(sampleRate * channels * bitsPerSample / 8);
    uint16_t blockAlign = (uint16_t)(channels * bitsPerSample / 8);
    uint32_t chunkSize = 36 + dataSize;
    uint16_t audioFormat = 1; // PCM
    uint16_t numChannels = (uint16_t)channels;
    uint32_t sampleRateLE = (uint32_t)sampleRate;
    uint16_t bitsPerSampleLE = (uint16_t)bitsPerSample;

    [wav appendBytes:"RIFF" length:4];
    [wav appendBytes:&chunkSize length:4];
    [wav appendBytes:"WAVE" length:4];
    [wav appendBytes:"fmt " length:4];
    uint32_t subchunk1Size = 16;
    [wav appendBytes:&subchunk1Size length:4];
    [wav appendBytes:&audioFormat length:2];
    [wav appendBytes:&numChannels length:2];
    [wav appendBytes:&sampleRateLE length:4];
    [wav appendBytes:&byteRate length:4];
    [wav appendBytes:&blockAlign length:2];
    [wav appendBytes:&bitsPerSampleLE length:2];
    [wav appendBytes:"data" length:4];
    [wav appendBytes:&dataSize length:4];
    [wav appendData:pcm];
    return wav;
}

#pragma mark - 事件

/// 播放 / 暂停 / 继续 切换
- (void)onPlayPauseTapped {
    switch (self.mode) {
        case TSAITTSPlaybackModeReady:
            [self.delegate playbackViewDidRequestPlay:self];
            break;
        case TSAITTSPlaybackModePlaying:
            [self.delegate playbackViewDidRequestPause:self];
            break;
        case TSAITTSPlaybackModePaused:
            [self.delegate playbackViewDidRequestResume:self];
            break;
        default:
            break;
    }
}

- (void)onStopTapped {
    [self.delegate playbackViewDidRequestStop:self];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.playProgressTimer invalidate];
    self.playProgressTimer = nil;
    [self stopWaveformAnimation];
    if (self.currentResult) {
        self.mode = TSAITTSPlaybackModeReady;
    }
    [self refreshVisibility];
    [self refreshProgressBarFill];
    [self.delegate playbackViewDidFinishPlayback:self successfully:flag];
}

#pragma mark - 属性（懒加载）

- (UIView *)metaContainer {
    if (!_metaContainer) {
        _metaContainer = [[UIView alloc] init];
    }
    return _metaContainer;
}

- (UILabel *)taskIdLabel       { return [self lazyMetaLabel:&_taskIdLabel]; }
- (UILabel *)durationLabel     { return [self lazyMetaLabel:&_durationLabel]; }
- (UILabel *)bytesLabel        { return [self lazyMetaLabel:&_bytesLabel]; }
- (UILabel *)sampleRateLabel   { return [self lazyMetaLabel:&_sampleRateLabel]; }
- (UILabel *)formatLabel       { return [self lazyMetaLabel:&_formatLabel]; }

/// 元信息 label 统一样式
- (UILabel *)lazyMetaLabel:(UILabel * __strong *)backing {
    if (*backing) return *backing;
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:11.f];
    label.textColor = TSColor_TextSecondary;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.7f;
    *backing = label;
    return label;
}

- (UIView *)waveformView {
    if (!_waveformView) {
        _waveformView = [[UIView alloc] init];
    }
    return _waveformView;
}

- (UILabel *)progressTimeLabel {
    if (!_progressTimeLabel) {
        _progressTimeLabel = [[UILabel alloc] init];
        _progressTimeLabel.font = [UIFont monospacedDigitSystemFontOfSize:11.f weight:UIFontWeightRegular];
        _progressTimeLabel.textColor = TSColor_TextSecondary;
        _progressTimeLabel.text = @"00:00";
    }
    return _progressTimeLabel;
}

- (UILabel *)progressTotalLabel {
    if (!_progressTotalLabel) {
        _progressTotalLabel = [[UILabel alloc] init];
        _progressTotalLabel.font = [UIFont monospacedDigitSystemFontOfSize:11.f weight:UIFontWeightRegular];
        _progressTotalLabel.textColor = TSColor_TextSecondary;
        _progressTotalLabel.textAlignment = NSTextAlignmentRight;
        _progressTotalLabel.text = @"00:00";
    }
    return _progressTotalLabel;
}

- (UIView *)progressBar {
    if (!_progressBar) {
        _progressBar = [[UIView alloc] init];
        _progressBar.backgroundColor = TSColor_Separator;
        _progressBar.layer.masksToBounds = YES;
    }
    return _progressBar;
}

- (UIView *)progressBarFill {
    if (!_progressBarFill) {
        _progressBarFill = [[UIView alloc] init];
        _progressBarFill.backgroundColor = TSColor_Primary;
    }
    return _progressBarFill;
}

- (UIButton *)playPauseButton {
    if (!_playPauseButton) {
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playPauseButton setTitle:TSLocalizedString(@"ai_tts.play") forState:UIControlStateNormal];
        [_playPauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _playPauseButton.titleLabel.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightSemibold];
        _playPauseButton.backgroundColor = TSColor_Primary;
        _playPauseButton.layer.cornerRadius = TSRadius_SM;
        [_playPauseButton addTarget:self action:@selector(onPlayPauseTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playPauseButton;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopButton setTitle:TSLocalizedString(@"ai_tts.stop") forState:UIControlStateNormal];
        [_stopButton setTitleColor:TSColor_Danger forState:UIControlStateNormal];
        _stopButton.titleLabel.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightSemibold];
        _stopButton.backgroundColor = [TSColor_Danger colorWithAlphaComponent:0.10f];
        _stopButton.layer.cornerRadius = TSRadius_SM;
        [_stopButton addTarget:self action:@selector(onStopTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopButton;
}

- (UILabel *)emptyHintLabel {
    if (!_emptyHintLabel) {
        _emptyHintLabel = [[UILabel alloc] init];
        _emptyHintLabel.font = TSFont_Caption;
        _emptyHintLabel.textColor = TSColor_TextSecondary;
        _emptyHintLabel.textAlignment = NSTextAlignmentCenter;
        _emptyHintLabel.numberOfLines = 0;
    }
    return _emptyHintLabel;
}

- (UIView *)errorBanner {
    if (!_errorBanner) {
        _errorBanner = [[UIView alloc] init];
        _errorBanner.layer.cornerRadius = TSRadius_SM;
    }
    return _errorBanner;
}

- (UILabel *)errorTitleLabel {
    if (!_errorTitleLabel) {
        _errorTitleLabel = [[UILabel alloc] init];
        _errorTitleLabel.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightSemibold];
    }
    return _errorTitleLabel;
}

- (UILabel *)errorDetailLabel {
    if (!_errorDetailLabel) {
        _errorDetailLabel = [[UILabel alloc] init];
        _errorDetailLabel.font = [UIFont systemFontOfSize:11.f];
        _errorDetailLabel.numberOfLines = 0;
    }
    return _errorDetailLabel;
}

@end
