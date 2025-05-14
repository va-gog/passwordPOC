#import <Foundation/Foundation.h>
#import "PasswordTypes.h"
#import "PasswordScreenModel.h"
#import "BackendService.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppLaunchViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *userId;
@property (nonatomic, strong, readonly) id<BackendServiceProtocol> backendService;

- (instancetype)initWithBackendService:(id<BackendServiceProtocol>)backendService;

- (void)initializeUserWithCompletion:(void (^)(BOOL success,
                                               NSError * _Nullable error))completion;

- (void)createPasswordScreenModelWithType:(PasswordType)type
                              completion:(void (^)(PasswordScreenModel * _Nullable model,
                                                   NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END 
