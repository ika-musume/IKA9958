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
//////  PLA0
////

logic           cpc_1e3_z;

//PLA outputs
logic   [55:0]  pla0;
assign  pla0[0]  = cpc[3:0] == 4'h9;
assign  pla0[1]  = cpc      == 9'h1E_3;
assign  pla0[2]  = cpc      == 9'h1F_6 && !REG.TMODE;
assign  pla0[3]  = cpc      == 9'h1E_6;
assign  pla0[4]  = cpc      == 9'h17_7 &&  REG.TMODE;
assign  pla0[5]  = cpc      == 9'h1D_3;
assign  pla0[6]  = cpc      == 9'h12_F && !REG.TMODE;

assign  pla0[7]  = cpc      == 9'h00_0;
assign  pla0[8]  = cpc      == 9'h12_3;
assign  pla0[9]  = cpc      == 9'h14_0;
/* ---------------------------------------------- */
assign  pla0[10] = cpc      == 9'h11_3;
assign  pla0[11] = cpc[2:0] == 3'd0    && !(REG.TMODE && cpc[3]); //m8c0
assign  pla0[12] = cpc      == 9'h10_3;
assign  pla0[13] = cpc[2:0] == 3'd1    && !(REG.TMODE && cpc[3]);

assign  pla0[14] = cpc[2:0] == 3'd2    && !(REG.TMODE && cpc[3]);
assign  pla0[15] = cpc[3:0] == 4'd11;
assign  pla0[16] = cpc[2:0] == 3'd3    && !(REG.TMODE && cpc[3]);
assign  pla0[17] = cpc[3:0] == 4'd7;
assign  pla0[18] = cpc[2:0] == 3'd4    && !(REG.TMODE && cpc[3]);

assign  pla0[19] = cpc[2:0] == 3'd5    && !(REG.TMODE && cpc[3]);
assign  pla0[20] = cpc[3:0] == 4'd4    && !cpc_1e3_z;
assign  pla0[21] = cpc[2:0] == 3'd6    && !(REG.TMODE && cpc[3]);
assign  pla0[22] = cpc      == 9'h00_5;
assign  pla0[23] = cpc[2:0] == 3'd7    && !(REG.TMODE && cpc[3]); //m8c7

assign  pla0[24] = cpc[3:0] == 4'd8;                              //m16c8
assign  pla0[25] = cpc      == 9'h1D_A;
assign  pla0[26] = cpc[3:0] == 4'd9;                              //m16c9
/* ---------------------------------------------- */
assign  pla0[27] = cpc[3:0] == 4'd10;                             //m16c10
assign  pla0[28] = cpc[3:0] == 4'd11;                             //m16c11


//decoded signals
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    cpc_1e3_z   <= pla0[1];

    //cpc modulo 8, modulo 16
    PLA.cpc.z               <= cpc[3:0];
    PLA.cpc.z_of_m8c[0]     <= pla0[11];
    PLA.cpc.z_of_m8c[1]     <= pla0[13];
    PLA.cpc.z_of_m8c[2]     <= pla0[14];
    PLA.cpc.z_of_m8c[3]     <= pla0[16];
    PLA.cpc.z_of_m8c[4]     <= pla0[18];
    PLA.cpc.z_of_m8c[5]     <= pla0[19];
    PLA.cpc.z_of_m8c[6]     <= pla0[21];
    PLA.cpc.z_of_m8c[7]     <= pla0[23];
    PLA.cpc.z_of_m16c[8]    <= pla0[24];
    PLA.cpc.z_of_m16c[9]    <= pla0[26];
    PLA.cpc.z_of_m16c[10]   <= pla0[27];
    PLA.cpc.z_of_m16c[11]   <= pla0[28];
end


///////////////////////////////////////////////////////////
//////  Common PLA Counter
////

//Yamaha used upper 5 bits as a tile cycle, and the lower 4 bits as a pixel cycle(12 or 16)

logic           cpc_lo_ld, cpc_hi_ld;
logic           cpc_hi_ci;

logic           hadd_eq23_z, hadd_eq23_long_z;
wire            hadd_eq23_long = ST.hadd_eq23 | hadd_eq23_z;
logic           pla0_0_z, pla0_2_z, gt041_txt_active, gt032_eot_txt_z, gt042;
wire            gt031_eot_txt = gt041_txt_active & (pla0_0_z & ~hadd_eq23_long_z); //gt026 de morgan, posedge DDL combined
wire            gt033 = ~(gt042 | hadd_eq23_long_z);

//SR latches(synchronous); default_nettype wire has been declared to sink unused output of the SRlatch modules, nc means a dummy sink
//               name     clk       cen            set                         reset    Q         nQ
IKA9958_prim_srl u_gt043 (RCC.phiA, RCC.phiL_PCEN, |{pla0[9], hadd_eq23_long}, pla0[7], gt043_nc, gt043   ); //positive! gt043=1 when 0, gt043=0 when 320 or eq23``

always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    hadd_eq23_z <= ST.hadd_eq23;
    hadd_eq23_long_z <= hadd_eq23_long;

    pla0_0_z <= pla0[0]; //EndOfTile, cycle mod16 4'd10
    pla0_2_z <= pla0[2];

    gt041_txt_active <= gt043 & REG.TMODE; //text mode only...
    gt032_eot_txt_z <= gt031_eot_txt;
    gt042 <= ~(pla0[4] | pla0[6]); 
end

assign  cpc_lo_ld = gt033 | pla0_2_z | hadd_eq23_z | gt032_eot_txt_z; //$177 or $12F when not eq23long, $1F6(nontxt), eq23, EndOfTile txt(12px)
assign  cpc_hi_ld = gt033 | pla0_2_z | hadd_eq23_z;

logic           gt044;
logic   [3:0]   gt022_sr4; //Delays EndOfTile(pla0_0) assertion 4 cycles when in graphics mode, to compensate the 16px tile - 12px txt = 4px difference
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    gt044 <= gt041_txt_active;
    gt022_sr4[0] <= pla0_0_z & ~hadd_eq23_long_z; //gt026 de morgan;
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

