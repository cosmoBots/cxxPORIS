#ifndef _DEVICENAME_physical_CPP
#define _DEVICENAME_physical_CPP

// Add the specific cpp fragments for your device here (f.i. detector/actuator/... API)
// These fragments will be added at preprocessor time.
// You can choose better to add the specific code as a library using the _lmk.linux file
#include "DEVICENAME_physical.h"

using namespace std;

// In the DEVICENAME.l folder there is a pair of DEVICENAME_stub files (cpp and h)
// You should copy the stubs here below, and modify them to overwrite them with custom functionaliy added by you
// As the stubs are automatically generated from the model, you are advised to check
// them regularly.  
/*  This is an example:

int DEVICENAME_command(PORISNode *mynode, DEVICENAME *thisdevice)
{
	int ret = EXIT_FAILURE;
	cout << "Executing 'command' method with node " << mynode->name << endl;

	ret = EXIT_SUCCESS;
	return ret;
}
*/

#endif //_DEVICENAME_CPP