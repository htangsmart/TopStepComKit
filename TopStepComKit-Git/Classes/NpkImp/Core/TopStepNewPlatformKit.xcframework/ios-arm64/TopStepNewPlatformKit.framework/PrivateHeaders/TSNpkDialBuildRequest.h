//
//  TSNpkDialBuildRequest.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSNpkDialDeviceProfile;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Immutable input of one dial package build
 * @chinese 一次造包的不可变输入
 */
@interface TSNpkDialBuildRequest : NSObject

@property (nonatomic, strong, readonly) TSDialDraft *draft;
@property (nonatomic, copy, readonly) NSString *dialId;
@property (nonatomic, strong, readonly) TSNpkDialDeviceProfile *deviceProfile;
/** @brief Downloaded template zip @chinese 已下载的模板 zip */
@property (nonatomic, copy, readonly) NSString *templateArchivePath;
/** @brief Where the template zip is unpacked @chinese 模板 zip 的解压目录 */
@property (nonatomic, copy, readonly) NSString *templateDirectory;
/** @brief Dial content directory holding res.bin, config.json, screen.json @chinese 表盘内容目录，内含 res.bin、config.json、screen.json */
@property (nonatomic, copy, readonly) NSString *contentDirectory;
/** @brief Output tar path @chinese 输出的 tar 包路径 */
@property (nonatomic, copy, readonly) NSString *packageFilePath;

@property (nonatomic, copy, readonly) NSString *binFilePath;
@property (nonatomic, copy, readonly) NSString *screenFilePath;
@property (nonatomic, copy, readonly) NSString *configFilePath;

/** @brief YES when any item sets a time color @chinese 是否有草稿项设置了时间颜色 */
@property (nonatomic, assign, readonly) BOOL hasColorTint;

- (instancetype)initWithDraft:(TSDialDraft *)draft
                       dialId:(NSString *)dialId
                deviceProfile:(TSNpkDialDeviceProfile *)deviceProfile
            templateDirectory:(NSString *)templateDirectory
             contentDirectory:(NSString *)contentDirectory
              packageFilePath:(NSString *)packageFilePath NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
