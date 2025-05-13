#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject

@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, assign, readonly) BOOL hasFourDigitPassword;
@property (nonatomic, assign, readonly) BOOL hasSixDigitPassword;

- (instancetype)initWithUserId:(NSString *)userId
           hasFourDigitPassword:(BOOL)hasFourDigitPassword
            hasSixDigitPassword:(BOOL)hasSixDigitPassword;

- (void)updateFourDigitPasswordStatus:(BOOL)isSet;
- (void)updateSixDigitPasswordStatus:(BOOL)isSet;

@end

NS_ASSUME_NONNULL_END 
