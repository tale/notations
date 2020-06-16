#import "NTSNote.h"
#import "../Manager/NTSManager.h"
#import "../UI/Notes/NTSNoteView.h"

@implementation NTSNote

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [super init];

	if (self) {
		self.text = [decoder decodeObjectForKey:@"text"];
		self.center = CGPointFromString([decoder decodeObjectForKey:@"center"]);
		self.size = CGSizeFromString([decoder decodeObjectForKey:@"size"]);
		self.presented = [decoder decodeBoolForKey:@"presented"];
		self.interactive = [decoder decodeBoolForKey:@"interactive"];
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.text forKey:@"text"];
	[encoder encodeObject:NSStringFromCGPoint(self.view.center) forKey:@"center"];
	[encoder encodeObject:NSStringFromCGSize(self.size) forKey:@"size"];
	[encoder encodeBool:self.presented forKey:@"presented"];
	[encoder encodeBool:self.interactive forKey:@"interactive"];
}

- (void)loadView {
	if (!self.presented) {
		self.view = [[NTSNoteView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
		self.view.translatesAutoresizingMaskIntoConstraints = YES;
		self.view.center = self.center;

		[self.view.lockButton addTarget:self action:@selector(disableActions) forControlEvents:UIControlEventTouchUpInside];
		[self.view.deleteButton addTarget:self action:@selector(deleteNote) forControlEvents:UIControlEventTouchUpInside];

		UIPanGestureRecognizer *resize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeView:)];
		[self.view.resizeGrabber addGestureRecognizer:resize];

		UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
		[self.view addGestureRecognizer:drag];

		if (self.interactive) {
			[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/unlocked.png"] forState:UIControlStateNormal];
		} else {
			[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/notations/locked.png"] forState:UIControlStateNormal];
		}

		UIToolbar *keyboardBar = [[UIToolbar alloc] init];
		[keyboardBar sizeToFit];

		UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

		UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];

		keyboardBar.items = @[flexBarButton, doneBarButton];
		self.view.textView.inputAccessoryView = keyboardBar;

		if (self.text != nil) {
			self.view.textView.text = self.text;
		}

		[self saveNote];
	}
}

- (void)willShowView {
	[self.view updateEffect];
}

- (void)willHideView {
	self.view.hidden = YES;
}

- (void)didShowView {
	self.view.hidden = NO;
}

- (void)disableActions {
	if (self.interactive) {
		self.interactive = NO;
		[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/locked.png"] forState:UIControlStateNormal];
		[self.view lockNote];
	} else {
		self.interactive = YES;
		[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/unlocked.png"] forState:UIControlStateNormal];
		[self.view unlockNote];
	}

	[self saveNote];
}

- (void)deleteNote {
	if (self.interactive) {
		[[NTSManager sharedInstance] removeNote:self];
	}
}

- (void)resizeView:(UIPanGestureRecognizer *)sender {
	CGPoint translatedPoint = [sender translationInView:sender.view];
	[sender setTranslation:CGPointZero inView:sender.view];

	CGFloat x = self.view.frame.origin.x;
	CGFloat y = self.view.frame.origin.y;

	// CGFloat minHeight = 200;
	// CGFloat minWidth = 200;
	// CGFloat maxHeight = self.view.superview.frame.size.height - 35;
	// CGFloat maxWidth = self.view.superview.frame.size.width - 35;

	CGFloat width = fabs(self.view.frame.size.width + translatedPoint.x);
	CGFloat height = fabs(self.view.frame.size.height + translatedPoint.y);
	CGRect screen = [[UIScreen mainScreen] bounds];

	if (self.view.frame.size.width + translatedPoint.x < 200) {
		width = 200;
	}

	if (CGRectGetMaxX(self.view.frame) > screen.size.width) {
		width -= fabs(screen.size.width - CGRectGetMaxX(self.view.frame));
	}

	if (self.view.frame.size.height + translatedPoint.y < 200) {
		height = 200;
	}

	if (CGRectGetMaxY(self.view.frame) > screen.size.height) {
		height -= fabs(screen.size.height - CGRectGetMaxY(self.view.frame));
	}

	self.view.frame = CGRectMake(x, y, width, height);
	self.size = CGSizeMake(width, height);

	[self saveNote];
}

- (void)dragView:(UIPanGestureRecognizer *)sender {
	if (self.interactive) {
		CGPoint translatedPoint = CGPointMake(sender.view.center.x + [sender translationInView:sender.view.superview].x, sender.view.center.y + [sender translationInView:sender.view.superview].y);

		[self.view.superview bringSubviewToFront:sender.view];
		[sender.view setCenter:translatedPoint];
		[sender setTranslation:CGPointZero inView:sender.view];

		if (sender.state == UIGestureRecognizerStateEnded) {
			BOOL corrected = NO;
			CGFloat pointX = translatedPoint.x;
			CGFloat pointY = translatedPoint.y;
			CGRect screen = [[UIScreen mainScreen] bounds];

			if (CGRectGetMinX(self.view.frame) < screen.origin.x) {
				pointX = self.view.frame.size.width / 2;
				corrected = YES;
			}

			if (CGRectGetMaxX(self.view.frame) > screen.size.width) {
				pointX = screen.size.width - self.view.frame.size.width / 2;
				corrected = YES;
			}

			if (CGRectGetMinY(self.view.frame) < screen.origin.y) {
				pointY = self.view.frame.size.height / 2;
				corrected = YES;
			}

			if (CGRectGetMaxY(self.view.frame) > screen.size.height) {
				pointY = screen.size.height - self.view.frame.size.height / 2;
				corrected = YES;
			}

			if (corrected) {
				[UIView animateWithDuration:0.25 animations:^{
					[[sender view] setCenter:CGPointMake(pointX, pointY)];
				}];
			} else {
				[[sender view] setCenter:CGPointMake(pointX, pointY)];
			}
		}
	}

	[self saveNote];
}

- (void)dismissKeyboard {
	[self.view.textView resignFirstResponder];
	self.text = self.view.textView.text;

	[self saveNote];
}

- (void)saveNote {
	NSError *error;
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NTSManager sharedInstance].notes requiringSecureCoding:NO error:&error];

	[data writeToFile:@"/var/mobile/Library/Application Support/me.renai.notations.data.plist" atomically:NO];
}

@end
