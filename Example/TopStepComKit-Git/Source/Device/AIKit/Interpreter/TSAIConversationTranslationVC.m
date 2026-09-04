//
//  TSAIConversationTranslationVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/4.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIConversationTranslationVC.h"

#import <AVFoundation/AVFoundation.h>
#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAIInterpreterFormatter.h"
#import "TSAIInterpreterLanguageSheetVC.h"

typedef NS_ENUM(NSInteger, TSConversationSide) {
    TSConversationSideNone = 0,
    TSConversationSideLeft,
    TSConversationSideRight,
};

typedef NS_ENUM(NSInteger, TSConversationDevicePair) {
    TSConversationDevicePairPhoneAndCase = 0,
    TSConversationDevicePairPhoneAndEarbuds,
    TSConversationDevicePairEarbudsAndCase,
};

static NSTimeInterval const TSConversationStartDebounceInterval = 0.8;
static NSTimeInterval const TSConversationRestartCooldownInterval = 1.0;
static NSTimeInterval const TSConversationSilenceTimeout = 6.0;

static UIColor *TSConversationPrimaryTextColor(void) {
    return [UIColor colorWithWhite:0.10 alpha:1.0];
}

static UIColor *TSConversationSecondaryTextColor(void) {
    return [UIColor colorWithWhite:0.42 alpha:1.0];
}

@interface TSConversationTurn : NSObject

/// 对话轮次序号
@property (nonatomic, assign) NSInteger index;
/// 是否由左侧参与者发言
@property (nonatomic, assign) BOOL leftSpeaker;
/// 本轮源语言
@property (nonatomic, assign) TSAILanguage sourceLanguage;
/// 本轮目标语言
@property (nonatomic, assign) TSAILanguage targetLanguage;
/// 合并后的原文
@property (nonatomic, copy, nullable) NSString *originalText;
/// 合并后的译文
@property (nonatomic, copy, nullable) NSString *translatedText;
/// 译文音频归档
@property (nonatomic, strong) NSMutableData *audioData;
/// 译文音频格式
@property (nonatomic, assign) TSAIAudioFormat audioFormat;

@end

@implementation TSConversationTurn

- (instancetype)init {
    self = [super init];
    if (self) {
        _audioData = [NSMutableData data];
        _audioFormat = TSAIAudioFormatUnknown;
    }
    return self;
}

@end

@interface TSConversationBubbleCell : UITableViewCell

/// 历史音频播放回调
@property (nonatomic, copy, nullable) void (^playHandler)(void);

- (void)bindTurn:(TSConversationTurn *)turn
       faceToFace:(BOOL)faceToFace
      viewerOnLeft:(BOOL)viewerOnLeft;
+ (CGFloat)heightForTurn:(TSConversationTurn *)turn
              faceToFace:(BOOL)faceToFace
             viewerOnLeft:(BOOL)viewerOnLeft
                   width:(CGFloat)width;
+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width;

@end

@interface TSConversationBubbleCell ()

/// 气泡容器
@property (nonatomic, strong) UIView *bubbleView;
/// 原文或面对面模式单文本标签
@property (nonatomic, strong) UILabel *originalLabel;
/// 原文与译文分隔线
@property (nonatomic, strong) UIView *separatorView;
/// 译文标签
@property (nonatomic, strong) UILabel *translatedLabel;
/// 历史音频播放按钮
@property (nonatomic, strong) UIButton *playButton;
/// 是否为面对面展示
@property (nonatomic, assign) BOOL faceToFace;
/// 当前气泡是否靠右
@property (nonatomic, assign) BOOL alignsRight;

@end

@implementation TSConversationBubbleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.bubbleView];
        [self.bubbleView addSubview:self.originalLabel];
        [self.bubbleView addSubview:self.separatorView];
        [self.bubbleView addSubview:self.translatedLabel];
        [self.contentView addSubview:self.playButton];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.playHandler = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat contentWidth = CGRectGetWidth(self.contentView.bounds);
    CGFloat bubbleWidth = floor(contentWidth * (self.faceToFace ? 0.84 : 0.76));
    CGFloat bubbleX = self.alignsRight ? contentWidth - bubbleWidth - 18.0 : 18.0;
    CGFloat textWidth = bubbleWidth - 28.0;
    CGFloat verticalPosition = 14.0;
    CGSize originalSize = [self.originalLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)];
    self.originalLabel.frame = CGRectMake(14.0, verticalPosition,
                                           textWidth, ceil(originalSize.height));
    verticalPosition = CGRectGetMaxY(self.originalLabel.frame) + 14.0;
    if (!self.faceToFace) {
        self.separatorView.frame = CGRectMake(14.0, verticalPosition - 3.0, textWidth, 0.5);
        verticalPosition += 8.5;
        CGSize translatedSize = [self.translatedLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)];
        self.translatedLabel.frame = CGRectMake(14.0, verticalPosition,
                                                 textWidth, ceil(translatedSize.height));
        verticalPosition = CGRectGetMaxY(self.translatedLabel.frame) + 14.0;
    }
    self.bubbleView.frame = CGRectMake(bubbleX, 5.0, bubbleWidth, verticalPosition);
    CGFloat playX = self.alignsRight ? bubbleX - 38.0 : CGRectGetMaxX(self.bubbleView.frame) + 8.0;
    self.playButton.frame = CGRectMake(playX, CGRectGetMaxY(self.bubbleView.frame) - 32.0,
                                       28.0, 28.0);
}

- (void)bindTurn:(TSConversationTurn *)turn
       faceToFace:(BOOL)faceToFace
      viewerOnLeft:(BOOL)viewerOnLeft {
    self.faceToFace = faceToFace;
    self.alignsRight = faceToFace ? turn.leftSpeaker == viewerOnLeft : !turn.leftSpeaker;
    NSString *original = turn.originalText.length > 0 ? turn.originalText : @"…";
    NSString *translated = turn.translatedText.length > 0 ? turn.translatedText : @"…";
    if (faceToFace) {
        BOOL showsOriginal = turn.leftSpeaker == viewerOnLeft;
        self.originalLabel.text = showsOriginal ? original : translated;
        self.originalLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium];
        self.translatedLabel.hidden = YES;
        self.separatorView.hidden = YES;
        self.playButton.hidden = showsOriginal || turn.audioData.length == 0;
    } else {
        self.originalLabel.text = original;
        self.originalLabel.font = [UIFont systemFontOfSize:15.0];
        self.translatedLabel.text = translated;
        self.translatedLabel.hidden = NO;
        self.separatorView.hidden = NO;
        self.playButton.hidden = turn.audioData.length == 0;
    }
    self.bubbleView.backgroundColor = turn.leftSpeaker
        ? [UIColor colorWithRed:0.89 green:0.97 blue:0.95 alpha:1.0]
        : UIColor.whiteColor;
    [self setNeedsLayout];
}

+ (CGFloat)heightForTurn:(TSConversationTurn *)turn
              faceToFace:(BOOL)faceToFace
             viewerOnLeft:(BOOL)viewerOnLeft
                   width:(CGFloat)width {
    CGFloat textWidth = floor(width * (faceToFace ? 0.84 : 0.76)) - 28.0;
    NSString *original = turn.originalText.length > 0 ? turn.originalText : @" ";
    NSString *translated = turn.translatedText.length > 0 ? turn.translatedText : @" ";
    if (faceToFace) {
        NSString *text = turn.leftSpeaker == viewerOnLeft ? original : translated;
        CGFloat textHeight = [self heightForText:text
                                           font:[UIFont systemFontOfSize:17.0 weight:UIFontWeightMedium]
                                          width:textWidth];
        return MAX(58.0, textHeight + 38.0);
    }
    CGFloat originalHeight = [self heightForText:original
                                           font:[UIFont systemFontOfSize:15.0]
                                          width:textWidth];
    CGFloat translatedHeight = [self heightForText:translated
                                             font:[UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium]
                                            width:textWidth];
    return MAX(88.0, originalHeight + translatedHeight + 55.0);
}

+ (CGFloat)heightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
    return ceil(rect.size.height);
}

- (void)onPlayButtonTap {
    if (self.playHandler) self.playHandler();
}

- (UIView *)bubbleView {
    if (!_bubbleView) {
        _bubbleView = [[UIView alloc] init];
        _bubbleView.layer.cornerRadius = 18.0;
        _bubbleView.layer.masksToBounds = YES;
    }
    return _bubbleView;
}

- (UILabel *)originalLabel {
    if (!_originalLabel) {
        _originalLabel = [[UILabel alloc] init];
        _originalLabel.numberOfLines = 0;
        _originalLabel.textColor = TSConversationSecondaryTextColor();
    }
    return _originalLabel;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.08];
    }
    return _separatorView;
}

