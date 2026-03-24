//
//  TSECardModel+Fit.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/21.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>
#import <FitCloudKit/FitCloudKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Category for converting between TSECardModel and FitCloudECard
 * @chinese TSECardModel和FitCloudECard之间的转换分类
 */
@interface TSECardModel (Fit)

/**
 * @brief Convert FitCloudECard to TSECardModel
 * @chinese 将FitCloudECard转换为TSECardModel
 *
 * @param fitCard 
 * [EN]: FitCloudECard object to be converted
 * [CN]: 需要转换的FitCloudECard对象
 *
 * @return 
 * [EN]: Converted TSECardModel object, nil if conversion fails
 * [CN]: 转换后的TSECardModel对象，转换失败时返回nil
 */
+ (nullable TSECardModel *)modelWithFitCloudECard:(nullable FitCloudECard *)fitCard;

/**
 * @brief Convert array of FitCloudECard to array of TSECardModel
 * @chinese 将FitCloudECard数组转换为TSECardModel数组
 *
 * @param fitCards 
 * [EN]: Array of FitCloudECard objects to be converted
 * [CN]: 需要转换的FitCloudECard对象数组
 *
 * @return 
 * [EN]: Array of converted TSECardModel objects
 * [CN]: 转换后的TSECardModel对象数组
 */
+ (NSArray<TSECardModel *> *)modelsWithFitCloudECards:(NSArray<FitCloudECard *> *)fitCards;

/**
 * @brief Convert TSECardModel to FitCloudECard
 * @chinese 将TSECardModel转换为FitCloudECard
 *
 * @return 
 * [EN]: Converted FitCloudECard object, nil if conversion fails
 * [CN]: 转换后的FitCloudECard对象，转换失败时返回nil
 */
- (nullable FitCloudECard *)toFitCloudECard;

/**
 * @brief Convert array of TSECardModel to array of FitCloudECard
 * @chinese 将TSECardModel数组转换为FitCloudECard数组
 *
 * @param models 
 * [EN]: Array of TSECardModel objects to be converted
 * [CN]: 需要转换的TSECardModel对象数组
 *
 * @return 
 * [EN]: Array of converted FitCloudECard objects
 * [CN]: 转换后的FitCloudECard对象数组
 */
+ (NSArray<FitCloudECard *> *)fitCloudECardsWithModels:(NSArray<TSECardModel *> *)models;

@end

NS_ASSUME_NONNULL_END
