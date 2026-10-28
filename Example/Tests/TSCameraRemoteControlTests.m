//
//  TSCameraRemoteControlTests.m
//  TopStepComKit-GitTests
//

#import <XCTest/XCTest.h>
#import <CoreVideo/CoreVideo.h>
#import <AVKit/AVKit.h>
#import <TopStepComKit/TopStepComKit.h>

#import "../TopStepComKit-Git/Source/Device/CameraTakePhoto/TSTakePhotoVC.h"

// 仅测试声明私有入口，不为测试扩大 Demo 公共接口。
@interface TSTakePhotoVC (CameraRemoteControlTesting)
- (void)handleAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice;
- (void)ensureDeviceCameraEntered;
- (void)sendCameraRange;
- (CGFloat)zoomRatioForAction:(TSCameraAction)action;
- (void)refreshUI;
- (void)startPreviewIfPossible;
- (void)setZoomForAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice;
- (void)switchModeForAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice;
- (void)prepareRecordingFromDevice:(BOOL)fromDevice;
- (void)stopRecordingFromDevice:(BOOL)fromDevice;
- (void)notifyDevice:(TSCameraAction)action;
- (void)notifyRecordingStartedIfCurrent;
- (void)notifyPhotoResultIfCurrent;
- (void)notifyDevice:(TSCameraAction)action originService:(id<TSCameraInterface>)source generation:(NSUInteger)generation;
- (BOOL)canFeedPreviewInVideoMode:(BOOL)video connectionActive:(BOOL)connectionActive;
- (NSNumber *)preferredPreviewPixelFormatFromAvailableFormats:(NSArray<NSNumber *> *)availableFormats;
- (void)continueRecordingPreparation;
- (BOOL)canReuseRecordingConfigurationWithAudioAuthorized:(BOOL)audioAuthorized;
- (void)configureVideoMode:(BOOL)video position:(AVCaptureDevicePosition)position
              fromDevice:(BOOL)fromDevice completion:(void (^)(BOOL))completion;
- (void)startMovieRecordingFromDevice:(BOOL)fromDevice;
- (NSURL *)recentMediaCacheDirectory;
- (NSURL *)retainedMediaDirectoryWithError:(NSError **)error;
- (NSArray<NSURL *> *)mediaURLsInDirectory:(NSURL *)directory;
- (void)restoreRecentMedia;
- (UIImage *)thumbnailImageForURL:(NSURL *)fileURL error:(NSError **)error;
- (void)moveSavedMediaToRecentCache:(NSURL *)fileURL;
- (void)updateThumbnailForURL:(NSURL *)fileURL;
- (void)presentMediaAtURL:(NSURL *)fileURL;
- (void)beginMediaPreviewWithController:(UIViewController *)controller;
- (void)finishMediaPreview;
- (void)resumeCaptureIfPossible;
- (void)finishPendingTransition;
- (void)reportError:(NSError *)error fallback:(NSString *)fallback;
- (void)requestCloseFromDevice:(BOOL)fromDevice;
- (void)takePhoto;
- (void)handleMediaPlaybackError:(NSError *)error;
@end

// 公开 SDK 门面的替身只实现本测试使用的消息，不连接硬件。
@interface TSCameraServiceSpy : NSObject
@property (nonatomic, strong) NSMutableArray<NSString *> *events;
@property (nonatomic, copy) TSCompletionBlock enterCompletion;
@end

@implementation TSCameraServiceSpy
- (instancetype)init {
    self = [super init];
    if (self) {
        _events = [NSMutableArray array];
    }
    return self;
}
- (void)controlCameraWithAction:(TSCameraAction)action completion:(TSCompletionBlock)completion {
    [self.events addObject:action == TSCameraActionEnterCamera ? @"enter" : @"action"];
    self.enterCompletion = completion;
}
- (void)setCameraInfoWithMinimumZoomRatio:(float)minimum maximumZoomRatio:(float)maximum
                             completion:(TSCompletionBlock)completion {
    [self.events addObject:[NSString stringWithFormat:@"range:%.1f:%.1f", minimum, maximum]];
    if (completion) {
        completion(YES, nil);
    }
}
@end

// 路由测试替换真正拍摄动作，保留能力判断和动作派发。
@interface TSCameraPageSpy : TSTakePhotoVC
@property (nonatomic, strong) NSMutableArray<NSNumber *> *receivedZoomActions;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *outboundActions;
@property (nonatomic, assign) NSUInteger videoModeRequests;
@property (nonatomic, assign) NSUInteger recordingRequests;
@property (nonatomic, assign) NSUInteger stopRequests;
@property (nonatomic, assign) BOOL lastActionFromDevice;
@property (nonatomic, assign) BOOL performRealStop;
@property (nonatomic, assign) NSUInteger configurationRequests;
@property (nonatomic, assign) NSUInteger movieStartRequests;
@end

@implementation TSCameraPageSpy
- (instancetype)init {
    self = [super init];
    if (self) {
        _receivedZoomActions = [NSMutableArray array];
        _outboundActions = [NSMutableArray array];
    }
    return self;
}
- (void)refreshUI { }
- (void)startPreviewIfPossible { }
- (void)ts_showToast:(NSString *)message { }
- (void)setZoomForAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice {
    [self.receivedZoomActions addObject:@(action)];
    self.lastActionFromDevice = fromDevice;
}
- (void)switchModeForAction:(TSCameraAction)action fromDevice:(BOOL)fromDevice {
    self.videoModeRequests += 1;
    self.lastActionFromDevice = fromDevice;
}
- (void)prepareRecordingFromDevice:(BOOL)fromDevice {
    self.recordingRequests += 1;
    self.lastActionFromDevice = fromDevice;
}
- (void)stopRecordingFromDevice:(BOOL)fromDevice {
    self.stopRequests += 1;
    self.lastActionFromDevice = fromDevice;
    if (self.performRealStop) {
        [super stopRecordingFromDevice:fromDevice];
    }
}
- (void)notifyDevice:(TSCameraAction)action {
    [self.outboundActions addObject:@(action)];
}
- (void)configureVideoMode:(BOOL)video position:(AVCaptureDevicePosition)position
              fromDevice:(BOOL)fromDevice completion:(void (^)(BOOL))completion {
    self.configurationRequests += 1;
}
- (void)startMovieRecordingFromDevice:(BOOL)fromDevice {
    self.movieStartRequests += 1;
    self.lastActionFromDevice = fromDevice;
}
@end

