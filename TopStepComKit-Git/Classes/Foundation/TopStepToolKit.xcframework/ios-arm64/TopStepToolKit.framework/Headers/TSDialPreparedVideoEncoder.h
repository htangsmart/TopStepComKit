#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, TSDialPreparedInputKind) {
    TSDialPreparedInputKindVideo,
    TSDialPreparedInputKindGIF,
};

/// 纯媒体参数；不依赖设备 Provider 或 InterfaceKit。
@interface TSDialPreparedVideoRequest : NSObject
@property(nonatomic, strong) NSURL *inputURL;
@property(nonatomic, strong) NSURL *outputURL;
@property(nonatomic) TSDialPreparedInputKind inputKind;
@property(nonatomic) CGSize targetSize;
@property(nonatomic) BOOL circularMask;
@property(nonatomic) CGFloat cornerRadius;
@property(nonatomic) int64_t maxDurationMillis;
@property(nonatomic) BOOL preserveAudio;
@end

@interface TSDialPreparedVideoEncoder : NSObject
/// 在工作队列同步调用。拒绝覆盖既有输出；失败只清理本次创建的文件。
+ (BOOL)encodeRequest:(TSDialPreparedVideoRequest *)request error:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
