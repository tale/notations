#import "NTSNote.h"
#import "../Manager/NTSManager.h"
#import "../UI/Notes/NTSNoteView.h"

@implementation NTSNote

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [super init];

	if (self) {
		self.text = [decoder decodeObjectForKey:@"noteText"];

		self.x = [decoder decodeIntegerForKey:@"x"];
		self.y = [decoder decodeIntegerForKey:@"y"];
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

	[encoder encodeInteger:self.view.frame.origin.x forKey:@"x"];
	[encoder encodeInteger:self.view.frame.origin.y forKey:@"y"];
	[encoder encodeInteger:self.width forKey:@"width"];
	[encoder encodeInteger:self.height forKey:@"height"];

	[encoder encodeBool:self.draggable forKey:@"draggable"];
	[encoder encodeBool:self.resizeable forKey:@"resizeable"];
	[encoder encodeBool:self.presented forKey:@"presented"];
}

- (void)setupView {
	if (!self.presented) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];

		self.view = [[NTSNoteView alloc] initWithFrame:CGRectMake(self.x, self.y, self.width, self.height)];
		self.view.translatesAutoresizingMaskIntoConstraints = YES;

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

			if (finalX < 0) {
				finalX = 0;
			} else if (finalX > self.view.superview.frame.size.width) {
				finalX = self.view.superview.frame.size.width;
			}

			if (finalY < 50) {
				finalY = 50;
			} else if (finalY > self.view.superview.frame.size.height) {
				finalY = self.view.superview.frame.size.height;
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

	if (height + translatedPoint.y <= minHeight) height = minHeight - translatedPoint.y;
	if (width+translatedPoint.x <= minWidth) width = minWidth - translatedPoint.x;
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

- (void)keyboardDidShow {
	self.cachedX = (int) self.x;
	self.cachedY = (int) self.y;

	self.x = 20;
	self.y = 20;

	[UIView animateWithDuration:0.25 animations:^{
		self.view.frame = CGRectMake(self.x, self.y, self.view.frame.size.width, self.view.frame.size.height);
	}];
	[self saveNote];
}

- (void)keyboardDidHide {
	self.x = self.cachedX;
	self.y = self.cachedY;

	self.cachedY = 0;
	self.cachedY = 0;

	[UIView animateWithDuration:0.25 animations:^{
		self.view.frame = CGRectMake(self.x, self.y, self.view.frame.size.width, self.view.frame.size.height);
	}];
	[self saveNote];
}

@end
