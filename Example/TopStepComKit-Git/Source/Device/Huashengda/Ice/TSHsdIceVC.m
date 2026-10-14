//
//  TSHsdIceVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdIceVC.h"

@interface TSHsdIceVC ()
@property (nonatomic, strong) NSMutableArray<NSString *> *labels;
@property (nonatomic, strong) TSHsdWatchPreview *preview;
@property (nonatomic, strong) NSMutableArray<TSHsdFieldView *> *fields;
@end

@implementation TSHsdIceVC

#pragma mark - 生命周期

- (void)initData {
    [super initData];
    self.title = TSLocalizedString(@"hsd.ice");
    self.hue = [TSHsdDisplay hueIce];
    self.usesDock = YES;
    self.showsReloadButton = NO;
    self.chips = @[@"bit28", TSLocalizedString(@"hsd.ice.chip")];
    NSArray<NSString *> *cached = [TSHsdLocalCache iceLabels];
    self.labels = [NSMutableArray array];
    for (NSUInteger i = 0; i < TSHsdIceLabelMaxCount; i++) {
        [self.labels addObject:cached.count > i ? cached[i] : @""];
    }
    self.fields = [NSMutableArray array];
}

- (void)setupViews {
    [super setupViews];
    self.dock.offlineText = TSLocalizedString(@"hsd.dock.offline_send");
}

- (void)reload {
    // 只写能力：没有读取指令
}

#pragma mark - 保存条（只写）

- (NSArray<NSString *> *)ts_nonEmptyLabels {
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    for (NSString *label in self.labels) {
        NSString *trimmed = [label stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmed.length) { [result addObject:label]; }
    }
    return result;
}

- (BOOL)ts_anyOverLimit {
    for (NSString *label in self.labels) {
        if ([TSHsdDisplay utf8Length:label] > TSHsdIceLabelMaxBytes) { return YES; }
    }
    return NO;
}

- (TSHsdDockState)dockState {
    if (self.isSaving) { return TSHsdDockStateSaving; }
    if (!self.connected) { return TSHsdDockStateOffline; }
    return TSHsdDockStateWriteOnly;
}

- (NSString *)dockButtonTitle {
    NSUInteger n = [self ts_nonEmptyLabels].count;
    return n ? [NSString stringWithFormat:TSLocalizedString(@"hsd.dock.send_format"), (unsigned long)n] : TSLocalizedString(@"hsd.ice.need_one");
}

- (nullable NSString *)dockSmall {
    NSDate *sent = [TSHsdLocalCache iceSentDate];
    return sent ? [NSString stringWithFormat:TSLocalizedString(@"hsd.ice.last_sent_resend_format"), [TSHsdDisplay clockString:sent]] : TSLocalizedString(@"hsd.dock.never_sent");
}

- (void)ts_refreshValidity {
    self.invalid = ([self ts_nonEmptyLabels].count == 0) || [self ts_anyOverLimit];
}

#pragma mark - 发送

- (void)save {
    if (!self.hsd) { [self toast:TSLocalizedString(@"hsd.error.not_support")]; return; }
    NSArray<NSString *> *labels = [self ts_nonEmptyLabels];
    if (!labels.count || [self ts_anyOverLimit]) { return; }
    self.saving = YES;
    TSHsdCallLogEntry *entry = [self beginCall:@"huashengda.setIceLabels:completion:" params:[NSString stringWithFormat:@"labels=%lu", (unsigned long)labels.count]];
    __weak typeof(self) weakSelf = self;
    [self.hsd setIceLabels:labels completion:^(BOOL isSuccess, NSError *error) {
        [weakSelf onMain:^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            self.saving = NO;
            if (!isSuccess) {
                [self finishCall:entry success:NO error:error result:nil];
                [self alertError:error title:TSLocalizedString(@"hsd.send.failed")];
                return;
            }
            [self finishCall:entry success:YES error:nil result:nil];
            [TSHsdLocalCache saveIceLabels:labels];
            self.dirty = NO;
            [self render];
            [self toast:[NSString stringWithFormat:TSLocalizedString(@"hsd.ice.sent_format"), (unsigned long)labels.count]];
        }];
    }];
}

#pragma mark - 积木

- (void)ts_updatePreview {
    self.preview.hue = self.hue;
    self.preview.topLeft = @"9:41";
    self.preview.topRight = @"ICE";
    self.preview.topRightHighlighted = YES;
    self.preview.linesPlaceholder = TSLocalizedString(@"hsd.ice.watch_placeholder");
    self.preview.lines = [self ts_nonEmptyLabels];
}

- (NSArray<UIView *> *)buildBlocks {
    __weak typeof(self) weakSelf = self;
    if (!self.preview) { self.preview = [[TSHsdWatchPreview alloc] init]; }
    [self ts_updatePreview];
    [self ts_refreshValidity];

    NSArray<NSString *> *placeholders = @[TSLocalizedString(@"hsd.ice.ph1"), TSLocalizedString(@"hsd.ice.ph2"), TSLocalizedString(@"hsd.ice.ph3")];
    NSMutableArray<UIView *> *rows = [NSMutableArray arrayWithObject:self.preview];
    [self.fields removeAllObjects];
    for (NSUInteger i = 0; i < TSHsdIceLabelMaxCount; i++) {
        TSHsdFieldView *field = [self fieldWithLabel:[NSString stringWithFormat:TSLocalizedString(@"hsd.ice.label_format"), (unsigned long)(i + 1)]
                                                text:self.labels[i] maxBytes:TSHsdIceLabelMaxBytes
                                         placeholder:[NSString stringWithFormat:TSLocalizedString(@"hsd.ice.ph_format"), placeholders.count > i ? placeholders[i] : @""]
                                            onChange:^(NSString *text) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) { return; }
            self.labels[i] = text ?: @"";
            self.dirty = YES;
            [self ts_updatePreview];
            [self ts_refreshValidity];
            [self refreshDock];
        }];
        [self.fields addObject:field];
        [rows addObject:field];
    }
    NSDate *sentAt = [TSHsdLocalCache iceSentDate];
    NSString *bannerText = sentAt
        ? [NSString stringWithFormat:TSLocalizedString(@"hsd.write_only.banner_sent_format"), [TSHsdDisplay fullDateString:sentAt]]
        : TSLocalizedString(@"hsd.write_only.banner_never");
    return @[[self card:rows], [self banner:bannerText warn:NO], [self foot:TSLocalizedString(@"hsd.ice.foot")]];
}

@end
