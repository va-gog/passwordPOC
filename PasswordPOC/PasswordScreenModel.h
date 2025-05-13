#import <Foundation/Foundation.h>
#import "PasswordTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface PasswordScreenModel : NSObject

@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, assign, readonly) PasswordType type;
@property (nonatomic, assign, readonly) BOOL isPasswordSet;


- (instancetype)initWithUserID:(NSString *)userID
                            type: (PasswordType)type
                   isPasswordSet:(BOOL)isPasswordSet;

@end

NS_ASSUME_NONNULL_END 
