//
//  WMAppViewModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WMAppViewType) {
    //瀑布流 （Waterfall flow）
    WMAppViewTypeWATERFALL = 0,
    //列表 （list）
    WMAppViewTypeLIST,
    //满天星 （STAR）
    WMAppViewTypeSTAR,
    //九宫格 （9-box grid）
    WMAppViewTypeNINE_GRID,
};

/// app视图设置 （app view Settings）
@interface WMAppViewModel : NSObject

/// 当前视图 （Current view）
@property (nonatomic, assign) WMAppViewType current;

/// 支持的视图列表（WMAppViewType） （List of supported views (WMAppViewType)）
- (NSArray<NSNumber *> *)views;

@end

NS_ASSUME_NONNULL_END
