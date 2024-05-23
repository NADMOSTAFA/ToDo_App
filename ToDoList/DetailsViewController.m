//
//  DetailsViewController.m
//  ToDoList
//
//  Created by JETSMobileLabMini2 on 17/04/2024.
//

#import "DetailsViewController.h"
#import "Task.h"
#import "UserNotifications/UserNotifications.h"
@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *taskTitle;
@property (weak, nonatomic) IBOutlet UITextView *taskDescription;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskPriority;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskState;
@property (weak, nonatomic) IBOutlet UIDatePicker *taskDate;
@property (weak, nonatomic) IBOutlet UIImageView *taskImage;
@property (weak, nonatomic) IBOutlet UIButton *myBtn;



@property NSUserDefaults *userDefault;

//array
@property NSMutableArray *ToDoList;
@property NSMutableArray *progressList;
@property NSMutableArray *doneList;

//decode
@property NSData *decodeToDo ;
@property NSData *decodeProgress ;
@property NSData *decodeDone;


@property Task* task;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _taskDate.minimumDate = [NSDate date];
    _userDefault = [NSUserDefaults standardUserDefaults];
    _ToDoList   = [NSMutableArray new];
    _progressList = [NSMutableArray new];
    _doneList = [NSMutableArray new];
    _task = [Task new];
}

- (void)viewWillAppear:(BOOL)animated{
    printf("enter will appear in details\n");
    printf("process %d\n",_process);
    _decodeToDo = [_userDefault objectForKey:@"todoList"];
    _decodeProgress = [_userDefault objectForKey:@"progressList"];
    _decodeDone = [_userDefault objectForKey:@"doneList"];
    
    if(_decodeToDo != nil){
        _ToDoList = [NSKeyedUnarchiver unarchiveObjectWithData:_decodeToDo];
    }
    if(_decodeProgress != nil){
        _progressList = [NSKeyedUnarchiver unarchiveObjectWithData:_decodeProgress];
        
    }
    if(_decodeDone != nil){
        _doneList = [NSKeyedUnarchiver unarchiveObjectWithData:_decodeDone];
    }
    
    
    
    if(_process == 1){
        [self disableSegement];
    }else if (_process == 2){
        
        if(_source == 1){
            _task = [_ToDoList objectAtIndex:_objectIndex];
        }else if (_source == 2){
            [self disableSegement];
            _task = [_progressList objectAtIndex:_objectIndex];
        }
         [self setTaskToPresentInView];
    }else{
        _task = [_doneList objectAtIndex:_objectIndex];
        [self disableFields];
        [self setTaskToPresentInView];
    }

}

