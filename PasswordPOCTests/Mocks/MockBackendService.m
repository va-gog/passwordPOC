//
//  MockBackendService.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

// MockBackendService.m (extended for AppLaunchViewModel tests)

#import "MockBackendService.h"

@implementation MockBackendService

- (instancetype)init {
    self = [super init];
    if (self) {
        // User creation defaults
        _shouldSucceedUserCreation = YES;
        _userIdToReturn = @"mock_user_id";
        _errorForUserCreation = nil;
        _createUserCalled = NO;
        
        // Get user data defaults
        _shouldSucceedGetUserData = YES;
        _hasFourDigitPasswordToReturn = NO;
        _hasSixDigitPasswordToReturn = NO;
        _errorForGetUserData = nil;
        _getUserDataCalled = NO;
        
        // Password handling defaults (from previous mock)
        _shouldSucceedPasswordSet = YES;
        _shouldSucceedPasswordValidation = YES;
        _errorForPasswordSet = nil;
        _errorForPasswordValidation = nil;
        _setPasswordCalled = NO;
        _validatePasswordCalled = NO;
    }
    return self;
}

- (void)createUser:(NSString *)userId
        completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion {
    self.createUserCalled = YES;
    self.lastUserIdForCreate = userId;
    
    if (completion) {
        if (self.shouldSucceedUserCreation) {
            completion(self.userIdToReturn, nil);
        } else {
            completion(nil, self.errorForUserCreation);
        }
    }
}

- (void)getUserData:(NSString *)userId
         completion:(void (^)(NSString * _Nullable, BOOL, BOOL, NSError * _Nullable))completion {
    self.getUserDataCalled = YES;
    self.lastUserIdForGetUserData = userId;
    
    if (completion) {
        if (self.shouldSucceedGetUserData) {
            completion(userId,
                      self.hasFourDigitPasswordToReturn,
                      self.hasSixDigitPasswordToReturn,
                      nil);
        } else {
            completion(nil, NO, NO, self.errorForGetUserData);
        }
    }
}

- (void)setPassword:(NSString *)password
               type:(PasswordType)type
            forUser:(NSString *)userId
         completion:(void (^)(BOOL, NSError * _Nullable))completion {
    self.setPasswordCalled = YES;
    self.lastPasswordSet = password;
    self.lastUserForSetPassword = userId;
    self.lastTypeForSetPassword = type;
    
    if (completion) {
        if (self.shouldSucceedPasswordSet) {
            completion(YES, nil);
        } else {
            completion(NO, self.errorForPasswordSet);
        }
    }
}

- (void)validatePassword:(NSString *)password
                    type:(PasswordType)type
                 forUser:(NSString *)userId
              completion:(void (^)(BOOL, NSError * _Nullable))completion {
    self.validatePasswordCalled = YES;
    self.lastPasswordValidated = password;
    self.lastUserForValidatePassword = userId;
    self.lastTypeForValidatePassword = type;
    
    if (completion) {
        if (self.errorForPasswordValidation) {
            completion(NO, self.errorForPasswordValidation);
        } else {
            completion(self.shouldSucceedPasswordValidation, nil);
        }
    }
}

@end
