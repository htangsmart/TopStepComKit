//
//  TSContactEditVC.m
//  TopStepComKit_Example
//
//  Created by 磐石 on 2025/3/4.
//  Copyright © 2025 rd@hetangsmart.com. All rights reserved.
//

#import "TSContactEditVC.h"
#import <Contacts/Contacts.h>

// ── Cell 复用标识 ──────────────────────────────────────────────────────────────
static NSString * const kPickerCellID = @"kPickerCell";

// ── 布局常量 ──────────────────────────────────────────────────────────────────
static const CGFloat kPickerRowH = 60.f;

#pragma mark - 联系人数据封装

/**
 * 页面内部使用的联系人数据，包含是否选中状态
 */
@interface TSPickerItem : NSObject
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *phoneNum;
@property (nonatomic, assign) BOOL      selected;
@end

@implementation TSPickerItem
@end

#pragma mark - TSContactEditVC

@interface TSContactEditVC () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating>

// 导航栏右侧保存按钮
@property (nonatomic, strong) UIBarButtonItem        *saveBarButton;

// 搜索控制器
@property (nonatomic, strong) UISearchController     *searchController;

// 联系人列表（TableView）
@property (nonatomic, strong) UITableView            *tableView;

// 加载指示器（读取通讯录期间显示）
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

// 空视图（通讯录无联系人或权限被拒时显示）
@property (nonatomic, strong) UILabel                *emptyLabel;

// 全量数据（按姓名排序）
@property (nonatomic, strong) NSMutableArray<TSPickerItem *> *allItems;

// 搜索过滤后的数据（搜索框有内容时使用）
@property (nonatomic, strong) NSArray<TSPickerItem *> *filteredItems;

// 是否处于搜索状态
@property (nonatomic, assign) BOOL isSearching;

// 最大可选数量
@property (nonatomic, assign) NSInteger maxSelectCount;

// 初始选中的电话号码集合（用于判断是否有改动）
@property (nonatomic, strong) NSSet<NSString *> *initialSelectedPhones;

// 完成回调
@property (nonatomic, copy)   TSContactPickerCompletion completion;

// 导航栏是否已配置（避免 viewWillAppear 重复设置引发约束冲突）
@property (nonatomic, assign) BOOL navigationBarConfigured;

@end

@implementation TSContactEditVC

#pragma mark - Init

/**
 * 初始化选择器，传入已选联系人、最大数量限制和完成回调
 */
- (instancetype)initWithSelectedContacts:(NSArray<TopStepContactModel *> *)selectedContacts
                          maxSelectCount:(NSInteger)maxSelectCount
                              completion:(TSContactPickerCompletion)completion {
    self = [super init];
    if (self) {
        _maxSelectCount = maxSelectCount;
        _completion     = completion;
        _allItems       = [NSMutableArray array];
        _filteredItems  = @[];
        _isSearching    = NO;

        // 记录初始选中的号码集合，用于判断保存按钮是否高亮
        NSMutableSet *phones = [NSMutableSet set];
        for (TopStepContactModel *m in selectedContacts) {
            if (m.phoneNum.length > 0) [phones addObject:m.phoneNum];
        }
        _initialSelectedPhones = [phones copy];
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = TSColor_Background;
    self.title = TSLocalizedString(@"contact.select");

    [self setupViews];
    [self layoutViews];
    [self loadSystemContacts];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 延后到 viewWillAppear 再设置导航栏，避免 view 尚未入窗时导航栏 contentView 尺寸为 0 导致约束冲突
    if (!self.navigationBarConfigured) {
        [self setupNavigationBar];
        [self setupSearchController];
        self.navigationBarConfigured = YES;
    }
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    [self layoutViews];
}

#pragma mark - Setup

/**
 * 配置导航栏右侧「保存」按钮（初始灰色禁用）
 */
- (void)setupNavigationBar {
    _saveBarButton = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector(saveTapped)];
    _saveBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = _saveBarButton;
}

/**
 * 配置搜索框
 */
- (void)setupSearchController {
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater              = self;
    _searchController.obscuresBackgroundDuringPresentation = NO;
    _searchController.searchBar.placeholder             = TSLocalizedString(@"contact.search");
    _searchController.searchBar.tintColor               = TSColor_Primary;
    self.navigationItem.searchController                = _searchController;
    self.navigationItem.hidesSearchBarWhenScrolling     = NO;
    self.definesPresentationContext                     = YES;
}

/**
 * 构建视图层级
 */
- (void)setupViews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.loadingIndicator];
    [self.view addSubview:self.emptyLabel];
}

/**
 * Frame 布局
 */
- (void)layoutViews {
    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat screenH = CGRectGetHeight(self.view.bounds);
    if (screenW <= 0) return;

    CGFloat topInset    = self.view.safeAreaInsets.top;
    CGFloat bottomInset = self.view.safeAreaInsets.bottom;

    self.tableView.frame = CGRectMake(0, topInset, screenW, screenH - topInset - bottomInset);

    self.loadingIndicator.center = CGPointMake(screenW / 2.f, screenH / 2.f);

    self.emptyLabel.frame = CGRectMake(40.f, (screenH - 60.f) / 2.f, screenW - 80.f, 60.f);
}