@interface TSCameraRemoteControlTests : XCTestCase
@end

@implementation TSCameraRemoteControlTests

// 只设置无硬件状态，不加载页面或触发系统权限。
- (TSCameraPageSpy *)readyPage {
    TSCameraPageSpy *page = [[TSCameraPageSpy alloc] init];
    [page setValue:@YES forKey:@"cameraAuthorized"];
    [page setValue:@YES forKey:@"sessionReady"];
    [page setValue:@YES forKey:@"pageVisible"];
    [page setValue:@YES forKey:@"deviceReady"];
    return page;
}

// bit43 为关时仍接受全部五种设备变焦动作。
- (void)testZoomActionsRemainAvailableWithoutVideoOrPreview {
    TSCameraPageSpy *page = [self readyPage];
    [page setValue:@NO forKey:@"videoModeSupported"];
    [page setValue:@NO forKey:@"previewSupported"];
    for (NSNumber *action in @[@10, @11, @12, @13, @14]) {
        [page handleAction:action.integerValue fromDevice:YES];
    }
    XCTAssertEqualObjects(page.receivedZoomActions, (@[@10, @11, @12, @13, @14]));
    XCTAssertTrue(page.lastActionFromDevice);
    XCTAssertEqual(page.outboundActions.count, 0u);
}

// 录像模式和开始录制受能力限制，停止仍可清理。
- (void)testMissingVideoCapabilityBlocksModeAndStartButAllowsStop {
    TSCameraPageSpy *page = [self readyPage];
    [page setValue:@NO forKey:@"videoModeSupported"];
    [page handleAction:TSCameraActionEnterVideoMode fromDevice:YES];
    [page handleAction:TSCameraActionStartRecording fromDevice:YES];
    [page handleAction:TSCameraActionStopRecording fromDevice:YES];
    XCTAssertEqual(page.videoModeRequests, 0u);
    XCTAssertEqual(page.recordingRequests, 0u);
    XCTAssertEqual(page.stopRequests, 1u);
    XCTAssertEqual(page.outboundActions.count, 0u);
}

// 派发设备录像时保留来源，不产生本地动作回声。
- (void)testDeviceRecordingPreservesOrigin {
    TSCameraPageSpy *page = [self readyPage];
    [page setValue:@YES forKey:@"videoModeSupported"];
    [page handleAction:TSCameraActionStartRecording fromDevice:YES];
    XCTAssertEqual(page.recordingRequests, 1u);
    XCTAssertTrue(page.lastActionFromDevice);
    XCTAssertEqual(page.outboundActions.count, 0u);
}

// Min 和 Max 始终取当前镜头的真实边界。
- (void)testBoundaryZoomActionsUseActiveLensRange {
    TSCameraPageSpy *page = [self readyPage];
    [page setValue:@0.5 forKey:@"minimumZoomRatio"];
    [page setValue:@2.5 forKey:@"maximumZoomRatio"];
    XCTAssertEqualWithAccuracy([page zoomRatioForAction:TSCameraActionZoomRatioMinimum], 0.5, 0.001);
    XCTAssertEqualWithAccuracy([page zoomRatioForAction:TSCameraActionZoomRatioMaximum], 2.5, 0.001);
    XCTAssertEqualWithAccuracy([page zoomRatioForAction:TSCameraActionZoomRatioThreeX], 3, 0.001);
}

// Enter 成功之前不发范围；每次绑定标记仅发送一次，独立于预览和录像能力。
- (void)testRangeWaitsForEnterAndFlushesOncePerConfiguration {
    TSCameraPageSpy *page = [self readyPage];
    TSCameraServiceSpy *service = [[TSCameraServiceSpy alloc] init];
    [page setValue:service forKey:@"cameraService"];
    [page setValue:@7 forKey:@"connectionGeneration"];
    [page setValue:@3 forKey:@"configurationGeneration"];
    [page setValue:@YES forKey:@"zoomRangeValid"];
    [page setValue:@YES forKey:@"zoomRangePending"];
    [page setValue:@0.5 forKey:@"minimumZoomRatio"];
    [page setValue:@5 forKey:@"maximumZoomRatio"];
    [page sendCameraRange];
    XCTAssertEqual(service.events.count, 0u);
    [page ensureDeviceCameraEntered];
    XCTAssertEqualObjects(service.events, (@[@"enter"]));
    XCTAssertNotNil(service.enterCompletion);
    service.enterCompletion(YES, nil);
    XCTestExpectation *completion = [self expectationWithDescription:@"Enter 后范围同步"];
    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertEqualObjects(service.events, (@[@"enter", @"range:0.5:5.0"]));
        [page ensureDeviceCameraEntered];
        [page sendCameraRange];
        XCTAssertEqual(service.events.count, 2u);
        [page setValue:@4 forKey:@"configurationGeneration"];
        [page setValue:@YES forKey:@"zoomRangePending"];
        [page sendCameraRange];
        [page sendCameraRange];
        XCTAssertEqual(service.events.count, 3u);
        [completion fulfill];
    });
    [self waitForExpectations:@[completion] timeout:1];
}

// 准备期间返回拍照必须取消开始请求，不能在晚权限回调后开始录制。
- (void)testPhotoModeCancelsPendingRecordingPreparation {
    TSCameraPageSpy *page = [self readyPage];
    [page setValue:@YES forKey:@"pendingStartRecording"];
    [page setValue:@2 forKey:@"phase"]; // preparingRecording
    [page setValue:@YES forKey:@"microphoneRequestPending"];
    [page handleAction:TSCameraActionEnterPhotoMode fromDevice:YES];
    XCTAssertFalse([[page valueForKey:@"pendingStartRecording"] boolValue]);
    XCTAssertTrue([[page valueForKey:@"returnToPhoto"] boolValue]);
    XCTAssertEqual(page.stopRequests, 1u);
    XCTAssertTrue(page.lastActionFromDevice);
    XCTAssertEqual(page.recordingRequests, 0u);
}

