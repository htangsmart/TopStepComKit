//
//  TSAIConversationTranslationUI.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/10/13.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIConversationTranslationUI.h"

#import <TopStepComKit/TopStepComKit.h>

#import "TSAIInterpreterTheme.h"
#import "TSRootVC.h"

@implementation TSAIConversationTranslationUI

#pragma mark - 命名

+ (NSString *)nameForEndpoint:(TSAIConversationEndpoint)endpoint {
    switch (endpoint) {
        case TSAIConversationEndpointPhone: return TSLocalizedString(@"ai_conversation.device_phone");
        case TSAIConversationEndpointEarbuds: return TSLocalizedString(@"ai_conversation.device_earbuds");
        case TSAIConversationEndpointCase: return TSLocalizedString(@"ai_conversation.device_case");
        default: return TSLocalizedString(@"ai_conversation.endpoint_auto");
    }
}

+ (NSString *)symbolForEndpoint:(TSAIConversationEndpoint)endpoint {
    switch (endpoint) {
        case TSAIConversationEndpointEarbuds: return @"headphones";
        case TSAIConversationEndpointCase: return @"case";
        case TSAIConversationEndpointPhone:
        default: return @"iphone";
    }
}

+ (NSString *)titleForMode:(TSAIConversationTranslationMode)mode {
    switch (mode) {
        case TSAIConversationTranslationModeFaceToFace: return TSLocalizedString(@"ai_conversation.preset_face");
        case TSAIConversationTranslationModePrivate: return TSLocalizedString(@"ai_conversation.preset_private");
        case TSAIConversationTranslationModePortable: return TSLocalizedString(@"ai_conversation.preset_portable");
        default: return TSLocalizedString(@"ai_conversation.preset_custom");
    }
}

+ (NSString *)scenarioForMode:(TSAIConversationTranslationMode)mode {
    switch (mode) {
        case TSAIConversationTranslationModeFaceToFace: return TSLocalizedString(@"ai_conversation.preset_face_scene");
        case TSAIConversationTranslationModePrivate: return TSLocalizedString(@"ai_conversation.preset_private_scene");
        case TSAIConversationTranslationModePortable: return TSLocalizedString(@"ai_conversation.preset_portable_scene");
        default: return @"";
    }
}

+ (NSString *)descriptionForMode:(TSAIConversationTranslationMode)mode {
    switch (mode) {
        case TSAIConversationTranslationModeFaceToFace: return TSLocalizedString(@"ai_conversation.preset_face_desc");
        case TSAIConversationTranslationModePrivate: return TSLocalizedString(@"ai_conversation.preset_private_desc");
        case TSAIConversationTranslationModePortable: return TSLocalizedString(@"ai_conversation.preset_portable_desc");
        default: return TSLocalizedString(@"ai_conversation.preset_custom_desc");
    }
}

+ (NSString *)displayNameForEndReason:(TSAIConversationTranslationEndReason)reason {
    switch (reason) {
        case TSAIConversationTranslationEndReasonUserExitApp:
            return TSLocalizedString(@"ai_conversation.end_reason_user_exit");
        case TSAIConversationTranslationEndReasonUserExitDevice:
            return TSLocalizedString(@"ai_conversation.end_reason_device_exit");
        case TSAIConversationTranslationEndReasonDeviceDisconnected:
            return TSLocalizedString(@"ai_conversation.device_disconnected");
        case TSAIConversationTranslationEndReasonDeviceLowBattery:
            return TSLocalizedString(@"ai_conversation.end_reason_low_battery");
        case TSAIConversationTranslationEndReasonIncomingCall:
            return TSLocalizedString(@"ai_conversation.end_reason_incoming_call");
        case TSAIConversationTranslationEndReasonNetworkError:
            return TSLocalizedString(@"ai_conversation.network_error");
        case TSAIConversationTranslationEndReasonAudioInterrupted:
            return TSLocalizedString(@"ai_conversation.end_reason_audio_interrupted");
        case TSAIConversationTranslationEndReasonContextInactive:
            return TSLocalizedString(@"ai_conversation.end_reason_context_inactive");
        case TSAIConversationTranslationEndReasonFailure:
        default:
            return TSLocalizedString(@"ai_conversation.end_reason_failure");
    }
}

#pragma mark - 预设

+ (NSArray<NSNumber *> *)presetEndpointsForMode:(TSAIConversationTranslationMode)mode {
    switch (mode) {
        case TSAIConversationTranslationModeFaceToFace:
            return @[ @(TSAIConversationEndpointPhone), @(TSAIConversationEndpointPhone),
                      @(TSAIConversationEndpointCase), @(TSAIConversationEndpointCase) ];
        case TSAIConversationTranslationModePrivate:
            return @[ @(TSAIConversationEndpointEarbuds), @(TSAIConversationEndpointEarbuds),
                      @(TSAIConversationEndpointCase), @(TSAIConversationEndpointCase) ];
        case TSAIConversationTranslationModePortable:
            return @[ @(TSAIConversationEndpointEarbuds), @(TSAIConversationEndpointEarbuds),
                      @(TSAIConversationEndpointPhone), @(TSAIConversationEndpointPhone) ];
        default:
            return @[];
    }
}

