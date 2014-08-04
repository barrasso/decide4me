//
//  Green.m
//  Decide4Me
//
//  Created by Mark on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Green.h"

@implementation Green

- (void)goBack
{
    CCScene *goBackScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:goBackScene];
}

@end
