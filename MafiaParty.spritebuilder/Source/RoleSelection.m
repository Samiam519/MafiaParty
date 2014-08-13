//
//  RoleSelection.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RoleSelection.h"
#import "Player.h"
#import "Lobby.h"
#import "Gameplay.h"
#import "Results.h"

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
    int playersLeftToAssign;
    
    Player *chosenForDEATH;
}

-(void)didLoadFromCCB
{
    playersLeftToAssign = [Lobby sharedInstance].otherPlayers.count;
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
    
    _nextLabel.string = @"Waiting for Input";
    _nextButton.enabled = FALSE;
    
    for (int i = 0; i < [[Lobby sharedInstance].otherPlayers count]; i++)
    {
//        [_iconNode.children copy][i] = [Lobby sharedInstance].otherPlayers[i];
        Player *childSprite = _iconNode.children[i];
        Player *curPlayer = [Lobby sharedInstance].otherPlayers[i];
        childSprite.icon.spriteFrame = curPlayer.icon.spriteFrame;
        childSprite.FBname = curPlayer.FBname;
        childSprite.role = curPlayer.role;
    }
}

-(void)assignRolesToArray:(NSMutableArray *)players
{
    NSMutableArray *alreadyAssigned = [NSMutableArray array];
    int mafiaToAssign;
    if (players.count >= 11) {
        mafiaToAssign = 3;
    }
    else if (players.count >= 7) {
        mafiaToAssign = 2;
    }
    else {
        mafiaToAssign = 1;
    }
    int i = 0;
    while (i < mafiaToAssign)
    {
        int randNum = arc4random() % players.count;
        if ([alreadyAssigned containsObject:[NSNumber numberWithInt:randNum]])
        {
            continue;
        }
        Player *curPlayer = players[randNum];
        curPlayer.role = @"Mafia";
        [alreadyAssigned addObject:[NSNumber numberWithInt:randNum]];
        i++;
    }
    i = 0;
    while (i < 1)
    {
        int randNum = [self randomNumberUpTo:players.count];
        if ([alreadyAssigned containsObject:[NSNumber numberWithInt:randNum]])
        {
            continue;
        }
        Player *curPlayer = players[randNum];
        curPlayer.role = @"Doctor";
        [alreadyAssigned addObject:[NSNumber numberWithInt:randNum]];
        i++;
    }
    while (i < 1)
    {
        int randNum = [self randomNumberUpTo:players.count];
        if ([alreadyAssigned containsObject:[NSNumber numberWithInt:randNum]])
        {
            continue;
        }
        Player *curPlayer = players[randNum];
        curPlayer.role = @"Police";
        [alreadyAssigned addObject:[NSNumber numberWithInt:randNum]];
        i++;
    }
    
}

-(id)init
{
    self = [super init];
    if (self)
    {
        [self assignRolesToArray:[Lobby sharedInstance].otherPlayers];
    }
    return self;
}

-(int)randomNumberUpTo:(int)num
{
    return arc4random() % num;
}

- (void)mafiaChat
{
    // Chat with other mafia people
}

- (void)next
{
    // Load Results Scene
    Results *results = (Results *)[CCBReader load:@"Results"];
//    Results *page = results.children[0];
//    page.deadPlayer = chosenForDEATH;
    results.deadPlayer = chosenForDEATH;
    CCScene *empty = [CCScene alloc];
    [empty addChild:results];
    [[CCDirector sharedDirector] replaceScene:empty];
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
    _nextLabel.string = @"Waiting for Other Players";
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
    Player *myPlayer = [Lobby sharedInstance].otherPlayers[[Lobby sharedInstance].playerIndex.intValue];
    _roleLabel.string = myPlayer.role;
//    _roleLabel.string = ((Player *)_playerArray[[Lobby sharedInstance].playerIndex]).role;
    if ([myPlayer.role isEqualToString:@"Mafia"]){
        _RoleTaskLabel.string = @"Who do you want to kill?";
    }
    else if ([myPlayer.role isEqualToString:@"Doctor"]){
        _RoleTaskLabel.string = @"Who do you want to save?";
    }
    else if ([myPlayer.role isEqualToString:@"Police"]){
        _RoleTaskLabel.string = @"Who do you want to investigate?";
    }
    else if ([myPlayer.role isEqualToString:@"Citizen"]){
        _RoleTaskLabel.string = @"Silly citizen, you can't do anything";
        _RoleTaskLabel.fontSize = 25;
    }
    for (Player* curPlayer in _iconNode.children)
    {
        if (CGRectContainsPoint(curPlayer.boundingBox, touchLocation))
        {
            if (touchActivated)
            {
                CCLOG(@"You touched %@", curPlayer.FBname);
                [myPlayer performNightAction: curPlayer];
                if ([myPlayer.role isEqualToString:@"Mafia"])
                {
                    chosenForDEATH = curPlayer;
                }
                _nextLabel.string = @"Waiting for other players...";
            }
        }
    }
    
    for (Player *currentPlayer in [Lobby sharedInstance].otherPlayers)
    {
        if (currentPlayer.turnEnded)
        {
            return;
        }
    }
    _nextButton.enabled = true;
    _nextLabel.string = @"The next morning...";
    
}


- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    //On touch began
    touchActivated = true;
    touchLocation = [touch locationInWorld];
    CCLOG(@"TouchLocation = (%f, %f)", touchLocation.x, touchLocation.y);
    
}

-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    touchActivated = false;
    
}

//-(void)performNightAction
//{
//    if (role == @"citizen")
//    {
//        CCLOG(@"Choose a word!");
//    }
//
//    else if (role == "mafia")
//    {
//        CCLOG(@"Choose someone to kill!");
//    }
//
//    else if (role == "police")
//    {
//        CCLOG(@"Choose someone to investigate!");
//    }
//
//    else if (role == "doctor")
//    {
//        CCLOG(@"Choose someone to save!");
//    }
//    screenTouched = true;
//}

//<<<<<<< HEAD
//
//-(void)setDead
//{
//    self.isDead = true;
//}
//
//-(void)savePlayer
//{
//    self.isSaved = true;
//}
//=======

@end
