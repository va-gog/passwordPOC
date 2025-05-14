//
//  BiometricServiceProtocol.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BiometricServiceProtocol <NSObject>

- (void)authenticateWithReason:(NSString *)reason
                    completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

- (BOOL)canUseBiometricAuthentication:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
