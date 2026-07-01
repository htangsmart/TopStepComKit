//
//  TSEqualizerModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2026/4/28.
//

#import "TSKitBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Equalizer type
 * @chinese 均衡器类型
 */
typedef NS_ENUM(NSUInteger, TSEqualizerType) {
    TSEqualizerTypePreset = 0,    ///< 预设均衡器
    TSEqualizerTypeCustom         ///< 自定义均衡器
};

/**
 * @brief Equalizer preset type
 * @chinese 均衡器预设类型
 */
typedef NS_ENUM(NSUInteger, TSEqualizerPresetType) {
    TSEqualizerPresetTypeUnknown = 0,   ///< 未知预设
    TSEqualizerPresetTypeDefault,       ///< 默认
    TSEqualizerPresetTypePop,           ///< 流行
    TSEqualizerPresetTypeRock,          ///< 摇滚
    TSEqualizerPresetTypeJazz,          ///< 爵士
    TSEqualizerPresetTypeClassical,     ///< 古典
    TSEqualizerPresetTypeCountry        ///< 乡村
};

/**
 * @brief Equalizer model
 * @chinese 均衡器模型
 *
 * @discussion
 * EN: This model describes the current equalizer configuration of the device,
 *     including preset/custom type, preset style, gain array and display name.
 * CN: 此模型描述设备当前的均衡器配置，包含预设/自定义类型、预设风格、增益数组和显示名称。
 */
@interface TSEqualizerModel : TSKitBaseModel

/**
 * @brief Equalizer type
 * @chinese 均衡器类型
 *
 * @discussion
 * EN: Distinguishes whether the equalizer comes from a built-in preset or a custom configuration.
 * CN: 用于区分当前均衡器是内置预设还是自定义配置。
 */
@property (nonatomic, assign) TSEqualizerType equalizerType;

/**
 * @brief Equalizer preset type
 * @chinese 均衡器预设类型
 *
 * @discussion
 * EN: Valid when equalizerType is preset. Use Unknown for custom equalizers.
 * CN: 在预设均衡器场景下有效，自定义均衡器建议使用 Unknown。
 */
@property (nonatomic, assign) TSEqualizerPresetType presetType;

/**
 * @brief Equalizer gain values
 * @chinese 均衡器增益数组
 *
 * @discussion
 * EN: Gain values for each frequency band. The array index represents the band order.
 * CN: 每个频段的增益值数组，数组下标表示频段顺序。
 */
@property (nonatomic, copy) NSArray<NSNumber *> *gainValues;

/**
 * @brief Equalizer name
 * @chinese 均衡器名称
 *
 * @discussion
 * EN: English or internal identifier name, such as Default, Pop, Rock.
 * CN: 英文或内部标识名称，例如 Default、Pop、Rock。
 */
@property (nonatomic, copy) NSString *name;

/**
 * @brief Equalizer Chinese name
 * @chinese 均衡器中文名称
 *
 * @discussion
 * EN: Localized Chinese display name.
 * CN: 中文展示名称。
 */
@property (nonatomic, copy) NSString *chineseName;

@end

NS_ASSUME_NONNULL_END
