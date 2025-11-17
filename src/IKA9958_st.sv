`default_nettype wire //allow implicit net declaration

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
//////  Horizontal Counter
////

//generate horizontal reset timing
logic           hrst_z, hrst_zz, hpla0_z;
wire            hcntr_rst;
assign  hcntr_rst = {hpla0_z | &{hrst_z, ~hrst_zz, vpla[27]}}; //allow external hrst when vpla27 is on OR drive reset with hpla0_z
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) begin //the actural chip doesn't have async reset
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
reg     [8:0]   hcntr;
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) hcntr <= 9'd0; //the actural chip doesn't have async reset
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

//SR latches(synchronous); default_nettype wire has been declared to sink unused output of the SRlatch modules
//                   name     clk       cen            set                    reset         Q         nQ
IKA9958_prim_srlatch u_gc027 (RCC.phiA, RCC.phiL_NCEN, |{hpla[3:2]         }, |{hpla[1]  }, gc027,    gc027_nc);
IKA9958_prim_srlatch u_gc028 (RCC.phiA, RCC.phiL_NCEN, |{hpla[9:7]         }, |{hpla[5:4]}, gc028_nc, gc028   );
IKA9958_prim_srlatch u_gc029 (RCC.phiA, RCC.phiL_NCEN, |{hpla[11], hpla[13]}, |{hpla[9:8]}, gc029,    gc029_nc);
IKA9958_prim_srlatch u_gc030 (RCC.phiA, RCC.phiL_NCEN, |{hpla[16]          }, |{hpla[15] }, gc030_nc, gc030   );
IKA9958_prim_srlatch u_gc031 (RCC.phiA, RCC.phiL_NCEN, |{hpla[18]          }, |{hpla[17] }, gc031_nc, gc031   );
IKA9958_prim_srlatch u_gc021 (RCC.phiA, RCC.phiL_PCEN, |{hpla[12]          }, |{hpla[10] }, gc021_nc, gc021   ); //positive!

//decoded signals (reset required)
always_ff @(posedge RCC.phiA `ifdef IKA9958_SYNC_RST ) `else or negedge RCC.RST_async_n) begin `endif
    if(!RCC.RST_async_n) begin
        ST.gc024 <= 1'b0; //the actural chip doesn't have async reset
    end else begin if(RCC.phiL_NCEN) begin
        ST.gc024 <= (REG.regfile[9][5:4] == 2'd0 ? ~hpla[14] : ~hpla[12]) | REG.regfile[15][6];
    end end
end

always_ff @(posedge RCC.phiA) if(RCC.phiL_NCEN) begin

end




endmodule

`default_nettype none

interface IKA9958_if_st;
logic           gc024;

//clarify directionality
modport drive   (output gc024);
modport source  (input  gc024);
endinterface

