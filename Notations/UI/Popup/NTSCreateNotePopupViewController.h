#import "NTSPopupViewController.h"

@interface NTSCreateNotePopupViewController : NTSPopupViewController <UITextFieldDelegate> {
	CGFloat _keyboardHeight;
}

@property (nonatomic, retain) UIButton *createButton;
@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) UITextField *bodyTextField;

@end
