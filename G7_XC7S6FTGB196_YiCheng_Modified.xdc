set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
# TEST2
set_property PACKAGE_PIN K12 [get_ports spi_data]
set_property IOSTANDARD LVCMOS33 [get_ports spi_data]

# TEST3
set_property PACKAGE_PIN M11 [get_ports spi_cs_l]
set_property IOSTANDARD LVCMOS33 [get_ports spi_cs_l]

# TEST4
set_property PACKAGE_PIN M12 [get_ports spi_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports spi_sclk]

# EXPB Pin
set_property PACKAGE_PIN M13 [get_ports EXPB_Bit0]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit0]

set_property PACKAGE_PIN L12 [get_ports EXPB_Bit1]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit1]

set_property PACKAGE_PIN L14 [get_ports EXPB_Bit2]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit2]

set_property PACKAGE_PIN L13 [get_ports EXPB_Bit3]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit3]

set_property PACKAGE_PIN J12 [get_ports EXPB_Bit4]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit4]

set_property PACKAGE_PIN J13 [get_ports EXPB_Bit5]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit5]

set_property PACKAGE_PIN H12 [get_ports EXPB_Bit6]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit6]

set_property PACKAGE_PIN H13 [get_ports EXPB_Bit7]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit7]

set_property PACKAGE_PIN H14 [get_ports EXPB_Bit8]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit8]

set_property PACKAGE_PIN H11 [get_ports EXPB_Bit9]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit9]

set_property PACKAGE_PIN G14 [get_ports EXPB_Bit10]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit10]

set_property PACKAGE_PIN F13 [get_ports EXPB_Bit11]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit11]

set_property PACKAGE_PIN F14 [get_ports EXPB_Bit12]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit12]

set_property PACKAGE_PIN F12 [get_ports EXPB_Bit13]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit13]

set_property PACKAGE_PIN F11 [get_ports EXPB_Bit14]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit14]

set_property PACKAGE_PIN E13 [get_ports EXPB_Bit15]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit15]

set_property PACKAGE_PIN E12 [get_ports EXPB_Bit16]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit16]

set_property PACKAGE_PIN D14 [get_ports EXPB_Bit17]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit17]

set_property PACKAGE_PIN D13 [get_ports EXPB_Bit18]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit18]

set_property PACKAGE_PIN D12 [get_ports EXPB_Bit19]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit19]

set_property PACKAGE_PIN C14 [get_ports EXPB_Bit20]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit20]

set_property PACKAGE_PIN B14 [get_ports EXPB_Bit21]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit21]

set_property PACKAGE_PIN C12 [get_ports EXPB_Bit22]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit22]

set_property PACKAGE_PIN B13 [get_ports EXPB_Bit23]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit23]

set_property PACKAGE_PIN A13 [get_ports EXPB_Bit24]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit24]

set_property PACKAGE_PIN E11 [get_ports EXPB_Bit25]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit25]

set_property PACKAGE_PIN J11 [get_ports EXPB_Bit26]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit26]

set_property PACKAGE_PIN A12 [get_ports EXPB_Bit27]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit27]

set_property PACKAGE_PIN B10 [get_ports EXPB_Bit28]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit28]

set_property PACKAGE_PIN A10 [get_ports EXPB_Bit29]
set_property IOSTANDARD LVCMOS33 [get_ports EXPB_Bit29]

# LVDS Pin

set_property IOSTANDARD LVDS_25 [get_ports A_rx0_p]
set_property IOSTANDARD LVDS_25 [get_ports A_rx0_n]
set_property PACKAGE_PIN G1 [get_ports A_rx0_p]
set_property PACKAGE_PIN F1 [get_ports A_rx0_n]

set_property IOSTANDARD LVDS_25 [get_ports A_rx1_p]
set_property IOSTANDARD LVDS_25 [get_ports A_rx1_n]
set_property PACKAGE_PIN F3 [get_ports A_rx1_p]
set_property PACKAGE_PIN F2 [get_ports A_rx1_n]

set_property IOSTANDARD LVDS_25 [get_ports A_rx2_p]
set_property IOSTANDARD LVDS_25 [get_ports A_rx2_n]
set_property PACKAGE_PIN E2 [get_ports A_rx2_p]
set_property PACKAGE_PIN D2 [get_ports A_rx2_n]

set_property IOSTANDARD LVDS_25 [get_ports A_rx3_p]
set_property IOSTANDARD LVDS_25 [get_ports A_rx3_n]
set_property PACKAGE_PIN D3 [get_ports A_rx3_p]
set_property PACKAGE_PIN C3 [get_ports A_rx3_n]

