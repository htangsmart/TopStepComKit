#import <UIKit/UIKit.h>

@class TSDeviceConnectionSnapshot;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TSDeviceLogTone) {
    TSDeviceLogToneAccent,
    TSDeviceLogToneLimited,
    TSDeviceLogToneInactive,
};

/// @brief Convert a prototype RGB color to UIKit. @chinese 将原型 RGB 色值转换为 UIKit 颜色。
UIColor *TSDeviceLogColor(NSUInteger rgb);
/// @brief Build a prototype label. @chinese 创建原型文字标签。
UILabel *TSDeviceLogLabel(CGFloat size, UIFontWeight weight, UIColor *color);
/// @brief Build a stack of arranged views. @chinese 创建指定方向的视图组。
UIStackView *TSDeviceLogStack(NSArray<UIView *> *views, UILayoutConstraintAxis axis, CGFloat spacing);
/// @brief Apply layout margins to a stack. @chinese 设置视图组的内边距。
void TSDeviceLogInset(UIStackView *stack, UIEdgeInsets insets);
/// @brief Apply the shared card appearance. @chinese 设置共用卡片外观。
void TSDeviceLogCard(UIView *view, CGFloat radius);
/// @brief Attach a scrolling column to the safe area. @chinese 在安全区内安装可滚动的内容列。
UIScrollView *TSDeviceLogInstall(UIStackView *content, UIView *host);
/// @brief Match the navigation colors to the prototype. @chinese 使用原型配色配置导航栏。
void TSDeviceLogNavigation(UINavigationItem *item);
/// @brief Create a template image using the prototype's icon geometry.
/// @chinese 按原型几何尺寸生成可着色的图标。
/// @param symbol Symbol name / 图标名称。
/// @param size Icon canvas size in points / 图标画布大小，单位为点。
/// @return Icon image / 图标图片。
UIImage *TSDeviceLogPageIcon(NSString *symbol, CGFloat size);
/// @brief Use the actual connection to build the device card. @chinese 根据真实连接状态构建设备卡。
UIStackView *TSDeviceLogDeviceCard(TSDeviceConnectionSnapshot *snapshot, NSString *badge, TSDeviceLogTone tone);
/// @brief Build an accessible row with a symbol, title and trailing action. @chinese 创建带图标、标题和操作入口的可访问行。
UIButton *TSDeviceLogRow(NSString *symbol, NSString *title, NSString *subtitle, NSString *action, BOOL chevron, BOOL enabled);
/// @brief Build a file group with bounded scrolling. @chinese 创建具有最大滚动高度的文件区。
UIView *TSDeviceLogFileList(NSArray<UIButton *> *rows, NSString *empty, CGFloat maximumHeight);
/// @brief Update the prototype primary action. @chinese 更新原型主操作按钮。
void TSDeviceLogPrimary(UIButton *button, NSString *title, NSString *symbol, BOOL destructive, BOOL enabled);
/// @brief Format a received or saved byte count. @chinese 格式化接收或保存的字节数。
NSString *TSDeviceLogBytes(uint64_t count);
/// @brief Show the prototype dialog with a title, content and optionally a close icon.
/// @chinese 显示带标题、内容和可选关闭图标的原型弹窗。
void TSDeviceLogPresentDialog(UIViewController *presenter, NSString *title, NSArray<UIView *> *views, BOOL closable);

NS_ASSUME_NONNULL_END
