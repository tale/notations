#import "./RINotationsManager.h"
#import "./RINotationsNote.h"
#import "../UI/RINotationsNoteView.h"
#import "../UI/RINotationsWindow.h"

@implementation RINotationsManager

+ (instancetype)sharedInstance {
	static RINotationsManager *instance = nil;
	static dispatch_once_t token;

	dispatch_once(&token, ^{
		instance = [RINotationsManager alloc];
		instance.notes = nil;
	});

	return instance;
}

- (instancetype)init {
	return [RINotationsManager sharedInstance];
}

- (void)loadView {
	if (!self.window) {
		self.window = [[RINotationsWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	}

	if (!self.view) {
		self.view = self.window.rootViewController.view;
		self.view.userInteractionEnabled = YES;
	}
}

- (void)createNote:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		if (self.visible) {
			CGPoint position = [sender locationInView:self.view];
			RINotationsNote *note = [[RINotationsNote alloc] init];
			note.text = @"";
			note.center = CGPointMake(position.x, position.y);
			note.size = CGSizeMake(200, 200);
			note.interactive = YES;

			[self.notes addObject:note];
			[self reloadNotes];
			[note willShowView];
			[self.view addSubview:note.view];
			[note didShowView];

			NSError *error;
			NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.notes requiringSecureCoding:YES error:&error];

			[data writeToFile:@"/var/mobile/Library/Application Support/me.renai.notations.data.plist" atomically:NO];
		}
	}
}

- (void)removeNote:(RINotationsNote *)note {
	[note willHideView];
	[self.notes removeObject:note];

	NSError *error;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.notes requiringSecureCoding:YES error:&error];

	[data writeToFile:@"/var/mobile/Library/Application Support/me.renai.notations.data.plist" atomically:NO];

	[self reloadNotes];
}

- (void)loadNotes {
	NSData *notesArrayData = [NSData dataWithContentsOfFile:@"/var/mobile/Library/Application Support/me.renai.notations.data.plist"];

	if (notesArrayData) {
		NSError *error;
		NSArray *savedNotesArray = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:notesArrayData error:&error];

		if (savedNotesArray) {
			self.notes = [[NSMutableArray alloc] initWithArray:savedNotesArray];
		} else {
			self.notes = [[NSMutableArray alloc] init];
		}
	}

	for (RINotationsNote *note in self.notes) {
		note.presented = NO;
	}

	[self reloadNotes];
}

- (void)reloadNotes {
	if (self.notes.count != 0) {
		for (RINotationsNote *note in self.notes) {
			[note loadView];
			[note.view removeFromSuperview];
			[self.view addSubview:note.view];
			note.presented = YES;
		}
	}
}


- (void)toggleNotes {
	if (self.visible) {
		[self hideNotes];
	} else {
		[self showNotes];
	}
}

- (void)showNotes {
	for (RINotationsNote *note in self.notes) {
		[note willShowView];
	}

	[self reloadNotes];
	self.window.windowLevel = UIWindowLevelStatusBar + 99.0;
	self.window.hidden = NO;
	self.visible = YES;

	for (RINotationsNote *note in self.notes) {
		[note didShowView];
	}
}

- (void)hideNotes {
	for (RINotationsNote *note in self.notes) {
		[note willHideView];
	}

	self.window.hidden = YES;
	self.visible = NO;
}

@end
