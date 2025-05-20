#import <Foundation/Foundation.h>
#import "PasswordTypes.h"
#import "PasscodePresentationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PasswordScreenModel : NSObject

@property (nonatomic, strong, readonly) NSString *userID;
@property (nonatomic, assign, readonly) PasswordType type;
@property (nonatomic, assign, readonly) BOOL isPasswordSet;
@property (nonatomic, assign, readonly) NSString *titleText;
@property (nonatomic, strong, readonly) PasscodePresentationModel *presentationModel;

- (instancetype)initWithUserID:(NSString *)userID
                          type: (PasswordType)type
                 isPasswordSet:(BOOL)isPasswordSet
                     titleText:(NSString *)titleText
                presentationModel:(PasscodePresentationModel *)presentationModel;

@end

NS_ASSUME_NONNULL_END 
