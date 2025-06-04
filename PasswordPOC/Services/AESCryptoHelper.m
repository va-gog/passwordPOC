//
//  AESCryptoHelper.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 04.06.25.
//

#import "AESCryptoHelper.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation AESCryptoHelper

+ (NSData *)encryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    size_t outLength;
    NSMutableData *cipherData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    CCCryptorStatus result = CCCrypt(kCCEncrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                     key.bytes, key.length, iv.bytes,
                                     data.bytes, data.length,
                                     cipherData.mutableBytes, cipherData.length, &outLength);
    if (result == kCCSuccess) {
        cipherData.length = outLength;
        return cipherData;
    }
    return nil;
}

+ (NSData *)decryptData:(NSData *)data key:(NSData *)key iv:(NSData *)iv {
    size_t outLength;
    NSMutableData *plainData = [NSMutableData dataWithLength:data.length + kCCBlockSizeAES128];
    CCCryptorStatus result = CCCrypt(kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                     key.bytes, key.length, iv.bytes,
                                     data.bytes, data.length,
                                     plainData.mutableBytes, plainData.length, &outLength);
    if (result == kCCSuccess) {
        plainData.length = outLength;
        return plainData;
    }
    return nil;
}

@end
