/*
    IKA9958 Registers
*/

module IKA9958_reg (
    /* INTERFACES */
    IKA9958_if_rcc.source       RCC, //reset and clock control
    IKA9958_if_reg.drive        REG
);

logic   [7:0]   regfile [0:63];
assign  REG.FILE    = regfile;                                          //drive interface port; whole register file
assign  REG.M       = {regfile[0][3:1], regfile[1][3], regfile[1][4]};  //display mode
assign  REG.DC      = regfile[9][0];                                    //dlclk mode
assign  REG.NT_n    = regfile[9][1];                                    //NTSC(0)/PAL(1)
assign  REG.IL      = regfile[9][3];                                    //interlaced mode
assign  REG.S       = regfile[9][5:4];                                  //synchronization mode
assign  REG.H       = regfile[18][3:0];                                 //H position adjust
assign  REG.V       = regfile[18][7:4];                                 //V position adjust


assign regfile[0]  = 'h01;
assign regfile[1]  = 'h10;
assign regfile[9]  = 'h00;
assign regfile[15] = 'h00;
assign regfile[18] = 'h00;


endmodule

interface IKA9958_if_reg;
//simply wires(no register here)
logic   [7:0]   FILE [0:63];
logic   [4:0]   M;
logic           DC, NT_n, IL;
logic   [1:0]   S;
logic   [3:0]   H, V;


//clarify directionality
modport drive   (output FILE, M, DC, NT_n, IL, S, H, V);
modport read    (input  FILE, M, DC, NT_n, IL, S, H, V);
endinterface