`timescale 10ps/10ps
module IKA9958_tb;

//generate clock
reg CLK = 1'b1;
always #1 CLK = ~CLK;

//async reset
reg RST_n = 1'b0;
initial #35 RST_n = 1'b1;


IKA9958 #(.CM(0)) u_dut (
    .i_XTAL1                    (CLK                        ),
    .o_XTAL2                    (                           ),
    .i_XTAL_NCEN                (1'b1                       ),

    .i_DLCLK_n                  (1'b1                       ),
    .o_DHCLK_n                  (                           ),
    .o_DLCLK_n                  (                           ),

    .i_RST_n                    (RST_n                      )
);




endmodule