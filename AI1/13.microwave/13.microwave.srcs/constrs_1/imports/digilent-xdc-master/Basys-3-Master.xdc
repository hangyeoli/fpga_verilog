## Basys3 constraints for top_microwave.v
## Active ports:
## clk, reset, btnU/L/C/R/D, start_cancel_btn,
## seg[6:0], dp, an[3:0], motor_pwm, motor_in1, motor_in2, servo_pwm, buzzer

## Clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Reset (SW15)
set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS33 } [get_ports reset]

## Buttons (on-board)
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports btnU]
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports btnL]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports btnC]
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports btnR]
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports btnD]

## Start/Cancel toggle button (external, J3 / XA1_P)
set_property -dict { PACKAGE_PIN J3 IOSTANDARD LVCMOS33 } [get_ports start_cancel_btn]

## 7-segment
set_property -dict { PACKAGE_PIN W7 IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]
set_property -dict { PACKAGE_PIN W6 IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
set_property -dict { PACKAGE_PIN U8 IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]
set_property -dict { PACKAGE_PIN V8 IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]
set_property -dict { PACKAGE_PIN U5 IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]
set_property -dict { PACKAGE_PIN V5 IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]
set_property -dict { PACKAGE_PIN U7 IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]
set_property -dict { PACKAGE_PIN V7 IOSTANDARD LVCMOS33 } [get_ports dp]

set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN U4 IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN V4 IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN W4 IOSTANDARD LVCMOS33 } [get_ports {an[3]}]

## DC motor driver on JA1/JA2/JA3
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports motor_pwm]  ;# JA1
set_property -dict { PACKAGE_PIN L2 IOSTANDARD LVCMOS33 } [get_ports motor_in1]  ;# JA2
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports motor_in2]  ;# JA3

## Buzzer on JC1
set_property -dict { PACKAGE_PIN K17 IOSTANDARD LVCMOS33 } [get_ports buzzer]    ;# JC1

## Servo control on JC9 (signal only)
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports servo_pwm] ;# JC9

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
