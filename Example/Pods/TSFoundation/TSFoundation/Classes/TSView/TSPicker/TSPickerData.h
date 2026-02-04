//
//  TSPickerData.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSPickerData: NSObject

+ (NSArray *)birthdayDataSourceWithCurrent:(NSString *)current;
+ (void)reloadBirthdayPickerDataSource:(NSArray * _Nonnull)pickerDataSource;

+ (NSArray *)yearAndMonthDataSourceWithCurrent:(NSString *)current;
+ (NSArray *)genderDataSourceWithCurrent:(int)current;
+ (NSArray *)calorieDataSourceWithCurrent:(int)current;
+ (NSArray *)heightDataSourceWithCurrent:(int)current;
+ (NSArray *)weightDataSourceWithCurrent:(float)current;
+ (NSArray *)stepDataSourceWithCurrent:(int)current;
+ (NSArray *)frequencyDataSourceWithCurrent:(int)current;
+ (NSArray *)distanceDataSourceWithCurrent:(float)current;
+ (NSArray *)hourMinutesDataSourceWithCurrent:(int)current;
+ (NSArray *)hourMinutesDataSourceWithCurrent:(int)current hMin:(NSInteger)hMin hMax:(NSInteger)hMax mMin:(NSInteger)mMin mMax:(NSInteger)mMax canLinkRefresh:(BOOL)canLinkRefresh;
+ (NSArray *)integerDataWithCurrent:(NSInteger)current min:(NSInteger)min max:(NSInteger)max interval:(NSInteger)interval unit:(NSString *)unit;
@end

NS_ASSUME_NONNULL_END

