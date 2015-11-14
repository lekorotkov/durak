#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

- (void)addCard:(Card *)card atTop:(BOOL)atTop;


- (NSUInteger)lastCardsCount;

- (Card *)drawRandomCard;

@end
