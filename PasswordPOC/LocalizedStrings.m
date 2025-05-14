//
//  LocalizedStrings.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import "LocalizedStrings.h"

@implementation LocalizedStrings

#pragma mark - Common Strings

+ (NSString *)ok {
    return NSLocalizedString(@"OK", @"OK button title");
}

+ (NSString *)yes {
    return NSLocalizedString(@"Yes", @"Yes button title");
}

+ (NSString *)no {
    return NSLocalizedString(@"No", @"No button title");
}

+ (NSString *)error {
    return NSLocalizedString(@"Error", @"Error alert title");
}

+ (NSString *)success {
    return NSLocalizedString(@"Success", @"Success alert title");
}

#pragma mark - Password ViewController Strings
+ (NSString *)enterPassword {
    return NSLocalizedString(@"Enter password", @"Password field placeholder");
}

+ (NSString *)enterFourDigitPassword {
    return NSLocalizedString(@"Enter 4-digit password", @"Enter 4-digit password text");
}

+ (NSString *)enterSixDigitPassword {
    return NSLocalizedString(@"Enter 6-digit password", @"Enter 6-digit password text");
}

+ (NSString *)setFourPassword {
    return NSLocalizedString(@"Please set 4-digit password", @"Set 4-digit password text");
}

+ (NSString *)setSixPassword {
    return NSLocalizedString(@"Please set 6-digit password", @"Set 6-digit password text");
}

+ (NSString *)authenticateToAccessPassword {
    return NSLocalizedString(@"Authenticate to access password", @"Biometric authentication reason");
}

+ (NSString *)passwordSetSuccessfully {
    return NSLocalizedString(@"Password set successfully", @"Success message for password set");
}

+ (NSString *)saveToKeychainQuestion {
    return NSLocalizedString(@"Password set successfully. Would you like to save it to Keychain?", @"Question for saving to keychain");
}

+ (NSString *)passwordValidated {
    return NSLocalizedString(@"Password validated successfully", @"Success message for password validation");
}

#pragma mark - Keychain Operation Strings

+(NSString *)passwordSavedToKeychain {
   return NSLocalizedString(@"Password saved to keychain successfully", @"Success message for keychain save");
}

+ (NSString *)passwordLoadedFromKeychain {
   return NSLocalizedString(@"Password loaded from keychain successfully", @"Success message for keychain load");
}

+ (NSString *)failedToSavePasswordToKeychain {
   return NSLocalizedString(@"Failed to save password to keychain", @"Error message for keychain save");
}

+ (NSString *)failedToLoadPasswordFromKeychain {
   return NSLocalizedString(@"Failed to load password from keychain", @"Error message for keychain load");
}

#pragma mark - AppLaunchViewModel Strings

+ (NSString *)fourDigitPasswordButtonTitle {
   return NSLocalizedString(@"4-Digit Password", @"4-Digit Password button title");
}

+ (NSString *)sixDigitPasswordButtonTitle {
   return NSLocalizedString(@"6-Digit Password", @"6-Digit Password button title");
}

#pragma mark - Error Messages

+ (NSString *)invalidPasswordType {
   return NSLocalizedString(@"Invalid password type", @"Error message for invalid password type");
}

+ (NSString *)userNotFound {
   return NSLocalizedString(@"User not found", @"Error message for user not found");
}

+ (NSString *)serverError {
   return NSLocalizedString(@"Server error occurred", @"Error message for server error");
}

+ (NSString *)userAlreadyExists {
   return NSLocalizedString(@"User already exists", @"Error message for existing user");
}

+ (NSString *)somethingWentWrong {
   return NSLocalizedString(@"Something went wrong", @"Generic error message");
}

@end
