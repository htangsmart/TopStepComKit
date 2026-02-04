//
//  TSCustomTableViewCellModel.m
//  JieliJianKang
//
//  Created by luigi on 2024/3/29.
//

#import "TSCustomTableViewCellModel.h"

@implementation TSCustomTableViewCellModel
- (void)switchChange:(BOOL)isOn {
    if (self.switchChangeBlock) { self.switchChangeBlock(isOn); }
}
@end
