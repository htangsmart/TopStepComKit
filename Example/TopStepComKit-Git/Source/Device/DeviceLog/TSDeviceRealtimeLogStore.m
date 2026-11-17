#import "TSDeviceRealtimeLogStore.h"
#import <stdlib.h>
#import <TopStepToolKit/TSFileStreamWriter.h>
#import <TopStepToolKit/TSLogPrinter.h>

static const unsigned long long TSDeviceRealtimeLogFileLimit = 2 * 1024 * 1024;
static const unsigned long long TSDeviceRealtimeLogHistoryLimit = 20 * 1024 * 1024;
static NSString *const TSDeviceRealtimeLogStoreErrorDomain = @"TSDeviceRealtimeLogStoreErrorDomain";

@interface TSDeviceRealtimeLogStore ()
@property (nonatomic, strong) TSFileStreamWriter *writer;
@property (nonatomic, strong) NSURL *activeFile;
@property (nonatomic, strong) NSUUID *recordingIdentifier;
@end

@implementation TSDeviceRealtimeLogStore

#pragma mark - 公开方法

// 共享打开文件的归属，避免另一个页面分享仍在写的文件。
+ (instancetype)sharedStore {
    static TSDeviceRealtimeLogStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ store = [[self alloc] init]; });
    return store;
}

// 在首包时创建文件，轮转时保持包完整。
- (BOOL)appendData:(NSData *)data
  deviceIdentifier:(NSString *)deviceIdentifier
         recording:(NSUUID *)recordingIdentifier
       createdFile:(BOOL *)createdFile
             error:(NSError **)error {
    if (createdFile) *createdFile = NO;
    if (data.length == 0) return YES;
    @synchronized (self) {
        if (self.recordingIdentifier && ![self.recordingIdentifier isEqual:recordingIdentifier]) {
            return [self failWithCode:1 error:error];
        }

        NSUUID *deviceUUID = [[NSUUID alloc] initWithUUIDString:deviceIdentifier];
        NSURL *directory = [[self rootDirectory] URLByAppendingPathComponent:deviceUUID.UUIDString ?: @"" isDirectory:YES];
        if (!deviceUUID || !directory) return [self failWithCode:1 error:error];

        if (self.activeFile && [self.writer currentOffset] + data.length > TSDeviceRealtimeLogFileLimit) {
            [self closeRecording:recordingIdentifier];
        }
        BOOL needsFile = self.activeFile == nil;
        if (needsFile) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:error]) {
                return NO;
            }

            NSArray<NSURL *> *history = [self filesInDirectory:directory];
            NSURL *file = [self nextFileInDirectory:directory newestFile:history.lastObject];
            TSFileStreamWriter *writer = [[TSFileStreamWriter alloc] init];
            if (![writer openForWriting:file.path]) {
                [fileManager removeItemAtURL:file error:nil];
                return [self failWithCode:2 error:error];
            }
            self.writer = writer;
            self.activeFile = file;
            self.recordingIdentifier = recordingIdentifier;
            [self trimHistory:history];
        }

        if (![self.writer writeData:data]) {
            return [self failWithCode:3 error:error];
        }
        if (needsFile) {
            TSLogInfo(@"[RealtimeLog][File] first_write recording=%@ file=%@ bytes=%lu",
                      recordingIdentifier.UUIDString, self.activeFile.lastPathComponent, (unsigned long)data.length);
        }
        if (createdFile) *createdFile = needsFile;
        return YES;
    }
}

// 终态先关闭文件，再由页面刷新已关闭文件列表。
- (void)closeRecording:(NSUUID *)recordingIdentifier {
    @synchronized (self) {
        if (![self.recordingIdentifier isEqual:recordingIdentifier]) return;
        NSURL *file = self.activeFile;
        unsigned long long written = [self.writer currentOffset];
        [self.writer close];
        NSError *error = nil;
        NSDictionary<NSFileAttributeKey, id> *attributes = [[NSFileManager defaultManager]
            attributesOfItemAtPath:file.path error:&error];
        NSNumber *size = attributes[NSFileSize];
        if (size && size.unsignedLongLongValue == written) {
            TSLogInfo(@"[RealtimeLog][File] finalized recording=%@ file=%@ result=size_matched bytes=%llu",
                      recordingIdentifier.UUIDString, file.lastPathComponent, written);
        } else {
            TSLogWarning(@"[RealtimeLog][File] finalized recording=%@ file=%@ result=%@ expected_bytes=%llu "
                         @"actual_bytes=%@ error=%@/%ld",
                         recordingIdentifier.UUIDString, file.lastPathComponent,
                         size ? @"size_mismatch" : @"metadata_failed", written, size ?: @"unknown",
                         error.domain ?: @"none", (long)error.code);
        }
        self.writer = nil;
        self.activeFile = nil;
        self.recordingIdentifier = nil;
    }
}

