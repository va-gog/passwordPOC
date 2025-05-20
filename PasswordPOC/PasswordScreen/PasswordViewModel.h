#import <Foundation/Foundation.h>
#import "PasswordTypes.h"
#import "PasswordScreenModel.h"
#import "BackendService.h"
#import "KeychainService.h"
#import "BiometricService.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PasscodeEntryState) {
    PasscodeEntryStateInitial,          // Initial entry state
    PasscodeEntryStateConfirmation,     // Confirmation entry state (for new passcodes)
    PasscodeEntryStateValidation        // Validation state (for existing passcodes)
};

@interface PasswordViewModel : NSObject

@property (nonatomic, strong, readonly) PasswordScreenModel *screenModel;
@property (nonatomic, strong, readwrite) NSMutableString *enteredPasscode;
@property (nonatomic, strong, readwrite) NSString *initialPasscode;
@property (nonatomic, assign, readwrite) PasscodeEntryState entryState;

- (instancetype)initWithScreenModel:(PasswordScreenModel *)screenModel
                     backendService:(id<BackendServiceProtocol>)backendService
                    keychainService:(id<KeychainServiceProtocol>)keychainService
                   biometricService:(id<BiometricServiceProtocol>)biometricService;

- (void)setPassword:(NSString *)password
         completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

- (void)validatePassword:(NSString *)password
              completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

- (void)loadPasswordFromKeychainWithCompletion:(void (^)(NSString * _Nullable password, NSError * _Nullable error))completion;

- (void)savePasswordToKeychain:(NSString *)password
                    completion:(void (^)(BOOL success,
                                         NSError * _Nullable error))completion;

- (void)authenticateWithBiometricsWithCompletion:(void (^)(BOOL success, NSError * _Nullable error))completion;

- (BOOL)canUseBiometricAuthentication:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END 
