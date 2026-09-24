//
//  TSAIInterpreterSettingsVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/5/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSAIInterpreterSettingsVC.h"

#import <TopStepAIKit/TopStepAIKit.h>

#import "TSAIInterpreterFormatter.h"
#import "TSAILogView.h"
#import "TSRootVC.h"

@interface TSAIInterpreterSettingsVC ()

#pragma mark - 视图
/// 会话信息卡片
@property (nonatomic, strong) UIView *infoCardView;
/// 会话信息（多行）
@property (nonatomic, strong) UILabel *infoLabel;
/// 「LOGS / EVENTS」标题
@property (nonatomic, strong) UILabel *logsHeaderLabel;
/// 清空日志按钮
@property (nonatomic, strong) UIButton *logsClearButton;
/// 外部传入并 reparent 的日志视图
@property (nonatomic, strong) TSAILogView *logView;

#pragma mark - 状态
/// 当前会话请求
@property (nonatomic, copy, nullable) TSAIInterpretationRequest *request;

@end

@implementation TSAIInterpreterSettingsVC

#pragma mark - 生命周期

- (instancetype)initWithRequest:(nullable TSAIInterpretationRequest *)request
                        logView:(TSAILogView *)logView {
    self = [super init];
    if (self) {
        _request = [request copy];
        _logView = logView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.title = TSLocalizedString(@"ai_interpreter.sheet_settings_title");
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                       target:self
                                                       action:@selector(onDoneTap)];
    [self.view addSubview:self.infoCardView];
    [self.infoCardView addSubview:self.infoLabel];
    [self.view addSubview:self.logsHeaderLabel];
    [self.view addSubview:self.logsClearButton];
    if (self.logView) {
        [self.view addSubview:self.logView];
    }
    [self refreshInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 下滑关闭被取消后重新出现时，把归还过的日志视图加回来。
    if (self.logView != nil && self.logView.superview != self.view) {
        [self.view addSubview:self.logView];
        [self.view setNeedsLayout];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat sideInset = 20.0;
    CGFloat contentWidth = width - sideInset * 2;
    CGFloat y = self.view.safeAreaInsets.top + 12.0;

    CGSize infoSize = [self.infoLabel sizeThatFits:CGSizeMake(contentWidth - 32.0, CGFLOAT_MAX)];
    self.infoCardView.frame = CGRectMake(sideInset, y, contentWidth, infoSize.height + 28.0);
    self.infoLabel.frame = CGRectMake(16.0, 14.0, contentWidth - 32.0, infoSize.height);
    y = CGRectGetMaxY(self.infoCardView.frame) + 22.0;

    CGFloat logsHeaderHeight = 18.0;
    self.logsHeaderLabel.frame = CGRectMake(sideInset + 4.0, y, contentWidth - 68.0, logsHeaderHeight);
    self.logsClearButton.frame = CGRectMake(width - sideInset - 60.0, y - 4.0, 60.0, logsHeaderHeight + 8.0);
    y += logsHeaderHeight + 8.0;

    CGFloat logBottom = height - self.view.safeAreaInsets.bottom - 16.0;
    self.logView.frame = CGRectMake(sideInset, y, contentWidth, MAX(100.0, logBottom - y));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.logView removeFromSuperview];
}

#pragma mark - 私有方法

/// 用请求刷新会话信息文案
- (void)refreshInfo {
    TSAIInterpretationRequest *request = self.request;
    if (request == nil) {
        self.infoLabel.text = TSLocalizedString(@"ai_interpreter.status_idle");
        return;
    }
    NSString *pickup = TSLocalizedString(@"ai_interpreter.lang.unset");
    switch (request.pickup) {
        case TSAIInterpretationPickupPhone: pickup = TSLocalizedString(@"ai_interpreter.setup_pickup_phone"); break;
        case TSAIInterpretationPickupEarbuds: pickup = TSLocalizedString(@"ai_interpreter.setup_pickup_earbuds"); break;
        case TSAIInterpretationPickupChargingCase: pickup = TSLocalizedString(@"ai_interpreter.setup_pickup_case"); break;
        default: break;
    }
    NSString *speaker = request.speakerId.length > 0
        ? request.speakerId
        : TSLocalizedString(@"ai_interpreter.speaker_default");
    self.infoLabel.text = [NSString stringWithFormat:@"%@: %@\n%@: %@ → %@\n%@: %@\n%@: %@",
                           TSLocalizedString(@"ai_interpreter.setting_pickup"), pickup,
                           TSLocalizedString(@"ai_interpreter.setup_section_language"),
                           [TSAIInterpreterFormatter displayNameForLanguage:request.sourceLanguage],
                           [TSAIInterpreterFormatter displayNameForLanguage:request.targetLanguage],
                           TSLocalizedString(@"ai_interpreter.setting_tts"),
                           request.enableVoiceOutput ? @"On" : @"Off",
                           TSLocalizedString(@"ai_interpreter.setting_speaker"), speaker];
    [self.view setNeedsLayout];
}

- (void)onLogsClearTap {
    [self.logView clear];
}

- (void)onDoneTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 属性（懒加载）

- (UIView *)infoCardView {
    if (!_infoCardView) {
        _infoCardView = [[UIView alloc] init];
        _infoCardView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        _infoCardView.layer.cornerRadius = 14.0;
    }
    return _infoCardView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont monospacedSystemFontOfSize:13.0 weight:UIFontWeightRegular];
        _infoLabel.textColor = [UIColor labelColor];
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
}

- (UILabel *)logsHeaderLabel {
    if (!_logsHeaderLabel) {
        _logsHeaderLabel = [[UILabel alloc] init];
        _logsHeaderLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightSemibold];
        _logsHeaderLabel.textColor = [UIColor secondaryLabelColor];
        _logsHeaderLabel.text = [TSLocalizedString(@"ai_interpreter.setting_logs_header") uppercaseString];
    }
    return _logsHeaderLabel;
}

- (UIButton *)logsClearButton {
    if (!_logsClearButton) {
        _logsClearButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _logsClearButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_logsClearButton setTitle:TSLocalizedString(@"general.clear") forState:UIControlStateNormal];
        [_logsClearButton addTarget:self action:@selector(onLogsClearTap)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    return _logsClearButton;
}

@end
