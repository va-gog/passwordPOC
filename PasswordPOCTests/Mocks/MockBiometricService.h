//
//  MockBiometricService.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import <Foundation/Foundation.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "BiometricServiceProtocol.h"

@interface MockBiometricService : NSObject <BiometricServiceProtocol>

@property (nonatomic, assign) BOOL shouldSucceedAuthentication;
@property (nonatomic, assign) BOOL biometricsAvailable;
@property (nonatomic, strong, nullable) NSError *errorForAuthentication;
@property (nonatomic, strong, nullable) NSError *errorForCanUseBiometrics;

@property (nonatomic, assign) BOOL authenticateCalled;
@property (nonatomic, assign) BOOL canUseBiometricsCalled;
@property (nonatomic, copy, nullable) NSString *lastReason;

@end
