#import "PasscodePresentationModel.h"

@interface PasscodePresentationModel()
// Private properties that are readwrite internally
@property (nonatomic, assign, readwrite) CGFloat topSpacing;
@property (nonatomic, assign, readwrite) CGFloat dotsSpacing;
@property (nonatomic, assign, readwrite) CGFloat keypadSpacing;
@property (nonatomic, assign, readwrite) CGFloat dotSize;
@property (nonatomic, assign, readwrite) CGFloat dotSpacing;
@property (nonatomic, strong, readwrite) UIColor *dotActiveColor;
@property (nonatomic, strong, readwrite) UIColor *dotInactiveColor;
@property (nonatomic, assign, readwrite) CGFloat dotInactiveAlpha;
@property (nonatomic, assign, readwrite) CGFloat buttonSize;
@property (nonatomic, assign, readwrite) CGFloat buttonSpacing;
@property (nonatomic, strong, readwrite) UIFont *buttonFont;
@property (nonatomic, strong, readwrite) UIColor *buttonTextColor;
@property (nonatomic, strong, readwrite) UIColor *buttonBorderColor;
@property (nonatomic, assign, readwrite) CGFloat buttonCornerRadius;
@end

@implementation PasscodePresentationModel

+ (instancetype)defaultModel {
    PasscodePresentationModel *model = [[PasscodePresentationModel alloc] init];
    model.digitsCount = 4;
    model.dotActiveColor = [UIColor systemBlueColor];
    model.dotInactiveColor = [UIColor systemGrayColor];
    model.dotInactiveAlpha = 0.3;
    model.buttonFont = [UIFont systemFontOfSize:28 weight:UIFontWeightRegular];
    model.buttonTextColor = [UIColor labelColor];
    model.buttonBorderColor = [UIColor systemGrayColor];
    return model;
}

- (void)updateForSize:(CGSize)size {
    BOOL isPortrait = size.height > size.width;
    
    // Update layout properties
    self.topSpacing = isPortrait ? 60 : 20;
    self.dotsSpacing = isPortrait ? 20 : 10;
    self.keypadSpacing = isPortrait ? 60 : 30;
    
    // Update dots properties
    self.dotSize = isPortrait ? 20 : 10;
    self.dotSpacing = isPortrait ? 20 : 10;
    
    // Update keypad properties
    self.buttonSize = isPortrait ? 80 : 40;
    self.buttonSpacing = isPortrait ? 20 : 10;
    self.buttonCornerRadius = self.buttonSize / 2;
}

@end 
