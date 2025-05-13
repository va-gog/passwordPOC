#import "PasswordScreenModel.h"

@interface PasswordScreenModel()

@property (nonatomic, strong, readwrite) NSString *userID;
@property (nonatomic, assign, readwrite) PasswordType type;
@property (nonatomic, assign, readwrite) BOOL isPasswordSet;

@end

@implementation PasswordScreenModel

- (instancetype)initWithUserID:(NSString *)userID
                            type: (PasswordType)type
                   isPasswordSet:(BOOL)isPasswordSet {
    self = [super init];
    if (self) {
        _userID = userID;
        _type = type;
        _isPasswordSet = isPasswordSet;
    }
    return self;
}

@end 