// 配置输出期间返回拍照也排队清理，不让配置完成回调重新开始录像。
- (void)testPhotoModeDuringBindingCancelsLateStart {
    TSCameraPageSpy *page = [self readyPage];
    [page setValue:@YES forKey:@"pendingStartRecording"];
    [page setValue:@1 forKey:@"phase"]; // configuring
    [page handleAction:TSCameraActionEnterPhotoMode fromDevice:YES];
    XCTAssertFalse([[page valueForKey:@"pendingStartRecording"] boolValue]);
    XCTAssertTrue([[page valueForKey:@"returnToPhoto"] boolValue]);
    XCTAssertEqual(page.recordingRequests, 0u);
}

// 权限弹窗尚未返回时停止仍取消开始请求，不访问真实录制输出。
- (void)testStopCancelsPendingPermissionStart {
    TSCameraPageSpy *page = [self readyPage];
    page.performRealStop = YES;
    [page setValue:@YES forKey:@"pendingStartRecording"];
    [page setValue:@YES forKey:@"microphoneRequestPending"];
    [page setValue:@2 forKey:@"phase"];
    [page handleAction:TSCameraActionStopRecording fromDevice:YES];
    XCTAssertFalse([[page valueForKey:@"pendingStartRecording"] boolValue]);
    XCTAssertEqual([[page valueForKey:@"phase"] integerValue], 0);
    XCTAssertEqual(page.outboundActions.count, 0u);
}

// 权限等待期间退出优先于晚开始回调，退出来源仍保留设备标记。
- (void)testExitCancelsPendingPermissionStart {
    TSCameraPageSpy *page = [self readyPage];
    page.performRealStop = YES;
    [page setValue:@YES forKey:@"pendingStartRecording"];
    [page setValue:@YES forKey:@"microphoneRequestPending"];
    [page setValue:@2 forKey:@"phase"];
    [page handleAction:TSCameraActionExitCamera fromDevice:YES];
    XCTAssertFalse([[page valueForKey:@"pendingStartRecording"] boolValue]);
    XCTAssertTrue([[page valueForKey:@"closeRequested"] boolValue]);
    XCTAssertTrue([[page valueForKey:@"closeFromDevice"] boolValue]);
    XCTAssertEqual(page.outboundActions.count, 0u);
}


// 本地开始后换设备，迟到 didStart 不能向新设备发送开始录像。
- (void)testLateRecordingStartCannotNotifyAnotherConnection {
    TSCameraPageSpy *page = [self readyPage];
    TSCameraServiceSpy *original = [[TSCameraServiceSpy alloc] init];
    TSCameraServiceSpy *replacement = [[TSCameraServiceSpy alloc] init];
    [page setValue:replacement forKey:@"cameraService"];
    [page setValue:@8 forKey:@"connectionGeneration"];
    [page setValue:original forKey:@"recordingOriginService"];
    [page setValue:@7 forKey:@"recordingConnectionGeneration"];
    [page notifyRecordingStartedIfCurrent];
    XCTAssertEqual(page.outboundActions.count, 0u);
    [page setValue:@7 forKey:@"connectionGeneration"];
    [page notifyRecordingStartedIfCurrent];
    XCTAssertEqual(page.outboundActions.count, 0u);
    [page setValue:original forKey:@"cameraService"];
    [page notifyRecordingStartedIfCurrent];
    XCTAssertEqualObjects(page.outboundActions, (@[@(TSCameraActionStartRecording)]));
}

// 保存失败跨连接重试成功不通知新设备，同一连接保留拍照结果通知。
- (void)testRetriedPhotoResultCannotNotifyAnotherConnection {
    TSCameraPageSpy *page = [self readyPage];
    TSCameraServiceSpy *original = [[TSCameraServiceSpy alloc] init];
    TSCameraServiceSpy *replacement = [[TSCameraServiceSpy alloc] init];
    [page setValue:replacement forKey:@"cameraService"];
    [page setValue:@8 forKey:@"connectionGeneration"];
    [page setValue:original forKey:@"photoOriginService"];
    [page setValue:@7 forKey:@"photoNotificationGeneration"];
    [page setValue:@YES forKey:@"pendingPhotoNotification"];
    [page notifyPhotoResultIfCurrent];
    XCTAssertEqual(page.outboundActions.count, 0u);
    XCTAssertFalse([[page valueForKey:@"pendingPhotoNotification"] boolValue]);
    [page setValue:original forKey:@"cameraService"];
    [page setValue:@7 forKey:@"connectionGeneration"];
    [page setValue:@YES forKey:@"pendingPhotoNotification"];
    [page notifyPhotoResultIfCurrent];
    XCTAssertEqualObjects(page.outboundActions, (@[@(TSCameraActionTakePhoto)]));
}

// 旧关闭和配置完成回调不能向新设备发送退出、模式和镜头状态。
- (void)testLateCloseAndConfigurationNotificationsKeepOriginalOwner {
    TSCameraPageSpy *page = [self readyPage];
    TSCameraServiceSpy *original = [[TSCameraServiceSpy alloc] init];
    TSCameraServiceSpy *replacement = [[TSCameraServiceSpy alloc] init];
    [page setValue:replacement forKey:@"cameraService"];
    [page setValue:@8 forKey:@"connectionGeneration"];
    for (NSNumber *action in @[@0, @3, @4, @8, @9]) {
        [page notifyDevice:action.integerValue originService:(id<TSCameraInterface>)original generation:7];
    }
    XCTAssertEqual(page.outboundActions.count, 0u);
    [page setValue:original forKey:@"cameraService"];
    [page setValue:@7 forKey:@"connectionGeneration"];
    [page notifyDevice:TSCameraActionExitCamera originService:(id<TSCameraInterface>)original generation:7];
    XCTAssertEqualObjects(page.outboundActions, (@[@(TSCameraActionExitCamera)]));
}

// 不能仅凭 SDK 启动成功宣称送帧：输出连接不活动时必须暂停。
- (void)testPreviewRequiresActualFrameOutput {
    TSCameraPageSpy *page = [self readyPage];
    XCTAssertFalse([page canFeedPreviewInVideoMode:NO connectionActive:NO]);
    XCTAssertFalse([page canFeedPreviewInVideoMode:YES connectionActive:NO]);
    XCTAssertTrue([page canFeedPreviewInVideoMode:NO connectionActive:YES]);
    if (@available(iOS 16.0, *)) {
        XCTAssertTrue([page canFeedPreviewInVideoMode:YES connectionActive:YES]);
    } else {
        XCTAssertFalse([page canFeedPreviewInVideoMode:YES connectionActive:YES]);
    }
}

