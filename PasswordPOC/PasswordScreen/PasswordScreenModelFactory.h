//
//  PasswordScreenModelFactory.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 04.06.25.
//

#import <Foundation/Foundation.h>
#import "PasswordTypes.h"
#import "PasswordScreenModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PasswordScreenModelFactory : NSObject

+ (instancetype)sharedInstance;

- (PasswordScreenModel *)createPasswordScreenModelWithType:(PasswordType)type
                                                  userID:(NSString *)userID
                                      hasFourDigitPassword:(BOOL)hasFourDigitPassword
                                       hasSixDigitPassword:(BOOL)hasSixDigitPassword;

@end

NS_ASSUME_NONNULL_END 