/// 配置解析后的四个端点，顺序同 presetEndpointsForMode:
+ (NSArray<NSNumber *> *)resolvedEndpointsOfConfig:(TSAIConversationTranslationConfig *)config {
    return @[ @([config captureEndpointForParticipant:TSAIConversationParticipantSelf]),
              @([config playbackEndpointForParticipant:TSAIConversationParticipantSelf]),
              @([config captureEndpointForParticipant:TSAIConversationParticipantPeer]),
              @([config playbackEndpointForParticipant:TSAIConversationParticipantPeer]) ];
}

+ (TSAIConversationTranslationMode)presetMatchingConfig:(TSAIConversationTranslationConfig *)config {
    NSArray<NSNumber *> *resolved = [self resolvedEndpointsOfConfig:config];
    for (NSNumber *boxed in @[ @(TSAIConversationTranslationModeFaceToFace),
                               @(TSAIConversationTranslationModePrivate),
                               @(TSAIConversationTranslationModePortable) ]) {
        TSAIConversationTranslationMode mode = (TSAIConversationTranslationMode)boxed.integerValue;
        if ([[self presetEndpointsForMode:mode] isEqualToArray:resolved]) return mode;
    }
    return TSAIConversationTranslationModeInvalid;
}

+ (void)applyPreset:(TSAIConversationTranslationMode)mode toConfig:(TSAIConversationTranslationConfig *)config {
    NSArray<NSNumber *> *endpoints = [self presetEndpointsForMode:mode];
    if (endpoints.count != 4) return;
    config.mode = mode;
    config.selfCaptureEndpoint = (TSAIConversationEndpoint)endpoints[0].integerValue;
    config.selfPlaybackEndpoint = (TSAIConversationEndpoint)endpoints[1].integerValue;
    config.peerCaptureEndpoint = (TSAIConversationEndpoint)endpoints[2].integerValue;
    config.peerPlaybackEndpoint = (TSAIConversationEndpoint)endpoints[3].integerValue;
}

+ (TSAIConversationTranslationMode)deviceModeForConfig:(TSAIConversationTranslationConfig *)config {
    TSAIConversationTranslationMode preset = [self presetMatchingConfig:config];
    if (preset != TSAIConversationTranslationModeInvalid) return preset;
    TSAIConversationEndpoint selfCapture = [config captureEndpointForParticipant:TSAIConversationParticipantSelf];
    TSAIConversationEndpoint peerCapture = [config captureEndpointForParticipant:TSAIConversationParticipantPeer];
    TSAIConversationEndpoint other = TSAIConversationEndpointAutomatic;
    if (peerCapture == TSAIConversationEndpointCase) {
        other = selfCapture;
    } else if (selfCapture == TSAIConversationEndpointCase) {
        other = peerCapture;
    } else if (![config caseParticipates]) {
        return TSAIConversationTranslationModePortable;
    } else {
        // 仓只做播报端：按对方的收音设备归类
        other = selfCapture;
    }
    return other == TSAIConversationEndpointEarbuds
        ? TSAIConversationTranslationModePrivate
        : TSAIConversationTranslationModeFaceToFace;
}

#pragma mark - 导航

+ (BOOL)isCustomBarPage:(UIViewController *)viewController {
    if (viewController == nil) return NO;
    NSString *name = NSStringFromClass([viewController class]);
    return [name isEqualToString:@"TSAIConversationTranslationSetupVC"]
        || [name isEqualToString:@"TSAIConversationTranslationVC"]
        || [name isEqualToString:@"TSAIConversationTranslationReportVC"]
        || [TSAIInterpreterTheme isInterpreterPage:viewController];
}

@end

#pragma mark - 设备格（图标在上、名称在下）

/// 分段选择器里的单个设备格
@interface TSAIConversationDeviceTile : UIControl

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation TSAIConversationDeviceTile

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 11.0;
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeCenter;
        _iconView.userInteractionEnabled = NO;
        [self addSubview:_iconView];
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [TSAIInterpreterTheme fontOfSize:10.0 cssWeight:600];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.userInteractionEnabled = NO;
        [self addSubview:_nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat iconH = 18.0;
    CGFloat nameH = 12.0;
    CGFloat top = (h - iconH - 2.0 - nameH) / 2.0;
    self.iconView.frame = CGRectMake(0, top, w, iconH);
    self.nameLabel.frame = CGRectMake(0, top + iconH + 2.0, w, nameH);
}