- (UILabel *)translatedLabel {
    if (!_translatedLabel) {
        _translatedLabel = [[UILabel alloc] init];
        _translatedLabel.numberOfLines = 0;
        _translatedLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium];
        _translatedLabel.textColor = TSConversationPrimaryTextColor();
    }
    return _translatedLabel;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _playButton.tintColor = [UIColor colorWithRed:0.13 green:0.66 blue:0.58 alpha:1.0];
        if (@available(iOS 13.0, *)) {
            [_playButton setImage:[UIImage systemImageNamed:@"speaker.wave.2.fill"]
                         forState:UIControlStateNormal];
        }
        [_playButton addTarget:self action:@selector(onPlayButtonTap)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

@end

@interface TSAIConversationTranslationVC ()
    <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>

/// 页面标题
@property (nonatomic, strong) UILabel *pageTitleLabel;
/// 展示模式切换按钮
@property (nonatomic, strong) UIButton *modeButton;
/// 使用说明按钮
@property (nonatomic, strong) UIButton *helpButton;
/// 普通模式容器
@property (nonatomic, strong) UIView *normalContainerView;
/// 普通模式消息列表
@property (nonatomic, strong) UITableView *normalTableView;
/// 空会话提示文案
@property (nonatomic, strong) UILabel *emptyLabel;
/// 普通模式底部操作区
@property (nonatomic, strong) UIView *normalControlView;
/// 左侧语言按钮
@property (nonatomic, strong) UIButton *leftLanguageButton;
/// 右侧语言按钮
@property (nonatomic, strong) UIButton *rightLanguageButton;
/// 语言互换按钮
@property (nonatomic, strong) UIButton *swapButton;
/// 左侧收音按钮
@property (nonatomic, strong) UIButton *leftTalkButton;
/// 右侧收音按钮
@property (nonatomic, strong) UIButton *rightTalkButton;
/// 面对面模式容器
@property (nonatomic, strong) UIView *faceContainerView;
/// 面对面上半屏消息列表
@property (nonatomic, strong) UITableView *faceTopTableView;
/// 面对面下半屏消息列表
@property (nonatomic, strong) UITableView *faceBottomTableView;
/// 面对面中部分隔条
@property (nonatomic, strong) UIView *faceDividerView;
/// 面对面双方位置互换按钮
@property (nonatomic, strong) UIButton *faceSwapButton;
/// 面对面上半屏收音按钮
@property (nonatomic, strong) UIButton *faceTopTalkButton;
/// 面对面下半屏收音按钮
@property (nonatomic, strong) UIButton *faceBottomTalkButton;
/// 设备选择遮罩
@property (nonatomic, strong) UIView *devicePickerOverlay;
/// 设备选择底部面板
@property (nonatomic, strong) UIView *devicePickerSheet;
/// 设备选择标题
@property (nonatomic, strong) UILabel *devicePickerTitleLabel;
/// 设备组合按钮
@property (nonatomic, copy) NSArray<UIButton *> *devicePairButtons;
/// 设备选择确认按钮
@property (nonatomic, strong) UIButton *deviceConfirmButton;
/// 全部对话轮次
@property (nonatomic, strong) NSMutableArray<TSConversationTurn *> *turns;
/// 当前录音对应的对话轮次
@property (nonatomic, strong, nullable) TSConversationTurn *activeTurn;
/// 当前任务各分段原文
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *originalSegments;
/// 当前任务各分段译文
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *translatedSegments;
/// 左侧参与者语言
@property (nonatomic, assign) TSAILanguage leftLanguage;
/// 右侧参与者语言
@property (nonatomic, assign) TSAILanguage rightLanguage;
/// 当前发言侧
@property (nonatomic, assign) TSConversationSide activeSide;
/// 当前任务实际输入通道
@property (nonatomic, assign) TSAIAudioInputChannel activeInputChannel;
/// 当前底层任务标识
@property (nonatomic, copy, nullable) NSString *currentTaskId;
/// 当前设备协同会话请求
@property (nonatomic, strong, nullable) TSAIStartRequest *deviceSessionRequest;
/// 设备协同会话是否正在启动
@property (nonatomic, assign) BOOL deviceSessionStarting;
/// 设备协同会话是否已激活
@property (nonatomic, assign) BOOL deviceSessionActive;
/// 设备协同会话是否正在停止
@property (nonatomic, assign) BOOL deviceSessionStopping;
/// 是否已在设备激活前收到停止请求
@property (nonatomic, assign) BOOL deviceSessionStopRequested;
/// 设备对话翻译产品模式是否正在启动
@property (nonatomic, assign) BOOL deviceConversationModeStarting;
/// 设备对话翻译产品模式是否已激活
@property (nonatomic, assign) BOOL deviceConversationModeActive;
/// 是否已在产品模式启动完成前收到退出请求
@property (nonatomic, assign) BOOL deviceConversationModeStopRequested;
/// 设备对话翻译产品模式请求代次
@property (nonatomic, assign) NSUInteger deviceConversationModeGeneration;
/// 当前任务代次
@property (nonatomic, assign) NSUInteger sessionGeneration;
/// 是否正在等待停止完成
@property (nonatomic, assign) BOOL stopping;
/// 是否为面对面模式
@property (nonatomic, assign) BOOL faceToFace;
/// 面对面双方位置是否已互换
@property (nonatomic, assign) BOOL faceSidesSwapped;
/// 是否已展示设备选择
@property (nonatomic, assign) BOOL didPresentDevicePicker;
/// 当前设备组合
@property (nonatomic, assign) TSConversationDevicePair selectedDevicePair;
/// 最近一次开始时间
@property (nonatomic, strong, nullable) NSDate *lastStartDate;
/// 最近一次完成时间
@property (nonatomic, strong, nullable) NSDate *lastCompletionDate;
/// 静音自动停止计时器
@property (nonatomic, strong, nullable) NSTimer *silenceTimer;
/// 历史音频播放器
@property (nonatomic, strong, nullable) AVAudioPlayer *audioPlayer;
/// 等待当前任务完成后播放的轮次
@property (nonatomic, strong, nullable) TSConversationTurn *pendingPlaybackTurn;
/// 页面是否正在退出
@property (nonatomic, assign) BOOL leavingPage;

@end

@implementation TSAIConversationTranslationVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = @"";
    self.leftLanguage = TSAILanguageEnglishUS;
    self.rightLanguage = TSAILanguageChineseSimplified;
    self.activeInputChannel = TSAIAudioInputChannelUnknown;
    self.selectedDevicePair = TSConversationDevicePairPhoneAndEarbuds;
    self.turns = [NSMutableArray array];
    self.originalSegments = [NSMutableDictionary dictionary];
    self.translatedSegments = [NSMutableDictionary dictionary];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.98 blue:0.97 alpha:1.0];
    [self setupViews];
    [self refreshInterface];
    [self registerAudioRouteObservation];
    [self registerDeviceSessionHandlers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.leavingPage = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.didPresentDevicePicker) {
        self.didPresentDevicePicker = YES;
        [self showDevicePicker];
    } else if (!self.deviceConversationModeActive &&
               !self.deviceConversationModeStarting) {
        [self startDeviceConversationTranslationMode];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.leavingPage = YES;
    [self requestStopSession];
    [self stopDeviceConversationTranslationMode];
}

- (void)dealloc {
    [_silenceTimer invalidate];
    [_audioPlayer stop];
    TSAIContext *context = [TSAIKit sharedInstance].activeContext;
    [context.audioRouting registerAudioRouteCapabilitiesDidChange:nil];
    [context registerDeviceAISessionHandlerForUseCase:TSAIUseCaseVoiceTranslation
                                       prepareHandler:nil
                                    activationHandler:nil
                               inputCompletionHandler:nil
                                   terminationHandler:nil
                                     voiceDataHandler:nil];
    if (_currentTaskId.length > 0 && !_stopping) {
        [context.interpreter stopInterpretationWithTaskId:_currentTaskId];
    }
    if (_deviceSessionActive && !_deviceSessionStopping && _deviceSessionRequest) {
        [context stopDeviceAISessionWithRequest:_deviceSessionRequest completion:nil];
    }
    if (_deviceConversationModeActive) {
        [context stopDeviceConversationTranslationWithCompletion:nil];
    }
}

#pragma mark - 私有方法 - 页面搭建

- (void)setupViews {
    [self.view addSubview:self.pageTitleLabel];
    [self.view addSubview:self.modeButton];
    [self.view addSubview:self.helpButton];
    [self.view addSubview:self.normalContainerView];
    [self.normalContainerView addSubview:self.normalTableView];
    [self.normalContainerView addSubview:self.emptyLabel];
    [self.normalContainerView addSubview:self.normalControlView];
    [self.normalControlView addSubview:self.leftLanguageButton];
    [self.normalControlView addSubview:self.rightLanguageButton];
    [self.normalControlView addSubview:self.swapButton];
    [self.normalControlView addSubview:self.leftTalkButton];
    [self.normalControlView addSubview:self.rightTalkButton];
    [self.view addSubview:self.faceContainerView];
    [self.faceContainerView addSubview:self.faceTopTableView];
    [self.faceContainerView addSubview:self.faceBottomTableView];
    [self.faceContainerView addSubview:self.faceDividerView];
    [self.faceContainerView addSubview:self.faceSwapButton];
    [self.faceContainerView addSubview:self.faceTopTalkButton];
    [self.faceContainerView addSubview:self.faceBottomTalkButton];
    self.faceTopTableView.transform = CGAffineTransformMakeRotation(M_PI);
    self.faceTopTalkButton.transform = CGAffineTransformMakeRotation(M_PI);
    [self.view addSubview:self.devicePickerOverlay];
    [self.devicePickerOverlay addSubview:self.devicePickerSheet];
    [self.devicePickerSheet addSubview:self.devicePickerTitleLabel];
    for (UIButton *button in self.devicePairButtons) {
        [self.devicePickerSheet addSubview:button];
    }
    [self.devicePickerSheet addSubview:self.deviceConfirmButton];
}

- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat topInset = self.ts_navigationBarTotalHeight;
    if (topInset <= 0.0) topInset = self.view.safeAreaInsets.top;
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;
    self.pageTitleLabel.frame = CGRectMake(20.0, topInset + 10.0, width - 160.0, 44.0);
    self.modeButton.frame = CGRectMake(width - 118.0, topInset + 13.0, 70.0, 34.0);
    self.helpButton.frame = CGRectMake(width - 42.0, topInset + 13.0, 30.0, 34.0);
    CGFloat contentTop = CGRectGetMaxY(self.pageTitleLabel.frame) + 6.0;
    CGFloat contentHeight = height - contentTop;
    self.normalContainerView.frame = CGRectMake(0.0, contentTop, width, contentHeight);
    self.faceContainerView.frame = self.normalContainerView.frame;

    CGFloat controlsHeight = 156.0 + bottomInset;
    self.normalControlView.frame = CGRectMake(0.0, contentHeight - controlsHeight,
                                               width, controlsHeight);
    self.normalTableView.frame = CGRectMake(0.0, 0.0, width,
                                             CGRectGetMinY(self.normalControlView.frame));
    self.emptyLabel.frame = CGRectInset(self.normalTableView.frame, 40.0, 40.0);
    CGFloat halfWidth = width / 2.0;
    self.leftLanguageButton.frame = CGRectMake(14.0, 10.0, halfWidth - 48.0, 36.0);
    self.rightLanguageButton.frame = CGRectMake(halfWidth + 34.0, 10.0,
                                                 halfWidth - 48.0, 36.0);
    self.swapButton.frame = CGRectMake(halfWidth - 22.0, 10.0, 44.0, 36.0);
    self.leftTalkButton.frame = CGRectMake(halfWidth / 2.0 - 43.0, 57.0, 86.0, 70.0);
    self.rightTalkButton.frame = CGRectMake(halfWidth + halfWidth / 2.0 - 43.0,
                                             57.0, 86.0, 70.0);

    CGFloat dividerHeight = 48.0;
    CGFloat halfHeight = (contentHeight - dividerHeight) / 2.0;
    self.faceTopTableView.bounds = CGRectMake(0.0, 0.0, width, halfHeight);
    self.faceTopTableView.center = CGPointMake(width / 2.0, halfHeight / 2.0);
    self.faceDividerView.frame = CGRectMake(0.0, halfHeight, width, dividerHeight);
    self.faceSwapButton.frame = CGRectMake((width - 44.0) / 2.0,
                                            halfHeight + 4.0, 44.0, 40.0);
    self.faceBottomTableView.frame = CGRectMake(0.0, halfHeight + dividerHeight,
                                                 width, halfHeight);
    self.faceTopTalkButton.bounds = CGRectMake(0.0, 0.0, 88.0, 58.0);
    self.faceTopTalkButton.center = CGPointMake(width - 60.0, 45.0);
    self.faceBottomTalkButton.frame = CGRectMake(16.0,
                                                  contentHeight - 74.0 - bottomInset,
                                                  88.0, 58.0);

    self.devicePickerOverlay.frame = self.view.bounds;
    CGFloat sheetHeight = 300.0 + bottomInset;
    self.devicePickerSheet.frame = CGRectMake(0.0, height - sheetHeight, width, sheetHeight);
    self.devicePickerTitleLabel.frame = CGRectMake(20.0, 20.0, width - 40.0, 34.0);
    CGFloat cardGap = 10.0;
    CGFloat cardWidth = (width - 40.0 - cardGap * 2.0) / 3.0;
    [self.devicePairButtons enumerateObjectsUsingBlock:^(UIButton *button,
                                                         NSUInteger index,
                                                         BOOL *stop) {
        button.frame = CGRectMake(20.0 + (cardWidth + cardGap) * index,
                                  70.0, cardWidth, 126.0);
    }];
    self.deviceConfirmButton.frame = CGRectMake(20.0, sheetHeight - bottomInset - 62.0,
                                                 width - 40.0, 48.0);
}

- (UITableView *)conversationTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                          style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = UIColor.clearColor;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.contentInset = UIEdgeInsetsMake(8.0, 0.0, 14.0, 0.0);
    return tableView;
}

- (UIButton *)talkButtonForSide:(TSConversationSide)side {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = side;
    button.titleLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(onTalkButtonTouchDown:)
       forControlEvents:UIControlEventTouchDown];
    UIControlEvents stopEvents = UIControlEventTouchUpInside | UIControlEventTouchUpOutside |
        UIControlEventTouchCancel | UIControlEventTouchDragExit;
    [button addTarget:self action:@selector(onTalkButtonTouchUp:)
       forControlEvents:stopEvents];
    return button;
}

- (UIButton *)headerButtonWithSystemName:(NSString *)systemName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tintColor = TSConversationPrimaryTextColor();
    button.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.72];
    button.layer.cornerRadius = 17.0;
    if (@available(iOS 13.0, *)) {
        [button setImage:[UIImage systemImageNamed:systemName] forState:UIControlStateNormal];
    }
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - 私有方法 - 页面状态

- (void)refreshInterface {
    self.normalContainerView.hidden = self.faceToFace;
    self.faceContainerView.hidden = !self.faceToFace;
    NSString *modeTitle = self.faceToFace
        ? TSLocalizedString(@"ai_conversation.mode_face")
        : TSLocalizedString(@"ai_conversation.mode_normal");
    [self.modeButton setTitle:modeTitle forState:UIControlStateNormal];
    [self.leftLanguageButton
        setTitle:[TSAIInterpreterFormatter displayNameForLanguage:self.leftLanguage]
        forState:UIControlStateNormal];
    [self.rightLanguageButton
        setTitle:[TSAIInterpreterFormatter displayNameForLanguage:self.rightLanguage]
        forState:UIControlStateNormal];
    BOOL sessionInFlight = self.currentTaskId.length > 0 || self.deviceSessionRequest != nil;
    BOOL languageEnabled = !sessionInFlight && !self.stopping;
    self.leftLanguageButton.enabled = languageEnabled;
    self.rightLanguageButton.enabled = languageEnabled;
    self.swapButton.enabled = languageEnabled;
    self.modeButton.enabled = languageEnabled;
    self.emptyLabel.hidden = self.turns.count > 0;
    TSConversationSide topSide = self.faceSidesSwapped
        ? TSConversationSideLeft : TSConversationSideRight;
    TSConversationSide bottomSide = self.faceSidesSwapped
        ? TSConversationSideRight : TSConversationSideLeft;
    self.faceTopTalkButton.tag = topSide;
    self.faceBottomTalkButton.tag = bottomSide;
    [self refreshTalkButton:self.leftTalkButton side:TSConversationSideLeft];
    [self refreshTalkButton:self.rightTalkButton side:TSConversationSideRight];
    [self refreshTalkButton:self.faceTopTalkButton side:topSide];
    [self refreshTalkButton:self.faceBottomTalkButton side:bottomSide];
    [self refreshConversationTables];
}

- (void)refreshTalkButton:(UIButton *)button side:(TSConversationSide)side {
    BOOL sessionInFlight = self.currentTaskId.length > 0 || self.deviceSessionRequest != nil;
    BOOL active = self.activeSide == side && sessionInFlight && !self.stopping;
    BOOL locked = sessionInFlight && self.activeSide != side;
    NSString *state = active ? @"▂▄▆▄▂"
        : TSLocalizedString(@"ai_conversation.hold_to_talk");
    button.accessibilityLabel = active ? TSLocalizedString(@"ai_conversation.listening") : state;
    BOOL faceButton = button == self.faceTopTalkButton || button == self.faceBottomTalkButton;
    if (faceButton) {
        TSAILanguage language = side == TSConversationSideLeft
            ? self.leftLanguage : self.rightLanguage;
        NSString *languageName = [TSAIInterpreterFormatter displayNameForLanguage:language];
        [button setTitle:[NSString stringWithFormat:@"%@\n%@ · %@", languageName,
                          [self deviceNameForSide:side], state]
                forState:UIControlStateNormal];
    } else {
        [button setTitle:[NSString stringWithFormat:@"%@\n%@",
                          [self deviceNameForSide:side], state]
                forState:UIControlStateNormal];
    }
    button.backgroundColor = active ? UIColor.blackColor
        : [UIColor colorWithWhite:0.90 alpha:1.0];
    [button setTitleColor:active ? UIColor.whiteColor : TSConversationPrimaryTextColor()
                 forState:UIControlStateNormal];
    button.layer.cornerRadius = active ? 28.0 : 32.0;
    button.enabled = self.deviceConversationModeActive && !self.stopping && !locked;
    button.alpha = button.enabled ? 1.0 : 0.42;
}

- (NSString *)deviceNameForSide:(TSConversationSide)side {
    switch (self.selectedDevicePair) {
        case TSConversationDevicePairPhoneAndCase:
            return side == TSConversationSideLeft
                ? TSLocalizedString(@"ai_conversation.device_phone")
                : TSLocalizedString(@"ai_conversation.device_case");
        case TSConversationDevicePairPhoneAndEarbuds:
            return side == TSConversationSideLeft
                ? TSLocalizedString(@"ai_conversation.device_phone")
                : TSLocalizedString(@"ai_conversation.device_earbuds");
        case TSConversationDevicePairEarbudsAndCase:
            return side == TSConversationSideLeft
                ? TSLocalizedString(@"ai_conversation.device_earbuds")
                : TSLocalizedString(@"ai_conversation.device_case");
    }
    return @"";
}

- (void)refreshConversationTables {
    [self.normalTableView reloadData];
    [self.faceTopTableView reloadData];
    [self.faceBottomTableView reloadData];
    self.emptyLabel.hidden = self.turns.count > 0;
    if (self.turns.count == 0) return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.turns.count - 1 inSection:0];
    for (UITableView *tableView in @[self.normalTableView,
                                     self.faceTopTableView,
                                     self.faceBottomTableView]) {
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
    }
}

#pragma mark - 私有方法 - 页面事件

