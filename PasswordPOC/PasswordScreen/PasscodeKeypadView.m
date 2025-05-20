#import "PasscodeKeypadView.h"

@interface PasscodeKeypadView ()

@property (nonatomic, strong) NSMutableArray<UIButton *> *keypadButtons;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation PasscodeKeypadView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.keypadButtons = [NSMutableArray array];
        [self setupKeypad];
    }
    return self;
}

- (void)setupKeypad {
    for (int i = 1; i <= 9; i++) {
        [self createKeypadButtonWithNumber:i];
    }
    
    [self createKeypadButtonWithNumber:0];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deleteButton setImage:[UIImage systemImageNamed:@"delete.left"] forState:UIControlStateNormal];
    self.deleteButton.tintColor = [UIColor labelColor];
    [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    [self updateForSize:self.bounds.size];
}

- (void)createKeypadButtonWithNumber:(int)number {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.tag = number;
    [button setTitle:[NSString stringWithFormat:@"%d", number] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightRegular];
    
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor systemGrayColor].CGColor;
    
    [button addTarget:self action:@selector(keypadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [self.keypadButtons addObject:button];
}

- (void)updateForSize:(CGSize)size {
    BOOL isPortrait = size.height > size.width;
    CGFloat buttonSpacing = isPortrait ? 20 : 10;
    CGFloat buttonSize = isPortrait ? 80 : 40;
    
    [self removeConstraints:self.constraints];
    
    for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
            int index = row * 3 + col;
            UIButton *button = self.keypadButtons[index];
            button.layer.cornerRadius = buttonSize / 2;
            [button removeConstraints:button.constraints];

            [NSLayoutConstraint activateConstraints:@[
                [button.widthAnchor constraintEqualToConstant:buttonSize],
                [button.heightAnchor constraintEqualToConstant:buttonSize],
                [button.topAnchor constraintEqualToAnchor:self.topAnchor constant:row * (buttonSize + buttonSpacing)],
                [button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:col * (buttonSize + buttonSpacing)]
            ]];
        }
    }
    
    UIButton *zeroButton = self.keypadButtons[9];
    zeroButton.layer.cornerRadius = buttonSize / 2;
    
    [self.deleteButton removeConstraints:self.deleteButton.constraints];
    [zeroButton removeConstraints:zeroButton.constraints];

    [NSLayoutConstraint activateConstraints:@[
        [self.deleteButton.centerYAnchor constraintEqualToAnchor:zeroButton.centerYAnchor],
        [self.deleteButton.leadingAnchor constraintEqualToAnchor:zeroButton.trailingAnchor constant:buttonSpacing],
        [self.deleteButton.widthAnchor constraintEqualToConstant:buttonSize],
        [self.deleteButton.heightAnchor constraintEqualToConstant:buttonSize],
        
        [zeroButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:3 * (buttonSize + buttonSpacing)],
        [zeroButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [zeroButton.widthAnchor constraintEqualToConstant:buttonSize],
        [zeroButton.heightAnchor constraintEqualToConstant:buttonSize],
        
        [self.widthAnchor constraintEqualToConstant:3 * buttonSize + 2 * buttonSpacing],
        [self.heightAnchor constraintEqualToConstant:4 * buttonSize + 3 * buttonSpacing]
    ]];
}

- (void)keypadButtonTapped:(UIButton *)sender {
    [self.delegate keypadButtonTapped:sender.tag];
}

- (void)deleteButtonTapped {
    [self.delegate deleteButtonTapped];
}

@end 