@end

#pragma mark - 三设备分段选择器

@interface TSAIConversationDeviceSegment ()

/// 三个格子，顺序 手机 / 耳机 / 充电仓
@property (nonatomic, copy) NSArray<TSAIConversationDeviceTile *> *tiles;
/// 各端点可用性
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *availability;

@end

@implementation TSAIConversationDeviceSegment

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TSAIInterpreterTheme paper];
        self.layer.cornerRadius = 14.0;
        _tint = [TSAIInterpreterTheme cobalt];
        _selectedEndpoint = TSAIConversationEndpointPhone;
        _availability = [NSMutableDictionary dictionary];
        NSMutableArray<TSAIConversationDeviceTile *> *tiles = [NSMutableArray arrayWithCapacity:3];
        UIImageSymbolConfiguration *cfg =
            [UIImageSymbolConfiguration configurationWithPointSize:15.0 weight:UIImageSymbolWeightMedium];
        for (NSNumber *boxed in [self endpointOrder]) {
            TSAIConversationEndpoint endpoint = (TSAIConversationEndpoint)boxed.integerValue;
            TSAIConversationDeviceTile *tile = [[TSAIConversationDeviceTile alloc] init];
            tile.tag = endpoint;
            tile.nameLabel.text = [TSAIConversationTranslationUI nameForEndpoint:endpoint];
            tile.iconView.image = [[UIImage systemImageNamed:[TSAIConversationTranslationUI symbolForEndpoint:endpoint]
                                             withConfiguration:cfg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [tile addTarget:self action:@selector(onTileTap:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:tile];
            [tiles addObject:tile];
        }
        _tiles = tiles;
        [self refresh];
    }
    return self;
}

- (NSArray<NSNumber *> *)endpointOrder {
    return @[ @(TSAIConversationEndpointPhone), @(TSAIConversationEndpointEarbuds), @(TSAIConversationEndpointCase) ];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat pad = 4.0;
    CGFloat gap = 4.0;
    CGFloat count = self.tiles.count;
    CGFloat tileW = floor((CGRectGetWidth(self.bounds) - pad * 2 - gap * (count - 1)) / count);
    CGFloat tileH = CGRectGetHeight(self.bounds) - pad * 2;
    [self.tiles enumerateObjectsUsingBlock:^(TSAIConversationDeviceTile *tile, NSUInteger idx, BOOL *stop) {
        tile.frame = CGRectMake(pad + idx * (tileW + gap), pad, tileW, tileH);
    }];
}

- (void)setTint:(UIColor *)tint {
    _tint = tint;
    [self refresh];
}

- (void)setSelectedEndpoint:(TSAIConversationEndpoint)selectedEndpoint {
    _selectedEndpoint = selectedEndpoint;
    [self refresh];
}

- (void)setEndpoint:(TSAIConversationEndpoint)endpoint available:(BOOL)available {
    self.availability[@(endpoint)] = @(available);
    [self refresh];
}

- (BOOL)isAvailable:(TSAIConversationEndpoint)endpoint {
    NSNumber *flag = self.availability[@(endpoint)];
    return flag == nil ? YES : flag.boolValue;
}

- (void)refresh {
    for (TSAIConversationDeviceTile *tile in self.tiles) {
        TSAIConversationEndpoint endpoint = (TSAIConversationEndpoint)tile.tag;
        BOOL on = endpoint == self.selectedEndpoint;
        BOOL available = [self isAvailable:endpoint];
        tile.backgroundColor = on ? self.tint : UIColor.clearColor;
        UIColor *fg = on ? UIColor.whiteColor : [TSAIInterpreterTheme muted];
        tile.iconView.tintColor = fg;
        tile.nameLabel.textColor = fg;
        tile.alpha = available ? 1.0 : 0.3;
        tile.layer.shadowColor = self.tint.CGColor;
        tile.layer.shadowOpacity = on ? 0.35 : 0.0;
        tile.layer.shadowRadius = 4.0;
        tile.layer.shadowOffset = CGSizeMake(0, 2.0);
    }
}

- (void)onTileTap:(TSAIConversationDeviceTile *)tile {
    if (self.onTap) self.onTap((TSAIConversationEndpoint)tile.tag);
}

@end

#pragma mark - 预设卡

@interface TSAIConversationPresetCard ()

/// 我方设备图标块（钴蓝）
@property (nonatomic, strong) UIView *selfTile;
@property (nonatomic, strong) UIImageView *selfIcon;
/// 对方设备图标块（翠绿）
@property (nonatomic, strong) UIView *peerTile;
@property (nonatomic, strong) UIImageView *peerIcon;
/// 标题 / 场景
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *sceneLabel;
/// 右上角选中标记
@property (nonatomic, strong) UIImageView *checkView;

@end

@implementation TSAIConversationPresetCard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [TSAIInterpreterTheme panel];
        self.layer.cornerRadius = 18.0;
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = UIColor.clearColor.CGColor;
        _available = YES;
        _selfTile = [self tileWithColor:[TSAIInterpreterTheme cobalt]];
        _selfIcon = [self iconView];
        [_selfTile addSubview:_selfIcon];
        _peerTile = [self tileWithColor:[TSAIInterpreterTheme jade]];
        _peerIcon = [self iconView];
        [_peerTile addSubview:_peerIcon];
        [self addSubview:_peerTile];
        [self addSubview:_selfTile];
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [TSAIInterpreterTheme fontOfSize:13.0 cssWeight:700];
        _titleLabel.textColor = [TSAIInterpreterTheme ink];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.8;
        [self addSubview:_titleLabel];
        _sceneLabel = [[UILabel alloc] init];
        _sceneLabel.font = [TSAIInterpreterTheme fontOfSize:11.0 cssWeight:400];
        _sceneLabel.textColor = [TSAIInterpreterTheme muted];
        _sceneLabel.textAlignment = NSTextAlignmentCenter;
        _sceneLabel.adjustsFontSizeToFitWidth = YES;
        _sceneLabel.minimumScaleFactor = 0.8;
        [self addSubview:_sceneLabel];
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:9.0 weight:UIImageSymbolWeightBold];
        _checkView = [[UIImageView alloc] initWithImage:[[UIImage systemImageNamed:@"checkmark" withConfiguration:cfg]
                                                          imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _checkView.tintColor = UIColor.whiteColor;
        _checkView.backgroundColor = [TSAIInterpreterTheme ink];
        _checkView.contentMode = UIViewContentModeCenter;
        _checkView.layer.cornerRadius = 9.0;
        _checkView.hidden = YES;
        [self addSubview:_checkView];
        for (UIView *sub in self.subviews) sub.userInteractionEnabled = NO;
    }
    return self;
}

