#!/bin/bash

# Copy results
cp ../transformGamPoi-Figures/benchmark/output/benchmark_results/{simulation_results.tsv,consistency_results.tsv,downsampling_results.tsv} data/.
cp ../transformGamPoi-Figures/benchmark/output/benchmark_results/dataset_plot_data.RDS data/.

# Copy helper scripts
cp ../transformGamPoi-Figures/notebooks/annotation_helper.R src/.