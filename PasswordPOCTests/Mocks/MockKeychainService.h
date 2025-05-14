//
//  MockKeychainService.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import <Foundation/Foundation.h>
#import "KeychainServiceProtocol.h"

@interface MockKeychainService : NSObject <KeychainServiceProtocol>

@property (nonatomic, assign) BOOL shouldSucceedSaving;
@property (nonatomic, assign) BOOL shouldSucceedLoading;
@property (nonatomic, strong, nullable) NSError *errorForSaving;
@property (nonatomic, strong, nullable) NSError *errorForLoading;
@property (nonatomic, copy, nullable) NSString *passwordToReturn;

@property (nonatomic, assign) BOOL savePasswordCalled;
@property (nonatomic, assign) BOOL loadPasswordCalled;
@property (nonatomic, copy, nullable) NSString *lastPasswordSaved;
@property (nonatomic, copy, nullable) NSString *lastUserForSave;
@property (nonatomic, copy, nullable) NSString *lastUserForLoad;
@property (nonatomic, assign) PasswordType lastTypeForSave;
@property (nonatomic, assign) PasswordType lastTypeForLoad;

@end
