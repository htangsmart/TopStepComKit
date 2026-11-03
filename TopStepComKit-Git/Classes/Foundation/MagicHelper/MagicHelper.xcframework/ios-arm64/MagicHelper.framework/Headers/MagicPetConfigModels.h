//
//  MagicPetConfigModels.h
//  MagicHelper
//
//  宠物配置接口 data 模型（App 端文档：`/service/memory/pet_config/...`）。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 接口「设置当前宠物的音色」响应 data：`SetVoiceResult`（文档另含 `deviceSn`，本模型当前仅映射 `voice`）。
@interface MagicPetSetVoiceResult : NSObject
/// 已设置的音色参数，如 `sitong`（服务端字段 `voice`）。
@property (nonatomic, copy) NSString *voice;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 接口「获取当前宠物已设置的音色」响应 data：`GetVoiceResult`（文档另含 `deviceSn`，本模型当前仅映射 `voice`）。
@interface MagicPetGetVoiceResult : NSObject
/// 当前设置的音色参数；未设置时服务端为 `null`（服务端字段 `voice`）。
@property (nonatomic, copy) NSString *voice;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 接口「支持的音色列表」单项：`VoiceInfo`（文档字段：`id`、`name`、`voice`、`sampleUrl`）。
@interface MagicPetVoiceInfo : NSObject
/// 音色参数，如 `sitong`（服务端字段 `voice`）。
@property (nonatomic, copy) NSString *voice;
/// 音色名称，如「思彤」（服务端字段 `name`）。
@property (nonatomic, copy) NSString *name;
/// 扩展描述；解析自 `desc` / `description`（与文档主字段对齐时可视为补充说明）。
@property (nonatomic, copy) NSString *voiceDesc;
/// 示例音频 URL（服务端字段 `sampleUrl`）。
@property (nonatomic, copy) NSString *sampleUrl;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 接口「设置当前宠物的性格」响应 data：`SetPersonalityResult`（文档另含 `deviceSn`，本模型当前仅映射 `personalityCode`）。
@interface MagicPetSetPersonalityResult : NSObject
/// 已设置的性格编码，如 `1010`（服务端字段 `personalityCode`）。
@property (nonatomic, copy) NSString *personalityCode;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 接口「获取当前宠物已设置的性格」响应 data：`GetPersonalityResult`（文档另含 `deviceSn`，本模型当前仅映射 `personalityCode`）。
@interface MagicPetGetPersonalityResult : NSObject
/// 当前性格编码；未设置时服务端为 `null`（服务端字段 `personalityCode`）。
@property (nonatomic, copy) NSString *personalityCode;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 接口「性格列表」单项：`PersonalityInfo`（文档字段：`id`、`name`、`code`、`personality`、`description`、`hobbies`、`birthday`）。
@interface MagicPetPersonalityInfo : NSObject
/// 性格编码，如 `1010`（文档为 `code`；解析兼容 `personalityCode`）。
@property (nonatomic, copy) NSString *personalityCode;
/// 性格名称，如「布丁」（服务端字段 `name`）。
@property (nonatomic, copy) NSString *name;
/// 性格描述等文案；解析自 `desc` / `description`（文档主字段为 `description`）。
@property (nonatomic, copy) NSString *personalityDesc;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;
@end

/// 接口「查询设备宠物完整配置」响应 data：`DevicePetConfig`；无配置时 `data` 为 `null`，`modelWithDictionary:` 返回 nil。
@interface MagicDevicePetConfig : NSObject
/// 当前音色参数；未设置时为 `null`（服务端字段 `voice`）。
@property (nonatomic, copy) NSString *voice;
/// 当前性格编码；未设置时为 `null`（服务端字段 `personalityCode`）。
@property (nonatomic, copy) NSString *personalityCode;
+ (nullable instancetype)modelWithDictionary:(nullable NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
