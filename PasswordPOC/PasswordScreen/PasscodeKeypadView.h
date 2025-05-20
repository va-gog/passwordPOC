#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PasscodeKeypadViewDelegate <NSObject>
- (void)keypadButtonTapped:(NSInteger)digit;
- (void)deleteButtonTapped;
@end

@interface PasscodeKeypadView : UIView

@property (nonatomic, weak) id<PasscodeKeypadViewDelegate> delegate;

- (void)updateForSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END 