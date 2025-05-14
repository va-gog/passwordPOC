//
//  MockBiometricService.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import "MockBiometricService.h"

@implementation MockBiometricService

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldSucceedAuthentication = YES;
        _biometricsAvailable = YES;
        _errorForAuthentication = nil;
        _errorForCanUseBiometrics = nil;
        _authenticateCalled = NO;
        _canUseBiometricsCalled = NO;
        _lastReason = nil;
    }
    return self;
}

- (void)authenticateWithReason:(NSString *)reason
                    completion:(void (^)(BOOL, NSError * _Nullable))completion {
    self.authenticateCalled = YES;
    self.lastReason = reason;
    
    // Simulate a small delay to mimic real biometric authentication
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            if (self.shouldSucceedAuthentication) {
                completion(YES, nil);
            } else {
                completion(NO, self.errorForAuthentication);
            }
        }
    });
}

- (BOOL)canUseBiometricAuthentication:(NSError * _Nullable *)error {
    self.canUseBiometricsCalled = YES;
    
    if (!self.biometricsAvailable && error != NULL) {
        *error = self.errorForCanUseBiometrics;
    }
    
    return self.biometricsAvailable;
}

@end
