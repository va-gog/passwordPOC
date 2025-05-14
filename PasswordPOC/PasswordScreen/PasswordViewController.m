#import "PasswordViewController.h"
#import "AlertManager.h"
#import "LocalizedStrings.h"

@interface PasswordViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self checkPasswordStatus];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // Loading Indicator
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
    
    // Title Label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    self.titleLabel.text = self.viewModel.screenModel.titleText;
    [self.view addSubview:self.titleLabel];
    
    // Password TextField
    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.passwordTextField.delegate = self;
    self.passwordTextField.placeholder = [LocalizedStrings enterPassword];
    [self.view addSubview:self.passwordTextField];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:50],
        
        [self.passwordTextField.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.passwordTextField.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:20],
        [self.passwordTextField.widthAnchor constraintEqualToConstant:200],
        [self.passwordTextField.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)checkPasswordStatus {
    if (self.viewModel.screenModel.isPasswordSet) {
        [self tryToLoadFromKeychain];
    }
}

- (void)tryToLoadFromKeychain {
    if (self.keychainEnalbled) {
        NSError *error = nil;
        if ([self.viewModel canUseBiometricAuthentication:&error]) {
            // Show loading indicator before authentication
            [self.loadingIndicator startAnimating];
            
            [self.viewModel authenticateWithBiometricsWithCompletion:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        [self.viewModel loadPasswordFromKeychainWithCompletion:^(NSString * _Nullable password, NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.loadingIndicator stopAnimating];
                                if (password) {
                                    self.passwordTextField.text = password;
                                    [self validatePassword:password];
                                } else if (error) {
                                    if (self.onPasswordValidated) {
                                        self.onPasswordValidated(NO, error);
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

- (void)setPassword:(NSString *)password {
    [self.loadingIndicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    [self.viewModel setPassword:password completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            if (success) {
                if (weakSelf.keychainEnalbled) {
                    [AlertManager showConfirmationAlertWithTitle:[LocalizedStrings success]
                                                         message:[LocalizedStrings saveToKeychainQuestion]
                                                  viewController:weakSelf
                                              confirmActionTitle:[LocalizedStrings yes]
                                                  confirmHandler:^{
                        [weakSelf.viewModel savePasswordToKeychain:password
                                                        completion:^(BOOL success,
                                                                     NSError * _Nullable error) {
                            if (weakSelf.onPasswordSet) {
                                weakSelf.onPasswordSet(YES, nil);
                            }
                        }];
                    }
                                               cancelActionTitle:[LocalizedStrings no]
                                                   cancelHandler:^{
                        if (weakSelf.onPasswordSet) {
                            weakSelf.onPasswordSet(YES, nil);
                        }
                    }];
                } else {
                    if (weakSelf.onPasswordSet) {
                        weakSelf.onPasswordSet(YES, nil);
                    }
                }
            } else {
                if (weakSelf.onPasswordSet) {
                    weakSelf.onPasswordSet(NO, error);
                }
            }
        });
    }];
}

- (void)validatePassword:(NSString *)password {
    [self.loadingIndicator startAnimating];
    
    [self.viewModel validatePassword:password completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];
            
            if (success) {
                if (self.onPasswordValidated) {
                    self.onPasswordValidated(YES, nil);
                }
            } else {
                if (self.onPasswordValidated) {
                    self.onPasswordValidated(NO, error);
                }
            }
        });
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Calculate the resulting text
    NSString *password = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Limit input to numbers only if not backspace
    if (![string isEqualToString:@""] && ![self isNumeric:string]) {
        return NO;
    }
    
    // Enforce digit limit
    if (password.length > self.viewModel.screenModel.digitsCount) {
        return NO;
    }
    
    // Only trigger password check when we reach the exact length
    if (password.length == self.viewModel.screenModel.digitsCount) {
        // Use dispatch_async to move this work off the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator startAnimating];
            
            if (!self.viewModel.screenModel.isPasswordSet) {
                [self setPassword:password];
            } else {
                [self validatePassword:password];
            }
        });
    }
    
    return YES;
}

- (BOOL)isNumeric:(NSString *)string {
    NSCharacterSet *nonDigitSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [string rangeOfCharacterFromSet:nonDigitSet].location == NSNotFound;
}

@end 
