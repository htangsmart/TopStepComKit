//
//  MGQPlayMusicManager.h
//  MagicHelper
//
//  Created on 2026/2/4.
//
//  使用说明：
//  【重要】使用前必须先调用 setScheme: 设置 URL Scheme！
//
//  1. 初始化时设置 scheme（必须调用）：
//     [[MGQPlayMusicManager shared] setScheme:@"your-app://qqmusic"];
//
//  2. 直接使用，无需手动注册和连接（全自动）：
//     [[MGQPlayMusicManager shared] searchAndPlay:@"周杰伦 青花瓷" completion:^(BOOL success, QPlayAutoListItem *song, NSError *error) {
//         if (success) {
//             NSLog(@"正在播放：%@", song.Name);
//         }
//     }];
//  3. 播放控制：playPause、playNext、playPrev 等
//  4. 状态监听：通过 block 属性设置回调，如 onPlayStateChanged、onPlayProgressChanged 等
//

#import <Foundation/Foundation.h>
#import "QPlayAutoSDK.h"
#import "QPlayAutoDefine.h"

// 如果编译报错，请确保 QPlayAutoSDK 已正确添加到项目中
typedef NS_ENUM(NSUInteger, QPlayAutoConnectState);
typedef NS_ENUM(NSUInteger, QPlayAutoPlayState);
typedef NS_ENUM(NSUInteger, QPlayAutoPlayMode);

/// MGQPlayMusicManager 本地错误码（从 1000 开始），其它错误见 QPlayAutoDefine -> QPlayAutoError
typedef NS_ENUM(NSInteger, MGQPlayError) {
    MGQPlayError_InvalidKeyword        = 1000,  ///< 搜索关键词不能为空
    MGQPlayError_ConnectFailed         = 1001,  ///< 连接失败
    MGQPlayError_RegisterFailed        = 1002,  ///< 注册失败
    MGQPlayError_PlayIndexOutOfRange   = 1003,  ///< 播放索引超出范围
    MGQPlayError_ConnectTimeout        = 1004,  ///< 连接超时
    MGQPlayError_QQMusicNotInstalled   = 1005,  ///< 未检测到QQ音乐
};

NS_ASSUME_NONNULL_BEGIN

/// QPlayAutoSDK 封装工具类，简化音乐播放接入
@interface MGQPlayMusicManager : NSObject

/// 单例
+ (instancetype)shared;

#pragma mark - 初始化配置

/// 【必须调用】设置 scheme（URL Scheme，用于 QPlay 回调）
/// 在使用任何其他功能之前，必须先调用此方法设置 scheme
/// @param scheme URL Scheme，例如 @"qplayautodemo://qqmusic" 或 @"your-app://qqmusic"
/// @note 如果不调用此方法，将从 Info.plist 读取，但建议显式设置以确保正确
- (void)setScheme:(NSString *)scheme;

#pragma mark - 状态属性

/// 是否已注册
@property (nonatomic, readonly) BOOL isRegistered;

/// 是否已连接
@property (nonatomic, readonly) BOOL isConnected;

/// 是否已安装QQ音乐
@property (nonatomic, readonly) BOOL isQQMusicInstalled;

/// 当前播放的歌曲
@property (nonatomic, readonly, nullable) QPlayAutoListItem *currentSong;

/// 当前播放状态
@property (nonatomic, readonly) QPlayAutoPlayState playState;

/// 当前播放列表
@property (nonatomic, readonly) NSArray<QPlayAutoListItem *> *playingList;

#pragma mark - 连接管理

/// 连接回调
typedef void(^MGQPlayConnectBlock)(BOOL success, NSError * _Nullable error);

/// 连接（自动处理超时和重试）
/// @param timeout 超时时间（秒），默认 60 秒
/// @param completion 连接结果回调
- (void)connectWithTimeout:(NSTimeInterval)timeout completion:(MGQPlayConnectBlock)completion;

