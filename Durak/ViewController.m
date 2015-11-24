//
//  ViewController.m
//  Durak
//
//  Created by Александр Карцев on 11/12/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import "ViewController.h"
#import "PlayingCardView.h"
#import "PlayingCard.h"
#import "PlayingCardDeck.h"
#import "DurakGameModel.h"
#import "iAd/ADBannerView.h"
#import "UIImage+ImageEffects.h"
#import "CoolButton.h"
#import "iRate.h"

@interface ViewController () <DurakGameProtocol, ADBannerViewDelegate, UIScrollViewDelegate, iRateDelegate>

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic, strong) DurakGameModel *gameModel;

@property (nonatomic, strong) PlayingCardDeck *deck;
@property (nonatomic, strong) PlayingCard *mainCard;
@property (nonatomic, assign) BOOL isWidthSreenMore320;

@property (nonatomic, strong) CoolButton * pauseButton;

@property UIScrollView *scrollView;
@property UIView *blurMask;
@property UIImageView *blurredBgImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    if (self.amount == DurakGameCardAmount36) {
        self.gameModel = [[DurakGameModel alloc] initWithBigDeck:NO];
    } else {
        self.gameModel = [[DurakGameModel alloc] initWithBigDeck:YES];
    }
    
    [self checkIfGameModelCorrect];
    
    if (self.view.bounds.size.width<=320.0f) {
        self.isWidthSreenMore320 = NO;
    }
    else
    {
        self.isWidthSreenMore320 = YES;
    }
    
    self.gameModel.delegate = self;
    
    self.view.backgroundColor = [UIColor greenColor];
    
    [self.button removeFromSuperview];
    NSLog(NSLocalizedString(@"Take", @"Take button"));
    CoolButton *button = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - 55.f, self.view.bounds.size.height - 140, 100, 40)];
    [button setTitle:NSLocalizedString(@"Take", @"Take button") forState:UIControlStateNormal];
    [self makeButtonPreparationsWithButton:button];
    button.tag = 0;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.button = button;
    
    [iRate sharedInstance].delegate = self;
    
    [self changeButtonName];
    [self disableButton];
    self.button.hidden = YES;
    [self.view bringSubviewToFront:self.button];
    [self updateUI];
    
    self.pauseButton = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 110, self.view.bounds.size.height - 140, 100, 40)];
    [self.pauseButton setTitle:NSLocalizedString(@"Pause", @"Pause button") forState:UIControlStateNormal];
    [self makeButtonPreparationsWithButton:self.pauseButton];
    self.pauseButton.tag = 0;
    [self.pauseButton addTarget:self action:@selector(changePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.pauseButton];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    self.blurredBgImage = [[UIImageView  alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.blurredBgImage setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:self.blurredBgImage];
    self.blurMask = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 0)];
    self.blurMask.backgroundColor = [UIColor whiteColor];
    self.blurredBgImage.layer.mask = self.blurMask.layer;
}

- (void)checkIfGameModelCorrect {
    
    NSUInteger firstSuitCounter = 0;
    NSUInteger secondSuitCounter = 0;
    NSUInteger thirdSuitCounter = 0;
    NSUInteger fourthSuitCounter = 0;

    for (PlayingCard *card in self.gameModel.selfParticipantCards) {
        if ([card.suit isEqualToString:@"♣"]) {
            firstSuitCounter++;
        }
        if ([card.suit isEqualToString:@"♠"]) {
            secondSuitCounter++;
        }
        if ([card.suit isEqualToString:@"♦"]) {
            thirdSuitCounter++;
        }
        if ([card.suit isEqualToString:@"♥"]) {
            fourthSuitCounter++;
        }
    }
    
    if (firstSuitCounter > 4 || secondSuitCounter > 4 || thirdSuitCounter > 4 || fourthSuitCounter > 4) {
        [self changeDeck];
    }
    
    firstSuitCounter = 0;
    secondSuitCounter = 0;
    thirdSuitCounter = 0;
    fourthSuitCounter = 0;
    
    for (PlayingCard *card in self.gameModel.computerParticipantCards) {
        if ([card.suit isEqualToString:@"♣"]) {
            firstSuitCounter++;
        }
        if ([card.suit isEqualToString:@"♠"]) {
            secondSuitCounter++;
        }
        if ([card.suit isEqualToString:@"♦"]) {
            thirdSuitCounter++;
        }
        if ([card.suit isEqualToString:@"♥"]) {
            fourthSuitCounter++;
        }
    }
    
    if (firstSuitCounter > 4 || secondSuitCounter > 4 || thirdSuitCounter > 4 || fourthSuitCounter > 4) {
        [self changeDeck];
    }
}

