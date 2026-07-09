//
//  TSAIKitRootVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIKitRootVC.h"

#import "TSAISummaryVC.h"
#import "TSAIChatVC.h"
#import "TSAIInterpreterVC.h"
#import "TSAITTSVC.h"
#import "TSAIASRFileVC.h"
#import "TSAIASRDeviceMicVC.h"
#import "TSAITranslateVC.h"

#import "TSAIKitRootCapability.h"
#import "TSAIKitRootCapabilityCell.h"
#import "TSAIKitRootHeroView.h"
#import "TSAIKitRootSectionHeaderView.h"

typedef NS_ENUM(NSInteger, TSAIKitSection) {
    TSAIKitSectionAssistant = 0,
    TSAIKitSectionInterpreter,
    TSAIKitSectionSpeech,
    TSAIKitSectionTranslate,
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

    NSArray<TSAIKitRootCapability *> *assistantItems = @[
        [TSAIKitRootCapability capabilityWithTitle:@"Text Summary"
                                          subtitle:@"流式文本总结"
                                         tintColor:assistantTint
                                          iconType:TSAIKitRootCapabilityIconSummary
                                        widthStyle:TSAIKitRootCapabilityWidthHalf
                                           vcClass:[TSAISummaryVC class]],
        [TSAIKitRootCapability capabilityWithTitle:@"Voice Chat"
                                          subtitle:@"端到端语音对话长会话"
                                         tintColor:assistantTint
                                          iconType:TSAIKitRootCapabilityIconVoiceChat
                                        widthStyle:TSAIKitRootCapabilityWidthHalf
                                           vcClass:[TSAIChatVC class]],
    ];

    NSArray<TSAIKitRootCapability *> *interpreterItems = @[
        [TSAIKitRootCapability capabilityWithTitle:@"Simultaneous Interpretation"
                                          subtitle:@"同声传译 · ASR → MT → TTS"
                                         tintColor:interpreterTint
                                          iconType:TSAIKitRootCapabilityIconInterpreter
                                        widthStyle:TSAIKitRootCapabilityWidthFull
                                           vcClass:[TSAIInterpreterVC class]],
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
    ];

    return @[assistantItems, interpreterItems, speechItems, translateItems];
}

/// section 标题
- (NSString *)titleForSection:(TSAIKitSection)section {
    switch (section) {
        case TSAIKitSectionAssistant:   return @"Assistant";
        case TSAIKitSectionInterpreter: return @"Interpreter";
        case TSAIKitSectionSpeech:      return @"Speech";
        case TSAIKitSectionTranslate:   return @"Translate";
        default: return @"";
    }
}

/// section 协议名
- (NSString *)protocolNameForSection:(TSAIKitSection)section {
    switch (section) {
        case TSAIKitSectionAssistant:   return @"TSAIAssistantInterface";
        case TSAIKitSectionInterpreter: return @"TSAIInterpreterInterface";
        case TSAIKitSectionSpeech:      return @"TSAISpeechInterface";
        case TSAIKitSectionTranslate:   return @"TSAITranslateInterface";
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
    UIViewController *vc = [[vcClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 私有方法 - Hero 回调

- (void)onHeroPrimaryTap {
    [self pushCapabilityClass:[TSAIChatVC class]];
}

- (void)onHeroSecondaryTap {
    [self pushCapabilityClass:[TSAIInterpreterVC class]];
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
