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
        dotView.backgroundColor = [UIColor systemGrayColor];
        dotView.alpha = 0.3;
        [self addSubview:dotView];
        [self.dotViews addObject:dotView];
    }
    
    [self updateForSize:self.bounds.size];
}

- (void)updateForSize:(CGSize)size {
    BOOL isPortrait = size.height > size.width;
    CGFloat dotSpacing = isPortrait ? 20 : 10;
    CGFloat dotSize = isPortrait ? 20 : 10;
    
    [self removeConstraints:self.constraints];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.widthAnchor constraintEqualToConstant:self.digitsCount * dotSize + (self.digitsCount - 1) * dotSpacing],
        [self.heightAnchor constraintEqualToConstant:dotSize]
    ]];
    
    for (int i = 0; i < self.digitsCount; i++) {
        UIView *dotView = self.dotViews[i];
        dotView.layer.cornerRadius = dotSize / 2;
        [dotView removeConstraints:dotView.constraints];
        [NSLayoutConstraint activateConstraints:@[
            [dotView.widthAnchor constraintEqualToConstant:dotSize],
            [dotView.heightAnchor constraintEqualToConstant:dotSize],
            [dotView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
            [dotView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor
                                                  constant:i * dotSpacing + i * dotSize]
        ]];
    }
}

- (void)updateDisplayForEnteredDigitsCount:(NSInteger)enteredDigitsCount {
    for (NSInteger i = 0; i < self.dotViews.count; i++) {
        UIView *dotView = self.dotViews[i];
        if (i < enteredDigitsCount) {
            dotView.alpha = 1.0;
            dotView.backgroundColor = [UIColor systemBlueColor];
        } else {
            dotView.alpha = 0.3;
            dotView.backgroundColor = [UIColor systemGrayColor];
        }
    }
}

@end 
