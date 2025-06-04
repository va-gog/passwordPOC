//
//  KeychainService.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import <Foundation/Foundation.h>
#import "PasswordTypes.h"
#import "KeychainServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface KeychainService : NSObject <KeychainServiceProtocol>

@end

NS_ASSUME_NONNULL_END 
