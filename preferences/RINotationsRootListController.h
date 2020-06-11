#import <Preferences/PSListController.h>

@interface RINotationsRootListController : PSListController
@end

@interface NSUserDefaults (Private)

- (instancetype)_initWithSuiteName:(NSString *)suiteName container:(NSURL *)container;

@end
