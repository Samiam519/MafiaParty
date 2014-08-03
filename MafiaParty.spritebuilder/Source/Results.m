//
//  Results.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Results.h"

@implementation Results
{
    // Labels
    CCLabelTTF *_storyLabel;
    CCLabelTTF *nextLabel;
    
    // Ints
    int randomIndex;
    
    // Arrays
    NSArray *_eachLine;
    
    // Strings
    NSString *_path;
    NSString *_allContent;
}

-(void)didLoadFromCCB
{
    // Initialize arrays
    _eachLine = [[NSArray alloc] init];
    
    // Read in content from txt file
    _path = [[NSBundle mainBundle] pathForResource:@"stories" ofType:@"txt"];
    _allContent = [NSString stringWithContentsOfFile:_path encoding:NSUTF8StringEncoding error:NULL];
    _eachLine = [_allContent componentsSeparatedByString:@"\n"];
    
    // Load Stories and shit
    randomIndex = arc4random() % [_eachLine count];
    _storyLabel.string = _eachLine[randomIndex];
}

-(void)next{
    //if mafia caught -> play again goes to lobby
    CCScene *lobby = [CCBReader loadAsScene:@"Lobby"];
    [[CCDirector sharedDirector] replaceScene:lobby];
    //if mafia not caught -> role selection
    CCScene *roleScreen = [CCBReader loadAsScene:@"RoleSelection"];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

@end
