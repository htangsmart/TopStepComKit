//
//  TSDialEditorVideoTests.m
//  TopStepComKit-Git_Tests
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import "../../TopStepComKit-Git/Source/Device/PeripheralDial/TSDialEditorVC.h"
#import "../../TopStepComKit-Git/Source/Device/PeripheralDial/TSDialEditorState.h"
#import "../../TopStepComKit-Git/Source/Device/PeripheralDial/TSDialImageCropVC.h"
#import "../../TopStepComKit-Git/Source/Device/PeripheralDial/TSDialPreviewView.h"

@interface TSDialEditorVC (VideoTesting)
- (void)exportVideoForState:(TSDialEditorState *)state completion:(void (^)(NSURL *, NSError *))completion;
- (void)completeVideoExportWithURL:(NSURL *)url error:(NSError *)error generation:(NSUInteger)generation;
- (void)cleanupExportedVideo;
- (TSPeripheralScreen *)videoCanvasForQuality:(TSDialQuality)quality;
- (BOOL)videoCropForState:(TSDialEditorState *)state matchesCanvas:(TSPeripheralScreen *)canvas;
- (void)selectQuality:(TSDialQuality)quality;
- (void)renderMediaOptions;
- (void)renderMaterial;
- (void)updatePreview;
@end

@interface TSDialImageCropVC (VideoTesting)
- (void)applyCrop;
@end

// 只提供公开只读字段的测试值，不导入 SDK 内部构造器或任何 Provider。
@interface TSDialEditorRequirementsFixture : NSObject
// 成品画布、上限和外形。
@property (nonatomic, assign) CGSize inputPixelSize;
@property (nonatomic, assign) NSTimeInterval maxDuration;
@property (nonatomic, assign) TSPeriphShape inputShape;
@property (nonatomic, assign) CGFloat cornerRadius;
// 是否允许导出首音轨。
@property (nonatomic, assign) BOOL supportsAudio;
@end
@implementation TSDialEditorRequirementsFixture
@end

// 只提供当前画质的公开查询结果，不使用 SDK 私有能力构造器。
@interface TSDialEditorCapabilityFixture : NSObject
// 每种画质各自的只读规格测试值。
@property (nonatomic, copy) NSDictionary<NSNumber *, TSDialEditorRequirementsFixture *> *requirements;
@end
@implementation TSDialEditorCapabilityFixture
- (TSDialVideoRequirements *)videoRequirementsForQuality:(TSDialQuality)quality {
    return (TSDialVideoRequirements *)self.requirements[@(quality)];
}
@end

// 截获模态页面，保留真实裁剪控制器和确认回调，不连接设备或弹出系统 UI。
@interface TSDialEditorCropFixtureVC : TSDialEditorVC
// 捕获待确认页面，不启动真实模态转场。
@property (nonatomic, strong) UIViewController *capturedPresentation;
@end
@implementation TSDialEditorCropFixtureVC
- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    self.capturedPresentation = viewController;
    if (completion) { completion(); }
}
- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    self.capturedPresentation = nil;
    if (completion) { completion(); }
}
- (void)renderMediaOptions {}
- (void)renderMaterial {}
- (void)updatePreview {}
@end

@interface TSDialEditorVideoTests : XCTestCase
// 本例实际媒体目录与编辑器，不读取或连接设备。
@property (nonatomic, strong) NSURL *directoryURL;
@property (nonatomic, strong) TSDialEditorVC *editor;
@property (nonatomic, strong) TSDialEditorState *state;
@property (nonatomic, strong) TSDialEditorRequirementsFixture *requirements;
// Demo 导出到 NSTemporaryDirectory 的文件也由本例登记回收。
@property (nonatomic, strong) NSMutableArray<NSURL *> *outputs;
@end

@implementation TSDialEditorVideoTests

#pragma mark - 生命周期

