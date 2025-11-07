module IKA9958_st (
    /* INTERFACES */
    IKA9958_if_rcc.source       RCC, //reset and clock control
    IKA9958_if_reg.read         REG, //register file(configuration)
    IKA9958_if_st.drive         ST
);

/*
    IKA9958 Screen Timing
    This module generates all video timing signals
*/

assign  ST.n_gc024 = 1'b1;

endmodule

interface IKA9958_if_st;
wire            n_gc024;

//clarify directionality
modport drive   (output n_gc024);
modport source  (input  n_gc024);
endinterface