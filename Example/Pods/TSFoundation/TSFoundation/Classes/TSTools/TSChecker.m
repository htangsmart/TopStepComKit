//
//  TSChecker.m
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/25.
//

#import "TSChecker.h"

@implementation TSChecker

+ (BOOL)isEmptyString:(NSString *)string{
    if(string == nil || string == NULL) return YES;
    if ([string isKindOfClass:[NSNull class]])  return YES;
    if (string.length == 0) return YES;
    
     NSString *trimmedStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedStr.length == 0) return YES;
    return NO;
}

+ (BOOL)isNumber:(NSNumber *)number {
    if (number == nil || number == NULL) { return false; }
    if ([number isKindOfClass:[NSNull class]])  return false;
    if (![number isKindOfClass:[NSNumber class]]) { return false; }
    return true;
}

+ (BOOL)isEmptyDictonary:(NSDictionary *)dict{
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return YES;
    }

    if (dict == nil) {
        return YES;
    }
    if ([dict isKindOfClass:[NSNull class]] || [dict isEqual:[NSNull null]]) {
        return YES;
    }
    
    if( [dict count] == 0) {
        return YES;
    }
    return NO;
    
}

+ (BOOL)isEmptyObject:(NSDictionary *)dict{
    if (dict == nil) {return YES;}
    if ([dict isKindOfClass:[NSNull class]] || [dict isEqual:[NSNull null]]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isEmptyArray:(NSArray *)array{
    if (array == nil) {return YES;}
    if ([array isKindOfClass:[NSNull class]] || [array isEqual:[NSNull null]]) {
        return YES;
    }
    if (![array isKindOfClass:[NSArray class]]) {
        return YES;
    }
    if ([array count] ==0 ) {
        return YES;
    }
    return NO;
}


+ (BOOL)isArrayObject:(id)object{
    if (![TSChecker isEmptyObject:object]) {
        return [object isKindOfClass:[NSArray class]];
    }
    return NO;
}

+ (BOOL)isDictionaryObject:(id)object{
    if (![TSChecker isEmptyObject:object]) {
        return [object isKindOfClass:[NSDictionary class]];
    }
    return NO;
}

@end
