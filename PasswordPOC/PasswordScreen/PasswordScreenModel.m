//
//  PasswordScreenModel.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 04.06.25.
//

#import "PasswordScreenModel.h"

@implementation PasswordScreenModel

- (instancetype)initWithUserID:(NSString *)userID
                          type: (PasswordType)type
                 isPasswordSet:(BOOL)isPasswordSet
                     titleText:(NSString *)titleText
             presentationModel:(PasscodePresentationModel *)presentationModel {
    self = [super init];
    if (self) {
        _userID = userID;
        _type = type;
        _isPasswordSet = isPasswordSet;
        _titleText = titleText;
        _presentationModel = presentationModel ?: [PasscodePresentationModel defaultModel];
    }
    return self;
}

@end 
