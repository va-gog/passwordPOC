#import "AppLaunchViewController.h"
#import "PasswordViewController.h"
#import "PasswordScreenModel.h"
#import "AppLaunchViewModel.h"
#import "AlertManager.h"
#import "LocalizedStrings.h"

@interface AppLaunchViewController ()

@property (nonatomic, strong) UIButton *fourDigitButton;
@property (nonatomic, strong) UIButton *sixDigitButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) AppLaunchViewModel *viewModel;

@end

@implementation AppLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupViewModel];
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
    self.fourDigitButton.hidden = YES;
    [self.view addSubview:self.fourDigitButton];
    
    // Six Digit Button
    self.sixDigitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sixDigitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sixDigitButton setTitle:@"6-Digit Password" forState:UIControlStateNormal];
    [self.sixDigitButton addTarget:self action:@selector(sixDigitButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.sixDigitButton.hidden = YES;
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

- (void)setupViewModel {
    self.viewModel = [[AppLaunchViewModel alloc] initWithBackendService:[[BackendService alloc] init]];
    [self initializeUser];
}

- (void)initializeUser {
    [self.loadingIndicator startAnimating];
    
    [self.viewModel initializeUserWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingIndicator stopAnimating];
               
            if (success) {
                self.fourDigitButton.hidden = NO;
                self.sixDigitButton.hidden = NO;
            } else if (error) {
                [AlertManager showNotifyAlertWithTitle:[LocalizedStrings somethingWentWrong]
                                               message:error.localizedDescription
                                    confirmActionTitle:[LocalizedStrings ok]
                                        viewController:self];
            }
        });
    }];
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
    [self.viewModel createPasswordScreenModelWithType:type
                                           completion:^(PasswordScreenModel * _Nullable model, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.loadingIndicator stopAnimating];
            
            if (error) {
                [AlertManager showNotifyAlertWithTitle:[LocalizedStrings somethingWentWrong]
                                               message:error.localizedDescription
                                         confirmActionTitle:[LocalizedStrings ok]
                                        viewController:weakSelf];
                return;
            }
            
            PasswordViewController *passwordVC = [[PasswordViewController alloc] init];
            passwordVC.viewModel = [[PasswordViewModel alloc] initWithScreenModel:model
                                                                   backendService: self.viewModel.backendService
                                                                  keychainService:[[KeychainService alloc] init]
                                                                 biometricService:[[BiometricService alloc] init]];
            passwordVC.keychainEnalbled = YES;
            passwordVC.modalPresentationStyle = UIModalPresentationFormSheet;
            
            __weak PasswordViewController *weakPasswordVC = passwordVC;
            passwordVC.onPasswordValidated = ^(BOOL success,
                                               NSError * _Nullable error) {
                [self handlePasswordOperationResult:success
                                          withError:error
                                     fromController:weakPasswordVC
                                     successMessage:[LocalizedStrings passwordValidated]];
            };
            passwordVC.onPasswordSet = ^(BOOL success, NSError * _Nullable error) {
                [self handlePasswordOperationResult:success
                                          withError:error
                                     fromController:weakPasswordVC
                                     successMessage:[LocalizedStrings passwordSetSuccessfully]];
            };
            
            [weakSelf presentViewController:passwordVC
                                   animated:YES
                                 completion:nil];
        });
    }];
}

- (void)handlePasswordOperationResult:(BOOL)success
                         withError:(NSError * _Nullable)error
                   fromController:(PasswordViewController *)passwordVC
                      successMessage:(NSString *)successMessage {
    if (success) {
        [passwordVC dismissViewControllerAnimated:YES completion:^{
            [AlertManager showNotificationHoodWithMessage:successMessage
                                                   onView:self.view];
        }];
    } else if (error) {
        [AlertManager showNotifyAlertWithTitle:[LocalizedStrings somethingWentWrong]
                                       message:error.localizedDescription
                             confirmActionTitle:[LocalizedStrings ok]
                                viewController:passwordVC];
    }
}

@end
