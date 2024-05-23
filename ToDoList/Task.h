//
//  Task.h
//  ToDoList
//
//  Created by JETSMobileLabMini2 on 17/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Task : NSObject<NSCoding>
@property NSMutableString* taskTitle;
@property NSMutableString* taskDescription;
@property NSMutableString* taskState;
@property NSMutableString* taskPriority;
@property NSMutableString* taskDate;
@end

NS_ASSUME_NONNULL_END
