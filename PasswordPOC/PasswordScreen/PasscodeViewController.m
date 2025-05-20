#import "PasscodeViewController.h"
#import "AlertManager.h"
#import "LocalizedStrings.h"
#import "PasscodeDotsView.h"
#import "PasscodeKeypadView.h"

@interface PasscodeViewController () <UITraitChangeObservable> {
    id<UITraitChangeRegistration> _traitToken;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) PasscodeDotsView *dotsView;
@property (nonatomic, strong) PasscodeKeypadView *keypadView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSLayoutConstraint *titleLabelTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *dotsContainerTopConstraint;
@property (nonatomic, strong) NSLayoutConstraint *keypadContainerTopConstraint;

@end

@implementation PasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self checkPasswordStatus];
    [self updateUIForCurrentState];
    
    __weak typeof(self) weakSelf = self;
    _traitToken = [self registerForTraitChanges:@[
        [UITraitVerticalSizeClass class],
        [UITraitHorizontalSizeClass class]
    ] withHandler:^(__kindof id<UITraitEnvironment> env, UITraitCollection *previousTraits) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        
        UIInterfaceOrientation orientation = self.view.window.windowScene.interfaceOrientation;
        CGSize newSize;
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            newSize = CGSizeMake(MAX(self.view.bounds.size.width, self.view.bounds.size.height),
                               MIN(self.view.bounds.size.width, self.view.bounds.size.height));
        } else {
            newSize = CGSizeMake(MIN(self.view.bounds.size.width, self.view.bounds.size.height),
                               MAX(self.view.bounds.size.width, self.view.bounds.size.height));
        }
        
        [self updateLayoutForSize:newSize];
    }];
}

- (void)updateLayoutForSize:(CGSize)size {
    BOOL isPortrait = size.height > size.width;
    CGFloat topSpacing = isPortrait ? 60 : 20;
    CGFloat dotsSpacing = isPortrait ? 20 : 10;
    CGFloat keypadSpacing = isPortrait ? 60 : 30;
    
    [self.titleLabelTopConstraint setConstant:topSpacing];
    [self.dotsContainerTopConstraint setConstant:dotsSpacing];
    [self.keypadContainerTopConstraint setConstant:keypadSpacing];
    
    [self.dotsView updateForSize:size];
    [self.keypadView updateForSize:size];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.backButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    self.titleLabel.text = self.viewModel.screenModel.titleText;
    [self.view addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.font = [UIFont systemFontOfSize:14];
    self.subtitleLabel.textColor = [UIColor secondaryLabelColor];
    self.subtitleLabel.text = @"";
    [self.view addSubview:self.subtitleLabel];
    
    [self setupDots];
    [self setupKeypad];
    
    self.titleLabelTopConstraint = [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:60];
    self.dotsContainerTopConstraint = [self.dotsView.topAnchor constraintEqualToAnchor:self.subtitleLabel.bottomAnchor constant:20];
    self.keypadContainerTopConstraint = [self.keypadView.topAnchor constraintEqualToAnchor:self.dotsView.bottomAnchor constant:60];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [self.backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        self.titleLabelTopConstraint,
        
        [self.subtitleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        
        [self.dotsView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        self.dotsContainerTopConstraint,
        
        [self.keypadView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        self.keypadContainerTopConstraint
    ]];
    [self updateLayoutForSize:self.view.bounds.size];
}

- (void)setupDots {
    self.dotsView = [[PasscodeDotsView alloc] init];
    self.dotsView.digitsCount = self.viewModel.screenModel.digitsCount;
    self.dotsView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.dotsView];
}


- (void)setupKeypad {
    self.keypadView = [[PasscodeKeypadView alloc] init];
    self.keypadView.delegate = self;
    self.keypadView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.keypadView];
}

- (void)updateUIForCurrentState {
    switch (self.viewModel.entryState) {
        case PasscodeEntryStateInitial:
            self.titleLabel.text = [NSString stringWithFormat:@"Enter new %@-digit passcode", @(self.viewModel.screenModel.digitsCount)];
            self.subtitleLabel.text = @"";
            break;
            
        case PasscodeEntryStateConfirmation:
            self.titleLabel.text = [NSString stringWithFormat:@"Confirm your %@-digit passcode", @(self.viewModel.screenModel.digitsCount)];
            self.subtitleLabel.text = @"Enter the same passcode again to confirm";
            break;
            
        case PasscodeEntryStateValidation:
            self.titleLabel.text = [NSString stringWithFormat:@"Enter your %@-digit passcode", @(self.viewModel.screenModel.digitsCount)];
            self.subtitleLabel.text = @"";
            break;
    }
    
    [self resetPasscodeEntry];
}

- (void)processCompletedPasscodeEntry {
    switch (self.viewModel.entryState) {
        case PasscodeEntryStateInitial:
            self.viewModel.initialPasscode = [self.viewModel.enteredPasscode copy];
            self.viewModel.entryState = PasscodeEntryStateConfirmation;
            [self updateUIForCurrentState];
            break;
            
        case PasscodeEntryStateConfirmation:
            if ([self.viewModel.enteredPasscode isEqualToString:self.viewModel.initialPasscode]) {
                [self setPasscode:self.viewModel.enteredPasscode];
            } else {
                [self showPasscodeMismatchError];
                self.viewModel.entryState = PasscodeEntryStateInitial;
                self.viewModel.initialPasscode = @"";
                [self updateUIForCurrentState];
            }
            break;
            
        case PasscodeEntryStateValidation:
            [self validatePasscode:self.viewModel.enteredPasscode];
            break;
    }
}

- (void)showPasscodeMismatchError {
    [AlertManager showNotifyAlertWithTitle:@"Passcodes Don't Match"
                                   message:@"The passcodes you entered don't match. Please try again."
                         confirmActionTitle:[LocalizedStrings ok]
                            viewController:self];
}

- (void)resetPasscodeEntry {
    self.viewModel.enteredPasscode = [NSMutableString string];
    [self.dotsView updateDisplayForEnteredDigitsCount:self.viewModel.enteredPasscode.length];
}

- (void)checkPasswordStatus {
    if (self.viewModel.screenModel.isPasswordSet) {
        [self tryToLoadFromKeychain];
    }
}

- (void)tryToLoadFromKeychain {
    if (self.keychainEnabled) {
        NSError *error = nil;
        if ([self.viewModel canUseBiometricAuthentication:&error]) {
            [self.loadingIndicator startAnimating];
            
            [self.viewModel authenticateWithBiometricsWithCompletion:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [self.viewModel loadPasswordFromKeychainWithCompletion:^(NSString * _Nullable password, NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.loadingIndicator stopAnimating];
                                if (password) {
                                    self.viewModel.enteredPasscode = [NSMutableString stringWithString:password];
                                    [self.dotsView updateDisplayForEnteredDigitsCount:self.viewModel.enteredPasscode.length];
                                    [self validatePasscode:password];
                                } else if (error) {
                                    if (self.onPasscodeValidated) {
                                        self.onPasscodeValidated(NO, error);
                                    }
                                }
                            });
                        }];
                    } else {
                        [self.loadingIndicator stopAnimating];
                    }
                });
            }];
        }
    }
}

