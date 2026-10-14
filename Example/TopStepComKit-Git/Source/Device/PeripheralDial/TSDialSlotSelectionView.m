//
//  TSDialSlotSelectionView.m
//  TopStepComKit_Example
//
//  Created by Claude on 2026/10/14.
//

#import "TSDialSlotSelectionView.h"

#import <TopStepComKit/TopStepComKit.h>

#import "TSDialEditorAppearance.h"

// 表盘位读取状态
typedef NS_ENUM(NSInteger, TSDialSlotSelectionState) {
    TSDialSlotSelectionStateLoading = 0,
    TSDialSlotSelectionStateFailed,
    TSDialSlotSelectionStateReady,
};

// 未选中任何项（只在不能自动选位时出现）；自动选位使用 TSDialSlotIndexAutomatic
static const NSInteger kTSDialSlotNoSelection = NSIntegerMin;
static const CGFloat kTSDialSlotHeaderHeight = 22;
static const CGFloat kTSDialSlotHeaderGap = 9;
static const CGFloat kTSDialSlotRowGap = 8;
static const CGFloat kTSDialSlotTailGap = 10;
static const CGFloat kTSDialSlotSkeletonHeight = 64;
static const NSTimeInterval kTSDialSlotLoadTimeout = 12;

// 原型色值
static const NSUInteger kTSDialSlotInk = 0x252823;
static const NSUInteger kTSDialSlotMuted = 0x8B9085;
static const NSUInteger kTSDialSlotLine = 0xE7E8E2;
static const NSUInteger kTSDialSlotAccent = 0xF16D43;
static const NSUInteger kTSDialSlotAccentSoft = 0xFFF1EA;

#pragma mark - 尺寸协议

// 按宽度计算高度的内容块
@protocol TSDialSlotSizing <NSObject>
- (CGFloat)heightForWidth:(CGFloat)width;
@end

#pragma mark - TSDialSlotOptionRow

// 单选行：单选圈、图标、标题与标签、说明
@interface TSDialSlotOptionRow : UIControl <TSDialSlotSizing>
// 对应表盘位；TSDialSlotIndexAutomatic 表示「自动」
@property (nonatomic, assign) NSInteger slotIndex;
// 是否选中
@property (nonatomic, assign, getter=isChecked) BOOL checked;
// 单选圈与选中圆点
@property (nonatomic, strong) UIView *radioView;
@property (nonatomic, strong) UIView *radioDot;
// 左侧图标
@property (nonatomic, strong) UIView *iconView;
// 标题、标签与说明
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) NSArray<UILabel *> *tagLabels;
@property (nonatomic, strong) UILabel *subtitleLabel;
// 创建单选行
- (instancetype)initWithTitle:(NSString *)title
                    tagLabels:(NSArray<UILabel *> *)tagLabels
                     subtitle:(NSString *)subtitle
                     iconView:(UIView *)iconView;
@end

@implementation TSDialSlotOptionRow

// 创建单选行，所有子视图不接收触摸，点击统一由行处理
- (instancetype)initWithTitle:(NSString *)title
                    tagLabels:(NSArray<UILabel *> *)tagLabels
                     subtitle:(NSString *)subtitle
                     iconView:(UIView *)iconView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.layer.cornerRadius = 15;
        _radioView = [[UIView alloc] init];
        _radioView.layer.cornerRadius = 10;
        _radioView.layer.borderWidth = 1.5;
        _radioView.backgroundColor = UIColor.whiteColor;
        _radioDot = [[UIView alloc] init];
        _radioDot.layer.cornerRadius = 5;
        _radioDot.backgroundColor = [TSDialEditorAppearance color:kTSDialSlotAccent];
        [_radioView addSubview:_radioDot];
        _iconView = iconView;
        _titleLabel = [TSDialEditorAppearance label:title size:14 color:kTSDialSlotInk];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        _tagLabels = [tagLabels copy];
        _subtitleLabel = [TSDialEditorAppearance label:subtitle size:12 color:kTSDialSlotMuted];
        _subtitleLabel.numberOfLines = 2;
        for (UIView *view in [@[_radioView, _iconView, _titleLabel, _subtitleLabel] arrayByAddingObjectsFromArray:_tagLabels]) {
            view.userInteractionEnabled = NO;
            [self addSubview:view];
        }
        self.isAccessibilityElement = YES;
        NSMutableArray<NSString *> *parts = [NSMutableArray arrayWithObject:title];
        for (UILabel *tag in _tagLabels) {
            [parts addObject:tag.text];
        }
        [parts addObject:subtitle];
        self.accessibilityLabel = [parts componentsJoinedByString:@"，"];
        [self updateAppearance];
    }
    return self;
}

// 文字区左侧起点：内边距 12 + 单选圈 20 + 间距 11 + 图标 40 + 间距 11
- (CGFloat)textLeft {
    return 94;
}

