//
//  TSAIKitRootVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIKitRootVC.h"

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAppDelegate.h"
#import "TSDeviceCoordinator.h"
#import "TSAISummaryVC.h"
#import "TSAIChatVC.h"
#import "TSAIInterpreterSetupVC.h"
#import "TSAIConversationTranslationSetupVC.h"
#import "TSAITTSVC.h"
#import "TSAIASRFileVC.h"
#import "TSAIASRDeviceMicVC.h"
#import "TSAITranslateVC.h"
#import "TSAIAudioRecordVC.h"
#import "TSAIQuestionAnswerVC.h"

#import "TSAIKitRootCapability.h"
#import "TSAIKitRootCapabilityCell.h"
#import "TSAIKitRootHeroView.h"
#import "TSAIKitRootSectionHeaderView.h"

typedef NS_ENUM(NSInteger, TSAIKitSection) {
    TSAIKitSectionAssistant = 0,
    TSAIKitSectionQuestionAnswer,
    TSAIKitSectionInterpreter,
    TSAIKitSectionSpeech,
    TSAIKitSectionTranslate,
    TSAIKitSectionAudioRecord,
    TSAIKitSectionCount
};

static NSString * const kCapabilityCellID = @"TSAIKitRootCapabilityCell";
static NSString * const kSectionHeaderID  = @"TSAIKitRootSectionHeaderView";

@interface TSAIKitRootVC () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *aiCollectionView;
@property (nonatomic, strong) TSAIKitRootHeroView *heroView;
@property (nonatomic, copy)   NSArray<NSArray<TSAIKitRootCapability *> *> *sectionItems;

@end

@implementation TSAIKitRootVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = @"AI Kit";
    self.sectionItems = [self buildSectionItems];
}

- (void)setupViews {
    self.view.backgroundColor = [UIColor colorWithRed:0xF5/255.0 green:0xF6/255.0 blue:0xFB/255.0 alpha:1.0];
    [self.view addSubview:self.aiCollectionView];
    [self.view addSubview:self.heroView];
}

- (void)layoutViews {
    CGFloat topOffset = self.ts_navigationBarTotalHeight;
    if (topOffset <= 0) topOffset = self.view.safeAreaInsets.top;

    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat heroSide = 20.0;
    CGFloat heroTopGap = 12.0;
    CGFloat heroH = [TSAIKitRootHeroView heightForWidth:width - heroSide * 2];
    CGFloat heroBottomGap = 18.0;

    self.heroView.frame = CGRectMake(heroSide,
                                     topOffset + heroTopGap,
                                     width - heroSide * 2,
                                     heroH);

    CGFloat collectionTop = topOffset + heroTopGap + heroH + heroBottomGap;
    self.aiCollectionView.frame = CGRectMake(0, collectionTop,
                                              width,
                                              CGRectGetHeight(self.view.bounds) - collectionTop);
}

#pragma mark - 私有方法 - 数据

