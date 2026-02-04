//
//  TSAttributedString.m
//  JieliJianKang
//
//  Created by 磐石 on 2024/1/23.
//

#import "TSAttributedString.h"
#import "TSChecker.h"
@implementation TSAttributedString


+ (NSAttributedString *)attributedStringWithString:(NSString *)targetString font:(UIFont *)font textColor:(UIColor *)textColor link:(NSString *)link{
    if ([TSChecker isEmptyString:targetString] || [TSChecker isEmptyString:link]) {return nil;}
    return [[NSAttributedString alloc]initWithString:targetString attributes:@{
        NSFontAttributeName:font,
        NSForegroundColorAttributeName:textColor,
        NSLinkAttributeName:link
    }];
}

+ (NSAttributedString *)attributedStringWithString:(NSString *)targetString font:(UIFont *)font textColor:(UIColor *)textColor{
    if ([TSChecker isEmptyString:targetString]) {return nil;}
    return [[NSAttributedString alloc]initWithString:targetString attributes:@{
        NSFontAttributeName:font,
        NSForegroundColorAttributeName:textColor
    }];
}

+ (NSAttributedString *)attributedStringWithString:(NSString *)targetString font:(UIFont *)font textColor:(UIColor *)textColor lineSpace:(CGFloat)lineSpace alignment:(NSTextAlignment)alignment {
    
    if ([TSChecker isEmptyString:targetString]) {return nil;}
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;  //设置行间距
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = alignment;

    return  [[NSAttributedString alloc]initWithString:targetString attributes:@{
        NSFontAttributeName:font,
        NSForegroundColorAttributeName:textColor,
        NSParagraphStyleAttributeName:paragraphStyle
    }];
}

+ (NSAttributedString *)attributedStringWithString:(NSString *)targetString subString:(NSString *)subString font:(UIFont *)font textColor:(UIColor *)textColor subFont:(UIFont *)subFont subColor:(UIColor *)subColor {
    if (![TSChecker isEmptyString:targetString] && ![TSChecker isEmptyString:subString]) {
        NSDictionary *targetAttributes = @{
            NSFontAttributeName:font,
            NSForegroundColorAttributeName:textColor,
        };
        NSDictionary *subAttributes = @{
            NSFontAttributeName:subFont,
            NSForegroundColorAttributeName:subColor,
        };
        NSMutableAttributedString *totalAttributeString =  [[NSMutableAttributedString alloc]initWithString:targetString attributes:targetAttributes];
        NSArray *ranges = [TSAttributedString stringRangesWithTarget:targetString subString:subString];
        if (ranges.count>0) {
            for (NSString *rangeString in ranges) {
                [totalAttributeString addAttributes:subAttributes range:NSRangeFromString(rangeString)];
            }
        }
        return totalAttributeString;
    }
    return nil;
}


+ (NSArray *)stringRangesWithTarget:(NSString *)targetString subString:(NSString *)subString{
    NSMutableArray *ranges = [NSMutableArray new];
    if (![TSChecker isEmptyString:targetString] && ![TSChecker isEmptyString:subString]) {
        NSString *fountString = targetString;
        NSInteger location = 0;
        while (fountString.length>0) {
            NSRange locationRange = [fountString rangeOfString:subString];
            if (locationRange.location != NSNotFound) {
                [ranges addObject:NSStringFromRange(NSMakeRange(location+locationRange.location, locationRange.length))];
                location = locationRange.location+locationRange.length;
                fountString = [fountString substringFromIndex:locationRange.location+locationRange.length];
            }else{
                fountString = nil;
            }
        }
    }
    return ranges;
}


@end
