//
//  TSCompanionWorkoutVC.m
//  TopStepComKit_Example
//

#import "TSCompanionWorkoutVC.h"

#import <TopStepComKit/TopStepComKit.h>

@interface TSCompanionWorkoutVC ()

@property (nonatomic, strong) UILabel *capabilityLabel;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, assign) NSTimeInterval workoutStartTime;
@property (nonatomic, assign) NSInteger workoutDuration;

@end


@implementation TSCompanionWorkoutVC

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"互联运动";
    self.view.backgroundColor = TSColor_Background;
    [self setupViews];
    [self registerCallbacks];
    [self reloadCapabilities];
}

- (void)dealloc {
    id<TSCompanionWorkoutInterface> companionWorkout = [TopStepComKit sharedInstance].companionWorkout;
    [companionWorkout registerWorkoutEventDidChanged:nil];
    [companionWorkout registerPeriodicReportDataDidChanged:nil];
    [companionWorkout registerLowBatteryAlert:nil];
}

#pragma mark - 公开操作

- (void)queryWorkout {
    [[TopStepComKit sharedInstance].companionWorkout queryWorkoutInfoWithCompletion:
     ^(TSCompanionWorkoutInfoModel *workoutInfo, NSError *error) {
        if (error) {
            [self showResult:[NSString stringWithFormat:@"查询失败：%@", error.localizedDescription]];
            return;
        }
        if (!workoutInfo) {
            [self showResult:@"当前无互联运动会话"];
            return;
        }
        self.workoutStartTime = workoutInfo.workoutStartTime;
        [self showResult:[NSString stringWithFormat:@"状态=%ld 类型=%ld 发起方=%ld 开始=%0.f",
                          (long)workoutInfo.state, (long)workoutInfo.workoutType,
                          (long)workoutInfo.initiator, workoutInfo.workoutStartTime]];
    }];
}

- (void)startWorkout {
    self.workoutStartTime = [NSDate date].timeIntervalSince1970;
    self.workoutDuration = 0;
    [self sendEvent:TSCompanionWorkoutEventStart];
}

- (void)pauseWorkout {
    self.workoutDuration += 30;
    [self sendEvent:TSCompanionWorkoutEventPause];
}

- (void)resumeWorkout {
    [self sendEvent:TSCompanionWorkoutEventResume];
}

- (void)stopWorkout {
    self.workoutDuration += 30;
    [self sendEvent:TSCompanionWorkoutEventStop];
}

- (void)sendPeriodicReport {
    TSCompanionWorkoutAppReportModel *report = [[TSCompanionWorkoutAppReportModel alloc] init];
    report.workoutStartTime = self.workoutStartTime;
    report.workoutDurationInSeconds = self.workoutDuration;
    report.distanceInMeters = @1200.5;
    report.caloriesInKilocalories = @88.6;
    report.currentPace = @360;
    report.numberOfSteps = @1600;
    [[TopStepComKit sharedInstance].companionWorkout sendPeriodicReportData:report
                                                                  completion:[self completionWithAction:@"发送周期数据"]];
}

#pragma mark - 私有方法

- (void)setupViews {
    self.capabilityLabel = [[UILabel alloc] init];
    self.capabilityLabel.font = TSFont_Body;
    self.capabilityLabel.numberOfLines = 0;

    self.resultTextView = [[UITextView alloc] init];
    self.resultTextView.editable = NO;
    self.resultTextView.font = TSFont_Body;
    self.resultTextView.backgroundColor = TSColor_Card;
    self.resultTextView.layer.cornerRadius = TSRadius_MD;
    [self.resultTextView.heightAnchor constraintEqualToConstant:180].active = YES;

    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[
        self.capabilityLabel,
        [self buttonWithTitle:@"查询当前会话" action:@selector(queryWorkout)],
        [self buttonWithTitle:@"开始户外跑步" action:@selector(startWorkout)],
        [self buttonWithTitle:@"暂停（+30 秒）" action:@selector(pauseWorkout)],
        [self buttonWithTitle:@"继续" action:@selector(resumeWorkout)],
        [self buttonWithTitle:@"发送周期数据" action:@selector(sendPeriodicReport)],
        [self buttonWithTitle:@"结束（+30 秒）" action:@selector(stopWorkout)],
        self.resultTextView,
    ]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.spacing = TSSpacing_SM;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:TSSpacing_MD],
        [stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:TSSpacing_MD],
        [stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-TSSpacing_MD],
    ]];
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = TSColor_Card;
    button.layer.cornerRadius = TSRadius_SM;
    [button.heightAnchor constraintEqualToConstant:44].active = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)reloadCapabilities {
    TSCompanionWorkoutCapabilitiesModel *capabilities =
        [[TopStepComKit sharedInstance].companionWorkout capabilities];
    self.capabilityLabel.text = [NSString stringWithFormat:@"支持=%@ GPS=%@ 八字段=%@",
        capabilities.isCompanionWorkoutSupported ? @"是" : @"否",
        capabilities.isDeviceGPSSupported ? @"是" : @"否",
        capabilities.isEightFieldPeriodicReportSupported ? @"是" : @"否"];
}

- (void)sendEvent:(TSCompanionWorkoutEvent)event {
    TSCompanionWorkoutEventModel *model = [[TSCompanionWorkoutEventModel alloc] init];
    model.event = event;
    model.workoutStartTime = self.workoutStartTime;
    model.workoutType = TSSportTypeOutdoorRunning;
    model.workoutDurationInSeconds = self.workoutDuration;
    NSString *action = [NSString stringWithFormat:@"事件 %ld", (long)event];
    [[TopStepComKit sharedInstance].companionWorkout sendWorkoutEvent:model
                                                           completion:[self completionWithAction:action]];
}

- (TSCompletionBlock)completionWithAction:(NSString *)action {
    return ^(BOOL success, NSError *error) {
        NSString *message = success ? @"成功" : (error.localizedDescription ?: @"失败");
        [self showResult:[NSString stringWithFormat:@"%@：%@", action, message]];
    };
}

- (void)registerCallbacks {
    id<TSCompanionWorkoutInterface> companionWorkout = [TopStepComKit sharedInstance].companionWorkout;
    __weak typeof(self) weakSelf = self;
    [companionWorkout registerWorkoutEventDidChanged:^(TSCompanionWorkoutEventModel *event) {
        [weakSelf showResult:[NSString stringWithFormat:@"设备事件=%ld 时长=%ld",
                              (long)event.event, (long)event.workoutDurationInSeconds]];
    }];
    [companionWorkout registerPeriodicReportDataDidChanged:^(TSCompanionWorkoutDeviceReportModel *report) {
        [weakSelf showResult:[NSString stringWithFormat:@"设备周期数据 steps=%@ bpm=%@ distance=%@",
                              report.numberOfSteps, report.bpmValue, report.distanceInMeters]];
    }];
    [companionWorkout registerLowBatteryAlert:^(NSInteger batteryPercentage) {
        [weakSelf showResult:[NSString stringWithFormat:@"设备低电：%ld%%", (long)batteryPercentage]];
    }];
}

- (void)showResult:(NSString *)message {
    TSLog(@"[CompanionWorkout] %@", message);
    self.resultTextView.text = message;
}

@end
