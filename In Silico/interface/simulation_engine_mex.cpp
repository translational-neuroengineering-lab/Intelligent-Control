/*
 * mexmodelwrapper.cpp
 *
 *  Created on: Aug 23, 2015
 *      Author: mconnolly
 */

#include "mex.h"
#include "../simulation_engine/Sigma.h"
#include "../simulation_engine/Mass_CA3_Lumped.h"
#include "../simulation_engine/NoiseGenerator.h"
#include <stdio.h>
#include <vector>
#include <iostream>
#include <fstream>

void mexFunction(
		 int          nlhs,
		 mxArray      *[],
		 int          nrhs,
		 const mxArray *prhs[]
		 )
{
	  if (nrhs != 6) {
	    mexErrMsgIdAndTxt("MATLAB:mexcpp:nargin",
	            "MEXCPP requires three input arguments.");
	  }


	double *synaptic_gain, *synaptic_time_constants;
	double *internal_connectivities, *mass_connectivities;
	double *stimulation_parameters, *simulation_parameters;

	synaptic_gain 				= mxGetPr(prhs[0]);
	synaptic_time_constants 	= mxGetPr(prhs[1]);
	internal_connectivities 	= mxGetPr(prhs[2]);
	mass_connectivities 		= mxGetPr(prhs[3]);
	stimulation_parameters		= mxGetPr(prhs[4]);
	simulation_parameters 		= mxGetPr(prhs[5]);

	double A1 = synaptic_gain[0];
	double B1 = synaptic_gain[1];
	double G1 = synaptic_gain[2];

	double a = synaptic_time_constants[0];
	double b = synaptic_time_constants[1];
	double g = synaptic_time_constants[2];

	double C1 = internal_connectivities[0];
	double C2 = internal_connectivities[1];
	double C3 = internal_connectivities[2];
	double C4 = internal_connectivities[3];
	double C5 = internal_connectivities[4];
	double C6 = internal_connectivities[5];
	double C7 = internal_connectivities[6];

	double schaffer_weight 	= mass_connectivities[0];
	double feedback_weight 	= mass_connectivities[1];
	double lateral_weight 	= mass_connectivities[2];
	double dentate_weight 	= mass_connectivities[3];
	double perforant_weight = mass_connectivities[4];
	int n_layers 			= (int) mass_connectivities[5];

	double stimulation_amplitude 	= stimulation_parameters[0];
	double f_stimulation 			= stimulation_parameters[1];
	double stimulation_channel		= stimulation_parameters[2];

	double t_end 	= simulation_parameters[0];
	double f_sample = simulation_parameters[1];
	int n_samples 	= (int) t_end*f_sample;

	double 	v0 	= 6.0;
	double 	e0 	= 2.5;
	double 	r 	= 0.56;

	std::vector<Mass_CA3_Lumped *> CA3_row(n_layers);
	std::vector<Mass_CA1_Lumped *> CA1_row(n_layers);

	Noise_Generator *dentate_afferent, *perforant_afferent;


	// ==CA3 Row==
	// -----1-----

	for(int c1 = 0; c1 < CA3_row.size(); c1++){
		CA3_row[c1] = new Mass_CA3_Lumped;
	}

	for(int c1 = 0; c1 < CA1_row.size(); c1++){
		CA1_row[c1] = new Mass_CA1_Lumped;
	}

	dentate_afferent 	= new Noise_Generator();
	perforant_afferent 	= new Noise_Generator();

	for(int c1 = 0; c1 < CA3_row.size(); c1++){

		CA3_row[c1]->set_A(A1);
		CA3_row[c1]->set_B(B1);
		CA3_row[c1]->set_G(G1);
		CA3_row[c1]->set_a(a);
		CA3_row[c1]->set_b(b);
		CA3_row[c1]->set_g(g);

		CA3_row[c1]->set_C1(C1);
		CA3_row[c1]->set_C2(C2);
		CA3_row[c1]->set_C3(C3);
		CA3_row[c1]->set_C4(C4);
		CA3_row[c1]->set_C5(C5);
		CA3_row[c1]->set_C6(C6);
		CA3_row[c1]->set_C7(C7);

		CA3_row[c1]->add_feedback_afferent(CA1_row[c1], feedback_weight);

		if(c1 < CA3_row.size() - 1){
			CA3_row[c1]->add_lateral_afferent(CA3_row[c1 + 1], lateral_weight);
		}

		if (c1 > 0 ){
			CA3_row[c1]->add_lateral_afferent(CA3_row[c1 - 1], lateral_weight);
		}

		CA3_row[c1]->add_noise_afferent(dentate_afferent, dentate_weight);

	}

	for(int c1 = 0; c1 < CA1_row.size(); c1++){

		CA1_row[c1]->set_A(A1);
		CA1_row[c1]->set_B(B1);
		CA1_row[c1]->set_G(G1);
		CA1_row[c1]->set_a(a);
		CA1_row[c1]->set_b(b);
		CA1_row[c1]->set_g(g);

		CA1_row[c1]->set_C1(C1);
		CA1_row[c1]->set_C2(C2);
		CA1_row[c1]->set_C3(C3);
		CA1_row[c1]->set_C4(C4);
		CA1_row[c1]->set_C5(C5);
		CA1_row[c1]->set_C6(C6);
		CA1_row[c1]->set_C7(C7);

		CA1_row[c1]->add_schaffer_afferent(CA3_row[c1], schaffer_weight);

		if(c1 < CA1_row.size() - 1){
			CA1_row[c1]->add_lateral_afferent(CA1_row[c1 + 1], lateral_weight);
		}

		if (c1 > 0 ){
			CA1_row[c1]->add_lateral_afferent(CA1_row[c1 - 1], lateral_weight);
		}

		CA1_row[c1]->add_noise_afferent(perforant_afferent, perforant_weight);
	}

//	CA3_row[0]->set_A(A2);
//	CA3_row[0]->set_B(B2);
//	CA3_row[0]->set_G(G2);

	Sigma::set_v0(v0);
	Sigma::set_e0(e0);
	Sigma::set_r(r);

	FILE *myfile;
	myfile = fopen ("data/example2.csv", "w");

	double time = 0;
	for(int c1 = 0; c1 < n_samples; c1++){
		time += 1./f_sample;

		if(time > 8 && time < 12){

			if(fmod(time,1./f_stimulation) < 1./200){
				CA3_row[stimulation_channel]->set_stimulation(stimulation_amplitude);
			}else if(fmod(time,1./f_stimulation) < 1./100){
				CA3_row[stimulation_channel]->set_stimulation(-1.0*stimulation_amplitude);
			}else{
				CA3_row[stimulation_channel]->set_stimulation(0.0);
			}

		}else{
			CA3_row[stimulation_channel]->set_stimulation(0.0);
		}

		for(int c2 = 0; c2 < CA3_row.size(); c2++){
			CA3_row[c2]->update_ode();

		}

		for(int c2 = 0; c2 < CA1_row.size(); c2++){
			CA1_row[c2]->update_ode();
		}

		for(int c2 = 0; c2 < CA3_row.size(); c2++){
			CA3_row[c2]->update_state(1./f_sample);
		}

		for(int c2 = 0; c2 < CA1_row.size(); c2++){
			CA1_row[c2]->update_state(1./f_sample);
		}

		dentate_afferent->update_gaussian();
		perforant_afferent->update_gaussian();

		printf("%d\n", c1);
		if(c1 > f_sample){
			for(int c2 = 0; c2 < CA3_row.size(); c2++){
				fprintf(myfile, "%f,", CA3_row[c2]->get_lfp());
				printf("%f,", CA3_row[c2]->get_lfp());
			}

			for(int c2 = 0; c2 < CA1_row.size(); c2++){
				fprintf(myfile, "%f,", CA1_row[c2]->get_lfp());
				printf("%f,", CA1_row[c2]->get_lfp());
			}

			fprintf(myfile, "\n");
//			printf("\n");
		}
	}

//	printf("nsamp %d\n", n_samples);
	fclose(myfile);
	return;
}
