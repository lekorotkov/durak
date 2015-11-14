//
//  DurakGameModel.m
//  Durak
//
//  Created by Александр Карцев on 11/12/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import "DurakGameModel.h"

@interface DurakGameModel ()

@property (nonatomic) BOOL mainCardUsed;

@end

@implementation DurakGameModel

- (instancetype)initWithBigDeck:(BOOL)yes {
    if (self = [super init]) {
        //int tmp = (arc4random() % 30)+1;
        //if(tmp % 5 == 0) _isComputerTurn = YES;
        _gameState = DurakGameStatePlaying;
        _deck = [[PlayingCardDeck alloc] initWithBigDeck:yes];
        _mainCard = (PlayingCard *)[_deck drawRandomCard];
        _computerParticipantCards = [[NSMutableArray alloc] init];
        _selfParticipantCards = [[NSMutableArray alloc] init];
        for (int i = 0; i < 6; i++) {
            [_computerParticipantCards addObject:[_deck drawRandomCard]];
            [_selfParticipantCards addObject:[_deck drawRandomCard]];
        }
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
            
            if (self.selfParticipantCards.count == 0) {
                self.gameState = DurakGameStateEndedWithUserWin;
            }
            
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
                    [expensiveOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                    cheapestOption = [expensiveOptions lastObject];
                }
                
                [self.turnCards addObject:cheapestOption];
                [self.delegate computerMakeTurnWithCard:cheapestOption];
                [self.computerParticipantCards removeObject:cheapestOption];
                if (self.computerParticipantCards.count == 0) {
                    self.gameState = DurakGameStateEndedWithComputerWin;
                }
            } else {
                [self.computerParticipantCards addObjectsFromArray:self.turnCards];
                self.isComputerTurn = NO;
                [self.delegate updateUI];
                if (self.computerParticipantCards.count == 0) {
                    self.gameState = DurakGameStateEndedWithComputerWin;
                } else if (self.selfParticipantCards.count == 0) {
                    self.gameState = DurakGameStateEndedWithUserWin;
                }
            }
            return YES;
        } else {
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
                    
                    if (self.selfParticipantCards.count == 0) {
                        self.gameState = DurakGameStateEndedWithUserWin;
                    }
                    
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
                            [expensiveOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                            cheapestOption = [expensiveOptions lastObject];
                        }
                        
                        
                        [self.turnCards addObject:cheapestOption];
                        [self.delegate computerMakeTurnWithCard:cheapestOption];
                        [self.computerParticipantCards removeObject:cheapestOption];
                        if (self.computerParticipantCards.count == 0) {
                            self.gameState = DurakGameStateEndedWithComputerWin;
                        }
                    } else {
                        [self.computerParticipantCards addObjectsFromArray:self.turnCards];
                        self.isComputerTurn = NO;
                        [self.delegate updateUI];
                        if (self.computerParticipantCards.count == 0) {
                            self.gameState = DurakGameStateEndedWithComputerWin;
                        } else if (self.selfParticipantCards.count == 0) {
                            self.gameState = DurakGameStateEndedWithUserWin;
                        }
                    }
                    return YES;
                }
            }
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
                    [expensiveOptions sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"rank" ascending:NO]]];
                    cheapestOption = [expensiveOptions lastObject];
                }
                
                if (cheapestOption) {
                    [self.turnCards addObject:cheapestOption];
                    [self.delegate computerMakeTurnWithCard:cheapestOption];
                    [self.computerParticipantCards removeObject:cheapestOption];
                    if (self.computerParticipantCards.count == 0) {
                        self.gameState = DurakGameStateEndedWithComputerWin;
                    }
                } else {
                    self.turnCards = nil;
                    self.isComputerTurn = NO;
                    [self.delegate updateUI];
                    if (self.computerParticipantCards.count == 0) {
                        self.gameState = DurakGameStateEndedWithComputerWin;
                    } else if (self.selfParticipantCards.count == 0) {
                        self.gameState = DurakGameStateEndedWithUserWin;
                    }
                }
                
                return YES;
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    }
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

- (void)setIsComputerTurn:(BOOL)isComputerTurn{
    _isComputerTurn = isComputerTurn;
    
    self.turnCards = nil;
    
    NSUInteger numberOfSelfParticipantCards = self.selfParticipantCards.count;
    
    if (self.selfParticipantCards.count < 6) {
        for (int i = 0; i < 6 - numberOfSelfParticipantCards; i++) {
            Card *cardToAdd = [self drawCardFromDeck];
            if (cardToAdd) {
                [self.selfParticipantCards addObject:cardToAdd];
            }
            
        }
    }
    
    NSUInteger numberOfComputerParticipantCards = self.computerParticipantCards.count;
    
    if (self.computerParticipantCards.count < 6) {
        for (int i = 0; i < 6 - numberOfComputerParticipantCards; i++) {
            Card *cardToAdd = [self drawCardFromDeck];
            if (cardToAdd) {
                [self.computerParticipantCards addObject:cardToAdd];
            }
        }
    }
}

- (void)pickUpPressed {
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
    
    self.turnCards = nil;
    self.isComputerTurn = YES;
    [self.delegate updateUI];
    
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
    [self.delegate computerMakeTurnWithCard:cheapestOption];
    [self.computerParticipantCards removeObject:cheapestOption];
    if (self.computerParticipantCards.count == 0) {
        self.gameState = DurakGameStateEndedWithComputerWin;
    }
}

- (void)setGameState:(DurakGameState)gameState {
    _gameState = gameState;
    if (DurakGameStateEndedWithUserWin == gameState || DurakGameStateEndedWithComputerWin == gameState) {
        [self.delegate gameStateChanged];
    }
}

- (void)retreatPressed {
    self.isComputerTurn = YES;
    [self.delegate updateUI];
    
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
    [self.delegate computerMakeTurnWithCard:cheapestOption];
    [self.computerParticipantCards removeObject:cheapestOption];
    
    if (self.computerParticipantCards.count == 0) {
        self.gameState = DurakGameStateEndedWithComputerWin;
    }
}

@end
