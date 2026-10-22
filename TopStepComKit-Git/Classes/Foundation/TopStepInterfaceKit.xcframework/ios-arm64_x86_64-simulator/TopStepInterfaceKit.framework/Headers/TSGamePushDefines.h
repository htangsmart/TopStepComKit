//
//  TSGamePushDefines.h
//  TopStepInterfaceKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TSGameModel;
@class TSGameSlotModel;
@class TSStorageSpace;

/**
 * @brief Public game identifiers shared with the device protocol.
 * @chinese 公版游戏类型，与设备协议使用相同数值。
 *
 * @discussion
 * [EN]: Values 0–24 cover the 25 games in the confirmed public protocol table.
 *       Device support is determined by the queried list, not by this enum.
 *       Preserve future unnamed values; never use the last enum value as the
 *       upper bound of a device-supported list. Zero is a valid game.
 * [CN]: 编号 0–24 对应已确认公版类型表中的 25 种游戏。
 *       设备实际支持范围以查询结果为准；未来未命名类型必须保留原值，
 *       不能按枚举末值限制设备支持列表。
 *       0 是合法游戏类型，不能作为未知或空槽标记。
 */
typedef NS_ENUM(NSInteger, TSGameType) {
    /**
     * @brief Pet raising.
     * @chinese 宠物养成。
     */
    TSGameTypePetRaising = 0,
    /**
     * @brief 2048 number merge.
     * @chinese 2048 数字合并。
     */
    TSGameTypeNumberMerge = 1,
    /**
     * @brief Candy matching.
     * @chinese 糖果消消乐。
     */
    TSGameTypeCandy = 2,
    /**
     * @brief Picture puzzle.
     * @chinese 拼图。
     */
    TSGameTypePicturePuzzle = 3,
    /**
     * @brief Plane shooting.
     * @chinese 飞机。
     */
    TSGameTypePlane = 4,
    /**
     * @brief Car racing.
     * @chinese 赛车。
     */
    TSGameTypeRacingCar = 5,
    /**
     * @brief Maze exploration.
     * @chinese 迷宫。
     */
    TSGameTypeMaze = 6,
    /**
     * @brief Basketball shooting.
     * @chinese 篮球。
     */
    TSGameTypeBasketball = 7,
    /**
     * @brief Arithmetic practice.
     * @chinese 算数题。
     */
    TSGameTypeArithmetic = 8,
    /**
     * @brief Tetris.
     * @chinese 俄罗斯方块。
     */
    TSGameTypeTetris = 9,
    /**
     * @brief Sudoku.
     * @chinese 数独。
     */
    TSGameTypeSudoku = 10,
    /**
     * @brief Quiz challenge.
     * @chinese 答题。
     */
    TSGameTypeQuiz = 11,
    /**
     * @brief Jump.
     * @chinese 跳一跳。
     */
    TSGameTypeJump = 12,
    /**
     * @brief Stacking.
     * @chinese 堆堆乐。
     */
    TSGameTypeStacking = 13,
    /**
     * @brief Link matching.
     * @chinese 连一连。
     */
    TSGameTypeLinkMatching = 14,
    /**
     * @brief Snake.
     * @chinese 贪吃蛇。
     */
    TSGameTypeSnake = 15,
    /**
     * @brief Twenty-four points.
     * @chinese 24点。
     */
    TSGameTypeTwentyFourPoints = 16,
    /**
     * @brief Candy jump.
     * @chinese 糖果跳跳。
     */
    TSGameTypeCandyJump = 17,
    /**
     * @brief Ball breakout.
     * @chinese 弹球突破。
     */
    TSGameTypeBallBreakout = 18,
    /**
     * @brief Three-point shootout.
     * @chinese 3分投篮。
     */
    TSGameTypeThreePointShootout = 19,
    /**
     * @brief Soccer target.
     * @chinese 足球靶子。
     */
    TSGameTypeSoccerTarget = 20,
    /**
     * @brief Cute blocks.
     * @chinese 可爱方块。
     */
    TSGameTypeCuteBlocks = 21,
    /**
     * @brief Five in a row.
     * @chinese 五子连珠。
     */
    TSGameTypeFiveInARow = 22,
    /**
     * @brief Bird shooting.
     * @chinese 打小鸟。
     */
    TSGameTypeBirdShooting = 23,
    /**
     * @brief Colorful space bricks.
     * @chinese 五彩太空砖。
     */
    TSGameTypeColorfulSpaceBricks = 24,
};

/**
 * @brief Game storage query callback.
 * @chinese 游戏空间查询回调。
 *
 * @param storage
 * EN: Storage on success, nil on failure.
 * CN: 成功时为空间模型，失败时为 nil。
 *
 * @param error
 * EN: Failure reason, nil on success.
 * CN: 失败原因，成功时为 nil。
 */
typedef void (^TSGameStorageCompletionBlock)(
    TSStorageSpace * _Nullable storage, NSError * _Nullable error);

/**
 * @brief Game slot query callback.
 * @chinese 游戏槽位查询回调。
 *
 * @param slots
 * EN: Ordered slots; an empty array is a valid success result.
 * CN: 有序槽位数组，空数组为合法成功结果。
 *
 * @param error
 * EN: Failure reason; slots is nil on failure.
 * CN: 失败原因，失败时 slots 为 nil。
 */
typedef void (^TSGameSlotsCompletionBlock)(
    NSArray<TSGameSlotModel *> * _Nullable slots, NSError * _Nullable error);

/**
 * @brief Supported game type query callback.
 * @chinese 支持游戏类型查询回调。
 *
 * @param types
 * EN: Original integer identifiers, including unnamed values.
 * CN: 原始整数类型，包括未命名值。
 *
 * @param error
 * EN: Failure reason; types is nil on failure.
 * CN: 失败原因，失败时 types 为 nil。
 */
typedef void (^TSGameTypesCompletionBlock)(
    NSArray<NSNumber *> * _Nullable types, NSError * _Nullable error);

/**
 * @brief Installed game query callback.
 * @chinese 已安装游戏查询回调。
 *
 * @param games
 * EN: Ordered games; duplicates and skin information are preserved.
 * CN: 有序游戏数组，保留重复条目和皮肤信息。
 *
 * @param error
 * EN: Failure reason; games is nil on failure.
 * CN: 失败原因，失败时 games 为 nil。
 */
typedef void (^TSInstalledGamesCompletionBlock)(
    NSArray<TSGameModel *> * _Nullable games, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
