#import <UIKit/UIKit.h>
#import "PasscodePresentationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PasscodeDotsView : UIView

@property (nonatomic, strong, readwrite) PasscodePresentationModel *presentationModel;
@property (nonatomic, assign, readwrite) NSInteger digitsCount;

- (void)updateForSize:(CGSize)size;
- (void)updateDisplayForEnteredDigitsCount:(NSInteger)enteredDigitsCount;

@end

NS_ASSUME_NONNULL_END 
