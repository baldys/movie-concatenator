//
//  Scene.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "Scene.h"
#import "Take.h"

@implementation Scene

-(instancetype)init {
    if (self = [super init]) {
        if (!self.takes)
        {
            self.takes = [NSMutableArray array];
        }
        self.title = @"scene";
        
        
        //Take *newScene = [[Take alloc] init];
        //[self.takes addObject:newScene];
    }
    return self;
}



// LOAD
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.takes = [[aDecoder decodeObjectForKey:@"takes"] mutableCopy];
        
    }
    return self;
}
// SAVE
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.takes forKey:@"takes"];
}


@end
