//
//  TSAIAudioRecordDraftStoreTests.m
//  TopStepComKit-Git_Tests
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>

#import <TopStepAIKit/TopStepAIKit.h>

#import "../../TopStepComKit-Git/Source/Device/AIKit/AudioRecord/Model/TSAIAudioRecordDraft.h"
#import "../../TopStepComKit-Git/Source/Device/AIKit/AudioRecord/Store/TSAIAudioRecordDraftStore.h"
#import "../../TopStepComKit-Git/Source/Device/AIKit/AudioRecord/Store/TSAIAudioRecordPCMFileWriter.h"

@interface TSAIAudioRecordDraftStoreTests : XCTestCase

@end


@implementation TSAIAudioRecordDraftStoreTests

/** 验证同一句流式转写会被幂等更新 */
- (void)testTranscriptUpdatesSameSentence {
    TSAIAudioRecordDraft *draft = [TSAIAudioRecordDraft
        draftWithScene:TSAIAudioRecordSceneOnSite
        language:TSAILanguageChineseSimplified
        source:TSAIAudioRecordSessionSourceApp
        startDate:[NSDate date]];
    TSAIAudioRecordSessionResult *partialResult = [[TSAIAudioRecordSessionResult alloc] init];
    partialResult.type = TSAIAudioRecordSessionResultTypeTranscript;
    partialResult.sentenceIndex = 7;
    partialResult.text = @"Hello";
    partialResult.isSentenceFinal = NO;
    [draft applySessionResult:partialResult];

    TSAIAudioRecordSessionResult *finalResult = [[TSAIAudioRecordSessionResult alloc] init];
    finalResult.type = TSAIAudioRecordSessionResultTypeTranscript;
    finalResult.sentenceIndex = 7;
    finalResult.text = @"Hello world";
    finalResult.isSentenceFinal = YES;
    [draft applySessionResult:finalResult];

    XCTAssertEqual(draft.transcriptItems.count, 1u);
    XCTAssertEqualObjects(draft.transcriptItems.firstObject.text, @"Hello world");
    XCTAssertTrue(draft.transcriptItems.firstObject.isFinal);
}

/** 验证 Demo 存储会复制临时音频并写入元数据 */
- (void)testStoreCopiesAudioAndWritesMetadata {
    TSAIAudioRecordDraft *draft = [TSAIAudioRecordDraft
        draftWithScene:TSAIAudioRecordSceneOnSite
        language:TSAILanguageEnglishUS
        source:TSAIAudioRecordSessionSourceApp
        startDate:[NSDate date]];
    NSString *temporaryName = [NSString stringWithFormat:@"%@.wav", NSUUID.UUID.UUIDString];
    NSString *temporaryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:temporaryName];
    NSData *audioData = [@"demo-audio" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertTrue([audioData writeToFile:temporaryPath atomically:YES]);
    draft.rawAudioFilePath = temporaryPath;

    TSAIAudioRecordDraftStore *store = [[TSAIAudioRecordDraftStore alloc] init];
    NSError *saveError = nil;
    BOOL didSave = [store saveDraft:draft error:&saveError];
    NSURL *recordDirectory = [[store recordingsRootDirectory]
        URLByAppendingPathComponent:draft.recordIdentifier
        isDirectory:YES];
    NSURL *metadataURL = [recordDirectory URLByAppendingPathComponent:@"metadata.json"];
    NSURL *audioURL = [recordDirectory URLByAppendingPathComponent:@"recording.wav"];

    XCTAssertTrue(didSave);
    XCTAssertNil(saveError);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:metadataURL.path]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:audioURL.path]);
    XCTAssertEqualObjects(draft.storedAudioRelativePath,
                          [draft.recordIdentifier stringByAppendingPathComponent:@"recording.wav"]);

    NSDictionary<NSString *, id> *metadata = [draft dictionaryRepresentation];
    NSError *resolveError = nil;
    NSURL *resolvedAudioURL = [store audioFileURLForMetadata:metadata error:&resolveError];
    XCTAssertNil(resolveError);
    XCTAssertEqualObjects(resolvedAudioURL.path, audioURL.path);

    [[NSFileManager defaultManager] removeItemAtURL:recordDirectory error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:temporaryPath error:nil];
}