- (void)onModeButtonTap {
    if (self.currentTaskId.length > 0 || self.deviceSessionRequest || self.stopping) return;
    UIAlertController *sheet = [UIAlertController
        alertControllerWithTitle:TSLocalizedString(@"ai_conversation.select_mode")
                         message:nil
                  preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"ai_conversation.mode_normal")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        weakSelf.faceToFace = NO;
        [weakSelf refreshInterface];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"ai_conversation.mode_face")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
        weakSelf.faceToFace = YES;
        [weakSelf refreshInterface];
    }]];
    [sheet addAction:[UIAlertAction actionWithTitle:TSLocalizedString(@"general.cancel")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    sheet.popoverPresentationController.sourceView = self.modeButton;
    sheet.popoverPresentationController.sourceRect = self.modeButton.bounds;
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)onHelpButtonTap {
    [self showAlertWithMsg:TSLocalizedString(@"ai_conversation.help")];
}

- (void)onLeftLanguageTap {
    [self presentLanguageSheetForSide:TSConversationSideLeft];
}

- (void)onRightLanguageTap {
    [self presentLanguageSheetForSide:TSConversationSideRight];
}

- (void)onSwapLanguageTap {
    if (self.currentTaskId.length > 0 || self.deviceSessionRequest || self.stopping) return;
    TSAILanguage previousLeftLanguage = self.leftLanguage;
    self.leftLanguage = self.rightLanguage;
    self.rightLanguage = previousLeftLanguage;
    [self refreshInterface];
}

- (void)onFaceSwapButtonTap {
    self.faceSidesSwapped = !self.faceSidesSwapped;
    [self refreshInterface];
}

- (void)presentLanguageSheetForSide:(TSConversationSide)side {
    if (self.currentTaskId.length > 0 || self.deviceSessionRequest || self.stopping) return;
    TSAILanguage current = side == TSConversationSideLeft ? self.leftLanguage : self.rightLanguage;
    __weak typeof(self) weakSelf = self;
    TSAIInterpreterLanguageSheetVC *sheet = [[TSAIInterpreterLanguageSheetVC alloc]
        initWithTitle:TSLocalizedString(@"ai_conversation.select_language")
              languages:[TSAIInterpreterFormatter concreteLanguageList]
                current:current
                 onPick:^(TSAILanguage picked) {
        TSAILanguage other = side == TSConversationSideLeft
            ? weakSelf.rightLanguage : weakSelf.leftLanguage;
        if (picked == other) {
            [weakSelf showAlertWithMsg:TSLocalizedString(@"ai_conversation.same_language")];
            return;
        }
        if (side == TSConversationSideLeft) weakSelf.leftLanguage = picked;
        else weakSelf.rightLanguage = picked;
        [weakSelf refreshInterface];
    }];
    sheet.modalPresentationStyle = UIModalPresentationPageSheet;
    if (@available(iOS 15.0, *)) {
        sheet.sheetPresentationController.detents = @[
            [UISheetPresentationControllerDetent mediumDetent],
            [UISheetPresentationControllerDetent largeDetent]
        ];
        sheet.sheetPresentationController.prefersGrabberVisible = YES;
    }
    [self presentViewController:sheet animated:YES completion:nil];
}

#pragma mark - 私有方法 - 设备选择

- (void)registerAudioRouteObservation {
    __weak typeof(self) weakSelf = self;
    [[TSAIKit sharedInstance].activeContext.audioRouting
        registerAudioRouteCapabilitiesDidChange:^(TSAIFeatureOptions features) {
        if ((features & (TSAIFeatureInterpretation |
                         TSAIFeatureDeviceVoiceTranslation)) == 0) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf refreshDevicePicker];
        });
    }];
}

/// 注册语音翻译设备协同会话回调
- (void)registerDeviceSessionHandlers {
    TSAIContext *context = [TSAIKit sharedInstance].activeContext;
    __weak typeof(self) weakSelf = self;
    __weak TSAIContext *weakContext = context;
    [context registerDeviceAISessionHandlerForUseCase:TSAIUseCaseVoiceTranslation
        prepareHandler:^(TSAIStartRequest *request, TSAICompletionBlock completion) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            BOOL prepared = NO;
            if (request.deviceCoordination.initiator == TSAISessionInitiatorDevice) {
                prepared = [strongSelf prepareDeviceOriginSessionForRequest:request];
            } else {
                prepared = [strongSelf isCurrentDeviceSessionRequest:request] &&
                    [strongSelf startInterpreterForSide:strongSelf.activeSide
                                             generation:strongSelf.sessionGeneration];
            }
            completion(prepared, nil);
        }
        activationHandler:^(TSAIStartRequest *request) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil) {
                [weakContext stopDeviceAISessionWithRequest:request completion:nil];
                return;
            }
            [strongSelf handleDeviceSessionActivation:request];
        }
        inputCompletionHandler:^(TSAIStartRequest *request) {
            [weakSelf handleDeviceSessionInputCompletion:request];
        }
        terminationHandler:^(TSAIStartRequest *request,
                             BOOL interrupted,
                             NSError *error) {
            [weakSelf handleDeviceSessionTermination:request
                                         interrupted:interrupted
                                               error:error];
        }
        voiceDataHandler:nil];
}

/// 为设备在对话翻译产品模式中发起的一轮录音准备本地翻译
- (BOOL)prepareDeviceOriginSessionForRequest:(TSAIStartRequest *)request {
    if (!self.deviceConversationModeActive || self.currentTaskId.length > 0 ||
        self.deviceSessionRequest != nil || self.stopping ||
        request.parameters.kind != TSAIUseCaseParameterKindVoiceTranslation) {
        return NO;
    }
    TSConversationSide side = TSConversationSideNone;
    switch (request.parameters.voiceTranslationMode) {
        case TSAIVoiceTranslationModeConversationSelf:
            side = TSConversationSideLeft;
            break;
        case TSAIVoiceTranslationModeConversationPeer:
            side = TSConversationSideRight;
            break;
        case TSAIVoiceTranslationModeInvalid:
        case TSAIVoiceTranslationModeStandard:
            return NO;
    }
    self.lastStartDate = [NSDate date];
    self.sessionGeneration += 1;
    NSUInteger generation = self.sessionGeneration;
    self.activeSide = side;
    self.stopping = NO;
    self.deviceSessionRequest = request;
    self.deviceSessionStarting = YES;
    self.deviceSessionActive = NO;
    self.deviceSessionStopping = NO;
    self.deviceSessionStopRequested = NO;
    [self.originalSegments removeAllObjects];
    [self.translatedSegments removeAllObjects];
    TSConversationTurn *turn = [[TSConversationTurn alloc] init];
    turn.index = self.turns.count;
    turn.leftSpeaker = side == TSConversationSideLeft;
    turn.sourceLanguage = turn.leftSpeaker ? self.leftLanguage : self.rightLanguage;
    turn.targetLanguage = turn.leftSpeaker ? self.rightLanguage : self.leftLanguage;
    [self.turns addObject:turn];
    self.activeTurn = turn;
    [self refreshInterface];
    BOOL prepared = [self startInterpreterForSide:side generation:generation];
    if (prepared) return YES;
    [self.turns removeObject:turn];
    self.activeTurn = nil;
    self.activeSide = TSConversationSideNone;
    self.deviceSessionRequest = nil;
    self.deviceSessionStarting = NO;
    [self refreshInterface];
    return NO;
}

- (void)showDevicePicker {
    [self refreshDevicePicker];
    self.devicePickerOverlay.hidden = NO;
    self.devicePickerOverlay.alpha = 0.0;
    self.devicePickerSheet.transform = CGAffineTransformMakeTranslation(
        0.0, CGRectGetHeight(self.devicePickerSheet.bounds));
    [UIView animateWithDuration:0.25 animations:^{
        self.devicePickerOverlay.alpha = 1.0;
        self.devicePickerSheet.transform = CGAffineTransformIdentity;
    }];
}

- (void)refreshDevicePicker {
    BOOL deviceModeFixed = self.deviceConversationModeStarting ||
        self.deviceConversationModeActive;
    if (!deviceModeFixed && ![self isDevicePairAvailable:self.selectedDevicePair]) {
        for (NSInteger pair = TSConversationDevicePairPhoneAndCase;
             pair <= TSConversationDevicePairEarbudsAndCase; pair++) {
            if ([self isDevicePairAvailable:pair]) {
                self.selectedDevicePair = pair;
                break;
            }
        }
    }
    [self.devicePairButtons enumerateObjectsUsingBlock:^(UIButton *button,
                                                         NSUInteger index,
                                                         BOOL *stop) {
        BOOL available = [self isDevicePairAvailable:index];
        BOOL selected = self.selectedDevicePair == index;
        [button setTitle:[self titleForDevicePair:index selected:selected]
                forState:UIControlStateNormal];
        button.enabled = available;
        button.alpha = available ? 1.0 : 0.35;
        button.layer.borderWidth = selected ? 2.0 : 1.0;
        button.layer.borderColor = selected
            ? [UIColor colorWithRed:0.13 green:0.66 blue:0.58 alpha:1.0].CGColor
            : [UIColor colorWithWhite:0.82 alpha:1.0].CGColor;
    }];
    self.deviceConfirmButton.enabled =
        [self isDevicePairAvailable:self.selectedDevicePair] &&
        !self.deviceConversationModeStarting;
    self.deviceConfirmButton.alpha = self.deviceConfirmButton.enabled ? 1.0 : 0.4;
}

- (NSString *)titleForDevicePair:(TSConversationDevicePair)pair selected:(BOOL)selected {
    NSString *checkmark = selected ? @"✓\n" : @"\n";
    switch (pair) {
        case TSConversationDevicePairPhoneAndCase:
            return [NSString stringWithFormat:@"%@%@\n%@", checkmark,
                    TSLocalizedString(@"ai_conversation.device_phone"),
                    TSLocalizedString(@"ai_conversation.device_case")];
        case TSConversationDevicePairPhoneAndEarbuds:
            return [NSString stringWithFormat:@"%@%@\n%@", checkmark,
                    TSLocalizedString(@"ai_conversation.device_phone"),
                    TSLocalizedString(@"ai_conversation.device_earbuds")];
        case TSConversationDevicePairEarbudsAndCase:
            return [NSString stringWithFormat:@"%@%@\n%@", checkmark,
                    TSLocalizedString(@"ai_conversation.device_earbuds"),
                    TSLocalizedString(@"ai_conversation.device_case")];
    }
    return @"";
}