// 每例生成带旋转元数据和时间颜色标记的真实视频。
- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    self.directoryURL = [NSURL fileURLWithPath:
        [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString] isDirectory:YES];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtURL:self.directoryURL
        withIntermediateDirectories:YES attributes:nil error:nil]);
    self.outputs = [NSMutableArray array];
    self.state = [[TSDialEditorState alloc] init];
    self.state.videoURL = [self createSourceVideo];
    self.state.videoDuration = 1;
    self.state.videoStart = 0.5;
    self.state.videoEnd = 1;
    self.state.images = @[@{@"crop":NSStringFromCGRect(CGRectZero)}];
    self.editor = [[TSDialEditorVC alloc] initWithState:self.state];
    self.requirements = [[TSDialEditorRequirementsFixture alloc] init];
    self.requirements.inputPixelSize = CGSizeMake(32, 32);
    self.requirements.maxDuration = 2;
    self.requirements.inputShape = eTSPeriphShapeSquare;
    [self.editor setValue:self.requirements forKey:@"installationVideoRequirements"];
}

// 取消仍在进行的导出，并只删除本例所有的临时素材。
- (void)tearDown {
    [(AVAssetExportSession *)[self.editor valueForKey:@"exportSession"] cancelExport];
    self.editor = nil;
    for (NSURL *url in self.outputs) { [[NSFileManager defaultManager] removeItemAtURL:url error:nil]; }
    [[NSFileManager defaultManager] removeItemAtURL:self.directoryURL error:nil];
    [super tearDown];
}

#pragma mark - 测试

// 视频几何来自选定画质，不复用或修改共享设备屏幕；无规格时保留旧屏幕回退。
- (void)testVideoCanvasUsesSelectedRequirementsWithoutMutatingDeviceScreen {
    TSPeripheralScreen *device = [[TSPeripheralScreen alloc] init];
    device.screenSize = CGSizeMake(401, 501);
    device.shape = eTSPeriphShapeVerticalRectangle;
    device.screenBorderRadius = 31;
    [self.editor setValue:device forKey:@"screen"];
    self.requirements.inputPixelSize = CGSizeMake(48, 32);
    self.requirements.inputShape = eTSPeriphShapeCircle;
    self.requirements.cornerRadius = 7;
    TSDialEditorCapabilityFixture *capability = [[TSDialEditorCapabilityFixture alloc] init];
    capability.requirements = @{@(TSDialQualityLossless):self.requirements};
    [self.editor setValue:capability forKey:@"capability"];
    TSPeripheralScreen *canvas = [self.editor videoCanvasForQuality:TSDialQualityLossless];
    XCTAssertNotEqual(canvas, device);
    XCTAssertTrue(CGSizeEqualToSize(canvas.screenSize, CGSizeMake(48, 32)));
    XCTAssertEqual(canvas.shape, eTSPeriphShapeCircle);
    XCTAssertEqual(canvas.screenBorderRadius, 7);
    XCTAssertFalse([self.editor videoCropForState:self.state matchesCanvas:canvas]);
    XCTAssertTrue(CGSizeEqualToSize(device.screenSize, CGSizeMake(401, 501)));
    XCTAssertEqual(device.shape, eTSPeriphShapeVerticalRectangle);
    XCTAssertEqual(device.screenBorderRadius, 31);
    TSPeripheralScreen *legacy = [self.editor videoCanvasForQuality:TSDialQualityDefault];
    XCTAssertNotEqual(legacy, device);
    XCTAssertTrue(CGSizeEqualToSize(legacy.screenSize, device.screenSize));
}

