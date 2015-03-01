//
//  MediaLibrary.m
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

#import "MediaLibrary.h"
#import "Scene.h"

@implementation MediaLibrary

-(instancetype)init {
    if (self = [super init]) {
        ///
        self.scenes = [NSMutableArray array];
        
        Scene *newScene = [[Scene alloc] init];
        [self.scenes addObject:newScene];
        ///
    }
    return self;
}

// LOAD
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.scenes = [[aDecoder decodeObjectForKey:@"scenes"] mutableCopy];
        
    }
    return self;
}

// SAVE
- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.scenes forKey:@"scenes"];
}

+ (instancetype)libraryWithFilename:(NSString*)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:filename];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:myPathDocs];
}


-(void)saveToFilename:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:filename];
    [NSKeyedArchiver archiveRootObject:self toFile:myPathDocs];
}

// // TODO: put into video model class so that for each video, you can retrieve the url path that 
//- (NSURL*) getPathURL
//{
//    // 4 - Get path
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
//    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
//    return url;
//}



@end
