//
//  TSBleConnectVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/1/3.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSBleConnectVC.h"
#import "TSTableViewCell.h"

@interface TSBleConnectVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableDictionary * periperalDict;

@property (nonatomic,strong) UIButton * unbindButton;

@property (nonatomic,strong) UILabel * detailLabe;

@end

@implementation TSBleConnectVC

- (UIButton *)unbindButton{
    if (!_unbindButton) {
        _unbindButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_unbindButton setTitle:@"解除绑定" forState:UIControlStateNormal];
        [_unbindButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_unbindButton addTarget:self action:@selector(unbindDevice) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unbindButton;
}

- (UILabel *)detailLabe{
    if (!_detailLabe) {
        _detailLabe = [[UILabel alloc]init];
    }
    return _detailLabe;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[TopStepComKit sharedInstance] bleConnector] isConnected]) {
        [self.view addSubview:self.unbindButton];
        [self.view addSubview:self.detailLabe];
        self.detailLabe.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame)-80-15, 80);
        self.unbindButton.frame = CGRectMake( CGRectGetWidth(self.view.frame)-80-15, 86, 80, 45);
        self.sourceTableview.frame = CGRectMake(0,CGRectGetMaxY(self.detailLabe.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-80);
        NSString *mac = [[[[TopStepComKit sharedInstance] connectedPeripheral] systemInfo] mac];
        NSString *bleName = [[[[TopStepComKit sharedInstance] connectedPeripheral] systemInfo] bleName];

        self.detailLabe.text = [NSString stringWithFormat:@"当前设备：%@——%@",mac,bleName];
    }
    // 延迟一帧执行搜索，确保蓝牙状态同步
    [self requestValue];
}

