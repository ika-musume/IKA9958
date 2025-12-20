`timescale 10ps/10ps
module IKA9958_tb;

//generate clock
logic CLK = 1'b1;
always #1 CLK = ~CLK;

//generate external clock
logic DLCLK = 1'b1;
initial begin
    repeat(6) #16 DLCLK = ~DLCLK;
    repeat(4) begin
        #24 DLCLK = ~DLCLK;
        #16 DLCLK = ~DLCLK;
    end
    while(1) #16 DLCLK = ~DLCLK;
end

//generate clock enable(21MHz NCEN)
logic [1:0] CLKDIV = 2'd0;
wire NCEN = CLKDIV == 3;
always @(posedge CLK) CLKDIV = CLKDIV + 2'd1;

//async reset
logic RST_n = 1'b0;
initial begin 
    #60 RST_n = 1'b1;
    #200 RST_n = 1'b0;
    #175 RST_n = 1'b1;
end


IKA9958 #(.CM(1)) u_dut (
    .i_XTAL1                    (CLK                        ),
    .o_XTAL2                    (                           ),
    .i_XTAL_NCEN                (NCEN                       ),

    .i_DLCLK_n                  (DLCLK                      ),
    
    .o_DHCLK_n                  (                           ),
    .o_DLCLK_n                  (                           ),

    .i_RST_n                    (RST_n                      ),
    .i_HRST_n                   (1'b1                       ),
    .i_VRST_n                   (1'b1                       )
);




endmodule