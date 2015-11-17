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

@interface ViewController () <DurakGameProtocol, ADBannerViewDelegate>

@property (nonatomic, strong) DurakGameModel *gameModel;

@property (nonatomic, strong) PlayingCardDeck *deck;
@property (nonatomic, strong) PlayingCard *mainCard;
@property (nonatomic, assign) BOOL isWidthSreenMore320;

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    
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
        [self changePressed:nil];
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
        [self changePressed:nil];
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
    
    /* PlayingCard *card = [[PlayingCard alloc] init];
    card.rank = [(PlayingCardView *)recognizer.view rank];
    card.suit = [(PlayingCardView *)recognizer.view suit];
    
    if ([self.gameModel userTurnWithCard:card]) {
        NSTimeInterval oddCardDelay = 0.f;
        NSTimeInterval evenCardDelay = 0.f;
        
        if (self.gameModel.isComputerTurn) {
            evenCardDelay = 0.5f;
        } else {
            oddCardDelay = 0.5f;
        }
        
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
            
            //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                playingCardView.faceUp = YES;
                [self.view bringSubviewToFront:playingCardView];
            //});
            
            playingCardView.tag = 12;
            
            switch (i) {
                case 0: {
                    [UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? -90 : -150;
                    float tempHeight = self.isWidthSreenMore320 ? -100 : -130;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 1: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? -70 : -130;
                    float tempHeight = self.isWidthSreenMore320 ? -80 : -110;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 2: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? 0 : -60;
                    float tempHeight = self.isWidthSreenMore320 ? -100 : -130;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 3: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? 20 : -40;
                    float tempHeight = self.isWidthSreenMore320 ? -80 : -110;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 4: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? 90 : 30;
                    float tempHeight = self.isWidthSreenMore320 ? -100 : -130;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 5: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? 110 : 50;
                    float tempHeight = self.isWidthSreenMore320 ? -80 : -110;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 +tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 6: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? -90 : -150;
                    float tempHeight = self.isWidthSreenMore320 ? 5 : -25;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 7: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? -70 : -130;
                    float tempHeight = self.isWidthSreenMore320 ? 25 : -5;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 +temp, self.view.bounds.size.height/2 + tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 8: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? 0 : -60;
                    float tempHeight = self.isWidthSreenMore320 ? 5 : -25;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2+temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 9: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? 20 : -40;
                    float tempHeight = self.isWidthSreenMore320 ? 25 : -5;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 + tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 10: {[UIView animateWithDuration:0.5f delay:evenCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? 90 : 30;
                    float tempHeight = self.isWidthSreenMore320 ? 5 : -25;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2+tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                case 11: {[UIView animateWithDuration:0.5f delay:oddCardDelay options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    float temp = self.isWidthSreenMore320 ? 110 : 50;
                    float tempHeight = self.isWidthSreenMore320 ? 25 : -5;
                    CGRect newFrame = CGRectMake(self.view.bounds.size.width/2 + temp, self.view.bounds.size.height/2 + tempHeight, 60, 80);
                    playingCardView.frame = newFrame;
                    for (UIGestureRecognizer *recognizer in playingCardView.gestureRecognizers) {
                        [playingCardView  removeGestureRecognizer:recognizer];
                    }
                } completion:nil];}
                    break;
                    
                default:
                    break;
            }
            
        }
    } else {
        [(PlayingCardView *)recognizer.view animateIncorrectChoose];
    }*/
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
                                                                            message: @"Not allowed action"
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
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
                                                                            message: @"Not allowed action"
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
                                                              style: UIAlertActionStyleDestructive
                                                            handler: nil];
        [controller addAction: alertAction];
        [self presentViewController: controller animated: YES completion: nil];
    }
    
}

- (void)gameStateChanged {
    if (self.gameModel.gameState == DurakGameStateEndedWithUserWin) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle: @"Congratulation"
                                                                            message: @"You win"
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
                                                              style: UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction * _Nonnull action) {
                                                                [self performSegueWithIdentifier:@"unwindToSettings" sender:nil];
                                                            }];
        [controller addAction: alertAction];
        [self presentViewController: controller animated: YES completion: nil];
    } else if (self.gameModel.gameState == DurakGameStateEndedWithComputerWin) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle: @"Loser"
                                                                            message: @"stupid motherfucker"
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
                                                              style: UIAlertActionStyleDestructive
                                                            handler: ^(UIAlertAction * _Nonnull action) {
                                                                [self performSegueWithIdentifier:@"unwindToSettings" sender:nil];
                                                            }];
        [controller addAction: alertAction];
        [self presentViewController: controller animated: YES completion: nil];
    } else if (self.gameModel.gameState == DurakGameStateDraw) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle: @"Draw"
                                                                            message: @"stupid motherfucker, even can't win the stupid computer"
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
                                                              style: UIAlertActionStyleDestructive
                                                            handler: ^(UIAlertAction * _Nonnull action) {
                                                                [self performSegueWithIdentifier:@"unwindToSettings" sender:nil];
                                                            }];
        [controller addAction: alertAction];
        [self presentViewController: controller animated: YES completion: nil];
    }
}

- (IBAction)changePressed:(id)sender {
    
    if (self.amount == DurakGameCardAmount36) {
        self.gameModel = [[DurakGameModel alloc] initWithBigDeck:NO];
    } else {
        self.gameModel = [[DurakGameModel alloc] initWithBigDeck:YES];
    }

    [self checkIfGameModelCorrect];
    
    self.gameModel.delegate = self;
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
