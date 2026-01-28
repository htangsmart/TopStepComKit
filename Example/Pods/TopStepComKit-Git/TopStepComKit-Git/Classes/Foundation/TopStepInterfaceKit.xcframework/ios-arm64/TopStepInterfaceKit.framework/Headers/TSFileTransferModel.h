//
//  TSFileTransferModel.h
//  TopStepInterfaceKit
//
//  Created by 磐石 on 2025/2/17.
//

#import "TSFileModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief File Transfer model (Semantic wrapper for TSFileModel)
 * @chinese 文件传输模型（TSFileModel的语义包装）
 *
 * @discussion 
 * EN: TSFileTransferModel is now a semantic wrapper around TSFileModel.
 *     It provides no additional functionality beyond TSFileModel.
 *     It is kept for backward compatibility and semantic clarity in file transfer contexts.
 *     
 *     Since TSFileModel already provides all necessary functionality (path and size),
 *     TSFileTransferModel exists primarily for:
 *     1. Backward compatibility with existing code
 *     2. Semantic clarity (makes it clear this is for file transfer operations)
 *     3. Type safety in interfaces (TSFileTransferInterface uses TSFileTransferModel)
 *     
 *     You can use TSFileModel directly in new code, or continue using TSFileTransferModel.
 *     Both are functionally equivalent.
 *     
 * CN: TSFileTransferModel 现在是 TSFileModel 的语义包装。
 *     它不提供 TSFileModel 之外的任何额外功能。
 *     保留此类型是为了向后兼容和在文件传输上下文中的语义清晰。
 *     
 *     由于 TSFileModel 已经提供了所有必要的功能（path 和 size），
 *     TSFileTransferModel 存在的主要原因是：
 *     1. 与现有代码的向后兼容
 *     2. 语义清晰（明确表示这是用于文件传输操作）
 *     3. 接口中的类型安全（TSFileTransferInterface 使用 TSFileTransferModel）
 *     
 *     您可以在新代码中直接使用 TSFileModel，或继续使用 TSFileTransferModel。
 *     两者在功能上完全等价。
 */
@interface TSFileTransferModel : TSFileModel

/**
 * @brief Local file path for file transfer (deprecated, use path property instead)
 * @chinese 文件传输的本地文件路径（已废弃，请使用path属性）
 *
 * @discussion 
 * EN: This property is kept for backward compatibility.
 *     It automatically maps to the inherited 'path' property.
 *     It is recommended to use the 'path' property directly.
 * CN: 此属性保留用于向后兼容。
 *     它会自动映射到继承的'path'属性。
 *     建议直接使用'path'属性。
 */
@property (nonatomic, copy) NSString *localFilePath;

/**
 * @brief Create a file transfer model with local file path
 * @chinese 使用本地文件路径创建模型
 * 
 * @param localFilePath 
 * EN: Local file path for file transfer
 * CN: 文件传输的本地文件路径
 *
 * @return 
 * EN: A new file transfer model instance
 * CN: 新的文件传输模型实例
 */
+ (instancetype)modelWithLocalFilePath:(NSString *)localFilePath;

@end

NS_ASSUME_NONNULL_END
