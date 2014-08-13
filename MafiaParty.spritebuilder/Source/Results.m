//
//  Results.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Results.h"
#import "RoleSelection.h"
#import "Player.h"

@implementation Results
{
    // Labels
    CCLabelTTF *_storyLabel;
    CCLabelTTF *nextLabel;
    
    // Ints
    int randomIndex;
    int randomNoun;
    int randomVerb;
    int randomAdjective;
    
    // Arrays
    NSArray *_eachLine;
    NSArray *_nounsToRemove;
    NSArray *_verbsToRemove;
    NSArray *_adjectivesToRemove;
    
    // Strings
    NSString *_path;
    NSString *_allContent;
}

- (void)didLoadFromCCB
{
    
    
    
//    // Initialize arrays
//    _eachLine = [[NSArray alloc] init];
//    _nounsToRemove = [[NSArray alloc] init];
//    _verbsToRemove = [[NSArray alloc] init];
//    _adjectivesToRemove = [[NSArray alloc] init];
//    
//    // Shit to remove
//    
//    
//    // Create instance on Role Selection
//    RoleSelection *roleSelectionContent = [[RoleSelection alloc] init];
//    
//    // Read in content from txt file
//    _path = [[NSBundle mainBundle] pathForResource:@"stories" ofType:@"txt"];
//    _allContent = [NSString stringWithContentsOfFile:_path encoding:NSUTF8StringEncoding error:NULL];
//    _eachLine = [_allContent componentsSeparatedByString:@"\n"];
//    
//    // Load Stories and shit
//    randomIndex = arc4random() % [_eachLine count];
//    _storyLabel.string = _eachLine[randomIndex];
    
    // Find all nouns in the story and replace them
//    for(NSString *noun in _eachLine[randomIndex])
//    {
//        if ([noun isEqualToString:@"<noun>"])
//        {
//            // Replace it with a random noun
//            randomNoun = arc4random() % [roleSelectionContent.nounArray count];
//            //noun = roleSelectionContent.nounArray[randomNoun];
//        }
//    }    //    for(NSString *noun in _eachLine[randomIndex])
    //    {
    //        if ([noun isEqualToString:@"<noun>"])
    //        {
    //            // Replace it with a random noun
    //            randomNoun = arc4random() % [roleSelectionContent.nounArray count];
    //            //noun = roleSelectionContent.nounArray[randomNoun];
    //        }
    //    }
}

#pragma mark - Selectors

- (void)next
{
    // If mafia caught -> play again goes to lobby
    CCScene *lobby = [CCBReader loadAsScene:@"Lobby"];
    [[CCDirector sharedDirector] replaceScene:lobby];
    
    // If mafia not caught -> role selection
    CCScene *roleScreen = [CCBReader loadAsScene:@"RoleSelection"];
    [[CCDirector sharedDirector] replaceScene:roleScreen];
}

- (void)twitter
{
    
}

- (void)facebook
{
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params])
    {
        // Present the share dialog
        [FBDialogs presentShareDialogWithLink:params.link handler:^(FBAppCall *call, NSDictionary *results, NSError *error)
         {
             if(error)
             {
                 // An error occurred, we need to handle the error
                 // See: https://developers.facebook.com/docs/ios/errors
                 NSLog(@"Error publishing story: %@", error.description);
             }
             else
             {
                 // Success
                 NSLog(@"result %@", results);
             }
         }];
    }
    
    else
    {
        // Present the feed dialog
        
    }
}

-(void)update:(CCTime)delta
{
    NSString *story = [NSString stringWithFormat:@"%@ was found last night strangled with their own <noun>. The story went like this: the <noun> was <adjective> and <adjective>, so %@ decided to whip out the ol' <noun> and a picture of <noun> and get hammered. Unfortunately, as %@ began to <verb>, they noticed someone in the corner of their vision. The mafia knocked %@ out with a <noun>, and they got to work. %@ was discovered earlier this morning.", _deadPlayer.FBname, _deadPlayer.FBname, _deadPlayer.FBname, _deadPlayer.FBname, _deadPlayer.FBname];
    
    _storyLabel.string = story;
    
}

@end
