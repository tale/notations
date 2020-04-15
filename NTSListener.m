#import "NTSListener.h"
#import "NTSManager.h"

@implementation NTSListener

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
	return @"Notations";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Toggle the notes view visibility";
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName {
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
	return [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/NotationsPrefs.bundle/icon.png"];
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
	return [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/NotationsPrefs.bundle/icon.png"];
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	[[NTSManager sharedInstance] toggleNotesShown];
	[event setHandled:YES];
}

@end
