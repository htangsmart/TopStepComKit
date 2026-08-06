//
//  TSWorkoutPushVC+Internal.h
//  TopStepComKit_Example
//

#import "TSWorkoutPushVC.h"
#import "TSWorkoutCloudService.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSWorkoutPushVC () <UIDocumentPickerDelegate>

@property (nonatomic, strong) UITableView *workoutTableView;
@property (nonatomic, strong) UIView *deviceCardView;
@property (nonatomic, strong) UILabel *deviceTitleLabel;
@property (nonatomic, strong) UILabel *deviceDetailLabel;
@property (nonatomic, strong) UIButton *localFileButton;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIView *operationOverlay;
@property (nonatomic, strong) UIView *operationCardView;
@property (nonatomic, strong) UILabel *operationTitleLabel;
@property (nonatomic, strong) UILabel *operationDetailLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) TSWorkoutCloudService *cloudService;
@property (nonatomic, copy) NSArray<TSWorkoutCloudResource *> *cloudResources;
@property (nonatomic, copy) NSArray<TSWorkoutSlotModel *> *workoutSlots;
@property (nonatomic, copy) NSString *recentTitle;
@property (nonatomic, copy) NSString *recentDetail;
@property (nonatomic, strong, nullable) TSWorkoutSlotModel *selectedSlot;
@property (nonatomic, strong, nullable) NSURL *downloadedCloudURL;
@property (nonatomic, assign, getter=isCloudLoading) BOOL cloudLoading;
@property (nonatomic, assign, getter=isSlotLoading) BOOL slotLoading;
@property (nonatomic, assign, getter=isDownloading) BOOL downloading;
@property (nonatomic, assign, getter=isInstalling) BOOL installing;
@property (nonatomic, assign, getter=isOperationCancelled) BOOL operationCancelled;

@end

@interface TSWorkoutPushVC (InternalMethods)

- (id<TSWorkoutInterface>)workoutInterface;
- (void)reloadWorkoutData;
- (void)finishRefreshIfNeeded;
- (void)updateRecentTitle:(NSString *)title detail:(NSString *)detail;
- (NSString *)displayNameForSlot:(TSWorkoutSlotModel *)slot;
- (NSString *)formattedSize:(NSUInteger)size;
- (void)selectCloudResource:(TSWorkoutCloudResource *)resource;
- (void)selectDeviceSlot:(TSWorkoutSlotModel *)slot;
- (void)presentSlotPickerForWorkout:(TSWorkoutResourceModel *)workout;
- (void)presentSlotPickerForCloudResource:(TSWorkoutCloudResource *)resource;
- (void)presentLocalFilePicker;
- (void)installCloudResource:(TSWorkoutCloudResource *)resource toSlot:(TSWorkoutSlotModel *)slot;
- (void)installWorkout:(TSWorkoutResourceModel *)workout toSlot:(TSWorkoutSlotModel *)slot;
- (void)showOperationWithTitle:(NSString *)title detail:(NSString *)detail;
- (void)hideOperation;
- (void)localFileButtonTapped;
- (void)cancelButtonTapped;

@end

NS_ASSUME_NONNULL_END