// 新比例尽量保留原选区和中心，取消不改状态，明确确认后才原子提交画质与画布记录。
- (void)testQualityCanvasChangeRequiresConfirmationAndCancellationKeepsOriginalCrop {
    [self.state setValue:@(TSDialDraftTypeVideo) forKey:@"draftType"];
    CGRect originalCrop = CGRectMake(0.25, 1.0 / 3, 0.5, 1.0 / 3);
    self.state.images = @[@{@"crop":NSStringFromCGRect(originalCrop),
        @"videoCanvasSize":NSStringFromCGSize(CGSizeMake(32, 32)),
        @"videoCanvasShape":@(eTSPeriphShapeSquare), @"videoCanvasRadius":@0}];
    NSArray *originalRecords = self.state.images;
    self.requirements.inputPixelSize = CGSizeMake(48, 32);
    TSDialEditorCapabilityFixture *capability = [[TSDialEditorCapabilityFixture alloc] init];
    capability.requirements = @{@(TSDialQualityLossless):self.requirements};
    TSDialEditorCropFixtureVC *editor = [[TSDialEditorCropFixtureVC alloc] initWithState:self.state];
    [editor setValue:capability forKey:@"capability"];
    [editor selectQuality:TSDialQualityLossless];
    TSDialImageCropVC *crop = (id)((UINavigationController *)editor.capturedPresentation).topViewController;
    XCTAssertNotNil(crop);
    XCTAssertTrue(crop.usesVideoCanvas);
    XCTAssertEqual(self.state.quality, TSDialQualityDefault);
    XCTAssertEqualObjects(self.state.images, originalRecords);
    XCTAssertTrue([crop.title containsString:@"确认"]);
    crop.onCropCancelled();
    XCTAssertEqual(self.state.quality, TSDialQualityDefault);
    XCTAssertEqualObjects(self.state.images, originalRecords);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.state.videoURL.path]);

    [editor selectQuality:TSDialQualityLossless];
    crop = (id)((UINavigationController *)editor.capturedPresentation).topViewController;
    [crop loadViewIfNeeded];
    crop.view.frame = CGRectMake(0, 0, 390, 844);
    [crop.view setNeedsLayout];
    [crop.view layoutIfNeeded];
    [crop applyCrop];
    XCTAssertEqual(self.state.quality, TSDialQualityLossless);
    TSPeripheralScreen *canvas = [editor videoCanvasForQuality:TSDialQualityLossless];
    XCTAssertTrue([editor videoCropForState:self.state matchesCanvas:canvas]);
    CGRect confirmed = CGRectFromString(self.state.images.firstObject[@"crop"]);
    XCTAssertEqualWithAccuracy(CGRectGetMidX(confirmed), CGRectGetMidX(originalCrop), 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(confirmed), CGRectGetMidY(originalCrop), 0.001);
    XCTAssertGreaterThanOrEqual(confirmed.size.width + 0.001, originalCrop.size.width);
    XCTAssertGreaterThanOrEqual(confirmed.size.height + 0.001, originalCrop.size.height);
    XCTAssertEqualWithAccuracy(confirmed.size.width * 64 / (confirmed.size.height * 96), 1.5, 0.001);
}

// 旧记录不能绕过安装前校验进入导出，更不能把旧比例静默拉伸成新画布。
- (void)testUnconfirmedLegacyCropIsRejectedBeforePreparedExport {
    self.state.images = @[@{@"crop":NSStringFromCGRect(CGRectMake(0, 0, 0.5, 0.5))}];
    __block NSUInteger callbacks = 0;
    [self.editor exportVideoForState:self.state completion:^(NSURL *url, NSError *error) {
        callbacks++;
        XCTAssertNil(url);
        XCTAssertNotNil(error);
        XCTAssertTrue([error.localizedDescription containsString:@"确认"]);
    }];
    XCTAssertEqual(callbacks, 1u);
    XCTAssertNil([self.editor valueForKey:@"exportSession"]);
}

