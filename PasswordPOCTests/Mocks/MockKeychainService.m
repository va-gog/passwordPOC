//
//  MockKeychainService.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import "MockKeychainService.h"

@implementation MockKeychainService

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldSucceedSaving = YES;
        _shouldSucceedLoading = YES;
        _errorForSaving = nil;
        _errorForLoading = nil;
        _passwordToReturn = nil;
        _savePasswordCalled = NO;
        _loadPasswordCalled = NO;
        _lastPasswordSaved = nil;
        _lastUserForSave = nil;
        _lastUserForLoad = nil;
    }
    return self;
}

- (void)savePassword:(NSString *)password
            forUser:(NSString *)userId
               type:(PasswordType)type
         completion:(void (^)(BOOL, NSError * _Nullable))completion {
    self.savePasswordCalled = YES;
    self.lastPasswordSaved = password;
    self.lastUserForSave = userId;
    self.lastTypeForSave = type;
    
    if (completion) {
        if (self.shouldSucceedSaving) {
            completion(YES, nil);
        } else {
            completion(NO, self.errorForSaving);
        }
    }
}

- (void)loadPasswordForUser:(NSString *)userId
                       type:(PasswordType)type
                 completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion {
    self.loadPasswordCalled = YES;
    self.lastUserForLoad = userId;
    self.lastTypeForLoad = type;
    
    if (completion) {
        if (self.shouldSucceedLoading) {
            completion(self.passwordToReturn, nil);
        } else {
            completion(nil, self.errorForLoading);
        }
    }
}

- (void)deletePasswordForUser:(NSString *)userId
                         type:(PasswordType)type
                   completion:(void (^)(BOOL, NSError * _Nullable))completion {
    // This method might not be directly used in the ViewModel but is part of the protocol
    if (completion) {
        completion(YES, nil);
    }
}

@end
