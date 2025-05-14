//
//  MockBackendService.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import <Foundation/Foundation.h>
#import "BackendServiceProtocol.h"

@interface MockBackendService : NSObject <BackendServiceProtocol>

// User creation properties
@property (nonatomic, assign) BOOL shouldSucceedUserCreation;
@property (nonatomic, strong, nullable) NSString *userIdToReturn;
@property (nonatomic, strong, nullable) NSError *errorForUserCreation;
@property (nonatomic, assign) BOOL createUserCalled;
@property (nonatomic, copy, nullable) NSString *lastUserIdForCreate;

// Get user data properties
@property (nonatomic, assign) BOOL shouldSucceedGetUserData;
@property (nonatomic, assign) BOOL hasFourDigitPasswordToReturn;
@property (nonatomic, assign) BOOL hasSixDigitPasswordToReturn;
@property (nonatomic, strong, nullable) NSError *errorForGetUserData;
@property (nonatomic, assign) BOOL getUserDataCalled;
@property (nonatomic, copy, nullable) NSString *lastUserIdForGetUserData;

// Password handling properties (from previous mock)
@property (nonatomic, assign) BOOL shouldSucceedPasswordSet;
@property (nonatomic, assign) BOOL shouldSucceedPasswordValidation;
@property (nonatomic, strong, nullable) NSError *errorForPasswordSet;
@property (nonatomic, strong, nullable) NSError *errorForPasswordValidation;
@property (nonatomic, assign) BOOL setPasswordCalled;
@property (nonatomic, assign) BOOL validatePasswordCalled;
@property (nonatomic, copy, nullable) NSString *lastPasswordSet;
@property (nonatomic, copy, nullable) NSString *lastPasswordValidated;
@property (nonatomic, copy, nullable) NSString *lastUserForSetPassword;
@property (nonatomic, copy, nullable) NSString *lastUserForValidatePassword;
@property (nonatomic, assign) PasswordType lastTypeForSetPassword;
@property (nonatomic, assign) PasswordType lastTypeForValidatePassword;

@end
