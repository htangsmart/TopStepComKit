//
//  TSDialEditorTemplateTests.m
//  TopStepComKit-Git_Tests
//

#import <XCTest/XCTest.h>
#import "../../TopStepComKit-Git/Source/Device/PeripheralDial/TSDialEditorVC.h"
#import "../../TopStepComKit-Git/Source/Device/PeripheralDial/TSDialEditorState.h"
#import "../../TopStepComKit-Git/Source/Device/PeripheralDial/TSDialEditorSheet.h"

@interface TSDialEditorVC (TemplateTesting)
- (TSDialDraft *)installationDraftWithVideoURL:(NSURL *)videoURL;
- (void)reviewBuiltTemplate;
- (BOOL)isInstalling;
- (void)installBuiltArtifact;
- (void)failInstallation:(NSString *)message;
@end

// 仅截获传输和错误，不连接设备；草稿装配与预览确认执行生产实现。
@interface TSDialEditorTemplateFixtureVC : TSDialEditorVC
// 是否发起传输及失败提示。
@property (nonatomic, assign) BOOL transmitted;
@property (nonatomic, copy) NSString *failureMessage;
@end

@implementation TSDialEditorTemplateFixtureVC
- (void)installBuiltArtifact { self.transmitted = YES; }
- (void)failInstallation:(NSString *)message { self.failureMessage = message; }
@end

@interface TSDialEditorTemplateTests : XCTestCase
// 本例专属目录与真实编辑状态。
@property (nonatomic, strong) NSURL *directoryURL;
@property (nonatomic, strong) TSDialEditorState *state;
@property (nonatomic, strong) TSDialEditorTemplateFixtureVC *editor;
@property (nonatomic, strong) UIImage *background;
@end

@implementation TSDialEditorTemplateTests

#pragma mark - 生命周期

// 通过公开模型创建离线编辑输入，不依赖 Provider 内部类型。
- (void)setUp {
    [super setUp];
    self.continueAfterFailure = NO;
    self.directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString]];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtURL:self.directoryURL
        withIntermediateDirectories:YES attributes:nil error:nil]);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(16, 16)];
    self.background = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [UIColor.greenColor setFill];
        UIRectFill(CGRectMake(0, 0, 16, 16));
    }];
    self.state = [[TSDialEditorState alloc] init];
    [self.state setValue:@(TSDialDraftTypeSingleImage) forKey:@"draftType"];
    self.state.images = @[@{@"name":@"test", @"image":self.background, @"source":self.background}];
    self.state.templateFileURL = [self.directoryURL URLByAppendingPathComponent:@"template.bin"];
    self.state.templateName = @"template.bin";
    NSData *fileData = [@"fixture" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([fileData writeToURL:self.state.templateFileURL atomically:YES]);
    XCTAssertTrue([fileData writeToURL:[self.directoryURL URLByAppendingPathComponent:@"package.bin"] atomically:YES]);
    self.editor = [[TSDialEditorTemplateFixtureVC alloc] initWithState:self.state];
    self.editor.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 390, 844)];
    TSCustomDialStyleConstraint *constraint = [[TSCustomDialStyleConstraint alloc]
        initWithScreenSize:CGSizeMake(16, 16) screenShape:eTSPeriphShapeSquare styles:@[] positions:@[] allowColorTint:NO];
    [self.editor setValue:constraint forKey:@"styleConstraint"];
    [self.editor setValue:[[TSDialEditorSheet alloc] init] forKey:@"sheet"];
    [self.editor setValue:[self.state copy] forKey:@"installationState"];
}

// 删除本例专属文件。
- (void)tearDown {
    self.editor = nil;
    [[NSFileManager defaultManager] removeItemAtURL:self.directoryURL error:nil];
    [super tearDown];
}

#pragma mark - 测试

// 使用冻结的模板路径，保留背景，并禁止把旧预览传给 SDK。
- (void)testDraftUsesFrozenLocalTemplateAndRequestsNewPreview {
    NSURL *frozenURL = self.state.templateFileURL;
    self.state.templateFileURL = nil;
    [self.editor setValue:self.background forKey:@"installationPreview"];
    TSDialDraft *draft = [self.editor installationDraftWithVideoURL:nil];
    XCTAssertEqualObjects(draft.templateFilePath, frozenURL.path);
    XCTAssertEqual(draft.items.count, 1);
    XCTAssertNotNil(draft.items.firstObject.image);
    XCTAssertNil(draft.previewImage);
    XCTAssertNil([self.editor valueForKey:@"installationPreview"]);
}

// 已返回新预览也不能直接传输，必须保留在确认阶段。
- (void)testBuiltPreviewWaitsForExplicitConfirmation {
    NSURL *previewURL = [self.directoryURL URLByAppendingPathComponent:@"preview.png"];
    XCTAssertTrue([UIImagePNGRepresentation(self.background) writeToURL:previewURL atomically:YES]);
    TSDialArtifact *artifact = [[TSDialArtifact alloc] initWithDialType:eTSDialTypeCustomer dialId:@"test"
        filePath:[self.directoryURL URLByAppendingPathComponent:@"package.bin"].path previewFilePath:previewURL.path];
    [self.editor setValue:artifact forKey:@"builtArtifact"];
    [self.editor reviewBuiltTemplate];
    XCTAssertFalse(self.editor.transmitted);
    XCTAssertNil(self.editor.failureMessage);
    XCTAssertTrue([self.editor isInstalling]);
    XCTAssertNotNil([self.editor valueForKey:@"installationPreview"]);
    TSDialEditorSheet *sheet = [self.editor valueForKey:@"sheet"];
    XCTAssertEqualObjects(sheet.title, @"确认制作结果");
    XCTAssertFalse(sheet.allowsDismissal);
    XCTAssertNotNil(sheet.onPrimary);
    XCTAssertNotNil(sheet.onSecondary);
}

// SDK 没有可读取的预览时停止，不能复用旧预览继续安装。
- (void)testMissingPreviewFailsWithoutTransmitting {
    TSDialArtifact *artifact = [[TSDialArtifact alloc] initWithDialType:eTSDialTypeCustomer dialId:@"test"
        filePath:[self.directoryURL URLByAppendingPathComponent:@"package.bin"].path previewFilePath:nil];
    [self.editor setValue:artifact forKey:@"builtArtifact"];
    [self.editor reviewBuiltTemplate];
    XCTAssertFalse(self.editor.transmitted);
    XCTAssertTrue([self.editor.failureMessage containsString:@"预览"]);
}

@end