// 说明最多两行，行高随说明行数变化
- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat textWidth = MAX(0, width - [self textLeft] - 12);
    CGFloat subtitleHeight = ceil([self.subtitleLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height);
    return MAX(64, 11 + 20 + 1 + subtitleHeight + 11);
}

// 单选圈和图标垂直居中，标签跟在标题后
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds), height = CGRectGetHeight(self.bounds);
    self.radioView.frame = CGRectMake(12, (height - 20) / 2, 20, 20);
    self.radioDot.frame = CGRectMake(5, 5, 10, 10);
    self.iconView.frame = CGRectMake(43, (height - 40) / 2, 40, 40);
    CGFloat left = [self textLeft], textWidth = MAX(0, width - left - 12);
    CGFloat subtitleHeight = ceil([self.subtitleLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height);
    CGFloat top = (height - 20 - 1 - subtitleHeight) / 2;
    CGFloat titleWidth = MIN(textWidth, ceil([self.titleLabel sizeThatFits:CGSizeMake(textWidth, 20)].width));
    self.titleLabel.frame = CGRectMake(left, top, titleWidth, 20);
    CGFloat tagLeft = left + titleWidth + 6;
    for (UILabel *tag in self.tagLabels) {
        CGFloat tagWidth = ceil([tag sizeThatFits:CGSizeMake(CGFLOAT_MAX, 17)].width) + 12;
        tag.frame = CGRectMake(tagLeft, top + 1.5, MIN(tagWidth, MAX(0, left + textWidth - tagLeft)), 17);
        tagLeft += tagWidth + 6;
    }
    self.subtitleLabel.frame = CGRectMake(left, top + 21, textWidth, subtitleHeight);
}

// 选中状态切换样式
- (void)setChecked:(BOOL)checked {
    _checked = checked;
    [self updateAppearance];
}

// 不可选时整行变淡
- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self updateAppearance];
}

// 按下时轻微变淡
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = !self.enabled ? 0.48 : highlighted ? 0.7 : 1;
}

// 按原型绘制选中与未选中样式，并同步无障碍状态
- (void)updateAppearance {
    BOOL checked = self.checked;
    self.backgroundColor = [TSDialEditorAppearance color:checked ? kTSDialSlotAccentSoft : 0xFFFFFF];
    self.layer.borderWidth = checked ? 1.5 : 1;
    self.layer.borderColor = [TSDialEditorAppearance color:checked ? kTSDialSlotAccent : kTSDialSlotLine].CGColor;
    self.radioView.layer.borderColor = [TSDialEditorAppearance color:checked ? kTSDialSlotAccent : 0xC5C8BE].CGColor;
    self.radioDot.hidden = !checked;
    self.alpha = self.enabled ? 1 : 0.48;
    UIAccessibilityTraits traits = UIAccessibilityTraitButton;
    if (checked) {
        traits |= UIAccessibilityTraitSelected;
    }
    if (!self.enabled) {
        traits |= UIAccessibilityTraitNotEnabled;
    }
    self.accessibilityTraits = traits;
}

@end

#pragma mark - TSDialSlotNoteView

// 提示条：图标、文字和可选的文字按钮
@interface TSDialSlotNoteView : UIView <TSDialSlotSizing>
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong, nullable) UIButton *actionButton;
// 创建提示条
- (instancetype)initWithText:(NSString *)text
                      symbol:(NSString *)symbol
                  background:(NSUInteger)background
                       color:(NSUInteger)color;
// 在文字下方加一个文字按钮
- (void)setActionTitle:(NSString *)title target:(id)target action:(SEL)action;
@end

@implementation TSDialSlotNoteView

// 按传入色值创建提示条
- (instancetype)initWithText:(NSString *)text
                      symbol:(NSString *)symbol
                  background:(NSUInteger)background
                       color:(NSUInteger)color {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [TSDialEditorAppearance color:background];
        self.layer.cornerRadius = 12;
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:13];
        _iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:symbol withConfiguration:config]];
        _iconView.tintColor = [TSDialEditorAppearance color:color];
        _iconView.contentMode = UIViewContentModeCenter;
        _textLabel = [TSDialEditorAppearance label:text size:12 color:color];
        _textLabel.numberOfLines = 0;
        [self addSubview:_iconView];
        [self addSubview:_textLabel];
    }
    return self;
}

// 在文字下方加一个文字按钮
- (void)setActionTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold],
        NSForegroundColorAttributeName: self.textLabel.textColor,
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
    };
    [button setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:attributes]
                      forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.actionButton removeFromSuperview];
    self.actionButton = button;
    [self addSubview:button];
}

// 文字区左侧起点：内边距 12 + 图标 14 + 间距 8
- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat textHeight = ceil([self.textLabel sizeThatFits:CGSizeMake(MAX(0, width - 46), CGFLOAT_MAX)].height);
    return 10 + textHeight + (self.actionButton ? 28 : 0) + 10;
}

