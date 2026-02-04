//
//  TSUnit.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSUnit : NSObject

//distance
+ (float)kmToMiles:(float)kilometre;

+ (float)milesToKM:(float)miles;

+ (float)cmToInch:(float)cm;

+ (float)inchToCM:(float)inch;

+ (float)meterToMiles:(float)meter;

+ (float)meterToKM:(float)meter;

+ (float)kmToMeter:(float)km;

+ (float)milesToMeter:(float)miles;


// weight
+ (float)kgToPound:(float)kg;

+ (float)poundToKg:(float)pound;

@end

NS_ASSUME_NONNULL_END
