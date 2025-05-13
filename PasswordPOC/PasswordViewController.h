#import <UIKit/UIKit.h>
#import "PasswordTypes.h"
#import "PasswordScreenModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PasswordViewController : UIViewController

@property (nonatomic, strong) PasswordScreenModel *screenModel;
@property (nonatomic, assign, readonly) BOOL isSettingPassword;
@property (nonatomic, assign, readonly) BOOL isFourDigitPassword;
@property (nonatomic, assign, readonly) BOOL isSixDigitPassword;

@property (nonatomic, copy) void (^onPasswordValidated)(BOOL success, NSError * _Nullable error);
@property (nonatomic, copy) void (^onPasswordSet)(BOOL success, NSError * _Nullable error);

@end

NS_ASSUME_NONNULL_END 
