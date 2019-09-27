First round of processing (ATLAS deliverable)
used the string:

1. fe_superpose_histograms.sh
   -> unpack.sh
   
2. fe_superpose_case_studies.sh

3. fe_get_area_metrics.sh
   -> get_area_metrics.sh
   -> get_area_metrics_ring.sh

4. fe_get_pathway_metrics.sh
   -> get_pathway_metrics_ring.sh

5. fe_plot_area_metrics<_multi_panel>.sh

Second round of processing NatComms submission:

1. fe_seasonal_superposition.sh
   -> unpack.sh
   # For each year gather all histograms
   # that correspond to a given season.
   
2. fe_all_seasons_superposition.sh
   # Merge all the seasonal histograms
   # (by case study and by ring) into
   # a single result.

3. For each directory, for each zipped
   histogram file, compute the most likley
   time series file for it.