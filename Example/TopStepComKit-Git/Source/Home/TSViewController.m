//
//  TSViewController.m
//  TopStepComKit
//
//  Created by rd@hetangsmart.com on 12/23/2024.
//  Copyright (c) 2024 rd@hetangsmart.com. All rights reserved.
//

#import "TSViewController.h"
#import "TSBleConnectVC.h"
#import "TSPeripheralFindVC.h"
#import "TSTakePhotoVC.h"
#import "TSContactVC.h"
#import "TSAlarmClockVC.h"
#import "TSDailyExerciseGoalVC.h"
#import "TSLanguagesVC.h"
#import "TSUserInfoVC.h"
#import "TSMessageVC.h"
#import "TSFileOTAVC.h"
#import "TSWeatherVC.h"
#import "TSPeripheralDialVC.h"
#import "TSRemoteControlVC.h"
#import "TSUnitVC.h"
#import "TSSettingVC.h"
#import "TSBatteryVC.h"
#import "TSTimeVC.h"
#import "TSReminderVC.h"
#import "TSAutoMonitorSettingVC.h"
#import "TSDataSyncVC.h"
#import "TSActivityMeasureVC.h"


#import "TSHearRateVC.h"
#import "TSBloodOxygenVC.h"
#import "TSBloodPressureVC.h"
#import "TSSportVC.h"
#import "TSSleepVC.h"
#import "TSStressVC.h"
#import "TSTemperatureVC.h"
#import "TSDailyActivityVC.h"
#import "TSElectrocardioVC.h"
#import "TSGlassesVC.h"
#import "TSPeripheralInfoVC.h"


@interface TSViewController ()<CBCentralManagerDelegate,TSBleConnectVCDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, assign) TSSDKType currentSDKType;

@end

@implementation TSViewController



- (NSString *)sdkDisplayNameForOption:(TSSDKType)sdkType {
    switch (sdkType) {
        case eTSSDKTypeNPK: return @"NPK";
        case eTSSDKTypeCRP: return @"CRP";
        case eTSSDKTypeUTE: return @"UTE";
        case eTSSDKTypeFw:  return @"FW";
        case eTSSDKTypeFit: return @"Fit";
        case eTSSDKTypeSJ:  return @"SJ";
        default:            return @"";
    }
}

- (void)applyNavigationTitleForCurrentSDK {
    NSString *sdkName = [self sdkDisplayNameForOption:self.currentSDKType];
    self.title = sdkName.length > 0 ? [NSString stringWithFormat:@"TopStepComKit-%@", sdkName] : @"TopStepComKit";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 先初始化SDK

    
    [self initData];
    [self initView];
}

- (void)initView{
    [self addView];
    [self initFrame];
}
- (void)addView{
    // 添加右上角切换SDK按钮
    UIBarButtonItem *switchSDKButton = [[UIBarButtonItem alloc] initWithTitle:@"切换SDK"
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(switchSDKButtonTapped)];
    self.navigationItem.rightBarButtonItem = switchSDKButton;
}
- (void)initFrame{
    self.sourceTableview.frame = CGRectMake(0, self.ts_navigationBarTotalHeight, self.view.frame.size.width, CGRectGetHeight(self.view.frame)-self.ts_navigationBarTotalHeight);
}

// 切换SDK按钮点击事件
- (void)switchSDKButtonTapped {
    [self showSDKSelectionSheet];
}