#pragma mark - Load System Contacts

/**
 * 请求通讯录权限并加载所有联系人
 */
- (void)loadSystemContacts {
    [self.loadingIndicator startAnimating];
    self.tableView.hidden = YES;
    self.emptyLabel.hidden = YES;

    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];

    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        [self showPermissionDenied];
        return;
    }

    CNContactStore *store = [[CNContactStore alloc] init];

    if (status == CNAuthorizationStatusNotDetermined) {
        __weak typeof(self) weakSelf = self;
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [weakSelf fetchContactsFromStore:store];
                } else {
                    [weakSelf showPermissionDenied];
                }
            });
        }];
    } else {
        [self fetchContactsFromStore:store];
    }
}

/**
 * 从系统通讯录读取全部联系人，转换为 TSPickerItem 并按姓名排序
 */
- (void)fetchContactsFromStore:(CNContactStore *)store {
    NSArray<id<CNKeyDescriptor>> *keys = @[
        CNContactGivenNameKey,
        CNContactFamilyNameKey,
        CNContactPhoneNumbersKey,
        [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]
    ];

    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    request.sortOrder = CNContactSortOrderUserDefault;

    NSMutableArray<TSPickerItem *> *items = [NSMutableArray array];
    NSError *fetchError = nil;

    BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
        if (contact.phoneNumbers.count == 0) return;

        NSString *name = [CNContactFormatter stringFromContact:contact
                                                         style:CNContactFormatterStyleFullName] ?: @"";
        if (name.length == 0) name = contact.givenName ?: contact.familyName ?: @"未知";

        // 每个号码生成一条
        for (CNLabeledValue<CNPhoneNumber *> *labeled in contact.phoneNumbers) {
            NSString *rawPhone = labeled.value.stringValue;
            // 清洗号码：仅保留数字和 +
            NSMutableString *clean = [NSMutableString string];
            for (NSUInteger i = 0; i < rawPhone.length; i++) {
                unichar c = [rawPhone characterAtIndex:i];
                if (c == '+' || (c >= '0' && c <= '9')) {
                    [clean appendFormat:@"%C", c];
                }
            }
            NSString *phone = clean.length > 0 ? clean : rawPhone;

            TSPickerItem *item = [[TSPickerItem alloc] init];
            item.name     = name;
            item.phoneNum = phone;
            item.selected = [self.initialSelectedPhones containsObject:phone];
            [items addObject:item];
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];

        if (!success || fetchError) {
            self.emptyLabel.text   = TSLocalizedString(@"contact.read_failed");
            self.emptyLabel.hidden = NO;
            return;
        }

        // 按姓名拼音排序
        [items sortUsingComparator:^NSComparisonResult(TSPickerItem *a, TSPickerItem *b) {
            return [a.name localizedCompare:b.name];
        }];

        self.allItems = items;
        self.tableView.hidden = NO;

        if (items.count == 0) {
            self.emptyLabel.text   = TSLocalizedString(@"contact.empty");
            self.emptyLabel.hidden = NO;
        }

        [self.tableView reloadData];
    });
}

/**
 * 权限被拒时展示说明文字
 */
- (void)showPermissionDenied {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];
        self.emptyLabel.text   = TSLocalizedString(@"contact.no_access");
        self.emptyLabel.hidden = NO;
    });
}

#pragma mark - UISearchResultsUpdating

/**
 * 搜索框内容变化时过滤列表
 */
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *keyword = [searchController.searchBar.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceCharacterSet]];
    self.isSearching = keyword.length > 0;

    if (!self.isSearching) {
        self.filteredItems = @[];
    } else {
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(TSPickerItem *item, NSDictionary *bindings) {
            return [item.name localizedCaseInsensitiveContainsString:keyword]
                || [item.phoneNum containsString:keyword];
        }];
        self.filteredItems = [self.allItems filteredArrayUsingPredicate:pred];
    }

    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)(self.isSearching ? self.filteredItems.count : self.allItems.count);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kPickerRowH;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPickerCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPickerCellID];
        cell.textLabel.font          = TSFont_Body;
        cell.textLabel.textColor     = TSColor_TextPrimary;
        cell.detailTextLabel.font    = TSFont_Caption;
        cell.detailTextLabel.textColor = TSColor_TextSecondary;
        cell.selectionStyle          = UITableViewCellSelectionStyleNone;
    }

    TSPickerItem *item = [self itemAtIndexPath:indexPath];
    cell.textLabel.text       = item.name;
    cell.detailTextLabel.text = item.phoneNum;

    // 选中状态用对勾图标显示
    if (item.selected) {
        UIImageView *checkView   = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"checkmark.circle.fill"]];
        checkView.tintColor      = TSColor_Primary;
        checkView.frame          = CGRectMake(0, 0, 24.f, 24.f);
        cell.accessoryView       = checkView;
    } else {
        UIImageView *circleView  = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"circle"]];
        circleView.tintColor     = TSColor_Separator;
        circleView.frame         = CGRectMake(0, 0, 24.f, 24.f);
        cell.accessoryView       = circleView;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TSPickerItem *item = [self itemAtIndexPath:indexPath];

    if (item.selected) {
        // 取消选中
        item.selected = NO;
    } else {
        // 达到上限时提示
        NSInteger currentSelected = [self selectedCount];
        if (currentSelected >= self.maxSelectCount) {
            NSString *msg = self.maxSelectCount == 1
                ? @"最多只能选择 1 位联系人"
                : [NSString stringWithFormat:@"最多只能选择 %ld 位联系人", (long)self.maxSelectCount];
            [self showLimitToast:msg];
            return;
        }
        item.selected = YES;
    }

    // 同步更新 allItems 中对应条目（搜索态下 filteredItems 是 allItems 的子集引用，无需额外处理）
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self updateSaveButtonState];
}

