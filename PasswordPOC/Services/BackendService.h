#import <Foundation/Foundation.h>
#import "PasswordTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface BackendService : NSObject

+ (instancetype)sharedInstance;

- (void)createUser:(NSString *)userId
        completion:(void (^)(NSString * _Nullable userId,
                             NSError * _Nullable error))completion;

- (void)getUserData:(NSString *)userId
         completion:(void (^)(NSString * _Nullable userId,
                              BOOL hasFourDigitPassword,
                              BOOL hasSixDigitPassword,
                              NSError * _Nullable error))completion;

- (void)setPassword:(NSString *)password
               type:(PasswordType)type
            forUser:(NSString *)userId
         completion:(void (^)(BOOL success,
                              NSError * _Nullable error))completion;

- (void)validatePassword:(NSString *)password
                    type:(PasswordType)type
                 forUser:(NSString *)userId
              completion:(void (^)(BOOL isValid,
                                   NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END 