// 即便系统列表顺序不同，优先选择未压缩 8-bit NV12 full-range。
- (void)testPreviewPixelFormatPrefersFullRangeNV12 {
    TSCameraPageSpy *page = [self readyPage];
    NSNumber *format = [page preferredPreviewPixelFormatFromAvailableFormats:
        @[@(kCVPixelFormatType_420YpCbCr8Planar), @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange),
          @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]];
    XCTAssertEqualObjects(format, @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange));
}

// 缺少 full-range NV12 时优先 video-range NV12，优先级高于 I420。
- (void)testPreviewPixelFormatFallsBackToVideoRangeNV12 {
    TSCameraPageSpy *page = [self readyPage];
    NSNumber *format = [page preferredPreviewPixelFormatFromAvailableFormats:
        @[@(kCVPixelFormatType_420YpCbCr8PlanarFullRange), @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]];
    XCTAssertEqualObjects(format, @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange));
}

// 两种 NV12 均不可用时仅退到 SDK 支持的 I420。
- (void)testPreviewPixelFormatFallsBackToI420 {
    TSCameraPageSpy *page = [self readyPage];
    XCTAssertEqualObjects([page preferredPreviewPixelFormatFromAvailableFormats:
        @[@(kCVPixelFormatType_420YpCbCr8Planar), @(kCVPixelFormatType_420YpCbCr8PlanarFullRange)]],
        @(kCVPixelFormatType_420YpCbCr8PlanarFullRange));
    XCTAssertEqualObjects([page preferredPreviewPixelFormatFromAvailableFormats:
        @[@(kCVPixelFormatType_420YpCbCr8Planar)]], @(kCVPixelFormatType_420YpCbCr8Planar));
}

// 无可处理格式时明确返回不可推流，不把默认 BGRA 或 10-bit 当作 YUV。
- (void)testPreviewPixelFormatRejectsUnsupportedOrEmptyLists {
    TSCameraPageSpy *page = [self readyPage];
    XCTAssertNil([page preferredPreviewPixelFormatFromAvailableFormats:@[]]);
    XCTAssertNil([page preferredPreviewPixelFormatFromAvailableFormats:
        @[@(kCVPixelFormatType_32BGRA), @(kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange)]]);
}

// 待机录像输出可直接开始，不重绑、不发范围，也不覆盖用户已选倍率与补光。
- (void)testReadyVideoRecordingStartsWithoutRebindingOrRangeNotification {
    TSCameraPageSpy *page = [self readyPage];
    TSCameraServiceSpy *service = [[TSCameraServiceSpy alloc] init];
    BOOL audioAuthorized = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio] ==
        AVAuthorizationStatusAuthorized;
    [page setValue:service forKey:@"cameraService"];
    [page setValue:@7 forKey:@"connectionGeneration"];
    [page setValue:service forKey:@"recordingRequestService"];
    [page setValue:@7 forKey:@"recordingRequestGeneration"];
    [page setValue:@YES forKey:@"videoModeSupported"];
    [page setValue:@YES forKey:@"videoMode"];
    [page setValue:[[AVCaptureMovieFileOutput alloc] init] forKey:@"movieOutput"];
    [page setValue:@(audioAuthorized) forKey:@"configuredAudioAuthorized"];
    [page setValue:@YES forKey:@"pendingStartRecording"];
    [page setValue:@2 forKey:@"currentZoomRatio"];
    [page setValue:@YES forKey:@"torchEnabled"];
    [page continueRecordingPreparation];
    XCTAssertEqual(page.movieStartRequests, 1u);
    XCTAssertEqual(page.configurationRequests, 0u);
    XCTAssertEqual(service.events.count, 0u);
    XCTAssertEqualWithAccuracy([[page valueForKey:@"currentZoomRatio"] doubleValue], 2, 0.001);
    XCTAssertTrue([[page valueForKey:@"torchEnabled"] boolValue]);
}

// 首次授权变化必须重绑音轨，授权状态未变才允许复用既有录像输出。
- (void)testChangedAudioAuthorizationRequiresRebinding {
    TSCameraPageSpy *page = [self readyPage];
    [page setValue:@YES forKey:@"videoMode"];
    [page setValue:[[AVCaptureMovieFileOutput alloc] init] forKey:@"movieOutput"];
    [page setValue:@NO forKey:@"configuredAudioAuthorized"];
    XCTAssertTrue([page canReuseRecordingConfigurationWithAudioAuthorized:NO]);
    XCTAssertFalse([page canReuseRecordingConfigurationWithAudioAuthorized:YES]);
    [page setValue:@YES forKey:@"configuredAudioAuthorized"];
    XCTAssertTrue([page canReuseRecordingConfigurationWithAudioAuthorized:YES]);
    XCTAssertFalse([page canReuseRecordingConfigurationWithAudioAuthorized:NO]);
}

@end

// 缩略图回归只访问每个测试自己的临时目录，不启动相机或申请相册权限。
@interface TSCameraThumbnailPageSpy : TSTakePhotoVC
// 待保存作品目录。
@property (nonatomic, strong) NSURL *testPendingDirectory;
// 最近成功作品缓存目录。
@property (nonatomic, strong) NSURL *testCacheDirectory;
// 恢复流程请求生成缩略图的实际文件。
@property (nonatomic, strong) NSURL *requestedThumbnailURL;
@end

@implementation TSCameraThumbnailPageSpy

// 隔离真实应用待保存文件。
- (NSURL *)retainedMediaDirectoryWithError:(NSError **)error {
    return self.testPendingDirectory;
}

// 隔离真实应用缓存文件。
- (NSURL *)recentMediaCacheDirectory {
    return self.testCacheDirectory;
}

// 恢复测试只记录请求，解码测试直接调用真实解码方法。
- (void)updateThumbnailForURL:(NSURL *)fileURL {
    self.requestedThumbnailURL = fileURL;
}

// 不加载拍摄界面。
- (void)refreshUI { }

// 不启动蓝牙预览。
- (void)startPreviewIfPossible { }

@end