- (void)setPasscode:(NSString *)passcode {
    [self.loadingIndicator startAnimating];
    __weak typeof(self) weakSelf = self;
    [self.viewModel setPassword:passcode completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            if (success) {
                if (weakSelf.keychainEnabled) {
                    [AlertManager showConfirmationAlertWithTitle:[LocalizedStrings success]
                                                         message:[LocalizedStrings saveToKeychainQuestion]
                                                  viewController:weakSelf
                                              confirmActionTitle:[LocalizedStrings yes]
                                                  confirmHandler:^{
                        [weakSelf.viewModel savePasswordToKeychain:passcode
                                                        completion:^(BOOL success,
                                                                     NSError * _Nullable error) {
                            if (weakSelf.onPasscodeSet) {
                                weakSelf.onPasscodeSet(YES, nil);
                            }
                        }];
                    }
                                               cancelActionTitle:[LocalizedStrings no]
                                                   cancelHandler:^{
                        if (weakSelf.onPasscodeSet) {
                            weakSelf.onPasscodeSet(YES, nil);
                        }
                    }];
                } else {
                    if (weakSelf.onPasscodeSet) {
                        weakSelf.onPasscodeSet(YES, nil);
                    }
                }
            } else {
                [weakSelf resetPasscodeAndShowError:error];
                if (weakSelf.onPasscodeSet) {
                    weakSelf.onPasscodeSet(NO, error);
                }
            }
        });
    }];
}

- (void)validatePasscode:(NSString *)passcode {
    [self.loadingIndicator startAnimating];
    
    [self.viewModel validatePassword:passcode completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];
            
            if (success) {
                if (self.onPasscodeValidated) {
                    self.onPasscodeValidated(YES, nil);
                }
            } else {
                [self resetPasscodeAndShowError:error];
                if (self.onPasscodeValidated) {
                    self.onPasscodeValidated(NO, error);
                }
            }
        });
    }];
}

- (void)resetPasscodeAndShowError:(NSError *)error {
    self.viewModel.enteredPasscode = [NSMutableString string];
    
    [self.dotsView updateDisplayForEnteredDigitsCount:self.viewModel.enteredPasscode.length];

    if (error) {
        [AlertManager showNotifyAlertWithTitle:[LocalizedStrings error]
                                       message:error.localizedDescription
                             confirmActionTitle:[LocalizedStrings ok]
                                viewController:self];
    }
}

#pragma mark - PasscodeKeypadViewDelegate

- (void)keypadButtonTapped:(NSInteger)digit {
    if (self.viewModel.enteredPasscode.length >= self.viewModel.screenModel.digitsCount) {
        return;
    }
    [self.viewModel.enteredPasscode appendString:[NSString stringWithFormat:@"%ld", (long)digit]];
    [self.dotsView updateDisplayForEnteredDigitsCount:self.viewModel.enteredPasscode.length];
    if (self.viewModel.enteredPasscode.length == self.viewModel.screenModel.digitsCount) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self processCompletedPasscodeEntry];
        });
    }
}

- (void)deleteButtonTapped {
    if (self.viewModel.enteredPasscode.length > 0) {
        [self.viewModel.enteredPasscode deleteCharactersInRange:NSMakeRange(self.viewModel.enteredPasscode.length - 1, 1)];
        [self.dotsView updateDisplayForEnteredDigitsCount:self.viewModel.enteredPasscode.length];
    }
}

- (void)backButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    if (_traitToken) {
            [self unregisterForTraitChanges:_traitToken];
            _traitToken = nil;
        }
}

@end 
