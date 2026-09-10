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

/** 验证 SDK 裸 PCM 保存后可被系统解码，并保留完整采样 */
- (void)testStoreConvertsPCMToPlayableWAV {
    TSAIAudioRecordDraft *draft = [[TSAIAudioRecordDraft alloc] init];
    NSURL *sourceURL = [NSURL fileURLWithPath:[NSTemporaryDirectory()
        stringByAppendingPathComponent:[NSUUID.UUID.UUIDString stringByAppendingPathExtension:@"pcm"]]];
    NSMutableData *pcmData = [NSMutableData dataWithLength:32000];
    int16_t *samples = pcmData.mutableBytes;
    for (NSUInteger sampleIndex = 0; sampleIndex < 16000; sampleIndex++) {
        samples[sampleIndex] = (int16_t)(sampleIndex % 100 * 100);
    }
    XCTAssertTrue([pcmData writeToURL:sourceURL atomically:YES]);
    draft.rawAudioFilePath = sourceURL.path;
    TSAIAudioRecordDraftStore *store = [[TSAIAudioRecordDraftStore alloc] init];
    NSError *error = nil;
    XCTAssertTrue([store saveDraft:draft error:&error]);
    XCTAssertNil(error);
    NSURL *audioURL = [store audioFileURLForMetadata:[draft dictionaryRepresentation] error:&error];
    XCTAssertEqualObjects(audioURL.pathExtension, @"wav");
    AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:audioURL error:&error];
    XCTAssertNotNil(audioFile);
    XCTAssertNil(error);
    XCTAssertEqual(audioFile.length, 16000);
    XCTAssertEqualWithAccuracy(audioFile.fileFormat.sampleRate, 16000.0, 0.01);
    XCTAssertEqual(audioFile.fileFormat.channelCount, 1u);
    NSData *wavData = [NSData dataWithContentsOfURL:audioURL];
    XCTAssertEqualObjects([wavData subdataWithRange:NSMakeRange(44, pcmData.length)], pcmData);
    [[NSFileManager defaultManager] removeItemAtURL:[audioURL URLByDeletingLastPathComponent] error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:sourceURL error:nil];
}

/** 验证历史 PCM 可重复打开，且原音频不会被覆盖 */
- (void)testStoreResolvesLegacyPCMAsWAV {
    TSAIAudioRecordDraftStore *store = [[TSAIAudioRecordDraftStore alloc] init];
    NSString *recordIdentifier = NSUUID.UUID.UUIDString;
    NSURL *directoryURL = [[store recordingsRootDirectory] URLByAppendingPathComponent:recordIdentifier];
    XCTAssertTrue([[NSFileManager defaultManager] createDirectoryAtURL:directoryURL
                                         withIntermediateDirectories:YES attributes:nil error:nil]);
    NSURL *sourceURL = [directoryURL URLByAppendingPathComponent:@"recording.pcm"];
    NSData *pcmData = [NSMutableData dataWithLength:32000];
    XCTAssertTrue([pcmData writeToURL:sourceURL atomically:YES]);
    NSDictionary *metadata = @{@"audioRelativePath":
        [recordIdentifier stringByAppendingPathComponent:@"recording.pcm"]};
    NSError *error = nil;
    NSURL *audioURL = [store audioFileURLForMetadata:metadata error:&error];
    XCTAssertNotNil(audioURL);
    XCTAssertNil(error);
    AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:audioURL error:&error];
    XCTAssertNotNil(audioFile);
    XCTAssertEqual(audioFile.length, 16000);
    XCTAssertEqualObjects([store audioFileURLForMetadata:metadata error:&error], audioURL);
    XCTAssertEqualObjects([NSData dataWithContentsOfURL:sourceURL], pcmData);
    [[NSFileManager defaultManager] removeItemAtURL:directoryURL error:nil];
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

@end
