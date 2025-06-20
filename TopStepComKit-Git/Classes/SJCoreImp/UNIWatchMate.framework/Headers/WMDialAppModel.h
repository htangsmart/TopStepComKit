//
//  WMDialAppModel.h
//  UNIWatchMate
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMDialModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMDialAppModel : NSObject<WMSupportProtocol>

/// 监听当前表盘变化 （Monitor the current dial change）
@property (nonatomic, strong) RACSignal<NSString *> *currentDialIdentifier;

/// 获取表盘列表 （Gets a list of watch faces）
- (RACSignal<NSArray<WMDialModel *> *> *)syncDialList;

/// 删除表盘 （Remove dial）
/// - Parameter dial: 表盘 （Dial plate）
- (RACSignal<NSNumber *> *)deleteDial:(WMDialModel *)dial;

/// 设置当前表盘 （Set the current dial）
/// - Parameter dialIdentifier: 表盘Id （Dial Id）
- (RACSignal<NSNumber *> *)wm_setCurrentDial:(NSString *)dialIdentifier;

@end

NS_ASSUME_NONNULL_END
