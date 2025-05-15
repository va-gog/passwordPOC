#import "PasscodeViewController.h"
#import "AlertManager.h"
#import "LocalizedStrings.h"

@interface PasscodeViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *dotsContainerView;
@property (nonatomic, strong) NSMutableArray<UIView *> *dotViews;
@property (nonatomic, strong) UIView *keypadContainerView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *keypadButtons;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) NSMutableString *enteredPasscode;
@property (nonatomic, strong) NSString *initialPasscode;
@property (nonatomic, assign) PasscodeEntryState entryState;

@end

@implementation PasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enteredPasscode = [NSMutableString string];
    
    if (self.viewModel.screenModel.isPasswordSet) {
        self.entryState = PasscodeEntryStateValidation;
    } else {
        self.entryState = PasscodeEntryStateInitial;
    }
    
    [self setupUI];
    [self checkPasswordStatus];
    [self updateUIForCurrentState];
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
    
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [self.backButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.backButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:60],
        
        [self.subtitleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8],
        
        [self.dotsContainerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.dotsContainerView.topAnchor constraintEqualToAnchor:self.subtitleLabel.bottomAnchor constant:20],
        [self.dotsContainerView.widthAnchor constraintEqualToConstant:self.viewModel.screenModel.digitsCount * 20 + (self.viewModel.screenModel.digitsCount - 1) * 20],
        [self.dotsContainerView.heightAnchor constraintEqualToConstant:20],
        
        [self.keypadContainerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.keypadContainerView.topAnchor constraintEqualToAnchor:self.dotsContainerView.bottomAnchor constant:60],
        [self.keypadContainerView.widthAnchor constraintEqualToConstant:280],
        [self.keypadContainerView.heightAnchor constraintEqualToConstant:400]
    ]];
}

- (void)setupDots {
    self.dotsContainerView = [[UIView alloc] init];
    self.dotsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.dotsContainerView];
    
    self.dotViews = [NSMutableArray array];
    for (int i = 0; i < self.viewModel.screenModel.digitsCount; i++) {
        UIView *dotView = [[UIView alloc] init];
        dotView.translatesAutoresizingMaskIntoConstraints = NO;
        dotView.backgroundColor = [UIColor systemGrayColor];
        dotView.layer.cornerRadius = 10;
        dotView.alpha = 0.3;
        [self.dotsContainerView addSubview:dotView];
        [self.dotViews addObject:dotView];
        
        [NSLayoutConstraint activateConstraints:@[
            [dotView.widthAnchor constraintEqualToConstant:20],
            [dotView.heightAnchor constraintEqualToConstant:20],
            [dotView.centerYAnchor constraintEqualToAnchor:self.dotsContainerView.centerYAnchor],
            [dotView.leadingAnchor constraintEqualToAnchor:self.dotsContainerView.leadingAnchor constant:i * 40]
        ]];
    }
}

- (void)setupKeypad {
    self.keypadContainerView = [[UIView alloc] init];
    self.keypadContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.keypadContainerView];
    
    self.keypadButtons = [NSMutableArray array];
    
    for (int i = 1; i <= 9; i++) {
        [self createKeypadButtonWithNumber:i];
    }
    
    [self createKeypadButtonWithNumber:0];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deleteButton setImage:[UIImage systemImageNamed:@"delete.left"] forState:UIControlStateNormal];
    self.deleteButton.tintColor = [UIColor labelColor];
    [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.keypadContainerView addSubview:self.deleteButton];
    
    [self layoutKeypad];
}

- (void)createKeypadButtonWithNumber:(int)number {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.tag = number;
    [button setTitle:[NSString stringWithFormat:@"%d", number] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightRegular];
    
    button.layer.cornerRadius = 40;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor systemGrayColor].CGColor;
    
    [button addTarget:self action:@selector(keypadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.keypadContainerView addSubview:button];
    [self.keypadButtons addObject:button];
    
    [NSLayoutConstraint activateConstraints:@[
        [button.widthAnchor constraintEqualToConstant:80],
        [button.heightAnchor constraintEqualToConstant:80]
    ]];
}