- (UIView *)tileWithColor:(UIColor *)color {
    UIView *tile = [[UIView alloc] init];
    tile.backgroundColor = color;
    tile.layer.cornerRadius = 12.0;
    tile.layer.borderWidth = 2.0;
    tile.layer.borderColor = [TSAIInterpreterTheme panel].CGColor;
    return tile;
}

- (UIImageView *)iconView {
    UIImageView *icon = [[UIImageView alloc] init];
    icon.tintColor = UIColor.whiteColor;
    icon.contentMode = UIViewContentModeCenter;
    return icon;
}

- (void)setMode:(TSAIConversationTranslationMode)mode {
    _mode = mode;
    NSArray<NSNumber *> *endpoints = [TSAIConversationTranslationUI presetEndpointsForMode:mode];
    UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:14.0 weight:UIImageSymbolWeightMedium];
    if (endpoints.count == 4) {
        self.selfIcon.image = [[UIImage systemImageNamed:[TSAIConversationTranslationUI symbolForEndpoint:(TSAIConversationEndpoint)endpoints[0].integerValue]
                                       withConfiguration:cfg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.peerIcon.image = [[UIImage systemImageNamed:[TSAIConversationTranslationUI symbolForEndpoint:(TSAIConversationEndpoint)endpoints[2].integerValue]
                                       withConfiguration:cfg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    self.titleLabel.text = [TSAIConversationTranslationUI titleForMode:mode];
    self.sceneLabel.text = [TSAIConversationTranslationUI scenarioForMode:mode];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.borderColor = selected ? [TSAIInterpreterTheme ink].CGColor : UIColor.clearColor.CGColor;
    self.checkView.hidden = !selected;
}

- (void)setAvailable:(BOOL)available {
    _available = available;
    self.alpha = available ? 1.0 : 0.45;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    // padding 12 8 10；图标块 34，重叠 8；gap 8
    CGFloat y = 12.0;
    CGFloat pairW = 34.0 + 34.0 - 8.0;
    CGFloat x = (width - pairW) / 2.0;
    self.selfTile.frame = CGRectMake(x, y, 34.0, 34.0);
    self.peerTile.frame = CGRectMake(x + 34.0 - 8.0, y, 34.0, 34.0);
    self.selfIcon.frame = self.selfTile.bounds;
    self.peerIcon.frame = self.peerTile.bounds;
    y += 34.0 + 8.0;
    self.titleLabel.frame = CGRectMake(6.0, y, width - 12.0, 16.0);
    y += 16.0 + 2.0;
    self.sceneLabel.frame = CGRectMake(6.0, y, width - 12.0, 15.0);
    self.checkView.frame = CGRectMake(width - 8.0 - 18.0, 8.0, 18.0, 18.0);
}

@end
