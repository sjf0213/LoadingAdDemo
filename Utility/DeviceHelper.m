//
//  DeviceHelper.m
//  FafaBang
//
//  Created by xiong qi on 15/12/14.
//  Copyright © 2015年 xiongqi. All rights reserved.
//

#import "DeviceHelper.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <ifaddrs.h>
#import <UIKit/UIDevice.h>
#import <AdSupport/AdSupport.h>

#define IFT_ETHER 0x6

@interface DeviceHelper ()

@property (nonatomic,strong)NSString * deviceModel;
@property (nonatomic,strong)NSString * systemVersion;
@property (nonatomic,strong)NSString * idfaStr;
@property (nonatomic,strong)NSString * appver;
@property (nonatomic,strong)NSString * macaddr;
@property (nonatomic,strong)NSString * cliendTypeID;
@property (nonatomic,strong)NSString * appID;// 梦工厂内部的appID
@property (nonatomic,assign)BOOL jailbreakflag;

@end

@implementation DeviceHelper

+ (DeviceHelper*)shareInstance{
    static DeviceHelper* b_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        b_instance = [[DeviceHelper alloc] init];
    });
    return b_instance;
}

- (id)init{
    self = [super init];
    if (self) {
        
        self.systemVersion = [[UIDevice currentDevice] systemVersion];
        self.deviceModel = [self getDeviceModelType];
        self.cliendTypeID = [NSString stringWithFormat:@"%zd", [self getCliendID]];
        self.idfaStr = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
        self.macaddr = [self getDeviceMACAddress:"en0"];
        self.jailbreakflag = [self isJailBreak];
        self.appver = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        self.appID = @"81";
    }
    return self;
}

-(int)getCliendID{
    int ClientTypeID = 0;
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)) {
        ClientTypeID = 21;
    } else{
        ClientTypeID = 22;
    }
    return ClientTypeID;
}

-(NSString*)getDeviceModelType
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];//kCFStringEncodingUTF8];
    free(machine);
    return platform;
}


- (BOOL)isJailBreak
{
    NSArray * array = @[@"/Applications/Cydia.app",@"/Library/MobileSubstrate/MobileSubstrate.dylib",@"/usr/sbin/sshd",@"/etc/apt"];
    
    for (NSInteger i=0; i < array.count; i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:array[i]]) {
            return YES;
        }
    }
    return NO;
}

-(NSString*)getDeviceMACAddress:(char*)ifName
{
    int  success;
    struct ifaddrs * addrs;
    struct ifaddrs * cursor;
    const struct sockaddr_dl * dlAddr;
    const unsigned char* base;
    int i;
    
    NSMutableString* tempAddress = [NSMutableString new];
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != 0)
        {
            if ( (cursor->ifa_addr->sa_family == AF_LINK)
                && (((const struct sockaddr_dl *) cursor->ifa_addr)->sdl_type == IFT_ETHER)
                && strcmp(ifName,  cursor->ifa_name)==0 )
            {
                dlAddr = (const struct sockaddr_dl *) cursor->ifa_addr;
                base = (const unsigned char*) &dlAddr->sdl_data[dlAddr->sdl_nlen];
                
                for (i = 0; i < dlAddr->sdl_alen; i++)
                {
                    if (i != 0)
                        [tempAddress appendString:@":"];
                    
                    [tempAddress appendFormat:@"%02X",base[i]];
                }
            }
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    NSString * temp =[tempAddress stringByReplacingOccurrencesOfString:@"%3A" withString:@":"];
    
    return temp;
}


@end
