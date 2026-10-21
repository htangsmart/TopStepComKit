//
//  TSDialEditorStateTests.m
//  TopStepComKit-Git_Tests
//

#import <XCTest/XCTest.h>
#import "../../TopStepComKit-Git/Source/Device/PeripheralDial/TSDialEditorState.h"

static NSURL *sEditorDraftTestDirectory;

@interface TSDialEditorFixtureState : TSDialEditorState
@end

@implementation TSDialEditorFixtureState
// 将真实持久化路径限定在本用例的临时目录。
+ (NSURL *)storageURL {
    return sEditorDraftTestDirectory;
}

// 不依赖宿主 Bundle 图片，同时满足不同类型的默认背景索引。
+ (NSArray<NSDictionary *> *)backgrounds {
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(4, 4)];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [UIColor.whiteColor setFill];
        UIRectFill(CGRectMake(0, 0, 4, 4));
    }];
    NSDictionary *record = @{@"name":@"fixture", @"image":image, @"source":image,
                             @"crop":NSStringFromCGRect(CGRectZero)};
    return @[record, record, record, record];
}
@end

@interface TSDialEditorStateTests : XCTestCase
// 每例独立的真实源文件，迁移只验证路径，不要求媒体解码。
@property (nonatomic, strong) NSURL *sourceURL;
@end

@implementation TSDialEditorStateTests

#pragma mark - 生命周期

// 草稿和源文件完全隔离于实际用户目录。
- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    sEditorDraftTestDirectory = [NSURL fileURLWithPath:
        [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString] isDirectory:YES];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtURL:sEditorDraftTestDirectory
        withIntermediateDirectories:YES attributes:nil error:nil]);
    self.sourceURL = [sEditorDraftTestDirectory URLByAppendingPathComponent:@"source.mov"];
    XCTAssertTrue([[@"immutable source" dataUsingEncoding:NSUTF8StringEncoding] writeToURL:self.sourceURL atomically:YES]);
}

// 只清理测试自己创建的目录。
- (void)tearDown {
    [[NSFileManager defaultManager] removeItemAtURL:sEditorDraftTestDirectory error:nil];
    sEditorDraftTestDirectory = nil;
    [super tearDown];
}

#pragma mark - 测试

// 旧路径和编辑范围迁入源素材合同，保存时不产生 prepared 缓存。
- (void)testLegacyDraftMigratesSourceAndAudioSelectionToSchemaTwo {
    [self writeSaved:@{@"version":@1, @"videoPath":self.sourceURL.path,
        @"videoAudioPolicy":@2, @"videoDuration":@12, @"videoStart":@3, @"videoEnd":@8}];
    NSData *original = [NSData dataWithContentsOfURL:self.sourceURL];
    TSDialEditorState *state = [TSDialEditorFixtureState stateForType:TSDialDraftTypeVideo];
    XCTAssertEqualObjects(state.videoURL, self.sourceURL);
    XCTAssertEqual(state.videoAudioSelection, TSDialEditorVideoAudioSelectionPreserveFirstTrack);
    XCTAssertEqualWithAccuracy(state.videoStart, 3, 0.000001);
    XCTAssertEqualWithAccuracy(state.videoEnd, 8, 0.000001);
    XCTAssertTrue([state saveWithError:nil]);
    NSDictionary *saved = [NSDictionary dictionaryWithContentsOfURL:[self savedURL]];
    XCTAssertEqualObjects(saved[@"version"], @2);
    XCTAssertEqualObjects(saved[@"sourceVideoPath"], self.sourceURL.path);
    XCTAssertEqualObjects(saved[@"videoContentKind"], @"source");
    XCTAssertEqualObjects(saved[@"videoAudioSelection"], @2);
    XCTAssertNil(saved[@"videoPath"]);
    XCTAssertNil(saved[@"videoAudioPolicy"]);
    XCTAssertNil(saved[@"preparedVideoPath"]);
    XCTAssertEqualObjects(original, [NSData dataWithContentsOfURL:self.sourceURL]);
}

