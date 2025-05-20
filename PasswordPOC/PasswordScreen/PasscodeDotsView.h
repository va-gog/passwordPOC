#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PasscodeDotsView : UIView

@property (nonatomic, assign) NSInteger digitsCount;

- (void)updateForSize:(CGSize)size;
- (void)updateDisplayForEnteredDigitsCount:(NSInteger)enteredDigitsCount;

@end

NS_ASSUME_NONNULL_END 
