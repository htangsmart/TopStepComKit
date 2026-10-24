//
//  TSDialEditorState.m
//  TopStepComKit_Example
//

#import "TSDialEditorState.h"
#import <ImageIO/ImageIO.h>

// 模板导入错误；与现有草稿保存、编辑器错误码区分。
typedef NS_ENUM(NSInteger, TSDialEditorTemplateErrorCode) {
    TSDialEditorTemplateErrorInvalidFile = 1003
};

@implementation TSDialEditorState

#pragma mark - 生命周期

// 默认会话值与原型一致。
- (instancetype)init {
    self = [super init];
    if (self) {
        _images = @[[self.class backgrounds].firstObject];
        _textItems = @[[self.class defaultText]];
        _timeColor = @"FFFFFF";
        _timeStyle = eTSDialTimeStyleNone;
        _timePosition = eTSDialTimePositionTop;
        _showsTime = YES;
        _interval = 5;
        _videoAudioSelection = TSDialEditorVideoAudioSelectionAutomatic;
        _videoName = @"请选择本机视频";
    }
    return self;
}

#pragma mark - 公开方法

// 只列出真实落盘记录，默认背景不算草稿。
+ (NSArray<NSNumber *> *)savedDraftTypes {
    NSMutableArray<NSNumber *> *types = [NSMutableArray array];
    for (NSInteger type = TSDialDraftTypeSingleImage; type <= TSDialDraftTypeDanMu; type++) {
        NSURL *url = [[self storageURL] URLByAppendingPathComponent:
                      [NSString stringWithFormat:@"draft-%ld.plist", (long)type]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            [types addObject:@(type)];
        }
    }
    return types;
}

// 草稿列表只解码第一张背景的缩略图，不恢复全部原图与视频。
+ (UIImage *)savedThumbnailForType:(TSDialDraftType)type {
    if (type == TSDialDraftTypeVideo) {
        // 视频会话的 images 是编辑占位背景，不能作为实际视频缩略图。
        return nil;
    }
    NSURL *url = [[self storageURL] URLByAppendingPathComponent:
                  [NSString stringWithFormat:@"draft-%ld.plist", (long)type]];
    NSDictionary *saved = [NSDictionary dictionaryWithContentsOfURL:url];
    NSArray *images = [saved[@"images"] isKindOfClass:NSArray.class] ? saved[@"images"] : nil;
    NSDictionary *record = [images.firstObject isKindOfClass:NSDictionary.class] ? images.firstObject : nil;
    NSData *data = [record[@"image"] isKindOfClass:NSData.class] ? record[@"image"] : nil;
    if (!data) {
        return nil;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (!source) {
        return nil;
    }
    NSDictionary *options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways:@YES,
                              (NSString *)kCGImageSourceCreateThumbnailWithTransform:@YES,
                              (NSString *)kCGImageSourceThumbnailMaxPixelSize:@320};
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)options);
    UIImage *image = thumbnail ? [UIImage imageWithCGImage:thumbnail] : nil;
    if (thumbnail) {
        CGImageRelease(thumbnail);
    }
    CFRelease(source);
    return image;
}

