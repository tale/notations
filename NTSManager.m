#import "NTSManager.h"
#import "NTSNote.h"

@implementation NTSManager

UIView *emptyView;

+ (instancetype)sharedInstance {

    static NTSManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{

        instance = [NTSManager alloc];
        instance.notes = nil;
  });
  
  return instance;
}

- (id)init {

    return [NTSManager sharedInstance];
}

- (void)initView {

    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height + 50)];
    self.view.hidden = YES;
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
    [self.view setUserInteractionEnabled:YES];
}

- (void)addNote:(NTSNote *)note {

    [self.notes addObject:note];
    [self.view addSubview:note.view];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.notes] forKey:@"notations_notes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self addEmptyView];
}

- (void)removeNote:(NTSNote *)note {

    [self.notes removeObject:note];
    [note.view removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.notes] forKey:@"notations_notes"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self addEmptyView];
}

- (void)loadNotes {

    NSData *notesArrayData = [[NSUserDefaults standardUserDefaults] objectForKey:@"notations_notes"];
    if (notesArrayData != nil) {

        NSArray *savedNotesArray = [NSKeyedUnarchiver unarchiveObjectWithData:notesArrayData];
        if (savedNotesArray != nil) {

            self.notes = [[NSMutableArray alloc] initWithArray:savedNotesArray];
        }

        else {

            self.notes = [[NSMutableArray alloc] init];
        }
    }

    for (NTSNote *note in self.notes) {

        note.presented = NO;
    }
}

- (void)reloadNotes {

    for (NTSNote *note in self.notes) {

        [note.view removeFromSuperview];
        [note setupView];
        note.presented = NO;

        [self.view addSubview:note.view];
        note.presented = YES;
    }
}

- (void)updateNotes {

    for (NTSNote *note in self.notes) {

        [note setupView];
        [note.view removeFromSuperview];
        [self.view addSubview:note.view];
        note.presented = YES;
    }
}

- (void)addEmptyView {

    if (self.notes.count == 0) {

        NTSNote *note = [[NTSNote alloc] init];
        note.text = note.textView.text;
        note.x = [[UIScreen mainScreen] bounds].size.width / 2 - 100;
        note.y = [[UIScreen mainScreen] bounds].size.height / 2 - 100;
        note.width = 200;
        note.height = 200;
        note.draggable = YES;
        note.resizeable = YES;
        note.text = @"Long-Press to add more notes!\n\nYou can close this when you create your first note!";

        [self addNote:note];
        [self reloadNotes];
    }
}

@end