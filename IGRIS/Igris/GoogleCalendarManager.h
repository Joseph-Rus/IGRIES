#import <Foundation/Foundation.h>
#import "GTLRCalendar.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoogleCalendarManager : NSObject

@property (nonatomic, strong) GTLRCalendarService *service;

+ (instancetype)sharedManager;

// Sign In
- (void)signInWithCompletion:(void (^)(BOOL success, NSError * _Nullable error))completion;
- (void)signOut;

// Fetch Events
- (void)fetchEventsWithCompletion:(void (^)(NSArray<GTLRCalendar_Event *> * _Nullable events, NSError * _Nullable error))completion;

// Add Event
- (void)addEventWithSummary:(NSString *)summary
                description:(nullable NSString *)description
                 startDate:(NSDate *)startDate
                   endDate:(NSDate *)endDate
                completion:(void (^)(BOOL success, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
