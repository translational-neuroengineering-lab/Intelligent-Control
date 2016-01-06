/*
 * mexmodelwrapper.cpp
 *
 *  Created on: Aug 23, 2015
 *      Author: mconnolly
 */

#include "mexmodelwrapper.h"
#include <mex.h>

void _main();

mex_model_wrapper::mex_model_wrapper() {
	// TODO Auto-generated constructor stub

}

mex_model_wrapper::~mex_model_wrapper() {
	// TODO Auto-generated destructor stub
}

void mex_model_wrapper::mex_in_silico_model(){

}

void mexFunction(
		 int          nlhs,
		 mxArray      *[],
		 int          nrhs,
		 const mxArray *prhs[]
		 )
{
  double      *vin1, *vin2;

  /* Check for proper number of arguments */

  if (nrhs != 2) {
    mexErrMsgIdAndTxt("MATLAB:mexcpp:nargin",
            "MEXCPP requires two input arguments.");
  } else if (nlhs >= 1) {
    mexErrMsgIdAndTxt("MATLAB:mexcpp:nargout",
            "MEXCPP requires no output argument.");
  }

  vin1 = (double *) mxGetPr(prhs[0]);
  vin2 = (double *) mxGetPr(prhs[1]);

  mexcpp(*vin1, *vin2);
  return;
}