// 图标对齐首行文字
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat textWidth = MAX(0, CGRectGetWidth(self.bounds) - 46);
    CGFloat textHeight = ceil([self.textLabel sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height);
    self.iconView.frame = CGRectMake(12, 11, 14, 14);
    self.textLabel.frame = CGRectMake(34, 10, textWidth, textHeight);
    self.actionButton.frame = CGRectMake(34, 10 + textHeight + 2, MIN(textWidth, 120), 26);
}

@end

#pragma mark - TSDialSlotSelectionView

@interface TSDialSlotSelectionView ()
// 读取状态
@property (nonatomic, assign) TSDialSlotSelectionState state;
// 每次 reload 递增，用于丢弃迟到的回调
@property (nonatomic, assign) NSUInteger loadGeneration;
// 已读到、等待补齐名称的表盘位
@property (nonatomic, copy, nullable) NSArray<TSDialSlotModel *> *pendingSlots;
// 可安装的表盘位（按序号升序）
@property (nonatomic, copy) NSArray<TSDialSlotModel *> *installableSlots;
// 不可安装的表盘位数量（内置等）
@property (nonatomic, assign) NSUInteger lockedSlotCount;
// 表盘位序号 → 位上的表盘
@property (nonatomic, copy) NSDictionary<NSNumber *, TSDialModel *> *dialsBySlot;
// 当前选择：TSDialSlotIndexAutomatic、表盘位序号或 kTSDialSlotNoSelection
@property (nonatomic, assign) NSInteger selectedSlotIndex;
// 标题与可安装数量
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *countLabel;
// 列表区内容块（骨架、失败提示或单选行）
@property (nonatomic, copy) NSArray<UIView *> *bodyBlocks;
// 列表下方内容块（覆盖提示、脚注）
@property (nonatomic, copy) NSArray<UIView *> *tailBlocks;
@end

@implementation TSDialSlotSelectionView

#pragma mark - 生命周期

// 初始为读取中，默认自动选位
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _selectedSlotIndex = TSDialSlotIndexAutomatic;
        _installableSlots = @[];
        _dialsBySlot = @{};
        _bodyBlocks = @[];
        _tailBlocks = @[];
        [self addSubview:self.headerLabel];
        [self addSubview:self.countLabel];
    }
    return self;
}

// 按当前宽度排列标题和内容块
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutBlocksForWidth:CGRectGetWidth(self.bounds) apply:YES];
}

#pragma mark - 公开方法

// 由表盘接口的能力判断
+ (BOOL)isSupportedOnCurrentDevice {
    id<TSPeripheralDialInterface> dial = [TopStepComKit sharedInstance].dial;
    return dial != nil && [dial isSupportInstallToSlot];
}

// 先读表盘位，再按需补齐表盘名称；超时按读取失败处理
- (void)reload {
    NSUInteger generation = ++self.loadGeneration;
    self.state = TSDialSlotSelectionStateLoading;
    self.pendingSlots = nil;
    [self rebuildContent];
    id<TSPeripheralDialInterface> dial = [TopStepComKit sharedInstance].dial;
    if (!dial) {
        [self finishWithFailure];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [dial fetchDialSlots:^(NSArray<TSDialSlotModel *> *_Nullable slots, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf didFetchSlots:slots error:error generation:generation];
        });
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTSDialSlotLoadTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || generation != strongSelf.loadGeneration ||
            strongSelf.state != TSDialSlotSelectionStateLoading) {
            return;
        }
        // 表盘位已读到时不因名称读取超时而丢弃，直接展示（名称用表盘 id）
        NSArray<TSDialSlotModel *> *slots = strongSelf.pendingSlots;
        strongSelf.loadGeneration++;
        if (slots) {
            [strongSelf applySlots:slots dials:nil];
        } else {
            [strongSelf finishWithFailure];
        }
    });
}

// 列表区与下方内容块的总高度
- (CGFloat)preferredHeight {
    return [self layoutBlocksForWidth:CGRectGetWidth(self.bounds) apply:NO];
}

// 指定表盘位时写明目标位置
- (NSString *)primaryTitleWithDefault:(NSString *)title {
    if (self.state == TSDialSlotSelectionStateReady && [self hasExplicitSelection]) {
        return [NSString stringWithFormat:@"安装到表盘位 %ld", (long)self.selectedSlotIndex];
    }
    return title;
}

// 读取中不可安装；读不到时交给调用方按自动选位处理；读到后按当前选择判断
- (BOOL)canInstall {
    switch (self.state) {
        case TSDialSlotSelectionStateLoading:
            return NO;
        case TSDialSlotSelectionStateFailed:
            return YES;
        case TSDialSlotSelectionStateReady:
            return [self isSelectionValid:self.selectedSlotIndex] && self.selectedSlotIndex != kTSDialSlotNoSelection;
    }
    return NO;
}

// 自动选位返回 nil
- (TSDialInstallOptions *)selectedOptions {
    if (self.state != TSDialSlotSelectionStateReady || ![self hasExplicitSelection]) {
        return nil;
    }
    return [TSDialInstallOptions optionsWithTargetSlotIndex:self.selectedSlotIndex];
}

