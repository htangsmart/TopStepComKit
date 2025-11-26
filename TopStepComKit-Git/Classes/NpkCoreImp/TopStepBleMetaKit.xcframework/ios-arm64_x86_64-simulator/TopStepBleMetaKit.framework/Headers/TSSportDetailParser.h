//
//  TSSportDetailParser.h
//  TopStepBleMetaKit
//
//  Created by AI Assistant on 2025/11/13.
//

#import <Foundation/Foundation.h>

// 前向声明（Protobuf生成后会有实际定义）
@class TSMetaSportDetailData;
@class TSMetaSportRecord;

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Sport detail data parser
 * @chinese 运动详情数据解析器
 *
 * @discussion
 * [EN]: Parses binary sport detail files (.bin) into structured Protobuf format (.pb).
 *       The parser handles configuration blocks and multiple data blocks (HR, steps, distance, calories).
 * [CN]: 将二进制运动详情文件（.bin）解析为结构化的Protobuf格式（.pb）。
 *       解析器处理配置块和多个数据块（心率、步数、距离、卡路里）。
 */
@interface TSSportDetailParser : NSObject

/**
 * @brief Parse sport detail .bin file and save as .pb file
 * @chinese 解析运动详情.bin文件并保存为.pb文件
 *
 * @param binFilePath
 * EN: Original .bin file path (e.g., ".../sport/20251112105830.bin")
 * CN: 原始.bin文件路径（如：".../sport/20251112105830.bin"）
 *
 * @param record
 * EN: Sport record object (provides startTimeSeconds and duration)
 * CN: 运动记录对象（提供startTimeSeconds和duration）
 *
 * @param error
 * EN: Error information if parsing fails
 * CN: 解析失败时的错误信息
 *
 * @return
 * EN: Parsed .pb file path (e.g., ".../sport/20251112105830.pb"), nil if failed
 * CN: 解析后的.pb文件路径（如：".../sport/20251112105830.pb"），失败返回nil
 *
 * @discussion
 * [EN]: This method:
 *       1. Reads the binary .bin file
 *       2. Parses configuration block (0x00) for intervals
 *       3. Parses data blocks (0x01=HR, 0x07=steps, 0x08=distance, 0x09=calories)
 *       4. Skips first data point (always 0)
 *       5. Converts cumulative values to incremental values
 *       6. Merges all data into sport items
 *       7. Saves as Protobuf .pb file
 * [CN]: 此方法：
 *       1. 读取二进制.bin文件
 *       2. 解析配置块（0x00）获取间隔时间
 *       3. 解析数据块（0x01=心率、0x07=步数、0x08=距离、0x09=卡路里）
 *       4. 跳过第一个数据点（总是0）
 *       5. 将累加值转换为增量值
 *       6. 合并所有数据为运动项
 *       7. 保存为Protobuf .pb文件
 *
 */
+ (NSString * _Nullable)parseAndSaveFile:(NSString *)binFilePath
                              withRecord:(TSMetaSportRecord *)record
                                   error:(NSError **)error;

/**
 * @brief Load parsed sport detail data from .pb file
 * @chinese 从.pb文件加载已解析的运动详情数据
 *
 * @param pbFilePath
 * EN: .pb file path
 * CN: .pb文件路径
 *
 * @param error
 * EN: Error information if loading fails
 * CN: 加载失败时的错误信息
 *
 * @return
 * EN: TSMetaSportDetailData object, nil if failed
 * CN: TSMetaSportDetailData对象，失败返回nil
 *
 * @discussion
 * [EN]: Loads previously parsed sport detail data from Protobuf file.
 *       Returns a fully typed TSMetaSportDetailData object with type-safe access.
 * [CN]: 从Protobuf文件加载之前解析的运动详情数据。
 *       返回完全类型安全的TSMetaSportDetailData对象。
 *
 * @code
 * NSError *error = nil;
 * TSMetaSportDetailData *data = [TSSportDetailParser loadFromFile:pbPath error:&error];
 * if (data) {
 *     for (TSMetaSportHeartRateItem *item in data.heartRateItemsArray) {
 *         NSLog(@"心率: %d", item.heartRate);
 *     }
 * }
 * @endcode
 */
+ (TSMetaSportDetailData * _Nullable)loadFromFile:(NSString *)pbFilePath
                                            error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

