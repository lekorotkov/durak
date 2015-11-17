//
//  DurakGameModel.h
//  Durak
//
//  Created by Александр Карцев on 11/12/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayingCardDeck.h"
#import "PlayingCard.h"

typedef enum {
    DurakGameStatePlaying,
    DurakGameStateEndedWithComputerWin,
    DurakGameStateEndedWithUserWin,
    DurakGameStateDraw
} DurakGameState;

typedef void (^CompletionBlock)();

@protocol DurakGameProtocol <NSObject>

- (void)computerMakeTurnWithCard:(PlayingCard *)card;
- (void)updateUI;
- (void)gameStateChanged;
- (void)removeTurnCards;

- (void)takeCardFromDeckToComputer:(BOOL)yes
                   withPlayingCard:(PlayingCard *)card
                        completion:(CompletionBlock)completionBlock;

- (void)sortUserCardsWithCompletion:(CompletionBlock)completionBlock;

- (void)sortComputerCardsWithCompletion:(CompletionBlock)completionBlock;

- (void)makeTurnComputer:(BOOL)yes
                withCard:(PlayingCard *)card
              completion:(CompletionBlock)block;

- (void)moveCardToClear:(PlayingCard *)card
             completion:(CompletionBlock)block;

- (void)pickUpCardsComputer:(BOOL)yes
                  withCards:(NSArray *)cards
                 completion:(CompletionBlock)completion;

@end

@interface DurakGameModel : NSObject

@property (nonatomic, weak) id<DurakGameProtocol> delegate;
@property (nonatomic, strong) NSMutableArray *turnCards;
@property (nonatomic) DurakGameState gameState;

@property (nonatomic, strong) PlayingCardDeck *deck;
@property (nonatomic, strong) NSMutableArray *computerParticipantCards;
@property (nonatomic, strong) NSMutableArray *selfParticipantCards;
@property (nonatomic) BOOL isComputerTurn;
@property (nonatomic, strong) PlayingCard *mainCard;

- (BOOL)userTurnWithCard:(PlayingCard *)card;
- (void)retreatPressed;
- (void)pickUpPressed;

- (instancetype)initWithBigDeck:(BOOL)yes;

@end