- (void)pickUpCardsComputer:(BOOL)yes
                  withCards:(NSArray *)cards
                 completion:(CompletionBlock)completion {
    if (yes) {
        [UIView animateWithDuration:0.5 animations:^{
            for (PlayingCard *card in cards) {
                for (UIView *view in self.view.subviews) {
                    if ([view isKindOfClass:[PlayingCardView class]]) {
                        PlayingCardView *cardView = (PlayingCardView *)view;
                        if (card.rank == cardView.rank) {
                            if ([card.suit isEqualToString:cardView.suit]) {
                                cardView.frame = CGRectMake(10, 20, 60, 80);
                                cardView.faceUp = NO;
                            }
                            
                        }
                    }
                }
            }
        } completion:^(BOOL finished) {
            completion();
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            for (PlayingCard *card in cards) {
                for (UIView *view in self.view.subviews) {
                    if ([view isKindOfClass:[PlayingCardView class]]) {
                        PlayingCardView *cardView = (PlayingCardView *)view;
                        if (card.rank == cardView.rank) {
                            if ([card.suit isEqualToString:cardView.suit]) {
                                cardView.frame = CGRectMake(10, self.view.bounds.size.height - 90.f, 60, 80);
                                cardView.faceUp = YES;
                            }
                        }
                    }
                }
            }
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}

- (void)sortComputerCardsWithCompletion:(CompletionBlock)completionBlock {
    [UIView animateWithDuration:0.5 animations:^{
        for (int i = 0; i < self.gameModel.computerParticipantCards.count; i++) {
            if (i == self.gameModel.computerParticipantCards.count - 1) {
                CGFloat xPosition = 0;
                
                if (self.gameModel.computerParticipantCards.count > 5) {
                    xPosition = self.view.bounds.size.width - 70;
                } else {
                    xPosition = self.view.bounds.size.width/2 + ((self.gameModel.computerParticipantCards.count - 1) * 50 + 60)/2 - 60;
                }
                
                PlayingCardView *cardView;
                
                for (UIView *view in self.view.subviews) {
                    if ([view isKindOfClass:[PlayingCardView class]]) {
                        PlayingCardView *tempCardView = (PlayingCardView *)view;
                        if ([(PlayingCard *)self.gameModel.computerParticipantCards[i] rank] == tempCardView.rank) {
                            if ([[(PlayingCard *)self.gameModel.computerParticipantCards[i] suit] isEqualToString:tempCardView.suit]) {
                                cardView = tempCardView;
                            }
                            cardView.faceUp = NO;
                        }
                    }
                }
                
                cardView.frame = CGRectMake(xPosition, 20, 60, 80);
                
                [self.view bringSubviewToFront:cardView];
            } else {
                
                CGFloat xPosition = 0;
                
                if (self.gameModel.computerParticipantCards.count > 5) {
                    xPosition = 10 + (self.view.bounds.size.width - 80)/(self.gameModel.computerParticipantCards.count - 1) * i;
                } else {
                    xPosition = self.view.bounds.size.width/2 - ((self.gameModel.computerParticipantCards.count - 1) * 50 + 60)/2 + 50 * i;
                }
                
                PlayingCardView *cardView;
                
                for (UIView *view in self.view.subviews) {
                    if ([view isKindOfClass:[PlayingCardView class]]) {
                        PlayingCardView *tempCardView = (PlayingCardView *)view;
                        if ([(PlayingCard *)self.gameModel.computerParticipantCards[i] rank] == tempCardView.rank) {
                            if ([[(PlayingCard *)self.gameModel.computerParticipantCards[i] suit] isEqualToString:tempCardView.suit]) {
                                cardView = tempCardView;
                            }
                            cardView.faceUp = NO;
                        }
                    }
                }
                
                cardView.frame = CGRectMake(xPosition, 20, 60, 80);
                
                [self.view bringSubviewToFront:cardView];
            }
        }
    } completion:^(BOOL finished) {
        completionBlock();
    }];
}

- (IBAction)buttonPressed:(id)sender {
    if (!self.gameModel.isComputerTurn) {
        [self.gameModel retreatPressed];
    } else {
        [self.gameModel pickUpPressed];
    }
}

- (void)disableButton {
    self.button.enabled = NO;
}

- (void)changeButtonName {
    self.button.hidden = NO;
    self.button.enabled = YES;
    if (!self.gameModel.isComputerTurn) {
        [self.button setTitle:NSLocalizedString(@"Skip", @"Skip button") forState:UIControlStateNormal];
    } else {
        [self.button setTitle:NSLocalizedString(@"Take", @"Take button") forState:UIControlStateNormal];
    }
}

- (void)takeCardFromDeckToComputer:(BOOL)yes
                   withPlayingCard:(PlayingCard *)card
                        completion:(CompletionBlock)block {
    
    if (self.gameModel.deck.lastCardsCount == 0) {
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[PlayingCardView class]]) {
                if (view.tag == 12) {
                    [view removeFromSuperview];
                }
            }
        }
    }
    
    CGRect rect;
    
    if (yes) {
        CGFloat xPosition = 0;
        if (self.gameModel.computerParticipantCards.count > 5) {
            xPosition = self.view.bounds.size.width - 70;
        } else {
            xPosition = self.view.bounds.size.width/2 + ((self.gameModel.computerParticipantCards.count - 1) * 50 + 60)/2 - 60;
        }
        rect = CGRectMake(xPosition, 20, 60, 80);
    } else {
        CGFloat xPosition = 0;
        if (self.gameModel.selfParticipantCards.count > 5) {
            xPosition = self.view.bounds.size.width - 70;
        } else {
            xPosition = self.view.bounds.size.width/2 + ((self.gameModel.selfParticipantCards.count - 1) * 50 + 60)/2 - 60;
        }
        rect = CGRectMake(xPosition, self.view.bounds.size.height - 90, 60, 80);
    }
    
    
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[PlayingCardView class]]) {
            PlayingCardView *cardView = (PlayingCardView *)view;
            if (cardView.rank == card.rank) {
                if ([cardView.suit isEqualToString:card.suit]) {
                    [UIView animateWithDuration:0.5f animations:^{
                        cardView.frame = rect;
                        double rads = ((0) / 180.0 * M_PI);
                        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
                        cardView.transform = transform;
                    } completion:^(BOOL finished) {
                        if (!yes) {
                            cardView.faceUp = YES;
                        }
                        block();
                    }];
                    return;
                }
            }
        }
    }
    
    float temp = self.isWidthSreenMore320 ? self.view.bounds.size.height/2 -40 : self.view.bounds.size.height - 170;
    PlayingCardView *cardView = [[PlayingCardView alloc] initWithFrame:CGRectMake(0,temp, 60, 80)];
    cardView.rank = card.rank;
    cardView.suit = card.suit;
    cardView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:cardView];
    
    
    
    [UIView animateWithDuration:0.5f animations:^{
        cardView.frame = rect;
    } completion:^(BOOL finished) {
        if (!yes) {
            cardView.faceUp = YES;
        }
        block();
    }];
}