- (IBAction)btnDone:(id)sender {
    if(_source == 1){
        if([_taskTitle.text isEqualToString:@""] && [_taskDescription.text isEqualToString:@""] ){
            [self informationRequiredAlert];
        }else{
            if(_process == 1){
                printf("add\n");
                    [self setTaskToArchive];
                    [_ToDoList addObject:_task];
                //[self confirmAdd];
                
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.title = @"Reminder for You";
                content.body = _taskTitle.text;
                content.sound = [UNNotificationSound defaultSound];
                
                NSCalendar *calender = [NSCalendar currentCalendar];
                NSDateComponents *dateComponent = [calender components:(NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:_taskDate.date];
                
                UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger  triggerWithDateMatchingComponents:dateComponent repeats:NO];
                
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:_taskTitle.text content:content trigger:trigger];
                
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
                
                
            }else if(_process == 2){
                printf("edit\n");
                [self setTaskToArchive];
                [_ToDoList replaceObjectAtIndex:_objectIndex withObject:_task];
                [self changeTaskState];
                //[self confirmEdit];
            }
            NSData *toDoData = [NSKeyedArchiver archivedDataWithRootObject:_ToDoList];
            [_userDefault setObject:toDoData forKey:@"todoList"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (_source == 2){
        printf("enter from progress to edit \n");
       // [self confirmEdit];
        
        [self setTaskToArchive];
        [_progressList replaceObjectAtIndex:_objectIndex withObject:_task];
        [self changeTaskState];
        NSData *progressData = [NSKeyedArchiver archivedDataWithRootObject:_progressList];
        [_userDefault setObject:progressData forKey:@"progressList"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}



-(void) changeSegmentState:(int) source{
    
}

-(void) disableSegement{
    if(_source == 1){
        [_taskState setEnabled:NO forSegmentAtIndex:1];
        [_taskState setEnabled:NO forSegmentAtIndex:2];
    }else if (_source == 2){
        [_taskState setEnabled:NO forSegmentAtIndex:0];
    }else{
        [_taskState setEnabled:NO forSegmentAtIndex:2];
        [_taskState setEnabled:NO forSegmentAtIndex:0];
        [_taskState setEnabled:NO forSegmentAtIndex:1];
        [_taskPriority setEnabled:NO forSegmentAtIndex:0];
        [_taskPriority setEnabled:NO forSegmentAtIndex:1];
        [_taskPriority setEnabled:NO forSegmentAtIndex:2];
    }

}

-(void) setTaskToArchive{
    _task.taskTitle = _taskTitle.text;
    _task.taskDescription = _taskDescription.text;
    _task.taskPriority = [_taskPriority titleForSegmentAtIndex:_taskPriority.selectedSegmentIndex];
    _task.taskState = [_taskState titleForSegmentAtIndex:_taskState.selectedSegmentIndex];
    _task.taskDate = _taskDate.date;
}

-(void)  setTaskToPresentInView{
    _taskTitle.text = _task.taskTitle;
    _taskDescription.text = _task.taskDescription;
    for (int i = 0; i<3; i++) {
        NSString * state = [_taskState titleForSegmentAtIndex:i];
        NSString * proirity = [_taskPriority titleForSegmentAtIndex:i];
        if([state isEqualToString:_task.taskState]){
            _taskState.selectedSegmentIndex = i;
            
        }
        if([proirity isEqualToString:_task.taskPriority]){
            _taskPriority.selectedSegmentIndex = i;
            
        }
    }
    _taskDate.date = _task.taskDate;
    if([_task.taskPriority  isEqual: @"Low"]){
        _taskImage.image = [UIImage imageNamed:@"green"];
    }else if ([_task.taskPriority  isEqual: @"High"]){
        _taskImage.image = [UIImage imageNamed:@"red"];
    }else{
        _taskImage.image = [UIImage imageNamed:@"blue"];
    }
}

-(void) informationRequiredAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid!" message:@"All fields are required" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction  actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) confirmAdd{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation Required" message:@"Are you sure you want to add?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction  actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setTaskToArchive];
        [_ToDoList addObject:_task];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) confirmEdit{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirmation Required" message:@"Are you sure you want to Edit?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction  actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(_source == 1 && _process == 2){
            [self setTaskToArchive];
            [_ToDoList replaceObjectAtIndex:_objectIndex withObject:_task];
            [self changeTaskState];
            
        }else{
            [self setTaskToArchive];
            [_progressList replaceObjectAtIndex:_objectIndex withObject:_task];
            [self changeTaskState];
            NSData *progressData = [NSKeyedArchiver archivedDataWithRootObject:_progressList];
            [_userDefault setObject:progressData forKey:@"progressList"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) changeTaskState{
    printf("changeTaskState\n");
    NSString * state = [_taskState titleForSegmentAtIndex:_taskState.selectedSegmentIndex];
    if(_source == 1){
        if([state isEqual:@"inProgress"]){
            printf("inProgress\n");
            [_progressList addObject:_task];
            NSData *progressData = [NSKeyedArchiver archivedDataWithRootObject:_progressList];
            [_userDefault setObject:progressData forKey:@"progressList"];
            [_ToDoList removeObject:_task];
            
        }else if ([state isEqual:@"Done"]){
            printf("Done\n");
            [_doneList addObject:_task];
            NSData *doneData = [NSKeyedArchiver archivedDataWithRootObject:_doneList];
            [_userDefault setObject:doneData forKey:@"doneList"];
            [_ToDoList removeObject:_task];
        }
    }else{
        if ([state isEqual:@"Done"]){
            printf("Done\n");
            [_doneList addObject:_task];
            NSData *doneData = [NSKeyedArchiver archivedDataWithRootObject:_doneList];
            [_userDefault setObject:doneData forKey:@"doneList"];
            [_progressList removeObject:_task];
        }
    }
   
}

-(void) disableFields{
    _myBtn.hidden = YES;
    _taskTitle.enabled = NO;
    _taskDescription.editable =NO;
    _taskDate.enabled = NO;
    [self disableSegement];
}
@end
