//
//  AppDelegate.m
//  FPSTester
//
//  Created by David Hodge on 6/29/16.
//  Copyright © 2016 David Hodge. All rights reserved.
//

#import "AppDelegate.h"

//#define TIMER_INTERVAL 0.005
#define TIMER_INTERVAL 1.0/60.0


//need to figure out how to plug into a dynamic format string. Had some toruble on first attempt
//#define DECIMAL_PLACES 3
//log stats every this number of updates
#define LOG_STATS 1000

#define LOG_DELAYS_GREATER_THAN 0.025

@interface AppDelegate ()

@property (nonatomic, weak) IBOutlet NSTextField *timingField;
@property (nonatomic, weak) IBOutlet NSTextField *longestDelayField;



@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSDate *startDate;

//This is the time interval since the last update, multiplied by 1000 and made into an int.
@property (nonatomic, assign) int lastValue;
@property (nonatomic, assign) NSTimeInterval longestDelay;

//For profiling
@property (nonatomic, assign) int use;
@property (nonatomic, assign) int skip;



@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    self.startDate = [NSDate date];
    [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                    target:self
                                   selector:@selector(timerFired)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)timerFired {
    NSDate * theDate = [NSDate date];
    double theTimeInterval = [theDate timeIntervalSinceDate:_startDate];
    int nextValue = theTimeInterval*1000;

    //If it's been long enough that there would be a visble change.
    if (nextValue != _lastValue) {
        
        NSString * presentTimeString = [NSString stringWithFormat:@"%.3lf",theTimeInterval];
        
        _timingField.stringValue = presentTimeString;
       
        
        double delay = (nextValue - _lastValue)/1000.0;
        if (delay > LOG_DELAYS_GREATER_THAN) {
            NSLog(@"There was a delay of %lf",delay);
        }
        
        if(delay > _longestDelay) {
            _longestDelay = delay;
            _longestDelayField.stringValue = [NSString stringWithFormat:@"Longest delay: %.4lf at %@",_longestDelay,presentTimeString];
        }
        
        _lastValue = nextValue; //log the timing of this cycle for future comparisons
        _use++; //log that we used this timer cycle.
        
    } else {
        _skip++; //log that we skipped this timer cycle
    }
    
    if (_use%LOG_STATS == 0) {
        NSLog(@"Use is %d skip is %d",_use, _skip);
    }

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    NSDate * theDate = [NSDate date];
    double theTimeInterval = [theDate timeIntervalSinceDate:_startDate];
    
    //This gets a little weird when we turn on layer-backed views because the "framerate" goes through the roof, but I think we're still capped at 60 in terms of effective framerate getting sent to the screen.
    NSLog(@"%d updates in %lf seconds. Assuming each update ends up hitting the screen, %lf FPS average. Or a frame every %lf seconds.",_use,theTimeInterval,_use/theTimeInterval,theTimeInterval/_use);
    // Insert code here to tear down your application
}

@end
