#import "AppLaunchViewModel.h"
#import "BackendService.h"
#import "KeychainService.h"
#import "PasswordError.h"
#import "PasswordScreenModelFactory.h"

@interface AppLaunchViewModel()

@property (nonatomic, strong, readwrite) NSString *userId;

@end

@implementation AppLaunchViewModel

- (void)initializeUserWithCompletion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    NSString *userId = [[NSUUID UUID] UUIDString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[BackendService sharedInstance] createUser:userId
                                         completion:^(NSString * _Nullable userId,
                                                      NSError * _Nullable error) {
            if (!userId) {
                if (completion) {
                    completion(NO, [PasswordError errorWithCode:PasswordErrorCodeUserNotFound]);
                }
                return;
            }
            
            if (error) {
                if (completion) {
                    completion(NO, [PasswordError errorWithCode:error.code]);
                }
                return;
            }
            
            self.userId = userId;
            if (completion) {
                completion(YES, nil);
            }
        }];
    });
}

- (void)createPasswordScreenModelWithType:(PasswordType)type
                              completion:(void (^)(PasswordScreenModel * _Nullable model, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[BackendService sharedInstance] getUserData:self.userId
                                          completion:^(NSString * _Nullable userId,
                                                       BOOL hasFourDigitPassword,
                                                       BOOL hasSixDigitPassword,
                                                       NSError * _Nullable error) {
            if (error) {
                if (completion) {
                    completion(nil, [PasswordError errorWithCode:error.code]);
                }
                return;
            }
            
            PasswordScreenModel *model = [[PasswordScreenModelFactory sharedInstance] createPasswordScreenModelWithType:type
                                                                                                                 userID:userId
                                                                                                   hasFourDigitPassword:hasFourDigitPassword
                                                                                                    hasSixDigitPassword:hasSixDigitPassword];
            if (completion) {
                completion(model, nil);
            }
        }];
    });
}

- (void)savePasswordToKeychain:(NSString *)password
                          type:(PasswordType)type
                    completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    [[KeychainService sharedInstance] savePassword:password
                                           forUser:self.userId
                                             type:type
                                       completion:completion];
}

@end 
