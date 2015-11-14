//
//  ViewController.h
//  Durak
//
//  Created by Александр Карцев on 11/12/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DurakGameCardAmount36,
    DurakGameCardAmount52,
} DurakGameCardAmount;

@interface ViewController : UIViewController

@property (nonatomic) DurakGameCardAmount amount;

@end

