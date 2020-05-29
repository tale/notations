#import "NTSNote.h"
#import "../Manager/NTSManager.h"
#import "../UI/Notes/NTSNoteView.h"

@implementation NTSNote

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [super init];

	if (self) {
		self.text = [decoder decodeObjectForKey:@"noteText"];

		self.center = CGPointFromString([decoder decodeObjectForKey:@"center"]);
		self.width = [decoder decodeIntegerForKey:@"width"];
		self.height = [decoder decodeIntegerForKey:@"height"];

		self.draggable = [decoder decodeBoolForKey:@"draggable"];
		self.resizeable = [decoder decodeBoolForKey:@"resizeable"];
		self.presented = [decoder decodeBoolForKey:@"presented"];
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.text forKey:@"noteText"];

	[encoder encodeObject:NSStringFromCGPoint(self.view.center) forKey:@"center"];
	[encoder encodeInteger:self.width forKey:@"width"];
	[encoder encodeInteger:self.height forKey:@"height"];

	[encoder encodeBool:self.draggable forKey:@"draggable"];
	[encoder encodeBool:self.resizeable forKey:@"resizeable"];
	[encoder encodeBool:self.presented forKey:@"presented"];
}

- (void)setupView {
	if (!self.presented) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];

		self.view = [[NTSNoteView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
		self.view.translatesAutoresizingMaskIntoConstraints = YES;

		CGFloat finalX = self.view.center.x;
		CGFloat finalY = self.view.center.y;

		if (finalX < self.width / 2 + 10) {
			finalX = self.width / 2 + self.center.x - 100;
		} else if (finalX > self.view.superview.frame.size.width - self.width / 2 - 25) {
			finalX = self.view.superview.frame.size.width - self.width / 2 - self.center.x - 100;
		}

		if (finalY < self.height / 2 + 10) {
			finalY = self.height / 2 + self.center.y - 100;
		} else if (finalY > self.view.superview.frame.size.height - self.height / 2 - 25) {
			finalY = self.view.superview.frame.size.height - self.height / 2 - self.center.y - 100;
		}

		self.center = CGPointMake(finalX, finalY);
		self.view.center = self.center;

		[self.view.lockButton addTarget:self action:@selector(disableActions) forControlEvents:UIControlEventTouchUpInside];
		[self.view.deleteButton addTarget:self action:@selector(deleteNote) forControlEvents:UIControlEventTouchUpInside];

		UIPanGestureRecognizer *dragResize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeView:)];
		[self.view.resizeGrabber addGestureRecognizer:dragResize];

		UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
		[self.view addGestureRecognizer:dragGesture];

		if (self.draggable) {
			[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/unlocked.png"] forState:UIControlStateNormal];
		} else {
			[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/locked.png"] forState:UIControlStateNormal];
		}

		UIToolbar* keyboardBar = [[UIToolbar alloc] init];
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

- (void)dragView:(UIPanGestureRecognizer*)gesture {
	if (self.draggable) {
		[self.view.superview bringSubviewToFront:gesture.view];
		CGPoint translatedPoint = [gesture translationInView:gesture.view.superview];
		translatedPoint = CGPointMake(gesture.view.center.x + translatedPoint.x, gesture.view.center.y + translatedPoint.y);

		[gesture.view setCenter:translatedPoint];
		[gesture setTranslation:CGPointZero inView:gesture.view];

		if (gesture.state == UIGestureRecognizerStateEnded) {
			CGFloat velocityX = (0.2 * [gesture velocityInView:self.view.superview].x);
			CGFloat velocityY = (0.2 * [gesture velocityInView:self.view.superview].y);

			CGFloat finalX = translatedPoint.x + velocityX;
			CGFloat finalY = translatedPoint.y + velocityY;

			if (finalX < self.width / 2 + 10) {
				finalX = self.width / 2 + 10;
			} else if (finalX > self.view.superview.frame.size.width - self.width / 2 - 25) {
				finalX = self.view.superview.frame.size.width - self.width / 2 - 25;
			}

			if (finalY < self.height / 2 + 10) {
				finalY = self.height / 2 + 10;
			} else if (finalY > self.view.superview.frame.size.height - self.height / 2 - 25) {
				finalY = self.view.superview.frame.size.height - self.height / 2 - 25;
			}

			[UIView animateWithDuration:ABS(velocityX) * 0.0002 + 0.2 animations:^{
				[[gesture view] setCenter:CGPointMake(finalX, finalY)];
			}];
		}
	}

	[self saveNote];
}

- (void)resizeView:(UIPanGestureRecognizer *)gesture {
	CGPoint translatedPoint = [gesture translationInView:gesture.view];
	[gesture setTranslation:CGPointZero inView:gesture.view];

	CGFloat x = self.view.frame.origin.x;
	CGFloat y = self.view.frame.origin.y;
	CGFloat width = self.view.frame.size.width;
	CGFloat height = self.view.frame.size.height;

	CGFloat minHeight = 200;
	CGFloat minWidth = 200;

	CGFloat maxHeight = self.view.superview.frame.size.height - 35;
	CGFloat maxWidth = self.view.superview.frame.size.width - 35;

	if (height + translatedPoint.y <= minHeight) height = minHeight - translatedPoint.y;
	if (width + translatedPoint.x <= minWidth) width = minWidth - translatedPoint.x;

	if (height + translatedPoint.y >= maxHeight) height = maxHeight - translatedPoint.y;
	if (width + translatedPoint.x >= maxWidth) width = maxWidth - translatedPoint.x;

	self.view.frame = CGRectMake(x, y, width + translatedPoint.x, height + translatedPoint.y);
	self.width = width + translatedPoint.x;
	self.height = height + translatedPoint.y;

	[self saveNote];
}

- (void)disableActions {
	if (self.draggable) {
		self.draggable = NO;
		self.resizeable = NO;
		[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/locked.png"] forState:UIControlStateNormal];
		[self.view lockNote];
	} else {
		self.draggable = YES;
		self.resizeable = NO;
		[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/unlocked.png"] forState:UIControlStateNormal];
		[self.view unlockNote];
	}
	[self saveNote];
}


- (void)deleteNote {
	if (self.draggable) {
		[[NTSManager sharedInstance] removeNote:self];
	}
}

- (void)saveNote {
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[NTSManager sharedInstance].notes] forKey:@"notations_notes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dismissKeyboard {
	[self.view.textView resignFirstResponder];
	self.text = self.view.textView.text;
	[self saveNote];
}

- (void)willShowView {
	[self.view updateEffect];
}

- (void)didShowView {
	self.view.hidden = NO;
}

- (void)willHideView {
	self.view.hidden = YES;
}

- (void)keyboardDidShow:(NSNotification *)notification {
	NSInteger keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
	self.centerCache = self.center;

	if ([[UIScreen mainScreen] bounds].size.height - self.center.y + self.height / 2 >= [[UIScreen mainScreen] bounds].size.height - keyboardHeight) {
		NSLog(@"[NOTATIONS] WOWOWOWOW");
		[UIView animateWithDuration:0.25 animations:^{
			self.center = CGPointMake(self.center.x, [[UIScreen mainScreen] bounds].size.height - keyboardHeight - 300);
			[self setupView];
		}];
	}

	[self saveNote];
}

- (void)keyboardDidHide {
	// self.x = self.cachedX;
	// self.y = self.cachedY;

	// self.cachedY = 0;
	// self.cachedY = 0;

	// [UIView animateWithDuration:0.25 animations:^{
	// 	self.view.frame = CGRectMake(self.x, self.y, self.view.frame.size.width, self.view.frame.size.height);
	// }];
	// [self saveNote];
}

@end
