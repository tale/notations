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
		instance.notes = nil;
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
	}
}

- (void)addNote:(NTSNote *)note {
	[self.notes addObject:note];
	[self updateNotes];
	[note willShowView];
	[self.notesView addSubview:note.view];
	[note didShowView];

	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.notes] forKey:@"notations_notes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeNote:(NTSNote *)note {
	[note willHideView];
	[self.notes removeObject:note];

	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.notes] forKey:@"notations_notes"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self updateNotes];
}

- (void)loadNotes {
	NSData *notesArrayData = [[NSUserDefaults standardUserDefaults] objectForKey:@"notations_notes"];

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
			[note setupView];
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
			note.x = position.x - 100;
			note.y = position.y - 100;
			note.width = 200;
			note.height = 200;
			note.draggable = YES;
			note.resizeable = YES;
			[self addNote:note];
		}
	}
}

- (void)toggleNotesShown {
	if (self.windowVisible) {
		[self hideNotes];
	} else {
		[self showNotes];
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