// 显示SDK选择sheet
- (void)showSDKSelectionSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择SDK类型"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 添加各个SDK选项
    [alertController addAction:[UIAlertAction actionWithTitle:@"NPK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self resetSDKWithType:eTSSDKTypeNPK];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"CRP"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self resetSDKWithType:eTSSDKTypeCRP];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"UET"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self resetSDKWithType:eTSSDKTypeUTE];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"FW"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self resetSDKWithType:eTSSDKTypeFw];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Fit"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self resetSDKWithType:eTSSDKTypeFit];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"SJ"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self resetSDKWithType:eTSSDKTypeSJ];
    }]];
    
    // 添加取消按钮
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    // 在iPad上需要设置popoverPresentationController
    if (alertController.popoverPresentationController) {
        alertController.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//
- (void)initData{
    self.currentSDKType = eTSSDKTypeNPK;
    [self applyNavigationTitleForCurrentSDK];
    self.view.backgroundColor = [UIColor colorWithRed:246/255.0f green:246/255.0f blue:246/255.0f alpha:1.0f];
    // 初始化蓝牙管理器
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey: @YES}];
    
    // 设置当前SDK类型
    
}


- (void)initSDKWithType:(TSSDKType)sdkType{
    
    __weak typeof(self)weakSelf = self;
    self.currentSDKType = sdkType;
    [self applyNavigationTitleForCurrentSDK];
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:[self configOptionsWithSDKType:sdkType] completion:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        // success
        if (isSuccess) {
            [strongSelf autoConnect];
        }
    }];
}

- (void)resetSDKWithType:(TSSDKType)sdkType{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    self.currentSDKType = sdkType;
    [self applyNavigationTitleForCurrentSDK];
    [[TopStepComKit sharedInstance] initSDKWithConfigOptions:[self configOptionsWithSDKType:sdkType] completion:^(BOOL isSuccess, NSError * _Nullable error) {
        [TSToast dismissLoadingOnView:weakSelf.view];
        if (isSuccess) {
            TSLog(@"SDK 切换成功");
        }else{
            TSLog(@"SDK 切换失败：%@",error.debugDescription);
        }
    }];
}

- (TSKitConfigOptions *)configOptionsWithSDKType:(TSSDKType)sdkType{
    TSKitConfigOptions *configs = [TSKitConfigOptions configOptionWithSDKType:sdkType license:@"abcdef1234567890abcdef1234567890"];
    configs.isDevelopModel = YES;
    return  configs;
}