- (void)sortUserCardsWithCompletion:(CompletionBlock)completionBlock {
    [UIView animateWithDuration:0.5 animations:^{
        for (int i = 0; i < self.gameModel.selfParticipantCards.count; i++) {
            if (i == self.gameModel.selfParticipantCards.count - 1) {
                CGFloat xPosition = 0;
                
                if (self.gameModel.selfParticipantCards.count > 5) {
                    xPosition = self.view.bounds.size.width - 70;
                } else {
                    xPosition = self.view.bounds.size.width/2 + ((self.gameModel.selfParticipantCards.count - 1) * 50 + 60)/2 - 60;
                }
                
                PlayingCardView *cardView;
                
                for (UIView *view in self.view.subviews) {
                    if ([view isKindOfClass:[PlayingCardView class]]) {
                        PlayingCardView *tempCardView = (PlayingCardView *)view;
                        if ([(PlayingCard *)self.gameModel.selfParticipantCards[i] rank] == tempCardView.rank) {
                            if ([[(PlayingCard *)self.gameModel.selfParticipantCards[i] suit] isEqualToString:tempCardView.suit]) {
                                cardView = tempCardView;
                            }
                            cardView.faceUp = YES;
                        }
                    }
                }
                
                if (cardView.gestureRecognizers.count == 0) {
                    [cardView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTouched:)]];
                }
                
                cardView.frame = CGRectMake(xPosition, self.view.bounds.size.height - 90.f, 60, 80);
                
                [self.view bringSubviewToFront:cardView];
            } else {
                
                CGFloat xPosition = 0;
                
                if (self.gameModel.selfParticipantCards.count > 5) {
                    xPosition = 10 + (self.view.bounds.size.width - 80)/(self.gameModel.selfParticipantCards.count - 1) * i;
                } else {
                    xPosition = self.view.bounds.size.width/2 - ((self.gameModel.selfParticipantCards.count - 1) * 50 + 60)/2 + 50 * i;
                }
                
                PlayingCardView *cardView;
                
                for (UIView *view in self.view.subviews) {
                    if ([view isKindOfClass:[PlayingCardView class]]) {
                        PlayingCardView *tempCardView = (PlayingCardView *)view;
                        if ([(PlayingCard *)self.gameModel.selfParticipantCards[i] rank] == tempCardView.rank) {
                            if ([[(PlayingCard *)self.gameModel.selfParticipantCards[i] suit] isEqualToString:tempCardView.suit]) {
                                cardView = tempCardView;
                            }
                            cardView.faceUp = YES;
                        }
                    }
                }
                
                if (cardView.gestureRecognizers.count == 0) {
                    [cardView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTouched:)]];
                }
                
                cardView.frame = CGRectMake(xPosition, self.view.bounds.size.height - 90.f, 60, 80);
                
                [self.view bringSubviewToFront:cardView];
            }
        }
    } completion:^(BOOL finished) {
        completionBlock();
    }];
}

