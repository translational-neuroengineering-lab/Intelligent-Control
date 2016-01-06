/*
 * mexmodelwrapper.h
 *
 *  Created on: Aug 23, 2015
 *      Author: mconnolly
 */

#ifndef MEXMODELWRAPPER_H_
#define MEXMODELWRAPPER_H_

class mex_model_wrapper {

public:
	mex_model_wrapper();
	virtual ~mex_model_wrapper();
	void mex_in_silico_model();
};

#endif /* MEXMODELWRAPPER_H_ */