/// 构建各 section 的能力卡片
- (NSArray<NSArray<TSAIKitRootCapability *> *> *)buildSectionItems {
    UIColor *assistantTint   = [UIColor colorWithRed:0x4F/255.0 green:0x7B/255.0 blue:0xFF/255.0 alpha:1.0];
    UIColor *interpreterTint = [UIColor colorWithRed:0xFF/255.0 green:0x8A/255.0 blue:0x3D/255.0 alpha:1.0];
    UIColor *speechTint      = [UIColor colorWithRed:0x1F/255.0 green:0xC8/255.0 blue:0xA0/255.0 alpha:1.0];
    UIColor *translateTint   = [UIColor colorWithRed:0x9C/255.0 green:0x6D/255.0 blue:0xFF/255.0 alpha:1.0];
    UIColor *dialogueTint    = [UIColor colorWithRed:0x20/255.0 green:0xB8/255.0 blue:0xA6/255.0 alpha:1.0];
    UIColor *audioRecordTint = [UIColor colorWithRed:0xFF/255.0 green:0x4D/255.0 blue:0x5E/255.0 alpha:1.0];
    UIColor *questionAnswerTint = [UIColor colorWithRed:0xE6/255.0 green:0x4A/255.0 blue:0x8F/255.0 alpha:1.0];

    NSArray<TSAIKitRootCapability *> *assistantItems = @[
        [TSAIKitRootCapability capabilityWithTitle:@"Text Summary"
                                          subtitle:@"流式文本总结"
                                         tintColor:assistantTint
                                          iconType:TSAIKitRootCapabilityIconSummary
                                        widthStyle:TSAIKitRootCapabilityWidthHalf
                                           vcClass:[TSAISummaryVC class]],
        [TSAIKitRootCapability capabilityWithTitle:@"Voice Chat"
                                          subtitle:@"设备发起 · 长会话"
                                         tintColor:assistantTint
                                          iconType:TSAIKitRootCapabilityIconVoiceChat
                                        widthStyle:TSAIKitRootCapabilityWidthHalf
                                           vcClass:[TSAIChatVC class]],
    ];

    NSArray<TSAIKitRootCapability *> *questionAnswerItems = @[
        [TSAIKitRootCapability capabilityWithTitle:@"AI Q&A"
                                          subtitle:@"单次问答 · 文字 / 手机 / 耳机 / 手表四种拾音\n独立于 Voice Chat 会话"
                                         tintColor:questionAnswerTint
                                          iconType:TSAIKitRootCapabilityIconQuestionAnswer
                                        widthStyle:TSAIKitRootCapabilityWidthFull
                                           vcClass:[TSAIQuestionAnswerVC class]],
    ];

    NSArray<TSAIKitRootCapability *> *interpreterItems = @[
        [TSAIKitRootCapability capabilityWithTitle:@"Simultaneous Interpretation"
                                          subtitle:@"同声传译 · ASR → MT → TTS"
                                         tintColor:interpreterTint
                                          iconType:TSAIKitRootCapabilityIconInterpreter
                                        widthStyle:TSAIKitRootCapabilityWidthFull
                                           vcClass:[TSAIInterpreterSetupVC class]],
    ];

    NSArray<TSAIKitRootCapability *> *speechItems = @[
        [TSAIKitRootCapability capabilityWithTitle:@"TTS"
                                          subtitle:@"文本转语音"
                                         tintColor:speechTint
                                          iconType:TSAIKitRootCapabilityIconTTS
                                        widthStyle:TSAIKitRootCapabilityWidthHalf
                                           vcClass:[TSAITTSVC class]],
        [TSAIKitRootCapability capabilityWithTitle:@"ASR · File"
                                          subtitle:@"本地音频文件识别"
                                         tintColor:speechTint
                                          iconType:TSAIKitRootCapabilityIconASRFile
                                        widthStyle:TSAIKitRootCapabilityWidthHalf
                                           vcClass:[TSAIASRFileVC class]],
        [TSAIKitRootCapability capabilityWithTitle:@"ASR · Device Mic"
                                          subtitle:@"设备麦克风识别（AI 录音 / 实时上行）"
                                          tintColor:speechTint
                                           iconType:TSAIKitRootCapabilityIconASRMic
                                        widthStyle:TSAIKitRootCapabilityWidthFull
                                           vcClass:[TSAIASRDeviceMicVC class]],
    ];

    NSArray<TSAIKitRootCapability *> *translateItems = @[
        [TSAIKitRootCapability capabilityWithTitle:@"Text Translate"
                                          subtitle:@"流式文本翻译"
                                         tintColor:translateTint
                                          iconType:TSAIKitRootCapabilityIconTranslate
                                        widthStyle:TSAIKitRootCapabilityWidthFull
                                           vcClass:[TSAITranslateVC class]],
        [TSAIKitRootCapability capabilityWithTitle:@"Dialogue Translation"
                                          subtitle:@"对话翻译 · 双向会话"
                                         tintColor:dialogueTint
                                          iconType:TSAIKitRootCapabilityIconTranslate
                                        widthStyle:TSAIKitRootCapabilityWidthFull
                                           vcClass:[TSAIConversationTranslationSetupVC class]],
    ];

    // AIAudioRecording Demo 入口：固定放在 Translate 下方。
    NSArray<TSAIKitRootCapability *> *audioRecordItems = @[
        [TSAIKitRootCapability capabilityWithTitle:@"AI Recording"
                                          subtitle:@"设备录音 · 实时转写 · 说话人分离\n支持 App / Device 双向启停"
                                         tintColor:audioRecordTint
                                          iconType:TSAIKitRootCapabilityIconAudioRecord
                                        widthStyle:TSAIKitRootCapabilityWidthFull
                                           vcClass:[TSAIAudioRecordVC class]],
    ];

    return @[assistantItems, questionAnswerItems, interpreterItems, speechItems, translateItems, audioRecordItems];
}

