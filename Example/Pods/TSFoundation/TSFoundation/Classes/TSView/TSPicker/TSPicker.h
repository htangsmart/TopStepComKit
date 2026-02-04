//
//  TSPicker.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/25.
//

#import <Foundation/Foundation.h>
#import "TSPickerViewController.h"
#import "TSPickerData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSPicker : NSObject

+(void)presentPickerAlertOnVC:(UIViewController *)superVC pickerDataSource:(NSArray *)pickerDataSource confirm:(NSString *)confirmString confirmBlock:(void(^)(NSArray<TSPickerValue *> * actionValue))confirmBlock  cancel:(NSString *)cancelString cancelBlock:(void(^)(NSArray * actionValue))cancelBlock;

+(void)presentDatePickerAlertOnVC:(UIViewController *)superVC pickerDataSource:(NSArray *)pickerDataSource confirm:(NSString *)confirmString confirmBlock:(void(^)(NSArray <TSPickerValue *>* actionValue))confirmBlock  cancel:(NSString *)cancelString cancelBlock:(void(^)(NSArray <TSPickerValue *> *actionValue))cancelBlock reloadComponents:(NSArray *(^)(NSArray *pickerDataSource))reloadComponents;

@end

NS_ASSUME_NONNULL_END
