#import "Tweak.h"

@interface SBHomeScreenViewController : UIViewController
@end

@interface UIStatusBarWindow : UIWindow
@end

BOOL visible;

%hook SBHomeScreenViewController

- (void)viewDidLoad {

    %orig;
	
    UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createNote:)];
    [self.view addGestureRecognizer:pressRecognizer];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotes:)];
    tapRecognizer.numberOfTapsRequired = 2;

    [self.view addGestureRecognizer:tapRecognizer];


    [[NTSManager sharedInstance] initView];
    [self.view addSubview:[NTSManager sharedInstance].view];
    [[NTSManager sharedInstance] loadNotes];
    [[NTSManager sharedInstance] updateNotes];
}

%new
- (void)showNotes:(UITapGestureRecognizer *)sender {

    if (visible == NO) {

        [NTSManager sharedInstance].view.hidden = NO;
        visible = YES;
    }

    else {

        [NTSManager sharedInstance].view.hidden = YES;
        visible = NO;
    }
}

%new
- (void)createNote:(UILongPressGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateBegan) {

        if (visible == YES) {

            CGPoint position = [sender locationInView:self.view];

            NTSNote *note = [[NTSNote alloc] init];
            note.text = note.textView.text;
            note.x = position.x - 100;
            note.y = position.y - 100;
            note.width = 200;
            note.height = 200;
            note.draggable = YES;
            note.resizeable = YES;

            [[NTSManager sharedInstance] addNote:note];
            [[NTSManager sharedInstance] updateNotes];
        }
    }
}

%end

%hook UIStatusBarWindow

- (instancetype)initWithFrame:(CGRect)frame {

    self = %orig;

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotes:)];
    tapRecognizer.numberOfTapsRequired = 2;

    [self addGestureRecognizer:tapRecognizer];

    return self;
}

%new
- (void)showNotes:(UITapGestureRecognizer *)sender {

    if (visible == NO) {

        [NTSManager sharedInstance].view.hidden = NO;
        visible = YES;
    }

    else {

        [NTSManager sharedInstance].view.hidden = YES;
        visible = NO;
    }
}

%end

%ctor {

    visible = NO;
}