//
//  TSAIBudsConfiguration.h
//  TopStepAIKit
//
//  Created by TopStep on 2026/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief AIBuds AI vendor type
 * @chinese AIBuds AI 厂商类型
 */
typedef NS_OPTIONS(NSUInteger, TSAIBudsVendorType) {
    /// No vendor (无厂商)
    TSAIBudsVendorTypeNone = 0,
    /// StarBurst vendor (火山厂商)
    TSAIBudsVendorTypeStarBurst = 1 << 0,
    /// MltCloud vendor (魔方厂商)
    TSAIBudsVendorTypeMltCloud = 1 << 1,
    /// All built-in vendors for internal Runtime registration (仅供 Runtime 内部注册的全部厂商)
    TSAIBudsVendorTypeAll = TSAIBudsVendorTypeStarBurst | TSAIBudsVendorTypeMltCloud,
};

/**
 * @brief AIBuds initialization configuration
 * @chinese AIBuds 初始化配置
 *
 * @discussion
 * [EN]: Carries vendor-neutral information needed before using AIBuds AI
 *       services. Secret values must be provided by the host application and
 *       must not be logged by this kit.
 * [CN]: 承载使用 AIBuds AI 服务前所需的厂商无关配置。密钥类数据由宿主 App
 *       提供，本库不得打印。
 */
@interface TSAIBudsConfiguration : NSObject <NSCopying>

/**
 * @brief StarBurst authentication SDK mode
 * @chinese StarBurst 鉴权模式
 *
 * @discussion
 * [EN]: Uses the vendor public values 1 through 5; no mode is inferred.
 * [CN]: 使用厂商公开的 1 至 5 枚举值，不根据设备名称推断。
 *
 * @note
 * [EN]: Defaults to nil; required with an explicit StarBurst product.
 * [CN]: 默认为 nil；显式配置 StarBurst 项目时必须提供。
 */
@property (nonatomic, copy, nullable) NSNumber *starBurstAuthSDK;

/**
 * @brief StarBurst authorization product identifier
 * @chinese StarBurst 授权项目标识
 *
 * @discussion
 * [EN]: Separate from the device firmware project number and chat prompt.
 * [CN]: 与设备固件项目号和对话 prompt 分离。
 *
 * @note
 * [EN]: Defaults to nil; explicit values must be nonempty.
 * [CN]: 默认为 nil；显式传入时不能为空。
 */
@property (nonatomic, copy, nullable) NSString *starBurstProductId;

/**
 * @brief StarBurst authorization environment
 * @chinese StarBurst 授权环境
 *
 * @discussion
 * [EN]: Forwarded to the vendor ppeEnv field without transformation.
 * [CN]: 原样传递给厂商 ppeEnv 字段。
 *
 * @note
 * [EN]: Defaults to nil; nil leaves the environment unspecified.
 * [CN]: 默认为 nil；nil 表示未指定环境。
 */
@property (nonatomic, copy, nullable) NSString *starBurstPPEEnvironment;

/**
 * @brief MltCloud authorization channel
 * @chinese MltCloud 授权渠道
 *
 * @discussion
 * [EN]: Forwarded to the vendor channelId field.
 * [CN]: 传递给厂商 channelId 字段。
 *
 * @note
 * [EN]: Defaults to nil; explicit values must be nonempty.
 * [CN]: 默认为 nil；显式传入时不能为空。
 */
@property (nonatomic, copy, nullable) NSString *mltCloudChannelId;

/**
 * @brief MltCloud staging environment selection
 * @chinese MltCloud 测试环境选择
 *
 * @discussion
 * [EN]: Controls the vendor isStaging field.
 * [CN]: 控制厂商 isStaging 字段。
 *
 * @note
 * [EN]: Defaults to NO.
 * [CN]: 默认为 NO。
 */
@property (nonatomic, assign) BOOL mltCloudStagingEnvironment;

/**
 * @brief Target AI vendor for this Context
 * @chinese 当前 Context 的目标 AI 厂商
 *
 * @discussion
 * [EN]: Specify exactly one vendor for a Context. The process-wide runtime
 *       registers every linked vendor once and routes this Context to the
 *       selected vendor.
 * [CN]: 每个 Context 只指定一个目标厂商。进程级 Runtime 会一次性注册
 *       所有已链接厂商，再将当前 Context 路由到这里指定的厂商。
 */
@property (nonatomic, assign) TSAIBudsVendorType preferredVendor;

/**
 * @brief Application identifier used by the AI backend
 * @chinese AI 后端使用的应用标识
 */
@property (nonatomic, copy, nullable) NSString *appId;

/**
 * @brief Application key used by the AI backend
 * @chinese AI 后端使用的应用 Key
 */
@property (nonatomic, copy, nullable) NSString *appKey;

/**
 * @brief Additional vendor-specific options
 * @chinese 额外的厂商自定义配置
 */
@property (nonatomic, copy) NSDictionary<NSString *, id> *vendorOptions;

/**
 * @brief Create an AIBuds configuration for one target vendor
 * @chinese 通过单个目标厂商创建 AIBuds 配置
 *
 * @param preferredVendor
 * EN: Target AI vendor
 * CN: 目标 AI 厂商
 *
 * @return
 * EN: A new AIBuds configuration instance
 * CN: 新创建的 AIBuds 配置对象
 */
+ (instancetype)configurationWithPreferredVendor:(TSAIBudsVendorType)preferredVendor;

@end

NS_ASSUME_NONNULL_END