- (NSArray *)sourceArray{
    return @[
        [TSValueModel valueWithName:@"日志" kitType:eTSKitLog],
        [TSValueModel valueWithName:@"蓝牙连接" kitType:eTSKitBle vcName:NSStringFromClass([TSBleConnectVC class])],
        [TSValueModel valueWithName:@"设备信息" kitType:eTSKitPeripheralInfo vcName:NSStringFromClass([TSPeripheralInfoVC class])],

        [TSValueModel valueWithName:@"数据同步" kitType:eTSKitDataSync vcName:NSStringFromClass([TSDataSyncVC class])],
       
        [TSValueModel valueWithName:@"心率" kitType:eTSKitHR vcName:NSStringFromClass([TSHearRateVC class])],
        [TSValueModel valueWithName:@"血压" kitType:eTSKitBP vcName:NSStringFromClass([TSBloodPressureVC class])],
        [TSValueModel valueWithName:@"血氧" kitType:eTSKitBO vcName:NSStringFromClass([TSBloodOxygenVC class])],
        [TSValueModel valueWithName:@"压力" kitType:eTSKitStress vcName:NSStringFromClass([TSStressVC class])],
        [TSValueModel valueWithName:@"睡眠" kitType:eTSKitSleep vcName:NSStringFromClass([TSSleepVC class])],
        [TSValueModel valueWithName:@"体温" kitType:eTSKitTemp vcName:NSStringFromClass([TSTemperatureVC class])],
        [TSValueModel valueWithName:@"心电" kitType:eTSKitECG vcName:NSStringFromClass([TSElectrocardioVC class])],
        [TSValueModel valueWithName:@"运动" kitType:eTSKitSport vcName:NSStringFromClass([TSSportVC class])],
        [TSValueModel valueWithName:@"日常活动" kitType:eTSKitDailyActivity vcName:NSStringFromClass([TSDailyActivityVC class])],

        [TSValueModel valueWithName:@"查找设备" kitType:eTSKitFind vcName:NSStringFromClass([TSPeripheralFindVC class])],
        [TSValueModel valueWithName:@"摇一摇拍照" kitType:eTSKitTakePhoto vcName:NSStringFromClass([TSTakePhotoVC class])],
        [TSValueModel valueWithName:@"通讯录" kitType:eTSKitContact vcName:NSStringFromClass([TSContactVC class])],
        [TSValueModel valueWithName:@"闹钟" kitType:eTSKitAlarmClock vcName:NSStringFromClass([TSAlarmClockVC class])],
        [TSValueModel valueWithName:@"每日运动目标设置" kitType:eTSKitExerciseGoal vcName:NSStringFromClass([TSDailyExerciseGoalVC class])],
        [TSValueModel valueWithName:@"语言设置" kitType:eTSKitLanguage vcName:NSStringFromClass([TSLanguagesVC class])],
        [TSValueModel valueWithName:@"用户信息" kitType:eTSKitUserInfo vcName:NSStringFromClass([TSUserInfoVC class])],
        [TSValueModel valueWithName:@"消息通知" kitType:eTSKitMessage vcName:NSStringFromClass([TSMessageVC class])],
        [TSValueModel valueWithName:@"OTA升级" kitType:eTSKitFileOTA vcName:NSStringFromClass([TSFileOTAVC class])],
        [TSValueModel valueWithName:@"天气" kitType:eTSKitWeather vcName:NSStringFromClass([TSWeatherVC class])],
        [TSValueModel valueWithName:@"表盘" kitType:eTSKitPeripheralDial vcName:NSStringFromClass([TSPeripheralDialVC class])],
        [TSValueModel valueWithName:@"设备控制" kitType:eTSKitRemoteControl vcName:NSStringFromClass([TSRemoteControlVC class])],
        [TSValueModel valueWithName:@"单位设置" kitType:eTSKitUnit vcName:NSStringFromClass([TSUnitVC class])],
        [TSValueModel valueWithName:@"开关设置" kitType:eTSKitSetting vcName:NSStringFromClass([TSSettingVC class])],
        [TSValueModel valueWithName:@"电量" kitType:eTSKitBattery vcName:NSStringFromClass([TSBatteryVC class])],
        [TSValueModel valueWithName:@"时间设置" kitType:eTSKitTime vcName:NSStringFromClass([TSTimeVC class])],
        [TSValueModel valueWithName:@"提醒设置" kitType:eTSKitReminder vcName:NSStringFromClass([TSReminderVC class])],
        [TSValueModel valueWithName:@"自动监测设置" kitType:eTSKitAutoMonitor vcName:NSStringFromClass([TSAutoMonitorSettingVC class])],
        [TSValueModel valueWithName:@"健康数据测量" kitType:eTSKitActivityMeasure vcName:NSStringFromClass([TSActivityMeasureVC class])],

        [TSValueModel valueWithName:@"眼镜" kitType:eTSKitActivityMeasure vcName:NSStringFromClass([TSGlassesVC class])],
    ];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sourceArray.count>indexPath.row) {
        TSValueModel *value = [self.sourceArray objectAtIndex:indexPath.row];
        if (value.kitType == eTSKitBle) {
            [self checkBluetoothAuthority];
        }else {
            [self pushVCWithValue:value];
        }
    }
}

- (void)checkBluetoothAuthority {
    // 检查当前蓝牙状态
    switch (self.centralManager.state) {
        case CBManagerStatePoweredOn: {
            // 蓝牙已开启，直接跳转
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pushToBle];
            });
            break;
        }
        case CBManagerStatePoweredOff: {
            // 蓝牙关闭，显示提示
            [self showBluetoothOffAlert];
            break;
        }
        case CBManagerStateUnauthorized: {
            // 未授权，显示授权提示
            [self showBluetoothUnauthorizedAlert];
            break;
        }
        default:
            // 其他状态等待代理回调
            break;
    }
}

