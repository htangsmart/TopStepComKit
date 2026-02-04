//
//  TSSheetContainerView.h
//  TSFoundation
//
//  Created by 磐石 on 2024/8/12.
//

#import <UIKit/UIKit.h>
#import "TSSheetAction.h"

NS_ASSUME_NONNULL_BEGIN

@class TSSheetContainerView;

@protocol TSSheetContainerViewDelegate <NSObject>

- (void)containerDismiss:(TSSheetContainerView *)container;

@end

@interface TSSheetContainerView : UIView

@property (nonatomic,weak) id <TSSheetContainerViewDelegate> delegate;

- (void)reloadContainerWithActions:(NSArray *)actions cancelAction:(TSSheetAction *)cancelAction;

- (void)show;


@end

NS_ASSUME_NONNULL_END
