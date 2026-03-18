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
        [TSValueModel valueWithName:TSLocalizedString(@"glasses.open_video_preview")],
        [TSValueModel valueWithName:TSLocalizedString(@"glasses.close_video_preview")],
        [TSValueModel valueWithName:TSLocalizedString(@"glasses.get_preview_status")],

        [TSValueModel valueWithName:TSLocalizedString(@"glasses.start_audio")],
        [TSValueModel valueWithName:TSLocalizedString(@"glasses.stop_audio")],
        [TSValueModel valueWithName:TSLocalizedString(@"glasses.get_audio_status")],

        [TSValueModel valueWithName:TSLocalizedString(@"glasses.start_video")],
        [TSValueModel valueWithName:TSLocalizedString(@"glasses.stop_video")],
        [TSValueModel valueWithName:TSLocalizedString(@"glasses.get_video_status")],

        [TSValueModel valueWithName:TSLocalizedString(@"glasses.take_photo")],

        [TSValueModel valueWithName:TSLocalizedString(@"glasses.get_media_count")],
        [TSValueModel valueWithName:TSLocalizedString(@"glasses.get_storage_info")],

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
    
    
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] startVideoPreview:^(BOOL isSuccess, NSError * _Nullable error) {
//        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"openVideoPreview result: %d error: %@",isSuccess,error.localizedDescription);
    } didReceiveData:^(NSData * _Nonnull videoData) {
        TSLog(@"openVideoPreview data : %ld",videoData.length);
    } completionHandler:^(NSError * _Nullable error) {
        TSLog(@"openVideoPreview end error: %@",error.localizedDescription);
    }];
}
- (void)closeVideoPreview{
    
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] stopVideoPreview:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"closeVideoPreview result: %d error: %@",isSuccess,error.localizedDescription);
    }];

}

- (void)getVideoPreviewStatus{
    
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getVideoPreviewStatus:^(TSVideoPreviewStatus status, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"getVideoPreviewStatus result: %d error: %@",status,error.localizedDescription);
    }];
}




- (void)startAudioRecording{
    
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] startAudioRecording:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"startAudioRecording result: %d error: %@",isSuccess,error.localizedDescription);
    }];

}
- (void)stopAudioRecording{
    
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] stopAudioRecording:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"stopAudioRecording result: %d error: %@",isSuccess,error.localizedDescription);
    }];

}

- (void)getAudioRecordStatus{
    
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getAudioRecordingStatus:^(TSAudioRecordingStatus status, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"getAudioRecordStatus result: %d error: %@",status,error.localizedDescription);
    }];
}




- (void)startVideRecording{
    
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] startVideoRecording:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"startVideoRecording result: %d error: %@",isSuccess,error.localizedDescription);
    }];
}

- (void)stopVideRecording{
    
    __weak typeof(self)weakSelf = self;
    [[[TopStepComKit sharedInstance] glasses] stopVideoRecording:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"stopVideoRecording result: %d error: %@",isSuccess,error.localizedDescription);
    }];

}

- (void)getVideoRecordStatus{
    
    
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getVideoRecordingStatus:^(TSVideoRecordingStatus status, NSError * _Nullable error) {
     
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"getVideoRecordStatus result: %d error: %@",status,error.localizedDescription);
    }];

}

- (void)takePhoto{
    
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] takePhoto:^(BOOL isSuccess, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"takePhoto result: %d error: %@",isSuccess,error.localizedDescription);
    }];
    
}

- (void)getMediaCount{
    
    
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getMediaCount:^(TSGlassesMediaCount * _Nullable mediaCount, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"getMediaCount result: %@ error: %@",mediaCount.debugDescription,error.localizedDescription);

    }];

}

- (void)getStorageInfo{
    
    
    __weak typeof(self)weakSelf = self;

    [[[TopStepComKit sharedInstance] glasses] getStorageInfo:^(TSGlassesStorageInfo * _Nullable storageInfo, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        TSLog(@"getStorageInfo result: %@ @ error: %@",storageInfo.debugDescription,storageInfo.formattedStorageInfo,error.localizedDescription);

    }];
}




@end
