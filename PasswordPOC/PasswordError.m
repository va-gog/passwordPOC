#import "PasswordError.h"

NSString * const PasswordErrorDomain = @"com.passwordpoc.error";

@implementation PasswordError

+ (NSError *)errorWithCode:(NSInteger)code {
    
    NSString *errorDescription;
    PasswordErrorCode errorCode = code;
    switch (code) {
        case PasswordErrorCodeUserNotFound:
            errorDescription = @"User not found";
            break;
        case PasswordErrorCodeInvalidPassword:
            errorDescription = @"Invalid password";
            break;
        case PasswordErrorCodeUserAlreadyExists:
            errorDescription = @"User already exists";
            break;
        case PasswordErrorCodeServerError:
            errorDescription = @"Server error occurred";
            break;
        default:
            errorCode = PasswordErrorCodeUnknown;
            errorDescription = @"Unknown error occurred";
            break;
    }
    
    return [NSError errorWithDomain:PasswordErrorDomain
                             code:errorCode
                         userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
}

@end 
