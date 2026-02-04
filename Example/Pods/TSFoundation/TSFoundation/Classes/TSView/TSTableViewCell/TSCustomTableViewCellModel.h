//
//  TSCustomTableViewCellModel.h
//  JieliJianKang
//
//  Created by luigi on 2024/3/29.
//

#import <Foundation/Foundation.h>
#import "TSCustomTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSCustomTableViewCellModel : NSObject<TSCustomTableViewCellProtocol>
@property (nonatomic, assign) TSCustomTableViewCellStyle cellStyle;
@property (nonatomic, copy) NSString *cellTag;//单元格标识
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, strong) UIImage * titleImage;
@property (nonatomic, assign) BOOL isOn;//UIswitch isOn
@property (nonatomic, assign) BOOL isSelected;//选择按钮isSelected
@property (nonatomic, copy) void(^switchChangeBlock)(BOOL isON);
- (void)switchChange:(BOOL)isOn;
@end

NS_ASSUME_NONNULL_END