@interface TSCameraThumbnailRegressionTests : XCTestCase
// 含唯一 UUID 的临时根目录。
@property (nonatomic, strong) NSURL *testRootDirectory;
// 不访问硬件的真实业务控制器子类。
@property (nonatomic, strong) TSCameraThumbnailPageSpy *page;
@end

@implementation TSCameraThumbnailRegressionTests

#pragma mark - 生命周期

// 每个用例独立创建文件系统夹具。
- (void)setUp {
    [super setUp];
    self.testRootDirectory = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES]
        URLByAppendingPathComponent:[@"TSCameraThumbnailTests-" stringByAppendingString:NSUUID.UUID.UUIDString]
        isDirectory:YES];
    self.page = [[TSCameraThumbnailPageSpy alloc] init];
    self.page.testPendingDirectory = [self.testRootDirectory URLByAppendingPathComponent:@"pending" isDirectory:YES];
    self.page.testCacheDirectory = [self.testRootDirectory URLByAppendingPathComponent:@"recent" isDirectory:YES];
    NSError *error = nil;
    XCTAssertTrue([NSFileManager.defaultManager createDirectoryAtURL:self.page.testPendingDirectory
        withIntermediateDirectories:YES attributes:nil error:&error], @"%@", error);
    error = nil;
    XCTAssertTrue([NSFileManager.defaultManager createDirectoryAtURL:self.page.testCacheDirectory
        withIntermediateDirectories:YES attributes:nil error:&error], @"%@", error);
}

// 只删除本用例创建的 UUID 目录。
- (void)tearDown {
    self.page = nil;
    [NSFileManager.defaultManager removeItemAtURL:self.testRootDirectory error:nil];
    self.testRootDirectory = nil;
    [super tearDown];
}

#pragma mark - 私有方法

// 生成有效的小 JPEG，同时足够大以验证 ImageIO 的尺寸限制。
- (NSData *)testJPEGData {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(640, 480), YES, 1);
    [UIColor.blueColor setFill];
    UIRectFill(CGRectMake(0, 0, 640, 480));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    XCTAssertGreaterThan(data.length, 0u);
    return data;
}

// 写入固定修改时间，目录排序不依赖执行速度。
- (NSURL *)writeMediaNamed:(NSString *)name directory:(NSURL *)directory
                     data:(NSData *)data modifiedAt:(NSTimeInterval)modifiedAt {
    NSURL *fileURL = [directory URLByAppendingPathComponent:name];
    NSError *error = nil;
    XCTAssertTrue([data writeToURL:fileURL options:NSDataWritingAtomic error:&error], @"%@", error);
    error = nil;
    XCTAssertTrue([NSFileManager.defaultManager setAttributes:
        @{NSFileModificationDate: [NSDate dateWithTimeIntervalSince1970:modifiedAt]}
        ofItemAtPath:fileURL.path error:&error], @"%@", error);
    return fileURL;
}

#pragma mark - 回归用例

// 移动后保留新缓存，删除旧缓存，同时不触碰其他待保存作品。
- (void)testSavedMediaMoveKeepsNewCacheAndRemovesOnlyOlderCache {
    NSData *imageData = [self testJPEGData];
    NSURL *oldCache = [self writeMediaNamed:@"older.jpg" directory:self.page.testCacheDirectory
        data:imageData modifiedAt:100];
    NSURL *source = [self writeMediaNamed:@"latest.jpg" directory:self.page.testPendingDirectory
        data:imageData modifiedAt:200];
    NSURL *otherPending = [self writeMediaNamed:@"still-pending.jpg" directory:self.page.testPendingDirectory
        data:imageData modifiedAt:150];
    [self.page setValue:source forKey:@"recentMediaURL"];
    [self.page moveSavedMediaToRecentCache:source];
    NSURL *destination = [self.page.testCacheDirectory URLByAppendingPathComponent:@"latest.jpg"];
    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:destination.path]);
    XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:source.path]);
    XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:oldCache.path]);
    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:otherPending.path]);
    XCTAssertEqualObjects([[self.page valueForKey:@"recentMediaURL"] path], destination.path);
    XCTAssertEqualObjects([NSData dataWithContentsOfURL:destination], imageData);
}

// 新页面恢复最近成功照片，较新的视频缓存随后正确替换 URL，均不误标为待保存。
- (void)testReenteredPageRestoresSavedPhotoAndLatestVideoURL {
    NSData *imageData = [self testJPEGData];
    NSURL *photo = [self writeMediaNamed:@"saved-photo.jpg" directory:self.page.testCacheDirectory
        data:imageData modifiedAt:100];
    [self.page restoreRecentMedia];
    XCTAssertEqualObjects([[self.page valueForKey:@"recentMediaURL"] path], photo.path);
    XCTAssertTrue([[self.page valueForKey:@"recentMediaSaved"] boolValue]);
    XCTAssertNil([self.page valueForKey:@"pendingMediaURL"]);
    XCTAssertEqualObjects(self.page.requestedThumbnailURL.path, photo.path);
    NSURL *video = [self writeMediaNamed:@"newer-video.mov" directory:self.page.testCacheDirectory
        data:[@"URL restore fixture; no video decoding" dataUsingEncoding:NSUTF8StringEncoding] modifiedAt:200];
    [self writeMediaNamed:@"ignored.txt" directory:self.page.testCacheDirectory data:imageData modifiedAt:300];
    [self.page restoreRecentMedia];
    XCTAssertEqualObjects([[self.page valueForKey:@"recentMediaURL"] path], video.path);
    XCTAssertTrue([[self.page valueForKey:@"recentMediaSaved"] boolValue]);
    XCTAssertNil([self.page valueForKey:@"pendingMediaURL"]);
    XCTAssertEqualObjects(self.page.requestedThumbnailURL.path, video.path);
    NSArray<NSURL *> *ordered = [self.page mediaURLsInDirectory:self.page.testCacheDirectory];
    XCTAssertEqual(ordered.count, 2u);
    XCTAssertEqualObjects(ordered.firstObject.path, video.path);
    XCTAssertEqualObjects(ordered.lastObject.path, photo.path);
}

