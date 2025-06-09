//
//  urpc.h
//  PyApp
//
//  Created by RT-Thread on 2021/10/21.
//  Copyright © 2021 Ventura. All rights reserved.
//

#ifndef urpc_h
#define urpc_h

#include <stdio.h>
// #import "PwCocoaLumberjack.h"
#import "BridgeUtils.h"

int  py_urpc_init();
int py_urpc_startServer(const char* bundleId);
void py_urpc_connectServer(const char* bundleId);
int py_urpc_portingInput(const uint8_t * data,const int dataLen);
void py_urpc_setPortingCallback(int (*Callback)(const uint8_t *dataBytes,const int dataLen));

void _urpc_c_api_init();
#endif /* urpc_h */
