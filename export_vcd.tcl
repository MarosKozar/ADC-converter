# Vivado TCL Script to generate VCD from simulation
open_wave_database "ADC_filtr_signal.sim/sim_1/behav/xsim/sim_top_behav.wdb"

# Log all signals recursively
log_wave -recursive /*

# Run the simulation fully
run all

# Export to VCD
write_vcd "sim_top_behav.vcd"

# Close simulation
close_wave_database
quit