/** 验证缺少音频时不会留下可见的历史元数据 */
- (void)testStoreDoesNotCommitMetadataWithoutAudio {
    TSAIAudioRecordDraft *draft = [TSAIAudioRecordDraft
        draftWithScene:TSAIAudioRecordSceneOnSite
        language:TSAILanguageEnglishUS
        source:TSAIAudioRecordSessionSourceApp
        startDate:[NSDate date]];
    TSAIAudioRecordDraftStore *store = [[TSAIAudioRecordDraftStore alloc] init];

    NSError *saveError = nil;
    BOOL didSave = [store saveDraft:draft error:&saveError];
    NSURL *recordDirectory = [[store recordingsRootDirectory]
        URLByAppendingPathComponent:draft.recordIdentifier
        isDirectory:YES];

    XCTAssertFalse(didSave);
    XCTAssertEqual(saveError.code, TSAIAudioRecordDemoErrorCodeAudioMissing);
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:recordDirectory.path]);
}

/** 验证旧版本遗留的无音频元数据不会进入历史列表 */
- (void)testStoreFiltersLegacyMetadataWithoutAudio {
    TSAIAudioRecordDraft *draft = [TSAIAudioRecordDraft
        draftWithScene:TSAIAudioRecordSceneOnSite
        language:TSAILanguageEnglishUS
        source:TSAIAudioRecordSessionSourceApp
        startDate:[NSDate date]];
    TSAIAudioRecordDraftStore *store = [[TSAIAudioRecordDraftStore alloc] init];
    NSURL *recordDirectory = [[store recordingsRootDirectory]
        URLByAppendingPathComponent:draft.recordIdentifier
        isDirectory:YES];
    XCTAssertTrue([[NSFileManager defaultManager]
        createDirectoryAtURL:recordDirectory
        withIntermediateDirectories:YES
        attributes:nil
        error:nil]);
    NSData *metadataData = [NSJSONSerialization dataWithJSONObject:[draft dictionaryRepresentation]
                                                           options:0
                                                             error:nil];
    NSURL *metadataURL = [recordDirectory URLByAppendingPathComponent:@"metadata.json"];
    XCTAssertTrue([metadataData writeToURL:metadataURL atomically:YES]);

    NSArray<NSDictionary<NSString *, id> *> *records = [store loadRecordingMetadata];
    NSPredicate *sameRecordPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *metadata,
                                                                             NSDictionary *bindings) {
        return [metadata[@"recordIdentifier"] isEqualToString:draft.recordIdentifier];
    }];
    XCTAssertEqual([[records filteredArrayUsingPredicate:sameRecordPredicate] count], 0u);

    [[NSFileManager defaultManager] removeItemAtURL:recordDirectory error:nil];
}

/** 验证播放器不会接受越过录音根目录的相对路径 */
- (void)testStoreRejectsAudioPathOutsideRecordingDirectory {
    TSAIAudioRecordDraftStore *store = [[TSAIAudioRecordDraftStore alloc] init];
    NSDictionary<NSString *, id> *metadata = @{
        @"audioRelativePath": @"../unexpected.wav",
    };

    NSError *resolveError = nil;
    NSURL *resolvedAudioURL = [store audioFileURLForMetadata:metadata error:&resolveError];

    XCTAssertNil(resolvedAudioURL);
    XCTAssertEqual(resolveError.code, TSAIAudioRecordDemoErrorCodeAudioMissing);
}

