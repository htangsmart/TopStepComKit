//
//  TSDialArtifact.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/7/19.
//
//  文件说明:
//  表盘可安装产物。由自定义造包或云端下载生成，是"产出"与"安装"之间
//  的传递物，包含表盘类型、表盘 id 和表盘包路径。

#import "TSKitBaseModel.h"
#import "TSDialDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Installable watch face artifact
 * @chinese 表盘可安装产物
 *
 * @discussion
 * [EN]: Output of custom build or cloud download. It carries the watch face type,
 *       generated watch face id and package path. The underlying container format is
 *       not exposed; filePath is an opaque local handle.
 * [CN]: 自定义造包或云端下载的输出。承载表盘类型、生成后的表盘 id 和表盘包路径。
 *       底层容器格式不外泄，filePath 仅为不透明的本地句柄。
 */
@interface TSDialArtifact : TSKitBaseModel

/**
 * @brief Watch face id (opaque)
 * @chinese 表盘 id（不透明）
 */
@property (nonatomic, copy, readonly) NSString *dialId;

/**
 * @brief Dial type
 * @chinese 表盘类型
 *
 * @discussion
 * [EN]: The installable artifact source type. It must be custom or cloud.
 * [CN]: 当前可安装产物的来源表盘类型，必须是自定义或云端。
 */
@property (nonatomic, assign, readonly) TSDialType dialType;

/**
 * @brief Built package local file path (opaque handle for install)
 * @chinese 已造包的本地文件路径（安装用不透明句柄）
 */
@property (nonatomic, copy, readonly) NSString *filePath;

/**
 * @brief Designated initializer
 * @chinese 指定初始化方法
 *
 * @param dialType
 * EN: Artifact dial type, custom or cloud.
 * CN: 产物表盘类型，自定义或云端。
 *
 * @param dialId
 * EN: Watch face id.
 * CN: 表盘 id。
 *
 * @param filePath
 * EN: Built package local file path.
 * CN: 已造包的本地文件路径。
 *
 * @return
 * EN: Initialized artifact.
 * CN: 初始化完成的产物。
 */
- (instancetype)initWithDialType:(TSDialType)dialType
                          dialId:(NSString *)dialId
                         filePath:(NSString *)filePath NS_DESIGNATED_INITIALIZER;

/**
 * @brief Disable default init method
 * @chinese 禁用默认初始化方法
 */
- (instancetype)init NS_UNAVAILABLE;

/**
 * @brief Disable new method
 * @chinese 禁用 new 方法
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 * @brief Create a custom watch face artifact
 * @chinese 创建自定义表盘产物
 *
 * @param dialId
 * EN: Watch face id.
 * CN: 表盘 id。
 *
 * @param filePath
 * EN: Built package local file path.
 * CN: 已造包的本地文件路径。
 *
 * @return
 * EN: Initialized custom artifact.
 * CN: 初始化完成的自定义表盘产物。
 */
- (instancetype)initWithDialId:(NSString *)dialId
                      filePath:(NSString *)filePath;

/**
 * @brief Convenience constructor with dial type
 * @chinese 带表盘类型的便利构造方法
 *
 * @param dialType
 * EN: Artifact dial type, custom or cloud.
 * CN: 产物表盘类型，自定义或云端。
 *
 * @param dialId
 * EN: Watch face id.
 * CN: 表盘 id。
 *
 * @param filePath
 * EN: Built package local file path.
 * CN: 已造包的本地文件路径。
 *
 * @return
 * EN: Initialized artifact.
 * CN: 初始化完成的产物。
 */
+ (instancetype)artifactWithDialType:(TSDialType)dialType
                              dialId:(NSString *)dialId
                            filePath:(NSString *)filePath;

/**
 * @brief Convenience constructor for custom watch face artifact
 * @chinese 自定义表盘产物便利构造方法
 *
 * @param dialId
 * EN: Watch face id.
 * CN: 表盘 id。
 *
 * @param filePath
 * EN: Built package local file path.
 * CN: 已造包的本地文件路径。
 *
 * @return
 * EN: Initialized custom artifact.
 * CN: 初始化完成的自定义表盘产物。
 */
+ (instancetype)artifactWithDialId:(NSString *)dialId
                          filePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
