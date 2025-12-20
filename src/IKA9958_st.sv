`default_nettype wire //allow implicit net declaration

module IKA9958_st (
    /* RESET INPUT */
    input   logic               i_HRST_n,
    input   logic               i_VRST_n,
    output  logic               o_BLEO_BLK_n, o_BLEO_P_nS, //tri-level logic pin
    output  logic               o_HSYNC_n, o_CSYNC_n,

    /* INTERFACES */
    IKA9958_if_rcc.source       RCC, //reset and clock control
    IKA9958_if_reg.read         REG, //register file(configuration)
    IKA9958_if_st.drive         ST,
    IKA9958_if_pla.source       PLA
);

/*
    IKA9958 Screen Timing
    This module generates all video timing signals
*/

//PLA outputs
logic   [20:0]  hpla;   //horizontal
logic   [27:0]  vpla;   //vertical
logic   [9:0]   vapla;  //vertical-auxiliary



///////////////////////////////////////////////////////////
//////  Horizontal Counter
////

//generate horizontal reset timing
logic           hrst_z, hrst_zz, hpla0_z, hcntr_rst;
assign  hcntr_rst = {hpla0_z | &{hrst_z, ~hrst_zz, vpla[27]}}; //allow external hrst when vpla27 is on OR drive reset with hpla0_z
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) begin //the actural chip doesn't have reset feature
        hrst_z <= 1'b0;
        hrst_zz <= 1'b0;
        hpla0_z <= 1'b0;
    end
    else begin if(RCC.phiL_NCEN) begin
        hrst_z <= ~i_HRST_n;
        hrst_zz <= hrst_z;
        hpla0_z <= hpla[0];
    end end
end

//horizontal counter
logic   [8:0]   hcntr;
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) hcntr <= 9'd0; //the actural chip doesn't have reset feature
    else begin if(RCC.phiL_NCEN) begin
        hcntr <= hcntr_rst ? 9'd0 : hcntr + 9'd1;
    end end
end


///////////////////////////////////////////////////////////
//////  Horizontal Timings
////

//assign PLA outputs
assign  hpla[0]  = hcntr == 9'd339 && !hcntr_rst;
assign  hpla[1]  = hcntr == 9'd21;

assign  hpla[2]  = hcntr == 9'd0;
assign  hpla[3]  = hcntr == 9'd337;
assign  hpla[4]  = hcntr == 9'd9;
assign  hpla[5]  = hcntr == 9'd179;

assign  hpla[6]  = hcntr == 9'd229;
assign  hpla[7]  = hcntr == 9'd0;
/* ---------------------------------------------- */
assign  hpla[8]  = hcntr == 9'd337;
assign  hpla[9]  = hcntr == 9'd166;
assign  hpla[10] = hcntr == 9'd45;
assign  hpla[11] = hcntr == 9'd312;

assign  hpla[12] = hcntr == 9'd328;
assign  hpla[13] = hcntr == 9'd141;
assign  hpla[14] = hcntr >= 9'd328 && hcntr < 9'd332;
assign  hpla[15] = hcntr == 9'd24;
/* ---------------------------------------------- */
assign  hpla[16] = hcntr == 9'd38;
assign  hpla[17] = hcntr == 9'd46;

assign  hpla[18] = hcntr == 9'd330;
assign  hpla[19] = hcntr == 9'd336;
assign  hpla[20] = hcntr == 9'd165;

//decoded signals (sync SR latch); default_nettype wire has been declared to sink unused output of the SRlatch modules, nc means a dummy sink
//               name     clk       cen            set                    reset         Q         nQ
IKA9958_prim_srl u_gc027 (RCC.phiA, RCC.phiL_NCEN, |{hpla[3:2]         }, |{hpla[1]  }, gc027,    gc027_nc);
IKA9958_prim_srl u_gc028 (RCC.phiA, RCC.phiL_NCEN, |{hpla[9:7]         }, |{hpla[5:4]}, gc028_nc, gc028   );
IKA9958_prim_srl u_gc029 (RCC.phiA, RCC.phiL_NCEN, |{hpla[11], hpla[13]}, |{hpla[9:8]}, gc029,    gc029_nc);
IKA9958_prim_srl u_gc030 (RCC.phiA, RCC.phiL_NCEN, |{hpla[16]          }, |{hpla[15] }, gc030_nc, gc030   );
IKA9958_prim_srl u_gc031 (RCC.phiA, RCC.phiL_NCEN, |{hpla[18]          }, |{hpla[17] }, gc031_nc, gc031   );
IKA9958_prim_srl u_gc021 (RCC.phiA, RCC.phiL_PCEN, |{hpla[12]          }, |{hpla[10] }, gc021_nc, gc021   ); //positive!

//decoded signals (reset required)
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) begin
        ST.gc024 <= 1'b0; //the actural chip doesn't have reset feature
    end else begin if(RCC.phiL_NCEN) begin
        ST.gc024 <= (REG.S == 2'd0 ? ~hpla[14] : ~hpla[12]) | REG.FILE[15][6];
    end end
end

//decoded signals
logic           hcntr_230, hcntr_337, hcntr_166;
logic   [8:0]   hadd;
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    hcntr_230    <= hpla[6];
    hcntr_337    <= hpla[19];
    hcntr_166    <= hpla[20];

    hadd         <= hcntr + {{5{REG.H[3]}}, REG.H}; //with sign extension
    ST.hadd_eq23 <= hadd == 9'd23; //gc047
end



///////////////////////////////////////////////////////////
//////  Vertical Counter
////

//vertical counter
logic   [8:0]   vcntr;
logic           vcntr_ci, vcntr_rst;
logic           field; //NTSC field, 0=primary 1=secondary

//synchronize VRST input and make a posedge tick
logic   [1:0]   comcntr_mod16_cyc7_z;
logic   [2:0]   vrst_sync;
logic           vrst_sync_eq7_z, vrst_pdet;
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    comcntr_mod16_cyc7_z <= {comcntr_mod16_cyc7_z[0], PLA.comcntr[3:0] == 4'd7}; //generate a VRST input synchronization tick
    if(comcntr_mod16_cyc7_z[1]) vrst_sync <= {vrst_sync[1:0], ~i_VRST_n}; //VRST synchronizer

    //VRST posedge detector
    vrst_sync_eq7_z <= &{vrst_sync};
    vrst_pdet <= !vrst_sync_eq7_z && &{vrst_sync};
end

//make a field dominance flag
wire            vrst_field_0 = (vpla[2]  | vpla[5]  | vpla[8]  | vpla[11]) & vcntr_ci; //PAL+non-i, PAL+i, NTSC+non-i, NTSC+i
wire            vrst_field_1 = (vpla[14] | vpla[17] | vpla[20] | vpla[23]) & vcntr_ci; //PAL+non-i, PAL+i, NTSC+non-i, NTSC+i
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) field <= 1'b0; //the actural chip doesn't have reset feature
    else begin if(RCC.phiL_NCEN) begin
        field <= vrst_pdet || vrst_field_1 || (!field && !vrst_field_0) ? 1'b0 : 1'b1; //Field dominance
    end end
end

//generate vcounter control signals
assign  vcntr_rst = vrst_pdet || vrst_field_1 || vrst_field_0;
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) vcntr_ci <= hcntr_230; //VCNTR carry in(count enable)

//vertical counter
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) vcntr <= 9'd0; //the actural chip doesn't have reset feature
    else begin if(RCC.phiL_NCEN) begin
        vcntr <= vcntr_rst ? 9'd0 : vcntr + vcntr_ci;
    end end
end



///////////////////////////////////////////////////////////
//////  Vertical Timings
////

//assign PLA outputs
assign  vpla[0]  = vcntr == 9'd0   && !REG.IL &&  REG.NT_n           ;
assign  vpla[1]  = vcntr == 9'd0   && !REG.IL && !REG.NT_n           ;
assign  vpla[2]  = vcntr == 9'd312 && !REG.IL &&  REG.NT_n  && !field;
assign  vpla[3]  = vcntr == 9'd0   &&  REG.IL && !REG.NT_n  && !field; 
assign  vpla[4]  = vcntr == 9'd0   &&  REG.IL &&  REG.NT_n  && !field; 
assign  vpla[5]  = vcntr == 9'd312 &&  REG.IL &&  REG.NT_n  && !field; 
assign  vpla[6]  = vcntr == 9'd312 &&  REG.IL &&  REG.NT_n  && !field; 
assign  vpla[7]  = vcntr == 9'd262 &&  REG.IL && !REG.NT_n  && !field;
assign  vpla[8]  = vcntr == 9'd261 && !REG.IL && !REG.NT_n  && !field;
assign  vpla[9]  = vcntr == 9'd3   && !REG.IL                        ;
assign  vpla[10] = vcntr == 9'd3   &&  REG.IL               && !field;
/* ------------------------------------------------------------------------ */
assign  vpla[11] = vcntr == 9'd262 &&  REG.IL && !REG.NT_n  && !field;
assign  vpla[12] = vcntr == 9'd2   &&  REG.IL               &&  field;
assign  vpla[13] = vcntr == 9'd6   && !REG.IL                        ;
assign  vpla[14] = vcntr == 9'd312 && !REG.IL &&  REG.NT_n  &&  field;
assign  vpla[15] = vcntr == 9'd6   &&  REG.IL               && !field;
assign  vpla[16] = vcntr == 9'd5   &&  REG.IL               &&  field;
assign  vpla[17] = vcntr == 9'd311 &&  REG.IL &&  REG.NT_n  &&  field;
assign  vpla[18] = vcntr == 9'd310 && !REG.IL &&  REG.NT_n           ;
assign  vpla[19] = vcntr == 9'd309 &&  REG.IL &&  REG.NT_n  &&  field;
/* ------------------------------------------------------------------------ */
assign  vpla[20] = vcntr == 9'd261 && !REG.IL && !REG.NT_n  &&  field;
assign  vpla[21] = vcntr == 9'd259 && !REG.IL && !REG.NT_n           ;
assign  vpla[22] = vcntr == 9'd259 &&  REG.IL && !REG.NT_n  &&  field;
assign  vpla[23] = vcntr == 9'd261 &&  REG.IL && !REG.NT_n  &&  field;
assign  vpla[24] = vcntr == 9'd259 &&  REG.IL && !REG.NT_n  && !field;
assign  vpla[25] = vcntr == 9'd309 &&  REG.IL &&  REG.NT_n  && !field;
assign  vpla[26] = vcntr == 9'd16                                    ;
assign  vpla[27] = vcntr == 9'd6                                     ;

//decoded signals
wire            gc078 = (hcntr_337 & |{vpla[0] , vpla[1] , vpla[3] , vpla[4] }) | (hcntr_166 & |{vpla[6] , vpla[7] });
wire            gc079 = (hcntr_337 & |{vpla[9] , vpla[10]                    }) | (hcntr_166 & |{vpla[12]          });
wire            gc080 = (hcntr_337 & |{vpla[13], vpla[15]                    }) | (hcntr_166 & |{vpla[16]          });
wire            gc081 = (hcntr_337 & |{vpla[18], vpla[19], vpla[21], vpla[22]}) | (hcntr_166 & |{vpla[24], vpla[25]});
wire            gc082 = (hcntr_337 &   vpla[26]                               )                                      ;
wire            vadd_eq15 = (vcntr + {{5{REG.V[3]}}, REG.V}) == 9'd15;

//decoded signals (sync SR latch)
//               name     clk       cen            set    reset  Q          nQ
IKA9958_prim_srl u_gc084 (RCC.phiA, RCC.phiL_NCEN, gc079, gc078, gc084    , gc084_nc);
IKA9958_prim_srl u_gc086 (RCC.phiA, RCC.phiL_NCEN, gc081, gc080, gc086    , gc086_nc);
IKA9958_prim_srl u_gc087 (RCC.phiA, RCC.phiL_PCEN, gc082, gc081, gc087    , gc087_nc); //positive!

logic           gc087_z;
always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    ST.gc026 <= gc021 & gc087;
    gc087_z <= gc087;
end


///////////////////////////////////////////////////////////
//////  Vertical-Auxiliary Counter
////

/*
    The vertical counter increases sooner than we expected.
    To align the vertical count with the adjustable horizontal line,
    a "relatively" adjusted vertical auxiliary counter is used.
    As a result, the vertical line indication aligns with the horizontal period.
*/


///////////////////////////////////////////////////////////
//////  Video Sync Generator
////

/*
    I think the CSYNC appears to be correct. The HSYNC behavior is not verified yet.
    See: https://forum.vcfed.org/index.php?threads/composite-sync-question-msx-v9958.1240634/
*/

logic           gc039, gc037, gc041;
always_comb begin
    gc039 = gc030 & gc087_z;

    case({gc086, gc084})
        2'b00: begin gc037 = ~gc027; gc041 =  1'b0 ; end
        2'b01: begin gc037 = ~gc027; gc041 = ~gc027; end
        2'b10: begin gc037 =  gc028; gc041 =  gc029; end
        2'b11: begin gc037 =  gc028; gc041 =  gc028; end
    endcase
end

always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin
    ST.gc026 <= gc021 & gc087;
    gc087_z <= gc087;

    o_BLEO_BLK_n <= gc087_z & gc031; //blank
    o_BLEO_P_nS  <= ~field; //field

    o_HSYNC_n    <= REG.S == 2'd0 ? gc039 : gc037;
    o_CSYNC_n    <= gc041;
end





endmodule

`default_nettype none

interface IKA9958_if_st;
logic           gc024, gc026;
logic           hadd_eq23;

//clarify directionality
modport drive   (output gc024, gc026, hadd_eq23);
modport source  (input  gc024, gc026, hadd_eq23);
endinterface

