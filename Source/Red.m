//
//  Red.m
//  Decide4Me
//
//  Created by Mark on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Red.h"

@implementation Red

- (void)goBack
{
    CCScene *goBackScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:goBackScene];
}

@end
