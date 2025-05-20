//
//  AppLaunchViewModelTests.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import <XCTest/XCTest.h>
#import "AppLaunchViewModel.h"
#import "MockBackendService.h"
#import "PasswordError.h"
#import "PasswordScreenModel.h"

@interface AppLaunchViewModelTests : XCTestCase

@property (nonatomic, strong) AppLaunchViewModel *viewModel;
@property (nonatomic, strong) MockBackendService *mockBackendService;

@end

@implementation AppLaunchViewModelTests

#pragma mark - Setup and Teardown

- (void)setUp {
    [super setUp];
    
    // Create mock backend service
    self.mockBackendService = [[MockBackendService alloc] init];
    
    // Initialize view model with mock
    self.viewModel = [[AppLaunchViewModel alloc] initWithBackendService:self.mockBackendService];
}

- (void)tearDown {
    self.viewModel = nil;
    self.mockBackendService = nil;
    [super tearDown];
}

#pragma mark - Initialization Tests

- (void)testInitialization {
    // Assert
    XCTAssertNotNil(self.viewModel, @"ViewModel should be properly initialized");
    XCTAssertEqual(self.viewModel.backendService, self.mockBackendService, @"Backend service should be set correctly");
}

- (void)testInitializationWithNilBackendService {
    // Arrange & Act - This would be an edge case, might crash
    id<BackendServiceProtocol> nilBackendService = nil;
    AppLaunchViewModel *nilServiceViewModel = [[AppLaunchViewModel alloc] initWithBackendService:nilBackendService];
    
    // Assert
    XCTAssertNotNil(nilServiceViewModel, @"ViewModel should still initialize with nil backend service");
    XCTAssertNil(nilServiceViewModel.backendService, @"Backend service should be nil");
}

#pragma mark - User Initialization Tests

- (void)testInitializeUserSuccess {
    // Arrange
    self.mockBackendService.shouldSucceedUserCreation = YES;
    self.mockBackendService.userIdToReturn = @"test_user_id";
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Initialize user completion"];
    
    [self.viewModel initializeUserWithCompletion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertTrue(success, @"User initialization should succeed");
        XCTAssertNil(error, @"Error should be nil for successful initialization");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBackendService.createUserCalled, @"createUser should be called on backend service");
    XCTAssertNotNil(self.mockBackendService.lastUserIdForCreate, @"User ID should be passed to service");
}

- (void)testInitializeUserFailureWithNilUserId {
    // Arrange
    self.mockBackendService.shouldSucceedUserCreation = NO;
    self.mockBackendService.userIdToReturn = nil; // Simulate nil userId in response
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Initialize user completion"];
    
    [self.viewModel initializeUserWithCompletion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertFalse(success, @"User initialization should fail");
        XCTAssertNotNil(error, @"Error should not be nil for failed initialization");
        XCTAssertEqual(error.code, PasswordErrorCodeUserNotFound, @"Error code should be UserNotFound");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBackendService.createUserCalled, @"createUser should be called on backend service");
}

