//
//  TSChecker.h
//  JieliJianKang
//
//  Created by 磐石 on 2023/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define TSSTRING_ISEMPTY(string) [TSChecker isEmptyString:string]
#define TSSTRING_SAFE(string) (TSSTRING_ISEMPTY(string) ? @"" : string)

#define TSARRAY_ISEMPTY(array) [TSChecker isEmptyArray:array]
#define TSARRAY_SAFE(array) (TSARRAY_ISEMPTY(array) ? @[] : array)

#define TSNUMBER_SAFE(number) ([TSChecker isNumber:number] ? number : @(0))

@interface TSChecker : NSObject

+ (BOOL)isEmptyString:(NSString *)string;

+ (BOOL)isEmptyDictonary:(NSDictionary *)dict;

+ (BOOL)isEmptyArray:(NSArray *)array;

+ (BOOL)isEmptyObject:(NSDictionary *)dict;

+ (BOOL)isArrayObject:(id)object;

+ (BOOL)isDictObject:(id)object;

+ (BOOL)isNumber:(NSNumber *)number;

@end

NS_ASSUME_NONNULL_END
