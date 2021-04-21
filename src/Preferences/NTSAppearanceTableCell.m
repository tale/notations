#import "./NTSAppearanceTableCell.h"

NSString *leftOptionName;
NSString *leftOptionImage;

NSString *centerOptionName;
NSString *centerOptionImage;

NSString *rightOptionName;
NSString *rightOptionImage;

NSString *postNotification;
NSString *defaults;
NSString *key;

UIImage *unchecked;
UIImage *checked;

@implementation AppearanceTypeStackView

- (instancetype)initWithType:(int)type forController:(NTSAppearanceCell *)controller {
	self = [super init];

	if (self) {
		self.hostController = controller;
		self.captionLabel = [[UILabel alloc] init];
		self.checkmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
   	 	self.checkmarkButton.frame = CGRectMake(0, 0, 22, 22);

		self.feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:(UIImpactFeedbackStyleMedium)];
		[self.feedbackGenerator prepare];

		self.type = type;

		if (self.type == 0) {
			self.iconImage = [UIImage imageWithContentsOfFile:leftOptionImage];
			self.captionLabel.text = leftOptionName;
		} else if (self.type == 1) {
	  		self.iconImage = [UIImage imageWithContentsOfFile:centerOptionImage];
	  		self.captionLabel.text = centerOptionName;
		} else if (self.type == 2) {
			self.iconImage = [UIImage imageWithContentsOfFile:rightOptionImage];
			self.captionLabel.text = rightOptionName;
		}

		NSMutableDictionary *preferences;
		CFArrayRef preferencesKeyList = CFPreferencesCopyKeyList(CFSTR("me.tale.notations-legacy"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (preferencesKeyList) {
			preferences = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(preferencesKeyList, CFSTR("me.tale.notations-legacy"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
			CFRelease(preferencesKeyList);
		} else {
			preferences = nil;
		}

		if (preferences == nil) {
			preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", @"me.tale.notations-legacy"]];
		}

		checked = [[UIImage kitImageNamed:@"UITintedCircularButtonCheckmark.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

		unchecked = [[UIImage kitImageNamed:@"UIRemoveControlMultiNotCheckedImage.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

		NSNumber *appearanceStyle = [NSNumber numberWithInt:[([preferences objectForKey:key] ?: @(0)) integerValue]];
		if ([appearanceStyle isEqualToNumber:[NSNumber numberWithInt:self.type]]) {
	  		[self.checkmarkButton setImage:checked forState:UIControlStateNormal];
			self.checkmarkButton.tintColor = [UIColor systemBlueColor];
		} else {
	  		[self.checkmarkButton setImage:unchecked forState:UIControlStateNormal];
			self.checkmarkButton.tintColor = [UIColor systemGrayColor];
		}

		self.iconView = [[UIImageView alloc] initWithImage:self.iconImage];
		// self.iconView.contentMode = UIViewContentModeScaleAspectFit;
		[self.iconView.heightAnchor constraintEqualToConstant:120].active = true;
		[self.iconView.widthAnchor constraintEqualToConstant:60].active = true;

		[self.captionLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
		[self.captionLabel.heightAnchor constraintEqualToConstant:20].active = true;

		if (@available(iOS 13, *)) {
	  		[self.captionLabel setTextColor:[UIColor labelColor]];
		} else {
	  		[self.captionLabel setTextColor:[UIColor blackColor]];
		}

		[self.checkmarkButton.heightAnchor constraintEqualToConstant:22].active = true;
		[self.checkmarkButton.widthAnchor constraintEqualToConstant:22].active = true;
		[self.checkmarkButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

		self.contentStackview = [[UIStackView alloc] init];
		self.contentStackview.axis = UILayoutConstraintAxisVertical;
		self.contentStackview.alignment = UIStackViewAlignmentCenter;
		self.contentStackview.spacing = 8;

		[self.contentStackview addArrangedSubview:self.iconView];
		[self.contentStackview addArrangedSubview:self.captionLabel];
		[self.contentStackview addArrangedSubview:self.checkmarkButton];

		self.contentStackview.translatesAutoresizingMaskIntoConstraints = false;
		self.translatesAutoresizingMaskIntoConstraints = false;

		self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped:)];
		self.tapGestureRecognizer.numberOfTapsRequired = 1;

		[self addSubview:self.contentStackview];
		[self.contentStackview setUserInteractionEnabled:YES];
		[self.contentStackview addGestureRecognizer:self.tapGestureRecognizer];

		[self.widthAnchor constraintEqualToConstant:55].active = true;
		[self.heightAnchor constraintEqualToConstant:140].active = true;
	}

	return self;
}

- (void)buttonTapped:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.alpha = 0.5;
		} completion:^(BOOL finished) {}];
	} else if (sender.state == UIGestureRecognizerStateEnded){
		[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			self.alpha = 1.0;
		} completion:^(BOOL finished) {}];
	}

	[self.feedbackGenerator impactOccurred];

	CFPreferencesSetValue((CFStringRef) key, CFBridgingRetain([NSNumber numberWithInt:self.type]), (CFStringRef) defaults, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

  	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef) postNotification, NULL, NULL, YES);

	[self.hostController updateForType:self.type];
}

@end

@implementation NTSAppearanceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

  	if (self) {
		leftOptionName = specifier.properties[@"leftOptionName"];
		centerOptionName = specifier.properties[@"centerOptionName"];
		rightOptionName = specifier.properties[@"rightOptionName"];
		leftOptionImage = specifier.properties[@"leftOptionImage"];
		centerOptionImage = specifier.properties[@"centerOptionImage"];
		rightOptionImage = specifier.properties[@"rightOptionImage"];
		defaults = specifier.properties[@"defaults"];
		postNotification = specifier.properties[@"PostNotification"];
		key = specifier.properties[@"key"];

		self.leftStackView = [[AppearanceTypeStackView alloc] initWithType:0 forController:self];
		self.centerStackView =[[AppearanceTypeStackView alloc] initWithType:1 forController:self];
		self.rightStackView = [[AppearanceTypeStackView alloc] initWithType:2 forController:self];

		self.containerStackView = [[UIStackView alloc] init];
		self.containerStackView.axis = UILayoutConstraintAxisHorizontal;
		self.containerStackView.alignment = UIStackViewAlignmentCenter;
		self.containerStackView.distribution = UIStackViewDistributionEqualSpacing;
		self.containerStackView.spacing = 50;
		self.containerStackView.translatesAutoresizingMaskIntoConstraints = NO;

		[self.containerStackView addArrangedSubview:self.leftStackView];
		[self.containerStackView addArrangedSubview:self.centerStackView];
		[self.containerStackView addArrangedSubview:self.rightStackView];
		[self.contentView addSubview:self.containerStackView];

		[self.containerStackView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = true;
		[self.containerStackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = true;
		[self.heightAnchor constraintEqualToConstant:179].active = true;
	}

  return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
	self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NTSAppearanceCell" specifier:specifier];
  	return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 410.0f;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)tableView {
	return [self preferredHeightForWidth:width];
}

- (void)updateForType:(int)type {
	AppearanceTypeStackView *notSelect1;
	AppearanceTypeStackView *notSelect2;
	AppearanceTypeStackView *toSelect;

  	if (type == 1) {
		notSelect1 = self.leftStackView;
		notSelect2 = self.rightStackView;
		toSelect = self.centerStackView;
  	} else if (type == 2) {
		notSelect1 = self.leftStackView;
		notSelect2 = self.centerStackView;
		toSelect = self.rightStackView;
	} else {
		notSelect1 = self.centerStackView;
		notSelect2 = self.rightStackView;
		toSelect = self.leftStackView;
  	}

	[UIView transitionWithView:notSelect1.checkmarkButton duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[notSelect1.checkmarkButton setImage:unchecked forState:UIControlStateNormal];
		notSelect1.checkmarkButton.tintColor = [UIColor systemGrayColor];
	} completion:^(BOOL finished) {
		finished = YES;
	}];

	[UIView transitionWithView:notSelect2.checkmarkButton duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[notSelect2.checkmarkButton setImage:unchecked forState:UIControlStateNormal];
		notSelect2.checkmarkButton.tintColor = [UIColor systemGrayColor];
	} completion:^(BOOL finished) {
		finished = YES;
	}];

  	[UIView transitionWithView:toSelect.checkmarkButton duration:0.2f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
		[toSelect.checkmarkButton setImage:checked forState:UIControlStateNormal];
		toSelect.checkmarkButton.tintColor = [UIColor systemBlueColor];
	} completion:^(BOOL finished) {
		finished = YES;
	}];
}

@end

