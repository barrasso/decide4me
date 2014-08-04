//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//
//
// MOTHER FUCKING Mark4Random();
//

#import "MainScene.h"

@implementation MainScene
{
    // Transistion Colors
    CCColor *redColor;
    CCColor *greenColor;
}

#pragma mark - Lifecycle

- (void)onEnter
{
    [super onEnter];
    
    // Enable touches
    self.userInteractionEnabled = YES;
    
    // Initialize colors
    redColor = [CCColor redColor];
    greenColor = [CCColor greenColor];
}

- (void)onExit
{
    // Deallocate Memory
    [super onExit];
}

#pragma mark - Selectors

- (void)deciderButton
{
    // Arc4MotherFuckingRandom Baby
    int randomChoice = arc4random() % 2; // GOD ALGORITHM
    // RNGESUS  // Mark4Random()
    
    // If NO,
    if (randomChoice == 0)
    {
        // Load RED Scene
        CCScene *redScene = [CCBReader loadAsScene:@"Red"];
        CCTransition *redTrans = [CCTransition transitionFadeWithColor:redColor duration:1];
        [[CCDirector sharedDirector] replaceScene:redScene withTransition:redTrans];
        
        // Load 'No' Sound
        [[OALSimpleAudio sharedInstance] playEffect:@"no.wav"];
    }
    // If YES,
    else if (randomChoice == 1)
    {
        // Load GREEN Scene
        CCScene *greenScene = [CCBReader loadAsScene:@"Green"];
        CCTransition *greenTrans = [CCTransition transitionFadeWithColor:greenColor duration:1];
        [[CCDirector sharedDirector] replaceScene:greenScene withTransition:greenTrans];
        
        // Load 'Yes' sound
        [[OALSimpleAudio sharedInstance] playEffect:@"yes.mp3"];
    }
}

@end
