//
//  TranslationImageBodyV2.h
//  MagicHelper
//
//  Created by ymz on 2026/5/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TranslationImageBodyV2 : NSObject

/// 请求id,请求方自定
@property (nonatomic, strong) NSString *qid;

/// 图片base64
/// 最大5M
@property (nonatomic, strong) NSString *imageBase64;

/// 源语言，默认nil （自动识别语言）
/// BCP-47
@property (nonatomic, strong, nullable) NSString *from;

/// 目标语言
/// BCP-47
@property (nonatomic, strong) NSString *to;

/// 是否返回云端渲染图，1=是，0=否，默认 1
@property (nonatomic, strong) NSString *render;

/// 翻译模型，0=NMT，1=大模型 pro，2=大模型 lite，默认 0
@property (nonatomic, strong) NSString *translateOption;

@end

NS_ASSUME_NONNULL_END
