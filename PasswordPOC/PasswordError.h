#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PasswordErrorCode) {
    PasswordErrorCodeUnknown = -1,
    PasswordErrorCodeUserNotFound = 404,
    PasswordErrorCodeInvalidPassword = 400,
    PasswordErrorCodeUserAlreadyExists = 409,
    PasswordErrorCodeServerError = 500
};

extern NSString * const PasswordErrorDomain;

@interface PasswordError : NSObject

+ (NSError *)errorWithCode:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END 
