#import "PasswordScreenModelFactory.h"
#import "LocalizedStrings.h"

@implementation PasswordScreenModelFactory

+ (instancetype)sharedInstance {
    static PasswordScreenModelFactory *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PasswordScreenModelFactory alloc] init];
    });
    return instance;
}

- (PasswordScreenModel *)createPasswordScreenModelWithType:(PasswordType)type
                                                  userID:(NSString *)userID
                                      hasFourDigitPassword:(BOOL)hasFourDigitPassword
                                       hasSixDigitPassword:(BOOL)hasSixDigitPassword {
    NSString *titleText = @"";
    NSInteger digitsCount = 0;
    BOOL hasPassword = NO;
    
    switch (type) {
        case PasswordTypeFourDigit:
            hasPassword = hasFourDigitPassword;
            titleText = hasPassword ? [LocalizedStrings enterFourDigitPassword] : [LocalizedStrings setFourPassword];
            digitsCount = 4;
            break;
        case PasswordTypeSixDigit:
            hasPassword = hasSixDigitPassword;
            titleText = hasPassword ? [LocalizedStrings enterSixDigitPassword] : [LocalizedStrings setSixPassword];
            digitsCount = 6;
            break;
        default:
            return nil;
    }
    
    return [[PasswordScreenModel alloc] initWithUserID:userID
                                                 type:type
                                        isPasswordSet:hasPassword
                                            titleText:titleText
                                          digitsCount:digitsCount];
}

@end 
