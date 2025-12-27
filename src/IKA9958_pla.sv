`default_nettype wire //allow implicit net declaration

/*
    IKA9958 PLAs
*/

import IKA9958_mnemonics::*;

module IKA9958_pla (

    /* INTERFACES */
    IKA9958_if_rcc.source       RCC, //reset and clock control
    IKA9958_if_reg.read         REG, //register file(configuration)
    IKA9958_if_st.source        ST,
    IKA9958_if_pla.drive        PLA
);

//common PLA counter
logic   [8:0]   bpc;


///////////////////////////////////////////////////////////
//////  Base PLA
////

/*
    "PLA0" Generates base control signals
*/

//base PLA output, combinational
logic   [55:0]  bpla;

//additional mask
wire            txt_mod12_en = REG.Data.M inside {T1, T2} && bpc[3];
logic           bpc_1e3_z;
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) bpc_1e3_z <= bpla[1];

//define PLA0 outputs
assign  bpla[0]  = bpc[3:0] == 4'd9;
assign  bpla[1]  = bpc      == 9'h1E_3;
assign  bpla[2]  = bpc      == 9'h1F_6 && !REG.Data.M inside {T1, T2};
assign  bpla[3]  = bpc      == 9'h1E_6;
assign  bpla[4]  = bpc      == 9'h17_7 &&  REG.Data.M inside {T1, T2};
assign  bpla[5]  = bpc      == 9'h1D_3;
assign  bpla[6]  = bpc      == 9'h12_F && !REG.Data.M inside {T1, T2};

assign  bpla[7]  = bpc      == 9'h00_0;
assign  bpla[8]  = bpc      == 9'h12_3;
assign  bpla[9]  = bpc      == 9'h14_0;
/* ----------------------------------------------------------- */
assign  bpla[10] = bpc      == 9'h11_3;
assign  bpla[11] = bpc[2:0] == 3'd0    && !txt_mod12_en; //m8c0
assign  bpla[12] = bpc      == 9'h10_3;
assign  bpla[13] = bpc[2:0] == 3'd1    && !txt_mod12_en; //m8c1

assign  bpla[14] = bpc[2:0] == 3'd2    && !txt_mod12_en; //m8c2
assign  bpla[15] = bpc[3:0] == 4'd11;
assign  bpla[16] = bpc[2:0] == 3'd3    && !txt_mod12_en; //m8c3
assign  bpla[17] = bpc[3:0] == 4'd7;
assign  bpla[18] = bpc[2:0] == 3'd4    && !txt_mod12_en; //m8c4

assign  bpla[19] = bpc[2:0] == 3'd5    && !txt_mod12_en; //m8c5
assign  bpla[20] = bpc[3:0] == 4'd4    && !bpc_1e3_z;
assign  bpla[21] = bpc[2:0] == 3'd6    && !txt_mod12_en; //m8c6
assign  bpla[22] = bpc      == 9'h00_5;
assign  bpla[23] = bpc[2:0] == 3'd7    && !txt_mod12_en; //m8c7

assign  bpla[24] = bpc[3:0] == 4'd8;                              //m16c8
assign  bpla[25] = bpc      == 9'h1D_A;
assign  bpla[26] = bpc[3:0] == 4'd9;                              //m16c9
/* ----------------------------------------------------------- */
assign  bpla[27] = bpc[3:0] == 4'd10;                             //m16c10
assign  bpla[28] = bpc[3:0] == 4'd11;                             //m16c11
assign  bpla[29] = bpc      == 9'h1E_3;
assign  bpla[30] = bpc      == 9'h10_0;
assign  bpla[31] = bpc      == 9'h1E_B;
assign  bpla[32] = bpc      == 9'h1F_0;
assign  bpla[33] = bpc      == 9'h14_0;
assign  bpla[34] = bpc      == 9'h1D_1;

assign  bpla[35] = bpc      == 9'h1E_B;
assign  bpla[36] = bpc      == 9'h00_0;

assign  bpla[37] = bpc      == 9'h10_8;
assign  bpla[38] = bpc      == 9'h1D_F;

assign  bpla[39] = bpc      == 9'h1E_C;
assign  bpla[40] = bpc      == 9'h0F_F;

assign  bpla[41] = bpc      == 9'h1F_1;
assign  bpla[42] = bpc inside {9'b0_????_?001};
assign  bpla[43] = bpc inside {9'b0_???1_0001};
/* ----------------------------------------------------------- */
assign  bpla[44] = bpc[2:0] == 3'h1;
assign  bpla[45] = bpc inside {9'b0_???1_0100};
assign  bpla[46] = bpc inside {9'b1_00?1_0100};
assign  bpla[47] = bpc inside {9'b1_00??_0111};
assign  bpla[48] = bpc      == 9'h1E_C;
assign  bpla[49] = bpc      == 9'h1D_7;
/* ----------------------------------------------------------- */
assign  bpla[50] = bpc      == 9'h00_0;
assign  bpla[51] = bpc      == 9'h10_0;

assign  bpla[52] = bpc      == 9'h0F_F;
assign  bpla[53] = bpc      == 9'h1F_0;

assign  bpla[54] = bpc      == 9'h1E_E;
assign  bpla[55] = bpc      == 9'h1E_5;

//decoded signals (sync SR latch); default_nettype wire has been declared to sink unused output of the SRlatch modules, nc means a dummy sink
//               name     clk       cen            set        reset      Q         nQ
IKA9958_prim_srl u_gt046 (RCC.phiA, RCC.phiL_NCEN, bpla[3]  , bpla[5]  , gt046   , gt046_nc);
IKA9958_prim_srl u_gt047 (RCC.phiA, RCC.phiL_NCEN, bpla[5]  , bpla[8]  , gt047   , gt047_nc);
IKA9958_prim_srl u_gt048 (RCC.phiA, RCC.phiL_NCEN, bpla[8]  , bpla[10] , gt048   , gt048_nc);
IKA9958_prim_srl u_gt049 (RCC.phiA, RCC.phiL_NCEN, bpla[10] , bpla[12] , gt049   , gt049_nc);
IKA9958_prim_srl u_gt055 (RCC.phiA, RCC.phiL_NCEN, bpla[29] , bpla[30] , gt055   , gt055_nc);
IKA9958_prim_srl u_gt056 (RCC.phiA, RCC.phiL_NCEN, bpla[29] , bpla[31] , gt056   , gt056_nc);
IKA9958_prim_srl u_gt057 (RCC.phiA, RCC.phiL_NCEN, bpla[32] , bpla[31] , gt057   , gt057_nc);
IKA9958_prim_srl u_gt058 (RCC.phiA, RCC.phiL_NCEN, bpla[30] , bpla[32] , gt058   , gt058_nc); //same as the gt059, negative
IKA9958_prim_srl u_gt059 (RCC.phiA, RCC.phiL_PCEN, bpla[30] , bpla[32] , gt059_nc, gt059   ); //same as the gt058, positive
IKA9958_prim_srl u_gt061 (RCC.phiA, RCC.phiL_PCEN, bpla[34] , bpla[33] , gt061   , gt061_nc); //positive!
IKA9958_prim_srl u_gt062 (RCC.phiA, RCC.phiL_PCEN, bpla[36] , bpla[35] , gt062   , gt062_nc); //positive!
IKA9958_prim_srl u_gt063 (RCC.phiA, RCC.phiL_PCEN, bpla[38] , bpla[37] , gt063   , gt063_nc); //positive!
IKA9958_prim_srl u_gt064 (RCC.phiA, RCC.phiL_PCEN, bpla[40] , bpla[39] , gt064   , gt064_nc); //positive!

//decoded signals
logic           bpla_43_z, gt072;
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    //bpc modulo 8, modulo 16
    PLA.Bpc.z         <= bpc[3:0];
    PLA.Bpc.z_cyc[0]  <= bpla[11];
    PLA.Bpc.z_cyc[1]  <= bpla[13];
    PLA.Bpc.z_cyc[2]  <= bpla[14];
    PLA.Bpc.z_cyc[3]  <= bpla[16];
    PLA.Bpc.z_cyc[4]  <= bpla[18];
    PLA.Bpc.z_cyc[5]  <= bpla[19];
    PLA.Bpc.z_cyc[6]  <= bpla[21];
    PLA.Bpc.z_cyc[7]  <= bpla[23];
    PLA.Bpc.z_cyc[8]  <= bpla[24];
    PLA.Bpc.z_cyc[9]  <= bpla[26];
    PLA.Bpc.z_cyc[10] <= bpla[27];
    PLA.Bpc.z_cyc[11] <= bpla[28];

    gt072 <= (bpla[41] | bpla[42]) & ~bpla[43];
    bpla_43_z <= bpla[43];
end

//decoded signals (combinational)
wire            gt074 = ((gt061 & gt062) | bpc[0]) & ~bpla[45] & ~bpla[46];
wire            gt075 = ~((bpla[41] | bpla[42]) & ~bpla[43]) & ~bpla[47] & ~bpla[48] & ~bpla[49];
wire            gt076 = ~gt072 & ~bpla[47] & ~bpla[48] & ~bpla[49];
wire            gt077 = (gt059 | ~bpla[44]) & (bpc[0] | gt063) & ~gt072 & ~bpla[48];
wire            gt078 = (bpc[0] | gt063) & (bpc[0] | gt064 | bpla_43_z);



///////////////////////////////////////////////////////////
//////  Base PLA Counter
////

/*
    A PLA-dedicated horizontal counter
*/

//Yamaha used upper 5 bits as a tile cycle, and the lower 4 bits as a pixel cycle(12 or 16)

logic           bpc_lo_ld, bpc_hi_ld;
logic           bpc_hi_ci;

logic           hadd_eq23_z, hadd_eq23_long_z;
wire            hadd_eq23_long = ST.hadd_eq23 | hadd_eq23_z;
logic           bpla_0_z, bpla_2_z, gt041_txt_active, gt032_eot_txt_z, gt042;
wire            gt031_eot_txt = gt041_txt_active & (bpla_0_z & ~hadd_eq23_long_z); //gt026 de morgan, posedge DDL combined
wire            gt033 = ~(gt042 | hadd_eq23_long_z);

//SR latches(synchronous); default_nettype wire has been declared to sink unused output of the SRlatch modules, nc means a dummy sink
//               name     clk       cen            set                         reset    Q         nQ
IKA9958_prim_srl u_gt043 (RCC.phiA, RCC.phiL_PCEN, |{bpla[9], hadd_eq23_long}, bpla[7], gt043_nc, gt043   ); //positive! gt043=1 when 0, gt043=0 when 320 or eq23``

always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    hadd_eq23_z <= ST.hadd_eq23;
    hadd_eq23_long_z <= hadd_eq23_long;

    bpla_0_z <= bpla[0]; //EndOfTile, cycle mod16 4'd10
    bpla_2_z <= bpla[2];

    gt041_txt_active <= gt043 & REG.Data.M inside {T1, T2}; //text mode only...
    gt032_eot_txt_z <= gt031_eot_txt;
    gt042 <= ~(bpla[4] | bpla[6]); 
end

assign  bpc_lo_ld = gt033 | bpla_2_z | hadd_eq23_z | gt032_eot_txt_z; //$177 or $12F when not eq23long, $1F6(nontxt), eq23, EndOfTile txt(12px)
assign  bpc_hi_ld = gt033 | bpla_2_z | hadd_eq23_z;

logic           gt044;
logic   [3:0]   gt022_sr4; //Delays EndOfTile(bpla_0) assertion 4 cycles when in graphics mode, to compensate the 16px tile - 12px txt = 4px difference
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    gt044 <= gt041_txt_active;
    gt022_sr4[0] <= bpla_0_z & ~hadd_eq23_long_z; //gt026 de morgan;
    gt022_sr4[1] <= (hadd_eq23_z || gt044) ? 1'b0 : gt022_sr4[0];
    gt022_sr4[2] <= (hadd_eq23_z)          ? 1'b0 : gt022_sr4[1];
    gt022_sr4[3] <= (hadd_eq23_z)          ? 1'b0 : gt022_sr4[2];

    bpc_hi_ci <= gt031_eot_txt | &{~gt041_txt_active, ~hadd_eq23_z, hadd_eq23_z ? 1'b0 : gt022_sr4[3]};
end

//common pla counter
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) bpc <= 9'd0; //the actural chip doesn't have async reset
    else begin if(RCC.phiL_NCEN) begin
        if(bpc_lo_ld) bpc[3:0] <= {2'b00, hadd_eq23_z, hadd_eq23_z | gt033};
        else bpc[3:0] <= bpc[3:0] + 4'd1;

        if(bpc_hi_ld) bpc[8:4] <= {{3{hadd_eq23_z | gt033}}, hadd_eq23_z, gt033};
        else bpc[8:4] <= bpc[8:4] + bpc_hi_ci;
    end end
end



///////////////////////////////////////////////////////////
//////  Memory PLA
////

/*
    "PLA1" Generates DRAM requests
*/

//encode the modulo cycle indicators first...
logic   [11:0]  act_cyc_type;
assign  act_cyc_type[0]  = PLA.Bpc.z_m8c  inside {      8'b????_?0??} && !(~|PLA.Bpc.z_m8c ); //in graphic mode, only the modulo 8 is used
assign  act_cyc_type[1]  = PLA.Bpc.z_m8c  inside {      8'b????_0??0} && !(~|PLA.Bpc.z_m8c );
assign  act_cyc_type[2]  = PLA.Bpc.z_m8c  inside {      8'b0??0_??0?} && !(~|PLA.Bpc.z_m8c );
assign  act_cyc_type[3]  = PLA.Bpc.z_m8c  inside {      8'b0?0?_?0??} && !(~|PLA.Bpc.z_m8c );
assign  act_cyc_type[4]  = PLA.Bpc.z_m8c  inside {      8'b0???_????} && !(~|PLA.Bpc.z_m8c );
assign  act_cyc_type[5]  = PLA.Bpc.z_m8c  inside {      8'b0???_0???} && !(~|PLA.Bpc.z_m8c );
assign  act_cyc_type[6]  = PLA.Bpc.z_m8c  inside {      8'b????_???0} && !(~|PLA.Bpc.z_m8c );
assign  act_cyc_type[7]  = PLA.Bpc.z_m8c  inside {      8'b???0_???0} && !(~|PLA.Bpc.z_m8c );
assign  act_cyc_type[8]  = PLA.Bpc.z_m8c  inside {      8'b0???_0000} && !(~|PLA.Bpc.z_m8c );
assign  act_cyc_type[9]  = PLA.Bpc.z_m8c  inside {      8'b????_0000} && !(~|PLA.Bpc.z_m8c );
assign  act_cyc_type[10] = PLA.Bpc.z_m12c inside {12'b0??0_??0?_????} && !(~|PLA.Bpc.z_m12c); //in text mode, the modulo 8 is gated while cycle 8-11
assign  act_cyc_type[11] = PLA.Bpc.z_m12c inside {12'b?0??_0??0_????} && !(~|PLA.Bpc.z_m12c);

//memory PLA output, combinational
logic   [29:0]  mpla;
assign  mpla[0]  = REG.Data.M inside {T1, T2                    } && act_cyc_type[11] &&  gt041_txt_active;
assign  mpla[1]  = REG.Data.M inside {T1, T2                    } && !PLA.Bpc.z[0]    && !gt041_txt_active && gt056; //even
assign  mpla[2]  = REG.Data.M inside {T1, T2                    } && act_cyc_type[10];
//assign  mpla[3]  = REG.Data.M inside {            G4, G5, G6, G7} && 




//assign  mpla[0]  = REG.Data.M inside {T1, T2, G3, G4, G5, G6, G7} && 




endmodule

`default_nettype none

interface IKA9958_if_pla;

//pack the bpc-related global signal
typedef struct packed {
    logic   [3:0]   z;
    logic   [11:0]  z_cyc;
    logic   [11:0]  z_m12c;
    logic   [7:0]   z_m8c;
} BpcModCyc_t;
BpcModCyc_t Bpc;

assign  Bpc.z_m12c = Bpc.z_cyc;
assign  Bpc.z_m8c  = Bpc.z_cyc[7:0];


modport drive  (output Bpc);
modport source (input  Bpc);
endinterface

