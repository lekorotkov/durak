#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@implementation PlayingCardDeck

- (instancetype)initWithBigDeck:(BOOL)yes {
    self = [super init];
    
    if (self) {
        for (NSString *suit in [PlayingCard validSuits]) {
            if (yes) {
                for (NSUInteger rank = 1; rank <= [PlayingCard maxRank]; rank++) {
                    PlayingCard *card = [[PlayingCard alloc] init];
                    card.rank = rank;
                    card.suit = suit;
                    [self addCard:card atTop:YES];
                }
            } else {
                for (NSUInteger rank = 5; rank <= [PlayingCard maxRank]; rank++) {
                    PlayingCard *card = [[PlayingCard alloc] init];
                    card.rank = rank;
                    card.suit = suit;
                    [self addCard:card atTop:YES];
                }
            }
        }
    }
    
    return self;
}

@end
