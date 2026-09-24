//
//  TSHsdErrorText.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Error → human readable text
 * @chinese 错误 → 人话文案 + 「domain / 名称 (code)」小字（产品方案 §3.5）
 */
@interface TSHsdErrorText : NSObject

/// 给用户看的一句话：不支持 / 手表拒绝 / 未连接 / 超时 / 分包不连续 / 其他
+ (NSString *)messageForError:(nullable NSError *)error;

/// 小字："domain / NOTSUPPORT (2004)"
+ (NSString *)detailForError:(nullable NSError *)error;

/// 错误码 → 名称（eTSErrorNotSupport → "NOTSUPPORT"），未知码返回十进制字符串
+ (NSString *)codeNameForCode:(NSInteger)code;

/// BleMeta 分包不连续（"missing some fragments"），没有专用 code，只能按描述判断
+ (BOOL)isMissingFragmentsError:(nullable NSError *)error;

/// 一行摘要，用于日志与 toast："人话（domain / 名称）"
+ (NSString *)summaryForError:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
