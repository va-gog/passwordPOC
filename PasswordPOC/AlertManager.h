//
//  AlertManager.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^AlertActionHandler)(void);

@interface AlertManager : NSObject

+ (UIAlertController *)showNotifyAlertWithTitle:(NSString *)title
                                       message:(NSString *)message
                                  confirmActionTitle:(NSString *)confirmActionTitle
                                 viewController:(UIViewController *)viewController;

+ (UIAlertController *)showConfirmationAlertWithTitle:(NSString *)title
                                              message:(NSString *)message
                                        viewController:(UIViewController *)viewController
                                   confirmActionTitle:(NSString *)confirmActionTitle
                                        confirmHandler:(AlertActionHandler _Nullable)confirmHandler
                                         cancelActionTitle:(NSString *)cancelActionTitle
                                         cancelHandler:(AlertActionHandler _Nullable)cancelHandler;

+ (void)showNotificationHoodWithMessage:(NSString *)message
                                 onView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
