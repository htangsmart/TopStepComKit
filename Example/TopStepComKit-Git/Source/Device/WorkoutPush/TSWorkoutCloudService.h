//
//  TSWorkoutCloudService.h
//  TopStepComKit_Example
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Cloud workout resource used only by the Example application
 * @chinese 仅供 Example 应用使用的云端运动资源
 */
@interface TSWorkoutCloudResource : NSObject

@property (nonatomic, assign) NSInteger sportType;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong, nullable) NSURL *iconURL;
@property (nonatomic, strong) NSURL *binURL;
@property (nonatomic, assign) NSUInteger binSize;

@end

typedef void (^TSWorkoutCloudListCompletion)(NSArray<TSWorkoutCloudResource *> * _Nullable resources,
                                              NSError * _Nullable error);
typedef void (^TSWorkoutCloudDownloadCompletion)(NSURL * _Nullable localURL,
                                                  NSError * _Nullable error);

/**
 * @brief Demo business service for cloud workout list and file download
 * @chinese Demo 业务层的云端运动列表与文件下载服务
 *
 * @discussion
 * EN: This service is not part of TopStepComKit. It converts the connected
 * FitCloud device information into the server request parameter and downloads
 * the selected binary before the SDK installation API is called.
 * CN: 本服务不属于 TopStepComKit。它将已连接 FitCloud 设备信息转换为服务端参数，
 * 并在调用 SDK 安装接口前下载选中的二进制文件。
 */
@interface TSWorkoutCloudService : NSObject

- (void)fetchResources:(TSWorkoutCloudListCompletion)completion;
- (void)downloadResource:(TSWorkoutCloudResource *)resource
              completion:(TSWorkoutCloudDownloadCompletion)completion;
- (void)cancelDownload;

@end


NS_ASSUME_NONNULL_END
