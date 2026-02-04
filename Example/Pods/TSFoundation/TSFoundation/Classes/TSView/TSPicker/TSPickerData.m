//
//  TSPickerData.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/18.
//

#import "TSPickerData.h"
#import "TSFont.h"
#import "TSPicker.h"
#import "TSChecker.h"
#import "TSColor.h"
#import "NSDate+Tools.h"
#import "JLPhoneUISetting.h"

@implementation TSPickerData


+ (void)reloadBirthdayPickerDataSource:(NSArray * _Nonnull)pickerDataSource {
    // 参数检查
    if (!pickerDataSource || pickerDataSource.count < 3) {
        NSLog(@"Warning: Invalid picker data source");
        return;
    }
    
    // 获取当前日期
    NSDate *today = [NSDate date];
    NSInteger currentYear = today.year;
    NSInteger currentMonth = today.month;
    NSInteger currentDay = today.day;
    
    // 获取年份组件
    TSPickerComponent *yearComponent = pickerDataSource[0];
    if (yearComponent.selectedRow >= yearComponent.items.count) {
        NSLog(@"Warning: Invalid year selected row");
        return;
    }
    TSPickerItem *yearItem = yearComponent.items[yearComponent.selectedRow];
    NSInteger selectedYear = [yearItem.value integerValue];
    
    // 更新月份组件
    TSPickerComponent *monthComponent = pickerDataSource[1];
    NSInteger monthMax = (selectedYear == currentYear) ? currentMonth : 12;
    monthComponent.items = [TSPickerItem pickItemsFormMinNum:1
                                                  toMaxNum:monthMax
                                                 interval:1
                                  fillZeroWhenLessTen:YES];
    
    // 确保月份选择不超过最大值
    if (monthComponent.selectedRow >= monthComponent.items.count) {
        monthComponent.selectedRow = monthComponent.items.count - 1;
    }
    
    // 获取选中的月份
    TSPickerItem *monthItem = monthComponent.items[monthComponent.selectedRow];
    NSInteger selectedMonth = [monthItem.value integerValue];
    
    // 更新日期组件
    TSPickerComponent *dayComponent = pickerDataSource[2];
    NSInteger dayMax;
    
    // 计算最大可选日期
    if (selectedYear == currentYear && selectedMonth == currentMonth) {
        // 当年当月，最大日期为当天
        dayMax = currentDay;
    } else {
        // 其他情况，计算月份的总天数
        dayMax = [NSDate daysCountAtYear:selectedYear month:selectedMonth];
    }
    
    // 更新日期选项
    dayComponent.items = [TSPickerItem pickItemsFormMinNum:1
                                                toMaxNum:dayMax
                                               interval:1
                                fillZeroWhenLessTen:YES];
    
    // 确保日期选择不超过最大值
    if (dayComponent.selectedRow >= dayComponent.items.count) {
        dayComponent.selectedRow = dayComponent.items.count - 1;
    }
}


+ (NSArray *)birthdayDataSourceWithCurrent:(NSString *)current {
    // 获取当前日期
    NSDate *today = [NSDate date];
    NSInteger maxYear = today.year;
    NSInteger maxMonth = today.month;
    NSInteger maxDay = today.day;
    
    // 默认选中当前日期
    NSInteger currentYear = maxYear;
    NSInteger currentMonth = maxMonth;
    NSInteger currentDay = maxDay;

    // 如果有指定日期，则使用指定日期
    if (![TSChecker isEmptyString:current]) {
        NSArray *dateArray = [current componentsSeparatedByString:@"-"];
        if (dateArray.count >= 3) {
            currentYear = [dateArray[0] integerValue];
            currentMonth = [dateArray[1] integerValue];
            currentDay = [dateArray[2] integerValue];
        }
    }
    
    // 年份组件
    NSInteger preYear = 1910;
    NSInteger yearInterval = 1;
    NSInteger selectedYear = (currentYear - preYear) / yearInterval;
    TSPickerComponent *yearCom = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:preYear
                                                                                                    toMaxNum:maxYear
                                                                                                   interval:1
                                                                                    fillZeroWhenLessTen:NO]
                                                                       unit:@""// 多语言UI有问题，和产品刘广昊讨论去掉单位
                                                               selectedRow:selectedYear];
    yearCom.canLinkRefresh = YES;
    
    // 月份组件
    NSInteger monthMax = (currentYear == maxYear) ? maxMonth : 12;
    NSInteger selectedMonth = currentMonth - 1;
    TSPickerComponent *monthCom = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:1
                                                                                                     toMaxNum:monthMax
                                                                                                    interval:1
                                                                                     fillZeroWhenLessTen:YES]
                                                                        unit:@""
                                                                selectedRow:selectedMonth];
    monthCom.canLinkRefresh = YES;

    // 日期组件
    NSInteger dayMax;
    if (currentYear == maxYear && currentMonth == maxMonth) {
        // 如果是当年当月，最大日期为当天
        dayMax = maxDay;
    } else {
        // 否则计算该月的总天数
        dayMax = [NSDate daysCountAtYear:currentYear month:currentMonth];
    }
    
    NSInteger selectedDay = currentDay - 1;
    // 确保选中日期不超过最大日期
    selectedDay = MIN(selectedDay, dayMax - 1);
    
    TSPickerComponent *dayCom = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:1
                                                                                                   toMaxNum:dayMax
                                                                                                  interval:1
                                                                                   fillZeroWhenLessTen:YES]
                                                                      unit:@""
                                                              selectedRow:selectedDay];
    
    return @[yearCom, monthCom, dayCom];
}

