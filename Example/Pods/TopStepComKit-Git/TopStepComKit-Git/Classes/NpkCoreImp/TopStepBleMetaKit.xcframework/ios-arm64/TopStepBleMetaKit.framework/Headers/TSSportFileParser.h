//
//  TSSportFileParser.h
//  TopStepBleMetaKit
//

#import <Foundation/Foundation.h>

@class TSMetaSportDetailData;
@class TSMetaSportRecord;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Coordinates the full parse flow for a sport detail binary file.
 * @chinese 协调运动详情二进制文件的完整解析流程。
 *
 * Registers all block parsers, detects file version, runs the main parse loop,
 * and returns a fully populated TSMetaSportDetailData.
 */
@interface TSSportFileParser : NSObject

- (nullable TSMetaSportDetailData *)parseData:(NSData *)data
                             startTimeSeconds:(int64_t)startTimeSeconds
                                     duration:(int32_t)duration
                                  binFilePath:(NSString *)binFilePath
                                        error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
