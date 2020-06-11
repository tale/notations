#import "./RINotationsActivatorListener.h"
#import "./RINotationsManager.h"

@implementation RINotationsActivatorListener

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenername:(NSString *)listenerName {
	return @"Notations";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
	return @"Toggle the visibility of the notes screen";
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
	[[RINotationsManager sharedInstance] toggleNotes];
	[event setHandled:YES];
}

@end