// 文件大小变化会影响可选项，已读到表盘位时立即刷新
- (void)setKnownFileBytes:(unsigned long long)knownFileBytes {
    _knownFileBytes = knownFileBytes;
    [self refreshReadyContent];
}

// 屏幕形状决定缩略图外形，已读到表盘位时立即刷新
- (void)setScreen:(TSPeripheralScreen *)screen {
    _screen = screen;
    [self refreshReadyContent];
}

// 被拒绝的表盘位变化会影响可选项，已读到表盘位时立即刷新
- (void)setRejectedSlotIndexes:(NSSet<NSNumber *> *)rejectedSlotIndexes {
    _rejectedSlotIndexes = [rejectedSlotIndexes copy];
    [self refreshReadyContent];
}

// 自动选位可用性变化会影响默认选项，已读到表盘位时立即刷新
- (void)setAutomaticUnavailableReason:(NSString *)automaticUnavailableReason {
    _automaticUnavailableReason = [automaticUnavailableReason copy];
    if (self.state == TSDialSlotSelectionStateFailed) {
        [self rebuildContent];
    } else {
        [self refreshReadyContent];
    }
}

#pragma mark - 私有方法

// 处理表盘位读取结果
- (void)didFetchSlots:(nullable NSArray<TSDialSlotModel *> *)slots
                error:(nullable NSError *)error
           generation:(NSUInteger)generation {
    if (generation != self.loadGeneration || self.state != TSDialSlotSelectionStateLoading) {
        return;
    }
    if (error || !slots) {
        [self finishWithFailure];
        return;
    }
    if (self.knownDials) {
        [self applySlots:slots dials:self.knownDials];
        return;
    }
    self.pendingSlots = slots;
    __weak typeof(self) weakSelf = self;
    [[TopStepComKit sharedInstance].dial fetchAllDials:^(NSArray<TSDialModel *> *_Nullable dials, NSError *_Nullable dialError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || generation != strongSelf.loadGeneration ||
                strongSelf.state != TSDialSlotSelectionStateLoading) {
                return;
            }
            // 名称读取失败不影响选位，只是不显示名称和「正在使用」
            [strongSelf applySlots:slots dials:dialError ? nil : dials];
        });
    }];
}

// 读取失败：提示可直接安装（自动选位）或重新读取
- (void)finishWithFailure {
    self.pendingSlots = nil;
    self.state = TSDialSlotSelectionStateFailed;
    [self rebuildContent];
}

// 整理可安装表盘位与位上表盘，保留仍然有效的选择
- (void)applySlots:(NSArray<TSDialSlotModel *> *)slots dials:(nullable NSArray<TSDialModel *> *)dials {
    NSMutableArray<TSDialSlotModel *> *installable = [NSMutableArray array];
    for (TSDialSlotModel *slot in slots) {
        if (slot.isInstallable) {
            [installable addObject:slot];
        }
    }
    [installable sortUsingComparator:^NSComparisonResult(TSDialSlotModel *first, TSDialSlotModel *second) {
        return [@(first.slotIndex) compare:@(second.slotIndex)];
    }];
    self.installableSlots = installable;
    self.lockedSlotCount = slots.count - installable.count;
    self.dialsBySlot = [self dialsBySlotForSlots:installable dials:dials];
    self.pendingSlots = nil;
    self.state = TSDialSlotSelectionStateReady;
    [self normalizeSelection];
    [self rebuildContent];
}

// 先按位置匹配，再按表盘 id 匹配
- (NSDictionary<NSNumber *, TSDialModel *> *)dialsBySlotForSlots:(NSArray<TSDialSlotModel *> *)slots
                                                           dials:(nullable NSArray<TSDialModel *> *)dials {
    NSMutableDictionary<NSNumber *, TSDialModel *> *result = [NSMutableDictionary dictionary];
    for (TSDialSlotModel *slot in slots) {
        if ([self isSlotEmpty:slot]) {
            continue;
        }
        TSDialModel *match = nil;
        for (TSDialModel *dial in dials) {
            if ((NSInteger)dial.locationIndex == slot.slotIndex && [dial.dialId isEqualToString:slot.dialId]) {
                match = dial;
                break;
            }
        }
        for (TSDialModel *dial in dials) {
            if (match) {
                break;
            }
            if ([dial.dialId isEqualToString:slot.dialId]) {
                match = dial;
            }
        }
        if (match) {
            result[@(slot.slotIndex)] = match;
        }
    }
    return [result copy];
}

// 已读到表盘位时按新条件重新校正选择并刷新
- (void)refreshReadyContent {
    if (self.state != TSDialSlotSelectionStateReady) {
        return;
    }
    [self normalizeSelection];
    [self rebuildContent];
}

