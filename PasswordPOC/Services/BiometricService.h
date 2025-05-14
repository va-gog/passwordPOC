#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BiometricService : NSObject

+ (instancetype)sharedInstance;

- (void)authenticateWithReason:(NSString *)reason
                    completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

- (BOOL)canUseBiometricAuthentication:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END 