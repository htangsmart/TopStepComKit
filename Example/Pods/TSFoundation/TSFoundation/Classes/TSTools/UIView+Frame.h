//
//  UIView+Frame.h
//  TSFoundation
//
//  Created by 磐石 on 2024/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Frame)

/*
 * @brief 获取view x最大
 */
- (CGFloat)maxX;

/*
 * @brief 获取view x最小
 */
- (CGFloat)minX;

/*
 * @brief 获取view y最大
 */
- (CGFloat)maxY;

/*
 * @brief 获取view y最小
 */
- (CGFloat)minY;

/*
 * @brief 获取view x最小
 */
- (CGFloat)oriX;

/*
 * @brief 获取view y最小
 */
- (CGFloat)oriY;
- (void)setOriY:(CGFloat)oriY;


/*
 * @brief 获取view 宽
 */
- (CGFloat)width;

/*
 * @brief 获取view 高
 */
- (CGFloat)height;

-/*
* @brief 获取view size
*/ (CGSize)size;




@end

NS_ASSUME_NONNULL_END
