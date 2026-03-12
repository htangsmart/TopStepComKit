//
//  TSCardBagInterface.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/5/20.
//

#import "TSKitBaseInterface.h"
#import "TSECardModel.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Card bag interface protocol
 * @chinese 卡片包接口协议
 *
 * @discussion
 * [EN]: This protocol defines the interface for managing electronic cards (e-cards) in the device.
 * It provides methods for getting the maximum number of supported cards, retrieving all cards,
 * and setting a new card.
 * [CN]: 该协议定义了设备中管理电子卡片的接口。提供了获取最大支持卡片数量、获取所有卡片
 * 以及设置新卡片的方法。
 */
@protocol TSECardBagInterface <TSKitBaseInterface>

/**
 * @brief Get the maximum number of cards supported by the device
 * @chinese 获取设备支持的最大卡片数量
 *
 * @return
 * [EN]: The maximum number of cards that can be stored in the device
 * [CN]: 设备可以存储的最大卡片数量
 *
 * @discussion
 * [EN]: This value is determined by the device's hardware capabilities and firmware.
 * [CN]: 该值由设备的硬件能力和固件决定。
 */
- (NSInteger)supportMaxCardsCount;

/**
 * @brief Get the maximum length of card name in bytes
 * @chinese 获取卡片名称的最大字节长度
 *
 * @return
 * [EN]: The maximum number of bytes allowed for a card name
 * [CN]: 卡片名称允许的最大字节数
 *
 * @discussion
 * [EN]: This value is determined by the device's firmware limitations.
 * When setting a card name, ensure it does not exceed this length.
 * [CN]: 该值由设备固件限制决定。设置卡片名称时，确保不超过此长度。
 */
- (NSInteger)supportMaxCardNameLength;

/**
 * @brief Get the maximum length of card URL in bytes
 * @chinese 获取卡片URL的最大字节长度
 *
 * @return
 * [EN]: The maximum number of bytes allowed for a card URL
 * [CN]: 卡片URL允许的最大字节数
 *
 * @discussion
 * [EN]: This value is determined by the device's firmware limitations.
 * When setting a card URL, ensure it does not exceed this length.
 * [CN]: 该值由设备固件限制决定。设置卡片URL时，确保不超过此长度。
 */
- (NSInteger)supportMaxCardURLLength;

/**
 * @brief Get all wallet cards stored in the device
 * @chinese 获取设备中存储的所有电子钱包卡片
 *
 * @param completion
 * [EN]: Completion block that returns an array of all wallet cards and any error that occurred
 * [CN]: 完成回调，返回所有电子钱包卡片数组和可能发生的错误
 *
 * @discussion
 * [EN]: This method retrieves all wallet cards (cards with type between 100-199) currently stored in the device.
 * The completion block will be called with an array of TSECardModel objects if successful,
 * or with an error if the operation fails.
 * [CN]: 该方法获取设备中当前存储的所有电子钱包卡片（类型在100-199之间的卡片）。
 * 如果成功，完成回调将返回TSECardModel对象数组；如果操作失败，将返回错误信息。
 */
- (void)getAllWalletCardsCompletion:(void(^)(NSArray<TSECardModel *>* _Nullable walletCards, NSError * _Nullable error))completion;

/**
 * @brief Get all business cards stored in the device
 * @chinese 获取设备中存储的所有电子名片卡片
 *
 * @param completion
 * [EN]: Completion block that returns an array of all business cards and any error that occurred
 * [CN]: 完成回调，返回所有电子名片卡片数组和可能发生的错误
 *
 * @discussion
 * [EN]: This method retrieves all business cards (cards with type between 1000-1999) currently stored in the device.
 * The completion block will be called with an array of TSECardModel objects if successful,
 * or with an error if the operation fails.
 * [CN]: 该方法获取设备中当前存储的所有电子名片卡片（类型在1000-1999之间的卡片）。
 * 如果成功，完成回调将返回TSECardModel对象数组；如果操作失败，将返回错误信息。
 */
- (void)getAllBusinessCardsCompletion:(void(^)(NSArray<TSECardModel *>* _Nullable businessCards, NSError * _Nullable error))completion;


/**
 * @brief Get all electronic cards stored in the device
 * @chinese 获取设备中存储的所有电子卡片
 *
 * @param completion
 * [EN]: Completion block that returns an array of all e-cards and any error that occurred
 * [CN]: 完成回调，返回所有电子卡片数组和可能发生的错误
 *
 * @discussion
 * [EN]: This method retrieves all e-cards currently stored in the device.
 * The completion block will be called with an array of TSECardModel objects if successful,
 * or with an error if the operation fails.
 * [CN]: 该方法获取设备中当前存储的所有电子卡片。如果成功，完成回调将返回TSECardModel
 * 对象数组；如果操作失败，将返回错误信息。
 */
- (void)getAllECardCompletion:(void(^)(NSArray<TSECardModel *>* _Nullable allECards, NSError * _Nullable error))completion;

