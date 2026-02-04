//
//  TSCircleProcessView.h
//  JieliJianKang
//
//  Created by 磐石 on 2024/2/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TSCircleProcessCallBackBlock)(NSInteger current);
typedef void(^TSCircleProcessFinishedBlock)(void);

@interface TSCircleProcessConfiger : NSObject

@property (nonatomic,assign) CGFloat processDuring;

@property (nonatomic,strong) UIColor * circleBackgroundColor;

@property (nonatomic,strong) UIColor * circleColor;

@property (nonatomic,assign) CGFloat lineWidth;

@property (nonatomic,assign) BOOL needCallback;

@property (nonatomic,assign) NSInteger timeInterval;

@property (nonatomic,copy) TSCircleProcessCallBackBlock callBackBlock;

@property (nonatomic,copy) TSCircleProcessFinishedBlock finishedBlock;

@end

@interface TSCircleProcessView : UIView

- (instancetype)initWithConfiger:(TSCircleProcessConfiger *)configer;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
