//
//  TSSportItemModel+Npk.h
//  TopStepNewPlatformKit
//
//  Created by 磐石 on 2025/9/11.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

@class TSMetaSportDetailData;

NS_ASSUME_NONNULL_BEGIN

@interface TSSportItemModel (Npk)

/// 从 TSSportDetailItemTable 查询结果构建 TSSportItemModel 数组
+ (NSArray<TSSportItemModel *> *)sportItemModelsFromDictionaries:(NSArray<NSDictionary *> *)dictionaryArray;

/**
 * @brief 从 TSMetaSportDetailData 转换运动详情数据为字典数组（用于入库）
 * @chinese 从解析后的运动详情数据生成数据库字典数组
 *
 * @param detailData
 * EN: Parsed sport detail data from .pb file
 * CN: 从.pb文件解析的运动详情数据
 *
 * @return
 * EN: Array of dictionaries ready for TSSportDetailItemTable insertion
 * CN: 可直接插入 TSSportDetailItemTable 的字典数组
 *
 * @discussion
 * [EN]: Converts TSMetaSportItem array to database dictionary format.
 *       sportID is automatically derived from detailData.startTimeSeconds.
 *       userID and macAddress are automatically fetched from TSNpkComDataStorage.
 * [CN]: 将 TSMetaSportItem 数组转换为数据库字典格式。
 *       sportID 自动从 detailData.startTimeSeconds 获取。
 *       userID 和 macAddress 会自动从 TSNpkComDataStorage 获取。
 */
+ (NSArray<NSDictionary *> *)sportDetailDictionariesFromDetailData:(TSMetaSportDetailData *)detailData;

@end

NS_ASSUME_NONNULL_END