// 选择失效时退回默认：可自动选位时选「自动」，否则不选
- (void)normalizeSelection {
    if (self.selectedSlotIndex != kTSDialSlotNoSelection && [self isSelectionValid:self.selectedSlotIndex]) {
        return;
    }
    self.selectedSlotIndex = self.automaticUnavailableReason.length ? kTSDialSlotNoSelection : TSDialSlotIndexAutomatic;
}

// 选择是否可用于安装
- (BOOL)isSelectionValid:(NSInteger)slotIndex {
    if (slotIndex == kTSDialSlotNoSelection) {
        return YES;
    }
    if (slotIndex == TSDialSlotIndexAutomatic) {
        return self.automaticUnavailableReason.length == 0 && [self predictedAutomaticSlot] != nil;
    }
    TSDialSlotModel *slot = [self installableSlotAtIndex:slotIndex];
    return slot != nil && [self isSlotUsable:slot];
}

// 是否指定了具体表盘位
- (BOOL)hasExplicitSelection {
    return self.selectedSlotIndex != TSDialSlotIndexAutomatic && self.selectedSlotIndex != kTSDialSlotNoSelection;
}

// 与 SDK 自动选位一致：按序号找第一个放得下的可安装位（跳过刚被拒绝的位置）
- (nullable TSDialSlotModel *)predictedAutomaticSlot {
    for (TSDialSlotModel *slot in self.installableSlots) {
        if ([self isSlotUsable:slot]) {
            return slot;
        }
    }
    return nil;
}

// 可作为安装目标：有容量、放得下且没有刚被拒绝
- (BOOL)isSlotUsable:(TSDialSlotModel *)slot {
    return slot.spaceSize > 0 && [self slotFitsKnownFile:slot] && ![self isSlotRejected:slot];
}

// 文件大小未知时不按大小拦截；容量为 0 的位置由 isSlotUsable 排除（SDK 不会向其安装）
- (BOOL)slotFitsKnownFile:(TSDialSlotModel *)slot {
    return self.knownFileBytes == 0 || self.knownFileBytes <= slot.spaceSize;
}

// 本轮安装中被设备或 SDK 拒绝过
- (BOOL)isSlotRejected:(TSDialSlotModel *)slot {
    return [self.rejectedSlotIndexes containsObject:@(slot.slotIndex)];
}

// 按序号查找可安装表盘位
- (nullable TSDialSlotModel *)installableSlotAtIndex:(NSInteger)slotIndex {
    for (TSDialSlotModel *slot in self.installableSlots) {
        if (slot.slotIndex == slotIndex) {
            return slot;
        }
    }
    return nil;
}

// 空位：设备标记为空或没有表盘 id
- (BOOL)isSlotEmpty:(TSDialSlotModel *)slot {
    return slot.isEmpty || slot.dialId.length == 0;
}

// 位上表盘名称：优先表盘名，其次「来源表盘 id」
- (NSString *)nameForSlot:(TSDialSlotModel *)slot {
    TSDialModel *dial = self.dialsBySlot[@(slot.slotIndex)];
    if (dial.dialName.length) {
        return dial.dialName;
    }
    if (!dial) {
        return [NSString stringWithFormat:@"表盘 %@", slot.dialId];
    }
    NSString *source = dial.dialType == eTSDialTypeCloud ? @"云端" :
        dial.dialType == eTSDialTypeCustomer ? @"自定义" :
        dial.dialType == eTSDialTypeBuiltIn ? @"内置" : @"";
    return [NSString stringWithFormat:@"%@表盘 %@", source, dial.dialId ?: slot.dialId];
}

// 位上表盘是否正在使用
- (BOOL)isSlotCurrent:(TSDialSlotModel *)slot {
    return self.dialsBySlot[@(slot.slotIndex)].isCurrent;
}

// 字节转 KB 显示；roundUp 用于文件大小，容量向下取整
- (NSString *)kilobytesText:(unsigned long long)bytes roundUp:(BOOL)roundUp {
    unsigned long long kilobytes = roundUp ? (bytes / 1024ULL) + (bytes % 1024ULL ? 1 : 0) : bytes / 1024ULL;
    NSString *number = [NSNumberFormatter localizedStringFromNumber:@(kilobytes)
                                                        numberStyle:NSNumberFormatterDecimalStyle];
    return [number stringByAppendingString:@" KB"];
}

// 按状态重建列表区和下方内容，并通知调用方
- (void)rebuildContent {
    for (UIView *block in [self.bodyBlocks arrayByAddingObjectsFromArray:self.tailBlocks]) {
        [block removeFromSuperview];
    }
    switch (self.state) {
        case TSDialSlotSelectionStateLoading:
            self.bodyBlocks = [self skeletonBlocks];
            break;
        case TSDialSlotSelectionStateFailed:
            self.bodyBlocks = @[[self failureNote]];
            break;
        case TSDialSlotSelectionStateReady:
            self.bodyBlocks = [self optionRows];
            break;
    }
    for (UIView *block in self.bodyBlocks) {
        [self addSubview:block];
    }
    self.countLabel.text = self.state == TSDialSlotSelectionStateReady
        ? [NSString stringWithFormat:@"%lu 个可安装", (unsigned long)self.installableSlots.count] : @"";
    [self rebuildTailAndNotify];
}

