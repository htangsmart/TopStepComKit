//
//  TopStepContactModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/12.
//
//  文件说明:
//  联系人数据模型，用于管理设备通讯录中的联系人信息，支持基本联系人和紧急联系人功能

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Contact model class
 * @chinese 联系人模型类
 *
 * @discussion
 * EN: This class represents contact information in device address book, including:
 *     1. Contact name
 *     2. Contact phone number
 *     3. Short name for categorization
 *     Used for data transfer and storage of device contacts and emergency contacts.
 *     Supports both regular contacts and emergency contacts management.
 *
 * CN: 该类用于表示设备通讯录中的联系人信息，包括：
 *     1. 联系人姓名
 *     2. 联系人电话号码
 *     3. 用于分类的简称
 *     用于设备通讯录和紧急联系人的数据传输和存储。
 *     支持普通联系人和紧急联系人的管理。
 */
@interface TopStepContactModel : TSKitBaseModel

/**
 * @brief Contact name
 * @chinese 联系人姓名
 *
 * @discussion
 * EN: Display name of the contact.
 *     Requirements:
 *     1. Supports both Chinese and English characters
 *     2. Length must not exceed 32 bytes
 *     3. Cannot be empty
 *     4. Will be used for contact display and search
 *
 * CN: 联系人的显示名称。
 *     要求：
 *     1. 支持中英文字符
 *     2. 长度不得超过32字节
 *     3. 不能为空
 *     4. 用于联系人显示和搜索
 */
@property (nonatomic, copy) NSString *name;

/**
 * @brief Contact phone number
 * @chinese 联系人电话号码
 *
 * @discussion
 * EN: Contact's phone number.
 *     Format requirements:
 *     1. Supports digits and plus sign (+)
 *     2. No spaces or other special characters allowed
 *     3. Length must not exceed 20 bytes
 *     4. Must be a valid phone number format
 *
 * CN: 联系人的电话号码。
 *     格式要求：
 *     1. 支持数字、加号(+)
 *     2. 不包含空格和其他特殊字符
 *     3. 长度不超过20字节
 *     4. 必须是有效的电话号码格式
 */
@property (nonatomic, copy) NSString *phoneNum;

/**
 * @brief Short name for categorization
 * @chinese 分类简称
 *
 * @discussion
 * EN: Short name used for contact categorization.
 *     For example, for contact name "Zhang Teng", the short name would be "Z".
 *     Used for:
 *     1. Contact list indexing
 *     2. Quick search and filtering
 *     3. Alphabetical sorting
 *
 * CN: 用于联系人分类的简称。
 *     例如，联系人"张三"的简称为"Z"。
 *     用途：
 *     1. 联系人列表索引
 *     2. 快速搜索和过滤
 *     3. 字母排序
 */
@property (nonatomic, strong) NSString *shortName;

/**
 * @brief Create contact with name and phone number
 * @chinese 使用姓名和电话号码创建联系人
 *
 * @param name 
 * EN: Contact name, must not be empty and not exceed 32 bytes
 * CN: 联系人姓名，不能为空且不超过32字节
 *
 * @param phoneNum 
 * EN: Contact phone number, must be valid format and not exceed 20 bytes
 * CN: 联系人电话号码，必须是有效格式且不超过20字节
 *
 * @return 
 * EN: Created contact object, nil if parameters are invalid
 * CN: 创建的联系人对象，如果参数无效则返回nil
 *
 * @discussion
 * EN: Factory method to create a contact object.
 *     Will automatically generate shortName based on the provided name.
 * CN: 创建联系人对象的工厂方法。
 *     将根据提供的姓名自动生成shortName。
 */
+ (instancetype)contactWithName:(NSString *)name phoneNum:(NSString *)phoneNum;


/**
 * @brief Create contact with name, phone number and short name
 * @chinese 使用姓名、电话号码和简称创建联系人
 *
 * @param name 
 * EN: Contact name, must not be empty and not exceed 32 bytes
 * CN: 联系人姓名，不能为空且不超过32字节
 *
 * @param phoneNum 
 * EN: Contact phone number, must be valid format and not exceed 20 bytes
 * CN: 联系人电话号码，必须是有效格式且不超过20字节
 *
 * @param shortName 
 * EN: Short name for categorization, usually first letter of name
 * CN: 用于分类的简称，通常是姓名的首字母
 *
 * @return 
 * EN: Created contact object, nil if parameters are invalid
 * CN: 创建的联系人对象，如果参数无效则返回nil
 *
 * @discussion
 * EN: Factory method to create a contact object with custom shortName.
 *     Useful when you need to specify a custom categorization.
 * CN: 使用自定义简称创建联系人对象的工厂方法。
 *     在需要指定自定义分类时使用。
 */
+ (instancetype)contactWithName:(NSString *)name phoneNum:(NSString *)phoneNum shortName:(NSString *)shortName;



@end

NS_ASSUME_NONNULL_END