// 只改变画布也必须重建播放合成，非正方形圆画布的播放器遮罩使用居中短边圆。
- (void)testVideoPreviewRefreshesCompositionWhenCanvasChanges {
    [self.state setValue:@(TSDialDraftTypeVideo) forKey:@"draftType"];
    self.state.images = @[@{@"crop":NSStringFromCGRect(CGRectMake(0.25, 1.0 / 3, 0.5, 1.0 / 3))}];
    TSDialPreviewView *preview = [[TSDialPreviewView alloc] initWithFrame:CGRectMake(0, 0, 390, 300)];
    TSPeripheralScreen *canvas = [[TSPeripheralScreen alloc] init];
    canvas.screenSize = CGSizeMake(32, 32);
    canvas.shape = eTSPeriphShapeCircle;
    [preview configureWithState:self.state screen:canvas constraint:nil timeImage:nil];
    AVPlayer *before = [preview valueForKey:@"player"];
    XCTAssertTrue(CGSizeEqualToSize(before.currentItem.videoComposition.renderSize, CGSizeMake(32, 32)));
    canvas.screenSize = CGSizeMake(48, 32);
    [preview configureWithState:self.state screen:canvas constraint:nil timeImage:nil];
    [preview layoutIfNeeded];
    AVPlayer *after = [preview valueForKey:@"player"];
    XCTAssertNotEqual(before, after);
    XCTAssertTrue(CGSizeEqualToSize(after.currentItem.videoComposition.renderSize, CGSizeMake(48, 32)));
    UIView *screen = [preview valueForKey:@"screenView"];
    XCTAssertEqualWithAccuracy(CGRectGetWidth(screen.bounds) / CGRectGetHeight(screen.bounds), 1.5, 0.001);
    AVPlayerLayer *layer = [preview valueForKey:@"playerLayer"];
    CGRect circle = CGPathGetBoundingBox(((CAShapeLayer *)layer.mask).path);
    XCTAssertEqualWithAccuracy(circle.size.width, circle.size.height, 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetMidX(circle), CGRectGetMidX(screen.bounds), 0.001);
    XCTAssertEqualWithAccuracy(CGRectGetMidY(circle), CGRectGetMidY(screen.bounds), 0.001);
}

// 真实视频导出应使用最终画布和选段，圆/圆角黑边必须存在于文件像素中。
- (void)testPreparedSizeClipAndMasksAreBakedWithoutChangingSource {
    NSData *source = [NSData dataWithContentsOfURL:self.state.videoURL];
    for (NSNumber *circle in @[@YES, @NO]) {
        self.requirements.inputShape = circle.boolValue ? eTSPeriphShapeCircle : eTSPeriphShapeSquare;
        self.requirements.cornerRadius = circle.boolValue ? 0 : 10;
        NSURL *output = [self exportCurrentState];
        AVURLAsset *asset = [AVURLAsset assetWithURL:output];
        AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        XCTAssertTrue(CGSizeEqualToSize(track.naturalSize, CGSizeMake(32, 32)));
        XCTAssertEqualWithAccuracy(CMTimeGetSeconds(asset.duration), 0.5, 1.0 / 12);
        NSData *rgba = [self firstFrameRGBA:output];
        const uint8_t *pixels = rgba.bytes;
        XCTAssertLessThan(pixels[0] + pixels[1] + pixels[2], 45);
        NSUInteger center = (16 * 32 + 16) * 4;
        XCTAssertGreaterThan(pixels[center + 2], 180);
        XCTAssertLessThan(pixels[center], 60);
    }
    XCTAssertEqualObjects(source, [NSData dataWithContentsOfURL:self.state.videoURL]);
}

// 非正方形画布短边决定圆直径，两侧应留下真实黑色区域，不能拉成椭圆。
- (void)testNonSquareCircularCanvasUsesCenteredCircleInsteadOfEllipse {
    self.requirements.inputPixelSize = CGSizeMake(48, 32);
    self.requirements.inputShape = eTSPeriphShapeCircle;
    NSURL *output = [self exportCurrentState];
    AVAssetTrack *track = [[AVURLAsset assetWithURL:output] tracksWithMediaType:AVMediaTypeVideo].firstObject;
    XCTAssertTrue(CGSizeEqualToSize(track.naturalSize, CGSizeMake(48, 32)));
    NSData *rgba = [self firstFrameRGBA:output];
    const uint8_t *pixels = rgba.bytes;
    NSUInteger margin = (16 * 48 + 2) * 4;
    NSUInteger center = (16 * 48 + 24) * 4;
    XCTAssertLessThan(pixels[margin] + pixels[margin + 1] + pixels[margin + 2], 45);
    XCTAssertGreaterThan(pixels[center + 2], 180);
    XCTAssertLessThan(pixels[center], 60);
}

