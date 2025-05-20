#import "PasswordViewModel.h"
#import "BackendService.h"
#import "KeychainService.h"
#import "BiometricService.h"
#import "PasswordError.h"

@interface PasswordViewModel()

@property (nonatomic, strong, readwrite) PasswordScreenModel *screenModel;
@property (nonatomic, strong, readonly) id<BackendServiceProtocol> backendService;
@property (nonatomic, strong, readonly) id<KeychainServiceProtocol> keychainService;
@property (nonatomic, strong, readonly) id<BiometricServiceProtocol> biometricService;

@end

@implementation PasswordViewModel

- (instancetype)initWithScreenModel:(PasswordScreenModel *)screenModel
                     backendService:(id<BackendServiceProtocol>)backendService
                    keychainService:(id<KeychainServiceProtocol>)keychainService
                   biometricService:(id<BiometricServiceProtocol>)biometricService {
    self = [super init];
    if (self) {
        _screenModel = screenModel;
        _backendService = backendService;
        _keychainService = keychainService;
        _biometricService = biometricService;
        
        _enteredPasscode = [NSMutableString string];
        
        if (self.screenModel.isPasswordSet) {
            self.entryState = PasscodeEntryStateValidation;
        } else {
            self.entryState = PasscodeEntryStateInitial;
        }
    }
    return self;
}

- (void)setPassword:(NSString *)password
         completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.backendService setPassword:password
                                                type:self.screenModel.type
                                             forUser:self.screenModel.userID
                                          completion:^(BOOL success, NSError * _Nullable error) {
            if (error && completion) {
                completion(NO, [PasswordError errorWithCode:error.code]);
                return;
            }
            
            if (completion) {
                completion(YES, nil);
            }
        }];
        
    });
}

- (void)validatePassword:(NSString *)password
              completion:(void (^)(BOOL success,
                                   NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.backendService validatePassword:password
                                                     type:self.screenModel.type
                                                  forUser:self.screenModel.userID
                                               completion:^(BOOL isValid, NSError * _Nullable error) {
            if (error && completion) {
                completion(NO, [PasswordError errorWithCode:error.code]);
                return;
            }
            
            if (completion) {
                completion(isValid, nil);
            }
        }];
        
    });
}

- (void)savePasswordToKeychain:(NSString *)password
                    completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    [self.keychainService savePassword:password
                                           forUser:self.screenModel.userID
                                              type:self.screenModel.type
                                       completion:completion];
}


- (void)loadPasswordFromKeychainWithCompletion:(void (^)(NSString * _Nullable password, NSError * _Nullable error))completion {
    [self.keychainService loadPasswordForUser:self.screenModel.userID
                                                    type:self.screenModel.type
                                              completion:completion];
}

- (void)authenticateWithBiometricsWithCompletion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    [self.biometricService authenticateWithReason:@"Authenticate to access password"
                                                  completion:completion];
}

- (BOOL)canUseBiometricAuthentication:(NSError * _Nullable *)error {
    return [self.biometricService canUseBiometricAuthentication:error];
}

@end 
