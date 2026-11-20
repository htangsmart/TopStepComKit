//
//  MagicSmartAgentUtil.h
//  MagicHelper
//
//  Created by ymz on 2026/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MagicSmartAgentModel : NSObject

/// 智能体code
@property (nonatomic, strong, nullable) NSString *llm_code;

/// 视觉智能体code
@property (nonatomic, strong, nullable) NSString *vllm_code;

/// 智能体名称
@property (nonatomic, strong) NSString *name;

@end

@interface MagicSmartAgentUtil : NSObject
 
/// 获取支持的智能体列表
/// 使用方式：将选中的智能体的llm_code，vllm_code在createsession时赋值给MagicSmartOptionModel
+ (NSArray<MagicSmartAgentModel *> *)getSupportAgents;

@end

NS_ASSUME_NONNULL_END