// 有声成品由 App 产生；切换静音后实际文件不能残留音轨。
- (void)testAllowedAudioSelectionProducesAudibleOrSilentPreparedFile {
    self.state.videoURL = [self sourceByAddingAudio:self.state.videoURL];
    self.requirements.supportsAudio = YES;
    for (NSNumber *selection in @[@(TSDialEditorVideoAudioSelectionAutomatic),
        @(TSDialEditorVideoAudioSelectionMuted), @(TSDialEditorVideoAudioSelectionPreserveFirstTrack)]) {
        self.state.videoAudioSelection = selection.integerValue;
        NSURL *output = [self exportCurrentState];
        NSUInteger audioCount = [[AVURLAsset assetWithURL:output] tracksWithMediaType:AVMediaTypeAudio].count;
        XCTAssertEqual(audioCount, selection.integerValue == TSDialEditorVideoAudioSelectionMuted ? 0u : 1u);
    }
}

// 不允许音轨时，旧保存的“保留音轨”选择也不能带进提交文件。
- (void)testSilentRequirementsOverrideSavedPreserveSelection {
    self.state.videoURL = [self sourceByAddingAudio:self.state.videoURL];
    self.state.videoAudioSelection = TSDialEditorVideoAudioSelectionPreserveFirstTrack;
    NSURL *output = [self exportCurrentState];
    XCTAssertEqual([[AVURLAsset assetWithURL:output] tracksWithMediaType:AVMediaTypeAudio].count, 0u);
}

// 尚未实现新合同的旧 Provider 继续按原屏幕尺寸导出无音轨视频。
- (void)testNilRequirementsRetainLegacyScreenExport {
    [self.editor setValue:nil forKey:@"installationVideoRequirements"];
    TSCustomDialStyleConstraint *constraint = [[TSCustomDialStyleConstraint alloc]
        initWithScreenSize:CGSizeMake(40, 40) screenShape:eTSPeriphShapeSquare
        styles:@[] positions:@[] allowColorTint:NO];
    [self.editor setValue:constraint forKey:@"styleConstraint"];
    NSURL *output = [self exportCurrentState];
    AVURLAsset *asset = [AVURLAsset assetWithURL:output];
    XCTAssertTrue(CGSizeEqualToSize([asset tracksWithMediaType:AVMediaTypeVideo].firstObject.naturalSize, CGSizeMake(40, 40)));
    XCTAssertEqual([asset tracksWithMediaType:AVMediaTypeAudio].count, 0u);
}

// App 校验拒绝超时长编辑范围，不能导出后依靠 SDK 自动截短。
- (void)testOverLimitSelectionFailsBeforeStartingExport {
    self.requirements.maxDuration = 0.25;
    __block NSUInteger callbacks = 0;
    [self.editor exportVideoForState:self.state completion:^(NSURL *url, NSError *error) {
        callbacks++;
        XCTAssertNil(url);
        XCTAssertNotNil(error);
    }];
    XCTAssertEqual(callbacks, 1u);
    XCTAssertNil([self.editor valueForKey:@"exportSession"]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.state.videoURL.path]);
}

// 取消后等待导出器退出，再验证任务输出已回收、源文件未被删改。
- (void)testCancelledExportRemovesOutputAndKeepsSource {
    NSData *source = [NSData dataWithContentsOfURL:self.state.videoURL];
    XCTestExpectation *done = [self expectationWithDescription:@"取消导出终态"];
    [self.editor exportVideoForState:self.state completion:^(NSURL *url, NSError *error) {
        XCTAssertNil(url);
        XCTAssertNotNil(error);
        [done fulfill];
    }];
    AVAssetExportSession *session = [self.editor valueForKey:@"exportSession"];
    XCTAssertNotNil(session);
    NSURL *output = session.outputURL;
    [session cancelExport];
    [self waitForExpectations:@[done] timeout:30];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:output.path]);
    XCTAssertEqualObjects(source, [NSData dataWithContentsOfURL:self.state.videoURL]);
}

// 任务清理仅针对生成物，不触碰编辑状态引用的原片。
- (void)testCleanupDeletesOnlyPreparedOutput {
    NSURL *output = [self exportCurrentState];
    NSData *source = [NSData dataWithContentsOfURL:self.state.videoURL];
    [self.editor setValue:output forKey:@"exportedVideoURL"];
    [self.editor cleanupExportedVideo];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:output.path]);
    XCTAssertEqualObjects(source, [NSData dataWithContentsOfURL:self.state.videoURL]);
}