// 即使成功缓存更新，未保存作品仍优先显示，并保留重试状态。
- (void)testPendingMediaTakesPriorityOverSavedCache {
    NSData *imageData = [self testJPEGData];
    NSURL *pending = [self writeMediaNamed:@"unsaved.jpg" directory:self.page.testPendingDirectory
        data:imageData modifiedAt:100];
    [self writeMediaNamed:@"newer-saved.jpg" directory:self.page.testCacheDirectory data:imageData modifiedAt:200];
    [self.page restoreRecentMedia];
    XCTAssertEqualObjects([[self.page valueForKey:@"pendingMediaURL"] path], pending.path);
    XCTAssertEqualObjects([[self.page valueForKey:@"recentMediaURL"] path], pending.path);
    XCTAssertFalse([[self.page valueForKey:@"recentMediaSaved"] boolValue]);
    XCTAssertEqualObjects(self.page.requestedThumbnailURL.path, pending.path);
    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:pending.path]);
}

// 真实 JPEG 解码产生可显示的小图，避免全尺寸照片占用过多内存。
- (void)testRealJPEGThumbnailDecodesWithinPixelLimit {
    NSURL *photo = [self writeMediaNamed:@"valid.jpg" directory:self.page.testCacheDirectory
        data:[self testJPEGData] modifiedAt:100];
    NSError *error = nil;
    UIImage *thumbnail = [self.page thumbnailImageForURL:photo error:&error];
    XCTAssertNotNil(thumbnail);
    XCTAssertNil(error);
    XCTAssertNotEqual(thumbnail.CGImage, NULL);
    if (thumbnail.CGImage) {
        XCTAssertGreaterThan(CGImageGetWidth(thumbnail.CGImage), 0u);
        XCTAssertGreaterThan(CGImageGetHeight(thumbnail.CGImage), 0u);
        XCTAssertLessThanOrEqual(CGImageGetWidth(thumbnail.CGImage), 320u);
        XCTAssertLessThanOrEqual(CGImageGetHeight(thumbnail.CGImage), 320u);
    }
}

// 非法文件明确返回错误，调用方不会把无图误当成功缩略图。
- (void)testInvalidImageReturnsErrorInsteadOfSilentNil {
    NSURL *invalid = [self writeMediaNamed:@"invalid.jpg" directory:self.page.testCacheDirectory
        data:[@"This is not a JPEG" dataUsingEncoding:NSUTF8StringEncoding] modifiedAt:100];
    NSError *error = nil;
    UIImage *thumbnail = [self.page thumbnailImageForURL:invalid error:&error];
    XCTAssertNil(thumbnail);
    XCTAssertNotNil(error);
    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:invalid.path]);
}

// 同一作品再次解码失败时，不清空此前已经可用的封面。
- (void)testFailedThumbnailRefreshKeepsExistingImageForSameMedia {
    TSCameraPageSpy *page = [[TSCameraPageSpy alloc] init];
    dispatch_queue_t captureQueue = dispatch_queue_create("com.topstep.tests.thumbnail.same-media", DISPATCH_QUEUE_SERIAL);
    [page setValue:captureQueue forKey:@"captureQueue"];
    NSURL *fileURL = [self writeMediaNamed:@"same-media.jpg" directory:self.page.testCacheDirectory
        data:[@"Invalid JPEG after an earlier successful decode" dataUsingEncoding:NSUTF8StringEncoding]
        modifiedAt:100];
    UIImage *existingImage = [UIImage imageWithData:[self testJPEGData]];
    XCTAssertNotNil(existingImage);
    [page setValue:fileURL forKey:@"recentMediaURL"];
    [page setValue:fileURL.lastPathComponent forKey:@"thumbnailMediaIdentifier"];
    [page setValue:existingImage forKey:@"recentThumbnail"];
    XCTestExpectation *completion = [self expectationWithDescription:@"同作品失败结果不清空封面"];
    [page updateThumbnailForURL:fileURL];
    dispatch_async(captureQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            XCTAssertEqual([page valueForKey:@"recentThumbnail"], existingImage);
            XCTAssertEqualObjects([[page valueForKey:@"recentMediaURL"] path], fileURL.path);
            [completion fulfill];
        });
    });
    [self waitForExpectations:@[completion] timeout:3];
}

// 旧作品成功回调到达时新作品已选中，即使新图失败也不得显示旧作品封面。
- (void)testLateThumbnailSuccessCannotReplaceNewMediaWithFailedThumbnail {
    TSCameraPageSpy *page = [[TSCameraPageSpy alloc] init];
    dispatch_queue_t captureQueue = dispatch_queue_create("com.topstep.tests.thumbnail.changed-media", DISPATCH_QUEUE_SERIAL);
    [page setValue:captureQueue forKey:@"captureQueue"];
    NSURL *oldURL = [self writeMediaNamed:@"previous-media.jpg" directory:self.page.testCacheDirectory
        data:[self testJPEGData] modifiedAt:100];
    NSURL *newURL = [self writeMediaNamed:@"current-media.jpg" directory:self.page.testCacheDirectory
        data:[@"Invalid current JPEG" dataUsingEncoding:NSUTF8StringEncoding] modifiedAt:200];
    XCTestExpectation *completion = [self expectationWithDescription:@"旧异步封面不覆盖新作品"];
    dispatch_suspend(captureQueue);
    @try {
        [page setValue:oldURL forKey:@"recentMediaURL"];
        [page updateThumbnailForURL:oldURL];
        [page setValue:newURL forKey:@"recentMediaURL"];
        [page updateThumbnailForURL:newURL];
        dispatch_async(captureQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                XCTAssertNil([page valueForKey:@"recentThumbnail"]);
                XCTAssertEqualObjects([[page valueForKey:@"recentMediaURL"] path], newURL.path);
                XCTAssertEqualObjects([page valueForKey:@"thumbnailMediaIdentifier"], newURL.lastPathComponent);
                [completion fulfill];
            });
        });
    } @finally {
        dispatch_resume(captureQueue);
    }
    [self waitForExpectations:@[completion] timeout:3];
}

@end

