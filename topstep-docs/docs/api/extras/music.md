---
sidebar_position: 1
title: 音乐控制
---

# 音乐控制（TSMusic）

TopStepComKit iOS SDK 中的音乐控制模块提供了完整的手表设备音乐管理功能。通过该模块，您可以获取设备上的音乐列表、向设备推送音乐、删除音乐以及管理音乐推送操作。

## 前提条件

1. 已初始化 TopStepComKit SDK
2. 已与手表设备配对并建立连接
3. 手表设备支持音乐管理功能
4. 推送音乐时，音乐文件必须存在且格式有效

## 数据模型

### TSMusicModel

| 属性 | 类型 | 说明 |
|-----|------|------|
| `musicId` | `NSString *` | 音乐标识符，用于在设备上唯一识别音乐曲目 |
| `filePath` | `NSString *` | 音乐文件的本地文件路径，推送音乐时必须指定 |
| `title` | `NSString *` | 音乐标题，最大长度 64 字节，用于在手表设备上显示 |
| `artist` | `NSString *` | 艺术家或表演者名称，最大长度 64 字节，用于在手表设备上显示 |
| `duration` | `NSTimeInterval` | 音乐总时长（秒），用于计算播放进度和显示剩余时间 |
| `currentTime` | `NSTimeInterval` | 当前播放位置（秒），范围 0 到 duration |
| `playbackStatus` | `TSMusicPlaybackStatus` | 音乐播放状态，可以是停止、播放中或暂停 |

## 枚举与常量

### TSMusicPlaybackStatus

| 枚举值 | 数值 | 说明 |
|-------|------|------|
| `TSMusicPlaybackStatusStopped` | 0 | 音乐已停止 |
| `TSMusicPlaybackStatusPlaying` | 1 | 音乐正在播放中 |
| `TSMusicPlaybackStatusPaused` | 2 | 音乐已暂停 |

## 回调类型

| 回调类型 | 签名 | 说明 |
|---------|------|------|
| `TSMusicListBlock` | `void (^)(NSArray<TSMusicModel *> *_Nullable musics, NSError *_Nullable error)` | 音乐列表获取回调，返回音乐模型数组或错误信息 |
| `TSFileTransferProgressBlock` | 文件传输进度回调 | 在文件传输过程中多次调用，返回传输进度（0-100） |
| `TSFileTransferSuccessBlock` | 文件传输成功回调 | 文件传输成功完成时调用 |
| `TSFileTransferFailureBlock` | 文件传输失败回调 | 文件传输失败或被取消时调用 |
| `TSCompletionBlock` | `void (^)(BOOL success, NSError *_Nullable error)` | 通用完成回调，返回操作是否成功及错误信息 |

## 接口方法

### 获取设备上所有音乐列表

```objc
- (void)fetchAllMusics:(nonnull TSMusicListBlock)completion;
```

此方法获取设备上所有当前存储的音乐曲目信息。回调将在主线程执行。如果获取失败或未找到音乐，则返回空数组。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `TSMusicListBlock` | 完成回调，返回所有音乐模型数组或错误信息 |

**代码示例：**

```objc
// 获取设备上的所有音乐列表
id<TSMusicInterface> music = [TopStepComKit sharedInstance].music;
[music fetchAllMusics:^(NSArray<TSMusicModel *> * _Nullable musics, NSError * _Nullable error) {
    if (error) {
        TSLog(@"获取音乐列表失败: %@", error.localizedDescription);
        return;
    }
    TSLog(@"获取到 %lu 首音乐", (unsigned long)musics.count);
    for (TSMusicModel *music in musics) {
        TSLog(@"音乐: %@ - %@", music.title, music.artist);
    }
}];
```

### 从设备删除指定音乐

```objc
- (void)deleteMusic:(TSMusicModel *)music completion:(nullable TSCompletionBlock)completion;
```

