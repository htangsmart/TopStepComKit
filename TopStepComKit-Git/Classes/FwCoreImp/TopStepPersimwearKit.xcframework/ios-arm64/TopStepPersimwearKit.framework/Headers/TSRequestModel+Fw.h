//
//  TSRequestModel+Fw.h
//  TopStepPersimwearKit
//
//  Created by 磐石 on 2026/1/20.
//

#import <TopStepInterfaceKit/TopStepInterfaceKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSRequestModel (Fw)

/**
 * @brief Convert JSON message dictionary to TSRequestModel
 * @chinese 将JSON消息字典转换为TSRequestModel
 *
 * @param jsonMsg
 * EN: Dictionary containing request information with keys: url, id, func, appId, params, savePath
 * CN: 包含请求信息的字典，键包括: url, id, func, appId, params, savePath
 *
 * @return
 * EN: Converted TSRequestModel object, nil if conversion fails or input is invalid
 * CN: 转换后的TSRequestModel对象，如果转换失败或输入无效则返回nil
 */
+ (nullable TSRequestModel *)modelWithJsonMsg:(NSDictionary *)jsonMsg;

+ (NSString *)localFilePathWithRemoteFilePath:(NSString *)remoteFilePath;

@end

NS_ASSUME_NONNULL_END
