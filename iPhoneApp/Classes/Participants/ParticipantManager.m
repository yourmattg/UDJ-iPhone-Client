/**
 * Copyright 2011 Matthew M. Graf
 *
 * This file is part of UDJ.
 *
 * UDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *r
 * UDJ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with UDJ.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "ParticipantManager.h"
#import "UDJUser.h"
#import "UDJPlayerData.h"
#import "UDJData.h"
#import "RKRequest+UDJRequest.h"

@implementation ParticipantManager

@synthesize playerID;
@synthesize globalData;
@synthesize participantArray;

-(id)init{
    if(self = [super init]){
        self.playerID = [UDJPlayerData sharedPlayerData].currentPlayer.playerID;
    }
    return self;
}

-(void)getPlayerParticipants{
    RKRequest* request = [RKRequest UDJRequestWithMethod: RKRequestMethodGET];

    NSString* urlString = [NSString stringWithFormat: @"%@/players/%@/users", [request.URL absoluteString], self.playerID, nil];
    request.URL = [NSURL URLWithString: urlString];
    request.delegate = globalData;
    
    [request send];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [participantArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UDJUser* user = (UDJUser*)[participantArray objectAtIndex: indexPath.row];
    [cell.textLabel setText: user.username];
    
    return cell;
}

- (void)request:(RKRequest *)request didReceiveResponse:(RKResponse *)response{
    
}


@end
