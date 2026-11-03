//
//  SimultInterpretationV2RequestBody.h
//  MagicHelper
//
//  Created by ymz on 2025/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimultInterpretationV2RequestBody : NSObject

/// 请求id，有默认值，调用方也可自定,该值也会在结果回调中返回
@property (nonatomic, strong) NSString *qid;
/// 源语言,例如zh-CN
@property (nonatomic, strong) NSString *sourceLanguage;
/// 目标语言,例如zh-CN
@property (nonatomic, strong) NSString *targetLanguage;
/// 是否是单语言识别，YES: 只识别设置的sourceLanguage， NO: 自动识别语言
@property (nonatomic, assign) BOOL isSingleLanguage __attribute__((deprecated("No longer supported")));
/// 是否开启互译，默认开启
/// 互译开始，比如sourceLanguage是中文 targetLanguage是英文 当输入英文时 回调数据sourceLanguage会是英文 targetLanguage则是中文
/// 不开启，回调数据中的language和设置的language一致
@property (nonatomic, assign) BOOL enableTwoWayTranslation;
@end

NS_ASSUME_NONNULL_END
