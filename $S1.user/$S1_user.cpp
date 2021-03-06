#ifndef _DEVICENAME_user_CPP
#define _DEVICENAME_user_CPP

// Add the specific cpp fragments for your device here (f.i. detector/actuator/... API)
// These fragments will be added at preprocessor time.
// You can choose better to add the specific code as a library using the _lmk.linux file
#include "DEVICENAME_user.h"

using namespace std;

int DEVICENAME_command(PORISNode *mynode)
{
	int ret = EXIT_FAILURE;
	cout << "Executing 'command' method with node " << mynode->name << endl;

	ret = EXIT_SUCCESS;
	return ret;
}

#endif //_DEVICENAME_CPP