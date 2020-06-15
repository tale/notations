#import <Foundation/Foundation.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>

@interface UIColor (iOS13Fix)

@property (class, nonatomic, readonly) UIColor *labelColor;

@end

@protocol PreferencesTableCustomView

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier;
- (CGFloat)preferredHeightForWidth:(CGFloat)width;

@end

@interface AppearanceTypeStackView : UIView
@end

@interface NTSAppearanceCell : PSTableCell <PreferencesTableCustomView>

@property (nonatomic, retain) UIStackView *containerStackView;
@property (nonatomic, retain) AppearanceTypeStackView *leftStackView;
@property (nonatomic, retain) AppearanceTypeStackView *centerStackView;
@property (nonatomic, retain) AppearanceTypeStackView *rightStackView;

- (void)updateForType:(int)type;

@end

@interface AppearanceTypeStackView ()

@property (nonatomic, retain) UIImage *iconImage;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UILabel *captionLabel;
@property (nonatomic, retain) UIButton *checkmarkButton;
@property (nonatomic, retain) UIStackView *contentStackview;
@property (nonatomic, retain) NTSAppearanceCell *hostController;
@property (nonatomic, retain) UIImpactFeedbackGenerator *feedbackGenerator;
@property (nonatomic, retain) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) int type;

@end

@interface UIImage (Private)

 + (UIImage*)kitImageNamed:(NSString*)name;

 @end