+ (NSArray *)yearAndMonthDataSourceWithCurrent:(NSString *)current{
    NSInteger maxYear = [[NSDate date] year];
    
    NSInteger currentYear = [[NSDate date] year];
    NSInteger currentMonth = [[NSDate date] month];

    if (![TSChecker isEmptyString:current]) {
        NSArray *dateArray = [current componentsSeparatedByString:@"-"];
        currentYear = [dateArray.firstObject integerValue];
        currentMonth = [dateArray.lastObject integerValue];
    }
    NSInteger preYear = 1910;
    NSInteger yearInterval = 1;
    NSInteger selectedYear = (currentYear-preYear)/yearInterval;
    TSPickerComponent *yearCom = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:preYear toMaxNum:maxYear interval:1 fillZeroWhenLessTen:NO] unit:@"" selectedRow:selectedYear];
    
    NSInteger totalMonth = 12;
    NSInteger preMonth = 1;
    NSInteger monthInterval = 1;
    NSInteger selectedMonth = (currentMonth-preMonth)/monthInterval;
    TSPickerComponent *monthCom = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:preMonth toMaxNum:totalMonth interval:1 fillZeroWhenLessTen:YES] unit:@"" selectedRow:selectedMonth];

    return @[yearCom,monthCom];
}

+ (NSArray *)genderDataSourceWithCurrent:(int)current{
    
    
    TSPickerItem *maleItem = [[TSPickerItem alloc]initWithValue:kJL_TXT("男")];
    maleItem.itemFont = [TSFont TSFontPingFangMediumWithSize:28];
    maleItem.itemTextColor = [TSColor colorwithHexString:@"#222222"];
    
    TSPickerItem *femaleItem = [[TSPickerItem alloc]initWithValue:kJL_TXT("女")];
    femaleItem.itemFont = [TSFont TSFontPingFangMediumWithSize:28];
    femaleItem.itemTextColor = [TSColor colorwithHexString:@"#222222"];
        
    return @[[TSPickerComponent pickerComponentWithItems:@[maleItem,femaleItem] unit:@"" selectedRow:current==0?0:1]];
}

+ (NSArray *)calorieDataSourceWithCurrent:(int)current{
    NSInteger min = 50;
    NSInteger max = 5000;
    NSInteger interval = 50;
    NSInteger selectedRow = 0;
    if (current != 0) {
        selectedRow = (current-min)/interval;
    }
    return @[[TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:min toMaxNum:max interval:interval fillZeroWhenLessTen:NO] unit:kJL_TXT("千卡") selectedRow:selectedRow]];
}

+ (NSArray *)heightDataSourceWithCurrent:(int)current{
    
    NSInteger min = 30;
    NSInteger max = 249;
    NSInteger interval = 1;
    NSInteger selectedRow = 140;
    if (current != 0) {
        selectedRow = (current-min)/interval;
    }
    NSString *unitAlert = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    NSString *unit = [unitAlert isEqualToString:@"英制"]?kJL_TXT("英寸"):kJL_TXT("厘米");
    return @[[TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:min toMaxNum:max interval:interval fillZeroWhenLessTen:NO] unit:unit selectedRow:selectedRow]];
}

+ (NSArray *)weightDataSourceWithCurrent:(float)current{
    
    NSInteger intMin = 1;
    NSInteger intMax = 299;
    NSInteger intInterval = 1;
    NSInteger selectedIntRow = 0;
    if (current != 0) {
        selectedIntRow = (current-intMin)/intInterval;
    }
    TSPickerComponent *superWeightComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:intMin toMaxNum:intMax interval:intInterval fillZeroWhenLessTen:NO] unit:@"" selectedRow:selectedIntRow];
    
    
    NSString *unitAlert = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    NSString *unit = [unitAlert isEqualToString:@"英制"]?kJL_TXT("磅"):kJL_TXT("千克");
    double floatMin = 0.0;
    double floatMax = 0.9;
    double floatInterval = 0.1;
    NSInteger selectedFloatRow = 0;
    double floatValue = modff(current, &current);
    if (floatValue != 0) {
        selectedFloatRow = (floatValue-floatMin)/floatInterval;
    }
    TSPickerComponent *detailWeightComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:floatMin toMaxNum:floatMax interval:floatInterval fillZeroWhenLessTen:NO] unit:unit selectedRow:selectedFloatRow];
