//
//  BackendService.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import "BackendService.h"
#import "AESCryptoHelper.h"

static NSData *DemoAESKey(void) {
    static uint8_t keyBytes[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                                   0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F};
    return [NSData dataWithBytes:keyBytes length:16];
}

static NSData *DemoAESIV(void) {
    static uint8_t ivBytes[16] = {0x0F, 0x0E, 0x0D, 0x0C, 0x0B, 0x0A, 0x09, 0x08,
                                  0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01, 0x00};
    return [NSData dataWithBytes:ivBytes length:16];
}

@interface UserPasswordData : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *fourDigitPassword;
@property (nonatomic, strong) NSString *sixDigitPassword;
@property (nonatomic, assign) BOOL hasSetFourDigitPassword;
@property (nonatomic, assign) BOOL hasSetSixDigitPassword;
@end

@implementation UserPasswordData
@end

@interface BackendService ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, UserPasswordData *> *users;
@end

@implementation BackendService

- (instancetype)init {
    self = [super init];
    if (self) {
        _users = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)createUser:(NSString *)userId
        completion:(void (^)(NSString * _Nullable userId, NSError * _Nullable error))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.users[userId]) {
            NSError *error = [NSError errorWithDomain:@"com.passwordpoc"
                                               code:409
                                           userInfo:@{NSLocalizedDescriptionKey: @"User already exists"}];
            completion(nil, error);
            return;
        }
        
        UserPasswordData *userData = [[UserPasswordData alloc] init];
        userData.userId = userId;
        userData.hasSetFourDigitPassword = NO;
        userData.hasSetSixDigitPassword = NO;
        
        self.users[userId] = userData;
        
        completion(userId, nil);
    });
}

- (void)getUserData:(NSString *)userId
         completion:(void (^)(NSString * _Nullable userId,
                              BOOL hasFourDigitPassword,
                              BOOL hasSixDigitPassword,
                              NSError * _Nullable error))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UserPasswordData *userData = self.users[userId];
        
        if (!userData) {
            NSError *error = [NSError errorWithDomain:@"com.passwordpoc"
                                               code:404
                                           userInfo:@{NSLocalizedDescriptionKey: @"User not found"}];
            completion(nil, NO, NO, error);
            return;
        }
        
        completion(userData.userId,
                 userData.hasSetFourDigitPassword,
                 userData.hasSetSixDigitPassword,
                 nil);
    });
}

- (void)setPassword:(NSString *)password
               type:(PasswordType)type
            forUser:(NSString *)userId
         completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UserPasswordData *userData = self.users[userId];
        if (!userData) {
            NSError *error = [NSError errorWithDomain:@"ServerError" code:404 userInfo:@{NSLocalizedDescriptionKey: @"User not found"}];
            completion(NO, error);
            return;
        }
        
        [self checkPassword:password type:type forUser:userId completion:^(BOOL isValid, NSError * _Nullable error) {
            if (!isValid) {
                completion(NO, error);
                return;
            }
            
            NSData *key = DemoAESKey();
            NSData *iv = DemoAESIV();
            NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
            NSData *encryptedPassword = [AESCryptoHelper encryptData:passwordData key:key iv:iv];
            NSString *base64Password = [encryptedPassword base64EncodedStringWithOptions:0];
            
            if (type == PasswordTypeFourDigit) {
                userData.fourDigitPassword = base64Password;
                userData.hasSetFourDigitPassword = YES;
            } else if (type == PasswordTypeSixDigit) {
                userData.sixDigitPassword = base64Password;
                userData.hasSetSixDigitPassword = YES;
            }
            
            completion(YES, nil);
        }];
    });
}

- (void)validatePassword:(NSString *)password
                    type:(PasswordType)type
                 forUser:(NSString *)userId
              completion:(void (^)(BOOL isValid, NSError * _Nullable error))completion {
    UserPasswordData *userData = self.users[userId];
    if (!userData) {
        NSError *error = [NSError errorWithDomain:@"ServerError" code:404 userInfo:@{NSLocalizedDescriptionKey: @"User not found"}];
        completion(NO, error);
        return;
    }
    
    NSData *key = DemoAESKey();
    NSData *iv = DemoAESIV();
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedPassword = [AESCryptoHelper encryptData:passwordData key:key iv:iv];
    NSString *base64Password = [encryptedPassword base64EncodedStringWithOptions:0];

    
    if (type == PasswordTypeFourDigit && ![base64Password isEqualToString:userData.fourDigitPassword]) {
        NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"4-digit password is not Correct"}];
        completion(NO, error);
        return;
    }
    
    if (type == PasswordTypeSixDigit && ![base64Password isEqualToString:userData.sixDigitPassword]) {
        NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"6-digit password is not correct set"}];
        completion(NO, error);
        return;
    }
    
    completion(YES, nil);
}

- (void)checkPassword:(NSString *)password
                 type:(PasswordType)type
              forUser:(NSString *)userId
           completion:(void (^)(BOOL isValid, NSError * _Nullable error))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // First check if user exists
        UserPasswordData *userData = self.users[userId];
        if (!userData) {
            NSError *error = [NSError errorWithDomain:@"ServerError" code:404 userInfo:@{NSLocalizedDescriptionKey: @"User not found"}];
            completion(NO, error);
            return;
        }
        
        // Validate password format
        if (type == PasswordTypeFourDigit) {
            if (password.length != 4) {
                NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Password must be exactly 4 digits"}];
                completion(NO, error);
                return;
            }
            
            if ([password hasPrefix:@"0"]) {
                NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Password cannot start with 0"}];
                completion(NO, error);
                return;
            }
            
            // Check if contains only digits
            NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            if ([password rangeOfCharacterFromSet:nonDigits].location != NSNotFound) {
                NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Password must contain only digits"}];
                completion(NO, error);
                return;
            }
            
        } else if (type == PasswordTypeSixDigit) {
            if (password.length != 6) {
                NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Password must be exactly 6 digits"}];
                completion(NO, error);
                return;
            }
            
            if ([password hasPrefix:@"0"]) {
                NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Password cannot start with 0"}];
                completion(NO, error);
                return;
            }
            
            // Check if contains only digits
            NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
            if ([password rangeOfCharacterFromSet:nonDigits].location != NSNotFound) {
                NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Password must contain only digits"}];
                completion(NO, error);
                return;
            }
        }
        
        completion(YES, nil);
    });
}

@end 
