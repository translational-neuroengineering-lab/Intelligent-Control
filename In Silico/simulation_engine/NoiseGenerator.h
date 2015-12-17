/*
 * NoiseGenerator.h
 *
 *  Created on: Aug 27, 2015
 *      Author: mconnolly
 */

#ifndef NOISEGENERATOR_H_
#define NOISEGENERATOR_H_

#include <cmath>
#include <stdlib.h>
#include <stdio.h>

class Noise_Generator {
	static double m;
	static double sigma;
	static double coeff_mult;

public:
	Noise_Generator();
	Noise_Generator(double m, double sigma, double coeff_mult);
	virtual ~Noise_Generator();

	void set_m(double m);
	void set_sigma(double sigma);
	void set_coeff_mult(double coeff_mult);

	double get_m();
	double get_sigma();
	double get_coeff_mult();

	static double gaussian();
};

#endif /* NOISEGENERATOR_H_ */