/** 验证 SDK 返回的原始 PCM 保存后可被系统播放器识别 */
- (void)testStoreConvertsRawPCMToPlayableWAV {
    TSAIAudioRecordDraft *draft = [[TSAIAudioRecordDraft alloc] init];
    NSURL *pcmURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()]
        URLByAppendingPathComponent:[NSUUID.UUID.UUIDString stringByAppendingPathExtension:@"PCM"]];
    // 使用与故障日志相同的数据量，并覆盖多个读取块。
    NSMutableData *pcmData = [NSMutableData dataWithLength:276480];
    memset(pcmData.mutableBytes, 0x12, pcmData.length);
    XCTAssertTrue([pcmData writeToURL:pcmURL atomically:YES]);
    draft.rawAudioFilePath = pcmURL.path;
    TSAIAudioRecordDraftStore *store = [[TSAIAudioRecordDraftStore alloc] init];
    NSURL *recordDirectory = [[store recordingsRootDirectory]
        URLByAppendingPathComponent:draft.recordIdentifier isDirectory:YES];
    @try {
        NSError *saveError = nil;
        XCTAssertTrue([store saveDraft:draft error:&saveError]);
        XCTAssertNil(saveError);
        XCTAssertEqualObjects(draft.storedAudioRelativePath.pathExtension, @"wav");
        NSURL *wavURL = [store audioFileURLForMetadata:[draft dictionaryRepresentation] error:nil];
        [self assertPlayableWAVAtURL:wavURL containsPCMData:pcmData];
        XCTAssertEqualObjects([NSData dataWithContentsOfURL:pcmURL], pcmData);
        NSData *metadataData = [NSData dataWithContentsOfURL:
            [recordDirectory URLByAppendingPathComponent:@"metadata.json"]];
        NSDictionary *metadata = [NSJSONSerialization JSONObjectWithData:metadataData options:0 error:nil];
        XCTAssertEqualObjects(metadata[@"audioRelativePath"], draft.storedAudioRelativePath);
    } @finally {
        [[NSFileManager defaultManager] removeItemAtURL:recordDirectory error:nil];
        [[NSFileManager defaultManager] removeItemAtURL:pcmURL error:nil];
    }
}

/** 验证已保存的 PCM 按需生成 WAV，保留原始音频和元数据并复用副本 */
- (void)testStorePreparesLegacyPCMOnlyWhenOpened {
    TSAIAudioRecordDraftStore *store = [[TSAIAudioRecordDraftStore alloc] init];
    TSAIAudioRecordDraft *draft = [[TSAIAudioRecordDraft alloc] init];
    draft.storedAudioRelativePath = [draft.recordIdentifier stringByAppendingPathComponent:@"recording.pcm"];
    NSURL *recordDirectory = [[store recordingsRootDirectory]
        URLByAppendingPathComponent:draft.recordIdentifier isDirectory:YES];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    XCTAssertTrue([fileManager createDirectoryAtURL:recordDirectory
                       withIntermediateDirectories:YES attributes:nil error:nil]);
    NSURL *pcmURL = [recordDirectory URLByAppendingPathComponent:@"recording.pcm"];
    NSURL *wavURL = [pcmURL URLByAppendingPathExtension:@"wav"];
    NSURL *metadataURL = [recordDirectory URLByAppendingPathComponent:@"metadata.json"];
    NSData *pcmData = [NSMutableData dataWithLength:32000];
    NSDictionary *metadata = [draft dictionaryRepresentation];
    NSData *metadataData = [NSJSONSerialization dataWithJSONObject:metadata options:0 error:nil];
    XCTAssertTrue([pcmData writeToURL:pcmURL atomically:YES]);
    XCTAssertTrue([metadataData writeToURL:metadataURL atomically:YES]);
    @try {
        NSArray *records = [store loadRecordingMetadata];
        XCTAssertTrue([records containsObject:metadata]);
        XCTAssertFalse([fileManager fileExistsAtPath:wavURL.path]);
        NSError *resolveError = nil;
        NSURL *resolvedURL = [store audioFileURLForMetadata:metadata error:&resolveError];
        XCTAssertNil(resolveError);
        [self assertPlayableWAVAtURL:resolvedURL containsPCMData:pcmData];
        NSDictionary *wavAttributes = [fileManager attributesOfItemAtPath:resolvedURL.path error:nil];
        XCTAssertEqualObjects([store audioFileURLForMetadata:metadata error:nil], resolvedURL);
        XCTAssertEqualObjects([fileManager attributesOfItemAtPath:resolvedURL.path error:nil][NSFileModificationDate],
                              wavAttributes[NSFileModificationDate]);
        XCTAssertEqualObjects([NSData dataWithContentsOfURL:pcmURL], pcmData);
        XCTAssertEqualObjects([NSData dataWithContentsOfURL:metadataURL], metadataData);
    } @finally {
        [fileManager removeItemAtURL:recordDirectory error:nil];
    }
}