// 从本机恢复完整草稿，不把浏览器临时资源限制带入原生页面。
+ (instancetype)stateForType:(TSDialDraftType)type {
    TSDialEditorState *state = [[self alloc] init];
    state->_draftType = type;
    NSArray *backgrounds = [self backgrounds];
    if (type == TSDialDraftTypeMultipleImage) {
        state.images = @[backgrounds[0], backgrounds[2], backgrounds[1]];
    } else if (type == TSDialDraftTypeDanMu) {
        state.images = @[backgrounds[3]];
    } else if (type == TSDialDraftTypeVideo) {
        state.images = @[backgrounds[2]];
    }
    NSDictionary *saved = [NSDictionary dictionaryWithContentsOfURL:[state saveURL]];
    NSInteger version = [saved[@"version"] integerValue];
    if (version != 1 && version != 2) {
        return state;
    }
    NSMutableArray *images = [NSMutableArray array];
    for (NSDictionary *record in saved[@"images"]) {
        UIImage *image = [UIImage imageWithData:record[@"image"]];
        UIImage *source = [UIImage imageWithData:record[@"source"]];
        if (image && source) {
            NSMutableDictionary *restored = [@{@"name":record[@"name"] ?: @"照片", @"image":image, @"source":source,
                @"crop":record[@"crop"] ?: NSStringFromCGRect(CGRectZero)} mutableCopy];
            for (NSString *key in @[@"videoCanvasSize", @"videoCanvasShape", @"videoCanvasRadius"]) {
                if (record[key]) { restored[key] = record[key]; }
            }
            [images addObject:restored];
        }
    }
    if (images.count) {
        state.images = images;
    }
    state.selectedImage = MIN([saved[@"selectedImage"] unsignedIntegerValue], state.images.count - 1);
    state.timeStyle = [saved[@"timeStyle"] integerValue];
    state.timePosition = [saved[@"timePosition"] integerValue];
    state.timeColor = saved[@"timeColor"] ?: @"FFFFFF";
    state.customTimeColor = [saved[@"customTimeColor"] boolValue];
    state.showsTime = saved[@"showsTime"] ? [saved[@"showsTime"] boolValue] : YES;
    state.interval = [@[@3, @5, @10] containsObject:saved[@"interval"]] ? [saved[@"interval"] integerValue] : 5;
    state.quality = [saved[@"quality"] integerValue];
    // v1 使用旧 SDK 枚举值；只迁移已知的三个值，不把未知值当保留音轨。
    NSInteger audioSelection = [saved[version == 1 ? @"videoAudioPolicy" : @"videoAudioSelection"] integerValue];
    state.videoAudioSelection = audioSelection >= TSDialEditorVideoAudioSelectionAutomatic &&
        audioSelection <= TSDialEditorVideoAudioSelectionPreserveFirstTrack
        ? audioSelection : TSDialEditorVideoAudioSelectionAutomatic;
    state.screenSize = CGSizeFromString(saved[@"screenSize"] ?: @"{0,0}");
    NSString *templateFileName = [saved[@"templateFileName"] isKindOfClass:NSString.class] ? saved[@"templateFileName"] : nil;
    if (templateFileName.length && [templateFileName isEqualToString:templateFileName.lastPathComponent] &&
        ![templateFileName isEqualToString:@".."] && ![templateFileName isEqualToString:@"."]) {
        state.templateFileURL = [[[self storageURL] URLByAppendingPathComponent:@"Media" isDirectory:YES]
                                 URLByAppendingPathComponent:templateFileName];
        state.templateName = [saved[@"templateName"] isKindOfClass:NSString.class] ? saved[@"templateName"] : templateFileName;
    }
    if ([saved[@"textItems"] isKindOfClass:NSArray.class] && [saved[@"textItems"] count] > 0) {
        state.textItems = saved[@"textItems"];
    }
    // v1 的 videoPath 一直是导入源文件；v2 显式区分源素材，不恢复安装临时成品。
    NSString *videoPath = version == 1 ? saved[@"videoPath"] :
        ([saved[@"videoContentKind"] isEqual:@"source"] ? saved[@"sourceVideoPath"] : nil);
    if (videoPath.length && [[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        state.videoURL = [NSURL fileURLWithPath:videoPath];
        state.videoName = saved[@"videoName"] ?: @"本机视频";
        state.videoDuration = [saved[@"videoDuration"] doubleValue];
        state.videoStart = [saved[@"videoStart"] doubleValue];
        state.videoEnd = [saved[@"videoEnd"] doubleValue];
    }
    return state;
}

// 每条弹幕独立保留可编辑字段。
+ (NSDictionary *)defaultText {
    return @{@"text":@"把日子过成喜欢的样子", @"color":@"F4F6C3", @"size":@22,
             @"speed":@60, @"position":@62, @"right":@NO};
}

// 原型中的六组风景直接来自同一 SVG。
+ (NSArray<NSDictionary *> *)backgrounds {
    NSArray *names = @[@"山间晨雾", @"落日旷野", @"蓝调时刻", @"松林深处", @"暮色山谷", @"金色沙丘"];
    NSArray *resources = @[@"morning", @"sunset", @"blue", @"forest", @"dusk", @"sand"];
    NSMutableArray *backgrounds = [NSMutableArray array];
    for (NSUInteger index = 0; index < names.count; index++) {
        UIImage *image = [UIImage imageNamed:[@"ts_dial_" stringByAppendingString:resources[index]]];
        if (image) {
            [backgrounds addObject:@{@"name":names[index], @"image":image, @"source":image,
                                    @"crop":NSStringFromCGRect(CGRectZero)}];
        }
    }
    return backgrounds;
}

// 先序列化完整快照，再原子替换旧文件。
- (BOOL)saveWithError:(NSError **)error {
    NSMutableArray *images = [NSMutableArray array];
    for (NSDictionary *record in self.images) {
        NSData *image = UIImagePNGRepresentation(record[@"image"]);
        NSData *source = UIImageJPEGRepresentation(record[@"source"], 0.95);
        if (!image || !source) {
            if (error) {
                *error = [NSError errorWithDomain:@"TSDialEditorErrorDomain" code:1001
                                        userInfo:@{NSLocalizedDescriptionKey:@"照片保存失败，原草稿已保留"}];
            }
            return NO;
        }
        NSMutableDictionary *saved = [@{@"name":record[@"name"], @"image":image, @"source":source,
            @"crop":record[@"crop"] ?: NSStringFromCGRect(CGRectZero)} mutableCopy];
        for (NSString *key in @[@"videoCanvasSize", @"videoCanvasShape", @"videoCanvasRadius"]) {
            if (record[key]) { saved[key] = record[key]; }
        }
        [images addObject:saved];
    }
    NSDictionary *snapshot = @{
        @"version":@2, @"images":images, @"selectedImage":@(self.selectedImage),
        @"textItems":self.textItems, @"timeStyle":@(self.timeStyle), @"timePosition":@(self.timePosition),
        @"timeColor":self.timeColor, @"customTimeColor":@(self.customTimeColor), @"showsTime":@(self.showsTime),
        @"interval":@(self.interval), @"sourceVideoPath":self.videoURL.path ?: @"", @"videoName":self.videoName,
        @"videoContentKind":@"source",
        @"quality":@(self.quality), @"videoAudioSelection":@(self.videoAudioSelection),
        @"templateFileName":self.templateFileURL.lastPathComponent ?: @"", @"templateName":self.templateName ?: @"",
        @"videoDuration":@(self.videoDuration), @"videoStart":@(self.videoStart), @"videoEnd":@(self.videoEnd),
        @"screenSize":NSStringFromCGSize(self.screenSize)
    };
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:snapshot
                                                            format:NSPropertyListBinaryFormat_v1_0 options:0 error:error];
    NSURL *directory = [self.class storageURL];
    if (![[NSFileManager defaultManager] createDirectoryAtURL:directory
                                withIntermediateDirectories:YES attributes:nil error:error]) {
        return NO;
    }
    return data && [data writeToURL:[self saveURL] options:NSDataWritingAtomic error:error];
}

// 独立文件名避免替换素材时覆盖正在造包的文件。
+ (NSURL *)importFile:(NSURL *)url error:(NSError **)error {
    NSURL *directory = [[self storageURL] URLByAppendingPathComponent:@"Media" isDirectory:YES];
    if (![[NSFileManager defaultManager] createDirectoryAtURL:directory
                                withIntermediateDirectories:YES attributes:nil error:error]) {
        return nil;
    }
    NSString *name = [NSUUID.UUID.UUIDString stringByAppendingPathExtension:url.pathExtension];
    NSURL *destination = [directory URLByAppendingPathComponent:name];
    BOOL scoped = [url startAccessingSecurityScopedResource];
    BOOL copied = [[NSFileManager defaultManager] copyItemAtURL:url toURL:destination error:error];
    if (scoped) {
        [url stopAccessingSecurityScopedResource];
    }
    return copied ? destination : nil;
}

// 协调读取文件提供器资源，格式与设备适配交给 SDK，避免只凭后缀判断兼容性。
+ (NSURL *)importTemplateAtURL:(NSURL *)url error:(NSError **)error {
    BOOL scoped = [url startAccessingSecurityScopedResource];
    __block NSURL *ownedURL = nil;
    __block NSError *readError = nil;
    NSError *coordinationError = nil;
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    [coordinator coordinateReadingItemAtURL:url options:0 error:&coordinationError byAccessor:^(NSURL *readURL) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:readURL.path error:&readError];
        if (!attributes) { return; }
        if (![attributes[NSFileType] isEqual:NSFileTypeRegular] || [attributes fileSize] == 0) {
            readError = [NSError errorWithDomain:@"TSDialEditorErrorDomain" code:TSDialEditorTemplateErrorInvalidFile
                userInfo:@{NSLocalizedDescriptionKey:@"请选择非空的表盘模板文件"}];
            return;
        }
        ownedURL = [self importFile:readURL error:&readError];
    }];
    if (scoped) { [url stopAccessingSecurityScopedResource]; }
    if (error) { *error = readError ?: coordinationError; }
    return ownedURL;
}