- (void)makeTurnComputer:(BOOL)yes
                withCard:(PlayingCard *)card
              completion:(CompletionBlock)block {
    NSUInteger cardPosition = [self.gameModel.turnCards indexOfObject:card];
    
   /* for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[PlayingCardView class]] && view.tag == 12) {
            cardPosition++;
        }
    }*/
    
    PlayingCardView *playingCardView;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[PlayingCardView class]]) {
            PlayingCardView *cardView = (PlayingCardView *)view;
            if (cardView.rank == card.rank) {
                if ([cardView.suit isEqualToString:card.suit]) {
                    playingCardView = cardView;
                }
            }
        }
    }
    
    playingCardView.faceUp = YES;
    [self.view bringSubviewToFront:playingCardView];
    
    switch (cardPosition) {
        case 0: {
            [UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? -90 : -150;
                float tempHeight = self.isWidthSreenMore320 ? -100 : -130;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                playingCardView.frame = newFrame;
                for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                    [playingCardView  removeGestureRecognizer:recognizer];
                }
            } completion:^(BOOL finished) {
                block();
            }];}
            break;
            
        case 1: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? -70 : -130;
            float tempHeight = self.isWidthSreenMore320 ? -80 : -110;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 2: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? 0 : -60;
            float tempHeight = self.isWidthSreenMore320 ? -100 : -130;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 3: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? 20 : -40;
            float tempHeight = self.isWidthSreenMore320 ? -80 : -110;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 4: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? 90 : 30;
            float tempHeight = self.isWidthSreenMore320 ? -100 : -130;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 5: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? 110 : 50;
            float tempHeight = self.isWidthSreenMore320 ? -80 : -110;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 6: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? -90 : -150;
            float tempHeight = self.isWidthSreenMore320 ? 5 : -25;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 7: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? -70 : -130;
            float tempHeight = self.isWidthSreenMore320 ? 25 : -5;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2 + tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 8: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? 0 : -60;
            float tempHeight = self.isWidthSreenMore320 ? 5 : -25;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2+temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 9: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? 20 : -40;
            float tempHeight = self.isWidthSreenMore320 ? 25 : -5;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 + tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 10: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? 90 : 30;
            float tempHeight = self.isWidthSreenMore320 ? 5 : -25;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        case 11: {[UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            float temp = self.isWidthSreenMore320 ? 110 : 50;
            float tempHeight = self.isWidthSreenMore320 ? 25 : -5;
            CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 + tempHeight, 60, 80);
            playingCardView.frame = newFrame;
            for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                [playingCardView  removeGestureRecognizer:recognizer];
            }
        } completion:^(BOOL finished) {
            block();
        }];}
            break;
            
        default:
            break;
    }
    
}

- (void)moveCardToClear:(PlayingCard *)card
             completion:(CompletionBlock)block {
    PlayingCardView *playingCardView;
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[PlayingCardView class]]) {
            PlayingCardView *cardView = (PlayingCardView *)view;
            if (cardView.rank == card.rank) {
                if ([cardView.suit isEqualToString:card.suit]) {
                    playingCardView = cardView;
                    [UIView animateWithDuration:0.5 animations:^{
                        playingCardView.frame = CGRectMake(self.view.bounds.size.width + 10.f, self.view.bounds.size.height / 2 - playingCardView.frame.size.height / 2, playingCardView.frame.size.width, playingCardView.frame.size.height);
                    } completion:^(BOOL finished) {
                        [playingCardView removeFromSuperview];
                        block();
                    }];
                }
            }
        }
    }
}