/** 验证空 PCM 和不完整 Int16 采样不会生成历史记录 */
- (void)testStoreRejectsEmptyOrTruncatedPCM {
    TSAIAudioRecordDraftStore *store = [[TSAIAudioRecordDraftStore alloc] init];
    for (NSNumber *byteCount in @[@0, @3]) {
        TSAIAudioRecordDraft *draft = [[TSAIAudioRecordDraft alloc] init];
        NSURL *pcmURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()]
            URLByAppendingPathComponent:[NSUUID.UUID.UUIDString stringByAppendingPathExtension:@"pcm"]];
        NSData *pcmData = [NSMutableData dataWithLength:byteCount.unsignedIntegerValue];
        XCTAssertTrue([pcmData writeToURL:pcmURL atomically:YES]);
        draft.rawAudioFilePath = pcmURL.path;
        NSURL *recordDirectory = [[store recordingsRootDirectory]
            URLByAppendingPathComponent:draft.recordIdentifier isDirectory:YES];
        @try {
            NSError *saveError = nil;
            XCTAssertFalse([store saveDraft:draft error:&saveError]);
            XCTAssertEqual(saveError.code, TSAIAudioRecordDemoErrorCodeConvertAudioFailed);
            XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:recordDirectory.path]);
            XCTAssertEqualObjects([NSData dataWithContentsOfURL:pcmURL], pcmData);
        } @finally {
            [[NSFileManager defaultManager] removeItemAtURL:recordDirectory error:nil];
            [[NSFileManager defaultManager] removeItemAtURL:pcmURL error:nil];
        }
    }
}

/** 验证实时 PCM 兜底文件会生成标准 WAV 头 */
- (void)testPCMWriterCreatesPlayableWAVContainer {
    TSAIAudioRecordPCMFileWriter *writer = [[TSAIAudioRecordPCMFileWriter alloc]
        initWithRecordIdentifier:NSUUID.UUID.UUIDString];
    XCTAssertNotNil(writer);
    NSData *oneSecondPCM = [NSMutableData dataWithLength:32000];
    [writer appendPCMData:oneSecondPCM];

    NSURL *wavURL = [writer finishWriting];
    NSData *wavData = [NSData dataWithContentsOfURL:wavURL];
    XCTAssertEqual(wavData.length, 32044u);
    XCTAssertEqualObjects([[NSString alloc] initWithData:[wavData subdataWithRange:NSMakeRange(0, 4)]
                                                encoding:NSASCIIStringEncoding], @"RIFF");
    XCTAssertEqualObjects([[NSString alloc] initWithData:[wavData subdataWithRange:NSMakeRange(8, 4)]
                                                encoding:NSASCIIStringEncoding], @"WAVE");
    [writer removeTemporaryFile];
}

/** 通过系统播放器校验 WAV 时长，并逐字节检查 PCM 内容未改变 */
- (void)assertPlayableWAVAtURL:(NSURL *)wavURL containsPCMData:(NSData *)pcmData {
    NSError *playerError = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:wavURL error:&playerError];
    XCTAssertNotNil(player);
    XCTAssertNil(playerError);
    XCTAssertEqual(player.numberOfChannels, 1u);
    XCTAssertEqualWithAccuracy(player.duration, pcmData.length / 32000.0, 0.001);
    NSData *wavData = [NSData dataWithContentsOfURL:wavURL];
    XCTAssertEqual(wavData.length, pcmData.length + 44);
    if (wavData.length == pcmData.length + 44) {
        XCTAssertEqualObjects([wavData subdataWithRange:NSMakeRange(44, pcmData.length)], pcmData);
    }
}

@end
