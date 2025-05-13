#import "PasswordViewController.h"
#import "ServerSimulator.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <Security/Security.h>

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
    
    switch (self.screenModel.type) {
        case PasswordTypeFourDigit:
            self.titleLabel.text = @"4-Digit Password";
            break;
        case PasswordTypeSixDigit:
            self.titleLabel.text = @"6-Digit Password";
            break;
        default:
            self.titleLabel.text = @"Password";
            break;
    }
}

- (void)checkPasswordStatus {
    if (self.screenModel.isPasswordSet)
        [self tryToLoadFromKeychain];
}

- (void)tryToLoadFromKeychain {
    if (!self.isSettingPassword) {
        LAContext *context = [[LAContext alloc] init];
        NSError *error = nil;
        
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:@"Authenticate to access password"
                            reply:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        // Load password from keychain
                        NSString *service = [NSString stringWithFormat:@"com.passwordpoc.%@", self.screenModel.userID];
                        NSString *account = [NSString stringWithFormat:@"password_%ld", (long)self.screenModel.type];
                        
                        NSDictionary *query = @{
                            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: service,
                            (__bridge id)kSecAttrAccount: account,
                            (__bridge id)kSecReturnData: @YES,
                            (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
                        };
                        
                        CFTypeRef result = NULL;
                        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
                        
                        if (status == errSecSuccess) {
                            NSData *passwordData = (__bridge_transfer NSData *)result;
                            NSString *password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
                            
                            if (password) {
                                self.passwordTextField.text = password;
                                [self validatePassword:password];
                            } else {
                                NSError *keychainError = [NSError errorWithDomain:@"KeychainError"
                                                                           code:1
                                                                       userInfo:@{NSLocalizedDescriptionKey: @"Failed to decode password from keychain"}];
                                if (self.onPasswordValidated) {
                                    self.onPasswordValidated(NO, keychainError);
                                }
                            }
                        } else {
                            NSError *keychainError = [NSError errorWithDomain:@"KeychainError"
                                                                       code:status
                                                                   userInfo:@{NSLocalizedDescriptionKey: @"Failed to load password from keychain"}];
                            if (self.onPasswordValidated) {
                                self.onPasswordValidated(NO, keychainError);
                            }
                        }
                    } else if (error) {
                        if (self.onPasswordValidated) {
                            self.onPasswordValidated(NO, error);
                        }
                    }
                });
            }];
        } else {
            if (self.onPasswordValidated) {
                self.onPasswordValidated(NO, error);
            }
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *password = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSInteger requiredLength = (self.screenModel.type == PasswordTypeFourDigit) ? 4 : 6;
    
    if (password.length == requiredLength) {
        [self.loadingIndicator startAnimating];
        
        if (!self.screenModel.isPasswordSet) {
            [self setPassword:password];
        } else {
            [self validatePassword:password];
        }
    }
    
    return YES;
}

- (void)setPassword:(NSString *)password {
    [self.loadingIndicator startAnimating];
    [[ServerSimulator sharedInstance] setPassword:password
                                             type:self.screenModel.type
                                          forUser:self.screenModel.userID
                                       completion:^(BOOL success,
                                                    NSError * _Nullable error) {
        [self handlePasswordSetResponse:success
                                  error:error];
    }];
}

- (void)handlePasswordSetResponse:(BOOL)success error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];
        
        if (success) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                         message:@"Password set successfully. Would you like to save it to Keychain?"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // Save to keychain
                NSString *password = self.passwordTextField.text;
                NSString *service = [NSString stringWithFormat:@"com.passwordpoc.%@", self.screenModel.userID];
                NSString *account = [NSString stringWithFormat:@"password_%ld", (long)self.screenModel.type];
                
                NSDictionary *query = @{
                    (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                    (__bridge id)kSecAttrService: service,
                    (__bridge id)kSecAttrAccount: account,
                    (__bridge id)kSecValueData: [password dataUsingEncoding:NSUTF8StringEncoding],
                    (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlocked
                };
                
                // First try to delete any existing password
                SecItemDelete((__bridge CFDictionaryRef)query);
                
                // Add the new password
                OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
                
                if (status == errSecSuccess) {
                    if (self.onPasswordSet) {
                        self.onPasswordSet(YES, nil);
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    NSError *keychainError = [NSError errorWithDomain:@"KeychainError"
                                                               code:status
                                                           userInfo:@{NSLocalizedDescriptionKey: @"Failed to save password to keychain"}];
                    if (self.onPasswordSet) {
                        self.onPasswordSet(NO, keychainError);
                    }
                }
            }]];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (self.onPasswordSet) {
                    self.onPasswordSet(YES, nil);
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            if (self.onPasswordSet) {
                self.onPasswordSet(NO, error);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

- (void)validatePassword:(NSString *)password {
    [self.loadingIndicator startAnimating];
    [[ServerSimulator sharedInstance] validatePassword:password
        type:self.screenModel.type forUser:self.screenModel.userID
        completion:^(BOOL isValid, NSError * _Nullable error) {
            [self handlePasswordValidationResponse:isValid error:error];
    }];
}

- (void)handlePasswordValidationResponse:(BOOL)isValid error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator stopAnimating];
        
        if (isValid) {
            if (self.onPasswordValidated) {
                self.onPasswordValidated(YES, nil);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                         message:error.localizedDescription
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            
            if (self.onPasswordValidated) {
                self.onPasswordValidated(NO, error);
            }
        }
    });
}

@end 
