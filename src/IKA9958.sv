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
    output  wire                o_DHCLK_n, o_DHCLK_n_PCEN, o_DHCLK_n_NCEN, //open drain output except the CENs
    output  wire                o_DLCLK_n, o_DLCLK_n_PCEN, o_DLCLK_n_NCEN, //open drain output except the CENs
    output  wire                o_CPUCLK_nVDS, o_CPUCLK_nVDS_PCEN, o_CPUCLK_nVDS_NCEN,

    /* VIDEO SYNCS */
    output  wire                o_BLEO_BLK_n, o_BLEO_P_nS, //tri-level logic pin
    output  wire                o_HSYNC_n, o_CSYNC_n,

    /* RESET INPUT */
    input   wire                i_RST_n,
    input   wire                i_HRST_n,
    input   wire                i_VRST_n
);



///////////////////////////////////////////////////////////
//////  Interfaces
////

IKA9958_if_rcc  if_rcc();
IKA9958_if_reg  if_reg();
IKA9958_if_st   if_st();
IKA9958_if_pla  if_pla();



///////////////////////////////////////////////////////////
//////  Reset and Clock Control
////

IKA9958_rcc #(.CM(CM)) u_rcc (
     .i_RST_n
    
    ,.i_XTAL1
    ,.o_XTAL2
    ,.i_XTAL_NCEN

    ,.i_DLCLK_n

    ,.o_DHCLK_n
    ,.o_DHCLK_n_PCEN
    ,.o_DHCLK_n_NCEN
    ,.o_DLCLK_n
    ,.o_DLCLK_n_PCEN
    ,.o_DLCLK_n_NCEN
    ,.o_CPUCLK                  (o_CPUCLK_nVDS              )
    ,.o_CPUCLK_PCEN             (                           )
    ,.o_CPUCLK_NCEN             (                           )

    ,.RCC                       (if_rcc                     )
    ,.REG                       (if_reg                     )
    ,.ST                        (if_st                      )
);



///////////////////////////////////////////////////////////
//////  Registers
////

IKA9958_reg u_reg (
     .RCC                       (if_rcc                     )
    ,.REG                       (if_reg                     )
);



///////////////////////////////////////////////////////////
//////  Screen Timing
////

IKA9958_st u_st (
     .i_HRST_n
    ,.i_VRST_n

    ,.o_BLEO_BLK_n
    ,.o_BLEO_P_nS
    ,.o_HSYNC_n
    ,.o_CSYNC_n

    ,.RCC                       (if_rcc                     )
    ,.REG                       (if_reg                     )
    ,.ST                        (if_st                      )
    ,.PLA                       (if_pla                     )
);



///////////////////////////////////////////////////////////
//////  PLA
////

IKA9958_pla u_pla (
     .RCC                       (if_rcc                     )
    ,.REG                       (if_reg                     )
    ,.ST                        (if_st                      )
    ,.PLA                       (if_pla                     )
);



endmodule