`default_nettype wire //allow implicit net declaration

module IKA9958_pla (

    /* INTERFACES */
    IKA9958_if_rcc.source       RCC, //reset and clock control
    IKA9958_if_reg.read         REG, //register file(configuration)
    IKA9958_if_st.source        ST,
    IKA9958_if_pla.drive        PLA
);

//common PLA counter
logic   [8:0]   cpc;


///////////////////////////////////////////////////////////
//////  Common PLA
////

/*
    "PLA0" Generates common control signals
*/

//common PLA output, combinational
logic   [55:0]  cpla;

//additional mask
logic           cpc_1e3_z;
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) cpc_1e3_z <= cpla[1];

//define PLA0 outputs
assign  cpla[0]  = cpc[3:0] == 4'd9;
assign  cpla[1]  = cpc      == 9'h1E_3;
assign  cpla[2]  = cpc      == 9'h1F_6 && !REG.TMODE;
assign  cpla[3]  = cpc      == 9'h1E_6;
assign  cpla[4]  = cpc      == 9'h17_7 &&  REG.TMODE;
assign  cpla[5]  = cpc      == 9'h1D_3;
assign  cpla[6]  = cpc      == 9'h12_F && !REG.TMODE;

assign  cpla[7]  = cpc      == 9'h00_0;
assign  cpla[8]  = cpc      == 9'h12_3;
assign  cpla[9]  = cpc      == 9'h14_0;
/* ----------------------------------------------------------- */
assign  cpla[10] = cpc      == 9'h11_3;
assign  cpla[11] = cpc[2:0] == 3'd0    && !(REG.TMODE && cpc[3]); //m8c0
assign  cpla[12] = cpc      == 9'h10_3;
assign  cpla[13] = cpc[2:0] == 3'd1    && !(REG.TMODE && cpc[3]); //m8c1

assign  cpla[14] = cpc[2:0] == 3'd2    && !(REG.TMODE && cpc[3]); //m8c2
assign  cpla[15] = cpc[3:0] == 4'd11;
assign  cpla[16] = cpc[2:0] == 3'd3    && !(REG.TMODE && cpc[3]); //m8c3
assign  cpla[17] = cpc[3:0] == 4'd7;
assign  cpla[18] = cpc[2:0] == 3'd4    && !(REG.TMODE && cpc[3]); //m8c4

assign  cpla[19] = cpc[2:0] == 3'd5    && !(REG.TMODE && cpc[3]); //m8c5
assign  cpla[20] = cpc[3:0] == 4'd4    && !cpc_1e3_z;
assign  cpla[21] = cpc[2:0] == 3'd6    && !(REG.TMODE && cpc[3]); //m8c6
assign  cpla[22] = cpc      == 9'h00_5;
assign  cpla[23] = cpc[2:0] == 3'd7    && !(REG.TMODE && cpc[3]); //m8c7

assign  cpla[24] = cpc[3:0] == 4'd8;                              //m16c8
assign  cpla[25] = cpc      == 9'h1D_A;
assign  cpla[26] = cpc[3:0] == 4'd9;                              //m16c9
/* ----------------------------------------------------------- */
assign  cpla[27] = cpc[3:0] == 4'd10;                             //m16c10
assign  cpla[28] = cpc[3:0] == 4'd11;                             //m16c11
assign  cpla[29] = cpc      == 9'h1E_3;
assign  cpla[30] = cpc      == 9'h10_0;
assign  cpla[31] = cpc      == 9'h1E_B;
assign  cpla[32] = cpc      == 9'h1F_0;
assign  cpla[33] = cpc      == 9'h14_0;
assign  cpla[34] = cpc      == 9'h1D_1;

assign  cpla[35] = cpc      == 9'h1E_B;
assign  cpla[36] = cpc      == 9'h00_0;

assign  cpla[37] = cpc      == 9'h10_8;
assign  cpla[38] = cpc      == 9'h1D_F;

assign  cpla[39] = cpc      == 9'h1E_C;
assign  cpla[40] = cpc      == 9'h0F_F;

assign  cpla[41] = cpc      == 9'h1F_1;
assign  cpla[42] = cpc inside {9'b0_????_?001};
assign  cpla[43] = cpc inside {9'b0_???1_0001};
/* ----------------------------------------------------------- */
assign  cpla[44] = cpc[2:0] == 3'h1;
assign  cpla[45] = cpc inside {9'b0_???1_0100};
assign  cpla[46] = cpc inside {9'b1_00?1_0100};
assign  cpla[47] = cpc inside {9'b1_00??_0111};
assign  cpla[48] = cpc      == 9'h1E_C;
assign  cpla[49] = cpc      == 9'h1D_7;
/* ----------------------------------------------------------- */
assign  cpla[50] = cpc      == 9'h00_0;
assign  cpla[51] = cpc      == 9'h10_0;

assign  cpla[52] = cpc      == 9'h0F_F;
assign  cpla[53] = cpc      == 9'h1F_0;

assign  cpla[54] = cpc      == 9'h1E_E;
assign  cpla[55] = cpc      == 9'h1E_5;

//decoded signals (sync SR latch); default_nettype wire has been declared to sink unused output of the SRlatch modules, nc means a dummy sink
//               name     clk       cen            set        reset      Q         nQ
IKA9958_prim_srl u_gt046 (RCC.phiA, RCC.phiL_NCEN, cpla[3]  , cpla[5]  , gt046   , gt046_nc);
IKA9958_prim_srl u_gt047 (RCC.phiA, RCC.phiL_NCEN, cpla[5]  , cpla[8]  , gt047   , gt047_nc);
IKA9958_prim_srl u_gt048 (RCC.phiA, RCC.phiL_NCEN, cpla[8]  , cpla[10] , gt048   , gt048_nc);
IKA9958_prim_srl u_gt049 (RCC.phiA, RCC.phiL_NCEN, cpla[10] , cpla[12] , gt049   , gt049_nc);
IKA9958_prim_srl u_gt055 (RCC.phiA, RCC.phiL_NCEN, cpla[29] , cpla[30] , gt055   , gt055_nc);
IKA9958_prim_srl u_gt056 (RCC.phiA, RCC.phiL_NCEN, cpla[29] , cpla[31] , gt056   , gt056_nc);
IKA9958_prim_srl u_gt057 (RCC.phiA, RCC.phiL_NCEN, cpla[32] , cpla[31] , gt057   , gt057_nc);
IKA9958_prim_srl u_gt058 (RCC.phiA, RCC.phiL_NCEN, cpla[30] , cpla[32] , gt058   , gt058_nc); //same as the gt059, negative
IKA9958_prim_srl u_gt059 (RCC.phiA, RCC.phiL_PCEN, cpla[30] , cpla[32] , gt059_nc, gt059   ); //same as the gt058, positive
IKA9958_prim_srl u_gt061 (RCC.phiA, RCC.phiL_PCEN, cpla[34] , cpla[33] , gt061   , gt061_nc); //positive!
IKA9958_prim_srl u_gt062 (RCC.phiA, RCC.phiL_PCEN, cpla[36] , cpla[35] , gt062   , gt062_nc); //positive!
IKA9958_prim_srl u_gt063 (RCC.phiA, RCC.phiL_PCEN, cpla[38] , cpla[37] , gt063   , gt063_nc); //positive!
IKA9958_prim_srl u_gt064 (RCC.phiA, RCC.phiL_PCEN, cpla[40] , cpla[39] , gt064   , gt064_nc); //positive!

//decoded signals
logic           cpla_43_z, gt072;
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    //cpc modulo 8, modulo 16
    PLA.cpc.z               <= cpc[3:0];
    PLA.cpc.z_of_m8c[0]     <= cpla[11];
    PLA.cpc.z_of_m8c[1]     <= cpla[13];
    PLA.cpc.z_of_m8c[2]     <= cpla[14];
    PLA.cpc.z_of_m8c[3]     <= cpla[16];
    PLA.cpc.z_of_m8c[4]     <= cpla[18];
    PLA.cpc.z_of_m8c[5]     <= cpla[19];
    PLA.cpc.z_of_m8c[6]     <= cpla[21];
    PLA.cpc.z_of_m8c[7]     <= cpla[23];
    PLA.cpc.z_of_m16c[8]    <= cpla[24];
    PLA.cpc.z_of_m16c[9]    <= cpla[26];
    PLA.cpc.z_of_m16c[10]   <= cpla[27];
    PLA.cpc.z_of_m16c[11]   <= cpla[28];

    gt072 <= (cpla[41] | cpla[42]) & ~cpla[43];
    cpla_43_z <= cpla[43];
end

//decoded signals (combinational)
wire            gt074 = ((gt061 & gt062) | cpc[0]) & ~cpla[45] & ~cpla[46];
wire            gt075 = ~((cpla[41] | cpla[42]) & ~cpla[43]) & ~cpla[47] & ~cpla[48] & ~cpla[49];
wire            gt076 = ~gt072 & ~cpla[47] & ~cpla[48] & ~cpla[49];
wire            gt077 = (gt059 | ~cpla[44]) & (cpc[0] | gt063) & ~gt072 & ~cpla[48];
wire            gt078 = (cpc[0] | gt063) & (cpc[0] | gt064 | cpla_43_z);



///////////////////////////////////////////////////////////
//////  Common PLA Counter
////

/*
    A PLA-dedicated horizontal counter
*/

//Yamaha used upper 5 bits as a tile cycle, and the lower 4 bits as a pixel cycle(12 or 16)

logic           cpc_lo_ld, cpc_hi_ld;
logic           cpc_hi_ci;

logic           hadd_eq23_z, hadd_eq23_long_z;
wire            hadd_eq23_long = ST.hadd_eq23 | hadd_eq23_z;
logic           cpla_0_z, cpla_2_z, gt041_txt_active, gt032_eot_txt_z, gt042;
wire            gt031_eot_txt = gt041_txt_active & (cpla_0_z & ~hadd_eq23_long_z); //gt026 de morgan, posedge DDL combined
wire            gt033 = ~(gt042 | hadd_eq23_long_z);

//SR latches(synchronous); default_nettype wire has been declared to sink unused output of the SRlatch modules, nc means a dummy sink
//               name     clk       cen            set                         reset    Q         nQ
IKA9958_prim_srl u_gt043 (RCC.phiA, RCC.phiL_PCEN, |{cpla[9], hadd_eq23_long}, cpla[7], gt043_nc, gt043   ); //positive! gt043=1 when 0, gt043=0 when 320 or eq23``

always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    hadd_eq23_z <= ST.hadd_eq23;
    hadd_eq23_long_z <= hadd_eq23_long;

    cpla_0_z <= cpla[0]; //EndOfTile, cycle mod16 4'd10
    cpla_2_z <= cpla[2];

    gt041_txt_active <= gt043 & REG.TMODE; //text mode only...
    gt032_eot_txt_z <= gt031_eot_txt;
    gt042 <= ~(cpla[4] | cpla[6]); 
end

assign  cpc_lo_ld = gt033 | cpla_2_z | hadd_eq23_z | gt032_eot_txt_z; //$177 or $12F when not eq23long, $1F6(nontxt), eq23, EndOfTile txt(12px)
assign  cpc_hi_ld = gt033 | cpla_2_z | hadd_eq23_z;

logic           gt044;
logic   [3:0]   gt022_sr4; //Delays EndOfTile(cpla_0) assertion 4 cycles when in graphics mode, to compensate the 16px tile - 12px txt = 4px difference
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    gt044 <= gt041_txt_active;
    gt022_sr4[0] <= cpla_0_z & ~hadd_eq23_long_z; //gt026 de morgan;
    gt022_sr4[1] <= (hadd_eq23_z || gt044) ? 1'b0 : gt022_sr4[0];
    gt022_sr4[2] <= (hadd_eq23_z)          ? 1'b0 : gt022_sr4[1];
    gt022_sr4[3] <= (hadd_eq23_z)          ? 1'b0 : gt022_sr4[2];

    cpc_hi_ci <= gt031_eot_txt | &{~gt041_txt_active, ~hadd_eq23_z, hadd_eq23_z ? 1'b0 : gt022_sr4[3]};
end

//common pla counter
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) cpc <= 9'd0; //the actural chip doesn't have async reset
    else begin if(RCC.phiL_NCEN) begin
        if(cpc_lo_ld) cpc[3:0] <= {2'b00, hadd_eq23_z, hadd_eq23_z | gt033};
        else cpc[3:0] <= cpc[3:0] + 4'd1;

        if(cpc_hi_ld) cpc[8:4] <= {{3{hadd_eq23_z | gt033}}, hadd_eq23_z, gt033};
        else cpc[8:4] <= cpc[8:4] + cpc_hi_ci;
    end end
end



///////////////////////////////////////////////////////////
//////  Memory PLA
////

/*
    "PLA1" Generates DRAM requests
*/





endmodule

`default_nettype none

interface IKA9958_if_pla;

//pack the cpc-related global signal
typedef struct packed {
    logic   [3:0]   z;
    logic   [7:0]   z_of_m8c;
    logic   [11:8]  z_of_m16c;
} cpc_modulo_t;
cpc_modulo_t cpc;


modport drive  (output cpc);
modport source (input  cpc);
endinterface

