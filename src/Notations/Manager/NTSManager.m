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
}

- (void)removeNote:(NTSNote *)note {
	[note willHideView];
	[self.notes removeObject:note];

	NSError *error;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.notes requiringSecureCoding:NO error:&error];

	[data writeToFile:@"/var/mobile/Library/Application Support/me.renai.notations.data.plist" atomically:NO];

	[self updateNotes];
}

- (void)loadNotes {
	NSData *notesArrayData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Application Support/me.renai.notations.data.plist"];

	if (notesArrayData) {
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

			[data writeToFile:@"/var/mobile/Library/Application Support/me.renai.notations.data.plist" atomically:NO];
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

@end
