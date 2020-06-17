#import <SpringBoard/SBHomeScreenViewController.h>
#import <SpringBoard/SBMainDisplaySceneLayoutStatusBarView.h>
#import <UIKit/UIStatusBarWindow.h>

#define SYSTEM_VERSION(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending)

extern CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface SBHomeScreenViewController (Notations)
@property (nonatomic, retain) UIGestureRecognizer *notationsGesture;
- (void)updateNotations;
- (void)toggleNotesShown;
@end

@interface SBMainDisplaySceneLayoutStatusBarView (Notations)
@property (nonatomic, retain) UIGestureRecognizer *notationsGesture;
- (void)updateNotations;
- (void)toggleNotesShown;
@end

@interface UIStatusBarWindow (Notations)
@property (nonatomic, retain) UIGestureRecognizer *notationsGesture;
- (void)updateNotations;
- (void)toggleNotesShown;
@end