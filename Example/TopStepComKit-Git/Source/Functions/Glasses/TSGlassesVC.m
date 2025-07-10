//
//  TSGlassesVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/6/19.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSGlassesVC.h"

@interface TSGlassesVC ()

@end

@implementation TSGlassesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self registerStatusChanged];
}

- (void)registerStatusChanged{
    // 视频预览
    [[[TopStepComKit sharedInstance] glasses] registerVideoPreviewStatusChangedBlock:^(TSVideoPreviewStatus status) {
        TSLog(@"VideoPreviewStatusChanged :%ld",status);
    }];
    
    // 语音录制
    [[[TopStepComKit sharedInstance] glasses] registerAudioRecordingStatusChangedBlock:^(TSAudioRecordingStatus status) {
        TSLog(@"AudioRecordingStatusChanged :%d",status);
    }];
    // 视频录制
    [[[TopStepComKit sharedInstance] glasses] registerVideoRecordingStatusChangedBlock:^(TSVideoRecordingStatus status) {
        TSLog(@"VideoRecordingStatusChanged :%d",status);
    }];
    // 拍照结果
    [[[TopStepComKit sharedInstance] glasses] registerPhotoCaptureResultBlock:^(BOOL isSuccess, NSError * _Nullable error) {
        TSLog(@"PhotoCaptureResult :%d  error:%@",isSuccess,error.localizedDescription);

    }];

}

- (NSArray *)sourceArray {
    return @[
        [TSValueModel valueWithName:@"打开视频预览"],
        [TSValueModel valueWithName:@"关闭视频预览"],
        [TSValueModel valueWithName:@"获取视频预览状态"],

        [TSValueModel valueWithName:@"打开录音"],
        [TSValueModel valueWithName:@"关闭录音"],
        [TSValueModel valueWithName:@"获取语音录制状态"],

        [TSValueModel valueWithName:@"打开视频录制"],
        [TSValueModel valueWithName:@"关闭视频录制"],
        [TSValueModel valueWithName:@"获取视频录制状态"],

        [TSValueModel valueWithName:@"拍照"],

        [TSValueModel valueWithName:@"获取多媒体数量"],
        [TSValueModel valueWithName:@"获取内存信息"],

    ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self openVideoPreview];
    } else if (indexPath.row == 1) {
        [self closeVideoPreview];
    }else if (indexPath.row == 2) {
        [self getVideoPreviewStatus];
    } else if (indexPath.row == 3) {
        [self startAudioRecording];
    }  else if (indexPath.row == 4) {
        [self stopAudioRecording];
    }else if (indexPath.row == 5) {
        [self getAudioRecordStatus];
    }  else if (indexPath.row == 6) {
        [self startVideRecording];
    }else if (indexPath.row == 7) {
        [self stopVideRecording];
    }else  if (indexPath.row == 8) {
        [self getVideoRecordStatus];
    }else  if (indexPath.row == 9) {
        [self takePhoto];
    }else  if (indexPath.row == 10) {
        [self getMediaCount];
    }else  if (indexPath.row == 11) {
        [self getStorageInfo];
    }

}


- (void)openVideoPreview{
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] startVideoPreview:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"openVideoPreview result: %d error: %@",isSuccess,error.localizedDescription);
    } didReceiveData:^(NSData * _Nonnull videoData) {
        TSLog(@"openVideoPreview data : %ld",videoData.length);
    } completionHandler:^(NSError * _Nullable error) {
        TSLog(@"openVideoPreview end error: %@",error.localizedDescription);
    }];
}
- (void)closeVideoPreview{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] stopVideoPreview:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"closeVideoPreview result: %d error: %@",isSuccess,error.localizedDescription);
    }];

}

- (void)getVideoPreviewStatus{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getVideoPreviewStatus:^(TSVideoPreviewStatus status, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"getVideoPreviewStatus result: %d error: %@",status,error.localizedDescription);
    }];
}




- (void)startAudioRecording{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] startAudioRecording:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"startAudioRecording result: %d error: %@",isSuccess,error.localizedDescription);
    }];

}
- (void)stopAudioRecording{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] stopAudioRecording:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"stopAudioRecording result: %d error: %@",isSuccess,error.localizedDescription);
    }];

}

- (void)getAudioRecordStatus{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getAudioRecordingStatus:^(TSAudioRecordingStatus status, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"getAudioRecordStatus result: %d error: %@",status,error.localizedDescription);
    }];
}




- (void)startVideRecording{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] startVideoRecording:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"startVideoRecording result: %d error: %@",isSuccess,error.localizedDescription);
    }];
}

- (void)stopVideRecording{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] stopVideoRecording:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"stopVideoRecording result: %d error: %@",isSuccess,error.localizedDescription);
    }];

}

- (void)getVideoRecordStatus{
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getVideoRecordingStatus:^(TSVideoRecordingStatus status, NSError * _Nullable error) {
     
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"getVideoRecordStatus result: %d error: %@",status,error.localizedDescription);
    }];

}

- (void)takePhoto{
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] takePhoto:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"takePhoto result: %d error: %@",isSuccess,error.localizedDescription);
    }];
    
}

- (void)getMediaCount{
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getMediaCount:^(TSGlassesMediaCount * _Nullable mediaCount, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"getMediaCount result: %@ error: %@",mediaCount.debugDescription,error.localizedDescription);

    }];

}

- (void)getStorageInfo{
    
    [TSToast showLoadingOnView:self.view];
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getStorageInfo:^(TSGlassesStorageInfo * _Nullable storageInfo, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [TSToast dismissLoadingOnView:strongSelf.view];
        TSLog(@"getStorageInfo result: %@ @ error: %@",storageInfo.debugDescription,storageInfo.formattedStorageInfo,error.localizedDescription);

    }];
}




@end
