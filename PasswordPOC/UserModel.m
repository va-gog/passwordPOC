#import "UserModel.h"

@interface UserModel()

@property (nonatomic, strong, readwrite) NSString *userId;
@property (nonatomic, assign, readwrite) BOOL hasFourDigitPassword;
@property (nonatomic, assign, readwrite) BOOL hasSixDigitPassword;

@end

@implementation UserModel

- (instancetype)initWithUserId:(NSString *)userId
           hasFourDigitPassword:(BOOL)hasFourDigitPassword
            hasSixDigitPassword:(BOOL)hasSixDigitPassword {
    self = [super init];
    if (self) {
        _userId = userId;
        _hasFourDigitPassword = hasFourDigitPassword;
        _hasSixDigitPassword = hasSixDigitPassword;
    }
    return self;
}

- (void)updateFourDigitPasswordStatus:(BOOL)isSet {
    _hasFourDigitPassword = isSet;
}

- (void)updateSixDigitPasswordStatus:(BOOL)isSet {
    _hasSixDigitPassword = isSet;
}

@end 
