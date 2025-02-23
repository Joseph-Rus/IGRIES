#import "GoogleCalendarManager.h"
#import "GTLRCalendar.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import <GTMSessionFetcher/GTMSessionFetcher.h>

@implementation GoogleCalendarManager

+ (instancetype)sharedManager {
    static GoogleCalendarManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.service = [[GTLRCalendarService alloc] init];
    }
    return self;
}

// MARK: - Sign In with Google

- (void)signInWithCompletion:(void (^)(BOOL, NSError * _Nullable))completion {
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.clientID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CLIENT_ID"];

    [signIn signInWithPresentingViewController:[UIApplication sharedApplication].keyWindow.rootViewController
                                    completion:^(GIDGoogleUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            completion(NO, error);
            return;
        }

        self.service.authorizer = user.authentication.fetcherAuthorizer;
        completion(YES, nil);
    }];
}

- (void)signOut {
    [[GIDSignIn sharedInstance] signOut];
    self.service.authorizer = nil;
}

// MARK: - Fetch Events

- (void)fetchEventsWithCompletion:(void (^)(NSArray<GTLRCalendar_Event *> * _Nullable, NSError * _Nullable))completion {
    GTLRCalendarQuery_EventsList *query = [GTLRCalendarQuery_EventsList queryWithCalendarId:@"primary"];
    query.maxResults = 10;
    query.singleEvents = YES;
    query.orderBy = kGTLRCalendarOrderByStartTime;
    
    [self.service executeQuery:query completionHandler:^(GTLRServiceTicket *ticket, id object, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        GTLRCalendar_Events *events = (GTLRCalendar_Events *)object;
        completion(events.items, nil);
    }];
}

// MARK: - Add Event

- (void)addEventWithSummary:(NSString *)summary
                description:(NSString *)description
                 startDate:(NSDate *)startDate
                   endDate:(NSDate *)endDate
                completion:(void (^)(BOOL, NSError * _Nullable))completion {

    GTLRCalendar_Event *event = [[GTLRCalendar_Event alloc] init];
    event.summary = summary;
    event.descriptionProperty = description;

    GTLRCalendar_EventDateTime *startDateTime = [[GTLRCalendar_EventDateTime alloc] init];
    startDateTime.dateTime = [GTLRDateTime dateTimeWithDate:startDate];

    GTLRCalendar_EventDateTime *endDateTime = [[GTLRCalendar_EventDateTime alloc] init];
    endDateTime.dateTime = [GTLRDateTime dateTimeWithDate:endDate];

    event.start = startDateTime;
    event.end = endDateTime;

    GTLRCalendarQuery_EventsInsert *insertQuery = [GTLRCalendarQuery_EventsInsert queryWithObject:event
                                                                                        calendarId:@"primary"];
    
    [self.service executeQuery:insertQuery completionHandler:^(GTLRServiceTicket *ticket, id object, NSError *error) {
        if (error) {
            completion(NO, error);
            return;
        }
        completion(YES, nil);
    }];
}

@end
