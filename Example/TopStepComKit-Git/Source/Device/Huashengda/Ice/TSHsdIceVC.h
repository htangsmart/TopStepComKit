//
//  TSHsdIceVC.h
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/9/22.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSHsdBaseVC.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief ICE labels page
 * @chinese ICE 紧急标签（bit28 · 0x59 只写）：手表预览 + 3 条字节计数输入 + 只写说明条；发送后本地缓存，可原样重发
 *
 * @discussion
 * [CN]: 三行全空或任一行超限时禁用发送（SDK 对空数组返回 TSERROR_INVALID_PARAM，协议无清空指令）。
 */
@interface TSHsdIceVC : TSHsdBaseVC

@end

NS_ASSUME_NONNULL_END