此方法从手表设备删除指定的音乐曲目。音乐通过提供的 TSMusicModel 中的 musicId 进行识别。回调将在主线程执行。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `music` | `TSMusicModel *` | 要删除的音乐模型，必须包含有效的 musicId |
| `completion` | `TSCompletionBlock` | 完成回调，返回删除是否成功及错误信息 |

**代码示例：**

```objc
// 删除指定的音乐
id<TSMusicInterface> music = [TopStepComKit sharedInstance].music;
TSMusicModel *musicToDelete = [[TSMusicModel alloc] init];
musicToDelete.musicId = @"music_123";
musicToDelete.title = @"My Song";

[music deleteMusic:musicToDelete completion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"音乐删除成功");
    } else {
        TSLog(@"音乐删除失败: %@", error.localizedDescription);
    }
}];
```

### 向设备推送一首音乐

```objc
- (void)pushMusic:(TSMusicModel *)music
         progress:(nullable TSFileTransferProgressBlock)progress
          success:(nullable TSFileTransferSuccessBlock)success
          failure:(nullable TSFileTransferFailureBlock)failure;
```

此方法将音乐曲目推送到手表设备。filePath 指向的音乐文件必须存在且有效。在推送过程中进度回调会被多次调用。所有回调将在主线程执行。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `music` | `TSMusicModel *` | 要推送的音乐模型，必须包含指向有效音乐文件的 filePath |
| `progress` | `TSFileTransferProgressBlock` | 进度回调，返回当前推送进度（0-100），在推送过程中会多次调用 |
| `success` | `TSFileTransferSuccessBlock` | 成功回调，推送成功完成时调用 |
| `failure` | `TSFileTransferFailureBlock` | 失败回调，推送失败或被取消时调用 |

**代码示例：**

```objc
// 向设备推送音乐
id<TSMusicInterface> music = [TopStepComKit sharedInstance].music;
TSMusicModel *musicToPush = [[TSMusicModel alloc] init];
musicToPush.filePath = @"/path/to/music/file.mp3";
musicToPush.title = @"Amazing Song";
musicToPush.artist = @"Great Artist";
musicToPush.duration = 240; // 4 分钟

[music pushMusic:musicToPush
                 progress:^(NSInteger progress, TSFileTransferStatus status) {
    if (status == eTSFileTransferStatusProgress) {
        TSLog(@"推送进度: %ld%%", (long)progress);
    }
} success:^(TSFileTransferStatus status) {
    TSLog(@"音乐推送成功");
} failure:^(TSFileTransferStatus status, NSError * _Nullable error) {
    TSLog(@"音乐推送失败: %@", error.localizedDescription);
}];
```

### 取消正在推送的音乐

```objc
- (void)cancelPushMusic:(nullable TSCompletionBlock)completion;
```

此方法取消当前正在进行的音乐推送操作。可以在推送过程中任何时候调用，会清理所有临时文件。取消操作可能需要一定时间完成。回调将在主线程执行。

| 参数 | 类型 | 说明 |
|-----|------|------|
| `completion` | `TSCompletionBlock` | 完成回调，返回取消是否成功及错误信息 |

**代码示例：**

```objc
// 取消正在进行的音乐推送
id<TSMusicInterface> music = [TopStepComKit sharedInstance].music;
[music cancelPushMusic:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"音乐推送已取消");
    } else {
        TSLog(@"取消推送失败: %@", error.localizedDescription);
    }
}];
```

## 注意事项

1. 音乐参数必须包含有效的 musicId（用于删除操作）或 filePath（用于推送操作）
2. 推送音乐时，filePath 指向的文件必须存在且可读，支持的音乐格式由设备决定
3. 同时只能有一个音乐推送操作处于活动状态，发起新的推送前应取消旧的推送操作
4. 所有回调都在主线程执行，若需执行耗时操作应切换到后台线程
5. 如果没有正在进行的推送操作，调用 cancelPushMusic: 方法不会有任何效果
6. 音乐标题和艺术家名称的最大长度为 64 字节，超长内容会被截断
7. 如果设备上未找到指定的音乐，删除操作将失败并返回相应错误