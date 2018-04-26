//
//  ESPTouchTask.h
//  EspTouchDemo
//
//  Created by 白 桦 on 4/14/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPTouchResult.h"
#import "ESPTouchDelegate.h"
#import <UIKit/UIKit.h>

#define DEBUG_ON   YES

@interface ESPTouchTask : NSObject

@property (atomic,assign) BOOL isCancelled;

- (id) initWithApSsid: (NSString *)apSsid andApBssid: (NSString *) apBssid andApPwd: (NSString *)apPwd;

/**
 * Deprecated
 */
- (id) initWithApSsid: (NSString *)apSsid andApBssid: (NSString *) apBssid andApPwd: (NSString *)apPwd andIsSsidHiden: (BOOL) isSsidHidden __deprecated_msg("Use initWithApSsid:(NSString *) andApBssid:(NSString *) andApPwd:(NSString *) instead.");

- (id) initWithApSsid: (NSString *)apSsid andApBssid: (NSString *) apBssid andApPwd: (NSString *)apPwd andTimeoutMillisecond: (int) timeoutMillisecond;

- (id) initWithApSsid: (NSString *)apSsid andApBssid: (NSString *) apBssid andApPwd: (NSString *)apPwd andIsSsidHiden: (BOOL) isSsidHidden andTimeoutMillisecond: (int) timeoutMillisecond  __deprecated_msg("Use initWithApSsid:(NSString *) andApBssid:(NSString *) andApPwd:(NSString *) andTimeoutMillisecond:(int) instead.");

/**
 * Interrupt the Esptouch Task when User tap back or close the Application.
 */
- (void) interrupt;

/**
 * Note: !!!Don't call the task at UI Main Thread
 *
 * Smart Config v2.4 support the API
 *
 * @return the ESPTouchResult
 */
- (ESPTouchResult*) executeForResult;

/**
 * Note: !!!Don't call the task at UI Main Thread
 *
 * Smart Config v2.4 support the API
 *
 * It will be blocked until the client receive result count >= expectTaskResultCount.
 * If it fail, it will return one fail result will be returned in the list.
 * If it is cancelled while executing,
 *     if it has received some results, all of them will be returned in the list.
 *     if it hasn't received any results, one cancel result will be returned in the list.
 *
 * @param expectTaskResultCount
 *            the expect result count(if expectTaskResultCount <= 0,
 *            expectTaskResultCount = INT32_MAX)
 * @return the NSArray of EsptouchResult
 * @throws RuntimeException
 */
- (NSArray*) executeForResults:(int) expectTaskResultCount;

/**
 * set the esptouch delegate, when one device is connected to the Ap, it will be called back
 * @param esptouchDelegate when one device is connected to the Ap, it will be called back
 */
- (void) setEsptouchDelegate: (NSObject<ESPTouchDelegate> *) esptouchDelegate;

@end
