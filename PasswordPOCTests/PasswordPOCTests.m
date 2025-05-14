//
//  PasswordPOCTests.m
//  PasswordPOCTests
//
//  Created by Gohar Vardanyan on 12.05.25.
//
// PasswordViewModelTests.m

#import <XCTest/XCTest.h>
#import "PasswordViewModel.h"
#import "PasswordScreenModel.h"
#import "PasswordError.h"
#import "MockBackendService.h"
#import "MockKeychainService.h"
#import "MockBiometricService.h"

@interface PasswordViewModelTests : XCTestCase

@property (nonatomic, strong) PasswordViewModel *viewModel;
@property (nonatomic, strong) PasswordScreenModel *screenModel;
@property (nonatomic, strong) MockBackendService *mockBackendService;
@property (nonatomic, strong) MockKeychainService *mockKeychainService;
@property (nonatomic, strong) MockBiometricService *mockBiometricService;

@end

@implementation PasswordViewModelTests

#pragma mark - Setup and Teardown

- (void)setUp {
    [super setUp];
    
    // Create screen model
    self.screenModel = [[PasswordScreenModel alloc] initWithUserID:@"test_user_id"
                                                              type:PasswordTypeFourDigit
                                                     isPasswordSet:YES
                                                         titleText:@"Test Title"
                                                       digitsCount:4];
    
    // Create mock services
    self.mockBackendService = [[MockBackendService alloc] init];
    self.mockKeychainService = [[MockKeychainService alloc] init];
    self.mockBiometricService = [[MockBiometricService alloc] init];
    
    // Initialize view model with mocks
    self.viewModel = [[PasswordViewModel alloc] initWithScreenModel:self.screenModel
                                                     backendService:self.mockBackendService
                                                    keychainService:self.mockKeychainService
                                                   biometricService:self.mockBiometricService];
}

- (void)tearDown {
    self.viewModel = nil;
    self.screenModel = nil;
    self.mockBackendService = nil;
    self.mockKeychainService = nil;
    self.mockBiometricService = nil;
    [super tearDown];
}

#pragma mark - Setting Password Tests

- (void)testSetPasswordSuccess {
    // Arrange
    self.mockBackendService.shouldSucceedPasswordSet = YES;
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Set password completion"];
    
    [self.viewModel setPassword:@"1234" completion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertTrue(success, @"Setting password should succeed");
        XCTAssertNil(error, @"Error should be nil for successful password set");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBackendService.setPasswordCalled, @"setPassword should be called on backend service");
    XCTAssertEqual(self.mockBackendService.lastPasswordSet, @"1234", @"The correct password should be passed to service");
    XCTAssertEqual(self.mockBackendService.lastUserForSetPassword, @"test_user_id", @"The correct user ID should be passed");
    XCTAssertEqual(self.mockBackendService.lastTypeForSetPassword, PasswordTypeFourDigit, @"The correct password type should be passed");
}

- (void)testSetPasswordFailure {
    // Arrange
    self.mockBackendService.shouldSucceedPasswordSet = NO;
    self.mockBackendService.errorForPasswordSet = [NSError errorWithDomain:@"TestDomain" code:400 userInfo:nil];
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Set password completion"];
    
    [self.viewModel setPassword:@"1234" completion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertFalse(success, @"Setting password should fail");
        XCTAssertNotNil(error, @"Error should not be nil for failed password set");
        XCTAssertEqual(error.code, 400, @"Error code should match the original error");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBackendService.setPasswordCalled, @"setPassword should be called on backend service");
}

#pragma mark - Validate Password Tests

- (void)testValidatePasswordSuccess {
    // Arrange
    self.mockBackendService.shouldSucceedPasswordValidation = YES;
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Validate password completion"];
    
    [self.viewModel validatePassword:@"1234" completion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertTrue(success, @"Password validation should succeed");
        XCTAssertNil(error, @"Error should be nil for successful validation");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBackendService.validatePasswordCalled, @"validatePassword should be called on backend service");
    XCTAssertEqual(self.mockBackendService.lastPasswordValidated, @"1234", @"The correct password should be passed to service");
}

- (void)testValidatePasswordFailure {
    // Arrange
    self.mockBackendService.shouldSucceedPasswordValidation = NO;
    self.mockBackendService.errorForPasswordValidation = [NSError errorWithDomain:@"TestDomain" code:400 userInfo:nil];
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Validate password completion"];
    
    [self.viewModel validatePassword:@"1234" completion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertFalse(success, @"Password validation should fail");
        XCTAssertNotNil(error, @"Error should not be nil for failed validation");
        XCTAssertEqual(error.code, 400, @"Error code should match the original error");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBackendService.validatePasswordCalled, @"validatePassword should be called on backend service");
}