- (BOOL)isDevicePairAvailable:(TSConversationDevicePair)pair {
    id<TSAIAudioRoutingInterface> audioRouting = [TSAIKit sharedInstance].activeContext.audioRouting;
    if (audioRouting == nil) return NO;
    NSArray<TSAIAudioRouteCapability *> *deviceCapabilities =
        [audioRouting audioRouteCapabilitiesForFeature:
            TSAIFeatureDeviceVoiceTranslation];
    NSArray<TSAIAudioRouteCapability *> *interpretationCapabilities =
        [audioRouting audioRouteCapabilitiesForFeature:TSAIFeatureInterpretation];
    if (deviceCapabilities.count == 0) return NO;
    BOOL hasPhoneInput = [self capabilities:deviceCapabilities
                       containAvailableInput:TSAIAudioInputChannelBuiltInMic
                                      output:TSAIAudioOutputChannelBuiltInSpeaker];
    BOOL hasEarbudsInput = [self capabilities:interpretationCapabilities
                         containAvailableInput:TSAIAudioInputChannelSCO
                                        output:TSAIAudioOutputChannelBuiltInSpeaker];
    BOOL hasCaseInput = [self capabilities:deviceCapabilities
                      containAvailableInput:TSAIAudioInputChannelOpus
                                     output:TSAIAudioOutputChannelBuiltInSpeaker];
    switch (pair) {
        case TSConversationDevicePairPhoneAndCase:
            return hasPhoneInput && hasCaseInput;
        case TSConversationDevicePairPhoneAndEarbuds:
            return hasPhoneInput && hasEarbudsInput;
        case TSConversationDevicePairEarbudsAndCase:
            return hasEarbudsInput && hasCaseInput;
    }
    return NO;
}

- (BOOL)capabilities:(NSArray<TSAIAudioRouteCapability *> *)capabilities
    containAvailableInput:(TSAIAudioInputChannel)inputChannel
                   output:(TSAIAudioOutputChannel)outputChannel {
    for (TSAIAudioRouteCapability *capability in capabilities) {
        if (capability.isAvailable && capability.inputChannel == inputChannel &&
            capability.outputChannel == outputChannel) {
            return YES;
        }
    }
    return NO;
}

- (void)onDevicePairButtonTap:(UIButton *)button {
    TSConversationDevicePair pair = button.tag;
    if (![self isDevicePairAvailable:pair]) return;
    self.selectedDevicePair = pair;
    [self refreshDevicePicker];
}

- (void)onDeviceConfirmButtonTap {
    if (![self isDevicePairAvailable:self.selectedDevicePair]) return;
    [self startDeviceConversationTranslationMode];
}

/// 返回拾音组合对应的设备对话翻译产品模式
- (TSAIConversationTranslationMode)deviceConversationTranslationMode {
    switch (self.selectedDevicePair) {
        case TSConversationDevicePairPhoneAndCase:
            return TSAIConversationTranslationModeFaceToFace;
        case TSConversationDevicePairPhoneAndEarbuds:
            return TSAIConversationTranslationModePortable;
        case TSConversationDevicePairEarbudsAndCase:
            return TSAIConversationTranslationModePrivate;
    }
    return TSAIConversationTranslationModeInvalid;
}

/// 进入设备对话翻译产品模式
- (void)startDeviceConversationTranslationMode {
    if (self.deviceConversationModeStarting || self.deviceConversationModeActive ||
        self.leavingPage) return;
    TSAIConversationTranslationMode mode = [self deviceConversationTranslationMode];
    if (mode == TSAIConversationTranslationModeInvalid) return;
    self.deviceConversationModeGeneration += 1;
    NSUInteger generation = self.deviceConversationModeGeneration;
    self.deviceConversationModeStarting = YES;
    self.deviceConversationModeStopRequested = NO;
    [self refreshDevicePicker];
    [self refreshInterface];
    TSAIContext *context = [TSAIKit sharedInstance].activeContext;
    if (context == nil) {
        self.deviceConversationModeStarting = NO;
        [self refreshDevicePicker];
        [self refreshInterface];
        [self showAlertWithMsg:TSLocalizedString(@"ai_interpreter.toast_unavailable")];
        return;
    }
    TSLog(@"[TSAIConversationTranslationVC] enter device conversation mode=%lu",
          (unsigned long)mode);
    __weak typeof(self) weakSelf = self;
    [context startDeviceConversationTranslationWithMode:mode
                                             completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil) {
                if (success) {
                    [context stopDeviceConversationTranslationWithCompletion:nil];
                }
                return;
            }
            if (generation != strongSelf.deviceConversationModeGeneration) {
                if (success) {
                    [context stopDeviceConversationTranslationWithCompletion:nil];
                }
                return;
            }
            strongSelf.deviceConversationModeStarting = NO;
            if (!success || error != nil) {
                strongSelf.deviceConversationModeActive = NO;
                [strongSelf refreshDevicePicker];
                [strongSelf refreshInterface];
                if (!strongSelf.leavingPage) {
                    [strongSelf showAlertWithMsg:error.localizedDescription ?:
                        TSLocalizedString(@"ai_interpreter.toast_unavailable")];
                }
                return;
            }
            strongSelf.deviceConversationModeActive = YES;
            if (strongSelf.deviceConversationModeStopRequested || strongSelf.leavingPage) {
                [strongSelf stopDeviceConversationTranslationMode];
                return;
            }
            [strongSelf hideDevicePicker];
            [strongSelf refreshInterface];
        });
    }];
}

/// 退出设备对话翻译产品模式
- (void)stopDeviceConversationTranslationMode {
    if (self.deviceConversationModeStarting) {
        self.deviceConversationModeStopRequested = YES;
        return;
    }
    if (!self.deviceConversationModeActive) return;
    self.deviceConversationModeActive = NO;
    self.deviceConversationModeStopRequested = NO;
    TSLog(@"[TSAIConversationTranslationVC] exit device conversation mode");
    [[TSAIKit sharedInstance].activeContext
        stopDeviceConversationTranslationWithCompletion:^(BOOL success, NSError *error) {
        if (!success || error != nil) {
            TSLog(@"[TSAIConversationTranslationVC] exit device conversation mode failed: %@",
                  error);
        }
    }];
    [self refreshInterface];
}

/// 收起拾音组合选择面板
- (void)hideDevicePicker {
    [UIView animateWithDuration:0.22 animations:^{
        self.devicePickerOverlay.alpha = 0.0;
        self.devicePickerSheet.transform = CGAffineTransformMakeTranslation(
            0.0, CGRectGetHeight(self.devicePickerSheet.bounds));
    } completion:^(BOOL finished) {
        self.devicePickerOverlay.hidden = YES;
        self.devicePickerSheet.transform = CGAffineTransformIdentity;
        [self refreshInterface];
    }];
}

#pragma mark - 私有方法 - 录音入口

- (void)onTalkButtonTouchDown:(UIButton *)button {
    [self startSessionForSide:button.tag];
}

- (void)onTalkButtonTouchUp:(UIButton *)button {
    if (self.activeSide == button.tag) [self requestStopSession];
}

#pragma mark - 私有方法 - 会话流程

- (void)startSessionForSide:(TSConversationSide)side {
    if (!self.deviceConversationModeActive || side == TSConversationSideNone ||
        self.currentTaskId.length > 0 ||
        self.deviceSessionRequest || self.stopping) return;
    NSDate *now = [NSDate date];
    if (self.lastStartDate && [now timeIntervalSinceDate:self.lastStartDate] <
        TSConversationStartDebounceInterval) return;
    if (self.lastCompletionDate && [now timeIntervalSinceDate:self.lastCompletionDate] <
        TSConversationRestartCooldownInterval) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_conversation.restart_later")];
        return;
    }
    if (![self isDevicePairAvailable:self.selectedDevicePair]) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_interpreter.toast_unavailable")];
        return;
    }
    TSAIContext *context = [TSAIKit sharedInstance].activeContext;
    id<TSAIInterpreterInterface> interpreter = context.interpreter;
    if (interpreter == nil || ![context supportsAIFeatures:TSAIFeatureInterpretation]) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_interpreter.toast_unavailable")];
        return;
    }

    self.lastStartDate = now;
    self.sessionGeneration += 1;
    NSUInteger generation = self.sessionGeneration;
    self.activeSide = side;
    self.stopping = NO;
    self.deviceSessionStarting = YES;
    self.deviceSessionActive = NO;
    self.deviceSessionStopping = NO;
    self.deviceSessionStopRequested = NO;
    [self.originalSegments removeAllObjects];
    [self.translatedSegments removeAllObjects];
    TSConversationTurn *turn = [[TSConversationTurn alloc] init];
    turn.index = self.turns.count;
    turn.leftSpeaker = side == TSConversationSideLeft;
    turn.sourceLanguage = turn.leftSpeaker ? self.leftLanguage : self.rightLanguage;
    turn.targetLanguage = turn.leftSpeaker ? self.rightLanguage : self.leftLanguage;
    [self.turns addObject:turn];
    self.activeTurn = turn;

    TSAIVoiceTranslationMode mode = side == TSConversationSideLeft
        ? TSAIVoiceTranslationModeConversationSelf
        : TSAIVoiceTranslationModeConversationPeer;
    TSAIDeviceAIScene scene = side == TSConversationSideLeft
        ? TSAIDeviceAISceneTranslationSelf
        : TSAIDeviceAISceneTranslationPeer;
    TSAIAudioRouteConfiguration *deviceRoute = [TSAIAudioRouteConfiguration
        configurationWithInputChannel:TSAIAudioInputChannelOpus
                          outputChannel:TSAIAudioOutputChannelNone
                 routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyFail];
    TSAIDeviceCoordination *coordination = [TSAIDeviceCoordination
        coordinationWithScene:scene
                    initiator:TSAISessionInitiatorApp
      audioRouteConfiguration:deviceRoute];
    TSAIUseCaseParameters *parameters = [TSAIUseCaseParameters
        voiceTranslationParametersWithMode:mode];
    TSAIStartRequest *request = [TSAIStartRequest
        requestWithIdentifier:[NSString stringWithFormat:@"conversation-translation.%@",
                                                         NSUUID.UUID.UUIDString]
                      useCase:TSAIUseCaseVoiceTranslation
                   parameters:parameters
           deviceCoordination:coordination];
    self.deviceSessionRequest = request;
    TSLog(@"[TSAIConversationTranslationVC] start device session generation=%lu "
          @"side=%ld scene=%lu mode=%lu",
          (unsigned long)generation, (long)side,
          (unsigned long)scene, (unsigned long)mode);
    [self refreshInterface];
    __weak typeof(self) weakSelf = self;
    [context startDeviceAISessionFromAppWithRequest:request
                                         completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleDeviceSessionStartCompletion:success
                                                   error:error
                                              generation:generation];
        });
    }];
}

