/**
 * 图片生成任务错误码枚举
 */
typedef NS_ENUM(NSInteger, AIGCErrorCode) {
    /// 未授权访问
    AIGCErrorUnauthorized    = 401,
    /// 调用次数或资源超出配额限制
    AIGCErrorQuotaExceeded   = 4001,
    /// 无效的参数（如宽高非法）
    AIGCErrorInvalidParam    = -1,
    /// 网络连接失败
    AIGCErrorNetworkFailure  = -2,
    /// 任务已被取消
    AIGCErrorTaskCanceled    = -3,
    /// 查询任务状态超时
    AIGCErrorQueryTimeout    = -4,
    /// 未知错误
    AIGCErrorUnknown         = 9000
};