// 旧代次成功回调也只能删除旧输出，不能替换或删除新任务的成品。
- (void)testLateExportDoesNotTakeOwnershipFromNewInstallation {
    NSURL *oldOutput = [self.directoryURL URLByAppendingPathComponent:@"old-prepared.mp4"];
    NSURL *newOutput = [self.directoryURL URLByAppendingPathComponent:@"new-prepared.mp4"];
    NSData *fixture = [@"task owned output" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fixture writeToURL:oldOutput atomically:YES]);
    XCTAssertTrue([fixture writeToURL:newOutput atomically:YES]);
    [self.editor setValue:@2 forKey:@"installGeneration"];
    [self.editor setValue:newOutput forKey:@"exportedVideoURL"];
    [self.editor completeVideoExportWithURL:oldOutput error:nil generation:1];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:oldOutput.path]);
    XCTAssertEqualObjects([self.editor valueForKey:@"exportedVideoURL"], newOutput);
    XCTAssertEqualObjects(fixture, [NSData dataWithContentsOfURL:newOutput]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.state.videoURL.path]);
}

#pragma mark - 私有方法

// 调用实际 App 导出器，所有成功结果登记到本例清理列表。
- (NSURL *)exportCurrentState {
    XCTestExpectation *done = [self expectationWithDescription:@"App 成品导出"];
    __block NSURL *output = nil;
    [self.editor exportVideoForState:self.state completion:^(NSURL *url, NSError *error) {
        XCTAssertNil(error, @"%@", error);
        XCTAssertNotNil(url);
        output = url;
        if (url) { [self.outputs addObject:url]; }
        [done fulfill];
    }];
    [self waitForExpectations:@[done] timeout:30];
    return output;
}

// 自行编码一秒素材：前半红、后半蓝，附带 90 度显示矩阵。
- (NSURL *)createSourceVideo {
    NSURL *url = [self.directoryURL URLByAppendingPathComponent:@"source.mov"];
    NSError *error = nil;
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:&error];
    XCTAssertNotNil(writer, @"%@", error);
    NSDictionary *settings = @{AVVideoCodecKey:AVVideoCodecTypeH264, AVVideoWidthKey:@96, AVVideoHeightKey:@64};
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    input.transform = CGAffineTransformMakeRotation(M_PI_2);
    NSDictionary *attributes = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
        (id)kCVPixelBufferWidthKey:@96, (id)kCVPixelBufferHeightKey:@64};
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
        assetWriterInputPixelBufferAdaptorWithAssetWriterInput:input sourcePixelBufferAttributes:attributes];
    XCTAssertTrue([writer canAddInput:input]);
    [writer addInput:input];
    XCTAssertTrue([writer startWriting], @"%@", writer.error);
    [writer startSessionAtSourceTime:kCMTimeZero];
    for (NSUInteger frameIndex = 0; frameIndex < 12; frameIndex++) {
        NSUInteger waits = 0;
        while (!input.readyForMoreMediaData && waits++ < 1000) { [NSThread sleepForTimeInterval:0.001]; }
        XCTAssertTrue(input.readyForMoreMediaData);
        CVPixelBufferRef buffer = NULL;
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, 96, 64, kCVPixelFormatType_32BGRA,
            (__bridge CFDictionaryRef)attributes, &buffer);
        XCTAssertEqual(status, kCVReturnSuccess);
        XCTAssertNotEqual(buffer, NULL);
        CVPixelBufferLockBaseAddress(buffer, 0);
        uint8_t *pixels = CVPixelBufferGetBaseAddress(buffer);
        size_t stride = CVPixelBufferGetBytesPerRow(buffer);
        for (NSUInteger row = 0; row < 64; row++) {
            for (NSUInteger column = 0; column < 96; column++) {
                NSUInteger offset = row * stride + column * 4;
                pixels[offset] = frameIndex >= 6 ? 255 : 0;
                pixels[offset + 1] = 0;
                pixels[offset + 2] = frameIndex < 6 ? 255 : 0;
                pixels[offset + 3] = 255;
            }
        }
        CVPixelBufferUnlockBaseAddress(buffer, 0);
        XCTAssertTrue([adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frameIndex, 12)]);
        CVPixelBufferRelease(buffer);
    }
    [writer endSessionAtSourceTime:CMTimeMake(1, 1)];
    [input markAsFinished];
    XCTestExpectation *done = [self expectationWithDescription:@"真实视频样本"];
    [writer finishWritingWithCompletionHandler:^{ [done fulfill]; }];
    [self waitForExpectations:@[done] timeout:20];
    XCTAssertEqual(writer.status, AVAssetWriterStatusCompleted, @"%@", writer.error);
    return url;
}

