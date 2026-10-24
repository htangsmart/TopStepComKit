//
//  TSNpkDialBuildRouter.h
//  TopStepNewPlatformKit
//
//  Created on 2026/9/21.
//

#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TSNpkDialBuildContext, TSNpkDialStyleResource;

/** @brief Which dial building implementation runs @chinese 使用哪一套造包实现 */
typedef NS_ENUM(NSInteger, TSNpkDialBuildEngine) {
    /** @brief Original in-place res.bin editing (TSDialCreator) @chinese 原有的原地改写 res.bin 的实现（TSDialCreator） */
    TSNpkDialBuildEngineLegacy = 0,
    /** @brief Rebuild pipeline (TSNpkDialPackageBuilder) @chinese 重建 res.bin 的流水线实现（TSNpkDialPackageBuilder） */
    TSNpkDialBuildEngineV2 = 1,
};

/**
 * @brief Routes captured build inputs to the LVGL or GUI package system.
 * @chinese 将已捕获的构建输入分派到 LVGL 或 GUI 造包体系。
 *
 * @discussion
 * [EN]: GUI never enters the JSON/TAR stages. The legacy private draft entry retains its engine switch.
 * [CN]: GUI 不进入 JSON/TAR 阶段；旧私有草稿入口保留引擎开关，失败不自动回退。
 */
@interface TSNpkDialBuildRouter : NSObject

/**
 * @brief Engine selected by the legacy draft entry
 * @chinese 旧草稿入口选用的造包引擎
 *
 * @discussion
 * [EN]: Process-wide switch, defaulting to V2. Only createCustomDial:completion: reads it; context routing uses the platform.
 * [CN]: 进程级开关，默认 V2；仅 createCustomDial:completion: 读取，基于上下文的分派按设备平台决定。
 */
@property (class, nonatomic, assign) TSNpkDialBuildEngine engine;

/** @brief Build using captured input and a typed template result. @chinese 使用快照与明确模板结果造包。
 * @param context EN: Task input. CN: 任务输入。
 * @param resource EN: Resolved template. CN: 模板结果。
 * @param completion EN: Unpublished artifact or error. CN: 未发布产物或错误。
 */
+ (void)buildWithContext:(TSNpkDialBuildContext *)context templateResource:(TSNpkDialStyleResource *)resource
             completion:(void (^)(TSDialArtifact *_Nullable artifact, NSError *_Nullable error))completion;

/**
 * @brief Build a custom dial package with the selected engine
 * @chinese 用选定的实现生成自定义表盘包
 */
+ (void)createCustomDial:(TSDialDraft *)draft
              completion:(void (^)(BOOL isSuccess,
                                   NSString *_Nullable resultFilePath,
                                   NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
