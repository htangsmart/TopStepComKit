//
//  TSLicense.h
//  TopStepComKit
//
//  Created by 磐石 on 2025/3/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief License management class for SDK
 * @chinese SDK证书管理类
 *
 * @discussion 
 * [EN]: This class manages license validation for the SDK. It supports both predefined license keys 
 * and dynamically generated license keys based on the application's bundle identifier.
 * [CN]: 此类管理SDK的证书验证。它支持预定义的证书密钥和基于应用程序Bundle Identifier动态生成的证书密钥。
 */
@interface TSLicense : NSObject

/**
 * @brief Validate license key
 * @chinese 验证证书密钥
 *
 * @param licenseKey 
 * EN: License key string (32 characters)
 * CN: 证书密钥字符串（32位字符）
 *
 * @return 
 * EN: YES if license is valid, NO otherwise
 * CN: 证书有效返回YES，否则返回NO
 */
+ (BOOL)validateLicenseKey:(NSString *)licenseKey;

/**
 * @brief Get current license status
 * @chinese 获取当前证书状态
 *
 * @return 
 * EN: YES if license is valid, NO otherwise
 * CN: 证书有效返回YES，否则返回NO
 */
+ (BOOL)isLicenseValid;

/**
 * @brief Generate a license key based on current app's bundle identifier
 * @chinese 基于当前应用的Bundle Identifier生成证书密钥
 *
 * @return 
 * EN: Generated license key for current app
 * CN: 为当前应用生成的证书密钥
 */
+ (NSString *)generateLicenseKey;

/**
 * @brief Generate a license key for a specific bundle identifier
 * @chinese 为指定的Bundle Identifier生成证书密钥
 *
 * @param bundleID
 * EN: Bundle identifier to generate license for
 * CN: 用于生成证书的Bundle Identifier
 * 
 * @return 
 * EN: Generated license key for the specified bundle identifier
 * CN: 为指定Bundle Identifier生成的证书密钥
 */
+ (NSString *)generateLicenseKeyForBundleID:(NSString *)bundleID;

@end

NS_ASSUME_NONNULL_END
