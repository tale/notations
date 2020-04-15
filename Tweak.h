#define SYSTEM_VERSION(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending)

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface SBHomeScreenViewController : UIViewController
@property (nonatomic, retain) UIGestureRecognizer *notationsGesture;
- (void)updateNotations;
- (void)toggleNotesShown;
@end

@interface UIStatusBarWindow : UIWindow
@property (nonatomic, retain) UIGestureRecognizer *notationsGesture;
- (void)updateNotations;
- (void)toggleNotesShown;
@end

@interface SBMainDisplaySceneLayoutStatusBarView : UIView
@property (nonatomic, retain) UIGestureRecognizer *notationsGesture;
- (void)updateNotations;
- (void)toggleNotesShown;
@end
