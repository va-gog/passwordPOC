//
//  PasscodePresentationModel.h
//  PasswordPOC
//
//  Created by Gohar Vardanyan on 04.06.25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PasscodePresentationModel : NSObject

// Common properties
@property (nonatomic, assign) NSInteger digitsCount;

// Layout properties
@property (nonatomic, assign, readonly) CGFloat topSpacing;
@property (nonatomic, assign, readonly) CGFloat dotsSpacing;
@property (nonatomic, assign, readonly) CGFloat keypadSpacing;

// Dots view properties
@property (nonatomic, assign, readonly) CGFloat dotSize;
@property (nonatomic, assign, readonly) CGFloat dotSpacing;
@property (nonatomic, strong, readonly) UIColor *dotActiveColor;
@property (nonatomic, strong, readonly) UIColor *dotInactiveColor;
@property (nonatomic, assign, readonly) CGFloat dotInactiveAlpha;

// Keypad properties
@property (nonatomic, assign, readonly) CGFloat buttonSize;
@property (nonatomic, assign, readonly) CGFloat buttonSpacing;
@property (nonatomic, strong, readonly) UIFont *buttonFont;
@property (nonatomic, strong, readonly) UIColor *buttonTextColor;
@property (nonatomic, strong, readonly) UIColor *buttonBorderColor;
@property (nonatomic, assign, readonly) CGFloat buttonCornerRadius;

// Size-dependent properties
- (void)updateForSize:(CGSize)size;

// Factory method
+ (instancetype)defaultModel;

@end

NS_ASSUME_NONNULL_END 
