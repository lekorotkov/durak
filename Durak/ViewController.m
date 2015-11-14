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

@interface ViewController () <DurakGameProtocol>

@property (nonatomic, strong) DurakGameModel *gameModel;

@property (nonatomic, strong) PlayingCardDeck *deck;
@property (nonatomic, strong) PlayingCard *mainCard;
@property (nonatomic, assign) BOOL isWidthSreenMore320;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.amount == DurakGameCardAmount36) {
        self.gameModel = [[DurakGameModel alloc] initWithBigDeck:NO];
    } else {
        self.gameModel = [[DurakGameModel alloc] initWithBigDeck:YES];
    }
    
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

- (void)updateUI {
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[PlayingCardView class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (self.gameModel.deck.lastCardsCount > 0) {
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
    
    if (self.gameModel.deck.lastCardsCount > 1) {
        float temp = self.isWidthSreenMore320 ? self.view.bounds.size.height/2 -40 : self.view.bounds.size.height - 170;
        PlayingCardView *faceDownCardView = [[PlayingCardView alloc] initWithFrame:CGRectMake(0,temp, 60, 80)];
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
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                playingCardView.faceUp = YES;
                [self.view bringSubviewToFront:playingCardView];
            });
            
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
    }
}

- (void)faceUpCard:(PlayingCardView *)view {
    view.faceUp = YES;
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
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            playingCardView.faceUp = YES;
            [self.view bringSubviewToFront:playingCardView];
        });
        
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
                                                            handler: nil];
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
                                                            handler: nil];
        [controller addAction: alertAction];
        [self presentViewController: controller animated: YES completion: nil];
    } else if (self.gameModel.gameState == DurakGameStateEndedWithComputerWin) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle: @"Loser"
                                                                            message: @"stupid motherfucker"
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
                                                              style: UIAlertActionStyleDestructive
                                                            handler: nil];
        [controller addAction: alertAction];
        [self presentViewController: controller animated: YES completion: nil];
    } else if (self.gameModel.gameState == DurakGameStateDraw) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle: @"Draw"
                                                                            message: @"stupid motherfucker, even can't win the stupid computer"
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
                                                              style: UIAlertActionStyleDestructive
                                                            handler: nil];
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

    self.gameModel.delegate = self;
    
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
