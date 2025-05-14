#import "PasswordViewController.h"

@interface PasswordViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
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
    
    // Status Label
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:self.statusLabel];
    self.statusLabel.text = @"Please set your password";
    
    // Password TextField
    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.passwordTextField.delegate = self;
    self.passwordTextField.placeholder = @"Enter password";
    [self.view addSubview:self.passwordTextField];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:50],
        
        [self.statusLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.statusLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:20],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        
        [self.passwordTextField.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.passwordTextField.topAnchor constraintEqualToAnchor:self.statusLabel.bottomAnchor constant:20],
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
    NSError *error = nil;
    if ([self.viewModel canUseBiometricAuthentication:&error]) {
        [self.viewModel authenticateWithBiometricsWithCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [self.viewModel loadPasswordFromKeychainWithCompletion:^(NSString * _Nullable password, NSError * _Nullable error) {
                    if (password) {
                        self.passwordTextField.text = password;
                        [self validatePassword:password];
                    } else if (error) {
                        if (self.onPasswordValidated) {
                            self.onPasswordValidated(NO, error);
                        }
                    }
                }];
            }
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *password = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (password.length == self.viewModel.screenModel.digitsCount) {
        [self.loadingIndicator startAnimating];
        
        if (!self.viewModel.screenModel.isPasswordSet) {
            [self setPassword:password];
        } else {
            [self validatePassword:password];
        }
    }
    
    return YES;
}

- (void)setPassword:(NSString *)password {
    [self.loadingIndicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    [self.viewModel setPassword:password completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            
            if (success) {
                if (weakSelf.onPasswordSet) {
                    weakSelf.onPasswordSet(password, nil);
                }
            } else {
                if (weakSelf.onPasswordSet) {
                    weakSelf.onPasswordSet(nil, error);
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

@end 