- (void)updateUI {
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[PlayingCardView class]]) {
            if (view.tag != 12) {
                [view removeFromSuperview];
            }
        }
    }
    
    if (!self.gameModel.mainCardUsed) {
        float temp = self.isWidthSreenMore320 ? self.view.bounds.size.height/2 -40 : self.view.bounds.size.height - 170;
        NSLog(@"%f",self.view.bounds.size.height);
        PlayingCardView *cardView = [[PlayingCardView alloc] initWithFrame:CGRectMake(20, temp, 60, 80)];
        cardView.rank = [self.gameModel.mainCard rank];
        cardView.suit = [self.gameModel.mainCard suit];
        cardView.faceUp = YES;
        cardView.backgroundColor = [UIColor clearColor];
        double rads = ((90) / 180.0 * M_PI);
        CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
        cardView.transform = transform;
        [self.view addSubview:cardView];
    }
    
    if (self.gameModel.deck.lastCardsCount > 0) {
        float temp = self.isWidthSreenMore320 ? self.view.bounds.size.height/2 -40 : self.view.bounds.size.height - 170;
        PlayingCardView *faceDownCardView = [[PlayingCardView alloc] initWithFrame:CGRectMake(0,temp, 60, 80)];
        faceDownCardView.tag = 12;
        faceDownCardView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:faceDownCardView];
    }
    
    for (int i = 0; i < self.gameModel.computerParticipantCards.count; i++) {
        if (i == self.gameModel.computerParticipantCards.count - 1) {
            CGFloat xPosition = 0;
            
            if (self.gameModel.computerParticipantCards.count > 5) {
                xPosition = self.view.bounds.size.width - 70;
            } else {
                xPosition = self.view.bounds.size.width/2 + ((self.gameModel.computerParticipantCards.count - 1) * 50 + 60)/2 - 60;
            }
            
            PlayingCardView *cardView = [[PlayingCardView alloc] initWithFrame:CGRectMake(xPosition, 20, 60, 80)];
            cardView.rank = [(PlayingCard *)self.gameModel.computerParticipantCards[i] rank];
            cardView.suit = [(PlayingCard *)self.gameModel.computerParticipantCards[i] suit];
            
            cardView.backgroundColor = [UIColor clearColor];
            
            [self.view bringSubviewToFront:cardView];
            
            
            [self.view addSubview:cardView];
        } else {
            CGFloat xPosition = 0;
            
            if (self.gameModel.computerParticipantCards.count > 5) {
                xPosition = 10 + (self.view.bounds.size.width - 80)/(self.gameModel.computerParticipantCards.count - 1) * i;
            } else {
                xPosition = self.view.bounds.size.width/2 - ((self.gameModel.computerParticipantCards.count - 1) * 50 + 60)/2 + 50 * i;
            }
            
            PlayingCardView *cardView = [[PlayingCardView alloc] initWithFrame:CGRectMake(xPosition, 20, 60, 80)];
            cardView.rank = [(PlayingCard *)self.gameModel.computerParticipantCards[i] rank];
            cardView.suit = [(PlayingCard *)self.gameModel.computerParticipantCards[i] suit];
            cardView.backgroundColor = [UIColor clearColor];
            
            [self.view bringSubviewToFront:cardView];
            
            [self.view addSubview:cardView];
        }
    }
    
    for (int i = 0; i < self.gameModel.selfParticipantCards.count; i++) {
        if (i == self.gameModel.selfParticipantCards.count - 1) {
            CGFloat xPosition = 0;
            
            if (self.gameModel.selfParticipantCards.count > 5) {
                xPosition = self.view.bounds.size.width - 70;
            } else {
                xPosition = self.view.bounds.size.width/2 + ((self.gameModel.selfParticipantCards.count - 1) * 50 + 60)/2 - 60;
            }
            
            PlayingCardView *cardView = [[PlayingCardView alloc] initWithFrame:CGRectMake(xPosition, self.view.bounds.size.height - 90.f, 60, 80)];
            cardView.rank = [(PlayingCard *)self.gameModel.selfParticipantCards[i] rank];
            cardView.suit = [(PlayingCard *)self.gameModel.selfParticipantCards[i] suit];
            cardView.faceUp = YES;
            
            cardView.backgroundColor = [UIColor clearColor];
            
            [self.view bringSubviewToFront:cardView];
            
            [cardView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTouched:)]];
            
            [self.view addSubview:cardView];
        } else {
            
            CGFloat xPosition = 0;
            
            if (self.gameModel.selfParticipantCards.count > 5) {
                xPosition = 10 + (self.view.bounds.size.width - 80)/(self.gameModel.selfParticipantCards.count - 1) * i;
            } else {
                xPosition = self.view.bounds.size.width/2 - ((self.gameModel.selfParticipantCards.count - 1) * 50 + 60)/2 + 50 * i;
            }
            
            PlayingCardView *cardView = [[PlayingCardView alloc] initWithFrame:CGRectMake(xPosition , self.view.bounds.size.height - 90.f, 60, 80)];
            cardView.rank = [(PlayingCard *)self.gameModel.selfParticipantCards[i] rank];
            cardView.suit = [(PlayingCard *)self.gameModel.selfParticipantCards[i] suit];
            cardView.faceUp = YES;
            cardView.backgroundColor = [UIColor clearColor];
            
            [self.view bringSubviewToFront:cardView];
            
            [cardView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTouched:)]];
            
            [self.view addSubview:cardView];
        }
    }
}

