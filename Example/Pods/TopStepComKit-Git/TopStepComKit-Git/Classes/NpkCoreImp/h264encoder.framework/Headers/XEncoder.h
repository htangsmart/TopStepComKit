//
//  XEncoder.h
//  h264encoder
//
//  Created by wangwenfeng on 2023/7/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface XEncoderResultModel : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) bool isKeyFrame;

@end

@interface XEncoder : NSObject

+ (nonnull instancetype)shareInstance;
+ (nonnull instancetype)shareInstanceForNavi;

- (void *) initEncode:(int)dst_width height:(int)dst_height pmode:(int)pmode;
- (void *) initEncode:(int)dst_width height:(int)dst_height fps:(int)fps bitrate:(int)bitrate pmode:(int)pmode;

- (void) uninitEncode:(void *)handle;
- (XEncoderResultModel *) encode:(void *)handle yData:(uint8_t *)y_data uData:(uint8_t *)u_data vData:(nullable uint8_t *)v_data srcWidth:(int)src_width srcHeight:(int)src_height orientation:(int)orientation isBack:(bool)isBack;
- (XEncoderResultModel *) encodeFromImage:(void *)handle jpgData:(NSData *)img_data srcWidth:(int)src_width srcHeight:(int)src_height;

- (NSData*) makeDial:(NSString *)dialFilesDir width:(int)dialWidth height:(int)dialHeight pmode:(int)pmode;
- (NSData*) generateJpgHeader:(int)quality width:(int)width height:(int)height;

/// 把传入的jpg/png文件列表编码为h264数据
/// @param imageList 图片路径列表，jpg或png应该都可以
/// @param outPath 编码后的h264数据文件路径，数据是加了固件可以识别的自定义头信息的
/// @param width 目标视频宽度
/// @param height 目标视频高度
/// @param fps 编码的帧率，default: 20
/// @param bitrate 编码的比特率，default: 1000
/// @param pmode 参考p帧的方式，w20:0, w30:1，default: 0
/// @return 0:成功，其他:失败
- (int) encodeFromImageList:(NSArray<NSString *> *)imageList
                    outPath:(NSString *)outPath
                      width:(int)width
                     height:(int)height
                        fps:(int)fps
                    bitrate:(int)bitrate
                      pmode:(int)pmode;

@end

NS_ASSUME_NONNULL_END
