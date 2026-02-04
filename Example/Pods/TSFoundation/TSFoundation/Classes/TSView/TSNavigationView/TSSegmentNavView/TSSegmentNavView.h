//
//  TSDialHomeNavView.h
//  TSDial
//
//  Created by 磐石 on 2024/8/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TSSegmentNavView;

@protocol TSSegmentNavViewDelegate <NSObject>

- (void)returnBack;

@optional
- (void)rightButtonEvnet:(UIButton *)sender;

- (void)tsSegment:(TSSegmentNavView *)segmentNav didSelectedAtIndex:(NSInteger)index;

@end

typedef void(^TSActionBlock)(void);

@interface TSSegmentAction : NSObject

@property (nonatomic,strong) NSString  * actionName;

@property (nonatomic,strong)  TSActionBlock actionBlock;

@property (nonatomic,assign) SEL actionEvent;

- (instancetype)initWithActionName:(NSString *)actionName actionBlock:(TSActionBlock)actionBlock;
- (instancetype)initWithActionName:(NSString *)actionName actionEvent:(SEL)actionEvent;

@end

@interface TSSegmentNavView : UIView

@property (nonatomic,weak) id<TSSegmentNavViewDelegate> delegate;

- (void)addAction:(NSString *)actionName action:(void(^)(void))actionBlock;

- (void)addAction:(NSString *)actionName actionEvent:(SEL)actionEvent;

- (void)addActions:(NSArray *)actions;

- (void)selectedSegmentAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