- (void)cardTouched:(UITapGestureRecognizer *)recognizer {
    PlayingCard *card = [[PlayingCard alloc] init];
    card.rank = [(PlayingCardView *)recognizer.view rank];
    card.suit = [(PlayingCardView *)recognizer.view suit];
    if (![self.gameModel userTurnWithCard:card]) {
        [(PlayingCardView *)recognizer.view animateIncorrectChoose];
    }
}

- (void)faceUpCard:(PlayingCardView *)view {
    view.faceUp = YES;
}

- (void)removeTurnCards {
    for (UIView *view in self.view.subviews) {
        if (view.tag == 12) {
            [UIView animateWithDuration:1.f animations:^{
                view.frame = CGRectMake(self.view.bounds.size.width + 10, self.view.bounds.size.height / 2, view.bounds.size.width, view.bounds.size.height);
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
        }
    }
}

- (void)computerMakeTurnWithCard:(PlayingCard *)card {
    
    for (int i = 0; i < self.gameModel.turnCards.count; i++) {
        PlayingCard *playingCard = self.gameModel.turnCards[i];
        PlayingCardView *playingCardView;
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[PlayingCardView class]]) {
                PlayingCardView *cardView = (PlayingCardView *)view;
                if (cardView.rank == playingCard.rank) {
                    if ([cardView.suit isEqualToString:playingCard.suit]) {
                        playingCardView = cardView;
                    }
                }
            }
        }
        
       // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            playingCardView.faceUp = YES;
            [self.view bringSubviewToFront:playingCardView];
        //});
        
        playingCardView.tag = 12;
        
        NSTimeInterval oddCardDelay = 0.f;
        NSTimeInterval evenCardDelay = 0.f;
        
        if (self.gameModel.isComputerTurn) {
            evenCardDelay = 0.5f;
        } else {
            oddCardDelay = 0.5f;
        }
        
        [self.view bringSubviewToFront:playingCardView];
        
        switch (i) {
            case 0: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? -90 : -150;
                float tempHeight = self.isWidthSreenMore320 ? -100 : -130;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 1: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? -70 : -130;
                float tempHeight = self.isWidthSreenMore320 ? -80 : -110;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 2: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? 0 : -60;
                float tempHeight = self.isWidthSreenMore320 ? -100 : -130;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 3: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? 20 : -40;
                float tempHeight = self.isWidthSreenMore320 ? -80 : -110;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
            
            case 4: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? 90 : 30;
                float tempHeight = self.isWidthSreenMore320 ? -100 : -130;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 5: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? 110 : 50;
                float tempHeight = self.isWidthSreenMore320 ? -80 : -110;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 6: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? -90 : -159;
                float tempHeight = self.isWidthSreenMore320 ? 5 : -25;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 7: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? -70 : -130;
                float tempHeight = self.isWidthSreenMore320 ? 25 : -5;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2 + tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 8: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? 0 : -60;
                float tempHeight = self.isWidthSreenMore320 ? 5 : -25;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2+temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 9: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? 20 : -40;
                float tempHeight = self.isWidthSreenMore320 ? 25 : -5;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 + tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 10: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? 90 : 30;
                float tempHeight = self.isWidthSreenMore320 ? 5 : -25;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            case 11: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                float temp = self.isWidthSreenMore320 ? 110 : 50;
                float tempHeight = self.isWidthSreenMore320 ? 25 : -5;
                CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 + tempHeight, 60, 80);
                playingCardView.frame = newFrame;
            } completion:nil];}
                break;
                
            default:
                break;
        }
        
    }
}

- (IBAction)pickUpAction:(id)sender {
    if (self.gameModel.isComputerTurn) {
        [self.gameModel pickUpPressed];
    } else {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle: @"Error!"
                                                                            message: NSLocalizedString(@"Not allowed action", @"Not allowed action message")
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Dismiss", @"Dismiss message")
                                                              style: UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                
        }];
        [controller addAction: alertAction];
        [self presentViewController: controller animated: YES completion: nil];
    }
    
}

- (IBAction)retreatAction:(id)sender {
    if (!self.gameModel.isComputerTurn) {
        [self.gameModel retreatPressed];
    } else {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle: @"Error!"
                                                                            message: NSLocalizedString(@"Not allowed action", @"Not allowed action message")
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Dismiss", @"Dismiss message")
                                                              style: UIAlertActionStyleDestructive
                                                            handler: nil];
        [controller addAction: alertAction];
        [self presentViewController: controller animated: YES completion: nil];
    }
    
}

