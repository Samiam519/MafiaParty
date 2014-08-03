//
//  RoleSelection.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RoleSelection.h"
#import "Player.h"

@implementation RoleSelection
{
    // Array of roles
    NSArray *_rolesArray;
    
    // Player
    Player *player;
    
    // Labels
    CCLabelTTF *_jobDescription;
    CCLabelTTF *_roleDisplay;
    CCLabelTTF *_roleLabel;
    CCLabelTTF *_RoleTaskLabel;
    CCLabelTTF *_MafiaGangLabel;
    CCLabelTTF *_nextLabel;
    
    CCButton *_nextButton;
    
    
    // Text Fields
    CCTextField *_nounTextField;
    CCTextField *_verbTextField;
    CCTextField *_adjectiveTextField;
    
    // Gradient background
    CCNodeGradient *_backgroundGradient; //change color based on role
    
    CCNode *_iconNode;
    
    CGPoint touchLocation;
    bool touchActivated;
}

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = true;
    
    //init playerArray
    _playerArray = [NSMutableArray array];
    
    // Init player
    player = [[Player alloc] init];
    
    // Set player booleans
    player.isDead = false;
    player.isSaved = false;
    
    // Initialize Arrays
    _rolesArray = [[NSArray alloc] init];
    self.nounArray = [[NSMutableArray alloc] init];
    self.verbArray = [[NSMutableArray alloc] init];
    self.adjectiveArray = [[NSMutableArray alloc] init];
    
    // Set text field place holders ******* FIX THIS FUCKING BULLSHIT
    _nounTextField.textField.placeholder = @"test";
    
    _nextLabel.string = @"Waiting for other players";
    _nextButton.enabled = FALSE;
    
    

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
    if((self = (RoleSelection*) [CCBReader load:@"RoleSelection"])){
        _playerArray = theArray;
        for (int n = 0; n < _playerArray.count; n++)
        {
            Player *childSprite = _iconNode.children[n];
            Player *curPlayer = _playerArray[n];
            childSprite.icon.spriteFrame = curPlayer.icon.spriteFrame;
        }
        
    }
    return self;
}

- (void)mafiaChat
{
    // Chat with other mafia people
}

- (void)next
{
    // Load Results Scene
    CCScene *results = (CCScene *)[CCBReader loadAsScene:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
}

#pragma mark - Word Getters

- (void)getNoun
{
    // Add text to array
    [_nounArray addObject:_nounTextField.textField.text];
    
    // Send array to Firebase
    
}

- (void)getVerb
{
    // Add text to array
    [_verbArray addObject:_verbTextField.textField.text];
    
    // Send array to Firebase
    
}

- (void)getAdjective
{
    // Add text to array
    [_adjectiveArray addObject:_adjectiveTextField.textField.text];
    
    // Send array to Firebase
    
}

#pragma mark - Player methods

- (void)performNightAction: (Player*)selected
{
    [self getNoun];
    [self getAdjective];
    [self getVerb];
    
    // Perform player's night action
    if ([player.role isEqualToString:@"mafia"]) {
        [self setDead:selected];
    }
    else if ([player.role isEqualToString:@"doctor"])
    {
        [self savePlayer:selected];
    }
    else if ([player.role isEqualToString:@"police"])
    {
        [self suspectPlayer:selected];
    }
    else
    {
        [self beACitizen];
    }
}

- (void)setDead: (Player*)player
{
    // Kill player
    player.isDead = TRUE;
}

- (void)savePlayer: (Player*)player{
    // Save player
    player.isSaved = TRUE;
}

-(void)suspectPlayer: (Player *)player
{
    if ([player.role isEqualToString:@"mafia"])
    {
        CCLOG(@"%@ is mafia!", player.name);
    }
    else
    {
        CCLOG(@"%@ is not mafia!", player.name);
    }
}

-(void)beACitizen
{
    
}

- (void)update:(CCTime)delta
{
    for (Player* curPlayer in _iconNode.children)
    {
        if (CGRectContainsPoint(curPlayer.boundingBox, touchLocation))
        {
            if (touchActivated)
            {
                CCLOG(@"You touched %@", curPlayer.name);
            }
        }
    }
    
    for (Player *currentPlayer in _playerArray)
    {
        if (!currentPlayer.turnEnded)
        {
            return;
        }
    }
    _nextButton.enabled = true;
    _nextLabel.string = @"The next morning...";
}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // On touch began
    touchActivated = true;
    touchLocation = [touch locationInWorld];
    CCLOG(@"TouchLocation = (%f, %f)", touchLocation.x, touchLocation.y);
    
}

-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    touchActivated = false;

}



@end
