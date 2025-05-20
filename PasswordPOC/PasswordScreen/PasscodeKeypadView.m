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
        self.presentationModel = [PasscodePresentationModel defaultModel];
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
    self.deleteButton.tintColor = self.presentationModel.buttonTextColor;
    [self.deleteButton addTarget:self action:@selector(deleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    [self updateForSize:self.bounds.size];
}

- (void)createKeypadButtonWithNumber:(int)number {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.tag = number;
    [button setTitle:[NSString stringWithFormat:@"%d", number] forState:UIControlStateNormal];
    [button setTitleColor:self.presentationModel.buttonTextColor forState:UIControlStateNormal];
    button.titleLabel.font = self.presentationModel.buttonFont;
    
    button.layer.borderWidth = 1;
    button.layer.borderColor = self.presentationModel.buttonBorderColor.CGColor;
    
    [button addTarget:self action:@selector(keypadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    [self.keypadButtons addObject:button];
}

- (void)updateForSize:(CGSize)size {
    [self.presentationModel updateForSize:size];
    
    [self removeConstraints:self.constraints];
    
    for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
            int index = row * 3 + col;
            UIButton *button = self.keypadButtons[index];
            button.layer.cornerRadius = self.presentationModel.buttonCornerRadius;
            [button removeConstraints:button.constraints];

            [NSLayoutConstraint activateConstraints:@[
                [button.widthAnchor constraintEqualToConstant:self.presentationModel.buttonSize],
                [button.heightAnchor constraintEqualToConstant:self.presentationModel.buttonSize],
                [button.topAnchor constraintEqualToAnchor:self.topAnchor constant:row * (self.presentationModel.buttonSize + self.presentationModel.buttonSpacing)],
                [button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:col * (self.presentationModel.buttonSize + self.presentationModel.buttonSpacing)]
            ]];
        }
    }
    
    UIButton *zeroButton = self.keypadButtons[9];
    zeroButton.layer.cornerRadius = self.presentationModel.buttonCornerRadius;
    
    [self.deleteButton removeConstraints:self.deleteButton.constraints];
    [zeroButton removeConstraints:zeroButton.constraints];

    [NSLayoutConstraint activateConstraints:@[
        [self.deleteButton.centerYAnchor constraintEqualToAnchor:zeroButton.centerYAnchor],
        [self.deleteButton.leadingAnchor constraintEqualToAnchor:zeroButton.trailingAnchor constant:self.presentationModel.buttonSpacing],
        [self.deleteButton.widthAnchor constraintEqualToConstant:self.presentationModel.buttonSize],
        [self.deleteButton.heightAnchor constraintEqualToConstant:self.presentationModel.buttonSize],
        
        [zeroButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:3 * (self.presentationModel.buttonSize + self.presentationModel.buttonSpacing)],
        [zeroButton.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [zeroButton.widthAnchor constraintEqualToConstant:self.presentationModel.buttonSize],
        [zeroButton.heightAnchor constraintEqualToConstant:self.presentationModel.buttonSize],
        
        [self.widthAnchor constraintEqualToConstant:3 * self.presentationModel.buttonSize + 2 * self.presentationModel.buttonSpacing],
        [self.heightAnchor constraintEqualToConstant:4 * self.presentationModel.buttonSize + 3 * self.presentationModel.buttonSpacing]
    ]];
}

- (void)keypadButtonTapped:(UIButton *)sender {
    [self.delegate keypadButtonTapped:sender.tag];
}

- (void)deleteButtonTapped {
    [self.delegate deleteButtonTapped];
}

@end 