/// 在设备场景启动前准备 App 翻译业务
- (BOOL)startInterpreterForSide:(TSConversationSide)side
                      generation:(NSUInteger)generation {
    if (generation != self.sessionGeneration || self.deviceSessionRequest == nil ||
        self.currentTaskId.length > 0 || self.activeTurn == nil) return NO;
    TSAIContext *context = [TSAIKit sharedInstance].activeContext;
    id<TSAIInterpreterInterface> interpreter = context.interpreter;
    TSAIInterpreterConfig *config = [TSAIInterpreterConfig defaultConfig];
    config.sourceLanguage = self.activeTurn.sourceLanguage;
    config.targetLanguage = self.activeTurn.targetLanguage;
    config.enableVoiceOutput = YES;
    config.autoPlayVoice = YES;
    config.audioRouteConfiguration = [self audioRouteConfigurationForSide:side];
    self.activeInputChannel = config.audioRouteConfiguration.inputChannel;
    TSLog(@"[TSAIConversationTranslationVC] start generation=%lu side=%ld "
          @"source=%ld target=%ld input=%ld output=%ld",
          (unsigned long)generation, (long)side, (long)config.sourceLanguage,
          (long)config.targetLanguage,
          (long)config.audioRouteConfiguration.inputChannel,
          (long)config.audioRouteConfiguration.outputChannel);

    __weak typeof(self) weakSelf = self;
    NSString *taskId = [interpreter startInterpretationWithConfig:config
        onContent:^(TSAIInterpreterContent *content) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf handleContent:content generation:generation];
            });
        }
        onEvent:^(TSAIInterpreterEvent *event) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf handleEvent:event generation:generation];
            });
        }
        completion:^(TSAIInterpreterReport *report, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf handleCompletionWithReport:report error:error generation:generation];
            });
        }];
    if (taskId.length == 0) {
        self.activeInputChannel = TSAIAudioInputChannelUnknown;
        return NO;
    }
    self.currentTaskId = taskId;
    [self refreshInterface];
    return YES;
}

/// 处理设备协同会话启动结果
- (void)handleDeviceSessionStartCompletion:(BOOL)success
                                     error:(NSError *)error
                                generation:(NSUInteger)generation {
    if (generation != self.sessionGeneration || self.deviceSessionRequest == nil) return;
    self.deviceSessionStarting = NO;
    if (success && error == nil) return;
    TSLog(@"[TSAIConversationTranslationVC] device session start failed "
          @"generation=%lu domain=%@ code=%ld description=%@",
          (unsigned long)generation, error.domain, (long)error.code,
          error.localizedDescription);
    if (self.activeTurn) [self.turns removeObject:self.activeTurn];
    self.deviceSessionRequest = nil;
    self.deviceSessionActive = NO;
    self.deviceSessionStopping = NO;
    self.deviceSessionStopRequested = NO;
    self.activeTurn = nil;
    self.activeSide = TSConversationSideNone;
    self.stopping = self.currentTaskId.length > 0;
    [self invalidateSilenceTimer];
    [self refreshInterface];
    if (!self.leavingPage) {
        [self showAlertWithMsg:error.localizedDescription ?:
            TSLocalizedString(@"ai_interpreter.toast_unavailable")];
    }
    if (self.currentTaskId.length > 0) {
        [[TSAIKit sharedInstance].activeContext.interpreter
            stopInterpretationWithTaskId:self.currentTaskId];
    }
}

/// 处理设备协同会话激活
- (void)handleDeviceSessionActivation:(TSAIStartRequest *)request {
    if (![self isCurrentDeviceSessionRequest:request]) return;
    self.deviceSessionRequest = request;
    self.deviceSessionStarting = NO;
    self.deviceSessionActive = YES;
    if (self.deviceSessionStopRequested || self.leavingPage || self.stopping) {
        self.stopping = YES;
        self.activeSide = TSConversationSideNone;
        [self refreshInterface];
        [self stopDeviceSessionIfNeeded];
        return;
    }
    if (self.currentTaskId.length > 0) {
        [self scheduleSilenceTimerForGeneration:self.sessionGeneration
                                         taskId:self.currentTaskId];
    }
    [self refreshInterface];
}

/// 处理设备输入自然完成，Opus 输入等待同传自行完成 flush
- (void)handleDeviceSessionInputCompletion:(TSAIStartRequest *)request {
    if (![self isCurrentDeviceSessionRequest:request]) return;
    TSAIAudioInputChannel inputChannel = self.activeInputChannel;
    TSLog(@"[TSAIConversationTranslationVC] device input completed "
          @"requestId=%@, taskId=%@, input=%ld",
          request.requestIdentifier,
          self.currentTaskId,
          (long)inputChannel);
    self.deviceSessionRequest = nil;
    self.deviceSessionStarting = NO;
    self.deviceSessionActive = NO;
    self.deviceSessionStopping = NO;
    self.deviceSessionStopRequested = NO;
    self.stopping = self.currentTaskId.length > 0;
    self.activeSide = TSConversationSideNone;
    [self invalidateSilenceTimer];
    [self refreshInterface];
    if (self.currentTaskId.length == 0) {
        [self finishLocalSessionCleanup];
        return;
    }
    if (inputChannel != TSAIAudioInputChannelOpus) {
        [[TSAIKit sharedInstance].activeContext.interpreter
            stopInterpretationWithTaskId:self.currentTaskId];
    }
}

/// 处理设备协同会话结束
- (void)handleDeviceSessionTermination:(TSAIStartRequest *)request
                            interrupted:(BOOL)interrupted
                                  error:(NSError *)error {
    if (![self isCurrentDeviceSessionRequest:request]) return;
    TSLog(@"[TSAIConversationTranslationVC] device session terminated "
          @"interrupted=%d domain=%@ code=%ld description=%@",
          interrupted, error.domain, (long)error.code, error.localizedDescription);
    self.deviceSessionRequest = nil;
    self.deviceSessionStarting = NO;
    self.deviceSessionActive = NO;
    self.deviceSessionStopping = NO;
    self.deviceSessionStopRequested = NO;
    if (error && !self.leavingPage) {
        [self showAlertWithMsg:error.localizedDescription];
    }
    if (self.currentTaskId.length > 0) {
        if (!self.stopping) {
            self.stopping = YES;
            self.activeSide = TSConversationSideNone;
            [self invalidateSilenceTimer];
            [self refreshInterface];
            [[TSAIKit sharedInstance].activeContext.interpreter
                stopInterpretationWithTaskId:self.currentTaskId];
        }
        return;
    }
    if (self.activeTurn && self.activeTurn.originalText.length == 0 &&
        self.activeTurn.translatedText.length == 0) {
        [self.turns removeObject:self.activeTurn];
    }
    [self finishLocalSessionCleanup];
}

/// 判断是否为当前设备协同会话
- (BOOL)isCurrentDeviceSessionRequest:(TSAIStartRequest *)request {
    return request.requestIdentifier.length > 0 &&
        [request.requestIdentifier isEqualToString:
            self.deviceSessionRequest.requestIdentifier];
}

/// 返回所选设备组合中指定发言侧的精确输入通道
- (TSAIAudioInputChannel)inputChannelForSide:(TSConversationSide)side {
    TSAIAudioInputChannel inputChannel = TSAIAudioInputChannelBuiltInMic;
    switch (self.selectedDevicePair) {
        case TSConversationDevicePairPhoneAndCase:
            inputChannel = side == TSConversationSideLeft
                ? TSAIAudioInputChannelBuiltInMic : TSAIAudioInputChannelOpus;
            break;
        case TSConversationDevicePairPhoneAndEarbuds:
            inputChannel = side == TSConversationSideLeft
                ? TSAIAudioInputChannelBuiltInMic : TSAIAudioInputChannelSCO;
            break;
        case TSConversationDevicePairEarbudsAndCase:
            inputChannel = side == TSConversationSideLeft
                ? TSAIAudioInputChannelSCO : TSAIAudioInputChannelOpus;
            break;
    }
    return inputChannel;
}

- (TSAIAudioRouteConfiguration *)audioRouteConfigurationForSide:(TSConversationSide)side {
    TSAIAudioInputChannel inputChannel = [self inputChannelForSide:side];
    if (self.deviceSessionRequest.deviceCoordination.initiator ==
        TSAISessionInitiatorDevice) {
        TSAIAudioInputChannel requestedInputChannel =
            self.deviceSessionRequest.deviceCoordination.audioRouteConfiguration.inputChannel;
        BOOL requestedInputValid =
            requestedInputChannel == TSAIAudioInputChannelBuiltInMic ||
            requestedInputChannel == TSAIAudioInputChannelSCO ||
            requestedInputChannel == TSAIAudioInputChannelOpus;
        if (requestedInputValid) {
            inputChannel = requestedInputChannel;
        }
    }
    return [TSAIAudioRouteConfiguration
        configurationWithInputChannel:inputChannel
                          outputChannel:TSAIAudioOutputChannelBuiltInSpeaker
                 routeUnavailablePolicy:TSAIAudioRouteUnavailablePolicyFail];
}

- (void)requestStopSession {
    if (self.currentTaskId.length > 0) {
        if (self.stopping) return;
        self.stopping = YES;
        self.deviceSessionStopRequested = YES;
        self.activeSide = TSConversationSideNone;
        [self invalidateSilenceTimer];
        [self refreshInterface];
        TSLog(@"[TSAIConversationTranslationVC] stop taskId=%@ generation=%lu",
              self.currentTaskId, (unsigned long)self.sessionGeneration);
        if (self.activeInputChannel == TSAIAudioInputChannelOpus &&
            self.deviceSessionRequest != nil) {
            [self stopDeviceSessionIfNeeded];
            return;
        }
        [[TSAIKit sharedInstance].activeContext.interpreter
            stopInterpretationWithTaskId:self.currentTaskId];
        return;
    }
    if (self.deviceSessionRequest == nil) return;
    self.stopping = YES;
    self.deviceSessionStopRequested = YES;
    self.activeSide = TSConversationSideNone;
    [self invalidateSilenceTimer];
    [self refreshInterface];
    [self stopDeviceSessionIfNeeded];
}

