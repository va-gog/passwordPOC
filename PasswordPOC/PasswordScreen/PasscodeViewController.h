//
//  PasscodeViewController.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 04.06.25.
//

#import <UIKit/UIKit.h>
#import "PasswordTypes.h"
#import "PasswordViewModel.h"
#import "PasscodeKeypadView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PasscodeViewController : UIViewController <UITraitChangeObservable, PasscodeKeypadViewDelegate>

@property (nonatomic, strong) PasswordViewModel *viewModel;
@property (nonatomic) BOOL keychainEnabled;

@property (nonatomic, copy) void (^onPasscodeValidated)(BOOL success, NSError * _Nullable error);
@property (nonatomic, copy) void (^onPasscodeSet)(BOOL success, NSError * _Nullable error);

@end

NS_ASSUME_NONNULL_END 
