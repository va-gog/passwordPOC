#import "AppLaunchViewModel.h"
//
//  AppLaunchViewModel.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 04.06.25.
//

#import "BackendService.h"
#import "KeychainService.h"
#import "PasswordError.h"
#import "PasswordScreenModelFactory.h"
#import "PasswordError.h"

@interface AppLaunchViewModel()

@property (nonatomic, strong) NSString *userId;

@end

@implementation AppLaunchViewModel

- (instancetype)initWithBackendService:(BackendService *)backendService  {
    self = [super init];
    if (self) {
        _backendService = backendService;
    }
    return self;
}

- (void)initializeUserWithCompletion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    NSString *userId = [[NSUUID UUID] UUIDString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.backendService createUser:userId
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
        [self.backendService getUserData:self.userId
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

@end 