/// section 标题
- (NSString *)titleForSection:(TSAIKitSection)section {
    switch (section) {
        case TSAIKitSectionAssistant:   return @"Assistant";
        case TSAIKitSectionQuestionAnswer: return @"Question Answer";
        case TSAIKitSectionInterpreter: return @"Interpreter";
        case TSAIKitSectionSpeech:      return @"Speech";
        case TSAIKitSectionTranslate:   return @"Translate";
        case TSAIKitSectionAudioRecord: return @"Recording";
        default: return @"";
    }
}

/// section 协议名
- (NSString *)protocolNameForSection:(TSAIKitSection)section {
    switch (section) {
        case TSAIKitSectionAssistant:   return @"TSAIAssistantInterface";
        case TSAIKitSectionQuestionAnswer: return @"TSAIQuestionAnswerInterface";
        case TSAIKitSectionInterpreter: return @"TSAIInterpreterInterface";
        case TSAIKitSectionSpeech:      return @"TSAISpeechInterface";
        case TSAIKitSectionTranslate:   return @"TSAITranslateInterface";
        case TSAIKitSectionAudioRecord: return @"TSAudioRecordInterface";
        default: return @"";
    }
}

/// section 主色（取该 section 第一个 item 的 tint）
- (UIColor *)tintColorForSection:(NSInteger)section {
    if (section >= (NSInteger)self.sectionItems.count) return [UIColor blackColor];
    NSArray<TSAIKitRootCapability *> *items = self.sectionItems[section];
    if (items.count == 0) return [UIColor blackColor];
    return items.firstObject.tintColor;
}

/// 取出 indexPath 对应的能力模型
- (nullable TSAIKitRootCapability *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= (NSInteger)self.sectionItems.count) return nil;
    NSArray<TSAIKitRootCapability *> *items = self.sectionItems[indexPath.section];
    if (indexPath.item >= (NSInteger)items.count) return nil;
    return items[indexPath.item];
}

