#!/bin/bash

# Copy results
cp ../transformGamPoi-Figures2/benchmark/output/benchmark_results/{simulation_results.tsv,consistency_results.tsv,downsampling_results.tsv} data/.
cp ../transformGamPoi-Figures2/benchmark/output/benchmark_results/dataset_plot_data.RDS data/.

# Copy helper scripts
cp ../transformGamPoi-Figures2/notebooks/annotation_helper.R src/.