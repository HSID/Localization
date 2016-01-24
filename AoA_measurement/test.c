#include <stdio.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray *myStructure;
    int *size;
    *size = 1;
    const char *fields[] = {"this", "that"};

    myStructure = mxCreateStructArray(1, size, 2, fields);
    plhs[0] = myStructure;
}
