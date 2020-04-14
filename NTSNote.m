#import "NTSNote.h"

@implementation NTSNote

UIImage *lockedGlyph;
UIImage *unlockedGlyph;
UIImage *deleteGlyph;

UIButton *lockButton;
UIButton *deleteButton;

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

		UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragView:)];

		self.view = [[UIView alloc] initWithFrame:CGRectMake(self.x, self.y, self.width, self.height)];
		self.view.layer.cornerRadius = 20.0;

		UIBlurEffect *blurEffect;

		if ([NTSManager sharedInstance].colorStyle == 0) {

			if (SYSTEM_VERSION(@"13.0")) {

				blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
			}

			else {

				blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
			}
		}

		else if ([NTSManager sharedInstance].colorStyle == 2) {

			blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		}

		else {

			blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		}

		UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

		blurEffectView.layer.cornerRadius = 20;
		blurEffectView.frame = self.view.bounds;
		blurEffectView.layer.masksToBounds = YES;
		blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		[self.view setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:blurEffectView];
		[self.view addGestureRecognizer:dragGesture];
		[self.view setUserInteractionEnabled:YES];

		lockedGlyph = [[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/locked.png"];
		unlockedGlyph = [[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/unlocked.png"];
		deleteGlyph = [[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/delete.png"];
		UIColor *buttonColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];

		lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
		deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];

		[lockButton setImage:unlockedGlyph forState:UIControlStateNormal];
		[lockButton addTarget:self action:@selector(disableActions) forControlEvents:UIControlEventTouchUpInside];
		[lockButton setBackgroundColor:buttonColor];
		lockButton.frame = CGRectMake(5, 5, 30, 30);
		lockButton.layer.cornerRadius = 15.0;

		if (self.draggable) {

			[lockButton setImage:unlockedGlyph forState:UIControlStateNormal];
		}

		else {

			[lockButton setImage:lockedGlyph forState:UIControlStateNormal];
		}

		[deleteButton setImage:deleteGlyph forState:UIControlStateNormal];
		[deleteButton addTarget:self action:@selector(deleteNote) forControlEvents:UIControlEventTouchUpInside];
		[deleteButton setBackgroundColor:buttonColor];
		deleteButton.frame = CGRectMake(self.width - 35, 5, 30, 30);
		deleteButton.layer.cornerRadius = 15.0;

		[self.view addSubview:lockButton];
		[self.view addSubview:deleteButton];

		UIToolbar* keyboardBar = [[UIToolbar alloc] init];
		[keyboardBar sizeToFit];

		UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];

		keyboardBar.items = @[flexBarButton, doneBarButton];

		self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 50, self.width - 20, self.height - 60)];
		self.textView.inputAccessoryView = keyboardBar;

		[self.textView setBackgroundColor:[UIColor clearColor]];
		[self.textView setFont:[UIFont systemFontOfSize:[NTSManager sharedInstance].textSize]];

		if ([NTSManager sharedInstance].textAlignment == 1) {

			self.textView.textAlignment = NSTextAlignmentLeft;
		}

		else if ([NTSManager sharedInstance].textAlignment == 2) {

			self.textView.textAlignment = NSTextAlignmentCenter;
		}

		else if ([NTSManager sharedInstance].textAlignment == 3) {

			self.textView.textAlignment = NSTextAlignmentRight;
		}

		else if ([NTSManager sharedInstance].textAlignment == 4) {

			self.textView.textAlignment = NSTextAlignmentJustified;
		}

		else {

			self.textView.textAlignment = NSTextAlignmentNatural;
		}

		[self.view addSubview:self.textView];

		if (self.text != nil) {

			self.textView.text = self.text;
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
		[lockButton setImage:lockedGlyph forState:UIControlStateNormal];
	}

	else if (self.draggable == NO) {

		self.draggable = YES;
		[lockButton setImage:unlockedGlyph forState:UIControlStateNormal];
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

	[self.textView resignFirstResponder];
	self.text = self.textView.text;
	[self saveNote];
}

@end