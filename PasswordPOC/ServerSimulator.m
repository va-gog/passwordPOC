#import "ServerSimulator.h"
#import "PasswordTypes.h"

@interface UserData : NSObject
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *loginPassword;
@property (nonatomic, strong) NSString *fourDigitPassword;
@property (nonatomic, strong) NSString *sixDigitPassword;
@property (nonatomic, assign) BOOL hasSetFourDigitPassword;
@property (nonatomic, assign) BOOL hasSetSixDigitPassword;
@end

@implementation UserData
@end

@interface ServerSimulator ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, UserData *> *users;
@end

@implementation ServerSimulator

+ (instancetype)sharedInstance {
    static ServerSimulator *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ServerSimulator alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _users = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)signUpUser:(NSString *)username password:(NSString *)password completion:(void (^)(NSString * _Nullable userId, NSError * _Nullable error))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.users[username]) {
            NSError *error = [NSError errorWithDomain:@"ServerError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"User already exists"}];
            completion(nil, error);
            return;
        }
        
        NSString *userId = [[NSUUID UUID] UUIDString];
        
        UserData *userData = [[UserData alloc] init];
        userData.userId = userId;
        userData.loginPassword = password;
        userData.hasSetFourDigitPassword = NO;
        userData.hasSetSixDigitPassword = NO;
        
        // Store user data
        self.users[userId] = userData;
        
        completion(userId, nil);
    });
}

- (void)getUserData:(NSString *)username completion:(void (^)(NSString * _Nullable userId, BOOL hasFourDigitPassword, BOOL hasSixDigitPassword, NSError * _Nullable error))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UserData *userData = self.users[username];
        
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

- (void)setPassword:(NSString *)password type:(PasswordType)type forUser:(NSString *)userId completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UserData *userData = self.users[userId];
        if (!userData) {
            NSError *error = [NSError errorWithDomain:@"ServerError" code:404 userInfo:@{NSLocalizedDescriptionKey: @"User not found"}];
            completion(NO, error);
            return;
        }
        
        // Validate password first
        [self checkPassword:password type:type forUser:userId completion:^(BOOL isValid, NSError * _Nullable error) {
            if (!isValid) {
                completion(NO, error);
                return;
            }
            
            // Update user data
            if (type == PasswordTypeFourDigit) {
                userData.fourDigitPassword = password;
                userData.hasSetFourDigitPassword = YES;
            } else if (type == PasswordTypeSixDigit) {
                userData.sixDigitPassword = password;
                userData.hasSetSixDigitPassword = YES;
            }
            
            completion(YES, nil);
        }];
    });
}

- (void)validatePassword:(NSString *)password type:(PasswordType)type forUser:(NSString *)userId completion:(void (^)(BOOL isValid, NSError * _Nullable error))completion {
    UserData *userData = self.users[userId];
    if (!userData) {
        NSError *error = [NSError errorWithDomain:@"ServerError" code:404 userInfo:@{NSLocalizedDescriptionKey: @"User not found"}];
        completion(NO, error);
        return;
    }
    
    if (type == PasswordTypeFourDigit && ![password isEqualToString:userData.fourDigitPassword]) {
        NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"4-digit password is not Correct"}];
        completion(NO, error);
        return;
    }
    
    if (type == PasswordTypeSixDigit && ![password isEqualToString:userData.sixDigitPassword]) {
        NSError *error = [NSError errorWithDomain:@"ValidationError" code:400 userInfo:@{NSLocalizedDescriptionKey: @"6-digit password is not correct set"}];
        completion(NO, error);
        return;
    }
    
    completion(YES, nil);
}


- (void)checkPassword:(NSString *)password type:(PasswordType)type forUser:(NSString *)userId completion:(void (^)(BOOL isValid, NSError * _Nullable error))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // First check if user exists
        UserData *userData = self.users[userId];
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
