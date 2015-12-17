/*
 * NoiseGenerator.cpp
 *
 *  Created on: Aug 27, 2015
 *      Author: mconnolly
 */

#include "NoiseGenerator.h"

double Noise_Generator::m 			= 3;
double Noise_Generator::sigma		= 1;
double Noise_Generator::coeff_mult 	= 10;

Noise_Generator::Noise_Generator() {
	// TODO Auto-generated constructor stub

}

Noise_Generator::~Noise_Generator() {
	// TODO Auto-generated destructor stub
}

void Noise_Generator::set_m(double m){
	this->m = m;
}

void Noise_Generator::set_sigma(double sigma){
	this->sigma = sigma;
}

void Noise_Generator::set_coeff_mult(double coeff_mult){
	Noise_Generator::coeff_mult = coeff_mult;
}

double Noise_Generator::get_m(){
	return this->m;
}

double Noise_Generator::get_sigma(){
	return this->sigma;
}

double Noise_Generator::get_coeff_mult(){
	return this->coeff_mult;
}

double Noise_Generator::gaussian(){
    double gauss;
    double rand1;
    double rand2;
    double pi = 3.141592653589793238462643383;

    rand1 = (float)rand()/(float)(RAND_MAX);
    rand2 = (float)rand()/(float)(RAND_MAX);
    gauss = sigma * sqrt(-2.0*log(1.0-rand1)) * cos(2.0*pi*rand2)+m;

//    printf("sqrt(%.5f) = %.4f\n",-2.0*log(1.0-rand1), sqrt(-2.0*log(1.0-rand1)));
    return coeff_mult*gauss;
}
