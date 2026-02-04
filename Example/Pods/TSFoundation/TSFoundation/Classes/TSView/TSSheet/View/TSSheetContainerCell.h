//
//  TSSheetContainerCell.h
//  TSFoundation
//
//  Created by 磐石 on 2024/8/12.
//

#import <UIKit/UIKit.h>
#import "TSSheetAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSSheetContainerCell : UITableViewCell

- (void)reloadContainerCellWithAction:(TSSheetAction *)action;

@end

NS_ASSUME_NONNULL_END
