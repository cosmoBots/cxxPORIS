#ifndef _DEVICENAME_physical_H
#define _DEVICENAME_physical_H

#include <PORIS.h>

/****** PORIS features deactivation overrides *********/
/** This is needed for monitoring magnitudes which shall have no modes, and shall 
 * be written without taking care of its current working mode 
 
Examples:
#define DEVICENAME_PORIS_DISABLE_setDEVICENAMEMode

Check for these defines at DEVICENAME.l/DEVICENAME.cpp there must be one per each mode or parameter
in the device (one per monitor)

 */

// In the DEVICENAME.l folder there is a pair of DEVICENAME_stub files (cpp and h)
// You should copy the stubs here below, and modify them to overwrite them with custom functionaliy added by you
// As the stubs are automatically generated from the model, you are advised to check
// them regularly.
// The #define clause DEVICENAME_functionname_DEFINED deactivates the stubs
/*  This is an example:

#define DEVICENAME_command_DEFINED
int DEVICENAME_command(PORISNode *mynode, DEVICENAME *thisdevice);
*/



#endif //_DEVICENAME_physical_H