/// 在设备会话已激活后发起停止
- (void)stopDeviceSessionIfNeeded {
    if (!self.deviceSessionActive || self.deviceSessionStopping ||
        self.deviceSessionRequest == nil) return;
    self.deviceSessionStopping = YES;
    TSAIStartRequest *request = self.deviceSessionRequest;
    TSLog(@"[TSAIConversationTranslationVC] stop device session identifier=%@",
          request.requestIdentifier);
    __weak typeof(self) weakSelf = self;
    [[TSAIKit sharedInstance].activeContext
        stopDeviceAISessionWithRequest:request
                            completion:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil ||
                ![strongSelf isCurrentDeviceSessionRequest:request]) return;
            if (success && error == nil) return;
            strongSelf.deviceSessionStopping = NO;
            TSLog(@"[TSAIConversationTranslationVC] stop device session failed "
                  @"domain=%@ code=%ld description=%@",
                  error.domain, (long)error.code, error.localizedDescription);
            if (!strongSelf.leavingPage) {
                [strongSelf showAlertWithMsg:error.localizedDescription ?:
                    TSLocalizedString(@"ai_interpreter.toast_unavailable")];
            }
        });
    }];
}

/// 完成本地状态清理并处理待播放音频
- (void)finishLocalSessionCleanup {
    if (self.currentTaskId.length > 0 || self.deviceSessionRequest) return;
    TSConversationTurn *pendingTurn = self.pendingPlaybackTurn;
    self.pendingPlaybackTurn = nil;
    self.activeTurn = nil;
    self.activeSide = TSConversationSideNone;
    self.activeInputChannel = TSAIAudioInputChannelUnknown;
    self.stopping = NO;
    self.lastCompletionDate = [NSDate date];
    [self.originalSegments removeAllObjects];
    [self.translatedSegments removeAllObjects];
    [self refreshInterface];
    if (pendingTurn) [self playArchivedAudioForTurn:pendingTurn];
}

- (void)scheduleSilenceTimerForGeneration:(NSUInteger)generation taskId:(NSString *)taskId {
    [self invalidateSilenceTimer];
    __weak typeof(self) weakSelf = self;
    self.silenceTimer = [NSTimer scheduledTimerWithTimeInterval:TSConversationSilenceTimeout
                                                        repeats:NO
                                                          block:^(NSTimer *timer) {
        if (weakSelf.sessionGeneration == generation &&
            [weakSelf.currentTaskId isEqualToString:taskId]) {
            [weakSelf requestStopSession];
        }
    }];
}

- (void)invalidateSilenceTimer {
    [self.silenceTimer invalidate];
    self.silenceTimer = nil;
}

- (BOOL)isCurrentTaskId:(NSString *)taskId generation:(NSUInteger)generation {
    return generation == self.sessionGeneration && taskId.length > 0 &&
        [taskId isEqualToString:self.currentTaskId];
}

#pragma mark - 私有方法 - SDK 回调

- (void)handleContent:(TSAIInterpreterContent *)content generation:(NSUInteger)generation {
    if (![self isCurrentTaskId:content.taskId generation:generation] || !self.activeTurn) return;
    NSNumber *segmentKey = @(content.utteranceIndex);
    switch (content.contentType) {
        case TSAIInterpreterContentTypeOriginalText:
            self.originalSegments[segmentKey] = content.text ?: @"";
            self.activeTurn.originalText = [self mergedTextFromSegments:self.originalSegments];
            if (content.text.length > 0 && self.deviceSessionActive && !self.stopping) {
                [self scheduleSilenceTimerForGeneration:generation taskId:content.taskId];
            }
            break;
        case TSAIInterpreterContentTypeTranslatedText:
            self.translatedSegments[segmentKey] = content.text ?: @"";
            self.activeTurn.translatedText = [self mergedTextFromSegments:self.translatedSegments];
            break;
        case TSAIInterpreterContentTypeAudioChunk:
            if (content.audioChunk.length > 0) {
                [self.activeTurn.audioData appendData:content.audioChunk];
                self.activeTurn.audioFormat = content.audioFormat;
            }
            break;
        case TSAIInterpreterContentTypeUnknown:
            return;
    }
    [self refreshConversationTables];
}

- (void)handleEvent:(TSAIInterpreterEvent *)event generation:(NSUInteger)generation {
    if (![self isCurrentTaskId:event.taskId generation:generation]) return;
    switch (event.eventType) {
        case TSAIInterpreterEventTypeNetworkError:
            if (self.stopping || self.deviceSessionStopRequested ||
                self.deviceSessionStopping || self.leavingPage) {
                TSLog(@"[TSAIConversationTranslationVC] network error ignored while stopping: "
                      @"taskId=%@, deviceStopRequested=%d, deviceStopping=%d, leavingPage=%d",
                      event.taskId,
                      self.deviceSessionStopRequested,
                      self.deviceSessionStopping,
                      self.leavingPage);
                break;
            }
            [self showAlertWithMsg:TSLocalizedString(@"ai_conversation.network_error")];
            [self requestStopSession];
            break;
        case TSAIInterpreterEventTypeBleDisconnected:
            [self showAlertWithMsg:TSLocalizedString(@"ai_conversation.device_disconnected")];
            [self requestStopSession];
            break;
        case TSAIInterpreterEventTypeSessionStarted:
        case TSAIInterpreterEventTypeUtteranceStarted:
        case TSAIInterpreterEventTypeUtteranceEnded:
        case TSAIInterpreterEventTypeLanguageDetected:
        case TSAIInterpreterEventTypeTranslationPlaybackStarted:
        case TSAIInterpreterEventTypeTranslationPlaybackEnded:
        case TSAIInterpreterEventTypeUnknown:
            break;
    }
}

- (void)handleCompletionWithReport:(TSAIInterpreterReport *)report
                              error:(NSError *)error
                         generation:(NSUInteger)generation {
    if (generation != self.sessionGeneration || self.currentTaskId.length == 0) return;
    if (report.taskId.length > 0 && ![report.taskId isEqualToString:self.currentTaskId]) return;
    [self invalidateSilenceTimer];
    if (report.utterances.count > 0 && self.activeTurn) {
        NSMutableArray<NSString *> *originalTexts = [NSMutableArray array];
        NSMutableArray<NSString *> *translatedTexts = [NSMutableArray array];
        for (TSAIInterpreterUtterance *utterance in report.utterances) {
            if (utterance.originalText.length > 0) [originalTexts addObject:utterance.originalText];
            if (utterance.translatedText.length > 0) [translatedTexts addObject:utterance.translatedText];
        }
        self.activeTurn.originalText = [originalTexts componentsJoinedByString:@"\n"];
        self.activeTurn.translatedText = [translatedTexts componentsJoinedByString:@"\n"];
    }
    if (self.activeTurn && self.activeTurn.originalText.length == 0 &&
        self.activeTurn.translatedText.length == 0) {
        [self.turns removeObject:self.activeTurn];
    }
    if (error) {
        TSLog(@"[TSAIConversationTranslationVC] completion error domain=%@ code=%ld description=%@",
              error.domain, (long)error.code, error.localizedDescription);
        [self showAlertWithMsg:[NSString stringWithFormat:
            TSLocalizedString(@"ai_interpreter.toast_error_fmt"),
            error.localizedDescription ?: @"-"]];
    }
    self.currentTaskId = nil;
    self.activeTurn = nil;
    self.activeSide = TSConversationSideNone;
    [self.originalSegments removeAllObjects];
    [self.translatedSegments removeAllObjects];
    if (self.deviceSessionRequest) {
        self.stopping = YES;
        self.deviceSessionStopRequested = YES;
        [self refreshInterface];
        [self stopDeviceSessionIfNeeded];
        return;
    }
    [self finishLocalSessionCleanup];
}

- (NSString *)mergedTextFromSegments:(NSDictionary<NSNumber *, NSString *> *)segments {
    NSArray<NSNumber *> *keys = [segments.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray<NSString *> *texts = [NSMutableArray arrayWithCapacity:keys.count];
    for (NSNumber *key in keys) {
        NSString *text = segments[key];
        if (text.length > 0) [texts addObject:text];
    }
    return [texts componentsJoinedByString:@"\n"];
}

#pragma mark - 私有方法 - 历史音频

- (void)requestPlaybackForTurn:(TSConversationTurn *)turn {
    if (turn.audioData.length == 0) return;
    if (self.currentTaskId.length > 0 || self.deviceSessionRequest) {
        self.pendingPlaybackTurn = turn;
        [self requestStopSession];
        return;
    }
    [self playArchivedAudioForTurn:turn];
}

- (void)playArchivedAudioForTurn:(TSConversationTurn *)turn {
    NSData *playableData = turn.audioData;
    if (turn.audioFormat == TSAIAudioFormatPcm) {
        playableData = [self waveDataFromPCMData:turn.audioData];
    } else if (turn.audioFormat == TSAIAudioFormatOpus ||
               turn.audioFormat == TSAIAudioFormatUnknown) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_conversation.audio_unavailable")];
        return;
    }
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:playableData error:&error];
    if (error || ![self.audioPlayer prepareToPlay]) {
        [self showAlertWithMsg:TSLocalizedString(@"ai_conversation.audio_unavailable")];
        return;
    }
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
}

