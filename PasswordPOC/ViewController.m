//
//  ViewController.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 12.05.25.
//

#import "ViewController.h"
#import "PasswordViewController.h"
#import "ServerSimulator.h"
#import "UserModel.h"
#import "PasswordScreenModel.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *fourDigitButton;
@property (nonatomic, strong) UIButton *sixDigitButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) NSString *userID;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self signUpUser];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // Loading Indicator
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
    
    // Four Digit Button
    self.fourDigitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.fourDigitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.fourDigitButton setTitle:@"4-Digit Password" forState:UIControlStateNormal];
    [self.fourDigitButton addTarget:self action:@selector(fourDigitButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fourDigitButton];
    
    // Six Digit Button
    self.sixDigitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sixDigitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sixDigitButton setTitle:@"6-Digit Password" forState:UIControlStateNormal];
    [self.sixDigitButton addTarget:self action:@selector(sixDigitButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sixDigitButton];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [self.fourDigitButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.fourDigitButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-30],
        [self.fourDigitButton.widthAnchor constraintEqualToConstant:200],
        [self.fourDigitButton.heightAnchor constraintEqualToConstant:50],
        
        [self.sixDigitButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.sixDigitButton.topAnchor constraintEqualToAnchor:self.fourDigitButton.bottomAnchor constant:20],
        [self.sixDigitButton.widthAnchor constraintEqualToConstant:200],
        [self.sixDigitButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)signUpUser {
    [self.loadingIndicator startAnimating];
    
    // For demo purposes, we'll use a fixed username and password
    NSString *username = @"demo_user";
    NSString *password = @"demo123";
    
    [[ServerSimulator sharedInstance] signUpUser:username
                                        password:password
                                      completion:^(NSString * _Nullable userId,
                                                   NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];
            
            if (error) {
                [self showError:error];
                return;
            }
            
            if (!userId) {
                [self showError:[NSError errorWithDomain:@"com.passwordpoc"
                                                  code:1
                                              userInfo:@{NSLocalizedDescriptionKey: @"Failed to create user"}]];
                return;
            }
            self.userID = userId;
        });
    }];
}

- (void)showError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                 message:error.localizedDescription
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)fourDigitButtonTapped {
    [self presentPasswordViewControllerWithType:PasswordTypeFourDigit];
}

- (void)sixDigitButtonTapped {
    [self presentPasswordViewControllerWithType:PasswordTypeSixDigit];
}

- (void)presentPasswordViewControllerWithType:(PasswordType)type {
    [self.loadingIndicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    [[ServerSimulator sharedInstance] getUserData:self.userID
                                       completion:^(NSString * _Nullable userId,
                                                    BOOL hasFourDigitPassword,
                                                    BOOL hasSixDigitPassword,
                                                    NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.loadingIndicator stopAnimating];
            if (error) {
                [self showError:error];
                return;
            }
            
            BOOL hasPassword = false;
            switch (type) {
                case PasswordTypeFourDigit:
                    hasPassword = hasFourDigitPassword;
                    break;
                case PasswordTypeSixDigit:
                    hasPassword = hasSixDigitPassword;
                    break;
                default:
                    break;
            }
            PasswordScreenModel *passworsModel = [[PasswordScreenModel alloc] initWithUserID:userId
                                                                                        type:type
                                                                               isPasswordSet:hasPassword];
            PasswordViewController *passwordVC = [[PasswordViewController alloc] init];
            passwordVC.screenModel = passworsModel;
            passwordVC.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [weakSelf presentViewController:passwordVC
                                   animated:YES
                                 completion:nil];
        });
    }];
}
    
@end