- (void)layoutKeypad {
    CGFloat buttonSpacing = 20;
    CGFloat buttonSize = 80;
    
    for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
            int index = row * 3 + col;
            UIButton *button = self.keypadButtons[index];
            
            [NSLayoutConstraint activateConstraints:@[
                [button.topAnchor constraintEqualToAnchor:self.keypadContainerView.topAnchor constant:row * (buttonSize + buttonSpacing)],
                [button.leadingAnchor constraintEqualToAnchor:self.keypadContainerView.leadingAnchor constant:col * (buttonSize + buttonSpacing)]
            ]];
        }
    }
    
    UIButton *zeroButton = self.keypadButtons[9];
    [NSLayoutConstraint activateConstraints:@[
        [zeroButton.topAnchor constraintEqualToAnchor:self.keypadContainerView.topAnchor constant:3 * (buttonSize + buttonSpacing)],
        [zeroButton.centerXAnchor constraintEqualToAnchor:self.keypadContainerView.centerXAnchor]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.deleteButton.centerYAnchor constraintEqualToAnchor:zeroButton.centerYAnchor],
        [self.deleteButton.leadingAnchor constraintEqualToAnchor:zeroButton.trailingAnchor constant:buttonSpacing],
        [self.deleteButton.widthAnchor constraintEqualToConstant:80],
        [self.deleteButton.heightAnchor constraintEqualToConstant:80]
    ]];
}

- (void)updateUIForCurrentState {
    switch (self.entryState) {
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

- (void)keypadButtonTapped:(UIButton *)sender {
    NSInteger digit = sender.tag;
    
    if (self.enteredPasscode.length >= self.viewModel.screenModel.digitsCount) {
        return;
    }
    
    [self.enteredPasscode appendString:[NSString stringWithFormat:@"%ld", (long)digit]];
    
    [self updateDotsDisplay];
    
    if (self.enteredPasscode.length == self.viewModel.screenModel.digitsCount) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self processCompletedPasscodeEntry];
        });
    }
}

- (void)processCompletedPasscodeEntry {
    switch (self.entryState) {
        case PasscodeEntryStateInitial:
            self.initialPasscode = [self.enteredPasscode copy];
            self.entryState = PasscodeEntryStateConfirmation;
            [self updateUIForCurrentState];
            break;
            
        case PasscodeEntryStateConfirmation:
            if ([self.enteredPasscode isEqualToString:self.initialPasscode]) {
                [self setPasscode:self.enteredPasscode];
            } else {
                [self showPasscodeMismatchError];
            }
            break;
            
        case PasscodeEntryStateValidation:
            [self validatePasscode:self.enteredPasscode];
            break;
    }
}

- (void)showPasscodeMismatchError {
    [AlertManager showNotifyAlertWithTitle:@"Passcodes Don't Match"
                                   message:@"The passcodes you entered don't match. Please try again."
                         confirmActionTitle:[LocalizedStrings ok]
                            viewController:self];
    
    self.entryState = PasscodeEntryStateInitial;
    self.initialPasscode = nil;
    [self updateUIForCurrentState];
}

- (void)resetPasscodeEntry {
    self.enteredPasscode = [NSMutableString string];
    
    [self updateDotsDisplay];
}

- (void)checkPasswordStatus {
    // Nothing needed here anymore since biometric is removed
}

- (void)backButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)deleteButtonTapped {
    if (self.enteredPasscode.length > 0) {
        [self.enteredPasscode deleteCharactersInRange:NSMakeRange(self.enteredPasscode.length - 1, 1)];
        
        [self updateDotsDisplay];
    }
}

- (void)updateDotsDisplay {
    for (NSInteger i = 0; i < self.dotViews.count; i++) {
        UIView *dotView = self.dotViews[i];
        if (i < self.enteredPasscode.length) {
            dotView.alpha = 1.0;
            dotView.backgroundColor = [UIColor systemBlueColor];
        } else {
            dotView.alpha = 0.3;
            dotView.backgroundColor = [UIColor systemGrayColor];
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
    self.enteredPasscode = [NSMutableString string];
    
    [self updateDotsDisplay];
    
    if (error) {
        [AlertManager showNotifyAlertWithTitle:[LocalizedStrings error]
                                       message:error.localizedDescription
                             confirmActionTitle:[LocalizedStrings ok]
                                viewController:self];
    }
}

- (void)fillPasscodeWithStoredValue:(NSString *)password {
    [self validatePasscode:password];
}

@end 