#import "PasswordViewModel.h"
#import "BackendService.h"
#import "KeychainService.h"
#import "BiometricService.h"
#import "PasswordError.h"

@interface PasswordViewModel()

@property (nonatomic, strong, readwrite) PasswordScreenModel *screenModel;

@end

@implementation PasswordViewModel

- (instancetype)initWithScreenModel:(PasswordScreenModel *)screenModel {
    self = [super init];
    if (self) {
        _screenModel = screenModel;
    }
    return self;
}

- (void)setPassword:(NSString *)password
         completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[BackendService sharedInstance] setPassword:password
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
        
        [[BackendService sharedInstance] validatePassword:password
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
    [[KeychainService sharedInstance] savePassword:password
                                           forUser:self.screenModel.userID
                                              type:self.screenModel.type
                                       completion:completion];
}


- (void)loadPasswordFromKeychainWithCompletion:(void (^)(NSString * _Nullable password, NSError * _Nullable error))completion {
    [[KeychainService sharedInstance] loadPasswordForUser:self.screenModel.userID
                                                    type:self.screenModel.type
                                              completion:completion];
}

- (void)authenticateWithBiometricsWithCompletion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    [[BiometricService sharedInstance] authenticateWithReason:@"Authenticate to access password"
                                                  completion:completion];
}

- (BOOL)canUseBiometricAuthentication:(NSError * _Nullable *)error {
    return [[BiometricService sharedInstance] canUseBiometricAuthentication:error];
}

@end 
