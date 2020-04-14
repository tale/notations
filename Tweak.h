#define SYSTEM_VERSION(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending)

@interface SBHomeScreenViewController : UIViewController
@property (nonatomic, retain) UIGestureRecognizer *notationsGesture;
- (void)updateNotations;
@end

@interface UIStatusBarWindow : UIWindow
@property (nonatomic, retain) UIGestureRecognizer *notationsGesture;
- (void)updateNotations;
@end

@interface SBMainDisplaySceneLayoutStatusBarView : UIView
@property (nonatomic, retain) UIGestureRecognizer *notationsGesture;
- (void)updateNotations;
@end
