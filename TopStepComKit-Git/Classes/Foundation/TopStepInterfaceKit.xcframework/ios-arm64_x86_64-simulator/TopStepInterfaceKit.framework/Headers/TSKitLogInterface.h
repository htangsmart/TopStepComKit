//
//  TSKitLogInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2024/12/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TSKitLogInterface <NSObject>

- (void)setLogEnable:(BOOL)logEnable;

///**
// * 配置日志系统
// * @param enabled 是否启用日志
// * @param saveEnabled 是否保存日志
// * @param saveOnlyInDebug 是否仅在调试模式下保存
// * @param storageType 存储类型（控制台/文件/服务器）
// * @param encryption 是否启用加密
// * @param maxSize 单个日志文件最大大小(MB)
// * @param retentionDays 日志保留天数
// * @param directory 自定义日志存储目录路径（可选，传nil则使用默认路径）
// * @return BOOL 配置是否成功
// */
//- (BOOL)configureWithEnabled:(BOOL)enabled
//                saveEnabled:(BOOL)saveEnabled
//             saveOnlyDebug:(BOOL)saveOnlyInDebug
//              storageType:(TSLogStorageType)storageType
//               encryption:(BOOL)encryption
//                 maxSize:(NSUInteger)maxSize
//           retentionDays:(NSUInteger)days
//               directory:(nullable NSString *)directory;

/**
 * 快速配置（使用默认值）
 * @param saveEnabled 是否保存日志
 */
- (void)quickConfigureWithSaveEnabled:(BOOL)saveEnabled completion:(void(^)(BOOL successed))completion;


@end

NS_ASSUME_NONNULL_END
