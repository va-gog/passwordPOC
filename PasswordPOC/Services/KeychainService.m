//
//  KeychainService.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import "KeychainService.h"
#import <Security/Security.h>

@implementation KeychainService

- (NSString *)serviceNameForUser:(NSString *)userId {
    return [NSString stringWithFormat:@"com.passwordpoc.%@", userId];
}

- (NSString *)accountNameForType:(PasswordType)type {
    return [NSString stringWithFormat:@"password_%ld", (long)type];
}

- (void)savePassword:(NSString *)password
            forUser:(NSString *)userId
               type:(PasswordType)type
         completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    NSString *service = [self serviceNameForUser:userId];
    NSString *account = [self accountNameForType:type];
    
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: service,
        (__bridge id)kSecAttrAccount: account,
        (__bridge id)kSecValueData: [password dataUsingEncoding:NSUTF8StringEncoding],
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenUnlocked
    };
    
    [self deletePasswordForUser:userId type:type completion:^(BOOL success, NSError * _Nullable error) {
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        
        if (status == errSecSuccess) {
            if (completion) {
                completion(YES, nil);
            }
        } else {
            NSError *keychainError = [NSError errorWithDomain:@"KeychainError"
                                                       code:status
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Failed to save password to keychain"}];
            if (completion) {
                completion(NO, keychainError);
            }
        }
    }];
}

- (void)loadPasswordForUser:(NSString *)userId
                       type:(PasswordType)type
                 completion:(void (^)(NSString * _Nullable password, NSError * _Nullable error))completion {
    NSString *service = [self serviceNameForUser:userId];
    NSString *account = [self accountNameForType:type];
    
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: service,
        (__bridge id)kSecAttrAccount: account,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    if (status == errSecSuccess) {
        NSData *passwordData = (__bridge_transfer NSData *)result;
        NSString *password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
        
        if (password) {
            if (completion) {
                completion(password, nil);
            }
        } else {
            NSError *keychainError = [NSError errorWithDomain:@"KeychainError"
                                                       code:1
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Failed to decode password from keychain"}];
            if (completion) {
                completion(nil, keychainError);
            }
        }
    } else {
        NSError *keychainError = [NSError errorWithDomain:@"KeychainError"
                                                   code:status
                                               userInfo:@{NSLocalizedDescriptionKey: @"Failed to load password from keychain"}];
        if (completion) {
            completion(nil, keychainError);
        }
    }
}

- (void)deletePasswordForUser:(NSString *)userId
                         type:(PasswordType)type
                   completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    NSString *service = [self serviceNameForUser:userId];
    NSString *account = [self accountNameForType:type];
    
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: service,
        (__bridge id)kSecAttrAccount: account
    };
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    
    if (status == errSecSuccess || status == errSecItemNotFound) {
        if (completion) {
            completion(YES, nil);
        }
    } else {
        NSError *keychainError = [NSError errorWithDomain:@"KeychainError"
                                                   code:status
                                               userInfo:@{NSLocalizedDescriptionKey: @"Failed to delete password from keychain"}];
        if (completion) {
            completion(NO, keychainError);
        }
    }
}

@end 
