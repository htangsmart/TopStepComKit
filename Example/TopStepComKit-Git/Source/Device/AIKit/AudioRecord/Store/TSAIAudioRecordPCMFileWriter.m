//
//  TSAIAudioRecordPCMFileWriter.m
//  TopStepComKit-Git_Example
//

#import "TSAIAudioRecordPCMFileWriter.h"

static const uint32_t kTSAIAudioRecordPCMSampleRate = 16000;
static const uint16_t kTSAIAudioRecordPCMChannelCount = 1;
static const uint16_t kTSAIAudioRecordPCMBitDepth = 16;
static const NSUInteger kTSAIAudioRecordWAVHeaderLength = 44;

static void TSAIAppendUInt16LittleEndian(NSMutableData *data, uint16_t value) {
    uint8_t bytes[] = {(uint8_t)(value & 0xff), (uint8_t)((value >> 8) & 0xff)};
    [data appendBytes:bytes length:sizeof(bytes)];
}

static void TSAIAppendUInt32LittleEndian(NSMutableData *data, uint32_t value) {
    uint8_t bytes[] = {
        (uint8_t)(value & 0xff),
        (uint8_t)((value >> 8) & 0xff),
        (uint8_t)((value >> 16) & 0xff),
        (uint8_t)((value >> 24) & 0xff),
    };
    [data appendBytes:bytes length:sizeof(bytes)];
}

@interface TSAIAudioRecordPCMFileWriter ()

@property (nonatomic, strong) NSURL *temporaryFileURL;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@property (nonatomic, strong) dispatch_queue_t writingQueue;
@property (nonatomic, assign) uint64_t dataByteCount;
@property (nonatomic, assign) BOOL didFinishWriting;

@end


@implementation TSAIAudioRecordPCMFileWriter

#pragma mark - 生命周期

/** 创建临时 WAV 并预留文件头 */
- (instancetype)initWithRecordIdentifier:(NSString *)recordIdentifier {
    self = [super init];
    if (self) {
        NSString *directoryPath = [NSTemporaryDirectory()
            stringByAppendingPathComponent:@"TopStepComKitExample/AIAudioRecordPCM"];
        BOOL didCreateDirectory = [[NSFileManager defaultManager]
            createDirectoryAtPath:directoryPath
            withIntermediateDirectories:YES
            attributes:nil
            error:nil];
        if (!didCreateDirectory) {
            return nil;
        }
        NSString *fileName = [NSString stringWithFormat:@"%@-%@.wav",
                              recordIdentifier.length > 0 ? recordIdentifier : @"recording",
                              NSUUID.UUID.UUIDString];
        _temporaryFileURL = [NSURL fileURLWithPath:
            [directoryPath stringByAppendingPathComponent:fileName]];
        NSMutableData *emptyHeader = [NSMutableData dataWithLength:kTSAIAudioRecordWAVHeaderLength];
        if (![emptyHeader writeToURL:_temporaryFileURL atomically:YES]) {
            return nil;
        }
        _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_temporaryFileURL.path];
        if (!_fileHandle) {
            return nil;
        }
        [_fileHandle seekToEndOfFile];
        _writingQueue = dispatch_queue_create("com.topstep.example.ai-audio-record.pcm-writer",
                                              DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

/** 确保文件句柄被关闭 */
- (void)dealloc {
    [self.fileHandle closeFile];
}

#pragma mark - 公开方法

/** 在串行队列追加偶数字节的 Int16 PCM */
- (void)appendPCMData:(NSData *)pcmData {
    NSUInteger writableLength = pcmData.length - pcmData.length % sizeof(int16_t);
    if (writableLength == 0) {
        return;
    }
    NSData *writableData = writableLength == pcmData.length
        ? [pcmData copy]
        : [pcmData subdataWithRange:NSMakeRange(0, writableLength)];
    dispatch_async(self.writingQueue, ^{
        if (self.didFinishWriting) {
            return;
        }
        [self.fileHandle writeData:writableData];
        self.dataByteCount += writableData.length;
    });
}

/** 写回 WAV 文件头并关闭文件 */
- (NSURL *)finishWriting {
    __block NSURL *resultURL = nil;
    dispatch_sync(self.writingQueue, ^{
        if (!self.didFinishWriting) {
            self.didFinishWriting = YES;
            if (self.dataByteCount > 0 && self.dataByteCount <= UINT32_MAX) {
                [self.fileHandle seekToFileOffset:0];
                [self.fileHandle writeData:[self wavHeaderWithDataLength:(uint32_t)self.dataByteCount]];
                [self.fileHandle synchronizeFile];
                resultURL = self.temporaryFileURL;
            }
            [self.fileHandle closeFile];
            self.fileHandle = nil;
        } else if (self.dataByteCount > 0 && self.dataByteCount <= UINT32_MAX) {
            resultURL = self.temporaryFileURL;
        }
    });
    return resultURL;
}

/** 删除已完成复制的临时 WAV */
- (void)removeTemporaryFile {
    dispatch_async(self.writingQueue, ^{
        [self.fileHandle closeFile];
        self.fileHandle = nil;
        [[NSFileManager defaultManager] removeItemAtURL:self.temporaryFileURL error:nil];
    });
}

#pragma mark - 私有方法

/** 创建标准 44 字节 PCM WAV 文件头 */
- (NSData *)wavHeaderWithDataLength:(uint32_t)dataLength {
    uint16_t blockAlign = kTSAIAudioRecordPCMChannelCount * kTSAIAudioRecordPCMBitDepth / 8;
    uint32_t byteRate = kTSAIAudioRecordPCMSampleRate * blockAlign;
    NSMutableData *header = [NSMutableData dataWithCapacity:kTSAIAudioRecordWAVHeaderLength];
    [header appendBytes:"RIFF" length:4];
    TSAIAppendUInt32LittleEndian(header, 36 + dataLength);
    [header appendBytes:"WAVEfmt " length:8];
    TSAIAppendUInt32LittleEndian(header, 16);
    TSAIAppendUInt16LittleEndian(header, 1);
    TSAIAppendUInt16LittleEndian(header, kTSAIAudioRecordPCMChannelCount);
    TSAIAppendUInt32LittleEndian(header, kTSAIAudioRecordPCMSampleRate);
    TSAIAppendUInt32LittleEndian(header, byteRate);
    TSAIAppendUInt16LittleEndian(header, blockAlign);
    TSAIAppendUInt16LittleEndian(header, kTSAIAudioRecordPCMBitDepth);
    [header appendBytes:"data" length:4];
    TSAIAppendUInt32LittleEndian(header, dataLength);
    return header;
}

@end