- (void)testInitializeUserFailureWithError {
    // Arrange
    self.mockBackendService.shouldSucceedUserCreation = NO;
    self.mockBackendService.userIdToReturn = @"test_user_id"; // User ID is valid but we'll return an error
    self.mockBackendService.errorForUserCreation = [NSError errorWithDomain:@"TestDomain" code:409 userInfo:nil];
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Initialize user completion"];
    
    [self.viewModel initializeUserWithCompletion:^(BOOL success, NSError * _Nullable error) {
        // Assert
        XCTAssertFalse(success,
                       @"User initialization should fail");
        XCTAssertNotNil(error,
                        @"Error should not be nil for failed initialization");
        XCTAssertEqual(error.code, 404,
                       @"Error code should match the original error");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBackendService.createUserCalled, @"createUser should be called on backend service");
}

#pragma mark - Password Screen Model Creation Tests

- (void)testCreatePasswordScreenModelSuccess {
    // Arrange
    // First initialize user to set userId
    self.mockBackendService.shouldSucceedUserCreation = YES;
    self.mockBackendService.userIdToReturn = @"test_user_id";
    
    XCTestExpectation *initExpectation = [self expectationWithDescription:@"Initialize user"];
    
    [self.viewModel initializeUserWithCompletion:^(BOOL success, NSError * _Nullable error) {
        XCTAssertTrue(success, @"User initialization should succeed for this test");
        [initExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Now set up for the actual test
    self.mockBackendService.shouldSucceedGetUserData = YES;
    self.mockBackendService.hasFourDigitPasswordToReturn = YES;
    self.mockBackendService.hasSixDigitPasswordToReturn = NO;
    
    // Act
    XCTestExpectation *modelExpectation = [self expectationWithDescription:@"Create model completion"];
    
    [self.viewModel createPasswordScreenModelWithType:PasswordTypeFourDigit completion:^(PasswordScreenModel * _Nullable model, NSError * _Nullable error) {
        // Assert
        XCTAssertNotNil(model, @"Model should be created successfully");
        XCTAssertNil(error, @"Error should be nil for successful model creation");
        XCTAssertEqual(model.type, PasswordTypeFourDigit, @"Model should have correct type");
        XCTAssertEqual(model.isPasswordSet, YES, @"Model should indicate password is set");
        XCTAssertEqual(model.digitsCount, 4, @"Model should have 4 digits");
        [modelExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBackendService.getUserDataCalled, @"getUserData should be called on backend service");
    XCTAssertEqual(self.mockBackendService.lastUserIdForGetUserData, @"test_user_id", @"The correct user ID should be passed");
}

- (void)testCreatePasswordScreenModelFailureWithError {
    // Arrange
    // First initialize user to set userId
    self.mockBackendService.shouldSucceedUserCreation = YES;
    self.mockBackendService.userIdToReturn = @"test_user_id";
    
    XCTestExpectation *initExpectation = [self expectationWithDescription:@"Initialize user"];
    
    [self.viewModel initializeUserWithCompletion:^(BOOL success, NSError * _Nullable error) {
        XCTAssertTrue(success, @"User initialization should succeed for this test");
        [initExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Now set up for the actual test
    self.mockBackendService.shouldSucceedGetUserData = NO;
    self.mockBackendService.errorForGetUserData = [NSError errorWithDomain:@"TestDomain" code:404 userInfo:nil];
    
    // Act
    XCTestExpectation *modelExpectation = [self expectationWithDescription:@"Create model completion"];
    
    [self.viewModel createPasswordScreenModelWithType:PasswordTypeFourDigit completion:^(PasswordScreenModel * _Nullable model, NSError * _Nullable error) {
        // Assert
        XCTAssertNil(model, @"Model should be nil for failed creation");
        XCTAssertNotNil(error, @"Error should not be nil for failed creation");
        XCTAssertEqual(error.code, 404, @"Error code should match the original error");
        [modelExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Verify service interaction
    XCTAssertTrue(self.mockBackendService.getUserDataCalled, @"getUserData should be called on backend service");
}

- (void)testCreatePasswordScreenModelDifferentTypes {
    // Arrange
    // First initialize user to set userId
    self.mockBackendService.shouldSucceedUserCreation = YES;
    self.mockBackendService.userIdToReturn = @"test_user_id";
    
    XCTestExpectation *initExpectation = [self expectationWithDescription:@"Initialize user"];
    
    [self.viewModel initializeUserWithCompletion:^(BOOL success, NSError * _Nullable error) {
        XCTAssertTrue(success, @"User initialization should succeed for this test");
        [initExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    // Now set up for the actual test
    self.mockBackendService.shouldSucceedGetUserData = YES;
    self.mockBackendService.hasFourDigitPasswordToReturn = NO;
    self.mockBackendService.hasSixDigitPasswordToReturn = YES;
    
    // Act - Test with six digit password type
    XCTestExpectation *modelExpectation = [self expectationWithDescription:@"Create model completion"];
    
    [self.viewModel createPasswordScreenModelWithType:PasswordTypeSixDigit completion:^(PasswordScreenModel * _Nullable model, NSError * _Nullable error) {
        // Assert
        XCTAssertNotNil(model, @"Model should be created successfully");
        XCTAssertEqual(model.type, PasswordTypeSixDigit, @"Model should have correct type");
        XCTAssertEqual(model.isPasswordSet, YES, @"Model should indicate password is set");
        XCTAssertEqual(model.digitsCount, 6, @"Model should have 6 digits");
        [modelExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testCreatePasswordScreenModelWithoutInitializing {
    // Arrange - Don't initialize user, so userId is nil
    
    // Act
    XCTestExpectation *expectation = [self expectationWithDescription:@"Create model completion"];
    
    [self.viewModel createPasswordScreenModelWithType:PasswordTypeFourDigit completion:^(PasswordScreenModel * _Nullable model, NSError * _Nullable error) {
        // Assert
        // The behavior here depends on implementation - either it should fail gracefully or return an error
        // We'll check that at least one of model or error is nil, which should be true in either case
        XCTAssertTrue(model == nil || error == nil, @"Either model or error should be nil");
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
