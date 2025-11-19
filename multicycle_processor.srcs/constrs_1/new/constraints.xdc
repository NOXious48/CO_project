################################################################################
# Clock - 100 MHz on Basys3
################################################################################
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

create_clock -period 10.000 -name sys_clk [get_ports clk]

################################################################################
# Reset button (active HIGH)
################################################################################
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

################################################################################
# Debug enable switch (SW0)
################################################################################
set_property PACKAGE_PIN V17 [get_ports debug_enable]
set_property IOSTANDARD LVCMOS33 [get_ports debug_enable]

################################################################################
# Debug step button (BTNC)
################################################################################
set_property PACKAGE_PIN T18 [get_ports debug_step_btn]
set_property IOSTANDARD LVCMOS33 [get_ports debug_step_btn]

################################################################################
# Debug outputs on LEDs
#   debug_pc[7:0] → LED0-LED7
#   debug_state[2:0] → LED8-LED10
#   debug_reg2 lower 4 bits → LED11-LED14
#   cycle_count[0] → LED15
################################################################################

# PC lower 8 bits
set_property PACKAGE_PIN U16 [get_ports {debug_pc[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[0]}]

set_property PACKAGE_PIN E19 [get_ports {debug_pc[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[1]}]

set_property PACKAGE_PIN U19 [get_ports {debug_pc[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[2]}]

set_property PACKAGE_PIN V19 [get_ports {debug_pc[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[3]}]

set_property PACKAGE_PIN U14 [get_ports {debug_pc[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[4]}]

set_property PACKAGE_PIN V14 [get_ports {debug_pc[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[5]}]

set_property PACKAGE_PIN V13 [get_ports {debug_pc[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[6]}]

set_property PACKAGE_PIN U13 [get_ports {debug_pc[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[7]}]

# State bits
set_property PACKAGE_PIN W18 [get_ports {debug_state[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_state[0]}]

set_property PACKAGE_PIN W19 [get_ports {debug_state[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_state[1]}]

set_property PACKAGE_PIN U15 [get_ports {debug_state[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_state[2]}]

# R2 lower 4 bits
set_property PACKAGE_PIN L1 [get_ports {debug_reg2[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_reg2[0]}]

set_property PACKAGE_PIN P1 [get_ports {debug_reg2[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_reg2[1]}]

set_property PACKAGE_PIN N3 [get_ports {debug_reg2[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_reg2[2]}]

set_property PACKAGE_PIN P3 [get_ports {debug_reg2[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_reg2[3]}]

# LED15 = cycle_count[0]
set_property PACKAGE_PIN N4 [get_ports cycle_count[0]]
set_property IOSTANDARD LVCMOS33 [get_ports cycle_count[0]]

################################################################################
# Timing constraints
################################################################################
set_input_delay  -clock sys_clk 2.0 [all_inputs]
set_output_delay -clock sys_clk 2.0 [all_outputs]

################################################################################
# Configuration
################################################################################
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