- (NSData *)waveDataFromPCMData:(NSData *)pcmData {
    uint32_t dataLength = (uint32_t)pcmData.length;
    uint32_t fileLength = dataLength + 36;
    uint16_t audioFormat = 1;
    uint16_t channelCount = 1;
    uint32_t sampleRate = 16000;
    uint16_t bitsPerSample = 16;
    uint16_t blockAlign = channelCount * bitsPerSample / 8;
    uint32_t bytesPerSecond = sampleRate * blockAlign;
    uint32_t formatLength = 16;
    NSMutableData *waveData = [NSMutableData data];
    [waveData appendBytes:"RIFF" length:4];
    [waveData appendBytes:&fileLength length:sizeof(fileLength)];
    [waveData appendBytes:"WAVEfmt " length:8];
    [waveData appendBytes:&formatLength length:sizeof(formatLength)];
    [waveData appendBytes:&audioFormat length:sizeof(audioFormat)];
    [waveData appendBytes:&channelCount length:sizeof(channelCount)];
    [waveData appendBytes:&sampleRate length:sizeof(sampleRate)];
    [waveData appendBytes:&bytesPerSecond length:sizeof(bytesPerSecond)];
    [waveData appendBytes:&blockAlign length:sizeof(blockAlign)];
    [waveData appendBytes:&bitsPerSample length:sizeof(bitsPerSample)];
    [waveData appendBytes:"data" length:4];
    [waveData appendBytes:&dataLength length:sizeof(dataLength)];
    [waveData appendData:pcmData];
    return waveData;
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.turns.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const identifier = @"TSConversationBubbleCell";
    TSConversationBubbleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[TSConversationBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:identifier];
    }
    BOOL faceTable = tableView != self.normalTableView;
    BOOL viewerOnLeft = YES;
    if (tableView == self.faceTopTableView) viewerOnLeft = self.faceSidesSwapped;
    else if (tableView == self.faceBottomTableView) viewerOnLeft = !self.faceSidesSwapped;
    TSConversationTurn *turn = self.turns[indexPath.row];
    [cell bindTurn:turn faceToFace:faceTable viewerOnLeft:viewerOnLeft];
    __weak typeof(self) weakSelf = self;
    __weak TSConversationTurn *weakTurn = turn;
    cell.playHandler = ^{
        if (weakTurn) [weakSelf requestPlaybackForTurn:weakTurn];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL faceTable = tableView != self.normalTableView;
    BOOL viewerOnLeft = tableView == self.faceTopTableView
        ? self.faceSidesSwapped : !self.faceSidesSwapped;
    return [TSConversationBubbleCell heightForTurn:self.turns[indexPath.row]
                                       faceToFace:faceTable
                                      viewerOnLeft:viewerOnLeft
                                            width:CGRectGetWidth(tableView.bounds)];
}

#pragma mark - 属性（懒加载）

- (UILabel *)pageTitleLabel {
    if (!_pageTitleLabel) {
        _pageTitleLabel = [[UILabel alloc] init];
        _pageTitleLabel.text = TSLocalizedString(@"ai_conversation.title");
        _pageTitleLabel.font = [UIFont systemFontOfSize:30.0 weight:UIFontWeightBold];
        _pageTitleLabel.textColor = TSConversationPrimaryTextColor();
    }
    return _pageTitleLabel;
}

- (UIButton *)modeButton {
    if (!_modeButton) {
        _modeButton = [self headerButtonWithSystemName:@"rectangle.split.2x1"
                                                action:@selector(onModeButtonTap)];
        _modeButton.titleLabel.font = [UIFont systemFontOfSize:11.0 weight:UIFontWeightSemibold];
        _modeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -3.0, 0.0, 3.0);
    }
    return _modeButton;
}

- (UIButton *)helpButton {
    if (!_helpButton) {
        _helpButton = [self headerButtonWithSystemName:@"questionmark.circle"
                                                action:@selector(onHelpButtonTap)];
    }
    return _helpButton;
}

- (UIView *)normalContainerView {
    if (!_normalContainerView) _normalContainerView = [[UIView alloc] init];
    return _normalContainerView;
}

- (UITableView *)normalTableView {
    if (!_normalTableView) _normalTableView = [self conversationTableView];
    return _normalTableView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = TSLocalizedString(@"ai_conversation.empty");
        _emptyLabel.textColor = TSConversationSecondaryTextColor();
        _emptyLabel.font = [UIFont systemFontOfSize:15.0];
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
    }
    return _emptyLabel;
}

- (UIView *)normalControlView {
    if (!_normalControlView) {
        _normalControlView = [[UIView alloc] init];
        _normalControlView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.92];
        _normalControlView.layer.cornerRadius = 28.0;
        _normalControlView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    return _normalControlView;
}

- (UIButton *)languageButtonWithAction:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightSemibold];
    [button setTitleColor:TSConversationPrimaryTextColor() forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)leftLanguageButton {
    if (!_leftLanguageButton) {
        _leftLanguageButton = [self languageButtonWithAction:@selector(onLeftLanguageTap)];
    }
    return _leftLanguageButton;
}

- (UIButton *)rightLanguageButton {
    if (!_rightLanguageButton) {
        _rightLanguageButton = [self languageButtonWithAction:@selector(onRightLanguageTap)];
    }
    return _rightLanguageButton;
}

- (UIButton *)swapButton {
    if (!_swapButton) {
        _swapButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _swapButton.tintColor = [UIColor colorWithRed:0.13 green:0.66 blue:0.58 alpha:1.0];
        if (@available(iOS 13.0, *)) {
            [_swapButton setImage:[UIImage systemImageNamed:@"arrow.left.arrow.right"]
                         forState:UIControlStateNormal];
        }
        [_swapButton addTarget:self action:@selector(onSwapLanguageTap)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _swapButton;
}

- (UIButton *)leftTalkButton {
    if (!_leftTalkButton) _leftTalkButton = [self talkButtonForSide:TSConversationSideLeft];
    return _leftTalkButton;
}

- (UIButton *)rightTalkButton {
    if (!_rightTalkButton) _rightTalkButton = [self talkButtonForSide:TSConversationSideRight];
    return _rightTalkButton;
}

- (UIView *)faceContainerView {
    if (!_faceContainerView) _faceContainerView = [[UIView alloc] init];
    return _faceContainerView;
}

- (UITableView *)faceTopTableView {
    if (!_faceTopTableView) _faceTopTableView = [self conversationTableView];
    return _faceTopTableView;
}

- (UITableView *)faceBottomTableView {
    if (!_faceBottomTableView) _faceBottomTableView = [self conversationTableView];
    return _faceBottomTableView;
}

- (UIView *)faceDividerView {
    if (!_faceDividerView) {
        _faceDividerView = [[UIView alloc] init];
        _faceDividerView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.08];
    }
    return _faceDividerView;
}

- (UIButton *)faceSwapButton {
    if (!_faceSwapButton) {
        _faceSwapButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _faceSwapButton.backgroundColor = UIColor.whiteColor;
        _faceSwapButton.tintColor = [UIColor colorWithRed:0.13 green:0.66 blue:0.58 alpha:1.0];
        _faceSwapButton.layer.cornerRadius = 20.0;
        if (@available(iOS 13.0, *)) {
            [_faceSwapButton setImage:[UIImage systemImageNamed:@"arrow.up.arrow.down"]
                             forState:UIControlStateNormal];
        }
        [_faceSwapButton addTarget:self action:@selector(onFaceSwapButtonTap)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceSwapButton;
}

- (UIButton *)faceTopTalkButton {
    if (!_faceTopTalkButton) {
        _faceTopTalkButton = [self talkButtonForSide:TSConversationSideRight];
    }
    return _faceTopTalkButton;
}

- (UIButton *)faceBottomTalkButton {
    if (!_faceBottomTalkButton) {
        _faceBottomTalkButton = [self talkButtonForSide:TSConversationSideLeft];
    }
    return _faceBottomTalkButton;
}

- (UIView *)devicePickerOverlay {
    if (!_devicePickerOverlay) {
        _devicePickerOverlay = [[UIView alloc] init];
        _devicePickerOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.42];
        _devicePickerOverlay.hidden = YES;
    }
    return _devicePickerOverlay;
}

- (UIView *)devicePickerSheet {
    if (!_devicePickerSheet) {
        _devicePickerSheet = [[UIView alloc] init];
        _devicePickerSheet.backgroundColor = UIColor.whiteColor;
        _devicePickerSheet.layer.cornerRadius = 28.0;
        _devicePickerSheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    return _devicePickerSheet;
}

- (UILabel *)devicePickerTitleLabel {
    if (!_devicePickerTitleLabel) {
        _devicePickerTitleLabel = [[UILabel alloc] init];
        _devicePickerTitleLabel.text = TSLocalizedString(@"ai_conversation.audio_devices");
        _devicePickerTitleLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightBold];
        _devicePickerTitleLabel.textColor = TSConversationPrimaryTextColor();
    }
    return _devicePickerTitleLabel;
}

- (NSArray<UIButton *> *)devicePairButtons {
    if (!_devicePairButtons) {
        NSMutableArray<UIButton *> *buttons = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger pair = TSConversationDevicePairPhoneAndCase;
             pair <= TSConversationDevicePairEarbudsAndCase; pair++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.tag = pair;
            button.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
            button.layer.cornerRadius = 16.0;
            button.titleLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightSemibold];
            button.titleLabel.numberOfLines = 0;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setTitleColor:TSConversationPrimaryTextColor() forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onDevicePairButtonTap:)
              forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:button];
        }
        _devicePairButtons = buttons.copy;
    }
    return _devicePairButtons;
}

- (UIButton *)deviceConfirmButton {
    if (!_deviceConfirmButton) {
        _deviceConfirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _deviceConfirmButton.backgroundColor = UIColor.blackColor;
        _deviceConfirmButton.layer.cornerRadius = 24.0;
        _deviceConfirmButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
        [_deviceConfirmButton setTitle:TSLocalizedString(@"general.confirm")
                             forState:UIControlStateNormal];
        [_deviceConfirmButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_deviceConfirmButton addTarget:self action:@selector(onDeviceConfirmButtonTap)
                       forControlEvents:UIControlEventTouchUpInside];
    }
    return _deviceConfirmButton;
}

@end
