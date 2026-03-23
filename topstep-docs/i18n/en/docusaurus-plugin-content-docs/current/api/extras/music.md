---
sidebar_position: 1
title: Music
---

# Music

The Music module provides a complete interface for managing music on the watch device. This includes fetching the music list, pushing music files to the device, deleting music, and controlling music push operations. All operations are designed to work seamlessly with the watch device's music management system and support progress tracking for file transfers.

## Prerequisites

- The watch device must be connected and ready for operations
- For pushing music: the source music file must exist and be readable
- For deleting music: the music must exist on the device with a valid `musicId`
- All callbacks are executed on the main thread

## Data Models

### TSMusicModel

Music information and playback status model for the watch device.

| Property | Type | Description |
|----------|------|-------------|
| `musicId` | `NSString *` | Unique identifier for the music track. Used for identifying and managing music on the watch device. |
| `filePath` | `NSString *` | Local file path of the music file. Required when pushing music to the device. |
| `title` | `NSString *` | Title of the music track (max 64 bytes). Used for display on the watch device. |
| `artist` | `NSString *` | Name of the artist or performer (max 64 bytes). Used for display on the watch device. |
| `duration` | `NSTimeInterval` | Total duration of the music track in seconds. Used for calculating playback progress. |
| `currentTime` | `NSTimeInterval` | Current playback position in seconds. Range: 0 to duration. |
| `playbackStatus` | `TSMusicPlaybackStatus` | Current playback status (stopped, playing, or paused). Default is stopped. |

## Enumerations

### TSMusicPlaybackStatus

Music playback status enumeration.

| Value | Description |
|-------|-------------|
| `TSMusicPlaybackStatusStopped` (0) | Music is stopped |
| `TSMusicPlaybackStatusPlaying` (1) | Music is playing |
| `TSMusicPlaybackStatusPaused` (2) | Music is paused |

## Callback Types

### TSMusicListBlock

Music list callback block type.

```objc
typedef void (^TSMusicListBlock)(NSArray<TSMusicModel *> *_Nullable musics, NSError *_Nullable error);
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `musics` | `NSArray<TSMusicModel *> *` | Array of music models. Empty array if retrieval fails. |
| `error` | `NSError *` | Error information if failed. Nil if successful. |

## API Reference

### Fetch all music list from the device

```objc
- (void)fetchAllMusics:(nonnull TSMusicListBlock)completion;
```

Retrieves information about all music tracks currently stored on the watch device.

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSMusicListBlock` | Completion callback with array of all music models. Called on the main thread. |

**Code Example:**

```objc
id<TSMusicInterface> music = [TopStepComKit sharedInstance].music;
[music fetchAllMusics:^(NSArray<TSMusicModel *> * _Nullable musics, NSError * _Nullable error) {
    if (error) {
        TSLog(@"Failed to fetch musics: %@", error.localizedDescription);
    } else {
        TSLog(@"Fetched %lu musics", (unsigned long)musics.count);
        for (TSMusicModel *music in musics) {
            TSLog(@"Music: %@ by %@", music.title, music.artist);
        }
    }
}];
```

### Delete a specific music from the device

```objc
- (void)deleteMusic:(TSMusicModel *)music completion:(nullable TSCompletionBlock)completion;
```

Deletes a specific music track from the watch device by its musicId.

| Parameter | Type | Description |
|-----------|------|-------------|
| `music` | `TSMusicModel *` | Music model to delete. Must contain valid musicId. |
| `completion` | `TSCompletionBlock` | Completion callback with success status and error information. Called on the main thread. |

**Code Example:**

```objc
TSMusicModel *musicToDelete = [[TSMusicModel alloc] init];
musicToDelete.musicId = @"music_123";

id<TSMusicInterface> music = [TopStepComKit sharedInstance].music;
[music deleteMusic:musicToDelete completion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Music deleted successfully");
    } else {
        TSLog(@"Failed to delete music: %@", error.localizedDescription);
    }
}];
```

### Push a music track to the device

```objc
- (void)pushMusic:(TSMusicModel *)music
         progress:(nullable TSFileTransferProgressBlock)progress
          success:(nullable TSFileTransferSuccessBlock)success
          failure:(nullable TSFileTransferFailureBlock)failure;
```

Pushes a music track to the watch device with progress tracking.

| Parameter | Type | Description |
|-----------|------|-------------|
| `music` | `TSMusicModel *` | Music model to push. Must contain valid filePath pointing to an existing music file. |
| `progress` | `TSFileTransferProgressBlock` | Progress callback returning current push progress (0-100). Called multiple times during transfer. |
| `success` | `TSFileTransferSuccessBlock` | Success callback called when push completes successfully. |
| `failure` | `TSFileTransferFailureBlock` | Failure callback called when push fails or is canceled. |

**Code Example:**

```objc
TSMusicModel *musicModel = [[TSMusicModel alloc] init];
musicModel.filePath = @"/path/to/music/file.mp3";
musicModel.title = @"Song Title";
musicModel.artist = @"Artist Name";
musicModel.duration = 180;

id<TSMusicInterface> music = [TopStepComKit sharedInstance].music;
[music pushMusic:musicModel
                progress:^(NSInteger progress, TSFileTransferStatus status) {
    TSLog(@"Push progress: %ld%% (status: %ld)", (long)progress, (long)status);
}
                 success:^(TSFileTransferStatus status) {
    TSLog(@"Music pushed successfully");
}
                 failure:^(TSFileTransferStatus status, NSError * _Nullable error) {
    TSLog(@"Failed to push music: %@", error.localizedDescription);
}];
```

### Cancel ongoing music push operation

```objc
- (void)cancelPushMusic:(nullable TSCompletionBlock)completion;
```

Cancels the currently ongoing music push operation and cleans up temporary files.

| Parameter | Type | Description |
|-----------|------|-------------|
| `completion` | `TSCompletionBlock` | Completion callback with success status and error information. Called on the main thread. |

**Code Example:**

```objc
id<TSMusicInterface> music = [TopStepComKit sharedInstance].music;
[music cancelPushMusic:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        TSLog(@"Music push canceled successfully");
    } else {
        TSLog(@"Failed to cancel music push: %@", error.localizedDescription);
    }
}];
```

## Important Notes

1. The music parameter must contain a valid `filePath` when pushing music. The file must exist and be readable.

2. The `music` parameter for deletion must contain a valid `musicId` for identification on the device.

3. Only one music push operation can be active at a time. Attempting to push multiple files simultaneously will result in an error.

4. All callbacks are executed on the main thread, allowing safe UI updates without additional synchronization.

5. If no push operation is in progress, calling `cancelPushMusic:completion:` has no effect but will still invoke the completion callback.

6. Progress callbacks during push operations will be called multiple times with TSFileTransferStatus values indicating `eTSFileTransferStatusStart` or `eTSFileTransferStatusProgress`.

7. The music file at `filePath` must be valid and in a format supported by the watch device.

8. Music title and artist properties are limited to 64 bytes maximum for display on the watch device.

9. If music retrieval fails, `fetchAllMusics:` returns an empty array rather than nil, and the error parameter indicates the failure reason.

10. Use `fetchAllMusics:` to verify that music has been successfully deleted from the device after calling `deleteMusic:completion:`.