set_property IOSTANDARD LVDS_25 [get_ports A_rx4_p]
set_property IOSTANDARD LVDS_25 [get_ports A_rx4_n]
set_property PACKAGE_PIN B2 [get_ports A_rx4_p]
set_property PACKAGE_PIN B1 [get_ports A_rx4_n]

set_property IOSTANDARD LVDS_25 [get_ports A_clkout_p]
set_property IOSTANDARD LVDS_25 [get_ports A_clkout_n]
set_property PACKAGE_PIN D1 [get_ports A_clkout_p]
set_property PACKAGE_PIN C1 [get_ports A_clkout_n]

set_property IOSTANDARD LVDS_25 [get_ports B_rx0_p]
set_property IOSTANDARD LVDS_25 [get_ports B_rx0_n]
set_property PACKAGE_PIN B3 [get_ports B_rx0_p]
set_property PACKAGE_PIN A2 [get_ports B_rx0_n]

set_property IOSTANDARD LVDS_25 [get_ports B_rx1_p]
set_property IOSTANDARD LVDS_25 [get_ports B_rx1_n]
set_property PACKAGE_PIN A4 [get_ports B_rx1_p]
set_property PACKAGE_PIN A3 [get_ports B_rx1_n]

set_property IOSTANDARD LVDS_25 [get_ports B_rx2_p]
set_property IOSTANDARD LVDS_25 [get_ports B_rx2_n]
set_property PACKAGE_PIN E4 [get_ports B_rx2_p]
set_property PACKAGE_PIN D4 [get_ports B_rx2_n]

set_property IOSTANDARD LVDS_25 [get_ports B_rx3_p]
set_property IOSTANDARD LVDS_25 [get_ports B_rx3_n]
set_property PACKAGE_PIN C5 [get_ports B_rx3_p]
set_property PACKAGE_PIN C4 [get_ports B_rx3_n]

set_property IOSTANDARD LVDS_25 [get_ports B_rx4_p]
set_property IOSTANDARD LVDS_25 [get_ports B_rx4_n]
set_property PACKAGE_PIN B5 [get_ports B_rx4_p]
set_property PACKAGE_PIN A5 [get_ports B_rx4_n]

set_property IOSTANDARD LVDS_25 [get_ports B_clkout_p]
set_property IOSTANDARD LVDS_25 [get_ports B_clkout_n]
set_property PACKAGE_PIN G4 [get_ports B_clkout_p]
set_property PACKAGE_PIN F4 [get_ports B_clkout_n]

set_property IOSTANDARD LVDS_25 [get_ports A2_rx0_p]
set_property IOSTANDARD LVDS_25 [get_ports A2_rx0_n]
set_property PACKAGE_PIN M5 [get_ports A2_rx0_p]
set_property PACKAGE_PIN M4 [get_ports A2_rx0_n]

set_property IOSTANDARD LVDS_25 [get_ports A2_rx1_p]
set_property IOSTANDARD LVDS_25 [get_ports A2_rx1_n]
set_property PACKAGE_PIN P5 [get_ports A2_rx1_p]
set_property PACKAGE_PIN N4 [get_ports A2_rx1_n]

set_property IOSTANDARD LVDS_25 [get_ports A2_rx2_p]
set_property IOSTANDARD LVDS_25 [get_ports A2_rx2_n]
set_property PACKAGE_PIN H4 [get_ports A2_rx2_p]
set_property PACKAGE_PIN H3 [get_ports A2_rx2_n]

set_property IOSTANDARD LVDS_25 [get_ports A2_rx3_p]
set_property IOSTANDARD LVDS_25 [get_ports A2_rx3_n]
set_property PACKAGE_PIN K4 [get_ports A2_rx3_p]
set_property PACKAGE_PIN K3 [get_ports A2_rx3_n]

set_property IOSTANDARD LVDS_25 [get_ports A2_rx4_p]
set_property IOSTANDARD LVDS_25 [get_ports A2_rx4_n]
set_property PACKAGE_PIN P2 [get_ports A2_rx4_p]
set_property PACKAGE_PIN N1 [get_ports A2_rx4_n]

set_property IOSTANDARD LVDS_25 [get_ports A2_clkout_p]
set_property IOSTANDARD LVDS_25 [get_ports A2_clkout_n]
set_property PACKAGE_PIN P4 [get_ports A2_clkout_p]
set_property PACKAGE_PIN P3 [get_ports A2_clkout_n]

set_property IOSTANDARD LVDS_25 [get_ports B2_rx0_p]
set_property IOSTANDARD LVDS_25 [get_ports B2_rx0_n]
set_property PACKAGE_PIN M3 [get_ports B2_rx0_p]
set_property PACKAGE_PIN M2 [get_ports B2_rx0_n]

