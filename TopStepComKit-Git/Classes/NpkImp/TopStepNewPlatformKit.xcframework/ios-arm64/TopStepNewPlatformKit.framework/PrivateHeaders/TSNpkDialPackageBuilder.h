//
//  TSNpkDialPackageBuilder.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Builds an NPK custom dial package by running the V2 stages in order
 * @chinese 按顺序执行 V2 各阶段，生成 NPK 自定义表盘包
 *
 * @discussion
 * [EN]: Stages: Template, Video, Preview, ResPlan, ResBin, Screen, Config, Archive. The first failing stage stops
 *       the build. Scratch directories are removed when the build ends, whatever the outcome.
 * [CN]: 阶段依次为：Template、Video、Preview、ResPlan、ResBin、Screen、Config、Archive。任一阶段失败即停止。
 *       无论成功失败，结束时都会清理临时目录。
 */
@interface TSNpkDialPackageBuilder : NSObject

/**
 * @brief Build a dial package
 * @chinese 生成表盘包
 *
 * @param draft EN: Validated draft with a resolved template file. CN: 已校验且已解析出模板文件的草稿。
 * @param completion EN: Package path on success. May be called on any queue. CN: 成功时返回包路径；回调所在队列不限。
 */
+ (void)buildPackageWithDraft:(TSDialDraft *)draft
                   completion:(void (^)(BOOL isSuccess,
                                        NSString *_Nullable packageFilePath,
                                        NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
