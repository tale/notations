#import <SpringBoard/SBHomeScreenViewController.h>
#import <SpringBoard/SBMainDisplaySceneLayoutStatusBarView.h>
#import <UIKit/UIStatusBarWindow.h>

#define kIdentifier @"me.renai.notations.preferences"
#define kSettingsChangedNotification (CFStringRef)@"me.renai.notations.preferences/reload"
#define kActivatorNotification (CFStringRef)@"me.renai.notations/togglenotes"
#define kSettingsPath @"/var/mobile/Library/Preferences/me.renai.notations.preferences.plist"

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

