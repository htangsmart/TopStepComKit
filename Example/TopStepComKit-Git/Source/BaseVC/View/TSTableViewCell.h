//
//  TSTableViewCell.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/1/2.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSValueModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface TSTableViewCell : UITableViewCell

- (void)reloadCellWithModel:(TSValueModel *)cellModel;

- (void)reloadCellWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