// 保存和安装冻结数值快照，源图片与自有文件均不可变共享。
- (id)copyWithZone:(NSZone *)zone {
    TSDialEditorState *snapshot = [[[self class] allocWithZone:zone] init];
    snapshot->_draftType = self.draftType;
    snapshot.images = [[NSArray alloc] initWithArray:self.images copyItems:YES];
    snapshot.textItems = [[NSArray alloc] initWithArray:self.textItems copyItems:YES];
    snapshot.selectedImage = self.selectedImage;
    snapshot.selectedText = self.selectedText;
    snapshot.timeStyle = self.timeStyle;
    snapshot.timePosition = self.timePosition;
    snapshot.timeColor = self.timeColor;
    snapshot.customTimeColor = self.customTimeColor;
    snapshot.showsTime = self.showsTime;
    snapshot.interval = self.interval;
    snapshot.quality = self.quality;
    snapshot.videoAudioSelection = self.videoAudioSelection;
    snapshot.videoURL = self.videoURL;
    snapshot.videoName = self.videoName;
    snapshot.videoDuration = self.videoDuration;
    snapshot.videoStart = self.videoStart;
    snapshot.videoEnd = self.videoEnd;
    snapshot.screenSize = self.screenSize;
    snapshot.templateFileURL = self.templateFileURL;
    snapshot.templateName = self.templateName;
    return snapshot;
}

#pragma mark - 私有方法

// 草稿位于 App 自有目录，图片不依赖相册权限持续有效。
+ (NSURL *)storageURL {
    NSURL *directory = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
                                                            inDomains:NSUserDomainMask].firstObject;
    return [directory URLByAppendingPathComponent:@"CustomDialDrafts" isDirectory:YES];
}

// 各类型独立存储。
- (NSURL *)saveURL {
    return [[self.class storageURL] URLByAppendingPathComponent:
            [NSString stringWithFormat:@"draft-%ld.plist", (long)self.draftType]];
}

@end
