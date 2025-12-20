/*
    IKA9958 CPU Interface
*/

module IKA9958_ci (
    /* CPU BUS CONTROL INPUTS */
    input   logic       [1:0]   i_MODE,
    input   logic               i_CSR_n, i_CSW_n,

    /* INTERFACES */
    IKA9958_if_rcc.drive        RCC, //reset and clock control
    IKA9958_if_reg.read         REG, //register file(configuration)
    IKA9958_if_st.source        ST
);

endmodule