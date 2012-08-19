/**
 * Copyright 2011 Matthew M. Graf
 *
 * This file is part of UDJ.
 *
 * UDJ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * UDJ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with UDJ.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "UDJPlayer.h"

@implementation UDJPlayer

@synthesize playerID, name, hostId, latitude, longitude, hostUsername, hasPassword;

+ (UDJPlayer*) playerFromDictionary:(NSDictionary *)playerDict{
    UDJPlayer* player = [UDJPlayer new];
    player.name = [playerDict objectForKey:@"name"];
    player.playerID = [[playerDict objectForKey:@"id"] integerValue];
    player.hostId = [[playerDict objectForKey:@"owner_id"] integerValue];
    player.latitude = [[playerDict objectForKey:@"latitude"] doubleValue];
    player.longitude = [[playerDict objectForKey:@"longitude"] doubleValue];
    player.hostUsername = [playerDict objectForKey:@"owner_username"];
    player.hasPassword = [[playerDict objectForKey:@"has_password"] boolValue];
    return player;
}

// memory managed
@end