// 预览回归保留真实媒体验证和控制器构造，替换所有硬件与实际呈现操作。
@interface TSCameraMediaPreviewPageSpy : TSCameraPageSpy
// 业务创建并请求呈现的控制器。
@property (nonatomic, strong) UIViewController *requestedMediaController;
// 验证失败时收到的真实业务错误。
@property (nonatomic, strong) NSError *previewError;
// 当前错误报告次数。
@property (nonatomic, assign) NSUInteger previewErrorCount;
// 请求实际呈现的次数。
@property (nonatomic, assign) NSUInteger presentationRequests;
// 清理后请求恢复相机的次数。
@property (nonatomic, assign) NSUInteger resumeRequests;
// 请求消费排队关闭或模式切换的次数。
@property (nonatomic, assign) NSUInteger transitionRequests;
// 允许转发的设备退出次数。
@property (nonatomic, assign) NSUInteger closeRequests;
// 是否收到设备来源的退出。
@property (nonatomic, assign) BOOL closeRequestedFromDevice;
// 防止作品页背后误触发真实拍照。
@property (nonatomic, assign) NSUInteger photoRequests;
@end

@implementation TSCameraMediaPreviewPageSpy

// 不呈现真实界面，不暂停硬件，不启动播放或配置音频会话。
- (void)beginMediaPreviewWithController:(UIViewController *)controller {
    self.requestedMediaController = controller;
    self.presentationRequests += 1;
}

// 错误报告保留业务 NSError，避免 Toast 加载页面。
- (void)reportError:(NSError *)error fallback:(NSString *)fallback {
    self.previewError = error;
    self.previewErrorCount += 1;
}

// 记录恢复请求，不启动采集或 BLE。
- (void)resumeCaptureIfPossible {
    self.resumeRequests += 1;
}

// 不进入真实导航退出或配置流程。
- (void)finishPendingTransition {
    self.transitionRequests += 1;
}

// 只记录允许的退出动作，不实际关闭测试页面。
- (void)requestCloseFromDevice:(BOOL)fromDevice {
    self.closeRequests += 1;
    self.closeRequestedFromDevice = fromDevice;
}

// 如果拦截失效，只计数以暴露回归，不申请相机权限。
- (void)takePhoto {
    self.photoRequests += 1;
}

@end

@interface TSCameraMediaPreviewRegressionTests : XCTestCase
// 每个用例独享的媒体目录。
@property (nonatomic, strong) NSURL *mediaDirectory;
// 不访问硬件的真实业务子类。
@property (nonatomic, strong) TSCameraMediaPreviewPageSpy *page;
@end

@implementation TSCameraMediaPreviewRegressionTests

#pragma mark - 生命周期

// 夹具只创建 UUID 临时目录，不碰应用媒体缓存。
- (void)setUp {
    [super setUp];
    self.mediaDirectory = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES]
        URLByAppendingPathComponent:[@"TSCameraMediaPreviewTests-" stringByAppendingString:NSUUID.UUID.UUIDString]
        isDirectory:YES];
    NSError *error = nil;
    XCTAssertTrue([NSFileManager.defaultManager createDirectoryAtURL:self.mediaDirectory
        withIntermediateDirectories:YES attributes:nil error:&error], @"%@", error);
    self.page = [[TSCameraMediaPreviewPageSpy alloc] init];
    [self.page setValue:@YES forKey:@"pageVisible"];
    [self.page setValue:@YES forKey:@"cameraAuthorized"];
    [self.page setValue:@YES forKey:@"sessionReady"];
    [self.page setValue:@YES forKey:@"deviceReady"];
}

// 释放播放器结构，并仅删除本用例创建的文件。
- (void)tearDown {
    self.page = nil;
    [NSFileManager.defaultManager removeItemAtURL:self.mediaDirectory error:nil];
    self.mediaDirectory = nil;
    [super tearDown];
}

#pragma mark - 私有方法

// 生成真实 JPEG，照片预览必须经业务方法实际解码。
- (NSData *)previewJPEGData {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 80), YES, 1);
    [UIColor.greenColor setFill];
    UIRectFill(CGRectMake(0, 0, 120, 80));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    XCTAssertGreaterThan(data.length, 0u);
    return data;
}

// 测试仅向自己的临时目录写入文件。
- (NSURL *)writePreviewFileNamed:(NSString *)name data:(NSData *)data {
    NSURL *fileURL = [self.mediaDirectory URLByAppendingPathComponent:name];
    NSError *error = nil;
    XCTAssertTrue([data writeToURL:fileURL options:NSDataWritingAtomic error:&error], @"%@", error);
    return fileURL;
}

#pragma mark - 预览回归

// 缓存被系统清除后，不能弹出空的照片预览。
- (void)testMissingPreviewFileReportsErrorWithoutPresentation {
    NSURL *missing = [self.mediaDirectory URLByAppendingPathComponent:@"deleted.jpg"];
    [self.page presentMediaAtURL:missing];
    XCTAssertEqual(self.page.presentationRequests, 0u);
    XCTAssertNil(self.page.requestedMediaController);
    XCTAssertEqual(self.page.previewErrorCount, 1u);
    XCTAssertNotNil(self.page.previewError);
}

// 空文件也不能作为可预览的最近作品。
- (void)testEmptyPreviewFileReportsErrorWithoutPresentation {
    NSURL *empty = [self writePreviewFileNamed:@"empty.jpg" data:NSData.data];
    [self.page presentMediaAtURL:empty];
    XCTAssertEqual(self.page.presentationRequests, 0u);
    XCTAssertNil(self.page.requestedMediaController);
    XCTAssertEqual(self.page.previewErrorCount, 1u);
    XCTAssertNotNil(self.page.previewError);
}

