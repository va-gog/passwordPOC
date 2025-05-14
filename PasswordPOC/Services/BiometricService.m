#import "BiometricService.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation BiometricService

- (void)authenticateWithReason:(NSString *)reason
                    completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    
    if ([self canUseBiometricAuthentication:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
              localizedReason:reason
                        reply:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(success, error);
                }
            });
        }];
    } else {
        if (completion) {
            completion(NO, error);
        }
    }
}

- (BOOL)canUseBiometricAuthentication:(NSError * _Nullable *)error {
    LAContext *context = [[LAContext alloc] init];
    return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:error];
}

@end 
