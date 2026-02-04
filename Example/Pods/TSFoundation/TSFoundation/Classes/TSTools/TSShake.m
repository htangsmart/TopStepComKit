//
//  TSShake.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/8.
//

#import "TSShake.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation TSShake

+ (void)shake{
    [[[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium] impactOccurred];
}

+ (void)shake:(UIImpactFeedbackStyle)shakeStyle{
    [[[UIImpactFeedbackGenerator alloc]initWithStyle:shakeStyle] impactOccurred];
}

+ (void)audioShake{
    AudioServicesPlaySystemSound(1521);
}

+ (void)shakeView:(UIView *)shakeView{
    [TSShake shakeView:shakeView distance:4 direction:eTSShakeDirectionLeftRight duration:0.06f repeatCount:4];
}


+ (void)shakeView:(UIView *) view distance:(CGFloat)distance direction:(TSShakeDirection)direction duration:(CGFloat)duration repeatCount:(NSInteger)repeatCount
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint beginPoint;
    CGPoint endPoint;
    if (direction == eTSShakeDirectionLeftRight) {
        beginPoint = CGPointMake(position.x + distance, position.y);
        endPoint = CGPointMake(position.x - distance, position.y);
    }else{
        beginPoint = CGPointMake(position.x, position.y + distance);
        endPoint = CGPointMake(position.x, position.y - distance);
    }
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:beginPoint]];
    [animation setToValue:[NSValue valueWithCGPoint:endPoint]];
    [animation setAutoreverses:YES];
    [animation setDuration:duration];
    [animation setRepeatCount:repeatCount];
    [viewLayer addAnimation:animation forKey:nil];
}



@end
