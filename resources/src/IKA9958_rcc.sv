/*
    IKA9958 Reset and Clock Control
*/

module IKA9958_rcc #(parameter CM = 0) (
    /* CLOCK INPUTS */
    input   wire                i_XTAL1, //crystal input/output
    output  wire                o_XTAL2,
    input   wire                i_XTAL_NCEN, //21.48MHz negative clock enable(CM>0 only)

    /* SYNCHRONIZATION */
    input   wire                i_DLCLK_n, //multi V9958?

    /* CLOCK OUTPUTS */
    output  wire                o_DHCLK_n, o_DLCLK_n, //open drain output

    /* RESET INPUT */
    input   wire                i_RST_n,

    /* INTERFACES */
    IKA9958_if_rcc.drive        RCC, //reset and clock control
    IKA9958_if_reg.read         REG, //register file(configuration)
    IKA9958_if_st.source        ST
);



///////////////////////////////////////////////////////////
//////  phiA
////

/*
    Clock Mode (CM) settings:
    0: use a 21.48MHz source as a master clock: 
       o_phiA will be inverted and the i_XTAL_NCEN will be ignored
       Most of the flops clocked by phiA operates on the negedge.
    1: use a source higher than 21.48MHz and clock enables
*/

//inverted output for oscillation
assign  o_XTAL2 = ~i_XTAL1;

generate
if(CM == 0) begin
    assign RCC.phiA = ~i_XTAL1;
    assign RCC.phiA_NCEN = 1'b1;
end
else if(CM == 1) begin
    assign RCC.phiA = i_XTAL1;
    assign RCC.phiA_NCEN = i_XTAL_NCEN;
end
endgenerate



///////////////////////////////////////////////////////////
//////  Clock Divider
////

logic           genlock_z, nor4_z;
logic   [2:0]   cdiv_sr0, cdiv_sr1, cdiv_sr2;
logic           ref_phiL, ref_phiH; //reference internal clock

assign  o_DLCLK_n = ~ref_phiL | REG.regfile[9][0];
assign  o_DHCLK_n = ~ref_phiH;

always_ff @(posedge RCC.phiA or negedge i_RST_n) begin
    if(!i_RST_n) begin
        //original chip doesn't have reset
        genlock_z <= 1'b0; nor4_z <= 1'b0;
        cdiv_sr0 <= 3'b000; cdiv_sr1 <= 3'b000; cdiv_sr2 <= 3'b000;
        ref_phiL <= 1'b0; ref_phiH <= 1'b0;
    end
    else begin if(RCC.phiA_NCEN) begin
        genlock_z   <= ~i_DLCLK_n;
        nor4_z      <= ~|{|{cdiv_sr2[2:1]}, ST.n_gc024, REG.regfile[9][0]};

        cdiv_sr0    <= {cdiv_sr0[1:0], genlock_z & REG.regfile[9][0]}; //R#9 bit0 DC
        cdiv_sr1    <= {cdiv_sr1[1:0], ~|{|{cdiv_sr1}, |{cdiv_sr0[2:1]}, nor4_z}};
        cdiv_sr2    <= {cdiv_sr2[1:0], ~|{cdiv_sr1[2:1]}};

        //reference internal clock; super duper SR latch inverts the clock output
        ref_phiL    <= |{cdiv_sr1[1:0]};
        ref_phiH    <= |{cdiv_sr1[2], cdiv_sr1[0]};
    end end
end




endmodule


interface IKA9958_if_rcc;
wire            phiA; //internal master clock
wire            phiA_NCEN; //21.48MHz
wire            phiH_PCEN, phiH_NCEN; //DHCLK, 10.74MHz
wire            phiL_PCEN, phiL_NCEN; //DLCLK, 5.37MHz

//clarify directionality
modport drive   (output phiA, phiA_NCEN, phiH_PCEN, phiH_NCEN, phiL_PCEN, phiL_NCEN);
modport source  (input  phiA, phiA_NCEN, phiH_PCEN, phiH_NCEN, phiL_PCEN, phiL_NCEN);
endinterface