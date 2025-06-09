//
//  PwCrypto.h
//  persimwearSDK
//
//  Created by rtt on 2023/6/15.
//
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "JKBigDecimal.h"

@interface PwCrypto : NSObject

+(NSInteger)checkLicense:(NSString *)license;

+(NSInteger)getLicenseLevel;

+(BOOL)isPersimWearCore;

+(BOOL)isPersimWearService;

+(NSString * _Nonnull)createLicense:(BOOL)flag;

+(NSData *)sha1:(NSString * _Nonnull)code;

+(NSString *)shaEncrypt:(NSString * _Nonnull)code;

+(NSString * _Nonnull)coverToradix:(JKBigInteger * _Nonnull)value radix:(int)radix;


@end
