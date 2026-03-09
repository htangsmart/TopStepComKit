//
//  TSMessageSwitchCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/2/17.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSMessageModel;

@interface TSMessageSwitchCell : UITableViewCell

@property (nonatomic, copy) void(^onSwitchChanged)(BOOL isOn);

- (void)configureWithModel:(TSMessageModel *)model
                  iconName:(NSString *)iconName
                 iconColor:(UIColor *)iconColor
                      name:(NSString *)name;

- (void)setEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