#pragma mark - Actions

/**
 * 点击「保存」：将选中的 TSPickerItem 转换为 TopStepContactModel 并回调
 */
- (void)saveTapped {
    NSMutableArray<TopStepContactModel *> *result = [NSMutableArray array];
    for (TSPickerItem *item in self.allItems) {
        if (item.selected) {
            TopStepContactModel *model = [TopStepContactModel contactWithName:item.name phoneNum:item.phoneNum];
            [result addObject:model];
        }
    }

    if (self.completion) {
        self.completion([result copy]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - State

/**
 * 根据当前选中状态是否与初始状态不同，更新保存按钮的可点击状态
 */
- (void)updateSaveButtonState {
    // 收集当前选中的电话号码
    NSMutableSet<NSString *> *current = [NSMutableSet set];
    for (TSPickerItem *item in self.allItems) {
        if (item.selected) [current addObject:item.phoneNum];
    }
    self.saveBarButton.enabled = ![current isEqualToSet:self.initialSelectedPhones];
}

/**
 * 获取当前选中数量
 */
- (NSInteger)selectedCount {
    NSInteger count = 0;
    for (TSPickerItem *item in self.allItems) {
        if (item.selected) count++;
    }
    return count;
}

/**
 * 根据 indexPath 获取对应数据项（自动区分搜索/全量状态）
 */
- (TSPickerItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<TSPickerItem *> *source = self.isSearching ? self.filteredItems : self.allItems;
    return source[indexPath.row];
}

#pragma mark - Toast

/**
 * 上限提示（中部短暂 Toast）
 */
- (void)showLimitToast:(NSString *)message {
    UILabel *toast      = [[UILabel alloc] init];
    toast.text          = message;
    toast.textColor     = [UIColor whiteColor];
    toast.font          = [UIFont systemFontOfSize:14.f];
    toast.textAlignment = NSTextAlignmentCenter;
    toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.72f];
    toast.layer.cornerRadius = 10.f;
    toast.clipsToBounds = YES;
    toast.alpha         = 0;

    CGFloat screenW = CGRectGetWidth(self.view.bounds);
    CGFloat toastW  = 220.f;
    CGFloat toastH  = 40.f;
    toast.frame     = CGRectMake((screenW - toastW) / 2.f,
                                  CGRectGetHeight(self.view.bounds) / 2.f - toastH / 2.f,
                                  toastW, toastH);
    [self.view addSubview:toast];

    [UIView animateWithDuration:0.2 animations:^{ toast.alpha = 1.0f; }
                     completion:^(BOOL f) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{ toast.alpha = 0; }
                             completion:^(BOOL done) { [toast removeFromSuperview]; }];
        });
    }];
}

#pragma mark - Lazy Properties

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate        = self;
        _tableView.dataSource      = self;
        _tableView.backgroundColor = TSColor_Background;
        _tableView.separatorColor  = TSColor_Separator;
        _tableView.separatorInset  = UIEdgeInsetsMake(0, 16.f, 0, 0);
        _tableView.rowHeight       = kPickerRowH;
        if (@available(iOS 15.0, *)) { _tableView.sectionHeaderTopPadding = 0; }
    }
    return _tableView;
}

- (UIActivityIndicatorView *)loadingIndicator {
    if (!_loadingIndicator) {
        if (@available(iOS 13.0, *)) {
            _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        } else {
            _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        _loadingIndicator.hidesWhenStopped = YES;
    }
    return _loadingIndicator;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel               = [[UILabel alloc] init];
        _emptyLabel.font          = TSFont_Body;
        _emptyLabel.textColor     = TSColor_TextSecondary;
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
        _emptyLabel.hidden        = YES;
    }
    return _emptyLabel;
}

@end
