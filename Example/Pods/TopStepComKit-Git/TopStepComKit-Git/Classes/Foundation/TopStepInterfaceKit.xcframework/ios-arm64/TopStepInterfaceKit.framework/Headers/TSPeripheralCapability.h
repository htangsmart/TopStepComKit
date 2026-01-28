//
//  TSPeripheralCapability.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2025/3/17.
//

#import <Foundation/Foundation.h>
#import "TSFeatureAbility.h"
#import "TSMessageAbility.h"
#import "TSDailyActivityAbility.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Device capability container
 * @chinese 设备能力容器
 *
 * @discussion
 * [EN]: This class serves as a container that composes different capability modules
 *       of a peripheral device. It follows the Composition Pattern and organizes
 *       device capabilities into distinct, manageable modules:
 *       
 *       - featureAbility: Coarse-grained feature module support flags (YES/NO)
 *       - messageAbility: Fine-grained message type support details (which types)
 *       - dailyActivityAbility: Fine-grained daily activity type support (which types)
 *       
 *       This design provides clear separation of concerns and makes capability
 *       management more modular, maintainable, and extensible.
 * 
 * [CN]: 此类作为组合外设设备不同能力模块的容器。
 *       遵循组合模式，将设备能力组织为独立、可管理的模块：
 *       
 *       - featureAbility：粗粒度的功能模块支持标志（是/否）
 *       - messageAbility：细粒度的消息类型支持详情（支持哪些类型）
 *       - dailyActivityAbility：细粒度的每日活动类型支持（支持哪些类型）
 *       
 *       这种设计提供了清晰的关注点分离，使能力管理更加模块化、
 *       易于维护和扩展。
 *
 * @note
 * [EN]: This class does NOT contain any capability implementation logic.
 *       It only holds references to capability modules. Each module is
 *       responsible for its own data parsing and capability checking.
 * [CN]: 此类不包含任何能力实现逻辑。
 *       它只持有能力模块的引用。每个模块负责自己的数据解析和能力检查。
 */
@interface TSPeripheralCapability : NSObject

#pragma mark - Capability Modules

/**
 * @brief Feature module ability (coarse-grained capability flags)
 * @chinese 功能模块能力（粗粒度能力标志）
 *
 * @discussion
 * [EN]: Manages which major feature modules are supported by the device.
 *       Use this to check if a feature category is available (YES/NO).
 *       Examples: heart rate monitoring, sleep tracking, app notifications, etc.
 * 
 * [CN]: 管理设备支持哪些主要功能模块。
 *       使用此属性检查功能类别是否可用（是/否）。
 *       例如：心率监测、睡眠跟踪、应用通知等。
 */
@property (nonatomic, strong) TSFeatureAbility *featureAbility;

/**
 * @brief Message notification ability (fine-grained message type support)
 * @chinese 消息通知能力（细粒度消息类型支持）
 *
 * @discussion
 * [EN]: Manages which specific message types are supported.
 *       Only valid when featureAbility indicates AppNotifications is supported.
 *       May be nil if the platform doesn't provide this detailed information.
 *       Examples: SMS, WeChat, QQ, Facebook, etc.
 * 
 * [CN]: 管理支持哪些具体的消息类型。
 *       仅当 featureAbility 指示支持应用通知时有效。
 *       如果平台不提供此详细信息，可能为 nil。
 *       例如：SMS、微信、QQ、Facebook 等。
 *
 * @note
 * [EN]: Not all platforms provide detailed message type support.
 * [CN]: 并非所有平台都提供详细的消息类型支持信息。
 */
@property (nonatomic, strong, nullable) TSMessageAbility *messageAbility;

/**
 * @brief Daily activity ability (fine-grained activity type support)
 * @chinese 每日活动能力（细粒度活动类型支持）
 *
 * @discussion
 * [EN]: Manages which daily activity types are supported and displayed.
 *       Only valid when featureAbility indicates DailyActivity is supported.
 *       Typically contains up to 3 types shown in the main interface rings.
 *       Examples: steps, exercise duration, activity count, distance, calories.
 * 
 * [CN]: 管理支持并显示哪些每日活动类型。
 *       仅当 featureAbility 指示支持每日活动时有效。
 *       通常包含最多3个在主界面三环中显示的类型。
 *       例如：步数、锻炼时长、活动次数、距离、卡路里。
 */
@property (nonatomic, strong,nullable) TSDailyActivityAbility *dailyActivityAbility;

#pragma mark - Initialization

/**
 * @brief Initialize with default empty capabilities
 * @chinese 使用默认空能力初始化
 *
 * @return 
 * EN: Initialized instance with default capability modules
 * CN: 初始化的实例，包含默认的能力模块
 *
 * @discussion
 * [EN]: Creates a new instance with default initialized capability modules:
 *       - featureAbility: initialized with no features supported
 *       - messageAbility: nil (no message support)
 *       - dailyActivityAbility: initialized with default types [1, 2, 3]
 * [CN]: 创建一个包含默认初始化能力模块的新实例：
 *       - featureAbility：初始化为不支持任何功能
 *       - messageAbility：nil（无消息支持）
 *       - dailyActivityAbility：初始化为默认类型 [1, 2, 3]
 */
- (instancetype)init;

/**
 * @brief Initialize with specific capability modules
 * @chinese 使用指定的能力模块初始化
 *
 * @param featureAbility 
 * EN: Feature module ability object (required)
 * CN: 功能模块能力对象（必需）
 *
 * @param messageAbility 
 * EN: Message ability object (optional, can be nil)
 * CN: 消息能力对象（可选，可以为 nil）
 *
 * @param activityAbility (optional, can be nil)
 * EN: Daily activity ability object (required)
 * CN: 每日活动能力对象（可以为 nil）
 *
 * @return 
 * EN: Initialized instance
 * CN: 初始化的实例
 *
 * @discussion
 * [EN]: This is the designated initializer. Creates a capability container
 *       with the specified capability modules. Each module manages its own
 *       support details independently.
 * [CN]: 这是指定的初始化方法。使用指定的能力模块创建能力容器。
 *       每个模块独立管理自己的支持详情。
 */
- (instancetype)initWithFeatureAbility:(TSFeatureAbility *)featureAbility
                        messageAbility:(nullable TSMessageAbility *)messageAbility
                       activityAbility:(nullable TSDailyActivityAbility *)activityAbility NS_DESIGNATED_INITIALIZER;

#pragma mark - Factory Methods

/**
 * @brief Create instance with specific capability modules
 * @chinese 使用指定的能力模块创建实例
 *
 * @param featureAbility 
 * EN: Feature module ability object
 * CN: 功能模块能力对象
 *
 * @param messageAbility 
 * EN: Message ability object (can be nil)
 * CN: 消息能力对象（可以为 nil）
 *
 * @param activityAbility  (can be nil)
 * EN: Daily activity ability object
 * CN: 每日活动能力对象（可以为 nil）
 *
 * @return 
 * EN: New instance
 * CN: 新实例
 */
+ (instancetype)capabilityWithFeatureAbility:(TSFeatureAbility *)featureAbility
                              messageAbility:(nullable TSMessageAbility *)messageAbility
                             activityAbility:(nullable TSDailyActivityAbility *)activityAbility;

@end

NS_ASSUME_NONNULL_END