- (void)unbindDevice{
    
    //[TSToast showLoadingOnView:self.view text:@"解绑中..."];
    [[[TopStepComKit sharedInstance] bleConnector] unbindPeripheralCompletion:^(BOOL isSuccess, NSError * _Nullable error) {
        //[TSToast dismissLoadingOnView:self.view];
        if (isSuccess) {
            //[TSToast showText:@"解绑成功" onView:self.view dismissAfterDelay:2.0f];
            [self postUnbindDelegate];
        }else{
            //[TSToast showText:@"解绑失败" onView:self.view dismissAfterDelay:2.0f];
        }
        
        [self popVC];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 停止搜索
    [[[TopStepComKit sharedInstance] bleConnector] stopSearchPeripheral];
}

- (void)requestValue {
    
    __weak typeof(self)weakSelf = self;
    
    [[[TopStepComKit sharedInstance] bleConnector] startSearchPeripheral:30 discoverPeripheral:^(TSPeripheral * _Nonnull peripheral) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (peripheral) {
            if (peripheral.systemInfo.mac && peripheral.systemInfo.mac.length>0) {
                [strongSelf.periperalDict setObject:peripheral forKey:peripheral.systemInfo.mac];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *values = [strongSelf.periperalDict allValues];
                strongSelf.sourceArray = [values sortedArrayUsingComparator:^NSComparisonResult(TSPeripheral *obj1, TSPeripheral *obj2) {
                    // 127 表示无效RSSI，将其降级到最弱
                    NSInteger rssi1 = obj1.systemInfo.RSSI ? obj1.systemInfo.RSSI.integerValue : INT_MIN;
                    NSInteger rssi2 = obj2.systemInfo.RSSI ? obj2.systemInfo.RSSI.integerValue : INT_MIN;
                    if (rssi1 == 127) { rssi1 = INT_MIN; }
                    if (rssi2 == 127) { rssi2 = INT_MIN; }
                    // 若出现非负异常值，亦降级
                    if (rssi1 > 0) { rssi1 = INT_MIN + 1; }
                    if (rssi2 > 0) { rssi2 = INT_MIN + 1; }
                    if (rssi1 == rssi2) { return NSOrderedSame; }
                    // RSSI 越大(越接近0)越强，排前面
                    return rssi1 > rssi2 ? NSOrderedAscending : NSOrderedDescending;
                }];
                [strongSelf.sourceTableview reloadData];
            });
        }
    } completion:^(TSScanCompletionReason reason, NSError * _Nullable error) {
        TSLogError(@"[TSBleConnectVC] Scan complete, reason:%d error: %@",reason, error.localizedDescription);
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *text = [self cellNameAtIndexPath:indexPath];
    if (text.length == 0) {
        return 55;
    }
    CGFloat horizontalPadding = 32.0; // 与 TSTableViewCell 中 label 宽度保持一致（self.width-32）
    CGFloat availableWidth = CGRectGetWidth(tableView.frame) - horizontalPadding;
    if (availableWidth <= 0) {
        return 55;
    }
    UIFont *font = [UIFont systemFontOfSize:17.0];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(availableWidth, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil];
    CGFloat contentHeight = ceil(rect.size.height);
    CGFloat verticalPadding = 20.0; // 上下留白
    CGFloat computed = contentHeight + verticalPadding;
    // 保底高度，避免过小
    return MAX(computed, 55.0);
}

- (NSString *)cellNameAtIndexPath:(NSIndexPath *)cellIndexPath{
    if (self.sourceArray.count>cellIndexPath.row) {
        TSPeripheral *per = [self.sourceArray objectAtIndex:cellIndexPath.row];
        return [NSString stringWithFormat:@"name :%@ \nMac:%@ \nRSSI:%d ",per.systemInfo.bleName,per.systemInfo.mac,[per.systemInfo.RSSI intValue]];
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sourceArray && self.sourceArray.count>indexPath.row) {
        
        TSPeripheral *per = [self.sourceArray objectAtIndex:indexPath.row];
        NSString *userId = @"fajlief"; //[[NSUUID UUID] UUIDString];
//        if ([[[TopStepComKit sharedInstance] kitOption] sdkType] == eTSSDKTypeFW) {
//            userId = [userId substringToIndex:20];
//        }
        TSPeripheralConnectParam *param = [[TSPeripheralConnectParam alloc]initWithUserId:userId];

        //[TSToast showLoadingOnView:self.view text:@"连接中..."];
        __weak typeof(self)weakSelf = self;
        
        [[[TopStepComKit sharedInstance] bleConnector] connectWithPeripheral:per param:param completion:^(TSBleConnectionState conncetionState, NSError * _Nullable error) {
            __strong typeof(weakSelf)strongSelf = weakSelf;
            TSLog(@"connect state is %d",conncetionState);
            if (conncetionState == eTSBleStateConnected) {
                //[TSToast dismissLoadingOnView:strongSelf.view];
                TSPeripheral *currentPeri = [[TopStepComKit sharedInstance] connectedPeripheral];
                TSLog(@"TSBleConnectVC: currentPeri is %@",currentPeri.debugDescription);
                [strongSelf postDelegate:per param:param];
                [strongSelf popVC];
            }else if (conncetionState == eTSBleStateDisconnected){
                //[TSToast dismissLoadingOnView:strongSelf.view];
                if (error) {
                    [strongSelf showAlertWithMsg:[NSString stringWithFormat:@"connect error : %@",error.localizedDescription]];
                }
            }
        }];
    }
}
- (void)postUnbindDelegate{
    if (self.delegate && [self.delegate respondsToSelector:@selector(unbindSuccess)]) {
        [self.delegate unbindSuccess];
    }
}

- (void)postDelegate:(TSPeripheral *)peripheral param:(TSPeripheralConnectParam *)connectParam{
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectSuccess:param:)]) {
        [self.delegate connectSuccess:peripheral param:connectParam];
    }
}

- (void)popVC{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSMutableDictionary *)periperalDict{
    if (!_periperalDict) {
        _periperalDict = [NSMutableDictionary new];
    }
    return _periperalDict;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