- (void)gameStateChanged {
    self.blurredBgImage.image = [self blurWithImageEffects:[self takeSnapshotOfView:self.view]];
    [self.view bringSubviewToFront:self.blurredBgImage];
    if (self.gameModel.gameState == DurakGameStateEndedWithUserWin) {
        
        NSInteger gamesPlayed = [[NSUserDefaults standardUserDefaults] integerForKey:@"Games played"];
        [[NSUserDefaults standardUserDefaults] setInteger:gamesPlayed + 1 forKey:@"Games played"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Prompt Was Shown"] == NO && [[NSUserDefaults standardUserDefaults] integerForKey:@"Games played"] > 4) {
            [[iRate sharedInstance] promptForRating];
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 60,self.view.bounds.size.height/5, 120, 30)];
        label.text = NSLocalizedString(@"Victory", @"victory message");
        label.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:30.f];
        label.textColor = [UIColor colorWithRed:40.f/256.f green:77./256.f blue:45.f/256.f alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 20;
        
        CoolButton *button2 = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 60, self.view.bounds.size.height/2 - 55, 120, 50)];
        [button2 setTitle:NSLocalizedString(@"Replay", @"Replay message") forState:UIControlStateNormal];
        [self makeButtonPreparationsWithButton:button2];
        [button2 addTarget:self action:@selector(changeDeckPressed) forControlEvents:UIControlEventTouchUpInside];
        
        CoolButton *button3 = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 100, self.view.bounds.size.height/2, 200, 50)];
        [button3 setTitle:NSLocalizedString(@"Main menu", @"Main menu message") forState:UIControlStateNormal];
        [self makeButtonPreparationsWithButton:button3];
        [button3 addTarget:self action:@selector(goToMainMenuPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:1.f animations:^{
            self.blurMask.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        } completion:^(BOOL finished) {
            [self.view addSubview:label];
            [self.view addSubview:button2];
            [self.view addSubview:button3];
        }];
    } else if (self.gameModel.gameState == DurakGameStateEndedWithComputerWin) {
        NSInteger gamesPlayed = [[NSUserDefaults standardUserDefaults] integerForKey:@"Games played"];
        [[NSUserDefaults standardUserDefaults] setInteger:gamesPlayed + 1 forKey:@"Games played"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Prompt Was Shown"] == NO && [[NSUserDefaults standardUserDefaults] integerForKey:@"Games played"] > 4) {
            [[iRate sharedInstance] promptForRating];
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 60,self.view.bounds.size.height/5, 120, 30)];
        label.text = NSLocalizedString(@"Defeat", @"Defeat message");
        label.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:30.f];
        label.textColor = [UIColor colorWithRed:40.f/256.f green:77./256.f blue:45.f/256.f alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 20;
        
        CoolButton *button2 = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 60, self.view.bounds.size.height/2 - 55, 120, 50)];
        [button2 setTitle:NSLocalizedString(@"Replay", @"Replay message") forState:UIControlStateNormal];
        [self makeButtonPreparationsWithButton:button2];
        [button2 addTarget:self action:@selector(changeDeckPressed) forControlEvents:UIControlEventTouchUpInside];
        
        CoolButton *button3 = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 100, self.view.bounds.size.height/2, 200, 50)];
        [button3 setTitle:NSLocalizedString(@"Main menu", @"Main menu message") forState:UIControlStateNormal];
        [self makeButtonPreparationsWithButton:button3];
        [button3 addTarget:self action:@selector(goToMainMenuPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:1.f animations:^{
            self.blurMask.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        } completion:^(BOOL finished) {
            [self.view addSubview:label];
            [self.view addSubview:button3];
            [self.view addSubview:button2];
        }];
    } else if (self.gameModel.gameState == DurakGameStateDraw) {
        NSInteger gamesPlayed = [[NSUserDefaults standardUserDefaults] integerForKey:@"Games played"];
        [[NSUserDefaults standardUserDefaults] setInteger:gamesPlayed + 1 forKey:@"Games played"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Prompt Was Shown"] == NO && [[NSUserDefaults standardUserDefaults] integerForKey:@"Games played"] > 4) {
            [[iRate sharedInstance] promptForRating];
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 60,self.view.bounds.size.height/5, 120, 30)];
        label.text = NSLocalizedString(@"Draw", @"Draw message");
        label.font = [UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:30.f];
        label.textColor = [UIColor colorWithRed:40.f/256.f green:77./256.f blue:45.f/256.f alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 20;
        
        CoolButton *button2 = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 60, self.view.bounds.size.height/2 - 55, 120, 50)];
        [button2 setTitle:NSLocalizedString(@"Replay", @"Replay message") forState:UIControlStateNormal];
        [self makeButtonPreparationsWithButton:button2];
        [button2 addTarget:self action:@selector(changeDeckPressed) forControlEvents:UIControlEventTouchUpInside];
        
        CoolButton *button3 = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 100, self.view.bounds.size.height/2, 200, 50)];
        [button3 setTitle:NSLocalizedString(@"Main menu", @"Main menu message") forState:UIControlStateNormal];
        [self makeButtonPreparationsWithButton:button3];
        [button3 addTarget:self action:@selector(goToMainMenuPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:1.f animations:^{
            self.blurMask.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        } completion:^(BOOL finished) {
            [self.view addSubview:label];
            [self.view addSubview:button3];
            [self.view addSubview:button2];
            }];
    }
    
    
    [[iRate sharedInstance] promptIfAllCriteriaMet];
}

