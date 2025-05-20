#import "PasscodeDotsView.h"

@interface PasscodeDotsView () 

@property (nonatomic, strong) NSMutableArray<UIView *> *dotViews;

@end

@implementation PasscodeDotsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dotViews = [NSMutableArray array];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.presentationModel = [PasscodePresentationModel defaultModel];
    }
    return self;
}

- (void)setDigitsCount:(NSInteger)digitsCount {
    _digitsCount = digitsCount;
    [self setupDots];
}

- (void)setupDots {
    [self.dotViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.dotViews removeAllObjects];
    
    for (int i = 0; i < self.digitsCount; i++) {
        UIView *dotView = [[UIView alloc] init];
        dotView.translatesAutoresizingMaskIntoConstraints = NO;
        dotView.backgroundColor = self.presentationModel.dotInactiveColor;
        dotView.alpha = self.presentationModel.dotInactiveAlpha;
        [self addSubview:dotView];
        [self.dotViews addObject:dotView];
    }
    
    [self updateForSize:self.bounds.size];
}

- (void)updateForSize:(CGSize)size {
    [self.presentationModel updateForSize:size];
    
    [self removeConstraints:self.constraints];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.widthAnchor constraintEqualToConstant:self.digitsCount * self.presentationModel.dotSize + (self.digitsCount - 1) * self.presentationModel.dotSpacing],
        [self.heightAnchor constraintEqualToConstant:self.presentationModel.dotSize]
    ]];
    
    for (int i = 0; i < self.digitsCount; i++) {
        UIView *dotView = self.dotViews[i];
        dotView.layer.cornerRadius = self.presentationModel.dotSize / 2;
        [dotView removeConstraints:dotView.constraints];
        [NSLayoutConstraint activateConstraints:@[
            [dotView.widthAnchor constraintEqualToConstant:self.presentationModel.dotSize],
            [dotView.heightAnchor constraintEqualToConstant:self.presentationModel.dotSize],
            [dotView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [dotView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                  constant:i * self.presentationModel.dotSpacing + i * self.presentationModel.dotSize]
        ]];
    }
}

- (void)updateDisplayForEnteredDigitsCount:(NSInteger)enteredDigitsCount {
    for (NSInteger i = 0; i < self.dotViews.count; i++) {
        UIView *dotView = self.dotViews[i];
        if (i < enteredDigitsCount) {
            dotView.alpha = 1.0;
            dotView.backgroundColor = self.presentationModel.dotActiveColor;
        } else {
            dotView.alpha = self.presentationModel.dotInactiveAlpha;
            dotView.backgroundColor = self.presentationModel.dotInactiveColor;
        }
    }
}

@end 
