//
//  TSSafeValue.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/9/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: - Safe extract helpers
static inline double SafeDouble(id obj) {
    return [obj respondsToSelector:@selector(doubleValue)] ? [obj doubleValue] : 0.0;
}
static inline NSInteger SafeInteger(id obj) {
    return [obj respondsToSelector:@selector(integerValue)] ? [obj integerValue] : 0;
}
/**
 * @brief Read BOOL from NSNumber/NSString; NSNull / missing → NO (avoids -[NSNull boolValue] crash).
 * @chinese 从 NSNumber 等读取布尔；NSNull 或无法解析时为 NO，避免对 NSNull 调用 boolValue 崩溃。
 */
static inline BOOL SafeBool(id obj) {
    return [obj respondsToSelector:@selector(boolValue)] ? [obj boolValue] : NO;
}
static inline NSString * SafeString(id obj) {
    return [obj isKindOfClass:NSString.class] ? (NSString *)obj : (obj ? [obj description] : @"");
}


@interface TSSafeValue : NSObject

@end

NS_ASSUME_NONNULL_END