// 手写 PCM WAV 再生成真实有声视频，不把存在某个属性当成音轨已保留。
- (NSURL *)sourceByAddingAudio:(NSURL *)source {
    NSMutableData *wave = [NSMutableData dataWithLength:44 + 32000];
    uint8_t *bytes = wave.mutableBytes;
    memcpy(bytes, "RIFF", 4);
    memcpy(bytes + 8, "WAVEfmt ", 8);
    memcpy(bytes + 36, "data", 4);
    NSDictionary<NSNumber *, NSNumber *> *fields = @{@4:@32036, @16:@16, @20:@0x00010001,
        @24:@16000, @28:@32000, @32:@0x00100002, @40:@32000};
    for (NSNumber *offset in fields) {
        uint32_t value = fields[offset].unsignedIntValue;
        for (NSUInteger index = 0; index < 4; index++) {
            bytes[offset.unsignedIntegerValue + index] = (uint8_t)(value >> (index * 8));
        }
    }
    for (NSUInteger index = 0; index < 16000; index++) {
        int16_t sample = (int16_t)(sin(index * 2 * M_PI * 440 / 16000) * 12000);
        bytes[44 + index * 2] = (uint8_t)sample;
        bytes[45 + index * 2] = (uint8_t)(sample >> 8);
    }
    NSURL *waveURL = [self.directoryURL URLByAppendingPathComponent:@"tone.wav"];
    XCTAssertTrue([wave writeToURL:waveURL atomically:YES]);
    AVURLAsset *video = [AVURLAsset assetWithURL:source];
    AVURLAsset *audio = [AVURLAsset assetWithURL:waveURL];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVAssetTrack *sourceTrack = [video tracksWithMediaType:AVMediaTypeVideo].firstObject;
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
        preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, CMTimeMake(1, 1));
    XCTAssertTrue([videoTrack insertTimeRange:range ofTrack:sourceTrack atTime:kCMTimeZero error:nil]);
    videoTrack.preferredTransform = sourceTrack.preferredTransform;
    XCTAssertTrue([audioTrack insertTimeRange:range ofTrack:[audio tracksWithMediaType:AVMediaTypeAudio].firstObject
        atTime:kCMTimeZero error:nil]);
    NSURL *output = [self.directoryURL URLByAppendingPathComponent:@"audible.mov"];
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition
        presetName:AVAssetExportPresetHighestQuality];
    XCTAssertNotNil(session);
    session.outputURL = output;
    session.outputFileType = AVFileTypeQuickTimeMovie;
    XCTestExpectation *done = [self expectationWithDescription:@"真实有声样本"];
    [session exportAsynchronouslyWithCompletionHandler:^{ [done fulfill]; }];
    [self waitForExpectations:@[done] timeout:30];
    XCTAssertEqual(session.status, AVAssetExportSessionStatusCompleted, @"%@", session.error);
    XCTAssertEqual([[AVURLAsset assetWithURL:output] tracksWithMediaType:AVMediaTypeAudio].count, 1u);
    return output;
}

// 独立解码导出文件首帧，保留真实画布尺寸以区分中心圆与拉伸椭圆。
- (NSData *)firstFrameRGBA:(NSURL *)url {
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVURLAsset assetWithURL:url]];
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    NSError *error = nil;
    CGImageRef image = [generator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:&error];
    XCTAssertNotEqual(image, NULL, @"%@", error);
    size_t width = CGImageGetWidth(image), height = CGImageGetHeight(image);
    NSMutableData *pixels = [NSMutableData dataWithLength:width * height * 4];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels.mutableBytes, width, height, 8, width * 4,
        colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    XCTAssertNotEqual(context, NULL);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(image);
    return pixels;
}

@end
