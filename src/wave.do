onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /IKA9958_tb/CLK
add wave -noupdate /IKA9958_tb/RST_n
add wave -noupdate /IKA9958_tb/u_dut/u_rcc/nor4_z
add wave -noupdate /IKA9958_tb/u_dut/u_rcc/cdiv_sr0
add wave -noupdate /IKA9958_tb/u_dut/u_rcc/cdiv_sr1
add wave -noupdate /IKA9958_tb/u_dut/u_rcc/cdiv_sr2
add wave -noupdate /IKA9958_tb/u_dut/u_rcc/ref_phiL
add wave -noupdate /IKA9958_tb/u_dut/u_rcc/ref_phiH
add wave -noupdate -expand -group ST -radix unsigned /IKA9958_tb/u_dut/u_st/hcntr
add wave -noupdate -expand -group ST /IKA9958_tb/u_dut/u_st/hcntr_rst
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/comcntr_hi_ci
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/comcntr_hi_ld
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/comcntr_lo_ld
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/comcntr
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/gt022_sr4
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/gt031
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/gt032
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/gt033
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/gt041
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/gt042
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/gt043
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/gt044
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/hadd_eq23_long
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/hadd_eq23_long_z
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/hadd_eq23_z
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/ST/hadd_eq23
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/pla0
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/pla0_0_z
add wave -noupdate -expand -group PLA /IKA9958_tb/u_dut/u_pla/pla0_2_z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {218830 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {112590 ps} {262970 ps}
