#import <Foundation/Foundation.h>
#import "PasswordTypes.h"
#import "PasswordScreenModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppLaunchViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *userId;

- (void)initializeUserWithCompletion:(void (^)(BOOL success,
                                               NSError * _Nullable error))completion;

- (void)createPasswordScreenModelWithType:(PasswordType)type
                              completion:(void (^)(PasswordScreenModel * _Nullable model,
                                                   NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END 
