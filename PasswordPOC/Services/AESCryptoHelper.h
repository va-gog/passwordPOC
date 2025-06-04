//
//  AESCryptoHelper.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 04.06.25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AESCryptoHelper : NSObject

+ (NSData *)encryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;
+ (NSData *)decryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv;

@end

NS_ASSUME_NONNULL_END
