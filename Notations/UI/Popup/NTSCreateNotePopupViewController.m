#import "NTSCreateNotePopupViewController.h"
#import "../../Manager/NTSManager.h"
#import "../../Objects/NTSNote.h"

@implementation NTSCreateNotePopupViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Title text field
	self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 55, 291, 50)];
	self.titleTextField.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.95 alpha:1.0];
	self.titleTextField.layer.cornerRadius = 7.5;
	self.titleTextField.textColor = [UIColor blackColor];
	self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.83 green:0.83 blue:0.85 alpha:1.0]}];
	self.titleTextField.delegate = self;
	[self.view addSubview:self.titleTextField];

	// Body text field
	self.bodyTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 119, 291, 110)];
	self.bodyTextField.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.95 alpha:1.0];
	self.bodyTextField.layer.cornerRadius = 7.5;
	self.bodyTextField.textColor = [UIColor blackColor];
	self.bodyTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Text" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.83 green:0.83 blue:0.85 alpha:1.0]}];
	self.bodyTextField.delegate = self;
	[self.view addSubview:self.bodyTextField];

	UIView *titleSpacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
	[self.titleTextField setLeftViewMode:UITextFieldViewModeAlways];
	[self.titleTextField setLeftView:titleSpacer];

	UIView *bodySpacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
	[self.bodyTextField setLeftViewMode:UITextFieldViewModeAlways];
	[self.bodyTextField setLeftView:bodySpacer];

	// Create Note button
	self.createButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.createButton.frame = CGRectMake(36, self.view.bounds.size.height/2 - 84, 291, 50);
	self.createButton.backgroundColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.85 alpha:1.0];
	self.createButton.layer.cornerRadius = 7.5;
	[self.createButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[self.createButton setTitle:@"Create Note" forState:UIControlStateNormal];
	[self.createButton addTarget:self action:@selector(createNote) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.createButton];

	// Get keyboard frame
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)createNote {
	NTSNote *note = [[NTSNote alloc] init];
	note.text = self.bodyTextField.text;
	note.x = [UIScreen mainScreen].bounds.size.width/2 - 100;
	note.y = [UIScreen mainScreen].bounds.size.height/2 - 100;
	note.width = 200;
	note.height = 200;
	note.draggable = YES;
	note.resizeable = YES;
	[[NTSManager sharedInstance] addNote:note];
	[self dismiss];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
	_keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[UIView animateWithDuration:0.2 animations:^{
		// TODO: find way to get keyboard height better
		// The first time this method is called, _keyboardHeight is 0.
		self.view.transform = CGAffineTransformMakeTranslation(0, -(_keyboardHeight ?: 260));
	} completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[UIView animateWithDuration:0.2 animations:^{
		self.view.transform = CGAffineTransformIdentity;
	} completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

@end
