//
//  TSWorkoutPushVC+Layout.m
//  TopStepComKit_Example
//

#import "TSWorkoutPushVC+Internal.h"

@implementation TSWorkoutPushVC (Layout)

#pragma mark - 视图构建

/** 构建运动推送页面 */
- (void)setupViews {
    self.view.backgroundColor = TSColor_Background;
    [self.view addSubview:self.workoutTableView];

    self.deviceCardView = [[UIView alloc] init];
    self.deviceCardView.backgroundColor = TSColor_Card;
    self.deviceCardView.layer.cornerRadius = 14.f;

    self.deviceTitleLabel = [[UILabel alloc] init];
    self.deviceTitleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
    self.deviceTitleLabel.text = @"Fit Watch";
    [self.deviceCardView addSubview:self.deviceTitleLabel];

    self.deviceDetailLabel = [[UILabel alloc] init];
    self.deviceDetailLabel.font = [UIFont systemFontOfSize:13.f];
    self.deviceDetailLabel.textColor = TSColor_TextSecondary;
    self.deviceDetailLabel.text = TSLocalizedString(@"workout_push.loading");
    [self.deviceCardView addSubview:self.deviceDetailLabel];

    self.localFileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.localFileButton setTitle:TSLocalizedString(@"workout_push.local_file") forState:UIControlStateNormal];
    self.localFileButton.titleLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    [self.localFileButton addTarget:self action:@selector(localFileButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.deviceCardView addSubview:self.localFileButton];
    self.workoutTableView.tableHeaderView = self.deviceCardView;

    [self.view addSubview:self.operationOverlay];
    [self.operationOverlay addSubview:self.operationCardView];
    [self.operationCardView addSubview:self.operationTitleLabel];
    [self.operationCardView addSubview:self.operationDetailLabel];
    [self.operationCardView addSubview:self.progressView];
    [self.operationCardView addSubview:self.cancelButton];
}

/** 执行页面布局 */
- (void)layoutViews {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    CGFloat top = self.ts_navigationBarTotalHeight;
    if (top <= 0) {
        top = self.view.safeAreaInsets.top;
    }
    self.workoutTableView.frame = CGRectMake(0, top, width, height - top);

    CGFloat cardWidth = width - 32.f;
    self.deviceCardView.frame = CGRectMake(16.f, 12.f, cardWidth, 86.f);
    self.deviceTitleLabel.frame = CGRectMake(16.f, 18.f, cardWidth - 130.f, 22.f);
    self.deviceDetailLabel.frame = CGRectMake(16.f, 45.f, cardWidth - 32.f, 20.f);
    self.localFileButton.frame = CGRectMake(cardWidth - 112.f, 14.f, 96.f, 32.f);
    self.workoutTableView.tableHeaderView = self.deviceCardView;

    self.operationOverlay.frame = self.view.bounds;
    self.operationCardView.frame = CGRectMake(24.f, (height - 220.f) / 2.f, width - 48.f, 220.f);
    CGFloat operationWidth = CGRectGetWidth(self.operationCardView.bounds);
    self.operationTitleLabel.frame = CGRectMake(20.f, 24.f, operationWidth - 40.f, 26.f);
    self.operationDetailLabel.frame = CGRectMake(20.f, 58.f, operationWidth - 40.f, 44.f);
    self.progressView.frame = CGRectMake(20.f, 116.f, operationWidth - 40.f, 8.f);
    self.cancelButton.frame = CGRectMake(20.f, 150.f, operationWidth - 40.f, 48.f);
}

/** 安全区域变化时重新布局 */
- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self layoutViews];
}

#pragma mark - 状态视图

/** 展示下载或推送进度 */
- (void)showOperationWithTitle:(NSString *)title detail:(NSString *)detail {
    self.operationTitleLabel.text = title;
    self.operationDetailLabel.text = detail;
    self.progressView.progress = 0;
    self.operationOverlay.hidden = NO;
}

/** 隐藏进度视图 */
- (void)hideOperation {
    self.operationOverlay.hidden = YES;
}

@end