// 显示蓝牙关闭提示
- (void)showBluetoothOffAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                 message:@"请开启蓝牙以使用设备"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"设置"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 显示蓝牙未授权提示
- (void)showBluetoothUnauthorizedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                 message:@"请在设置中授权蓝牙权限"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"设置"
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                            style:UIAlertActionStyleCancel
                                          handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

// CBCentralManagerDelegate 方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStatePoweredOn: {
            NSLog(@"Bluetooth is powered on and available.");
            [self initSDKWithType:eTSSDKTypeFw];
            break;
        }
        case CBManagerStatePoweredOff: {
            NSLog(@"Bluetooth is powered off.");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showBluetoothOffAlert];
            });
            break;
        }
        case CBManagerStateUnauthorized: {
            NSLog(@"Bluetooth is not authorized.");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showBluetoothUnauthorizedAlert];
            });
            break;
        }
        default:
            break;
    }
}

- (void)autoConnect{
    
    NSString *macAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCurrentMac"];
    NSString *kUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"kUserId"];

    if (macAddress && macAddress.length>0) {
        TSPeripheral *prePeripheral = [[TSPeripheral alloc] init];
        prePeripheral.systemInfo.mac = macAddress;
        
        TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc]initWithUserId:kUserId];
        
        __weak typeof(self)weakSelf = self;
        [TSToast showLoadingOnView:self.view text:@"重连中..."];
        
        [[[TopStepComKit sharedInstance] bleConnector] reconnectWithPeripheral:prePeripheral param:param completion:^(TSBleConnectionState conncetionState, NSError * _Nullable error) {
            
            __strong typeof(weakSelf)strongSelf = weakSelf;
            TSLog(@"reconnectWithPeripheral state: %lu",(unsigned long)conncetionState);
            if (conncetionState == eTSBleStateConnected) {
                TSPeripheral *currentPeri = [[TopStepComKit sharedInstance] connectedPeripheral];
                TSLog(@"TSViewController: currentPeri is %@",currentPeri.debugDescription);
                [TSToast showLoadingOnView:self.view text:@"连接成功" dismissAfterDelay:1];
            }else if (conncetionState == eTSBleStateDisconnected){
                [TSToast dismissLoadingOnView:strongSelf.view];
                if (error) {
                    [strongSelf showAlertWithMsg:[NSString stringWithFormat:@"connect error :%@",error.localizedDescription]];
                }
            }
        }];
    }
}

- (void)pushVCWithValue:(TSValueModel *)valueModel{
    if (valueModel && valueModel.vcName && valueModel.vcName.length>0) {
        Class targetClass = NSClassFromString(valueModel.vcName);
        TSBaseVC* instance = [[targetClass alloc] init];
        instance.title = valueModel.valueName;
        [self pushVC:instance];
    }
}

- (void)pushToBle {
    // 创建蓝牙连接页面
    TSBleConnectVC *bleVC = [[TSBleConnectVC alloc] init];
    bleVC.title = @"蓝牙连接";
    bleVC.delegate = self;
    [self pushVC:bleVC];
}

- (void)connectSuccess:(TSPeripheral *)peripheral param:(nonnull TSPeripheralConnectParam *)connectParam{
    if (peripheral) {
        [[NSUserDefaults standardUserDefaults] setObject:peripheral.systemInfo.mac forKey:@"kCurrentMac"];
        [[NSUserDefaults standardUserDefaults] setObject:connectParam.userId forKey:@"kUserId"];
    }
}

- (void)unbindSuccess{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kCurrentMac"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kUserId"];
}


- (void)pushVC:(UIViewController *)vc{
    if (vc) {
        // 确保有导航控制器
        if (self.navigationController) {
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            // 如果没有导航控制器，创建一个
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
            [nav pushViewController:vc animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
