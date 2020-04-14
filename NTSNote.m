#import "NTSNote.h"
#import "NTSManager.h"
#import "NTSNoteView.h"

@implementation NTSNote

- (void)encodeWithCoder:(NSCoder *)encoder {

	[encoder encodeObject:self.text forKey:@"noteText"];

	[encoder encodeInteger:self.x forKey:@"x"];
	[encoder encodeInteger:self.y forKey:@"y"];
	[encoder encodeInteger:self.width forKey:@"width"];
	[encoder encodeInteger:self.height forKey:@"height"];

	[encoder encodeBool:self.draggable forKey:@"draggable"];
	[encoder encodeBool:self.resizeable forKey:@"resizeable"];
	[encoder encodeBool:self.presented forKey:@"presented"];
}

- (id)initWithCoder:(NSCoder *)decoder {

	if(self = [super init]) {

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

- (void)setupView {

	if (self.presented == NO) {

		self.view = [[NTSNoteView alloc] initWithFrame:CGRectMake(self.x, self.y, self.width, self.height)];

		[self.view.lockButton addTarget:self action:@selector(disableActions) forControlEvents:UIControlEventTouchUpInside];
		[self.view.deleteButton addTarget:self action:@selector(deleteNote) forControlEvents:UIControlEventTouchUpInside];

		UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];
		[self.view addGestureRecognizer:dragGesture];

		if (self.draggable) {

			[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/unlocked.png"] forState:UIControlStateNormal];
		}

		else {

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
			}

			else if (finalX > self.view.superview.frame.size.width) {

				finalX = self.view.superview.frame.size.width;
			}

			if (finalY < 50) {

				finalY = 50;
			}

			else if (finalY > self.view.superview.frame.size.height) {

				finalY = self.view.superview.frame.size.height;
			}

			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:(ABS(velocityX) * 0.0002) + 0.2];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDelegate:self.view];
			[UIView setAnimationDidStopSelector:@selector(animationDidFinish)];

			[[gesture view] setCenter:CGPointMake(finalX, finalY)];
			[UIView commitAnimations];
		}
	}

	[self saveNote];
}

- (void)disableActions {

	if (self.draggable) {

		self.draggable = NO;
		[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/locked.png"] forState:UIControlStateNormal];
	}

	else if (self.draggable == NO) {

		self.draggable = YES;
		[self.view.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/unlocked.png"] forState:UIControlStateNormal];
	}

	[self saveNote];
}


- (void)deleteNote {

	[[NTSManager sharedInstance] removeNote:self];
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

@end