- (void)testInvalidPasswordValidation {
    // Arrange
    self.mockBackendService.shouldSucceedPasswordValidation = NO;
    self.mockBackendService.errorForPasswordValidation = nil; // No error, just invalid password
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Validate password completion"];
    
    [self.viewModel validatePassword:@"1234" completion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertFalse(success, @"Password validation should fail");
        XCTAssertNil(error, @"Error should be nil for invalid password without error");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

#pragma mark - Keychain Tests

- (void)testSavePasswordToKeychain {
    // Arrange
    self.mockKeychainService.shouldSucceedSaving = YES;
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Save to keychain completion"];
    
    [self.viewModel savePasswordToKeychain:@"1234" completion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertTrue(success, @"Saving to keychain should succeed");
        XCTAssertNil(error, @"Error should be nil for successful keychain save");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockKeychainService.savePasswordCalled, @"savePassword should be called on keychain service");
    XCTAssertEqual(self.mockKeychainService.lastPasswordSaved, @"1234", @"The correct password should be saved");
    XCTAssertEqual(self.mockKeychainService.lastUserForSave, @"test_user_id", @"The correct user ID should be passed");
    XCTAssertEqual(self.mockKeychainService.lastTypeForSave, PasswordTypeFourDigit, @"The correct password type should be passed");
}

- (void)testSavePasswordToKeychainFailure {
    // Arrange
    self.mockKeychainService.shouldSucceedSaving = NO;
    self.mockKeychainService.errorForSaving = [NSError errorWithDomain:@"KeychainError" code:123 userInfo:nil];
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Save to keychain completion"];
    
    [self.viewModel savePasswordToKeychain:@"1234" completion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertFalse(success, @"Saving to keychain should fail");
        XCTAssertNotNil(error, @"Error should not be nil for failed keychain save");
        XCTAssertEqual(error.code, 123, @"Error code should match the original error");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testLoadPasswordFromKeychain {
    // Arrange
    self.mockKeychainService.shouldSucceedLoading = YES;
    self.mockKeychainService.passwordToReturn = @"1234";
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Load from keychain completion"];
    
    [self.viewModel loadPasswordFromKeychainWithCompletion:^(NSString * _Nullable password, NSError * _Nullable error) {
        // Assert
        XCTAssertEqualObjects(password, @"1234", @"The loaded password should match the expected value");
        XCTAssertNil(error, @"Error should be nil for successful keychain load");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockKeychainService.loadPasswordCalled, @"loadPassword should be called on keychain service");
    XCTAssertEqual(self.mockKeychainService.lastUserForLoad, @"test_user_id", @"The correct user ID should be passed");
    XCTAssertEqual(self.mockKeychainService.lastTypeForLoad, PasswordTypeFourDigit, @"The correct password type should be passed");
}

- (void)testLoadPasswordFromKeychainFailure {
    // Arrange
    self.mockKeychainService.shouldSucceedLoading = NO;
    self.mockKeychainService.errorForLoading = [NSError errorWithDomain:@"KeychainError" code:456 userInfo:nil];
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Load from keychain completion"];
    
    [self.viewModel loadPasswordFromKeychainWithCompletion:^(NSString * _Nullable password, NSError * _Nullable error) {
        // Assert
        XCTAssertNil(password, @"Password should be nil for failed keychain load");
        XCTAssertNotNil(error, @"Error should not be nil for failed keychain load");
        XCTAssertEqual(error.code, 456, @"Error code should match the original error");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

#pragma mark - Biometrics Tests

- (void)testAuthenticateWithBiometricsSuccess {
    // Arrange
    self.mockBiometricService.shouldSucceedAuthentication = YES;
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Biometric authentication completion"];
    
    [self.viewModel authenticateWithBiometricsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertTrue(success, @"Biometric authentication should succeed");
        XCTAssertNil(error, @"Error should be nil for successful authentication");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBiometricService.authenticateCalled, @"authenticate should be called on biometric service");
    XCTAssertNotNil(self.mockBiometricService.lastReason, @"Authentication reason should be provided");
}

- (void)testAuthenticateWithBiometricsFailure {
    // Arrange
    self.mockBiometricService.shouldSucceedAuthentication = NO;
    self.mockBiometricService.errorForAuthentication = [NSError errorWithDomain:@"BiometricError" code:789 userInfo:nil];
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Biometric authentication completion"];
    
    [self.viewModel authenticateWithBiometricsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertFalse(success, @"Biometric authentication should fail");
        XCTAssertNotNil(error, @"Error should not be nil for failed authentication");
        XCTAssertEqual(error.code, 789, @"Error code should match the original error");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testCanUseBiometricAuthentication {
    // Arrange
    self.mockBiometricService.biometricsAvailable = YES;
    
    // Act
    NSError *error = nil;
    BOOL canUse = [self.viewModel canUseBiometricAuthentication:&error];
    
    // Assert
    XCTAssertTrue(canUse, @"Should be able to use biometric authentication");
    XCTAssertNil(error, @"Error should be nil when biometrics are available");
    XCTAssertTrue(self.mockBiometricService.canUseBiometricsCalled, @"canUseBiometrics should be called on biometric service");
}

- (void)testCannotUseBiometricAuthentication {
    // Arrange
    self.mockBiometricService.biometricsAvailable = NO;
    self.mockBiometricService.errorForCanUseBiometrics = [NSError errorWithDomain:@"BiometricError" code:987 userInfo:nil];
    
    // Act
    NSError *error = nil;
    BOOL canUse = [self.viewModel canUseBiometricAuthentication:&error];
    
    // Assert
    XCTAssertFalse(canUse, @"Should not be able to use biometric authentication");
    XCTAssertNotNil(error, @"Error should not be nil when biometrics are unavailable");
    XCTAssertEqual(error.code, 987, @"Error code should match the original error");
}

@end
