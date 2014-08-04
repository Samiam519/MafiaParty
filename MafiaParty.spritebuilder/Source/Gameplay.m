//
//  Gameplay.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Player.h"
#import "RoleSelection.h"

@implementation Gameplay
{
    // Loader
    CCNode *_loader;
    int playersLeftToAssign;
    RoleSelection* roleSelectionControl;
    CGPoint touchLocation;
    Player *myself;
    CCNode *_iconNode;
    Firebase *_myRootRef;
    NSMutableArray *_playerArray;
}

+(CCScene*)sendTheArray:(NSMutableArray*)theArray{
    CCScene *newScene = [CCScene node];
    [newScene addChild:[self gameplayWithArray:theArray]];
    return newScene;
}

+(id)gameplayWithArray:(NSMutableArray*)theArray{
    return [[self alloc]initWithAnArray:theArray];
}

-(id)initWithAnArray:(NSMutableArray*)theArray{
    if((self = (Gameplay*) [CCBReader load:@"Gameplay"]))
    {
        _playerArray = theArray;
        // Load Role Selection scene
        CCScene *game = [RoleSelection sendTheArray:_playerArray];
        [_loader addChild:game];
    }
    return self;
}

-(void) didLoadFromCCB {
    _playerArray = [NSMutableArray array];
    self.userInteractionEnabled = true;
    
//    // Load Role Selection scene
//    CCScene *game = [CCBReader loadAsScene:@"RoleSelection" owner:self];
//    [_loader addChild:game];
}

- (id)init
{
    // Initialize
    self = [super init];
    
    // If intialized,
    if (self)
        // Init other players array
        _playerArray = [NSMutableArray array];
    roleSelectionControl = [[RoleSelection alloc]init];
    return self;
}

//- (void)assignRoles:(NSMutableArray*)players
//{
//    playersLeftToAssign = (int)players.count;
//    if (players.count >= 11) {
//        [self selectPlayerRole:@"Mafia" withValue:3];
//        playersLeftToAssign-= 3;
//    }
//    else if (players.count >= 7) {
//        [self selectPlayerRole:@"Mafia" withValue:2];
//        playersLeftToAssign-= 2;
//    }
//    else if (players.count >= 4) {
//        [self selectPlayerRole:@"Mafia" withValue:1];
//        playersLeftToAssign-= 1;
//    }
//    [self selectPlayerRole:@"Doctor" withValue:1];
//    [self selectPlayerRole:@"Police" withValue:1];
//    playersLeftToAssign -= 2;
//    [self selectPlayerRole:@"Citizen" withValue:playersLeftToAssign];
//    
//}
//
//- (void)selectPlayerRole: (NSString*)role withValue:(int)repeatValue
//{
//    for (int i = 0; i < repeatValue; i++) {
//        int selected = arc4random() % _playerArray.count;
//        if (!((Player *)_playerArray[selected]).alreadyPicked) {
//            ((Player *)_playerArray[selected]).role = role;
//            ((Player *)_playerArray[selected]).alreadyPicked;
//        }else if (((Player *)_playerArray[selected]).alreadyPicked){
//            [self selectPlayerRole:role withValue:repeatValue];
//        }
//    }
//}

-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    touchLocation = [touch locationInWorld];
}

- (void)update:(CCTime)delta
{
//    for (CCSprite *icon in _iconNode.children)
//    {    // Load Role Selection scene
//        CCScene *game = [CCBReader loadAsScene:@"RoleSelection" owner:self];
//        [_loader addChild:game];
//        if (CGRectContainsPoint(icon.boundingBox, touchLocation))
//        {
//            [myself performNightAction:[_playerArray indexOfObject:icon]];
//        }
//    }
    
    for (Player* currentPlayer in _playerArray)
    {
        if (!currentPlayer.turnEnded) {
            return;
        }
    }
    roleSelectionControl.nextButton.enabled = TRUE;
    roleSelectionControl.nextLabel.string = @"The next morning";
    
}

@end
