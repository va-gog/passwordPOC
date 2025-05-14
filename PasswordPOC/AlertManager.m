//
//  AlertManager.m
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 14.05.25.
//

#import "AlertManager.h"

@implementation AlertManager

+ (UIAlertController *)showNotifyAlertWithTitle:(NSString *)title
                                         message:(NSString *)message
                                  confirmActionTitle:(NSString *)confirmActionTitle
                                   viewController:(UIViewController *)viewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:confirmActionTitle
                                             style:UIAlertActionStyleDefault
                                           handler:nil]];
    
    [viewController presentViewController:alert animated:YES completion:nil];
    return alert;
}

+ (UIAlertController *)showConfirmationAlertWithTitle:(NSString *)title
                                              message:(NSString *)message
                                        viewController:(UIViewController *)viewController
                                        confirmActionTitle:(NSString *)confirmActionTitle
                                        confirmHandler:(AlertActionHandler _Nullable)confirmHandler
                                         cancelActionTitle:(NSString *)cancelActionTitle
                                         cancelHandler:(AlertActionHandler _Nullable)cancelHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:confirmActionTitle
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        if (confirmHandler) {
            confirmHandler();
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:cancelActionTitle
                                             style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction * _Nonnull action) {
        if (cancelHandler) {
            cancelHandler();
        }
    }]];
    
    [viewController presentViewController:alert animated:YES completion:nil];
    return alert;
}

+ (void)showNotificationHoodWithMessage:(NSString *)message onView:(UIView *)view {
    UIView *hoodView = [[UIView alloc] init];
    hoodView.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:0.85];
    hoodView.layer.cornerRadius = 10;
    hoodView.translatesAutoresizingMaskIntoConstraints = NO;
    hoodView.alpha = 0;
    
    // Create label for the message
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = message;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont boldSystemFontOfSize:16];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add label to hood
    [hoodView addSubview:messageLabel];
    
    // Add hood to main view (above everything else)
    [view addSubview:hoodView];
    
    // Setup constraints
    [NSLayoutConstraint activateConstraints:@[
        // Hood view constraints - centered at top with padding
        [hoodView.topAnchor constraintEqualToAnchor:view.safeAreaLayoutGuide.topAnchor constant:20],
        [hoodView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor],
        [hoodView.widthAnchor constraintLessThanOrEqualToAnchor:view.widthAnchor constant:-40],
        [hoodView.heightAnchor constraintGreaterThanOrEqualToConstant:50],
        
        // Label constraints - fill hood with padding
        [messageLabel.topAnchor constraintEqualToAnchor:hoodView.topAnchor constant:10],
        [messageLabel.bottomAnchor constraintEqualToAnchor:hoodView.bottomAnchor constant:-10],
        [messageLabel.leadingAnchor constraintEqualToAnchor:hoodView.leadingAnchor constant:20],
        [messageLabel.trailingAnchor constraintEqualToAnchor:hoodView.trailingAnchor constant:-20],
    ]];
    
    // Animate the hood appearing
    [UIView animateWithDuration:0.3 animations:^{
        hoodView.alpha = 1.0;
    } completion:^(BOOL finished) {
        // After appearing, wait and then fade out
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                hoodView.alpha = 0.0;
            } completion:^(BOOL finished) {
                [hoodView removeFromSuperview];
            }];
        });
    }];
}

@end
