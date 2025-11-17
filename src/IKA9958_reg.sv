/*
    IKA9958 Registers
*/

module IKA9958_reg (
    /* INTERFACES */
    IKA9958_if_rcc.source       RCC, //reset and clock control
    IKA9958_if_reg.drive        REG
);

logic   [7:0]   regfile [0:63];
assign  REG.regfile = regfile; //drive interface port


assign regfile[9][0] = 1'b0;
assign regfile[9][5:4] = 2'd0; //synchronization mode
assign regfile[15][6] = 1'b0; //unknown


endmodule

interface IKA9958_if_reg;
//simply wires(no register here)
logic   [7:0]   regfile [0:63];

//clarify directionality
modport drive   (output regfile);
modport read    (input  regfile);
endinterface