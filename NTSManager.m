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

- (void)initView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height + 50)];
	self.view.hidden = YES;
	[self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
	[self.view setUserInteractionEnabled:YES];
}

- (void)addNote:(NTSNote *)note {
	[self.notes addObject:note];
	[self.view addSubview:note.view];

	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.notes] forKey:@"notations_notes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self updateNotes];
}

- (void)removeNote:(NTSNote *)note {
	[self.notes removeObject:note];
	[note.view removeFromSuperview];

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
}

- (void)updateNotes {
	if (self.notes.count == 0) {
		if (!self.addLabel) {
			self.addLabel = [[UILabel alloc] init];
			self.addLabel.text = @"Long press to add a note";
			self.addLabel.textColor = [UIColor whiteColor];
			[self.addLabel sizeToFit];
			self.addLabel.frame = CGRectMake(self.view.bounds.size.width / 2 - self.addLabel.bounds.size.width / 2, self.view.bounds.size.height / 2 - self.addLabel.bounds.size.height / 2, self.addLabel.bounds.size.width, self.addLabel.bounds.size.height);
			[self.view addSubview:self.addLabel];
		}
		self.addLabel.hidden = NO;
	} else {
		if (self.addLabel) {
			self.addLabel.hidden = YES;
		}
		for (NTSNote *note in self.notes) {
			[note setupView];
			[note willShowView];
			[note.view removeFromSuperview];
			[self.view addSubview:note.view];
			note.presented = YES;
		}
	}
}

- (void)createNote:(CGPoint)position {
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

- (void)toggleNotesShown {
	if (self.windowVisible) {
		[self hideNotes];
	} else {
		[self showNotes];
	}
}

- (void)showNotes {
	if (!self.window) {
		self.window = [[NTSWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	}
	[self updateNotes];

	self.window.windowLevel = UIWindowLevelStatusBar + 100.0;
	self.window.hidden = NO;

	self.windowVisible = YES;
}

- (void)hideNotes {
	if (!self.window) {
		self.window = [[NTSWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	}
	self.window.hidden = YES;
	self.windowVisible = NO;
}

@end