//
//  WMContactsAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMContactModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMContactsAppModel : NSObject<WMSupportProtocol>

/// 设备端更新联系人列表   （Update the contact list on the device）
@property (nonatomic, strong) RACSignal<NSArray<WMContactModel*> *> *contactList;
/// 设备端删除联系人（序号） （Deleting a contact from a Device (serial number)）
@property (nonatomic, strong) RACSignal<NSNumber *> *dev_delegateContact;
/// 当前联系人列表（设备端、APP修改配置成功时更新数据）（Current contact list (Update data when the device and APP modify the configuration successfully)）
@property (nonatomic, strong, readonly) NSArray<WMContactModel*> *contactListValue;
/// 设备端更新紧急联系人 （RAC 无法设置nil 类型，所以这里用数组。数组为空时表示没有紧急联系人）
/// Update emergency contacts on the device side (RAC cannot set the nil type, so arrays are used here. If the array is empty, there are no emergency contacts)
@property (nonatomic, strong) RACSignal<NSArray<WMEmergencyContactModel *> *> *emergencyContact;
/// 当前紧急联系人（设备端、APP修改配置成功时更新数据）（Current emergency contacts (Update data when the device and APP successfully modify the configuration)）
@property (nonatomic, strong, readonly) WMEmergencyContactModel * _Nullable emergencyContactValue;

/// 获取联系人列表 （Get the contact list）
- (RACSignal<NSArray<WMContactModel*> *> *)wm_getContactList;
/// 获取急联系人列表（RAC 无法设置nil 类型，所以这里用数组。数组为空时表示没有紧急联系人）
/// Get the urgent contact list (RAC cannot set the nil type, so we use arrays here. If the array is empty, there are no emergency contacts)
- (RACSignal<NSArray<WMEmergencyContactModel*> *> *)wm_emergencyContact;

/// 同步联系人列表到设备 （Synchronize the contact list to the device）
/// - Parameter contact: 联系人列表 （Contact list）
- (RACSignal<NSArray<WMContactModel*> *> *)syncContactList:(NSArray<WMContactModel*> *)list;

/// 同步紧急联系人，nil为删除紧急联系人 （RAC 无法设置nil 类型，所以这里用数组。数组为空时表示没有紧急联系人）
/// Sync emergency contacts, nil to delete emergency contacts (RAC cannot set the nil type, so an array is used here. If the array is empty, there are no emergency contacts)
/// - Parameter contact: contact
- (RACSignal<NSArray<WMEmergencyContactModel *> *> *)syncEmergencyContact:(WMEmergencyContactModel * _Nullable)contact;

@end

NS_ASSUME_NONNULL_END
