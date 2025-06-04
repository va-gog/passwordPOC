//
//  KeychainServiceProtocol.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//
//
//  KeychainServiceProtocol.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import <Foundation/Foundation.h>
#import "PasswordTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KeychainServiceProtocol <NSObject>

- (void)savePassword:(NSString *)password
            forUser:(NSString *)userId
               type:(PasswordType)type
         completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

- (void)loadPasswordForUser:(NSString *)userId
                       type:(PasswordType)type
                 completion:(void (^)(NSString * _Nullable password, NSError * _Nullable error))completion;

- (void)deletePasswordForUser:(NSString *)userId
                         type:(PasswordType)type
                   completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
