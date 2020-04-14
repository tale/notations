#include "NTSRootListController.h"

@interface FBSSystemService : NSObject
+ (instancetype)sharedService;
- (void)sendActions:(NSSet *)arg1 withResult:(id)arg2 ;
@end

typedef enum {
	None = 0,
	SBSRelaunchOptionsRestartRenderServer = (1 << 0),
	SBSRelaunchOptionsSnapshot = (1 << 1),
	SBSRelaunchOptionsFadeToBlack = (1 << 2),
} SBSRelaunchOptions;

@interface SBSRelaunchAction : NSObject
+ (SBSRelaunchAction *)actionWithReason:(NSString *)reason options:(SBSRelaunchOptions)options targetURL:(NSURL *)url;
@end

@interface SBSRestartRenderServerAction : NSObject
+ (instancetype)restartActionWithTargetRelaunchURL:(NSURL *)targetURL;
@property(readonly, nonatomic) NSURL *targetURL;
@end

@implementation NTSRootListController
@synthesize respringButton;

- (instancetype)init {

	self = [super init];

	if (self) {

		self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
		self.navigationItem.rightBarButtonItem = self.respringButton;
	}

	return self;
}

- (NSArray *)specifiers {

	if (!_specifiers) {

		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (NSBundle *)resourceBundle {

	return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/NotationsPrefs.bundle"];
}

- (void)submitIssue {

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/tale/notations/issues/new"] options:@{} completionHandler:nil];
}

- (void)donate {

	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://ko-fi.com/renai"] options:@{} completionHandler:nil];
}

- (void)respring {

	SBSRelaunchAction *restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:SBSRelaunchOptionsFadeToBlack targetURL:[NSURL URLWithString:@"prefs:root=Notations"]];
	NSSet *actions = [NSSet setWithObject:restartAction];
	FBSSystemService *frontBoardService = [NSClassFromString(@"FBSSystemService") sharedService];
	[frontBoardService sendActions:actions withResult:nil];
}

@end
