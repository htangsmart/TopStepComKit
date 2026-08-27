//
//  TSAIAudioRecordDraftStore.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordDraftStore.h"

#import "TSAIAudioRecordDraft.h"

NSErrorDomain const TSAIAudioRecordDemoErrorDomain = @"TSAIAudioRecordDemoErrorDomain";

@implementation TSAIAudioRecordDraftStore

#pragma mark - Public Methods

- (NSURL *)recordingsRootDirectory {
    NSArray<NSURL *> *applicationSupportDirectories = [[NSFileManager defaultManager]
        URLsForDirectory:NSApplicationSupportDirectory
        inDomains:NSUserDomainMask];
    NSURL *applicationSupportDirectory = applicationSupportDirectories.firstObject;
    NSURL *demoDirectory = [applicationSupportDirectory URLByAppendingPathComponent:@"TopStepComKitExample"
                                                                         isDirectory:YES];
    return [demoDirectory URLByAppendingPathComponent:@"AIAudioRecordings" isDirectory:YES];
}

- (BOOL)saveDraft:(TSAIAudioRecordDraft *)draft error:(NSError **)error {
    if (draft.recordIdentifier.length == 0) {
        [self assignError:error
                     code:TSAIAudioRecordDemoErrorCodeInvalidDraft
              description:@"The AI audio recording draft is invalid."];
        return NO;
    }

    NSURL *recordingDirectory = [[self recordingsRootDirectory]
        URLByAppendingPathComponent:draft.recordIdentifier
        isDirectory:YES];
    BOOL recordingDirectoryExisted = [[NSFileManager defaultManager]
        fileExistsAtPath:recordingDirectory.path];
    NSError *directoryError = nil;
    BOOL didCreateDirectory = [[NSFileManager defaultManager]
        createDirectoryAtURL:recordingDirectory
        withIntermediateDirectories:YES
        attributes:nil
        error:&directoryError];
    if (!didCreateDirectory) {
        [self assignError:error
                     code:TSAIAudioRecordDemoErrorCodeCreateDirectoryFailed
              description:directoryError.localizedDescription ?: @"Failed to create the recording directory."];
        return NO;
    }

    NSError *audioError = nil;
    BOOL didSaveAudio = [self copyAudioForDraft:draft
                              recordingDirectory:recordingDirectory
                                           error:&audioError];
    if (!didSaveAudio) {
        [self rollbackRecordingDirectory:recordingDirectory
                      directoryExisted:recordingDirectoryExisted];
        if (error != NULL) {
            *error = audioError;
        }
        return NO;
    }

    NSError *metadataError = nil;
    BOOL didSaveMetadata = [self writeMetadataForDraft:draft
                                    recordingDirectory:recordingDirectory
                                                 error:&metadataError];
    if (!didSaveMetadata) {
        [self rollbackRecordingDirectory:recordingDirectory
                      directoryExisted:recordingDirectoryExisted];
        if (error != NULL) {
            *error = metadataError;
        }
        return NO;
    }
    return YES;
}

/** 加载并按开始时间倒序排列本地录音元数据 */
- (NSArray<NSDictionary<NSString *, id> *> *)loadRecordingMetadata {
    NSArray<NSURL *> *recordingDirectories = [[NSFileManager defaultManager]
        contentsOfDirectoryAtURL:[self recordingsRootDirectory]
        includingPropertiesForKeys:nil
        options:NSDirectoryEnumerationSkipsHiddenFiles
        error:nil];
    NSMutableArray<NSDictionary<NSString *, id> *> *metadataList = [NSMutableArray array];
    for (NSURL *recordingDirectory in recordingDirectories) {
        NSURL *metadataURL = [recordingDirectory URLByAppendingPathComponent:@"metadata.json"];
        NSData *metadataData = [NSData dataWithContentsOfURL:metadataURL];
        if (metadataData.length == 0) {
            continue;
        }
        NSDictionary<NSString *, id> *metadata = [NSJSONSerialization JSONObjectWithData:metadataData
                                                                                   options:0
                                                                                     error:nil];
        if ([metadata isKindOfClass:NSDictionary.class] &&
            [self audioFileURLForMetadata:metadata error:nil] != nil) {
            [metadataList addObject:metadata];
        }
    }
    [metadataList sortUsingComparator:^NSComparisonResult(NSDictionary<NSString *, id> *first,
                                                           NSDictionary<NSString *, id> *second) {
        return [second[@"startTimestamp"] compare:first[@"startTimestamp"]];
    }];
    return [metadataList copy];
}

