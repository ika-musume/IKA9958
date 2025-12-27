/*
    IKA9958 Registers
*/

import IKA9958_mnemonics::*;

module IKA9958_reg (
    /* INTERFACES */
    IKA9958_if_rcc.source       RCC, //reset and clock control
    IKA9958_if_reg.drive        REG
);

logic   [7:0]   regfile [0:63];
assign  REG.arr  = regfile; //drive interface port; whole register file



assign regfile[0]  = 'h06;
assign regfile[1]  = 'h00;
assign regfile[9]  = 'h00;
assign regfile[15] = 'h00;
assign regfile[18] = 'h00;


endmodule

interface IKA9958_if_reg;

//regfile 
typedef struct {
    logic   [4:0]   M;
    logic           DC, NT_n, IL;
    logic   [1:0]   S;
    logic   [3:0]   H, V;
} RegData_t;

RegData_t  Data;
logic   [7:0]   arr [0:63];

//data breakout
assign  Data.M      = 5'b01100; //{arr[0][3:1], arr[1][3], arr[1][4]};  //display mode
assign  Data.DC     = arr[9][0];                            //dlclk mode
assign  Data.NT_n   = arr[9][1];                            //NTSC(0)/PAL(1)
assign  Data.IL     = arr[9][3];                            //interlaced mode
assign  Data.S      = arr[9][5:4];                          //synchronization mode
assign  Data.H      = arr[18][3:0];                         //H position adjust
assign  Data.V      = arr[18][7:4];                         //V position adjust

//clarify directionality
modport drive   (output arr);
modport read    (input  Data, arr);
endinterface