// 重建覆盖提示与脚注，然后通知调用方更新高度与按钮
- (void)rebuildTailAndNotify {
    for (UIView *block in self.tailBlocks) {
        [block removeFromSuperview];
    }
    NSMutableArray<UIView *> *tail = [NSMutableArray array];
    if (self.state == TSDialSlotSelectionStateReady) {
        UIView *note = [self replaceNote];
        if (note) {
            [tail addObject:note];
        }
        if (self.lockedSlotCount > 0) {
            NSString *text = [NSString stringWithFormat:@"另有 %lu 个表盘位不可安装（如内置表盘），不会被替换。",
                              (unsigned long)self.lockedSlotCount];
            UILabel *foot = [TSDialEditorAppearance label:text size:11.5 color:kTSDialSlotMuted];
            foot.numberOfLines = 0;
            [tail addObject:foot];
        }
    }
    self.tailBlocks = tail;
    for (UIView *block in tail) {
        [self addSubview:block];
    }
    [self setNeedsLayout];
    if (self.onContentChange) {
        self.onContentChange();
    }
}

// 读取中显示三行骨架
- (NSArray<UIView *> *)skeletonBlocks {
    NSMutableArray<UIView *> *blocks = [NSMutableArray array];
    for (NSInteger index = 0; index < 3; index++) {
        UIView *skeleton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kTSDialSlotSkeletonHeight)];
        skeleton.backgroundColor = [TSDialEditorAppearance color:0xF1F2ED];
        skeleton.layer.cornerRadius = 15;
        skeleton.isAccessibilityElement = index == 0;
        skeleton.accessibilityLabel = @"正在读取表盘位置";
        if (!UIAccessibilityIsReduceMotionEnabled()) {
            [UIView animateWithDuration:0.8 delay:index * 0.15
                                options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                             animations:^{ skeleton.alpha = 0.5; } completion:nil];
        }
        [blocks addObject:skeleton];
    }
    return blocks;
}

// 读取失败提示：可自动选位时允许直接安装
- (UIView *)failureNote {
    NSString *text = self.automaticUnavailableReason.length
        ? @"暂时读不到手表的表盘位置。请重新读取后选择要替换的位置，或先清理表盘。"
        : @"暂时读不到手表的表盘位置，可以直接安装，由 SDK 自动选位。";
    TSDialSlotNoteView *note = [[TSDialSlotNoteView alloc] initWithText:text symbol:@"info.circle"
                                                             background:0xEEF1EA color:0x555C50];
    [note setActionTitle:@"重新读取" target:self action:@selector(reload)];
    return note;
}

// 「自动」行在前，之后是每个可安装表盘位
- (NSArray<UIView *> *)optionRows {
    NSMutableArray<UIView *> *rows = [NSMutableArray arrayWithObject:[self automaticRow]];
    for (TSDialSlotModel *slot in self.installableSlots) {
        [rows addObject:[self rowForSlot:slot]];
    }
    return rows;
}

// 「自动」行：说明预计落到哪个表盘位、是否替换
- (TSDialSlotOptionRow *)automaticRow {
    BOOL unavailable = self.automaticUnavailableReason.length > 0;
    NSArray<UILabel *> *tags = unavailable ? @[] : @[[self tagLabel:@"默认" background:0xFDE9DF color:0xB2491F]];
    NSString *subtitle = unavailable ? self.automaticUnavailableReason : [self automaticSubtitle];
    UIView *icon = [self symbolIcon:@"sparkles" background:0xF0F1EA tint:0x5F6659];
    TSDialSlotOptionRow *row = [[TSDialSlotOptionRow alloc] initWithTitle:@"自动" tagLabels:tags
                                                                 subtitle:subtitle iconView:icon];
    row.slotIndex = TSDialSlotIndexAutomatic;
    row.enabled = [self isSelectionValid:TSDialSlotIndexAutomatic];
    row.checked = self.selectedSlotIndex == TSDialSlotIndexAutomatic;
    [row addTarget:self action:@selector(rowTapped:) forControlEvents:UIControlEventTouchUpInside];
    return row;
}

// 例如：按制作后的大小选择，预计是表盘位 5（空）
- (NSString *)automaticSubtitle {
    TSDialSlotModel *target = [self predictedAutomaticSlot];
    if (!target) {
        return self.installableSlots.count ? @"没有可以安装这个表盘的位置" : @"手表没有可安装的表盘位";
    }
    NSString *lead = self.knownFileBytes > 0
        ? [NSString stringWithFormat:@"预计是第一个放得下的表盘位 %ld", (long)target.slotIndex]
        : [NSString stringWithFormat:@"按制作后的大小选择，预计是表盘位 %ld", (long)target.slotIndex];
    if ([self isSlotEmpty:target]) {
        return [lead stringByAppendingString:@"（空）"];
    }
    if ([self isSlotCurrent:target]) {
        return [lead stringByAppendingString:@"，会替换正在使用的表盘"];
    }
    return [NSString stringWithFormat:@"%@，会替换「%@」", lead, [self nameForSlot:target]];
}

