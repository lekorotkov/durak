//
//  DurakGameModel.m
//  Durak
//
//  Created by Александр Карцев on 11/12/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import "DurakGameModel.h"

@interface DurakGameModel ()



@end

@implementation DurakGameModel

- (instancetype)initWithBigDeck:(BOOL)yes {
    if (self = [super init]) {
        _gameState = DurakGameStatePlaying;
        _deck = [[PlayingCardDeck alloc] initWithBigDeck:yes];
        _mainCard = (PlayingCard *)[_deck drawRandomCard];
        _computerParticipantCards = [[NSMutableArray alloc] init];
        _selfParticipantCards = [[NSMutableArray alloc] init];
        for (int i = 0; i < 6; i++) {
            [_computerParticipantCards addObject:[_deck drawRandomCard]];
            [_selfParticipantCards addObject:[_deck drawRandomCard]];
        }
        [self sortSelfParticipantCards];
    }
    return self;
}

- (NSMutableArray *)turnCards {
    if (!_turnCards) {
        _turnCards = [NSMutableArray new];
    }
    return _turnCards;
}

- (BOOL)userTurnWithCard:(PlayingCard *)card {
    if (self.animationIsInProgress) {
        return NO;
    } else {
        self.animationIsInProgress = YES;
    }
    [self.delegate changeButtonName];
    NSLog(@"%lu", (unsigned long)self.deck.lastCardsCount);
    if (!self.isComputerTurn) {
        if (self.turnCards.count == 0) {
            [self.turnCards addObject:card];
            
            PlayingCard *cardToRemove;
            for (PlayingCard *selfCard in self.selfParticipantCards) {
                if (selfCard.rank == card.rank && [selfCard.suit isEqualToString:card.suit]) {
                    cardToRemove = selfCard;
                }
            }
            [self.selfParticipantCards removeObject:cardToRemove];
            
            NSMutableArray *options = [[NSMutableArray alloc] init];
            for (PlayingCard *computerCard in self.computerParticipantCards) {
                if (computerCard.rank > card.rank && ([computerCard.suit isEqualToString:card.suit] || [computerCard.suit isEqualToString:self.mainCard.suit])) {
                    [options addObject:computerCard];
                } else {
                    if ([computerCard.suit isEqualToString:self.mainCard.suit] && ![card.suit isEqualToString:self.mainCard.suit]) {
                        [options addObject:computerCard];
                    }
                }
            }
            
            if (options.count > 0) {
                
                NSMutableArray *cheapOptions = [NSMutableArray new];
                NSMutableArray *expensiveOptions = [NSMutableArray new];
                
                for (PlayingCard *option in options) {
                    if ([option.suit isEqualToString:self.mainCard.suit]) {
                        [expensiveOptions addObject:option];
                    } else {
                        [cheapOptions addObject:option];
                    }
                }
                
                PlayingCard *cheapestOption;
                
                if (cheapOptions.count > 0) {
                    [cheapOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                    cheapestOption = [cheapOptions lastObject];
                } else {
                    if (self.deck.lastCardsCount == 0) {
                        [expensiveOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                        cheapestOption = [expensiveOptions lastObject];
                    }
                }
                
                if (cheapestOption) {
                    [self.turnCards addObject:cheapestOption];
                    [self.computerParticipantCards removeObject:cheapestOption];
                    [self.delegate makeTurnComputer:NO withCard:card completion:^{
                        [self.delegate makeTurnComputer:YES withCard:cheapestOption completion:^{
                            [self checkIfGameStateShouldChange];
                            self.animationIsInProgress = NO;
                        }];
                    }];
                } else {
                    [self.computerParticipantCards addObjectsFromArray:self.turnCards];
                    [self.delegate makeTurnComputer:NO withCard:card completion:^{
                        [self.delegate pickUpCardsComputer:YES withCards:self.turnCards completion:^{
                            [self.delegate sortComputerCardsWithCompletion:^{
                                if (![self checkIfGameStateShouldChange]) {
                                    self.isComputerTurn = NO;
                                }
                                self.animationIsInProgress = NO;
                            }];
                        }];
                    }];
                }
            } else {
                [self.computerParticipantCards addObjectsFromArray:self.turnCards];
                [self.delegate makeTurnComputer:NO withCard:card completion:^{
                    [self.delegate pickUpCardsComputer:YES withCards:self.turnCards completion:^{
                        [self.delegate sortComputerCardsWithCompletion:^{
                            if (![self checkIfGameStateShouldChange]) {
                                self.isComputerTurn = NO;
                            }
                            self.animationIsInProgress = NO;
                        }];
                    }];
                }];
            }
            return YES;
        } else {
            
            if (self.turnCards.count == 12) {
                [self retreatPressed];
                return NO;
            }
            
            for (PlayingCard *playingCard in self.turnCards) {
                if (playingCard.rank == card.rank) {
                    [self.turnCards addObject:card];
                    
                    PlayingCard *cardToRemove;
                    for (PlayingCard *selfCard in self.selfParticipantCards) {
                        if (selfCard.rank == card.rank && [selfCard.suit isEqualToString:card.suit]) {
                            cardToRemove = selfCard;
                        }
                    }
                    [self.selfParticipantCards removeObject:cardToRemove];
                    
                    NSMutableArray *options = [[NSMutableArray alloc] init];
                    for (PlayingCard *computerCard in self.computerParticipantCards) {
                        if (computerCard.rank > card.rank && ([computerCard.suit isEqualToString:card.suit] || [computerCard.suit isEqualToString:self.mainCard.suit])) {
                            [options addObject:computerCard];
                        } else {
                            if ([computerCard.suit isEqualToString:self.mainCard.suit] && ![card.suit isEqualToString:self.mainCard.suit]) {
                                [options addObject:computerCard];
                            }
                        }
                    }
                    
                    for (PlayingCard *card in options) {
                        NSLog(@"%@ %lu", card.suit, (unsigned long)card.rank);
                    }
                    
                    if (options.count > 0) {
                        NSMutableArray *cheapOptions = [NSMutableArray new];
                        NSMutableArray *expensiveOptions = [NSMutableArray new];
                        
                        for (PlayingCard *option in options) {
                            if ([option.suit isEqualToString:self.mainCard.suit]) {
                                [expensiveOptions addObject:option];
                            } else {
                                [cheapOptions addObject:option];
                            }
                        }
                        PlayingCard *cheapestOption;
                        if (cheapOptions.count > 0) {
                            [cheapOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                            cheapestOption = [cheapOptions lastObject];
                        } else {
                            if (self.deck.lastCardsCount == 0 || expensiveOptions.count > 1) {
                                [expensiveOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                                cheapestOption = [expensiveOptions lastObject];
                            }
                        }
                        
                        if (cheapestOption) {
                            [self.turnCards addObject:cheapestOption];
                            [self.delegate makeTurnComputer:NO withCard:card completion:^{
                                [self.computerParticipantCards removeObject:cheapestOption];
                                [self.delegate makeTurnComputer:YES withCard:cheapestOption completion:^{
                                    [self checkIfGameStateShouldChange];
                                    self.animationIsInProgress = NO;
                                }];
                            }];
                        } else {
                            [self.delegate makeTurnComputer:NO withCard:card completion:^{
                                [self.computerParticipantCards addObjectsFromArray:self.turnCards];
                                [self.delegate pickUpCardsComputer:YES withCards:self.turnCards completion:^{
                                    [self.delegate sortComputerCardsWithCompletion:^{
                                        if (![self checkIfGameStateShouldChange]) {
                                            self.isComputerTurn = NO;
                                        }
                                        self.animationIsInProgress = NO;
                                    }];
                                }];
                            }];
                        }
                    } else {
                        [self.delegate makeTurnComputer:NO withCard:card completion:^{
                            [self.computerParticipantCards addObjectsFromArray:self.turnCards];
                            [self.delegate pickUpCardsComputer:YES withCards:self.turnCards completion:^{
                                [self.delegate sortComputerCardsWithCompletion:^{
                                    if (![self checkIfGameStateShouldChange]) {
                                        self.isComputerTurn = NO;
                                    }
                                    self.animationIsInProgress = NO;
                                }];
                            }];
                        }];
                    }
                    return YES;
                }
            }
            self.animationIsInProgress = NO;
            return NO;
        }
    } else {
        if ([card.suit isEqualToString:[self.turnCards.lastObject suit]]||[card.suit isEqualToString:self.mainCard.suit]) {
            if (card.rank > [self.turnCards.lastObject rank]||(![self.mainCard.suit isEqualToString:[self.turnCards.lastObject suit]]&&[self.mainCard.suit isEqualToString:card.suit])) {
                
                [self.turnCards addObject:card];
                
                PlayingCard *cardToRemove;
                for (PlayingCard *playingCard in self.selfParticipantCards) {
                    if (playingCard.rank == card.rank && [playingCard.suit isEqualToString:card.suit]) {
                        cardToRemove = playingCard;
                    }
                }
                [self.selfParticipantCards removeObject:cardToRemove];
                
                if ([self checkIfGameStateShouldChange]) {
                    return NO;
                }
                
                NSMutableArray *availableOptions = [NSMutableArray new];
                
                for (PlayingCard *card in self.computerParticipantCards) {
                    BOOL shouldAddToOptions = NO;
                    for (PlayingCard *turnCard in self.turnCards) {
                        if (turnCard.rank == card.rank) {
                            shouldAddToOptions = YES;
                        }
                    }
                    if (shouldAddToOptions) {
                        [availableOptions addObject:card];
                    }
                }
                
                NSMutableArray *cheapOptions = [NSMutableArray new];
                NSMutableArray *expensiveOptions = [NSMutableArray new];
                
                for (PlayingCard *option in availableOptions) {
                    if ([option.suit isEqualToString:self.mainCard.suit]) {
                        [expensiveOptions addObject:option];
                    } else {
                        [cheapOptions addObject:option];
                    }
                }
                
                PlayingCard *cheapestOption;
                
                if (cheapOptions.count > 0) {
                    [cheapOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                    cheapestOption = [cheapOptions lastObject];
                } else {
                    if (self.deck.lastCardsCount == 0) {
                        [expensiveOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                        cheapestOption = [expensiveOptions lastObject];
                    }
                }
                
                if (cheapestOption && self.turnCards.count < 12) {
                    [self.turnCards addObject:cheapestOption];
                    [self.computerParticipantCards removeObject:cheapestOption];
                    [self.delegate makeTurnComputer:NO withCard:card completion:^{
                        [self.delegate makeTurnComputer:YES withCard:cheapestOption completion:^{
                            self.animationIsInProgress = NO;
                        }];
                    }];
                } else {
                    __block NSUInteger numberOfAnimatedCards = 0;
                    
                    [self.delegate makeTurnComputer:NO withCard:card completion:^{
                        for (PlayingCard *card in self.turnCards) {
                            [self.delegate moveCardToClear:card completion:^{
                                numberOfAnimatedCards++;
                                if (numberOfAnimatedCards == self.turnCards.count) {
                                    self.isComputerTurn = NO;
                                }
                                self.animationIsInProgress = NO;
                            }];
                        }
                    }];
                }
                
                return YES;
            } else {
                self.animationIsInProgress = NO;
                return NO;
            }
        } else {
            self.animationIsInProgress = NO;
            return NO;
        }
    }
}

- (BOOL)checkIfGameStateShouldChange {
    if (self.deck.lastCardsCount > 0 || !self.mainCardUsed) {
        return NO;
    }
    
    if (self.selfParticipantCards.count == 0 && self.computerParticipantCards.count == 0) {
        self.gameState = DurakGameStateDraw;
        return YES;
    }
    
    if (self.selfParticipantCards.count == 0 && self.computerParticipantCards.count > 0) {
        self.gameState = DurakGameStateEndedWithUserWin;
        return YES;
    }
    
    if (self.selfParticipantCards.count > 0 && self.computerParticipantCards.count == 0) {
        self.gameState = DurakGameStateEndedWithComputerWin;
        return YES;
    }
    return NO;
}

- (Card *)drawCardFromDeck {
    Card *card = [self.deck drawRandomCard];
    if (card) {
        return card;
    }
    if (!self.mainCardUsed) {
        self.mainCardUsed = YES;
        return self.mainCard;
    } else {
        return nil;
    }
}

- (void)sortSelfParticipantCards {
    NSMutableArray *cheapCards = [NSMutableArray new];
    NSMutableArray *expensiveCards = [NSMutableArray new];
    
    for (PlayingCard *card in self.selfParticipantCards) {
        if ([card.suit isEqualToString:self.mainCard.suit]) {
            [expensiveCards addObject:card];
        } else {
            [cheapCards addObject:card];
        }
    }
    
    [cheapCards sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES]]];
    [expensiveCards sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:YES]]];
    
    self.selfParticipantCards = [[cheapCards arrayByAddingObjectsFromArray:expensiveCards] mutableCopy];
}

- (void)takeComputerNeededCardsWithCompletion:(CompletionBlock)completion {
    NSUInteger numberOfComputerParticipantCards = self.computerParticipantCards.count;
    
    __block NSUInteger numberOfCompletedAnimations = 0;
    
    if (self.computerParticipantCards.count < 6) {
        for (int i = 0; i < 6 - numberOfComputerParticipantCards; i++) {
            Card *cardToAdd = [self drawCardFromDeck];
            if (!cardToAdd) {
                if (!self.mainCardUsed) {
                    cardToAdd = self.mainCard;
                    self.mainCardUsed = YES;
                }
            }
            
            if (cardToAdd) {
                [self.computerParticipantCards addObject:cardToAdd];
                [self.delegate takeCardFromDeckToComputer:YES withPlayingCard:(PlayingCard *)cardToAdd completion:^{
                    numberOfCompletedAnimations++;
                    if (numberOfCompletedAnimations == 6 - numberOfComputerParticipantCards) {
                        [self.delegate sortComputerCardsWithCompletion:^{
                            completion();
                        }];
                    }
                }];
            } else {
                numberOfCompletedAnimations++;
                if (numberOfCompletedAnimations == 6 - numberOfComputerParticipantCards) {
                    [self.delegate sortComputerCardsWithCompletion:^{
                        completion();
                    }];
                }
            }
        }
    } else {
        [self.delegate sortComputerCardsWithCompletion:^{
            completion();
        }];
    }
}

- (void)takeUserNeededCardsWithCompletion:(CompletionBlock)completion {
    NSUInteger numberOfSelfParticipantCards = self.selfParticipantCards.count;
    
    __block NSUInteger numberOfCompletedAnimations = 0;
    
    if (self.selfParticipantCards.count < 6) {
        for (int i = 0; i < 6 - numberOfSelfParticipantCards; i++) {
            Card *cardToAdd = [self drawCardFromDeck];
            
            if (!cardToAdd) {
                if (!self.mainCardUsed) {
                    cardToAdd = self.mainCard;
                    self.mainCardUsed = YES;
                }
            }
            
            if (cardToAdd) {
                [self.selfParticipantCards addObject:cardToAdd];
                [self.delegate takeCardFromDeckToComputer:NO withPlayingCard:(PlayingCard *)cardToAdd completion:^{
                    numberOfCompletedAnimations++;
                    if (numberOfCompletedAnimations == 6 - numberOfSelfParticipantCards) {
                        [self.delegate sortUserCardsWithCompletion:^{
                            completion();
                        }];
                    }
                }];
            } else {
                numberOfCompletedAnimations++;
                if (numberOfCompletedAnimations == 6 - numberOfSelfParticipantCards) {
                    [self.delegate sortUserCardsWithCompletion:^{
                        completion();
                    }];
                }
            }
        }
        [self sortSelfParticipantCards];
    } else {
        [self sortSelfParticipantCards];
        [self.delegate sortUserCardsWithCompletion:^{
            completion();
        }];
    }
}

- (void)setIsComputerTurn:(BOOL)isComputerTurn{
    self.turnCards = nil;
    //[self.delegate removeTurnCards];
    
    
    if (_isComputerTurn) {
        [self takeComputerNeededCardsWithCompletion:^{
            [self takeUserNeededCardsWithCompletion:^{ }];
        }];
        
    } else {
        [self takeUserNeededCardsWithCompletion:^{
            [self takeComputerNeededCardsWithCompletion:^{ }];
        }];
        
    }
    
    _isComputerTurn = isComputerTurn;
    [self.delegate changeButtonName];
}

- (void)pickUpPressed {
    self.animationIsInProgress = YES;
    
    [self.delegate disableButton];
    for (PlayingCard *card in self.turnCards) {
        BOOL shouldAddToSelfParticipantCards = YES;
        for (PlayingCard *selfCard in self.selfParticipantCards) {
            if (selfCard.rank == card.rank && [selfCard.suit isEqualToString:card.suit]) {
                shouldAddToSelfParticipantCards = NO;
            }
        }
        if (shouldAddToSelfParticipantCards) {
            [self.selfParticipantCards addObject:card];
        }
    }
    
    
    [self.delegate pickUpCardsComputer:NO withCards:self.turnCards completion:^{
        [self sortSelfParticipantCards];
            [self.delegate sortUserCardsWithCompletion:^{
                if ([self checkIfGameStateShouldChange]) {
                    self.animationIsInProgress = NO;
                    return;
                }
                    [self takeComputerNeededCardsWithCompletion:^{
                        
                        self.turnCards = nil;
                        
                        if (self.computerParticipantCards.count == 0) {
                            self.animationIsInProgress = NO;
                            return;
                        }
                        
                        NSMutableArray *cheapOptions = [NSMutableArray new];
                        NSMutableArray *expensiveOptions = [NSMutableArray new];
                        
                        for (PlayingCard *option in self.computerParticipantCards) {
                            if ([option.suit isEqualToString:self.mainCard.suit]) {
                                [expensiveOptions addObject:option];
                            } else {
                                [cheapOptions addObject:option];
                            }
                        }
                        
                        PlayingCard *cheapestOption;
                        
                        if (cheapOptions.count > 0) {
                            [cheapOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                            cheapestOption = [cheapOptions lastObject];
                        } else {
                            [expensiveOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                            cheapestOption = [expensiveOptions lastObject];
                        }
                        
                        [self.turnCards addObject:cheapestOption];
                        [self.computerParticipantCards removeObject:cheapestOption];
                        [self.delegate makeTurnComputer:YES withCard:cheapestOption completion:^{
                            [self.delegate changeButtonName];
                            self.animationIsInProgress = NO;
                            if (self.computerParticipantCards.count == 0) {
                                self.gameState = DurakGameStateEndedWithComputerWin;
                            }
                        }];
                    }];
            }];
        }];
}

- (void)setGameState:(DurakGameState)gameState {
    _gameState = gameState;
    if (DurakGameStateEndedWithUserWin == gameState || DurakGameStateEndedWithComputerWin == gameState || gameState == DurakGameStateDraw) {
        [self.delegate gameStateChanged];
    }
}

- (void)retreatPressed {
    
    self.animationIsInProgress = YES;
    //[self.delegate removeTurnCards];
    [self.delegate disableButton];
    __block int numberOfCompletedClearCards = 0;
    
    for (PlayingCard *card in self.turnCards) {
        [self.delegate moveCardToClear:card completion:^{
            numberOfCompletedClearCards++;
            if (numberOfCompletedClearCards == self.turnCards.count) {
                [self takeUserNeededCardsWithCompletion:^{
                    [self takeComputerNeededCardsWithCompletion:^{
                        _isComputerTurn = YES;
                        
                        self.animationIsInProgress = NO;
                        
                        [self.delegate changeButtonName];
                        self.turnCards = [NSMutableArray new];
                        
                        if (self.computerParticipantCards.count == 0) {
                            self.gameState = DurakGameStateEndedWithComputerWin;
                        } else if (self.selfParticipantCards.count == 0) {
                            self.gameState = DurakGameStateEndedWithUserWin;
                        }
                        
                        NSMutableArray *cheapOptions = [NSMutableArray new];
                        NSMutableArray *expensiveOptions = [NSMutableArray new];
                        
                        for (PlayingCard *option in self.computerParticipantCards) {
                            if ([option.suit isEqualToString:self.mainCard.suit]) {
                                [expensiveOptions addObject:option];
                            } else {
                                [cheapOptions addObject:option];
                            }
                        }
                        
                        PlayingCard *cheapestOption;
                        
                        if (cheapOptions.count > 0) {
                            [cheapOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                            cheapestOption = [cheapOptions lastObject];
                        } else {
                            [expensiveOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                            cheapestOption = [expensiveOptions lastObject];
                        }
                        
                        [self.turnCards addObject:cheapestOption];
                        [self.computerParticipantCards removeObject:cheapestOption];
                        
                        [self.delegate makeTurnComputer:YES withCard:cheapestOption completion:^{
                            self.animationIsInProgress = NO;
                            if (self.computerParticipantCards.count == 0) {
                                self.gameState = DurakGameStateEndedWithComputerWin;
                            }
                        }];
                    }];
                }];
            }
        }];
    }
}

@end
