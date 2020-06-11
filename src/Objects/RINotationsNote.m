#import "./RINotationsNote.h"
#import "./RINotationsManager.h"
#import "../UI/RINotationsNoteView.h"

@implementation RINotationsNote

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
		self.view = [[RINotationsNoteView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
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
		[[RINotationsManager sharedInstance] removeNote:self];
	}
}

- (void)resizeView:(UIPanGestureRecognizer *)sender {
	CGPoint translatedPoint = [sender translationInView:sender.view];
	[sender setTranslation:CGPointZero inView:sender.view];

	CGFloat x = self.view.frame.origin.x;
	CGFloat y = self.view.frame.origin.y;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;

	CGFloat minHeight = 200;
	CGFloat minWidth = 200;
	CGFloat maxHeight = self.view.superview.frame.size.height - 35;
	CGFloat maxWidth = self.view.superview.frame.size.width - 35;

	if (height + translatedPoint.y <= minHeight) {
		height = minHeight - translatedPoint.y;
	}

	if (width + translatedPoint.x <= minWidth) {
		width = minWidth - translatedPoint.x;
	}

	if (height + translatedPoint.y >= maxHeight) {
		height = maxHeight - translatedPoint.y;
	}

	if (width + translatedPoint.x >= maxWidth) {
		width = maxWidth - translatedPoint.x;
	}

	self.view.frame = CGRectMake(x, y, width + translatedPoint.x, height + translatedPoint.y);
	self.size = CGSizeMake(width + translatedPoint.x, height + translatedPoint.y);

	[self saveNote];
}

- (void)dragView:(UIPanGestureRecognizer *)sender {
	if (self.interactive) {
		[self.view.superview bringSubviewToFront:sender.view];
		CGPoint translatedPoint = [sender translationInView:sender.view.superview];
		translatedPoint = CGPointMake(sender.view.center.x + translatedPoint.x, sender.view.center.y + translatedPoint.y);

		[sender.view setCenter:translatedPoint];
		[sender setTranslation:CGPointZero inView:sender.view];

		if (sender.state == UIGestureRecognizerStateEnded) {
			CGFloat velocityX = (0.2 * [sender velocityInView:self.view.superview].x);
			CGFloat velocityY = (0.2 * [sender velocityInView:self.view.superview].y);

			CGFloat finalX = translatedPoint.x + velocityX;
			CGFloat finalY = translatedPoint.y + velocityY;

			if (finalX < self.size.width / 2 + 10) {
				finalX = self.size.width / 2 + 10;
			} else if (finalX > self.view.superview.frame.size.width - self.size.width / 2 - 25) {
				finalX = self.view.superview.frame.size.width - self.size.width / 2 - 25;
			}

			if (finalY < self.size.height / 2 + 10) {
				finalY = self.size.height / 2 + 10;
			} else if (finalY > self.view.superview.frame.size.height - self.size.height / 2 - 25) {
				finalY = self.view.superview.frame.size.height - self.size.height / 2 - 25;
			}

			[UIView animateWithDuration:ABS(velocityX) * 0.0002 + 0.2 animations:^{
				[[sender view] setCenter:CGPointMake(finalX, finalY)];
			}];
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
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[RINotationsManager sharedInstance].notes requiringSecureCoding:YES error:&error];

	[data writeToFile:@"/var/mobile/Library/Application Support/me.renai.notations.data.plist" atomically:NO];
}

@end
