#import "NTSRootListController.h"
#import "Settings.h"

@implementation NTSRootListController

- (instancetype)init {
	self = [super init];

	if (self) {
		self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
		self.navigationItem.rightBarButtonItem = self.respringButton;
	}

	return self;
}

- (NSBundle *)resourceBundle {
	return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/NotationsPrefs.bundle"];
}

- (void)submitIssue {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Renaitare/Notations/issues/new"] options:@{} completionHandler:nil];
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
