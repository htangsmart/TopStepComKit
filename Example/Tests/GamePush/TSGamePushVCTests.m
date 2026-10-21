//
//  TSGamePushVCTests.m
//  TopStepComKit-Git_Tests
//
//  验证页面逻辑、回调归属和临时文件导入，不启动协调器或连接设备。
//

#import <XCTest/XCTest.h>
#import <stdint.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <TopStepToolKit/TopStepToolKit.h>

#import "../../TopStepComKit-Git/Source/Device/GamePush/TSGamePushVC.h"
#import "../../TopStepComKit-Git/Source/Ble/TSDeviceCoordinator.h"
#import "../../TopStepComKit-Git/Source/BaseVC/Category/UIViewController+TSToast.h"

// 声明真实页面的测试入口，不重复编译生产实现。
@interface TSGamePushVC (Testing)
- (NSString *)gameName:(NSInteger)type;
- (NSString *)slotUnavailableReason:(TSGameSlotModel *)slot;
- (NSString *)configurationIssue;
- (void)selectSlot:(UIButton *)sender;
- (BOOL)canPrepareInstallation;
- (BOOL)canImportGamePackage;
- (UIView *)importCard;
- (void)importTapped;
- (void)importFileURL:(NSURL *)url;
- (void)configureInstallation;
- (BOOL)synchronizeSession;
- (void)reloadGameData;
- (void)startPush;
- (void)confirmReplacement;
- (void)confirmCancel;
- (TSDeviceConnectionSnapshot *)currentSnapshot;
- (id<TSGamePushInterface>)gameInterface;
- (void)renderPage;
- (void)showProgress;
- (void)updateProgress;
- (void)closeSheet;
- (void)showResult:(NSString *)title heading:(NSString *)heading detail:(NSString *)detail icon:(NSString *)icon
           warning:(BOOL)warning actionTitle:(NSString *)actionTitle action:(SEL)action;
@end

// 仅保存真实协议回调，由各测试明确控制回调时机和顺序。
@interface TSGamePushTestInterface : NSObject <TSGamePushInterface>
// 能力由测试输入控制。
@property (nonatomic, assign) BOOL supported;
@property (nonatomic, assign) BOOL slotsSupported;
// 各查询的原始回调。
@property (nonatomic, copy) TSInstalledGamesCompletionBlock gamesCompletion;
@property (nonatomic, copy) TSGameTypesCompletionBlock typesCompletion;
@property (nonatomic, copy) TSGameStorageCompletionBlock storageCompletion;
@property (nonatomic, copy) TSGameSlotsCompletionBlock slotsCompletion;
// 记录推送意图及独立的推送、取消回调。
@property (nonatomic, strong) TSGamePushRequest *receivedRequest;
@property (nonatomic, copy) TSFileTransferProgressBlock progressBlock;
@property (nonatomic, copy) TSCompletionBlock pushCompletion;
@property (nonatomic, copy) TSCompletionBlock cancelCompletion;
// 记录请求数量，判断重复操作及路由。
@property (nonatomic, assign) NSUInteger pushCount;
@property (nonatomic, assign) NSUInteger cancelCount;
@property (nonatomic, assign) NSUInteger slotsQueryCount;
@end

@implementation TSGamePushTestInterface

#pragma mark - 公开方法

// 返回固定的测试能力。
- (BOOL)isSupport { return self.supported; }

// 返回固定的槽位能力。
- (BOOL)isSupportGameSlots { return self.slotsSupported; }

// 保存已有游戏查询回调。
- (void)fetchInstalledGames:(TSInstalledGamesCompletionBlock)completion { self.gamesCompletion = completion; }

// 保存支持类型查询回调。
- (void)fetchSupportedGameTypes:(TSGameTypesCompletionBlock)completion { self.typesCompletion = completion; }

// 保存空间查询回调。
- (void)fetchGameStorage:(TSGameStorageCompletionBlock)completion { self.storageCompletion = completion; }

// 保存槽位查询回调及调用次数。
- (void)fetchGameSlots:(TSGameSlotsCompletionBlock)completion {
    self.slotsQueryCount++;
    self.slotsCompletion = completion;
}

// 捕获页面实际生成的请求，不实现或模拟传输成功条件。
- (void)pushGame:(TSGamePushRequest *)request progress:(TSFileTransferProgressBlock)progress
      completion:(TSCompletionBlock)completion {
    self.pushCount++;
    self.receivedRequest = request;
    self.progressBlock = progress;
    self.pushCompletion = completion;
}

// 取消与原推送分别保存，不自动触发另一条回调。
- (void)cancelGamePush:(TSCompletionBlock)completion {
    self.cancelCount++;
    self.cancelCompletion = completion;
}

@end

// 只隔离协调器、SDK 获取及显示副作用，保留被测业务分支。
@interface TSGamePushTestVC : TSGamePushVC
// 可控的当前连接快照和公开接口。
@property (nonatomic, strong) TSDeviceConnectionSnapshot *testSnapshot;
@property (nonatomic, strong) TSGamePushTestInterface *testInterface;
// 捕获页面结果，不显示真实弹窗。
@property (nonatomic, copy) NSString *resultTitle;
@property (nonatomic, copy) NSString *toastMessage;
// 捕获文件选择器及配置入口，不展示系统界面。
@property (nonatomic, strong) UIViewController *capturedPresentation;
@property (nonatomic, assign) NSUInteger configurationCount;
// 按需执行真实配置视图，验证删参后的表单及替换交互。
@property (nonatomic, assign) BOOL rendersConfiguration;
// 导入完成渲染时通知异步用例。
@property (nonatomic, copy) dispatch_block_t onRender;
@end

@implementation TSGamePushTestVC

#pragma mark - 生命周期

// 只初始化真实页面数据，不注册全局协调器或触发自动查询。
- (void)viewDidLoad {
    [self initData];
}

#pragma mark - 私有方法

// 返回可控快照，仍使用生产代码的设备与会话比较。
- (TSDeviceConnectionSnapshot *)currentSnapshot { return self.testSnapshot; }

// 返回符合真实公开协议的测试接口。
- (id<TSGamePushInterface>)gameInterface { return self.testInterface; }

// 页面布局不属于这些状态测试的断言范围。
- (void)renderPage {
    if (self.onRender) {
        self.onRender();
    }
}

// 捕获系统选择器，保留生产 chooseFile 的校验和快照保存。
- (void)presentViewController:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))completion {
    self.capturedPresentation = controller;
    if (completion) {
        completion();
    }
}

// 记录是否进入配置，实际校验仍由入口方法执行。
- (void)configureInstallation {
    self.configurationCount++;
    if (self.rendersConfiguration) {
        [super configureInstallation];
    }
}

// 不创建传输弹层，进度状态仍由生产回调更新。
- (void)showProgress {}

