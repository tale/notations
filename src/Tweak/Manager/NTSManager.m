#import "NTSManager.h"
#import "../Objects/NTSNote.h"
#import "../UI/Notes/NTSNoteView.h"
#import "../UI/Window/NTSWindow.h"

@implementation NTSManager

+ (instancetype)sharedInstance {
	static NTSManager *instance = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		instance = [NTSManager alloc];
		instance.notes = [NSMutableArray new];
	});

	return instance;
}

- (instancetype)init {
	return [NTSManager sharedInstance];
}

- (void)loadView {
	if (!self.window) {
		self.window = [[NTSWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	}
	if (!self.notesView) {
		self.notesView = self.window.rootViewController.view;
		self.notesView.userInteractionEnabled = YES;
	}

	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

- (void)removeNote:(NTSNote *)note {
	[note willHideView];
	[self.notes removeObject:note];

	NSError *error;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.notes requiringSecureCoding:NO error:&error];

	[data writeToFile:@"/var/mobile/Documents/NotationsData.plist" atomically:NO];

	[self updateNotes];
}

- (void)loadNotes {
	NSData *notesArrayData = [NSData dataWithContentsOfFile:@"/var/mobile/Documents/NotationsData.plist"];

	if (notesArrayData) {
		// NSError *error;
		// NSArray *savedNotesArray = [NSKeyedUnarchiver unarchivedObjectOfClass:[NTSNote class] fromData:notesArrayData error:&error];
		NSArray *savedNotesArray = [NSKeyedUnarchiver unarchiveObjectWithData:notesArrayData];
		if (savedNotesArray) {
			self.notes = [[NSMutableArray alloc] initWithArray:savedNotesArray];
		} else {
			self.notes = [[NSMutableArray alloc] init];
		}
	}

	for (NTSNote *note in self.notes) {
		note.presented = NO;
	}

	[self updateNotes];
}

- (void)updateNotes {
	if (self.notes.count == 0) {
	} else {
		for (NTSNote *note in self.notes) {
			[note loadView];
			[note.view removeFromSuperview];
			[self.notesView addSubview:note.view];
			note.presented = YES;
		}
	}
}

- (void)createNote:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		if (self.windowVisible) {
			CGPoint position = [sender locationInView:self.notesView];
			NTSNote *note = [[NTSNote alloc] init];
			note.text = @"";
			note.center = CGPointMake(position.x, position.y);
			note.size = CGSizeMake(200, 200);
			note.interactive = YES;

			[self.notes addObject:note];
			[self updateNotes];
			[note willShowView];
			[self.notesView addSubview:note.view];
			[note didShowView];

			NSError *error;
			NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.notes requiringSecureCoding:NO error:&error];

			[data writeToFile:@"/var/mobile/Documents/NotationsData.plist" atomically:NO];
		}
	}
}

- (void)toggleNotesShown {
	if (self.enabled) {
		if (self.windowVisible) {
			[self hideNotes];
		} else {
			[self showNotes];
		}
	}
}

- (void)showNotes {
	for (NTSNote *note in self.notes) {
		[note willShowView];
	}
	[self updateNotes];

	self.window.windowLevel = UIWindowLevelStatusBar + 99.0;
	self.window.hidden = NO;
	self.windowVisible = YES;

	for (NTSNote *note in self.notes) {
		[note didShowView];
	}
}

- (void)hideNotes {
	for (NTSNote *note in self.notes) {
		[note willHideView];
	}
	self.window.hidden = YES;
	self.windowVisible = NO;
}

- (void) orientationChanged:(NSNotification *)sender {
	UIDevice * device = sender.object;
	switch (device.orientation) {
        case UIInterfaceOrientationLandscapeLeft:
			for (NTSNote *note in self.notes) {
				[UIView animateWithDuration:0.25 animations:^{
					note.view.transform = CGAffineTransformMakeRotation(-90 * M_PI / 180.0);
				} completion:nil];	
			}
			break;
        case UIInterfaceOrientationLandscapeRight:
            for (NTSNote *note in self.notes) {
				[UIView animateWithDuration:0.25 animations:^{
					note.view.transform = CGAffineTransformMakeRotation(90 * M_PI / 180.0);
				} completion:nil];	
			}
			break;
        case UIInterfaceOrientationPortraitUpsideDown:
            for (NTSNote *note in self.notes) {
				[UIView animateWithDuration:0.25 animations:^{
					note.view.transform = CGAffineTransformMakeRotation(180 * M_PI / 180.0);
				} completion:nil];	
			}
			break;
        case UIInterfaceOrientationPortrait:
        default: 
			for (NTSNote *note in self.notes) {
				[UIView animateWithDuration:0.25 animations:^{
					note.view.transform = CGAffineTransformMakeRotation(0 * M_PI / 180.0);
				} completion:nil];	
			}
			break;
    }
}

@end