// 非空但无法解码的照片必须报告错误，而非进入黑屏。
- (void)testInvalidPhotoReportsErrorWithoutPresentation {
    NSURL *invalid = [self writePreviewFileNamed:@"invalid.jpg"
        data:[@"Not a decodable image" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.page presentMediaAtURL:invalid];
    XCTAssertEqual(self.page.presentationRequests, 0u);
    XCTAssertNil(self.page.requestedMediaController);
    XCTAssertEqual(self.page.previewErrorCount, 1u);
    XCTAssertNotNil(self.page.previewError);
}

// 有效照片使用全屏导航预览，真实 UIImage 存在并提供可关闭的返回入口。
- (void)testValidPhotoBuildsClosableFullscreenImagePreview {
    NSURL *photo = [self writePreviewFileNamed:@"photo.jpg" data:[self previewJPEGData]];
    [self.page setValue:@YES forKey:@"recentMediaSaved"];
    [self.page presentMediaAtURL:photo];
    XCTAssertEqual(self.page.presentationRequests, 1u);
    XCTAssertEqual(self.page.previewErrorCount, 0u);
    XCTAssertTrue([self.page.requestedMediaController isKindOfClass:UINavigationController.class]);
    UINavigationController *navigation = (UINavigationController *)self.page.requestedMediaController;
    XCTAssertEqual(navigation.modalPresentationStyle, UIModalPresentationFullScreen);
    UIViewController *preview = navigation.viewControllers.firstObject;
    XCTAssertNotNil(preview);
    XCTAssertTrue([preview.view isKindOfClass:UIImageView.class]);
    UIImageView *imageView = (UIImageView *)preview.view;
    XCTAssertNotNil(imageView.image);
    XCTAssertGreaterThan(imageView.image.size.width, 0);
    XCTAssertEqual(imageView.contentMode, UIViewContentModeScaleAspectFit);
    XCTAssertNotNil(preview.navigationItem.leftBarButtonItem);
    XCTAssertNotNil(preview.navigationItem.leftBarButtonItem.target);
    XCTAssertNotEqual(preview.navigationItem.leftBarButtonItem.action, NULL);
}

// 视频仅校验 AVKit 与原文件 URL 的构造；实际解码和带声音播放交由真机验证。
- (void)testVideoBuildsFullscreenSystemPlayerWithOriginalAssetURL {
    NSURL *video = [self writePreviewFileNamed:@"video.mov"
        data:[@"Nonempty AVKit construction fixture; playback is not executed" dataUsingEncoding:NSUTF8StringEncoding]];
    [self.page presentMediaAtURL:video];
    XCTAssertEqual(self.page.presentationRequests, 1u);
    XCTAssertTrue([self.page.requestedMediaController isKindOfClass:AVPlayerViewController.class]);
    AVPlayerViewController *controller = (AVPlayerViewController *)self.page.requestedMediaController;
    XCTAssertEqual(controller.modalPresentationStyle, UIModalPresentationFullScreen);
    XCTAssertFalse(controller.allowsPictureInPicturePlayback);
    XCTAssertNotNil(controller.player);
    XCTAssertNotNil(controller.player.currentItem);
    XCTAssertTrue([controller.player.currentItem.asset isKindOfClass:AVURLAsset.class]);
    AVURLAsset *asset = (AVURLAsset *)controller.player.currentItem.asset;
    XCTAssertEqualObjects(asset.URL.path, video.path);
}

// 预览上方不能触发拍照、变焦和开始录像，但停止及退出仍可清理。
- (void)testMediaPreviewBlocksCaptureActionsButAllowsCleanup {
    [self.page setValue:@YES forKey:@"mediaPreviewPresented"];
    [self.page setValue:@YES forKey:@"videoModeSupported"];
    [self.page handleAction:TSCameraActionTakePhoto fromDevice:YES];
    [self.page handleAction:TSCameraActionZoomRatioOneX fromDevice:YES];
    [self.page handleAction:TSCameraActionStartRecording fromDevice:YES];
    XCTAssertEqual(self.page.photoRequests, 0u);
    XCTAssertEqual(self.page.receivedZoomActions.count, 0u);
    XCTAssertEqual(self.page.recordingRequests, 0u);
    [self.page handleAction:TSCameraActionStopRecording fromDevice:YES];
    [self.page handleAction:TSCameraActionExitCamera fromDevice:YES];
    XCTAssertEqual(self.page.stopRequests, 1u);
    XCTAssertEqual(self.page.closeRequests, 1u);
    XCTAssertTrue(self.page.closeRequestedFromDevice);
    XCTAssertEqual(self.page.outboundActions.count, 0u);
}

// 完成预览必须清理播放器与控制器引用，回到可恢复拍摄的状态。
- (void)testFinishingMediaPreviewClearsPlaybackAndRequestsCaptureResume {
    [self.page setValue:@YES forKey:@"mediaPreviewPresented"];
    [self.page setValue:[[UIViewController alloc] init] forKey:@"mediaPreviewController"];
    NSURL *video = [self writePreviewFileNamed:@"cleanup.mov"
        data:[@"Player cleanup fixture" dataUsingEncoding:NSUTF8StringEncoding]];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:video];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    [self.page setValue:player forKey:@"mediaPreviewPlayer"];
    [self.page setValue:item forKey:@"mediaPreviewItem"];
    [self.page finishMediaPreview];
    XCTAssertFalse([[self.page valueForKey:@"mediaPreviewPresented"] boolValue]);
    XCTAssertNil([self.page valueForKey:@"mediaPreviewController"]);
    XCTAssertNil([self.page valueForKey:@"mediaPreviewPlayer"]);
    XCTAssertNil([self.page valueForKey:@"mediaPreviewItem"]);
    XCTAssertNil(player.currentItem);
    XCTAssertEqual(player.rate, 0);
    XCTAssertEqual(self.page.resumeRequests, 1u);
    [self.page finishMediaPreview];
    XCTAssertEqual(self.page.resumeRequests, 1u);
}

// 播放项在界面呈现前失败也应完整清理并反馈原始错误，晚回调不能重复恢复。
- (void)testPlaybackFailureBeforePresentationCleansStateAndReportsError {
    [self.page setValue:@YES forKey:@"mediaPreviewPresented"];
    [self.page setValue:[[UIViewController alloc] init] forKey:@"mediaPreviewController"];
    [self.page setValue:[[AVPlayer alloc] init] forKey:@"mediaPreviewPlayer"];
    NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorFileFormatNotRecognized
        userInfo:@{NSLocalizedDescriptionKey: @"Invalid movie fixture"}];
    XCTAssertNil(self.page.presentedViewController);
    [self.page handleMediaPlaybackError:error];
    XCTAssertFalse([[self.page valueForKey:@"mediaPreviewPresented"] boolValue]);
    XCTAssertNil([self.page valueForKey:@"mediaPreviewController"]);
    XCTAssertNil([self.page valueForKey:@"mediaPreviewPlayer"]);
    XCTAssertNil([self.page valueForKey:@"mediaPreviewItem"]);
    XCTAssertEqual(self.page.previewError, error);
    XCTAssertEqual(self.page.previewErrorCount, 1u);
    XCTAssertEqual(self.page.resumeRequests, 1u);
    [self.page handleMediaPlaybackError:error];
    XCTAssertEqual(self.page.previewErrorCount, 1u);
    XCTAssertEqual(self.page.resumeRequests, 1u);
}

@end
