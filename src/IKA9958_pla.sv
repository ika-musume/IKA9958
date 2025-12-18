`default_nettype wire //allow implicit net declaration

module IKA9958_pla (

    /* INTERFACES */
    IKA9958_if_rcc.source       RCC, //reset and clock control
    IKA9958_if_reg.read         REG, //register file(configuration)
    IKA9958_if_st.source        ST
    //IKA9958_if_pla.drive        PLA
);


import IKA9958_mnemonics::*;

///////////////////////////////////////////////////////////
//////  Common PLA
////

//common PLA counter
logic   [8:0]   comcntr;
wire            comcntr_lo_ld, comcntr_hi_ld;
logic           comcntr_hi_ci;

//PLA outputs
wire    [55:0]  pla0;

assign  pla0[0]  = comcntr[3:0] == 4'h9;
assign  pla0[2]  = comcntr      == 9'h1F_6 && !(REG.M == T1 || REG.M == T2); //non-txtmode
assign  pla0[4]  = comcntr      == 9'h17_7 &&  (REG.M == T1 || REG.M == T2); //txtmode
assign  pla0[6]  = comcntr      == 9'h12_F && !(REG.M == T1 || REG.M == T2); //non-txtmode
assign  pla0[7]  = comcntr      == 9'h00_0;

assign  pla0[9]  = comcntr      == 9'h14_0;
/* ---------------------------------------------- */



///////////////////////////////////////////////////////////
//////  Common PLA Counter
////

logic           hadd_eq23_z, hadd_eq23_long_z;
wire            hadd_eq23_long = ST.hadd_eq23 | hadd_eq23_z;
logic           pla0_0_z, pla0_2_z, txt_active, gt032, gt042;
wire            gt031 = txt_active & (pla0_0_z & ~hadd_eq23_long_z); //gt026 de morgan, posedge DDL combined
wire            gt033 = ~(gt042 | hadd_eq23_long_z);

//SR latches(synchronous); default_nettype wire has been declared to sink unused output of the SRlatch modules, nc means a dummy sink
//               name     clk       cen            set                         reset         Q         nQ
IKA9958_prim_srl u_gt043 (RCC.phiA, RCC.phiL_PCEN, |{pla0[9], hadd_eq23_long}, |{pla0[7]  }, gt043_nc, gt043   ); //positive! gt043=1 when 0, gt043=0 when 320 or eq23``

always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    hadd_eq23_z <= ST.hadd_eq23;
    hadd_eq23_long_z <= hadd_eq23_long;

    pla0_0_z <= pla0[0];
    pla0_2_z <= pla0[2];

    txt_active <= gt043 & (REG.M == T1 || REG.M == T2); //gt041 text mode only...
    gt032 <= gt031;
    gt042 <= ~(pla0[4] | pla0[6]); 
end

assign  comcntr_lo_ld = gt033 | pla0_2_z | hadd_eq23_z | gt032; //375 or 303 when not eq23long, 502(nontxt), eq23, txtmode?
assign  comcntr_hi_ld = gt033 | pla0_2_z | hadd_eq23_z;

logic           gt044;
logic   [3:0]   gt022_sr4; //compensates the 16px tile - 12px txt = 4px difference
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    gt044 <= txt_active;
    gt022_sr4[0] <= pla0_0_z & ~hadd_eq23_long_z; //gt026 de morgan;
    gt022_sr4[1] <= (hadd_eq23_z || gt044) ? 1'b0 : gt022_sr4[0];
    gt022_sr4[2] <= (hadd_eq23_z)          ? 1'b0 : gt022_sr4[1];
    gt022_sr4[3] <= (hadd_eq23_z)          ? 1'b0 : gt022_sr4[2];

    comcntr_hi_ci <= gt031 | &{~txt_active, ~hadd_eq23_z, hadd_eq23_z ? 1'b0 : gt022_sr4[3]};
end

//common pla
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) comcntr <= 9'd0; //the actural chip doesn't have async reset
    else begin if(RCC.phiL_NCEN) begin
        if(comcntr_lo_ld) comcntr[3:0] <= {2'b00, hadd_eq23_z, hadd_eq23_z | gt033};
        else comcntr[3:0] <= comcntr[3:0] + 4'd1;

        if(comcntr_hi_ld) comcntr[8:4] <= {{3{hadd_eq23_z | gt033}}, hadd_eq23_z, gt033};
        else comcntr[8:4] <= comcntr[8:4] + comcntr_hi_ci;
    end end
end



endmodule

`default_nettype none

interface IKA9958_if_pla;

//clarify directionality
//modport drive   (output );
//modport source  (input  );
endinterface