/** 解析元数据中的相对路径，并确保音频仍位于 Demo 录音目录内。 */
- (NSURL *)audioFileURLForMetadata:(NSDictionary<NSString *, id> *)metadata
                             error:(NSError **)error {
    id relativePathValue = metadata[@"audioRelativePath"];
    if (![relativePathValue isKindOfClass:NSString.class] ||
        [(NSString *)relativePathValue length] == 0) {
        [self assignError:error
                     code:TSAIAudioRecordDemoErrorCodeAudioMissing
              description:@"This recording does not contain a saved audio file."];
        return nil;
    }

    NSString *relativePath = (NSString *)relativePathValue;
    if ([relativePath hasPrefix:@"/"] ||
        [relativePath.pathComponents containsObject:@".."]) {
        [self assignError:error
                     code:TSAIAudioRecordDemoErrorCodeAudioMissing
              description:@"The saved audio path is invalid."];
        return nil;
    }

    NSURL *rootDirectory = [[self recordingsRootDirectory] URLByResolvingSymlinksInPath];
    NSURL *audioFileURL = [[[self recordingsRootDirectory]
        URLByAppendingPathComponent:relativePath]
        URLByStandardizingPath];
    NSURL *resolvedAudioFileURL = [audioFileURL URLByResolvingSymlinksInPath];
    NSString *rootPathPrefix = [rootDirectory.path stringByAppendingString:@"/"];
    BOOL isInsideRecordingDirectory = [resolvedAudioFileURL.path hasPrefix:rootPathPrefix];
    BOOL isDirectory = NO;
    BOOL fileExists = [[NSFileManager defaultManager]
        fileExistsAtPath:resolvedAudioFileURL.path
        isDirectory:&isDirectory];
    if (!isInsideRecordingDirectory || !fileExists || isDirectory) {
        [self assignError:error
                     code:TSAIAudioRecordDemoErrorCodeAudioMissing
              description:@"The saved audio file is unavailable."];
        return nil;
    }
    return resolvedAudioFileURL;
}

#pragma mark - Private Methods

/** 保存失败时回滚本次新建的录音目录 */
- (void)rollbackRecordingDirectory:(NSURL *)recordingDirectory
                 directoryExisted:(BOOL)directoryExisted {
    if (directoryExisted) {
        return;
    }
    [[NSFileManager defaultManager] removeItemAtURL:recordingDirectory error:nil];
}

/// 复制 SDK 返回的临时音频文件到 Demo 自有目录。
- (BOOL)copyAudioForDraft:(TSAIAudioRecordDraft *)draft
       recordingDirectory:(NSURL *)recordingDirectory
                    error:(NSError **)error {
    if (draft.rawAudioFilePath.length == 0 ||
        ![[NSFileManager defaultManager] fileExistsAtPath:draft.rawAudioFilePath]) {
        [self assignError:error
                     code:TSAIAudioRecordDemoErrorCodeAudioMissing
              description:@"The temporary AI recording audio file is unavailable."];
        return NO;
    }

    NSString *extension = draft.rawAudioFilePath.pathExtension.length > 0
        ? draft.rawAudioFilePath.pathExtension
        : @"wav";
    NSString *audioFileName = [@"recording" stringByAppendingPathExtension:extension];
    NSURL *destinationURL = [recordingDirectory URLByAppendingPathComponent:audioFileName];
    NSError *copyError = nil;
    BOOL didCopy = [[NSFileManager defaultManager]
        copyItemAtURL:[NSURL fileURLWithPath:draft.rawAudioFilePath]
        toURL:destinationURL
        error:&copyError];
    if (!didCopy) {
        [self assignError:error
                     code:TSAIAudioRecordDemoErrorCodeCopyAudioFailed
              description:copyError.localizedDescription ?: @"Failed to copy the AI recording audio file."];
        return NO;
    }

    draft.storedAudioRelativePath = [draft.recordIdentifier
        stringByAppendingPathComponent:audioFileName];
    return YES;
}

/// 将草稿元数据以原子方式写入 JSON 文件。
- (BOOL)writeMetadataForDraft:(TSAIAudioRecordDraft *)draft
           recordingDirectory:(NSURL *)recordingDirectory
                        error:(NSError **)error {
    NSError *serializationError = nil;
    NSData *metadataData = [NSJSONSerialization dataWithJSONObject:[draft dictionaryRepresentation]
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&serializationError];
    if (metadataData == nil) {
        [self assignError:error
                     code:TSAIAudioRecordDemoErrorCodeWriteMetadataFailed
              description:serializationError.localizedDescription ?: @"Failed to serialize recording metadata."];
        return NO;
    }

    NSURL *metadataURL = [recordingDirectory URLByAppendingPathComponent:@"metadata.json"];
    NSError *writeError = nil;
    BOOL didWrite = [metadataData writeToURL:metadataURL
                                     options:NSDataWritingAtomic
                                       error:&writeError];
    if (!didWrite) {
        [self assignError:error
                     code:TSAIAudioRecordDemoErrorCodeWriteMetadataFailed
              description:writeError.localizedDescription ?: @"Failed to write recording metadata."];
    }
    return didWrite;
}

/// 创建统一的 Demo 存储错误。
- (void)assignError:(NSError **)error
               code:(TSAIAudioRecordDemoErrorCode)code
        description:(NSString *)description {
    if (error == NULL) {
        return;
    }
    *error = [NSError errorWithDomain:TSAIAudioRecordDemoErrorDomain
                                 code:code
                             userInfo:@{NSLocalizedDescriptionKey: description}];
}

@end
