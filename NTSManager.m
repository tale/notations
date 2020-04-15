#import "NTSManager.h"
#import "NTSNote.h"
#import "NTSNoteView.h"
#import "NTSWindow.h"

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
	if (!self.notesView) {
		self.notesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height + 50)];
		self.notesView.hidden = YES;
		self.notesView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
		self.notesView.userInteractionEnabled = YES;

		UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createNote:)];
		[self.notesView addGestureRecognizer:pressRecognizer];
	}
	if (!self.window) {
		self.window = [[NTSWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
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
		if (!self.addLabel) {
			self.addLabel = [[UILabel alloc] init];
			self.addLabel.alpha = 0;
			self.addLabel.text = @"Long press to add a note";
			self.addLabel.textColor = [UIColor whiteColor];
			[self.addLabel sizeToFit];
			self.addLabel.frame = CGRectMake(self.notesView.bounds.size.width / 2 - self.addLabel.bounds.size.width / 2, self.notesView.bounds.size.height / 2 - self.addLabel.bounds.size.height / 2, self.addLabel.bounds.size.width, self.addLabel.bounds.size.height);
			[self.notesView addSubview:self.addLabel];
		}
		[UIView animateWithDuration:0.3 animations:^{
			self.addLabel.alpha = 1;
		} completion:nil];
	} else {
		if (self.addLabel && self.addLabel.alpha > 0) {
			[UIView animateWithDuration:0.3 animations:^{
				self.addLabel.alpha = 0;
			} completion:nil];
		}
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

	self.window.windowLevel = UIWindowLevelStatusBar + 100.0;
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