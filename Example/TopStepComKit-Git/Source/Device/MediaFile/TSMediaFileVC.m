//
//  TSMediaFileVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2026/8/21.
//

#import "TSMediaFileVC.h"

@interface TSMediaFileVC ()

// 统一媒体文件接口
@property (nonatomic, strong) id<TSMediaFileInterface> mediaFileInterface;
// 当前录音文件列表
@property (nonatomic, copy) NSArray<TSMediaFileModel *> *mediaFiles;

@end

@implementation TSMediaFileVC

#pragma mark - 生命周期

// 注册列表失效监听并加载数据
- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.mediaFileInterface.isSupport) {
        [self showEmptyViewWithTitle:@"Audio recordings unavailable"
                            subtitle:@"The current device provider does not expose a recording file library."];
        self.sourceTableview.userInteractionEnabled = NO;
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self.mediaFileInterface registerMediaFileListDidChangedBlock:^(TSMediaFileType type) {
        if (type == TSMediaFileTypeAudioRecording) {
            [weakSelf refreshMediaFiles];
        }
    }];
    [self refreshMediaFiles];
}

// 解除列表失效监听
- (void)dealloc {
    [self.mediaFileInterface registerMediaFileListDidChangedBlock:nil];
}

#pragma mark - 公开方法

// 初始化页面数据
- (void)initData {
    [super initData];
    self.title = @"Audio Recordings";
    self.mediaFileInterface = TopStepComKit.sharedInstance.mediaFile;
    self.mediaFiles = @[];
    self.sourceArray = self.mediaFiles;
}

// 配置刷新与全删入口
- (void)setupViews {
    [super setupViews];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
        target:self
        action:@selector(refreshMediaFiles)];
    UIBarButtonItem *deleteAllButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Delete All"
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(confirmDeleteAllMediaFiles)];
    self.navigationItem.rightBarButtonItems = @[refreshButton, deleteAllButton];
}

#pragma mark - 私有方法

// 重新获取设备录音文件列表
- (void)refreshMediaFiles {
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [self.mediaFileInterface fetchMediaFilesOfType:TSMediaFileTypeAudioRecording
                                        completion:^(NSArray<TSMediaFileModel *> *mediaFiles, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf hideLoading];
        if (error) {
            [strongSelf showAlertWithMsg:error.localizedDescription];
            return;
        }
        strongSelf.mediaFiles = mediaFiles ?: @[];
        strongSelf.sourceArray = strongSelf.mediaFiles;
        [strongSelf.sourceTableview reloadData];
        if (strongSelf.mediaFiles.count == 0) {
            [strongSelf showEmptyViewWithTitle:@"No audio recordings"
                                      subtitle:@"Record on the device, then refresh this list."];
        } else {
            [strongSelf hideEmptyView];
        }
    }];
}

// 二次确认后删除全部录音文件
- (void)confirmDeleteAllMediaFiles {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete all recordings?"
                                                                   message:@"This operation cannot be undone."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                             style:UIAlertActionStyleCancel
                                           handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete All"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(__unused UIAlertAction *action) {
        [weakSelf deleteAllMediaFiles];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

// 删除全部录音文件并回读列表
- (void)deleteAllMediaFiles {
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [self.mediaFileInterface deleteAllMediaFilesOfType:TSMediaFileTypeAudioRecording
                                            completion:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideLoading];
        if (!success) {
            [strongSelf showAlertWithMsg:error.localizedDescription];
            return;
        }
        [strongSelf refreshMediaFiles];
    }];
}

// 下载选中的录音文件
- (void)downloadMediaFile:(TSMediaFileModel *)mediaFile {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *folderPath = [(cachePath ?: NSTemporaryDirectory()) stringByAppendingPathComponent:@"MediaFiles"];
    [self showLoading];
    __weak typeof(self) weakSelf = self;
    [self.mediaFileInterface downloadMediaFile:mediaFile
                               localFolderPath:folderPath
                                      progress:^(double progress) {
        weakSelf.navigationItem.prompt = [NSString stringWithFormat:@"Downloading %.0f%%", progress * 100.0];
    } completion:^(NSString *localFilePath, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideLoading];
        strongSelf.navigationItem.prompt = nil;
        TSLog(@"[TSMediaFileVC] download %@, error=%@", localFilePath, error.localizedDescription);
        [strongSelf showAlertWithMsg:error ? error.localizedDescription : localFilePath];
    }];
}

// 删除单个录音文件并回读列表
- (void)deleteMediaFile:(TSMediaFileModel *)mediaFile {
    __weak typeof(self) weakSelf = self;
    [self.mediaFileInterface deleteMediaFile:mediaFile completion:^(BOOL success, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!success) {
            [strongSelf showAlertWithMsg:error.localizedDescription];
            return;
        }
        [strongSelf refreshMediaFiles];
    }];
}

#pragma mark - UITableViewDelegate

// 展示文件名和可选大小
- (NSString *)cellNameAtIndexPath:(NSIndexPath *)cellIndexPath {
    TSMediaFileModel *mediaFile = self.mediaFiles[cellIndexPath.row];
    NSString *sizeText = mediaFile.fileSize ? [NSString stringWithFormat:@"%@ B", mediaFile.fileSize] : @"unknown size";
    return [NSString stringWithFormat:@"%@ · %@", mediaFile.fileName, sizeText];
}

// 点击文件开始下载
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self downloadMediaFile:self.mediaFiles[indexPath.row]];
}

// 右滑删除单个文件
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteMediaFile:self.mediaFiles[indexPath.row]];
    }
}

@end
