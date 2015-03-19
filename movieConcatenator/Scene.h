//
//  Scene.h
//  movieConcatenator
//
//  Created by Veronica Baldys on 2015-02-25.
//  Copyright (c) 2015 Veronica Baldys. All rights reserved.
//

// A scene has 

#import <Foundation/Foundation.h>

@interface Scene : NSObject <NSCoding>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *takes;
@property NSInteger takeNumber;

- (instancetype) init;
- (instancetype) initWithTitle:(NSString*)title;


@end