/**
 * @brief Set a new electronic card in the device
 * @chinese 在设备中设置新的电子卡片
 *
 * @param eCard
 * [EN]: The e-card model to be set in the device
 * [CN]: 要设置到设备中的电子卡片模型
 *
 * @param completion
 * [EN]: Completion block that indicates whether the operation was successful and any error that occurred
 * [CN]: 完成回调，指示操作是否成功以及可能发生的错误
 *
 * @discussion
 * [EN]: This method attempts to set a new e-card in the device. The completion block will be called
 * with a boolean indicating success or failure, and an error object if the operation failed.
 * If the device has reached its maximum card capacity, the operation will fail.
 * [CN]: 该方法尝试在设备中设置新的电子卡片。完成回调将返回一个布尔值表示成功或失败，
 * 如果操作失败还会返回错误对象。如果设备已达到最大卡片容量，操作将失败。
 */
- (void)setECard:(TSECardModel *)eCard completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Set all electronic cards in the device
 * @chinese 在设备中设置所有电子卡片
 *
 * @param eCards
 * [EN]: Array of e-card models to be set in the device
 * [CN]: 要设置到设备的电子卡片模型数组
 *
 * @param completion
 * [EN]: Completion block that indicates whether the operation was successful and any error that occurred
 * [CN]: 完成回调，指示操作是否成功以及可能发生的错误
 *
 * @discussion
 * [EN]: This method sets all e-cards in the device in one operation. The completion block will be called
 * with a boolean indicating success or failure, and an error object if the operation failed.
 * If the total number of cards exceeds the device's maximum capacity, the operation will fail.
 * This method will first clear all existing cards in the device, then set the new cards.
 * [CN]: 该方法一次性设置所有电子卡片到设备。完成回调将返回一个布尔值表示成功或失败，
 * 如果操作失败还会返回错误对象。如果卡片总数超过设备最大容量，操作将失败。
 * 该方法会先清除设备中所有现有卡片，然后设置新的卡片。
 */
- (void)setAllECards:(NSArray<TSECardModel *> *)eCards completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Delete an electronic card from the device
 * @chinese 从设备中删除电子卡片
 *
 * @param eCard
 * [EN]: The e-card model to be deleted from the device
 * [CN]: 要从设备中删除的电子卡片模型
 *
 * @param completion
 * [EN]: Completion block that indicates whether the operation was successful and any error that occurred
 * [CN]: 完成回调，指示操作是否成功以及可能发生的错误
 *
 * @discussion
 * [EN]: This method attempts to delete an e-card from the device. The completion block will be called
 * with a boolean indicating success or failure, and an error object if the operation failed.
 * If the card does not exist in the device, the operation will fail.
 * [CN]: 该方法尝试从设备中删除电子卡片。完成回调将返回一个布尔值表示成功或失败，
 * 如果操作失败还会返回错误对象。如果卡片在设备中不存在，操作将失败。
 */
- (void)deleteECard:(TSECardModel *)eCard completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Delete multiple electronic cards from the device by their IDs
 * @chinese 根据ID数组批量删除设备中的电子卡片
 *
 * @param cardIds
 * [EN]: Array of card IDs to be deleted
 * [CN]: 要删除的卡片ID数组
 *
 * @param completion
 * [EN]: Completion block that indicates whether the operation was successful and any error that occurred
 * [CN]: 完成回调，指示操作是否成功以及可能发生的错误
 *
 * @discussion
 * [EN]: This method attempts to delete multiple e-cards from the device by their IDs. The completion block
 * will be called with a boolean indicating success or failure, and an error object if the operation failed.
 * If any card ID in the array does not exist in the device, the operation will fail.
 * This method will delete all specified cards in one operation.
 * [CN]: 该方法尝试根据ID数组批量删除设备中的电子卡片。完成回调将返回一个布尔值表示成功或失败，
 * 如果操作失败还会返回错误对象。如果数组中的任何卡片ID在设备中不存在，操作将失败。
 * 该方法将一次性删除所有指定的卡片。
 */
- (void)deleteECardsWithIds:(NSArray<NSNumber *> *)cardIds completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;

/**
 * @brief Sort electronic cards in the device
 * @chinese 对设备中的电子卡片进行排序
 *
 * @param cardIds
 * [EN]: Array of card IDs in the desired order
 * [CN]: 按期望顺序排列的卡片ID数组
 *
 * @param completion
 * [EN]: Completion block that indicates whether the operation was successful and any error that occurred
 * [CN]: 完成回调，指示操作是否成功以及可能发生的错误
 *
 * @discussion
 * [EN]: This method sorts the e-cards in the device according to the provided card ID array.
 * The completion block will be called with a boolean indicating success or failure, and an error
 * object if the operation failed. If any card ID in the array does not exist in the device,
 * the operation will fail. The order of cards in the device will match the order of IDs in the array.
 * [CN]: 该方法根据提供的卡片ID数组对设备中的电子卡片进行排序。完成回调将返回一个布尔值
 * 表示成功或失败，如果操作失败还会返回错误对象。如果数组中的任何卡片ID在设备中不存在，
 * 操作将失败。设备中卡片的顺序将与数组中ID的顺序相匹配。
 */
- (void)sortECardsWithIds:(NSArray<NSNumber *> *)cardIds completion:(void(^)(BOOL isSuccess, NSError * _Nullable error))completion;


@end

NS_ASSUME_NONNULL_END
