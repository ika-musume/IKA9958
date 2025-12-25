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
assign  REG.file.array  = regfile;                                          //drive interface port; whole register file
assign  REG.file.M      = {regfile[0][3:1], regfile[1][3], regfile[1][4]};  //display mode
assign  REG.file.DC     = regfile[9][0];                                    //dlclk mode
assign  REG.file.NT_n   = regfile[9][1];                                    //NTSC(0)/PAL(1)
assign  REG.file.IL     = regfile[9][3];                                    //interlaced mode
assign  REG.file.S      = regfile[9][5:4];                                  //synchronization mode
assign  REG.file.H      = regfile[18][3:0];                                 //H position adjust
assign  REG.file.V      = regfile[18][7:4];                                 //V position adjust


assign regfile[0]  = 'h01;
assign regfile[1]  = 'h10;
assign regfile[9]  = 'h00;
assign regfile[15] = 'h00;
assign regfile[18] = 'h00;


endmodule

interface IKA9958_if_reg;
//simply wires(no register here)

typedef struct {
    logic   [7:0]   array [0:63];
    logic   [4:0]   M;
    logic           DC, NT_n, IL;
    logic   [1:0]   S;
    logic   [3:0]   H, V;
} reg_data_t;
reg_data_t file;

//make flags
wire            TMODE      = REG.file.M == T1 || REG.file.M == T2;
//wire            GMODE4567  = REG.file.M == T1 || REG.file.M == T2;
//wire            GMODE34567 = REG.file.M == T1 || REG.file.M == T2;


//clarify directionality
modport drive   (output file);
modport read    (input  file, TMODE);
endinterface