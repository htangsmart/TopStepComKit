//
//  TSMusicVC+Table.m
//  TopStepComKit-Git_Example
//
//  Created by Codex on 2026/8/18.
//  Copyright © 2026 rd@hetangsmart.com. All rights reserved.
//

#import "TSMusicVC+Table.h"

#import <TopStepComKit/TopStepComKit.h>

static const CGFloat kMusicCellHeight = 64.f;
static NSString *const kMusicCellIdentifier = @"TSMusicCell";

@interface TSMusicVC (TablePrivate)

/** 音乐列表 */
@property (nonatomic, strong) UITableView *tableView;
/** 音乐数据源 */
@property (nonatomic, strong) NSMutableArray<TSMusicModel *> *dataSource;

- (id<TSMusicInterface>)musicInterface;
- (NSString *)formatDuration:(NSTimeInterval)seconds;
- (void)showToast:(NSString *)message;
- (void)reloadMusicList;
- (void)confirmDeleteAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(BOOL))completion;

@end

@implementation TSMusicVC (Table)

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    (void)tableView;
    (void)section;
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMusicCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                     reuseIdentifier:kMusicCellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    TSMusicModel *music = self.dataSource[indexPath.row];
    cell.textLabel.text = music.title.length > 0 ? music.title : @"(Unknown)";
    NSString *artist = music.artist.length > 0 ? music.artist : @"-";
    NSString *duration = music.duration > 0 ? [self formatDuration:music.duration] : @"--:--";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@   %@", artist, duration];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    (void)tableView;
    (void)indexPath;
    return kMusicCellHeight;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    __weak typeof(self) weakSelf = self;
    UIContextualAction *deleteAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleDestructive
        title:@"Delete"
        handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
            (void)action;
            (void)sourceView;
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                completionHandler(NO);
                return;
            }
            [strongSelf confirmDeleteAtIndexPath:indexPath completion:completionHandler];
        }];
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}

#pragma mark - 私有方法

/** 确认并删除指定位置的音乐 */
- (void)confirmDeleteAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(BOOL))completion {
    if (indexPath.row >= (NSInteger)self.dataSource.count) {
        completion(NO);
        return;
    }
    TSMusicModel *music = self.dataSource[indexPath.row];
    NSString *message = [NSString stringWithFormat:@"Delete \"%@\"?", music.title ?: @""];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                             style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action) {
        (void)action;
        completion(NO);
    }]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"Delete"
                                             style:UIAlertActionStyleDestructive
                                           handler:^(UIAlertAction *action) {
        (void)action;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            completion(NO);
            return;
        }
        completion(YES);
        [strongSelf showLoading];
        TSLog(@"[TSMusicVC] deleteMusic: -> title=%@", music.title);
        [strongSelf.musicInterface deleteMusic:music completion:^(BOOL success, NSError *error) {
            __strong typeof(weakSelf) callbackSelf = weakSelf;
            if (!callbackSelf) {
                return;
            }
            TSLog(@"[TSMusicVC] deleteMusic: <- success=%d, error=%@",
                  success,
                  error.localizedDescription);
            [callbackSelf hideLoading];
            if (success) {
                [callbackSelf showToast:@"Deleted"];
                [callbackSelf reloadMusicList];
            } else {
                [callbackSelf showToast:error.localizedDescription ?: @"Delete failed"];
            }
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
