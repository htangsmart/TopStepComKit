//
//  TSUnit.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/19.
//

#import "TSUnit.h"

@implementation TSUnit

+ (float)kmToMiles:(float)kilometre{
    return kilometre*0.6213711922;
}

+ (float)milesToKM:(float)miles{
    return miles*1.609344;
}

+ (float)cmToInch:(float)cm{
    return cm*0.3937007874;
}

+ (float)inchToCM:(float)inch{
    return inch*2.54;
}

+ (float)meterToKM:(float)meter{
    return meter/1000.0;
}

+ (float)meterToMiles:(float)meter{
    return [TSUnit kmToMiles:[TSUnit meterToKM:meter]];
}

+ (float)kmToMeter:(float)km{
    return km*1000;
}

+ (float)milesToMeter:(float)miles{
    return [TSUnit kmToMeter:[TSUnit milesToKM:miles]];
}


+ (float)kgToPound:(float)kg{
    return kg*2.2046226218;
}

+ (float)poundToKg:(float)pound{
    return pound*0.45359237;
}

@end