// 不创建或刷新进度控件。
- (void)updateProgress {}

// 清除显示状态，避免执行弹层动画。
- (void)closeSheet {
    [self setValue:@0 forKey:@"sheetKind"];
}

// 只记录生产代码选择的结果类型。
- (void)showResult:(NSString *)title heading:(NSString *)heading detail:(NSString *)detail icon:(NSString *)icon
           warning:(BOOL)warning actionTitle:(NSString *)actionTitle action:(SEL)action {
    self.resultTitle = title;
}

// 捕获校验或取消提示，避免真实 Toast 动画。
- (void)ts_showToast:(NSString *)message { self.toastMessage = message; }

@end

@interface TSGamePushVCTests : XCTestCase
// 每条用例独立持有真实页面及协议替身。
@property (nonatomic, strong) TSGamePushTestVC *controller;
@property (nonatomic, strong) TSGamePushTestInterface *interface;
@property (nonatomic, strong) TSPeripheral *peripheral;
// 仅保存本条用例创建的临时输入目录。
@property (nonatomic, copy) NSString *fixtureDirectory;
@end

@implementation TSGamePushVCTests

#pragma mark - 生命周期

// 在主线程创建页面，所有接口请求均由替身接收。
- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    XCTAssertTrue(NSThread.isMainThread, @"页面测试必须在主线程执行");
    self.peripheral = [[TSPeripheral alloc] init];
    self.peripheral.systemInfo.mac = @"00:11:22:33:44:55";
    self.interface = [[TSGamePushTestInterface alloc] init];
    self.interface.supported = YES;
    self.interface.slotsSupported = YES;
    self.controller = [[TSGamePushTestVC alloc] init];
    self.controller.testInterface = self.interface;
    self.controller.testSnapshot = [self snapshotWithGeneration:7];
    [self.controller loadViewIfNeeded];
    XCTAssertNotNil([self.controller valueForKey:@"uncertainSnapshots"], @"夹具必须执行真实 initData");
    [self prepareValidConfiguration];
}

// 排空已经投递的页面回调，不触发任何设备清理。
- (void)tearDown {
    [self drainMainQueue];
    self.controller = nil;
    if (self.fixtureDirectory.length) {
        [NSFileManager.defaultManager removeItemAtPath:self.fixtureDirectory error:nil];
        self.fixtureDirectory = nil;
    }
    self.interface = nil;
    self.peripheral = nil;
    [super tearDown];
}

#pragma mark - 输入与目标校验

// 公版已命名类型均使用真实本地化资源，不降级成类型编号。
- (void)testConfirmedGameTypesUseLocalizedNames {
    for (NSInteger type = 0; type <= 24; type++) {
        NSString *key = [NSString stringWithFormat:@"game_push.ui.type_%ld", (long)type];
        NSString *expectedName = TSLocalizedString(key);
        XCTAssertGreaterThan(expectedName.length, 0u);
        XCTAssertNotEqualObjects(expectedName, key, @"类型 %ld 缺少本地化", (long)type);
        XCTAssertEqualObjects([self.controller gameName:type], expectedName, @"类型 %ld 名称遗漏", (long)type);
    }
}

// 未命名类型保留原编号，不误用相邻游戏名称或显示本地化 key。
- (void)testUnnamedGameTypesDisplayOriginalIdentifiers {
    for (NSNumber *type in @[@25, @99, @(INT32_MAX), @(-1)]) {
        NSString *expectedName = [NSString stringWithFormat:TSLocalizedString(@"game_push.ui.unknown_type"),
                                  (long)type.integerValue];
        XCTAssertEqualObjects([self.controller gameName:type.integerValue], expectedName);
    }
}

// 同一个空槽在容量恰好等于文件长度时可用，小一字节时不可用。
- (void)testSlotChecksItsOwnCapacityAtExactBoundary {
    TSGameSlotModel *slot = [self slotWithIndex:7 capacity:512 empty:YES];
    XCTAssertNil([self.controller slotUnavailableReason:slot], @"等量容量应通过页面门槛");
    slot.capacityBytes = 511;
    XCTAssertEqualObjects([self.controller slotUnavailableReason:slot],
                          TSLocalizedString(@"game_push.ui.insufficient_space"));
}

// 未确认索引和负索引都不能作为安装目标。
- (void)testSlotRejectsUnknownAndNegativeIndex {
    for (NSNumber *index in @[@(NSNotFound), @(-1)]) {
        TSGameSlotModel *slot = [self slotWithIndex:index.integerValue capacity:1024 empty:YES];
        XCTAssertEqualObjects([self.controller slotUnavailableReason:slot],
                              TSLocalizedString(@"game_push.ui.index_unknown"));
    }
}

// 内容 ID 为零并不表示空槽，容量为零也不能被当成无限空间。
- (void)testSlotUsesEmptyFlagAndRejectsUnknownCapacity {
    TSGameSlotModel *slot = [self slotWithIndex:0 capacity:1024 empty:NO];
    slot.rawIdentifier = 0;
    XCTAssertEqualObjects([self.controller slotUnavailableReason:slot], TSLocalizedString(@"game_push.ui.slot_content_unknown"));
    slot.empty = YES;
    slot.rawIdentifier = 0x1234567800000107ULL;
    slot.capacityBytes = 0;
    XCTAssertEqualObjects([self.controller slotUnavailableReason:slot],
                          TSLocalizedString(@"game_push.ui.capacity_unknown"));
}

