#import <UIKit/UIKit.h>

@interface PlayingCardView : UIView

@property (nonatomic) NSUInteger rank;
@property (strong, nonatomic) NSString *suit;

@property (nonatomic, getter=isFaceUp) BOOL faceUp;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)animateIncorrectChoose;

@end