- (void)iRateDidPromptForRating {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Prompt Was Shown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)backToGameActionPressed {
    for (UIView *view in self.view.subviews) {
        if (view.tag == 20) {
            [view removeFromSuperview];
        }
    }
    [UIView animateWithDuration:1.f animations:^{
        self.blurMask.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 0);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)changeDeck {
    if (self.amount == DurakGameCardAmount36) {
        self.gameModel = [[DurakGameModel alloc] initWithBigDeck:NO];
    } else {
        self.gameModel = [[DurakGameModel alloc] initWithBigDeck:YES];
    }
    
    [self checkIfGameModelCorrect];
    
    self.gameModel.delegate = self;
    
    [self updateUI];
}

- (void)changeDeckPressed {
    for (UIView *view in self.view.subviews) {
        if (view.tag == 20) {
            [view removeFromSuperview];
        }
    }
    [UIView animateWithDuration:1.f animations:^{
        self.blurMask.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 0);
    } completion:^(BOOL finished) {
        [self changeDeck];
    }];
}

- (void)goToMainMenuPressed {
    [self performSegueWithIdentifier:@"unwindToSettings" sender:self];
}

- (void)makeButtonPreparationsWithButton:(CoolButton *)button {
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.tag = 20;
    button.hue = 28.f/360.f;
    button.saturation = 64.f/100.f;
    button.brightness = 96.f/100.f;
}

- (IBAction)changePressed:(id)sender {
    self.blurredBgImage.image = [self blurWithImageEffects:[self takeSnapshotOfView:self.view]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 60,self.view.bounds.size.height/5, 120, 30)];
    label.text = NSLocalizedString(@"Pause", @"Pause message");
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 20;
    
    CoolButton *button = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 90, self.view.bounds.size.height/2 - 80, 180, 50)];
    [button setTitle:NSLocalizedString(@"Continue ", @"Continue message") forState:UIControlStateNormal];
    [self makeButtonPreparationsWithButton:button];
    [button addTarget:self action:@selector(backToGameActionPressed) forControlEvents:UIControlEventTouchUpInside];
    
    CoolButton *button2 = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 70, self.view.bounds.size.height/2 - 25, 140, 50)];
    [button2 setTitle:NSLocalizedString(@"Deal ", @"Deal message") forState:UIControlStateNormal];
    [self makeButtonPreparationsWithButton:button2];
    [button2 addTarget:self action:@selector(changeDeckPressed) forControlEvents:UIControlEventTouchUpInside];
    
    CoolButton *button3 = [[CoolButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 80, self.view.bounds.size.height/2 + 35, 160, 50)];
    [button3 setTitle:NSLocalizedString(@"Main menu", @"Main menu message") forState:UIControlStateNormal];
    [self makeButtonPreparationsWithButton:button3];
    [button3 addTarget:self action:@selector(goToMainMenuPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view bringSubviewToFront:self.blurredBgImage];
    
    [UIView animateWithDuration:1.f animations:^{
        self.blurMask.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [self.view addSubview:label];
        [self.view addSubview:button];
        [self.view addSubview:button2];
        [self.view addSubview:button3];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark blur 

- (UIImage *)takeSnapshotOfView:(UIView *)view
{
    CGFloat reductionFactor = 1;
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)blurWithImageEffects:(UIImage *)image
{
    return [image applyBlurWithRadius:15 tintColor:[UIColor colorWithWhite:1 alpha:0.5] saturationDeltaFactor:1.5 maskImage:nil];
}

- (UIImage *)blurWithCoreImage:(UIImage *)sourceImage
{
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    // Apply Affine-Clamp filter to stretch the image so that it does not look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@30 forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, self.view.frame, cgImage);
    
    // Apply white tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
    CGContextFillRect(outputContext, self.view.frame);
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
