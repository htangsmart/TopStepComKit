#import <Foundation/Foundation.h>

/// 仅 Debug 构建启用；观察闭源 SDK 的收包与解析边界，不改动数据或返回值。
@interface TSFitECGDebugTrace : NSObject
+ (void)begin;
+ (void)finish:(NSString *)reason;
+ (void)recordCallbackType:(NSInteger)type sampleIndex:(NSUInteger)index count:(NSUInteger)count;
@end
