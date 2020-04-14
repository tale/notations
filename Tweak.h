#define SYSTEM_VERSION(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending)

@interface SBHomeScreenViewController : UIViewController
@end

@interface UIStatusBarWindow : UIWindow
@end

@interface SBMainDisplaySceneLayoutStatusBarView : UIView
@end
