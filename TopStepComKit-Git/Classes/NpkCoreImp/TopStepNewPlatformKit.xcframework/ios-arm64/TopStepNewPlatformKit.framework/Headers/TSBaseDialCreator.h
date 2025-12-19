//
//  TSBaseDialCreator.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/12/4.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import "TSCustomDial+Npk.h"
#import "TSNpkFilePath.h"

static NSString * _Nullable kSingleTemplateName = @"base";
static NSString * _Nullable kMultipleTemplateName = @"mult";
static NSString * _Nullable kVideoTemplateName = @"video";

static NSString *_Nullable kTemplateBinName = @"res.bin";
static NSString *_Nullable kTemplateConfigName = @"config.json";
static NSString *_Nullable kTemplateScreenName = @"screen.json";


NS_ASSUME_NONNULL_BEGIN

@interface TSBaseDialCreator : NSObject

+ (void)createCustomDial:(TSCustomDial *)dial completion:(void(^)(BOOL isSuccess, NSString *_Nullable createResultFilePath, NSError * _Nullable error))completion;

+ (void)replaceBinFileWithDial:(TSCustomDial *)dial fileFolderPath:(NSString *)fileFolderPath completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

+ (void)modifyConfigFileWithDial:(TSCustomDial *)dial fileFolderPath:(NSString *)fileFolderPath completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

+ (void)modifyScreenFileWithDial:(TSCustomDial *)dial fileFolderPath:(NSString *)fileFolderPath completion:(void (^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Get the template file name that needs to be decompressed
 * @chinese 获取需要解压的模板文件名
 *
 * @return
 * EN: Template file name (without extension), e.g., "base", "mult", "video". Returns nil if no template file needs to be decompressed.
 * CN: 模板文件名（不含扩展名），例如 "base"、"mult"、"video"。如果不需要解压模板文件则返回nil。
 *
 * @discussion
 * [EN]: Subclasses should override this method to return the specific template file name they need.
 *       For example:
 *       - TSSingleImageDialCreator returns "base"
 *       - TSMultipleImagesDialCreator returns "mult"
 *       - TSVideoDialCreator returns "video"
 * [CN]: 子类应重写此方法以返回它们需要的特定模板文件名。
 *       例如：
 *       - TSSingleImageDialCreator 返回 "base"
 *       - TSMultipleImagesDialCreator 返回 "mult"
 *       - TSVideoDialCreator 返回 "video"
 */
+ (nullable NSString *)templateSubFileName;


@end

NS_ASSUME_NONNULL_END
