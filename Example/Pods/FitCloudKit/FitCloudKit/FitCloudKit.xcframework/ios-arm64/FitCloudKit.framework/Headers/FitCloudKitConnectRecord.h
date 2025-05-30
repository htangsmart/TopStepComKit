//
//  FitCloudKitConnectRecord.h
//  FitCloudKit
//
//  Created by pcjbird on 2018/8/2.
//  Copyright © 2018年 Zero Status. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A record of watch connection and pairing information
@interface FitCloudKitConnectRecord : NSObject <NSCoding, NSCopying>

/// The name of the watch
@property(nonatomic, strong) NSString *name;

/// Whether it uses next generation manufacturer name
@property(nonatomic, assign) BOOL isNextManufacturerName;

/// Whether to allow simultaneous connection with Bluetooth calling
@property(nonatomic, assign) BOOL allowConnectWithBT;

/// The UUID of the watch
@property(nonatomic, strong, nullable) NSUUID *uuid;

/// The MAC address of the watch. Returns nil if manufacturer has custom advertisement data
@property(nonatomic, strong, nullable) NSString *macAddr;

/// The last connection time
@property(nonatomic, strong) NSDate *lastConnectTime;

/// Whether the watch should automatically reconnect
@property(nonatomic, assign) BOOL shouldAutoReconnect;

/// The bound user ID
@property(nonatomic, strong, nullable) NSString *bindUserId;

/// The time when user binding occurred
@property(nonatomic, strong, nullable) NSDate *userBindTime;

/// Whether the watch has been unbound
@property(nonatomic, assign) BOOL isAlreadyUnbind;

/// The project number
/// - Returns:
/// The project number string, e.g. "51B2"
@property(nonatomic, strong, nullable) NSString *formatedProjNo;

/// Short firmware version
/// - Returns:
/// Short firmware version string, e.g. "1.08"
@property(nonatomic, strong, nullable) NSString *formatedFirmwareVersion;

/// The UI version
@property(nonatomic, strong, nullable) NSString *uiVersion;

/// The screen resolution
@property(nonatomic, strong, nullable) NSValue *screenResolution;

/// The screen shape
/// - 0: Rectangle
/// - 1: Circle
/// - nil: Unknown
@property(nonatomic, strong, nullable) NSNumber *screenShape;

/// The manufacturer data from advertisement data
@property(nonatomic, strong, nullable) NSString *advDataManufacturerData;

/// The advertisement data
@property(nonatomic, strong, nullable) NSString *advData;

@end

NS_ASSUME_NONNULL_END
