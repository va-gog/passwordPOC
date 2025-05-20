#import <UIKit/UIKit.h>
#import "PasswordTypes.h"
#import "PasswordViewModel.h"

NS_ASSUME_NONNULL_BEGIN

// Enum to track the current state of the passcode entry
typedef NS_ENUM(NSInteger, PasscodeEntryState) {
    PasscodeEntryStateInitial,          // Initial entry state
    PasscodeEntryStateConfirmation,     // Confirmation entry state (for new passcodes)
    PasscodeEntryStateValidation        // Validation state (for existing passcodes)
};

@interface PasscodeViewController : UIViewController <UITraitChangeObservable>

@property (nonatomic, strong) PasswordViewModel *viewModel;
@property (nonatomic) BOOL keychainEnabled;

@property (nonatomic, copy) void (^onPasscodeValidated)(BOOL success, NSError * _Nullable error);
@property (nonatomic, copy) void (^onPasscodeSet)(BOOL success, NSError * _Nullable error);

// Properties to support orientation changes
@property (nonatomic, strong) NSLayoutConstraint *titleLabelTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *dotsContainerTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *keypadContainerTopConstraint;

@end

NS_ASSUME_NONNULL_END 