/// 跳转到指定能力 VC
- (void)pushCapabilityClass:(Class)vcClass {
    if (!vcClass) return;
    NSString *unavailableTitle = nil;
    NSString *unavailableMessage = [self unavailableMessageForCapabilityClass:vcClass title:&unavailableTitle];
    if (unavailableMessage) {
        [self presentUnavailableAlertWithTitle:unavailableTitle message:unavailableMessage];
        return;
    }
    UIViewController *vc = [[vcClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/// 判断能力入口当前为何不可用：可用返回 nil，否则返回弹窗文案（并按需触发 AI 准备流程重试）
- (NSString *)unavailableMessageForCapabilityClass:(Class)vcClass title:(NSString **)titleOut {
    TSAIFeatureOptions feature = [self featureForCapabilityClass:vcClass];
    BOOL requiresContext = (feature != 0) || vcClass == [TSAIQuestionAnswerVC class];
    if (!requiresContext) return nil;

    TSAIContext *context = [TSAIKit sharedInstance].activeContext;
    if (!context) {
        // Context 未激活：绝大多数是公网探测 / 鉴权尚未完成，而不是设备或 SDK 不支持
        TSDeviceConnectionSnapshot *snapshot = [TSDeviceCoordinator sharedInstance].snapshot;
        if (!snapshot.isReady) {
            *titleOut = @"设备未连接";
            return @"请先连接手表，连接完成后 AI 功能会自动初始化";
        }
        [self retryAIPreparation];
        *titleOut = @"AI 尚未就绪";
        return @"AI 服务仍在初始化（公网探测或鉴权未完成），已自动重试，就绪后会在页面顶部提示你";
    }
    // Context 已激活但最终鉴权未完成：不拦截，顺带让 AppDelegate 续做鉴权，页内再按具体错误提示
    if (context.authorizationState != TSAIAuthorizationStateAuthenticated) {
        [self retryAIPreparation];
    }
    // 问答入口：Context 已激活即可进入；文字 / 设备两种模式各自在页内
    // 用 startEligibilityForRequest: 给出不支持的具体原因（设置 → 能力诊断）。
    if (vcClass == [TSAIQuestionAnswerVC class]) return nil;
    if (![context supportsAIFeatures:feature]) {
        *titleOut = @"暂不支持";
        return @"当前设备或 AI 方案不支持从 App 发起此功能";
    }
    return nil;
}

/// 通知 AppDelegate 立即重试 AI 准备流程（探测 / 激活 / 鉴权）
- (void)retryAIPreparation {
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    if ([delegate isKindOfClass:[TSAppDelegate class]]) {
        [(TSAppDelegate *)delegate retryAIPreparationIfNeeded];
    }
}

/// 弹出能力不可用提示
- (void)presentUnavailableAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (TSAIFeatureOptions)featureForCapabilityClass:(Class)vcClass {
    if (vcClass == [TSAISummaryVC class] || vcClass == [TSAIChatVC class]) {
        return vcClass == [TSAISummaryVC class] ? TSAIFeatureAISummary : TSAIFeatureAIChat;
    }
    if (vcClass == [TSAIInterpreterSetupVC class]) return TSAIFeatureInterpretation;
    if (vcClass == [TSAIASRDeviceMicVC class]) return TSAIFeatureDeviceMicRecognition;
    // 设备不支持 AI 录音时仍可用手机或耳机拾音，是否可用由录音页按拾音方式判断
    if (vcClass == [TSAIAudioRecordVC class]) return 0;
    if (vcClass == [TSAITranslateVC class] || vcClass == [TSAIConversationTranslationSetupVC class]) {
        return TSAIFeatureTextTranslation;
    }
    if (vcClass == [TSAITTSVC class]) return TSAIFeatureSpeechSynthesis;
    if (vcClass == [TSAIASRFileVC class]) return TSAIFeatureFileRecognition;
    return 0;
}

#pragma mark - 私有方法 - Hero 回调

- (void)onHeroPrimaryTap {
    [self pushCapabilityClass:[TSAIChatVC class]];
}

- (void)onHeroSecondaryTap {
    [self pushCapabilityClass:[TSAIInterpreterSetupVC class]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return TSAIKitSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section < (NSInteger)self.sectionItems.count) {
        return self.sectionItems[section].count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TSAIKitRootCapabilityCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:kCapabilityCellID forIndexPath:indexPath];
    TSAIKitRootCapability *item = [self itemAtIndexPath:indexPath];
    if (item) [cell bindCapability:item];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        TSAIKitRootSectionHeaderView *header =
            [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                withReuseIdentifier:kSectionHeaderID
                                                       forIndexPath:indexPath];
        TSAIKitSection section = (TSAIKitSection)indexPath.section;
        NSInteger count = (indexPath.section < (NSInteger)self.sectionItems.count)
                            ? (NSInteger)self.sectionItems[indexPath.section].count : 0;
        [header applyTitle:[self titleForSection:section]
              protocolName:[self protocolNameForSection:section]
                     count:count
                 tintColor:[self tintColorForSection:indexPath.section]];
        return header;
    }
    return [[UICollectionReusableView alloc] init];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat side = 20.0;
    CGFloat gap = 12.0;
    CGFloat innerW = CGRectGetWidth(collectionView.bounds) - side * 2;
    CGFloat halfW = (innerW - gap) / 2.0;

    TSAIKitRootCapability *item = [self itemAtIndexPath:indexPath];
    if (item.widthStyle == TSAIKitRootCapabilityWidthFull) {
        return CGSizeMake(innerW, 88.0);
    }
    return CGSizeMake(halfW, 132.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 20.0, 22.0, 20.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 12.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat height = [TSAIKitRootSectionHeaderView heightForWidth:CGRectGetWidth(collectionView.bounds)];
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), height);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TSAIKitRootCapability *item = [self itemAtIndexPath:indexPath];
    [self pushCapabilityClass:item.vcClass];
}

#pragma mark - 属性（懒加载）

- (UICollectionView *)aiCollectionView {
    if (!_aiCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionInset = UIEdgeInsetsZero;

        _aiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                              collectionViewLayout:layout];
        _aiCollectionView.backgroundColor = [UIColor clearColor];
        _aiCollectionView.alwaysBounceVertical = YES;
        _aiCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _aiCollectionView.delegate = self;
        _aiCollectionView.dataSource = self;
        _aiCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 24.0, 0);
        [_aiCollectionView registerClass:[TSAIKitRootCapabilityCell class]
              forCellWithReuseIdentifier:kCapabilityCellID];
        [_aiCollectionView registerClass:[TSAIKitRootSectionHeaderView class]
              forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                     withReuseIdentifier:kSectionHeaderID];
    }
    return _aiCollectionView;
}

- (TSAIKitRootHeroView *)heroView {
    if (!_heroView) {
        _heroView = [[TSAIKitRootHeroView alloc] initWithFrame:CGRectZero];
        __weak typeof(self) weakSelf = self;
        _heroView.onPrimaryTap = ^{ [weakSelf onHeroPrimaryTap]; };
        _heroView.onSecondaryTap = ^{ [weakSelf onHeroSecondaryTap]; };
    }
    return _heroView;
}

@end