// 真实槽位索引及包路径原样进入请求，不附带人工元数据。
- (void)testSlotSelectionAndRequestPreserveActualSlotIndex {
    TSGameSlotModel *slot = [self slotWithIndex:19 capacity:1024 empty:YES];
    slot.rawIdentifier = 0x1234567800000107ULL;
    [self.controller setValue:@[slot] forKey:@"gameSlots"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.tag = 0;
    [self.controller selectSlot:button];
    XCTAssertEqualObjects([self.controller valueForKey:@"selectedSlotIndex"], @19);
    [self.controller startPush];
    XCTAssertEqual(self.interface.pushCount, 1u);
    XCTAssertEqualObjects(self.interface.receivedRequest.targetSlotIndex, @19, @"请求应使用真实索引而非数组位置");
    XCTAssertEqualObjects(self.interface.receivedRequest.localFilePath, @"/game-push-test/fixture.bin");
}

// 越界点击和身份不明的占用槽点击不会替换之前的合法选择。
- (void)testInvalidSlotSelectionPreservesExistingTarget {
    TSGameSlotModel *slot = [self slotWithIndex:19 capacity:1024 empty:NO];
    [self.controller setValue:@[slot] forKey:@"gameSlots"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    for (NSNumber *tag in @[@(-1), @0, @1]) {
        button.tag = tag.integerValue;
        [self.controller selectSlot:button];
        XCTAssertEqualObjects([self.controller valueForKey:@"selectedSlotIndex"], @7);
    }
}

// 汇总空间足够不能放行一个容量不足的指定槽位。
- (void)testConfigurationDoesNotSubstituteAggregateCapacityForSingleSlot {
    [self.controller setValue:@[[self slotWithIndex:7 capacity:300 empty:YES],
                               [self slotWithIndex:19 capacity:300 empty:YES]] forKey:@"gameSlots"];
    XCTAssertEqualObjects([self.controller configurationIssue], TSLocalizedString(@"game_push.ui.insufficient_space"));
    [self.controller startPush];
    XCTAssertEqual(self.interface.pushCount, 0u, @"不得把多个空槽容量相加后提交");
}

// 未选择或已不存在的目标都要求重新选择，不自动改选数组首项。
- (void)testConfigurationRejectsMissingOrAbsentSelectedSlot {
    [self.controller setValue:nil forKey:@"selectedSlotIndex"];
    XCTAssertEqualObjects([self.controller configurationIssue], TSLocalizedString(@"game_push.ui.choose_slot"));
    [self.controller setValue:@99 forKey:@"selectedSlotIndex"];
    XCTAssertEqualObjects([self.controller configurationIssue], TSLocalizedString(@"game_push.ui.choose_slot"));
}

// 槽位零是有效显式输入，不能退化为自动选槽。
- (void)testRequestPreservesExplicitZeroSlot {
    [self.controller setValue:@[[self slotWithIndex:0 capacity:512 empty:YES]] forKey:@"gameSlots"];
    [self.controller setValue:@0 forKey:@"selectedSlotIndex"];
    XCTAssertNil([self.controller configurationIssue]);
    [self.controller startPush];
    XCTAssertEqualObjects(self.interface.receivedRequest.localFilePath, @"/game-push-test/fixture.bin");
    XCTAssertEqualObjects(self.interface.receivedRequest.targetSlotIndex, @0);
}

// 非槽位路径保留 64 位可用容量，请求中不夹带旧槽位选择。
- (void)testDirectoryCapacityRemains64BitAndRequestOmitsSlot {
    self.interface.slotsSupported = NO;
    unsigned long long fileSize = (1ULL << 32) + 512;
    TSStorageSpace *storage = [[TSStorageSpace alloc] init];
    storage.total = fileSize + 1024;
    storage.available = fileSize - 1;
    [self.controller setValue:@(fileSize) forKey:@"fileSize"];
    [self.controller setValue:storage forKey:@"gameStorage"];
    XCTAssertNotNil([self.controller configurationIssue], @"64 位容量小一字节时应拒绝");
    storage.available = fileSize;
    XCTAssertNil([self.controller configurationIssue], @"64 位容量相等时应通过页面门槛");
    [self.controller startPush];
    XCTAssertEqual(self.interface.pushCount, 1u, @"目录路径必须实际提交一笔请求");
    XCTAssertNotNil(self.interface.receivedRequest);
    XCTAssertNil(self.interface.receivedRequest.targetSlotIndex, @"目录路径不提交旧槽位");
}

// 空槽只依赖有效槽位，不依赖类型、已有游戏或汇总空间的展示结果。
- (void)testEmptySlotSubmissionDoesNotRequireMetadataQueries {
    [self.controller setValue:nil forKey:@"supportedTypes"];
    [self.controller setValue:nil forKey:@"installedGames"];
    [self.controller setValue:nil forKey:@"gameStorage"];
    NSMutableDictionary *errors = [self.controller valueForKey:@"queryErrors"];
    errors[@"types"] = [self gameError:eTSErrorTimeoutError];
    errors[@"games"] = [self gameError:eTSErrorTimeoutError];
    errors[@"storage"] = [self gameError:eTSErrorTimeoutError];
    XCTAssertNil([self.controller configurationIssue]);
    [self.controller startPush];
    XCTAssertEqual(self.interface.pushCount, 1u);
}

#pragma mark - 查询与会话隔离

// 四类查询失败都可导入；仅槽位失败阻塞已确认空槽的提交。
- (void)testOnlySlotQueryFailureBlocksEmptySlotPush {
    for (NSString *key in @[@"games", @"types", @"storage", @"slots"]) {
        [self.controller reloadGameData];
        NSError *failure = [self gameError:eTSErrorTimeoutError];
        if ([key isEqualToString:@"games"]) {
            self.interface.gamesCompletion(nil, failure);
        } else if ([key isEqualToString:@"types"]) {
            self.interface.typesCompletion(nil, failure);
        } else if ([key isEqualToString:@"storage"]) {
            self.interface.storageCompletion(nil, failure);
        } else {
            self.interface.slotsCompletion(nil, failure);
        }
        [self deliverSuccessfulQueries];
        XCTAssertTrue([self.controller canImportGamePackage], @"%@ 失败不应阻止本地导入", key);
        BOOL slotsFailed = [key isEqualToString:@"slots"];
        XCTAssertEqual([self.controller canPrepareInstallation], !slotsFailed);
        UIView *card = [self.controller importCard];
        UIStackView *content = (UIStackView *)card.subviews.firstObject;
        UIButton *button = (UIButton *)content.arrangedSubviews[1];
        XCTAssertTrue(button.enabled);
        XCTAssertEqualObjects(button.currentTitle, TSLocalizedString(slotsFailed ?
            @"game_push.ui.change_file" : @"game_push.ui.continue"));
        [self.controller setValue:@7 forKey:@"selectedSlotIndex"];
        NSUInteger previousCount = self.interface.pushCount;
        [self.controller startPush];
        XCTAssertEqual(self.interface.pushCount, previousCount + (slotsFailed ? 0 : 1));
        if (!slotsFailed) {
            self.interface.pushCompletion(NO, [self gameError:eTSErrorParamError]);
            [self deliverSuccessfulQueries];
        }
    }
}

// 查询尚未结束时也能选择文件，已有文件在结果恢复后才切换为继续配置。
- (void)testImportEntrySwitchesAfterQueriesRecover {
    [self.controller setValue:@"" forKey:@"localFilePath"];
    [self.controller reloadGameData];
    XCTAssertTrue([self.controller canImportGamePackage]);
    [self.controller importTapped];
    XCTAssertTrue([self.controller.capturedPresentation isKindOfClass:UIDocumentPickerViewController.class]);
    XCTAssertEqual(self.controller.configurationCount, 0u);
    [self.controller setValue:@"/game-push-test/retained.bin" forKey:@"localFilePath"];
    self.controller.capturedPresentation = nil;
    [self.controller importTapped];
    XCTAssertNotNil(self.controller.capturedPresentation, @"未就绪时可更换已有文件");
    [self deliverSuccessfulQueries];
    self.controller.capturedPresentation = nil;
    [self.controller importTapped];
    XCTAssertNil(self.controller.capturedPresentation);
    XCTAssertEqual(self.controller.configurationCount, 1u);
    XCTAssertEqual(self.interface.pushCount, 0u, @"恢复查询不得自动推送");
}

// 解除查询依赖不能放开活动操作、不支持设备和旧连接的导入入口。
- (void)testImportStillRequiresIdleSupportedCurrentSession {
    for (NSString *flag in @[@"pushing", @"importing", @"reconnecting"]) {
        [self.controller setValue:@YES forKey:flag];
        XCTAssertFalse([self.controller canImportGamePackage]);
        [self.controller setValue:@NO forKey:flag];
    }
    self.interface.supported = NO;
    XCTAssertFalse([self.controller canImportGamePackage]);
    self.interface.supported = YES;
    self.controller.testSnapshot = [self snapshotWithGeneration:8];
    XCTAssertFalse([self.controller canImportGamePackage]);
    self.controller.testSnapshot = nil;
    XCTAssertFalse([self.controller canImportGamePackage]);
}

// 安装结果待确认和取消后的重连要求仍阻止推送，但不阻止保存本地文件。
- (void)testImportDoesNotClearInstallationRecoveryRequirements {
    for (NSString *flag in @[@"installationUncertain", @"reconnectRequired"]) {
        NSMutableArray *uncertain = [self.controller valueForKey:@"uncertainSnapshots"];
        if ([flag isEqualToString:@"installationUncertain"]) {
            [uncertain addObject:self.controller.testSnapshot];
        } else {
            [self.controller setValue:@7 forKey:@"cancelledGeneration"];
        }
        [self.controller setValue:@YES forKey:flag];
        XCTAssertTrue([self.controller canImportGamePackage]);
        XCTAssertFalse([self.controller canPrepareInstallation]);
        [self.controller startPush];
        XCTAssertEqual(self.interface.pushCount, 0u);
        XCTAssertTrue([[self.controller valueForKey:flag] boolValue]);
        [self.controller setValue:@NO forKey:flag];
        [uncertain removeAllObjects];
    }
}

// 查询失败时执行真实文件协调及复制，刷新成功后复用同一份文件。
- (void)testFileImportSurvivesQueryFailureAndResumesAfterRefresh {
    [self.controller reloadGameData];
    self.interface.slotsCompletion(nil, [self gameError:eTSErrorTimeoutError]);
    [self deliverSuccessfulQueries];
    NSURL *fileURL = [self createImportFixture];
    XCTestExpectation *imported = [self expectationWithDescription:@"查询失败时完成本地导入"];
    __weak TSGamePushTestVC *weakController = self.controller;
    self.controller.onRender = ^{
        if (![[weakController valueForKey:@"importing"] boolValue]) {
            weakController.onRender = nil;
            [imported fulfill];
        }
    };
    [self.controller importFileURL:fileURL];
    [self waitForExpectations:@[imported] timeout:5];
    NSString *importedPath = [self.controller valueForKey:@"localFilePath"];
    XCTAssertEqualObjects([NSData dataWithContentsOfFile:importedPath], [NSData dataWithContentsOfURL:fileURL]);
    XCTAssertEqual(self.controller.configurationCount, 0u);
    XCTAssertFalse([self.controller canPrepareInstallation]);
    XCTAssertEqualObjects(self.controller.toastMessage, TSLocalizedString(@"game_push.ui.imported_waiting"));
    [self.controller reloadGameData];
    [self deliverSuccessfulQueries];
    XCTAssertEqualObjects([self.controller valueForKey:@"localFilePath"], importedPath);
    [self.controller importTapped];
    XCTAssertEqual(self.controller.configurationCount, 1u);
    XCTAssertEqual(self.interface.pushCount, 0u);
}

// 文件复制期间换连接时丢弃新副本，不覆盖已有有效文件。
- (void)testConnectionChangeDuringImportDiscardsNewFile {
    NSURL *fileURL = [self createImportFixture];
    NSString *previousPath = [self.controller valueForKey:@"localFilePath"];
    XCTestExpectation *finished = [self expectationWithDescription:@"跨连接导入结束"];
    __weak TSGamePushTestVC *weakController = self.controller;
    self.controller.onRender = ^{
        if (![[weakController valueForKey:@"importing"] boolValue]) {
            weakController.onRender = nil;
            [finished fulfill];
        }
    };
    [self.controller importFileURL:fileURL];
    self.controller.testSnapshot = [self snapshotWithGeneration:8];
    [self waitForExpectations:@[finished] timeout:5];
    XCTAssertEqualObjects([self.controller valueForKey:@"localFilePath"], previousPath);
    XCTAssertNil([self.controller valueForKey:@"importDirectory"]);
    XCTAssertEqual(self.controller.configurationCount, 0u);
    XCTAssertEqual(self.interface.pushCount, 0u);
}

// 非 nil 的空游戏列表是成功结果，并允许后续配置。
- (void)testSuccessfulEmptyInstalledGamesRemainDistinctFromFailure {
    [self.controller reloadGameData];
    [self deliverSuccessfulQueries];
    XCTAssertEqualObjects([self.controller valueForKey:@"installedGames"], @[]);
    XCTAssertEqual([[self.controller valueForKey:@"queryErrors"] count], 0u);
    XCTAssertTrue([self.controller canPrepareInstallation], @"成功空游戏列表不应阻止安装");
}

// nil 且没有错误仍是缺结果，不得转换成成功空列表。
- (void)testMissingGameQueryResultRemainsFailureWithoutBlockingEmptySlot {
    [self.controller reloadGameData];
    self.interface.gamesCompletion(nil, nil);
    [self deliverSuccessfulQueries];
    XCTAssertNil([self.controller valueForKey:@"installedGames"]);
    NSDictionary *errors = [self.controller valueForKey:@"queryErrors"];
    XCTAssertNotNil(errors[@"games"], @"缺失结果必须留下查询失败状态");
    XCTAssertTrue([self.controller canPrepareInstallation]);
}

// 同时携带数据和错误时按错误处理，不能展示这批数据为成功结果。
- (void)testQueryErrorDoesNotAcceptAccompanyingData {
    [self.controller reloadGameData];
    NSError *failure = [self gameError:eTSErrorParamError];
    self.interface.gamesCompletion(@[[[TSGameModel alloc] init]], failure);
    [self deliverSuccessfulQueries];
    XCTAssertNil([self.controller valueForKey:@"installedGames"]);
    XCTAssertEqualObjects([self.controller valueForKey:@"queryErrors"][@"games"], failure);
    XCTAssertTrue([self.controller canPrepareInstallation]);
}

// 槽位查询失败时，即使汇总空间成功也不能配置安装。
- (void)testSlotQueryFailureCannotBeReplacedByStorageSuccess {
    [self.controller reloadGameData];
    self.interface.slotsCompletion(nil, [self gameError:eTSErrorParamError]);
    [self deliverSuccessfulQueries];
    XCTAssertNotNil([self.controller valueForKey:@"gameStorage"]);
    XCTAssertNil([self.controller valueForKey:@"gameSlots"]);
    XCTAssertFalse([self.controller canPrepareInstallation]);
}

// 不提供槽位的接口只查询目录空间，不能为了完成页面而请求槽位。
- (void)testDirectoryPlatformDoesNotQuerySlots {
    self.interface.slotsSupported = NO;
    [self.controller reloadGameData];
    [self deliverSuccessfulQueries];
    XCTAssertEqual(self.interface.slotsQueryCount, 0u);
    XCTAssertNil([self.controller valueForKey:@"gameSlots"]);
    XCTAssertTrue([self.controller canPrepareInstallation]);
}

// 同设备新连接代次会清空旧选择，旧查询回调不能填入新会话。
- (void)testOldGenerationQueryCannotPopulateNewSession {
    [self.controller reloadGameData];
    TSInstalledGamesCompletionBlock oldCompletion = self.interface.gamesCompletion;
    [self.controller setValue:@7 forKey:@"selectedSlotIndex"];
    self.controller.testSnapshot = [self snapshotWithGeneration:8];
    XCTAssertTrue([self.controller synchronizeSession]);
    XCTAssertNil([self.controller valueForKey:@"selectedSlotIndex"]);
    [self.controller reloadGameData];
    oldCompletion(@[[[TSGameModel alloc] init]], nil);
    [self drainMainQueue];
    XCTAssertNil([self.controller valueForKey:@"installedGames"]);
    XCTAssertTrue([[self.controller valueForKey:@"pendingQueries"] containsObject:@"games"]);
    [self deliverSuccessfulQueries];
    XCTAssertEqualObjects([self.controller valueForKey:@"installedGames"], @[]);
}

// 即使设备快照相同，更换公开接口后也不接受旧接口的结果。
- (void)testQueryFromReplacedInterfaceIsIgnored {
    [self.controller reloadGameData];
    TSInstalledGamesCompletionBlock oldCompletion = self.interface.gamesCompletion;
    TSGamePushTestInterface *replacement = [[TSGamePushTestInterface alloc] init];
    replacement.supported = YES;
    replacement.slotsSupported = YES;
    self.controller.testInterface = replacement;
    oldCompletion(@[[[TSGameModel alloc] init]], nil);
    [self drainMainQueue];
    XCTAssertNil([self.controller valueForKey:@"installedGames"]);
    XCTAssertFalse([self.controller canPrepareInstallation]);
}

// 同一查询的重复回调不会覆盖首次结果或再制造失败。
- (void)testDuplicateQueryCompletionDoesNotReplaceAcceptedResult {
    [self.controller reloadGameData];
    TSInstalledGamesCompletionBlock completion = self.interface.gamesCompletion;
    completion(@[], nil);
    completion(nil, [self gameError:eTSErrorParamError]);
    [self deliverSuccessfulQueries];
    XCTAssertEqualObjects([self.controller valueForKey:@"installedGames"], @[]);
    XCTAssertEqual([[self.controller valueForKey:@"queryErrors"] count], 0u);
}

#pragma mark - 推送与取消回调

// 进度只能由有效事件单调推进，完成前不显示 100。
- (void)testProgressIsMonotonicAndCannotImplyInstallationSuccess {
    [self.controller startPush];
    self.interface.progressBlock(eTSFileTransferStatusStart, -10);
    [self drainMainQueue];
    XCTAssertEqualObjects([self.controller valueForKey:@"transferProgress"], @0);
    self.interface.progressBlock(eTSFileTransferStatusProgress, 80);
    self.interface.progressBlock(eTSFileTransferStatusProgress, 20);
    self.interface.progressBlock(eTSFileTransferStatusSuccess, 100);
    [self drainMainQueue];
    XCTAssertEqualObjects([self.controller valueForKey:@"transferProgress"], @80);
    self.interface.progressBlock(eTSFileTransferStatusProgress, 150);
    [self drainMainQueue];
    XCTAssertEqualObjects([self.controller valueForKey:@"transferProgress"], @99);
    XCTAssertTrue([[self.controller valueForKey:@"pushing"] boolValue]);
    XCTAssertNil(self.controller.resultTitle, @"进度事件不能决定安装结果");
}

// 取消请求成功不提前解除忙碌，原推送的取消终态才结束本次操作。
- (void)testCancellationAcknowledgementWaitsForOriginalPushTerminal {
    [self.controller startPush];
    NSUUID *token = [self.controller valueForKey:@"operationToken"];
    [self.controller confirmCancel];
    self.interface.cancelCompletion(YES, nil);
    [self drainMainQueue];
    XCTAssertTrue([[self.controller valueForKey:@"pushing"] boolValue]);
    XCTAssertTrue([[self.controller valueForKey:@"cancelRequested"] boolValue]);
    XCTAssertEqualObjects([self.controller valueForKey:@"operationToken"], token);
    XCTAssertEqual([self.controller valueForKey:@"activeInterface"], self.interface);
    XCTAssertNil(self.controller.resultTitle);
    [self.controller confirmCancel];
    XCTAssertEqual(self.interface.cancelCount, 1u, @"等待原终态时不重复发送取消");
    self.interface.pushCompletion(NO, [self gameError:eTSErrorUserCancelled]);
    [self drainMainQueue];
    XCTAssertFalse([[self.controller valueForKey:@"pushing"] boolValue]);
    XCTAssertNil([self.controller valueForKey:@"operationToken"]);
    XCTAssertTrue([[self.controller valueForKey:@"reconnectRequired"] boolValue]);
    XCTAssertEqualObjects(self.controller.resultTitle, @"game_push.ui.cancelled_title");
}

// END 已提交而拒绝取消后，保留原任务并禁用重复取消。
- (void)testRejectedCancellationKeepsOriginalOperationActive {
    [self.controller startPush];
    [self.controller confirmCancel];
    self.interface.cancelCompletion(NO, [self gameError:eTSErrorPreTaskExecuting]);
    [self drainMainQueue];
    XCTAssertTrue([[self.controller valueForKey:@"pushing"] boolValue]);
    XCTAssertFalse([[self.controller valueForKey:@"cancelRequested"] boolValue]);
    XCTAssertTrue([[self.controller valueForKey:@"cancelRejected"] boolValue]);
    XCTAssertNil(self.controller.resultTitle);
    [self.controller confirmCancel];
    XCTAssertEqual(self.interface.cancelCount, 1u);
    self.interface.pushCompletion(YES, nil);
    [self drainMainQueue];
    XCTAssertEqualObjects(self.controller.resultTitle, @"game_push.ui.success_title");
}

// 第一笔取消迟到时，不得把新操作改成取消中、拒绝或失败。
- (void)testLateCancellationCannotMutateNewOperation {
    [self.controller startPush];
    [self.controller confirmCancel];
    TSCompletionBlock oldCancel = self.interface.cancelCompletion;
    self.interface.pushCompletion(NO, [self gameError:eTSErrorParamError]);
    [self drainMainQueue];
    [self deliverSuccessfulQueries];
    [self prepareValidConfiguration];
    [self.controller startPush];
    XCTAssertEqual(self.interface.pushCount, 2u);
    NSUUID *newToken = [self.controller valueForKey:@"operationToken"];
    oldCancel(NO, [self gameError:eTSErrorPreTaskExecuting]);
    [self drainMainQueue];
    XCTAssertTrue([[self.controller valueForKey:@"pushing"] boolValue]);
    XCTAssertFalse([[self.controller valueForKey:@"cancelRequested"] boolValue]);
    XCTAssertFalse([[self.controller valueForKey:@"cancelRejected"] boolValue]);
    XCTAssertEqualObjects([self.controller valueForKey:@"operationToken"], newToken);
    XCTAssertNil(self.controller.toastMessage, @"旧取消不能给新操作显示拒绝提示");
}

// 门面切换后取消仍发给启动原任务时保存的接口。
- (void)testCancellationUsesOriginalInterfaceAfterFacadeChanges {
    [self.controller startPush];
    TSGamePushTestInterface *replacement = [[TSGamePushTestInterface alloc] init];
    self.controller.testInterface = replacement;
    [self.controller confirmCancel];
    XCTAssertEqual(self.interface.cancelCount, 1u);
    XCTAssertEqual(replacement.cancelCount, 0u);
}

// 原始 completion 的成功必须同时满足 success 和无 error。
- (void)testSuccessFlagWithErrorCannotDisplayInstalled {
    [self.controller startPush];
    self.interface.pushCompletion(YES, [self gameError:eTSErrorParamError]);
    [self drainMainQueue];
    XCTAssertFalse([[self.controller valueForKey:@"pushing"] boolValue]);
    XCTAssertEqualObjects(self.controller.resultTitle, @"game_push.ui.failed_title");
    XCTAssertNotEqual([[self.controller valueForKey:@"transferProgress"] integerValue], 100);
}

// 结果未确认不会因刷新到已有同类型条目而升级为成功或自动允许重推。
- (void)testUncertainInstallationRemainsBlockedAfterSuccessfulRefresh {
    [self.controller startPush];
    NSError *error = [NSError errorWithDomain:kTSErrorDomainGamePushName code:eTSErrorTimeoutError
        userInfo:@{NSLocalizedDescriptionKey: @"测试注入：安装结果未确认", @"installationResultUncertain": @YES}];
    self.interface.pushCompletion(NO, error);
    [self drainMainQueue];
    self.interface.gamesCompletion(@[[[TSGameModel alloc] init]], nil);
    [self deliverSuccessfulQueries];
    XCTAssertEqualObjects(self.controller.resultTitle, @"game_push.ui.uncertain_title");
    XCTAssertTrue([[self.controller valueForKey:@"installationUncertain"] boolValue]);
    XCTAssertFalse([self.controller canPrepareInstallation]);
    XCTAssertEqual(self.interface.pushCount, 1u, @"刷新不能自动重推游戏包");
}

// 完成后迟到的进度或失败不能覆盖已确认成功结果。
- (void)testLatePushCallbacksCannotReplaceConfirmedSuccess {
    [self.controller startPush];
    TSCompletionBlock completion = self.interface.pushCompletion;
    TSFileTransferProgressBlock progress = self.interface.progressBlock;
    completion(YES, nil);
    [self drainMainQueue];
    progress(eTSFileTransferStatusProgress, 25);
    completion(NO, [self gameError:eTSErrorParamError]);
    [self drainMainQueue];
    XCTAssertEqualObjects(self.controller.resultTitle, @"game_push.ui.success_title");
    XCTAssertEqualObjects([self.controller valueForKey:@"transferProgress"], @100);
    XCTAssertFalse([[self.controller valueForKey:@"pushing"] boolValue]);
}

// 同设备重连后旧成功仍收尾原任务和文件状态，但不能显示到新会话。
- (void)testOldGenerationPushSuccessCleansUpWithoutShowingResult {
    [self.controller startPush];
    self.controller.testSnapshot = [self snapshotWithGeneration:8];
    self.interface.progressBlock(eTSFileTransferStatusProgress, 80);
    [self drainMainQueue];
    XCTAssertEqualObjects([self.controller valueForKey:@"transferProgress"], @0);
    self.interface.pushCompletion(YES, nil);
    [self drainMainQueue];
    XCTAssertFalse([[self.controller valueForKey:@"pushing"] boolValue]);
    XCTAssertNil([self.controller valueForKey:@"operationToken"]);
    XCTAssertNil([self.controller valueForKey:@"activeInterface"]);
    XCTAssertEqualObjects([self.controller valueForKey:@"localFilePath"], @"");
    XCTAssertEqualObjects([self.controller valueForKey:@"fileSize"], @0);
    XCTAssertNil(self.controller.resultTitle, @"旧会话成功不能出现在重连后的结果弹层");
    XCTAssertNotEqual([[self.controller valueForKey:@"transferProgress"] integerValue], 100);
    XCTAssertEqualObjects(self.controller.toastMessage, TSLocalizedString(@"game_push.ui.device_changed"));
}

// 同设备同代次但接口已替换时，旧任务完成同样不能污染当前结果。
- (void)testReplacedInterfacePushSuccessDoesNotShowCurrentResult {
    [self.controller startPush];
    TSGamePushTestInterface *replacement = [[TSGamePushTestInterface alloc] init];
    replacement.supported = YES;
    replacement.slotsSupported = YES;
    self.controller.testInterface = replacement;
    self.interface.progressBlock(eTSFileTransferStatusProgress, 80);
    [self drainMainQueue];
    XCTAssertEqualObjects([self.controller valueForKey:@"transferProgress"], @0);
    self.interface.pushCompletion(YES, nil);
    [self drainMainQueue];
    XCTAssertFalse([[self.controller valueForKey:@"pushing"] boolValue]);
    XCTAssertNil([self.controller valueForKey:@"activeInterface"]);
    XCTAssertEqualObjects([self.controller valueForKey:@"localFilePath"], @"");
    XCTAssertNil(self.controller.resultTitle);
    XCTAssertNotNil(replacement.gamesCompletion, @"旧任务收尾后应通过新接口重新查询");
    XCTAssertEqual(replacement.pushCount, 0u, @"刷新新接口不能自动重推");
}

// 未确认状态按设备保留，切到B不误阻塞B，切回A也不能丢失门禁。
- (void)testUncertainInstallationGateSurvivesDeviceRoundTrip {
    TSPeripheral *originalPeripheral = self.peripheral;
    [self.controller startPush];
    NSError *error = [NSError errorWithDomain:kTSErrorDomainGamePushName code:eTSErrorTimeoutError
        userInfo:@{NSLocalizedDescriptionKey: @"测试注入：安装结果未确认", @"installationResultUncertain": @YES}];
    self.interface.pushCompletion(NO, error);
    [self drainMainQueue];
    XCTAssertEqual([[self.controller valueForKey:@"uncertainSnapshots"] count], 1u);
    self.peripheral = [[TSPeripheral alloc] init];
    self.peripheral.systemInfo.mac = @"00:11:22:33:44:66";
    self.controller.testSnapshot = [self snapshotWithGeneration:8];
    [self.controller reloadGameData];
    [self deliverSuccessfulQueries];
    XCTAssertFalse([[self.controller valueForKey:@"installationUncertain"] boolValue]);
    XCTAssertTrue([self.controller canPrepareInstallation], @"设备A未确认不应阻塞已就绪的B");
    self.peripheral = originalPeripheral;
    self.controller.testSnapshot = [self snapshotWithGeneration:9];
    [self.controller reloadGameData];
    [self deliverSuccessfulQueries];
    XCTAssertTrue([[self.controller valueForKey:@"installationUncertain"] boolValue]);
    XCTAssertFalse([self.controller canPrepareInstallation], @"切回A后仍需核实原安装结果");
    XCTAssertEqual(self.interface.pushCount, 1u);
}

#pragma mark - 路径与槽位交互

// 确认页保留文件和安装位置，彻底移除人工元数据输入。
- (void)testConfigurationShowsPackageAndSlotsWithoutMetadataInputs {
    self.controller.rendersConfiguration = YES;
    [self.controller configureInstallation];
    UIStackView *stack = [self.controller valueForKey:@"sheetStack"];
    XCTAssertNotNil(stack);
    NSMutableArray<UIView *> *views = [NSMutableArray arrayWithObject:stack];
    NSMutableArray<NSString *> *labels = [NSMutableArray array];
    while (views.count) {
        UIView *view = views.lastObject;
        [views removeLastObject];
        XCTAssertFalse([view isKindOfClass:UITextField.class]);
        if ([view isKindOfClass:UILabel.class] && ((UILabel *)view).text) {
            [labels addObject:((UILabel *)view).text];
        }
        [views addObjectsFromArray:view.subviews];
    }
    XCTAssertTrue([labels containsObject:@"fixture.bin"]);
    XCTAssertTrue([labels containsObject:TSLocalizedString(@"game_push.ui.select_position")]);
    XCTAssertFalse([labels containsObject:TSLocalizedString(@"game_push.ui.game_type")]);
    XCTAssertFalse([labels containsObject:TSLocalizedString(@"game_push.ui.skin_number")]);
}

// 非内置占用槽可选，确认前不发送；确认后只发送一次路径与槽位。
- (void)testOccupiedSlotRequiresExplicitReplacementConfirmation {
    [self prepareOccupiedSlot];
    XCTAssertNil([self.controller configurationIssue]);
    [self.controller startPush];
    XCTAssertEqual(self.interface.pushCount, 0u);
    XCTAssertNotNil([self.controller valueForKey:@"replacementRequest"]);
    [self.controller confirmReplacement];
    [self.controller confirmReplacement];
    XCTAssertEqual(self.interface.pushCount, 1u);
    XCTAssertEqualObjects(self.interface.receivedRequest.targetSlotIndex, @7);
    XCTAssertEqualObjects(self.interface.receivedRequest.localFilePath, @"/game-push-test/fixture.bin");
}

// 关闭替换提示表示取消本次提交，不能由迟到点击触发推送。
- (void)testClosingReplacementSheetDoesNotSubmit {
    [self prepareOccupiedSlot];
    [self.controller startPush];
    [self.controller closeSheet];
    [self.controller confirmReplacement];
    XCTAssertEqual(self.interface.pushCount, 0u);
}

// 确认弹层展示后文件或原槽位内容变化，必须重新确认。
- (void)testReplacementConfirmationRejectsChangedContentOrFile {
    TSGameSlotModel *slot = [self prepareOccupiedSlot];
    [self.controller startPush];
    slot.rawIdentifier = 0x219;
    [self.controller confirmReplacement];
    XCTAssertEqual(self.interface.pushCount, 0u);
    XCTAssertEqualObjects(self.controller.toastMessage, TSLocalizedString(@"game_push.ui.selection_changed"));
    [self prepareOccupiedSlot];
    [self.controller startPush];
    [self.controller setValue:@"/game-push-test/changed.bin" forKey:@"localFilePath"];
    [self.controller confirmReplacement];
    XCTAssertEqual(self.interface.pushCount, 0u);
}

// 替换确认绑定打开时的连接，重连后不能沿用旧授权。
- (void)testReplacementConfirmationRejectsChangedSession {
    [self prepareOccupiedSlot];
    [self.controller startPush];
    self.controller.testSnapshot = [self snapshotWithGeneration:8];
    [self.controller confirmReplacement];
    XCTAssertEqual(self.interface.pushCount, 0u);
}

// 同一身份中任一条目是内置均不可覆盖；查询错误也不能被旧数据绕过。
- (void)testOccupiedSlotProtectsBuiltInAndUnconfirmedContent {
    TSGameSlotModel *slot = [self prepareOccupiedSlot];
    TSGameModel *builtIn = [[TSGameModel alloc] init];
    builtIn.gameType = slot.gameType;
    builtIn.skinNumber = slot.skinNumber;
    builtIn.builtIn = YES;
    NSArray *games = [self.controller valueForKey:@"installedGames"];
    [self.controller setValue:[games arrayByAddingObject:builtIn] forKey:@"installedGames"];
    XCTAssertEqualObjects([self.controller slotUnavailableReason:slot], TSLocalizedString(@"game_push.ui.builtin_protected"));
    [self.controller setValue:games forKey:@"installedGames"];
    NSMutableDictionary *errors = [self.controller valueForKey:@"queryErrors"];
    errors[@"games"] = [self gameError:eTSErrorTimeoutError];
    XCTAssertEqualObjects([self.controller slotUnavailableReason:slot], TSLocalizedString(@"game_push.ui.slot_content_unknown"));
    slot.empty = YES;
    XCTAssertNil([self.controller slotUnavailableReason:slot]);
}

// 推送前未结束的展示查询不能填充成功后的列表；刷新失败不撤销推送结果。
- (void)testSuccessRefreshIgnoresPrePushQueriesAndPreservesTransferResult {
    [self.controller reloadGameData];
    TSInstalledGamesCompletionBlock oldGames = self.interface.gamesCompletion;
    self.interface.slotsCompletion(@[[self slotWithIndex:7 capacity:1024 empty:YES]], nil);
    [self.controller setValue:@7 forKey:@"selectedSlotIndex"];
    XCTAssertTrue([self.controller canPrepareInstallation]);
    [self.controller startPush];
    self.interface.pushCompletion(YES, nil);
    oldGames(@[[[TSGameModel alloc] init]], nil);
    XCTAssertNil([self.controller valueForKey:@"installedGames"]);
    self.interface.gamesCompletion(nil, [self gameError:eTSErrorTimeoutError]);
    [self deliverSuccessfulQueries];
    XCTAssertEqualObjects(self.controller.resultTitle, @"game_push.ui.success_title");
    XCTAssertNotNil([self.controller valueForKey:@"queryErrors"][@"games"]);
    XCTAssertFalse([[self.controller valueForKey:@"recentWarning"] boolValue]);
    XCTAssertEqualObjects([self.controller valueForKey:@"transferProgress"], @100);
    XCTAssertEqual(self.interface.pushCount, 1u);
}

// SDK 已接受成功后设备断连，原设备仍可展示推送完成，不伪造失败。
- (void)testAcknowledgedTransferCanDisplaySuccessAfterDeviceDisconnects {
    [self.controller startPush];
    self.controller.testSnapshot = [TSDeviceConnectionSnapshot snapshotWithSDKState:TSDemoSDKStateReady
        activeSDKType:eTSSDKTypeTPB connectionState:eTSBleStateDisconnected peripheral:self.peripheral
        error:nil hasBinding:YES sessionReady:NO connectionGeneration:7];
    self.interface.pushCompletion(YES, nil);
    XCTAssertEqualObjects(self.controller.resultTitle, @"game_push.ui.success_title");
    XCTAssertEqualObjects([self.controller valueForKey:@"transferProgress"], @100);
    XCTAssertFalse([[self.controller valueForKey:@"installationUncertain"] boolValue]);
}

#pragma mark - 夹具

// 准备可替换的未命名游戏类型，验证不依赖枚举或支持类型列表。
- (TSGameSlotModel *)prepareOccupiedSlot {
    TSGameSlotModel *slot = [self slotWithIndex:7 capacity:1024 empty:NO];
    slot.rawIdentifier = 0x119;
    TSGameModel *game = [[TSGameModel alloc] init];
    game.gameType = (TSGameType)25;
    game.skinNumber = 1;
    [self.controller setValue:@[slot] forKey:@"gameSlots"];
    [self.controller setValue:@[game] forKey:@"installedGames"];
    return slot;
}

// 使用真实不可变快照模型；固定测试 MAC 不对应任何真实设备。
- (TSDeviceConnectionSnapshot *)snapshotWithGeneration:(NSUInteger)generation {
    return [TSDeviceConnectionSnapshot snapshotWithSDKState:TSDemoSDKStateReady
        activeSDKType:eTSSDKTypeTPB connectionState:eTSBleStateConnected peripheral:self.peripheral
        error:nil hasBinding:YES sessionReady:YES connectionGeneration:generation];
}

// 构造真实槽位模型，内容 ID 不参与索引选择。
- (TSGameSlotModel *)slotWithIndex:(NSInteger)index capacity:(uint64_t)capacity empty:(BOOL)empty {
    TSGameSlotModel *slot = [[TSGameSlotModel alloc] init];
    slot.slotIndex = index;
    slot.capacityBytes = capacity;
    slot.empty = empty;
    return slot;
}

// 仅准备页面需要的模型；路径不写盘，文件合法性属于 SDK 独立用例。
- (void)prepareValidConfiguration {
    TSStorageSpace *storage = [[TSStorageSpace alloc] init];
    storage.total = 4096;
    storage.available = 4096;
    [self.controller setValue:self.controller.testSnapshot forKey:@"sessionSnapshot"];
    [self.controller setValue:self.controller.testSnapshot forKey:@"lastReadySnapshot"];
    [self.controller setValue:self.interface forKey:@"queryInterface"];
    [self.controller setValue:@[] forKey:@"installedGames"];
    [self.controller setValue:@[@0, @24, @99] forKey:@"supportedTypes"];
    [self.controller setValue:@[[self slotWithIndex:7 capacity:1024 empty:YES]] forKey:@"gameSlots"];
    [self.controller setValue:storage forKey:@"gameStorage"];
    [self.controller setValue:@"/game-push-test/fixture.bin" forKey:@"localFilePath"];
    [self.controller setValue:@512 forKey:@"fileSize"];
    [self.controller setValue:@7 forKey:@"selectedSlotIndex"];
}

// 交付所有已注册查询；已完成 key 的重复结果由真实页面忽略。
- (void)deliverSuccessfulQueries {
    XCTAssertNotNil(self.interface.gamesCompletion, @"必须由页面先发起查询");
    XCTAssertNotNil(self.interface.typesCompletion);
    XCTAssertNotNil(self.interface.storageCompletion);
    TSStorageSpace *storage = [[TSStorageSpace alloc] init];
    storage.total = 4096;
    storage.available = 4096;
    self.interface.gamesCompletion(@[], nil);
    self.interface.typesCompletion(@[@0, @24, @99], nil);
    self.interface.storageCompletion(storage, nil);
    if (self.interface.slotsSupported) {
        XCTAssertNotNil(self.interface.slotsCompletion);
        self.interface.slotsCompletion(@[[self slotWithIndex:7 capacity:1024 empty:YES]], nil);
    }
    [self drainMainQueue];
}

// 仅注入公开游戏错误域及已有错误码。
- (NSError *)gameError:(NSInteger)code {
    return [NSError errorWithDomain:kTSErrorDomainGamePushName code:code
        userInfo:@{NSLocalizedDescriptionKey: @"页面白盒测试注入错误"}];
}

// 创建本条用例拥有的非空文件，仅验证导入，不冒充合法固件游戏包。
- (NSURL *)createImportFixture {
    self.fixtureDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
    NSError *error = nil;
    XCTAssertTrue([NSFileManager.defaultManager createDirectoryAtPath:self.fixtureDirectory
        withIntermediateDirectories:YES attributes:nil error:&error]);
    NSURL *fileURL = [NSURL fileURLWithPath:[self.fixtureDirectory stringByAppendingPathComponent:@"sample.bin"]];
    XCTAssertTrue([[@"local import fixture" dataUsingEncoding:NSUTF8StringEncoding] writeToURL:fileURL options:0 error:&error]);
    return fileURL;
}

// 使用队列哨兵交付已有异步块，不以睡眠制造竞态。
- (void)drainMainQueue {
    XCTestExpectation *delivery = [self expectationWithDescription:@"主线程页面回调交付"];
    dispatch_async(dispatch_get_main_queue(), ^{ [delivery fulfill]; });
    [self waitForExpectations:@[delivery] timeout:1.0];
}

@end