// 表盘位行：放不下时不可选
- (TSDialSlotOptionRow *)rowForSlot:(TSDialSlotModel *)slot {
    BOOL empty = [self isSlotEmpty:slot];
    NSMutableArray<UILabel *> *tags = [NSMutableArray array];
    if (!empty && [self isSlotCurrent:slot]) {
        [tags addObject:[self tagLabel:@"正在使用" background:0xE6F1E8 color:0x3C7F52]];
    }
    if (empty) {
        [tags addObject:[self tagLabel:@"空" background:0xEEF0E8 color:0x5C6356]];
    }
    NSString *capacity = slot.spaceSize > 0
        ? [@"最大 " stringByAppendingString:[self kilobytesText:slot.spaceSize roundUp:NO]] : nil;
    NSString *subtitle = nil;
    if ([self isSlotRejected:slot]) {
        subtitle = @"刚才安装到这里没有成功，请换一个位置";
    } else if (!capacity) {
        subtitle = empty ? @"手表未上报容量，不能安装" : [NSString stringWithFormat:@"%@ · 手表未上报容量，不能安装",
                                                    [self nameForSlot:slot]];
    } else if (![self slotFitsKnownFile:slot]) {
        subtitle = [NSString stringWithFormat:@"放不下：需要 %@，%@",
                    [self kilobytesText:self.knownFileBytes roundUp:YES], capacity];
    } else if (!empty) {
        subtitle = [NSString stringWithFormat:@"%@ · %@", [self nameForSlot:slot], capacity];
    } else {
        subtitle = capacity;
    }
    NSString *title = [NSString stringWithFormat:@"表盘位 %ld", (long)slot.slotIndex];
    TSDialSlotOptionRow *row = [[TSDialSlotOptionRow alloc] initWithTitle:title tagLabels:tags
                                                                 subtitle:subtitle iconView:[self iconForSlot:slot]];
    row.slotIndex = slot.slotIndex;
    row.enabled = [self isSlotUsable:slot];
    row.checked = self.selectedSlotIndex == slot.slotIndex;
    [row addTarget:self action:@selector(rowTapped:) forControlEvents:UIControlEventTouchUpInside];
    return row;
}

// 选中已有表盘的位置时提示会被替换
- (nullable UIView *)replaceNote {
    if (![self hasExplicitSelection]) {
        return nil;
    }
    TSDialSlotModel *slot = [self installableSlotAtIndex:self.selectedSlotIndex];
    if (!slot || [self isSlotEmpty:slot]) {
        return nil;
    }
    NSString *text = [NSString stringWithFormat:@"会替换表盘位 %ld 上的「%@」%@。", (long)slot.slotIndex,
                      [self nameForSlot:slot], [self isSlotCurrent:slot] ? @"，它是正在使用的表盘" : @""];
    return [[TSDialSlotNoteView alloc] initWithText:text symbol:@"exclamationmark.triangle"
                                         background:0xFBF0E6 color:0xB4531F];
}

// 选中一行：更新单选状态与覆盖提示，行本身不重建
- (void)rowTapped:(TSDialSlotOptionRow *)sender {
    if (!sender.enabled || sender.slotIndex == self.selectedSlotIndex) {
        return;
    }
    self.selectedSlotIndex = sender.slotIndex;
    for (UIView *block in self.bodyBlocks) {
        if ([block isKindOfClass:TSDialSlotOptionRow.class]) {
            TSDialSlotOptionRow *row = (TSDialSlotOptionRow *)block;
            row.checked = row.slotIndex == self.selectedSlotIndex;
        }
    }
    [self rebuildTailAndNotify];
}

