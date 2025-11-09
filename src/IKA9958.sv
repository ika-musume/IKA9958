/*
    IKA9958 top module
*/

module IKA9958 #(parameter CM = 0) (
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
    input   wire                i_HRST_n
);



///////////////////////////////////////////////////////////
//////  Interfaces
////

IKA9958_if_rcc  if_rcc();
IKA9958_if_reg  if_reg();
IKA9958_if_st   if_st();



///////////////////////////////////////////////////////////
//////  Reset and Clock Control
////

IKA9958_rcc #(.CM(CM)) u_rcc (
    .i_XTAL1                    (i_XTAL1                    ),
    .o_XTAL2                    (o_XTAL2                    ),
    .i_XTAL_NCEN                (i_XTAL_NCEN                ),

    .i_DLCLK_n                  (i_DLCLK_n                  ),
    .o_DHCLK_n                  (o_DHCLK_n                  ),
    .o_DLCLK_n                  (o_DLCLK_n                  ),

    .i_RST_n                    (i_RST_n                    ),

    .RCC                        (if_rcc                     ),
    .REG                        (if_reg                     ),
    .ST                         (if_st                      )
);



///////////////////////////////////////////////////////////
//////  Registers
////

IKA9958_reg u_reg (
    .RCC                        (if_rcc                     ),
    .REG                        (if_reg                     )
);



///////////////////////////////////////////////////////////
//////  Screen Timing
////

IKA9958_st u_st (
    .i_HRST_n                   (i_HRST_n                   ),

    .RCC                        (if_rcc                     ),
    .REG                        (if_reg                     ),
    .ST                         (if_st                      )
);



endmodule