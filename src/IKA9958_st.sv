module IKA9958_st (
    /* RESET INPUT */
    input   wire                i_HRST_n,

    /* INTERFACES */
    IKA9958_if_rcc.source       RCC, //reset and clock control
    IKA9958_if_reg.read         REG, //register file(configuration)
    IKA9958_if_st.drive         ST
);

/*
    IKA9958 Screen Timing
    This module generates all video timing signals
*/

//PLA outputs
wire    [20:0]  hpla;   //horizontal
wire    [27:0]  vpla;   //vertical
wire    [9:0]   vapla;  //vertical-auxiliary



///////////////////////////////////////////////////////////
//////  Horizontal Timings
////

logic           hrst_z;
logic           hrst_zz, hpla0_z;
always_ff @(posedge RCC.phiA) if(RCC.phiA_NCEN) hrst_z <= ~i_HRST_n;
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    hrst_zz <= hrst_z;
    hpla0_z <= hpla[0];
end








assign  ST.gc024 = 1'b1;

endmodule

interface IKA9958_if_st;
wire            gc024;

//clarify directionality
modport drive   (output gc024);
modport source  (input  gc024);
endinterface