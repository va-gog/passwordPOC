#import <UIKit/UIKit.h>
#import "PasswordTypes.h"
#import "PasswordViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PasswordViewController : UIViewController

@property (nonatomic, strong) PasswordViewModel *viewModel;

@property (nonatomic, copy) void (^onPasswordValidated)(BOOL success, NSError * _Nullable error);
@property (nonatomic, copy) void (^onPasswordSet)(NSString * _Nullable password, NSError * _Nullable error);

@end

NS_ASSUME_NONNULL_END 
