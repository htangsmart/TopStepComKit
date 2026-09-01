//
//  TSWorkoutCloudService.m
//  TopStepComKit_Example
//

#import "TSWorkoutCloudService.h"

#import <TopStepToolKit/TopStepToolKit.h>

static NSString *const kTSWorkoutCloudListURL = @"https://fitcloud.hetangsmart.com/public/sportbin/list";
static NSString *const kTSWorkoutCloudErrorDomain = @"com.topstep.example.workoutCloud";
// 云端运动接口所需的硬件信息占位值，接入真实参数后替换此常量
static NSString *const kTSWorkoutCloudHardwareInfo =
    @"0000000000000000000000000000000000000000000000000000000000000000000000000000";

@implementation TSWorkoutCloudResource
@end

@interface TSWorkoutCloudService ()

@property (nonatomic, strong, nullable) NSURLSessionTask *activeTask;

@end


@implementation TSWorkoutCloudService

#pragma mark - 公开方法

/** 请求当前 FitCloud 设备可用的云端运动 */
- (void)fetchResources:(TSWorkoutCloudListCompletion)completion {
    NSError *parameterError = nil;
    NSString *hardwareInfo = [self hardwareInfoWithError:&parameterError];
    if (!hardwareInfo) {
        [self callListCompletion:completion resources:nil error:parameterError];
        return;
    }
    NSString *boundary = [NSString stringWithFormat:@"TSWorkout-%@", NSUUID.UUID.UUIDString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kTSWorkoutCloudListURL]];
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]
   forHTTPHeaderField:@"Content-Type"];
    NSString *bodyText = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"hardwareInfo\"\r\n\r\n%@\r\n--%@--\r\n",
                          boundary, hardwareInfo, boundary];
    request.HTTPBody = [bodyText dataUsingEncoding:NSUTF8StringEncoding];
    __weak typeof(self) weakSelf = self;
    self.activeTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data,
                                                                         NSURLResponse *response,
                                                                         NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.activeTask = nil;
        if (error) {
            [strongSelf callListCompletion:completion resources:nil error:error];
            return;
        }
        NSError *parseError = nil;
        NSArray *resources = [strongSelf resourcesFromData:data error:&parseError];
        [strongSelf callListCompletion:completion resources:resources error:parseError];
    }];
    [self.activeTask resume];
}

/** 下载云端运动 bin 到 Example 缓存目录 */
- (void)downloadResource:(TSWorkoutCloudResource *)resource
              completion:(TSWorkoutCloudDownloadCompletion)completion {
    if (!resource.binURL) {
        [self callDownloadCompletion:completion localURL:nil error:[self errorWithMessage:@"运动资源地址无效"]];
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.activeTask = [[NSURLSession sharedSession] downloadTaskWithURL:resource.binURL
                                                     completionHandler:^(NSURL *location,
                                                                         NSURLResponse *response,
                                                                         NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.activeTask = nil;
        if (error) {
            [strongSelf callDownloadCompletion:completion localURL:nil error:error];
            return;
        }
        NSURL *localURL = [strongSelf persistDownloadedFileAtURL:location resource:resource error:&error];
        [strongSelf callDownloadCompletion:completion localURL:localURL error:error];
    }];
    [self.activeTask resume];
}

/** 取消 Example 业务层下载 */
- (void)cancelDownload {
    [self.activeTask cancel];
    self.activeTask = nil;
}

#pragma mark - 私有方法

/** 返回服务端所需的固定硬件信息 */
- (nullable NSString *)hardwareInfoWithError:(NSError **)error {
    return kTSWorkoutCloudHardwareInfo;
}

/** 解析云端资源列表 */
- (nullable NSArray<TSWorkoutCloudResource *> *)resourcesFromData:(NSData *)data error:(NSError **)error {
    NSDictionary *json = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:error] : nil;
    if (![json isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if ([json[@"errorCode"] integerValue] != 0) {
        if (error) {
            *error = [self errorWithMessage:json[@"errorMsg"] ?: @"云端运动加载失败"];
        }
        return nil;
    }
    NSArray *items = [json[@"data"] isKindOfClass:[NSArray class]] ? json[@"data"] : @[];
    NSMutableArray *resources = [NSMutableArray arrayWithCapacity:items.count];
    BOOL isChinese = [[[NSLocale preferredLanguages] firstObject] hasPrefix:@"zh"];
    for (NSDictionary *item in items) {
        NSURL *binURL = [NSURL URLWithString:item[@"binUrl"] ?: @""];
        if (!binURL) {
            continue;
        }
        TSWorkoutCloudResource *resource = [[TSWorkoutCloudResource alloc] init];
        resource.sportType = [item[@"sportUiType"] integerValue];
        resource.name = isChinese ? (item[@"sportUiNameCn"] ?: item[@"sportUiName"]) : item[@"sportUiName"];
        resource.name = resource.name.length > 0 ? resource.name : @"Workout";
        resource.iconURL = [NSURL URLWithString:item[@"iconUrl"] ?: @""];
        resource.binURL = binURL;
        resource.binSize = [item[@"binSize"] unsignedIntegerValue];
        [resources addObject:resource];
    }
    return [resources copy];
}

/** 保存下载结果 */
- (nullable NSURL *)persistDownloadedFileAtURL:(NSURL *)location
                                      resource:(TSWorkoutCloudResource *)resource
                                         error:(NSError **)error {
    NSURL *directory = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory
                                                               inDomains:NSUserDomainMask] firstObject];
    directory = [directory URLByAppendingPathComponent:@"WorkoutPushDemo" isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directory
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:error];
    if (error && *error) {
        return nil;
    }
    NSString *fileName = resource.binURL.lastPathComponent.length > 0 ? resource.binURL.lastPathComponent : @"workout.bin";
    NSURL *destination = [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", NSUUID.UUID.UUIDString, fileName]];
    if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:destination error:error]) {
        return nil;
    }
    return destination;
}

/** 创建 Demo 云端错误 */
- (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:kTSWorkoutCloudErrorDomain
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

/** 在主线程回调列表 */
- (void)callListCompletion:(TSWorkoutCloudListCompletion)completion
                  resources:(nullable NSArray<TSWorkoutCloudResource *> *)resources
                      error:(nullable NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{ completion(resources, error); });
}

/** 在主线程回调下载结果 */
- (void)callDownloadCompletion:(TSWorkoutCloudDownloadCompletion)completion
                       localURL:(nullable NSURL *)localURL
                          error:(nullable NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{ completion(localURL, error); });
}

@end