// 打开中的文件不会出现在分享列表。
- (NSArray<NSURL *> *)closedFiles {
    @synchronized (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *root = [self rootDirectory];
        if (!root) return @[];
        NSArray<NSURL *> *directories = [fileManager contentsOfDirectoryAtURL:root
                                                 includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                      error:nil];
        NSMutableArray<NSURL *> *files = [NSMutableArray array];
        for (NSURL *directory in directories) {
            if (![[NSUUID alloc] initWithUUIDString:directory.lastPathComponent]) continue;
            [files addObjectsFromArray:[self filesInDirectory:directory]];
        }
        if (self.activeFile) [files removeObject:self.activeFile];
        return [files sortedArrayUsingComparator:^NSComparisonResult(NSURL *left, NSURL *right) {
            NSComparisonResult order = [right.lastPathComponent compare:left.lastPathComponent];
            return order == NSOrderedSame ? [left.path compare:right.path] : order;
        }];
    }
}

#pragma mark - 私有方法

// 设备日志放在应用支持目录中。
- (NSURL *)rootDirectory {
    NSURL *support = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                           inDomains:NSUserDomainMask].firstObject;
    return [support URLByAppendingPathComponent:@"DeviceRealtimeLogs" isDirectory:YES];
}

// 同设备的文件按 UTC 时间和递增序号排序。
- (NSArray<NSURL *> *)filesInDirectory:(NSURL *)directory {
    NSArray<NSURL *> *entries = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directory
                                                              includingPropertiesForKeys:@[NSURLIsRegularFileKey, NSURLFileSizeKey]
                                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                   error:nil];
    NSMutableArray<NSURL *> *files = [NSMutableArray array];
    for (NSURL *entry in entries) {
        NSNumber *isFile = nil;
        [entry getResourceValue:&isFile forKey:NSURLIsRegularFileKey error:nil];
        if (isFile.boolValue && [entry.pathExtension isEqualToString:@"log"]) [files addObject:entry];
    }
    return [files sortedArrayUsingComparator:^NSComparisonResult(NSURL *left, NSURL *right) {
        return [left.lastPathComponent compare:right.lastPathComponent];
    }];
}

// 时间相等或回拨时沿用最近时间，递增后缀。
- (NSURL *)nextFileInDirectory:(NSURL *)directory newestFile:(NSURL *)newestFile {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    formatter.dateFormat = @"yyyyMMdd_HHmmss_SSS";
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    NSArray<NSString *> *parts = [[newestFile.lastPathComponent stringByDeletingPathExtension] componentsSeparatedByString:@"-"];
    unsigned long long sequence = 0;
    if (parts.count == 2 && [timestamp compare:parts.firstObject] != NSOrderedDescending) {
        timestamp = parts.firstObject;
        sequence = strtoull(parts.lastObject.UTF8String, NULL, 10) + 1;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *file = nil;
    do {
        NSString *fileName = [NSString stringWithFormat:@"%@-%020llu.log", timestamp, sequence++];
        file = [directory URLByAppendingPathComponent:fileName isDirectory:NO];
    } while ([fileManager fileExistsAtPath:file.path]);
    return file;
}

// 只删除本设备历史文件，优先保留较新的内容。
- (void)trimHistory:(NSArray<NSURL *> *)history {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableDictionary<NSURL *, NSNumber *> *sizes = [NSMutableDictionary dictionary];
    unsigned long long totalBytes = 0;
    for (NSURL *file in history) {
        NSNumber *size = nil;
        if ([file getResourceValue:&size forKey:NSURLFileSizeKey error:nil] && size) {
            sizes[file] = size;
            totalBytes += size.unsignedLongLongValue;
        }
    }
    for (NSURL *file in history) {
        if (totalBytes <= TSDeviceRealtimeLogHistoryLimit) break;
        if ([fileManager removeItemAtURL:file error:nil]) totalBytes -= sizes[file].unsignedLongLongValue;
    }
}

// 流写入器用布尔值返回失败，转换成页面可显示的错误。
- (BOOL)failWithCode:(NSInteger)code error:(NSError **)error {
    if (error) {
        *error = [NSError errorWithDomain:TSDeviceRealtimeLogStoreErrorDomain code:code
                                userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"device_realtime_log.file_error", nil)}];
    }
    return NO;
}

@end