/// 连接（使用默认超时时间 60 秒）
- (void)connectWithCompletion:(MGQPlayConnectBlock)completion;

/// 断开连接
- (void)disconnect;

#pragma mark - 搜索与播放

/// 搜索并播放回调
typedef void(^MGQPlaySearchAndPlayBlock)(BOOL success, QPlayAutoListItem * _Nullable song, NSError * _Nullable error);

/// 搜索关键词并播放第一首（最常用场景）
/// @param keyword 搜索关键词（如："周杰伦 青花瓷"）
/// @param completion 结果回调，song 为播放的歌曲信息 错误码见MGQPlayError定义
- (void)searchAndPlay:(NSString *)keyword completion:(MGQPlaySearchAndPlayBlock)completion;

/// 搜索并播放指定索引的歌曲
/// @param keyword 搜索关键词
/// @param playIndex 播放索引（0 为第一首）
/// @param completion 结果回调 错误码见MGQPlayError定义
- (void)searchAndPlay:(NSString *)keyword atIndex:(NSInteger)playIndex completion:(MGQPlaySearchAndPlayBlock)completion;

/// 播放指定歌曲列表
/// @param songList 歌曲列表
/// @param playIndex 播放索引
/// @param completion 结果回调
- (void)playSongList:(NSArray<QPlayAutoListItem *> *)songList atIndex:(NSInteger)playIndex completion:(void(^)(BOOL success, NSInteger errorCode))completion;

#pragma mark - 播放控制

/// 播放/暂停
- (void)playPause;

/// 播放
- (void)play;

/// 播放（带回调）
/// @param completion 结果回调
- (void)playWithCompletion:(void(^)(BOOL success, NSInteger errorCode))completion;

/// 暂停
- (void)pause;

/// 下一首
/// @param completion 结果回调
- (void)playNextWithCompletion:(void(^)(BOOL success, NSInteger errorCode))completion;

/// 上一首
/// @param completion 结果回调
- (void)playPrevWithCompletion:(void(^)(BOOL success, NSInteger errorCode))completion;

/// 跳转到指定位置
/// @param position 位置（秒）
- (void)seekToPosition:(NSInteger)position;

#pragma mark - 状态监听

/// 连接状态变化回调
@property (nonatomic, copy, nullable) void(^onConnectStateChanged)(QPlayAutoConnectState state);

/// 播放状态变化回调
@property (nonatomic, copy, nullable) void(^onPlayStateChanged)(QPlayAutoPlayState state, QPlayAutoListItem * _Nullable song, NSInteger position);

/// 播放进度回调
@property (nonatomic, copy, nullable) void(^onPlayProgressChanged)(QPlayAutoListItem *song, NSTimeInterval progress, NSTimeInterval duration);

/// 播放模式变化回调
@property (nonatomic, copy, nullable) void(^onPlayModeChanged)(QPlayAutoPlayMode mode);

/// 登录状态变化回调
@property (nonatomic, copy, nullable) void(^onLoginStateChanged)(BOOL isLoginOK);

#pragma mark - 其他功能

/// 设置播放模式
/// @param mode 播放模式
/// @param completion 结果回调
- (void)setPlayMode:(QPlayAutoPlayMode)mode completion:(void(^)(BOOL success))completion;

/// 收藏/取消收藏歌曲
/// @param song 歌曲
/// @param isFavorite 是否收藏
/// @param completion 结果回调
- (void)setFavoriteStateWithSong:(QPlayAutoListItem *)song isFavorite:(BOOL)isFavorite completion:(void(^)(BOOL success, NSInteger errorCode))completion;

/// 获取歌词
/// @param song 歌曲
/// @param completion 结果回调
- (void)requestLyricWithSong:(QPlayAutoListItem *)song completion:(void(^)(BOOL success, QPlayAutoLyric * _Nullable lyric))completion;

#pragma mark - 内部方法（服务器返回参数后调用）

/// 设置注册参数
/// 注意：此方法供内部使用
- (void)setRegisterParams:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