// 旧未知枚举不会在删除 SDK 类型后意外变成保留音轨。
- (void)testUnknownLegacyAudioSelectionFallsBackToAutomatic {
    [self writeSaved:@{@"version":@1, @"videoPath":self.sourceURL.path, @"videoAudioPolicy":@99}];
    TSDialEditorState *state = [TSDialEditorFixtureState stateForType:TSDialDraftTypeVideo];
    XCTAssertEqual(state.videoAudioSelection, TSDialEditorVideoAudioSelectionAutomatic);
}

// 明确标为成品的路径不能冒充可继续编辑的原片。
- (void)testPreparedEntryIsNotRestoredAsSource {
    [self writeSaved:@{@"version":@2, @"sourceVideoPath":self.sourceURL.path,
        @"videoContentKind":@"prepared", @"videoAudioSelection":@1}];
    TSDialEditorState *state = [TSDialEditorFixtureState stateForType:TSDialDraftTypeVideo];
    XCTAssertNil(state.videoURL);
    XCTAssertEqual(state.videoAudioSelection, TSDialEditorVideoAudioSelectionMuted);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.sourceURL.path]);
}

// 冻结的安装编辑状态与后续交互隔离，源文件本身仍是同一只读输入。
- (void)testCopyPreservesSourceAndFreezesEditingSelection {
    TSDialEditorState *state = [TSDialEditorFixtureState stateForType:TSDialDraftTypeVideo];
    state.videoURL = self.sourceURL;
    state.videoStart = 1;
    state.videoEnd = 4;
    state.videoAudioSelection = TSDialEditorVideoAudioSelectionMuted;
    TSDialEditorState *snapshot = [state copy];
    state.videoStart = 2;
    state.videoAudioSelection = TSDialEditorVideoAudioSelectionPreserveFirstTrack;
    XCTAssertEqualObjects(snapshot.videoURL, self.sourceURL);
    XCTAssertEqual(snapshot.videoAudioSelection, TSDialEditorVideoAudioSelectionMuted);
    XCTAssertEqualWithAccuracy(snapshot.videoStart, 1, 0.000001);
}

// 重开草稿仍保留已确认画布；缺少该字段的旧草稿不会被伪造为已确认。
- (void)testConfirmedVideoCanvasSurvivesPersistenceAndCopy {
    TSDialEditorState *state = [TSDialEditorFixtureState stateForType:TSDialDraftTypeVideo];
    XCTAssertNil(state.images.firstObject[@"videoCanvasSize"]);
    NSMutableDictionary *record = [state.images.firstObject mutableCopy];
    record[@"videoCanvasSize"] = NSStringFromCGSize(CGSizeMake(48, 32));
    record[@"videoCanvasShape"] = @1;
    record[@"videoCanvasRadius"] = @7;
    state.images = @[record];
    state.videoURL = self.sourceURL;
    XCTAssertTrue([state saveWithError:nil]);
    TSDialEditorState *restored = [TSDialEditorFixtureState stateForType:TSDialDraftTypeVideo];
    TSDialEditorState *snapshot = [restored copy];
    for (NSString *key in @[@"videoCanvasSize", @"videoCanvasShape", @"videoCanvasRadius"]) {
        XCTAssertEqualObjects(restored.images.firstObject[key], record[key]);
        XCTAssertEqualObjects(snapshot.images.firstObject[key], record[key]);
    }
}

#pragma mark - 私有方法

// 使用真实草稿命名约定。
- (NSURL *)savedURL {
    return [sEditorDraftTestDirectory URLByAppendingPathComponent:
        [NSString stringWithFormat:@"draft-%ld.plist", (long)TSDialDraftTypeVideo]];
}

// 测试只注入实际磁盘数据，不替换生产迁移逻辑。
- (void)writeSaved:(NSDictionary *)saved {
    XCTAssertTrue([saved writeToURL:[self savedURL] atomically:YES]);
}

@end
