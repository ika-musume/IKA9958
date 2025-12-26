/*
    IKA9958 Reset and Clock Control
*/

module IKA9958_rcc #(parameter CM = 0) (
    /* RESET INPUT */
    input   wire                i_RST_n,

    /* CLOCK INPUTS */
    input   wire                i_XTAL1, //crystal input/output
    output  wire                o_XTAL2,
    input   wire                i_XTAL_NCEN, //21.48MHz negative clock enable(CM>0 only)

    /* SYNCHRONIZATION */
    input   wire                i_DLCLK_n, //multi V9958?

    /* CLOCK OUTPUTS */
    output  wire                o_DHCLK_n, o_DHCLK_n_PCEN, o_DHCLK_n_NCEN, //open drain output
    output  wire                o_DLCLK_n, o_DLCLK_n_PCEN, o_DLCLK_n_NCEN, //open drain output
    output  wire                o_CPUCLK, o_CPUCLK_PCEN, o_CPUCLK_NCEN, //Z80 clock

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
//////  phiL/phiH Clock Divider
////

logic           clksync_z;
logic           nor4_z = 1'b0;
logic   [2:0]   cdiv_sr0 = 3'd0;
logic   [2:0]   cdiv_sr1 = 3'd0;
logic   [2:0]   cdiv_sr2 = 3'd0;
logic           ref_phiL, ref_phiH; //reference internal clock

`ifdef IKA9958_ADD_RCC_RST
//optional register reset
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!i_RST_n) begin
        //original chip doesn't have reset, all dynamic shift registers
        clksync_z <= 1'b0; nor4_z <= 1'b0;
        cdiv_sr0 <= 3'b000; cdiv_sr1 <= 3'b000; cdiv_sr2 <= 3'b000;
        ref_phiL <= 1'b0; ref_phiH <= 1'b0;
    end
    else 
`else
always_ff @(posedge RCC.phiA) begin
`endif
    begin if(RCC.phiA_NCEN) begin
        clksync_z   <= ~i_DLCLK_n;
        nor4_z      <= ~|{~cdiv_sr2[2], cdiv_sr2[1], ST.gc024, REG.arr[9][0]};

        cdiv_sr0    <= {cdiv_sr0[1:0], clksync_z & REG.arr[9][0]}; //This SR delays the DLCLK input
        cdiv_sr1    <= {cdiv_sr1[1:0], ~|{|{cdiv_sr1}, |{cdiv_sr0[2:1]}, nor4_z}}; //This SR acts as a ring counter(div4)
        cdiv_sr2    <= {cdiv_sr2[1:0], ~|{cdiv_sr1[1:0]}}; //This SR adds a delay for clock pause

        //reference internal clock; super duper SR latch inverts the clock output
        ref_phiL    <= |{cdiv_sr1[1:0]};
        ref_phiH    <= |{cdiv_sr1[2], cdiv_sr1[0]};
    end end
end

//div2 CEN
assign  RCC.phiH_PCEN = (cdiv_sr1 == 3'b001 | cdiv_sr1 == 3'b100) & RCC.phiA_NCEN;
assign  RCC.phiH_NCEN = ((cdiv_sr1 == 3'b000 & cdiv_sr2 == 3'b001) | cdiv_sr1 == 3'b010) & RCC.phiA_NCEN;

//div4 CEN
assign  RCC.phiL_PCEN = (cdiv_sr1 == 3'b001) & RCC.phiA_NCEN;
assign  RCC.phiL_NCEN = (cdiv_sr1 == 3'b100) & RCC.phiA_NCEN;

//clock outputs
assign  o_DHCLK_n = ~ref_phiH;
assign  o_DHCLK_n_PCEN = RCC.phiH_NCEN;
assign  o_DHCLK_n_NCEN = RCC.phiH_PCEN;
assign  o_DLCLK_n = ~ref_phiL | REG.arr[9][0]; //R#9 bit0 DC
assign  o_DLCLK_n_PCEN = RCC.phiL_NCEN;
assign  o_DLCLK_n_NCEN = RCC.phiL_PCEN;



///////////////////////////////////////////////////////////
//////  Z80 clock
////

logic   [6:0]   cdiv_sr4 = 7'd0;
logic   [1:0]   cpuclk, cpuclk_pcen, cpuclk_ncen;
assign  o_CPUCLK = cpuclk[1];
assign  o_CPUCLK_PCEN = cpuclk_pcen[1];
assign  o_CPUCLK_NCEN = cpuclk_ncen[1];

always_ff @(posedge RCC.phiA) if(RCC.phiA_NCEN) begin
    cdiv_sr4[1:0] <= {cdiv_sr4[0], i_RST_n};
    cdiv_sr4[6:2] <= {cdiv_sr4[5:2], ~((cdiv_sr4[1] & ~cdiv_sr4[0]) | &{cdiv_sr4[6:2]})};

    cpuclk      <= {cpuclk[0], &{cdiv_sr4[6:4]}};
    cpuclk_pcen <= {cpuclk_pcen[0], cdiv_sr4[6:4] == 3'b111};
    cpuclk_ncen <= {cpuclk_ncen[0], cdiv_sr4[6:4] == 3'b110};
end



///////////////////////////////////////////////////////////
//////  Power On Reset
////

assign  RCC.RST_async_n = i_RST_n; //asynchronous master reset

//synchronous master reset
logic   [1:0]   rst_sr0;
assign  RCC.RST_sync_n = rst_sr0[1];
always_ff @(posedge RCC.phiA) if(RCC.phiA_NCEN) rst_sr0 <= {rst_sr0[0], i_RST_n};




endmodule


interface IKA9958_if_rcc;
wire            phiA; //internal master clock
wire            phiA_NCEN; //21.48MHz
wire            phiH_PCEN, phiH_NCEN; //DHCLK, 10.74MHz
wire            phiL_PCEN, phiL_NCEN; //DLCLK, 5.37MHz
wire            RST_async_n;
wire            RST_sync_n;

//clarify directionality
modport drive   (output RST_async_n, RST_sync_n, phiA, phiA_NCEN, phiH_PCEN, phiH_NCEN, phiL_PCEN, phiL_NCEN);
modport source  (input  RST_async_n, RST_sync_n, phiA, phiA_NCEN, phiH_PCEN, phiH_NCEN, phiL_PCEN, phiL_NCEN);
endinterface