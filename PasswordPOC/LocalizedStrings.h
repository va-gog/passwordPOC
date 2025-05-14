//
//  LocalizedStrings.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalizedStrings : NSObject

// Common strings
+ (NSString *)ok;
+ (NSString *)yes;
+ (NSString *)no;
+ (NSString *)error;
+ (NSString *)success;

// Password ViewController Strings
+ (NSString *)enterPassword;
+ (NSString *)enterFourDigitPassword;
+ (NSString *)enterSixDigitPassword;
+ (NSString *)setFourPassword;
+ (NSString *)setSixPassword;
+ (NSString *)authenticateToAccessPassword;
+ (NSString *)passwordSetSuccessfully;
+ (NSString *)saveToKeychainQuestion;
+ (NSString *)passwordValidated;

// Keychain Operation Strings
+ (NSString *)passwordSavedToKeychain;
+ (NSString *)passwordLoadedFromKeychain;
+ (NSString *)failedToSavePasswordToKeychain;
+ (NSString *)failedToLoadPasswordFromKeychain;

// AppLaunchViewModel Strings
+ (NSString *)fourDigitPasswordButtonTitle;
+ (NSString *)sixDigitPasswordButtonTitle;

// Error Messages
+ (NSString *)invalidPasswordType;
+ (NSString *)userNotFound;
+ (NSString *)serverError;
+ (NSString *)userAlreadyExists;
+ (NSString *)somethingWentWrong;

@end

NS_ASSUME_NONNULL_END
