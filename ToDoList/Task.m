//
//  Task.m
//  ToDoList
//
//  Created by JETSMobileLabMini2 on 17/04/2024.
//

#import "Task.h"

@implementation Task

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
    [coder encodeObject:self.taskTitle forKey:@"title"];
    [coder encodeObject:self.taskDescription forKey:@"description"];
    [coder encodeObject:self.taskState forKey:@"state"];
    [coder encodeObject:self.taskPriority forKey:@"priority"];
    [coder encodeObject:self.taskDate forKey:@"date"];
}


- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    
    self = [super init];
    
    if(self)
    {
        self.taskTitle = [coder decodeObjectForKey:@"title"];
        self.taskDescription = [coder decodeObjectForKey:@"description"];
        self.taskState = [coder decodeObjectForKey:@"state"];
        self.taskPriority = [coder decodeObjectForKey:@"priority"];
        self.taskDate = [coder decodeObjectForKey:@"date"];
    }
    
    return self;
}

@end