set_property IOSTANDARD LVDS_25 [get_ports B2_rx1_p]
set_property IOSTANDARD LVDS_25 [get_ports B2_rx1_n]
set_property PACKAGE_PIN M1 [get_ports B2_rx1_p]
set_property PACKAGE_PIN L1 [get_ports B2_rx1_n]

set_property IOSTANDARD LVDS_25 [get_ports B2_rx2_p]
set_property IOSTANDARD LVDS_25 [get_ports B2_rx2_n]
set_property PACKAGE_PIN L3 [get_ports B2_rx2_p]
set_property PACKAGE_PIN L2 [get_ports B2_rx2_n]

set_property IOSTANDARD LVDS_25 [get_ports B2_rx3_p]
set_property IOSTANDARD LVDS_25 [get_ports B2_rx3_n]
set_property PACKAGE_PIN J4 [get_ports B2_rx3_p]
set_property PACKAGE_PIN J3 [get_ports B2_rx3_n]

set_property IOSTANDARD LVDS_25 [get_ports B2_rx4_p]
set_property IOSTANDARD LVDS_25 [get_ports B2_rx4_n]
set_property PACKAGE_PIN H2 [get_ports B2_rx4_p]
set_property PACKAGE_PIN H1 [get_ports B2_rx4_n]

set_property IOSTANDARD LVDS_25 [get_ports B2_clkout_p]
set_property IOSTANDARD LVDS_25 [get_ports B2_clkout_n]
set_property PACKAGE_PIN J2 [get_ports B2_clkout_p]
set_property PACKAGE_PIN J1 [get_ports B2_clkout_n]

set_property PACKAGE_PIN G11 [get_ports iOSC]
set_property IOSTANDARD LVCMOS33 [get_ports iOSC]

set_property PACKAGE_PIN N14 [get_ports oSTB]
set_property IOSTANDARD LVCMOS33 [get_ports oSTB]

set_property PACKAGE_PIN M14 [get_ports iSW0]
set_property IOSTANDARD LVCMOS33 [get_ports iSW0]

set_property PACKAGE_PIN P12 [get_ports iSW1]
set_property IOSTANDARD LVCMOS33 [get_ports iSW1]

set_property PACKAGE_PIN P13 [get_ports iSW2]
set_property IOSTANDARD LVCMOS33 [get_ports iSW2]

set_property PACKAGE_PIN N10 [get_ports iSW3]
set_property IOSTANDARD LVCMOS33 [get_ports iSW3]

set_property PACKAGE_PIN N11 [get_ports iRESET]
set_property IOSTANDARD LVCMOS33 [get_ports iRESET]

set_property PACKAGE_PIN P10 [get_ports iBUTTON_0]
set_property IOSTANDARD LVCMOS33 [get_ports iBUTTON_0]

set_property PACKAGE_PIN M10 [get_ports iBUTTON_1]
set_property IOSTANDARD LVCMOS33 [get_ports iBUTTON_1]

set_property PACKAGE_PIN P11 [get_ports iBUTTON_2]
set_property IOSTANDARD LVCMOS33 [get_ports iBUTTON_2]

set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set_false_path -from [get_ports iRESET]
#set_clock_groups -physically_exclusive -group [get_clocks -include_generated_clocks txpllmmcm_x1] -group [get_clocks -include_generated_clocks txpllmmcm_x1_1]
#set_clock_groups -physically_exclusive -group [get_clocks -include_generated_clocks txpllmmcm_xn] -group [get_clocks -include_generated_clocks txpllmmcm_xn_1]
#set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks {txpllmmcm_x1 txpllmmcm_xn}] -group [get_clocks -include_generated_clocks {txpllmmcm_x1_1 txpllmmcm_xn_1}]
#create_generated_clock -name clk_out1_clk_wiz_0_Gen -source [get_pins {U1/uPATTERNSEL/FSM_sequential_btn0_status[1]_i_2/I2}] -divide_by 1 -add -master_clock clk_out1_clk_wiz_0 [get_pins {U1/uPATTERNSEL/FSM_sequential_btn0_status[1]_i_2/O}]
#create_generated_clock -name clk_out2_clk_wiz_0_Gen -source [get_pins {U1/uPATTERNSEL/FSM_sequential_btn0_status[1]_i_2/I0}] -divide_by 1 -add -master_clock clk_out2_clk_wiz_0 [get_pins {U1/uPATTERNSEL/FSM_sequential_btn0_status[1]_i_2/O}]
#set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks clk_out1_clk_wiz_0_Gen] -group [get_clocks -include_generated_clocks clk_out2_clk_wiz_0_Gen]
#set_input_jitter [get_clocks -filter { NAME =~  "*OSC*" && NAME =~  "*" }] 0.400