//    TSPickerComponent *detailWeightComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem precisionPickItemsFormMinNum:[[NSDecimalNumber alloc]initWithFloat:floatMin] toMaxNum:[[NSDecimalNumber alloc]initWithFloat:floatMax] interval:[[NSDecimalNumber alloc]initWithFloat:floatInterval] fillZeroWhenLessTen:NO] unit:unit selectedRow:selectedFloatRow];
    return @[superWeightComponent,detailWeightComponent];
}

+(NSArray *)hourMinutesDataSourceWithCurrent:(int)current{
    
    NSInteger selectedHourRow = 0;
    if (current>=60) {
        selectedHourRow = current/60;
    }
    NSInteger selectedMinRow = 0;
    if (current>0) {
        selectedMinRow = current%60;
    }
    TSPickerComponent *hourComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:0 toMaxNum:23 interval:1 fillZeroWhenLessTen:YES] unit:kJL_TXT("时") selectedRow:selectedHourRow];
    TSPickerComponent *minComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:0 toMaxNum:59 interval:1 fillZeroWhenLessTen:YES] unit:kJL_TXT("分") selectedRow:selectedMinRow];
    return @[hourComponent,minComponent];
}

+ (NSArray *)hourMinutesDataSourceWithCurrent:(int)current hMin:(NSInteger)hMin hMax:(NSInteger)hMax mMin:(NSInteger)mMin mMax:(NSInteger)mMax canLinkRefresh:(BOOL)canLinkRefresh{
    
    NSInteger selectedHourRow = 0;
    if (current>=60) {selectedHourRow = (current/60 - hMin);}
    NSInteger selectedMinRow = 0;
    if (current>0) {selectedMinRow = (current%60 - mMin);}
    TSPickerComponent *hourComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:hMin toMaxNum:hMax interval:1 fillZeroWhenLessTen:YES] unit:kJL_TXT("时") selectedRow:selectedHourRow];
    hourComponent.canLinkRefresh = canLinkRefresh;

    TSPickerComponent *minComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:mMin toMaxNum:mMax interval:1 fillZeroWhenLessTen:YES] unit:kJL_TXT("分") selectedRow:selectedMinRow];
    return @[hourComponent,minComponent];

}


+(NSArray *)frequencyDataSourceWithCurrent:(int)current{
    
    NSInteger min = 1;
    NSInteger max = 99;
    NSInteger interval = 1;
    NSInteger selectedRow = 0;
    if (current != 0) {
        selectedRow = (current-min)/interval;
    }
    TSPickerComponent *minComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:min toMaxNum:max interval:interval fillZeroWhenLessTen:NO] unit:kJL_TXT("次") selectedRow:selectedRow];
    return @[minComponent];
}

+(NSArray *)stepDataSourceWithCurrent:(int)current{
    
    NSInteger min = 1000;
    NSInteger max = 20000;
    NSInteger interval = 1000;
    NSInteger selectedRow = 7;
    if (current != 0) {
        selectedRow = (current-min)/interval;
    }
    TSPickerComponent *minComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:min toMaxNum:max interval:interval fillZeroWhenLessTen:NO] unit:kJL_TXT("步") selectedRow:selectedRow];
    return @[minComponent];
}

+ (NSArray *)distanceDataSourceWithCurrent:(float)current{
    
    float min = 0.5f;
    float max = 50.0f;
    float interval = 0.5f;
    NSInteger selectedRow = 0;
    if (current != 0) {
        selectedRow = (current-min)/interval;
    }
    NSString *unitAlert = [[NSUserDefaults standardUserDefaults] valueForKey:@"UNITS_ALERT"];
    NSString *unit = [unitAlert isEqualToString:@"英制"]?kJL_TXT("英里"):kJL_TXT("千米");
    return @[[TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:min toMaxNum:max interval:interval fillZeroWhenLessTen:NO] unit:unit selectedRow:selectedRow]];
}

+ (NSArray *)integerDataWithCurrent:(NSInteger)current min:(NSInteger)min max:(NSInteger)max interval:(NSInteger)interval unit:(NSString *)unit {
    
    NSInteger selectedRow = 0;
    if (current != 0) {
        selectedRow = (current - min)/interval;
    }
    
    TSPickerComponent *minComponent = [TSPickerComponent pickerComponentWithItems:[TSPickerItem pickItemsFormMinNum:min toMaxNum:max interval:interval fillZeroWhenLessTen:NO] unit:unit selectedRow:selectedRow];
    return @[ minComponent ];
}
@end