// 表盘位缩略图：在 40×40 区域内按设备屏幕形状居中；预览图 > 本地缓存 > 占位，空位为同形状虚线框
- (UIView *)iconForSlot:(TSDialSlotModel *)slot {
    CGFloat radius = 0;
    CGSize size = [TSDialEditorAppearance faceSizeForScreen:self.screen inBox:CGSizeMake(40, 40) cornerRadius:&radius];
    CGRect faceFrame = CGRectMake((40 - size.width) / 2, (40 - size.height) / 2, size.width, size.height);
    UIView *face = nil;
    if ([self isSlotEmpty:slot]) {
        face = [[UIView alloc] initWithFrame:faceFrame];
        face.backgroundColor = [TSDialEditorAppearance color:0xF4F5F0];
        CAShapeLayer *dash = [CAShapeLayer layer];
        dash.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(face.bounds, 4, 4)
                                               cornerRadius:MAX(0, radius - 4)].CGPath;
        dash.fillColor = UIColor.clearColor.CGColor;
        dash.strokeColor = [TSDialEditorAppearance color:0xB9BDB1].CGColor;
        dash.lineWidth = 1.5;
        dash.lineDashPattern = @[@3, @3];
        [face.layer addSublayer:dash];
    } else {
        UIImage *preview = [self previewImageForDialId:slot.dialId];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:faceFrame];
        if (preview) {
            imageView.image = preview;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
        } else {
            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:15];
            imageView.image = [UIImage systemImageNamed:@"clock" withConfiguration:config];
            imageView.contentMode = UIViewContentModeCenter;
            imageView.backgroundColor = [TSDialEditorAppearance color:0x3B4740];
            imageView.tintColor = [TSDialEditorAppearance color:0xE9ECE4];
        }
        face = imageView;
    }
    face.layer.cornerRadius = radius;
    face.clipsToBounds = YES;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [container addSubview:face];
    return container;
}

// 调用方提供的预览图优先，其次是安装成功时写入的本地缓存
- (nullable UIImage *)previewImageForDialId:(NSString *)dialId {
    UIImage *image = self.previewImages[dialId];
    if (image || dialId.length == 0) {
        return image;
    }
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
                           stringByAppendingPathComponent:@"dialPreviews"];
    return [UIImage imageWithContentsOfFile:[directory stringByAppendingPathComponent:
                                             [dialId stringByAppendingPathExtension:@"jpg"]]];
}

// 圆形底色 + SF Symbol 图标
- (UIView *)symbolIcon:(NSString *)name background:(NSUInteger)background tint:(NSUInteger)tint {
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:17];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:name withConfiguration:config]];
    icon.contentMode = UIViewContentModeCenter;
    icon.backgroundColor = [TSDialEditorAppearance color:background];
    icon.tintColor = [TSDialEditorAppearance color:tint];
    icon.layer.cornerRadius = 20;
    icon.clipsToBounds = YES;
    return icon;
}

// 圆角小标签
- (UILabel *)tagLabel:(NSString *)text background:(NSUInteger)background color:(NSUInteger)color {
    UILabel *label = [TSDialEditorAppearance label:text size:10.5 color:color];
    label.font = [UIFont systemFontOfSize:10.5 weight:UIFontWeightMedium];
    label.backgroundColor = [TSDialEditorAppearance color:background];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 6;
    label.clipsToBounds = YES;
    return label;
}

// 计算（apply 为 YES 时同时设置）各内容块位置，返回总高度
- (CGFloat)layoutBlocksForWidth:(CGFloat)width apply:(BOOL)apply {
    if (apply) {
        self.headerLabel.frame = CGRectMake(2, 0, width * 0.6, kTSDialSlotHeaderHeight);
        self.countLabel.frame = CGRectMake(width * 0.4, 0, width * 0.6 - 2, kTSDialSlotHeaderHeight);
    }
    CGFloat top = kTSDialSlotHeaderHeight;
    for (NSUInteger index = 0; index < self.bodyBlocks.count; index++) {
        UIView *block = self.bodyBlocks[index];
        top += index == 0 ? kTSDialSlotHeaderGap : kTSDialSlotRowGap;
        CGFloat height = [self heightOfBlock:block width:width];
        if (apply) {
            block.frame = CGRectMake(0, top, width, height);
        }
        top += height;
    }
    for (UIView *block in self.tailBlocks) {
        top += kTSDialSlotTailGap;
        CGFloat inset = [block isKindOfClass:UILabel.class] ? 2 : 0;
        CGFloat height = [self heightOfBlock:block width:width - inset * 2];
        if (apply) {
            block.frame = CGRectMake(inset, top, width - inset * 2, height);
        }
        top += height;
    }
    return ceil(top);
}

// 行与提示按宽度计算，文字按内容计算，骨架使用固定高度
- (CGFloat)heightOfBlock:(UIView *)block width:(CGFloat)width {
    if ([block conformsToProtocol:@protocol(TSDialSlotSizing)]) {
        return [(id<TSDialSlotSizing>)block heightForWidth:width];
    }
    if ([block isKindOfClass:UILabel.class]) {
        return ceil([block sizeThatFits:CGSizeMake(MAX(0, width), CGFLOAT_MAX)].height);
    }
    return CGRectGetHeight(block.bounds);
}

#pragma mark - 属性（懒加载）

// 区块标题
- (UILabel *)headerLabel {
    if (!_headerLabel) {
        _headerLabel = [TSDialEditorAppearance label:@"安装位置" size:14 color:kTSDialSlotInk];
        _headerLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        _headerLabel.accessibilityTraits = UIAccessibilityTraitHeader;
    }
    return _headerLabel;
}

// 可安装数量
- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [TSDialEditorAppearance label:@"" size:12 color:kTSDialSlotMuted];
        _countLabel.textAlignment = NSTextAlignmentRight;
    }
    return _countLabel;
}

@end
