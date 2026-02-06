`include "TIMING_SETTING.V"
module G7_TOP(
           input  iOSC,
           input  iRESET,
           input  iSW0,
           input  iSW1,
           input  iSW2,
           input  iSW3,
           input  iBUTTON_0,
           input  iBUTTON_1,
           input  iBUTTON_2,

           output A_rx0_p,
           output A_rx0_n,
           output A_rx1_p,
           output A_rx1_n,
           output A_rx2_p,
           output A_rx2_n,
           output A_rx3_p,
           output A_rx3_n,
           output A_rx4_p,
           output A_rx4_n,

           output B_rx0_p,
           output B_rx0_n,
           output B_rx1_p,
           output B_rx1_n,
           output B_rx2_p,
           output B_rx2_n,
           output B_rx3_p,
           output B_rx3_n,
           output B_rx4_p,
           output B_rx4_n,

           output A_clkout_p,
           output A_clkout_n,

           output B_clkout_p,
           output B_clkout_n,

           output A2_rx0_p,
           output A2_rx0_n,
           output A2_rx1_p,
           output A2_rx1_n,
           output A2_rx2_p,
           output A2_rx2_n,
           output A2_rx3_p,
           output A2_rx3_n,
           output A2_rx4_p,
           output A2_rx4_n,

           output B2_rx0_p,
           output B2_rx0_n,
           output B2_rx1_p,
           output B2_rx1_n,
           output B2_rx2_p,
           output B2_rx2_n,
           output B2_rx3_p,
           output B2_rx3_n,
           output B2_rx4_p,
           output B2_rx4_n,

           output A2_clkout_p,
           output A2_clkout_n,
           output B2_clkout_p,
           output B2_clkout_n,

           output wire oSTB,
           output wire spi_cs_l,
           output wire spi_data,
           output wire spi_sclk
       );

// Transmission data wires for A and B channels
wire [6:0] A_txd_0, A_txd_1, A_txd_2, A_txd_3, A_txd_4;
wire [6:0] B_txd_0, B_txd_1, B_txd_2, B_txd_3, B_txd_4;

// Color data outputs
wire [7:0] oRDATA_86, oGDATA_86, oBDATA_86;

// Color data signals for A and B
wire [7:0] R_data_a, G_data_a, B_data_a;
wire [7:0] R_data_b, G_data_b, B_data_b;

// Temporary color signals for A and B
wire [7:0] R_data_a_t, G_data_a_t, B_data_a_t;
wire [7:0] R_data_b_t, G_data_b_t, B_data_b_t;

// Synchronization and clock signals
wire DE, H_SYNC, V_SYNC, Tclk;

// Clock signals
wire txclk;
wire pixel_clk;
wire not_tx_mmcm_lckd;

assign A_txd_4[6]=1;
assign A_txd_4[5]=1;
assign A_txd_4[4]=1;
assign A_txd_4[3]=1;
assign A_txd_4[2]=1;
assign A_txd_4[1]=1;
assign A_txd_4[0]=1;

assign B_txd_4[6]=1;
assign B_txd_4[5]=1;
assign B_txd_4[4]=1;
assign B_txd_4[3]=1;
assign B_txd_4[2]=1;
assign B_txd_4[1]=1;
assign B_txd_4[0]=1;

//JEIDA format.
`ifdef JEIDA

assign A_txd_0[6]=R_data_a[2];
assign A_txd_0[5]=R_data_a[3];
assign A_txd_0[4]=R_data_a[4];
assign A_txd_0[3]=R_data_a[5];
assign A_txd_0[2]=R_data_a[6];
assign A_txd_0[1]=R_data_a[7];
assign A_txd_0[0]=G_data_a[2];

assign A_txd_1[6]=G_data_a[3];
assign A_txd_1[5]=G_data_a[4];
assign A_txd_1[4]=G_data_a[5];
assign A_txd_1[3]=G_data_a[6];
assign A_txd_1[2]=G_data_a[7];
assign A_txd_1[1]=B_data_a[2];
assign A_txd_1[0]=B_data_a[3];

assign A_txd_2[6]=B_data_a[4];
assign A_txd_2[5]=B_data_a[5];
assign A_txd_2[4]=B_data_a[6];
assign A_txd_2[3]=B_data_a[7];
assign A_txd_2[2]=H_SYNC;
assign A_txd_2[1]=V_SYNC;
assign A_txd_2[0]=DE;

assign A_txd_3[6]=R_data_a[0];
assign A_txd_3[5]=R_data_a[1];
assign A_txd_3[4]=G_data_a[0];
assign A_txd_3[3]=G_data_a[1];
assign A_txd_3[2]=B_data_a[0];
assign A_txd_3[1]=B_data_a[1];
assign A_txd_3[0]=1;

assign B_txd_0[6]=R_data_b[2];
assign B_txd_0[5]=R_data_b[3];
assign B_txd_0[4]=R_data_b[4];
assign B_txd_0[3]=R_data_b[5];
assign B_txd_0[2]=R_data_b[6];
assign B_txd_0[1]=R_data_b[7];
assign B_txd_0[0]=G_data_b[2];

assign B_txd_1[6]=G_data_b[3];
assign B_txd_1[5]=G_data_b[4];
assign B_txd_1[4]=G_data_b[5];
assign B_txd_1[3]=G_data_b[6];
assign B_txd_1[2]=G_data_b[7];
assign B_txd_1[1]=B_data_b[2];
assign B_txd_1[0]=B_data_b[3];

assign B_txd_2[6]=B_data_b[4];
assign B_txd_2[5]=B_data_b[5];
assign B_txd_2[4]=B_data_b[6];
assign B_txd_2[3]=B_data_b[7];
assign B_txd_2[2]=H_SYNC;
assign B_txd_2[1]=V_SYNC;
assign B_txd_2[0]=DE;

assign B_txd_3[6]=R_data_b[0];
assign B_txd_3[5]=R_data_b[1];
assign B_txd_3[4]=G_data_b[0];
assign B_txd_3[3]=G_data_b[1];
assign B_txd_3[2]=B_data_b[0];
assign B_txd_3[1]=B_data_b[1];
assign B_txd_3[0]=1;
`endif

//VESA format.
`ifdef  VESA

assign A_txd_0[6]=R_data_a[0];
assign A_txd_0[5]=R_data_a[1];
assign A_txd_0[4]=R_data_a[2];
assign A_txd_0[3]=R_data_a[3];
assign A_txd_0[2]=R_data_a[4];
assign A_txd_0[1]=R_data_a[5];
assign A_txd_0[0]=G_data_a[0];

assign A_txd_1[6]=G_data_a[1];
assign A_txd_1[5]=G_data_a[2];
assign A_txd_1[4]=G_data_a[3];
assign A_txd_1[3]=G_data_a[4];
assign A_txd_1[2]=G_data_a[5];
assign A_txd_1[1]=B_data_a[0];
assign A_txd_1[0]=B_data_a[1];

assign A_txd_2[6]=B_data_a[2];
assign A_txd_2[5]=B_data_a[3];
assign A_txd_2[4]=B_data_a[4];
assign A_txd_2[3]=B_data_a[5];
assign A_txd_2[2]=H_SYNC;
assign A_txd_2[1]=V_SYNC;
assign A_txd_2[0]=DE;

assign A_txd_3[6]=R_data_a[6];
assign A_txd_3[5]=R_data_a[7];
assign A_txd_3[4]=G_data_a[6];
assign A_txd_3[3]=G_data_a[7];
assign A_txd_3[2]=B_data_a[6];
assign A_txd_3[1]=B_data_a[7];
assign A_txd_3[0]=1;

assign B_txd_0[6]=R_data_b[0];
assign B_txd_0[5]=R_data_b[1];
assign B_txd_0[4]=R_data_b[2];
assign B_txd_0[3]=R_data_b[3];
assign B_txd_0[2]=R_data_b[4];
assign B_txd_0[1]=R_data_b[5];
assign B_txd_0[0]=G_data_b[0];

assign B_txd_1[6]=G_data_b[1];
assign B_txd_1[5]=G_data_b[2];
assign B_txd_1[4]=G_data_b[3];
assign B_txd_1[3]=G_data_b[4];
assign B_txd_1[2]=G_data_b[5];
assign B_txd_1[1]=B_data_b[0];
assign B_txd_1[0]=B_data_b[1];

assign B_txd_2[6]=B_data_b[2];
assign B_txd_2[5]=B_data_b[3];
assign B_txd_2[4]=B_data_b[4];
assign B_txd_2[3]=B_data_b[5];
assign B_txd_2[2]=H_SYNC;
assign B_txd_2[1]=V_SYNC;
assign B_txd_2[0]=DE;

assign B_txd_3[6]=R_data_b[6];
assign B_txd_3[5]=R_data_b[7];
assign B_txd_3[4]=G_data_b[6];
assign B_txd_3[3]=G_data_b[7];
assign B_txd_3[2]=B_data_b[6];
assign B_txd_3[1]=B_data_b[7];
assign B_txd_3[0]=1;
`endif

wire LDCLK,T_DE,T_HS,T_VS;

top5x2_7to1_sdr_tx U0_0(
                       .Atxd0				(A_txd_0),
                       .Atxd1				(A_txd_1),
                       .Atxd2				(A_txd_2),
                       .Atxd3				(A_txd_3),
                       .Atxd4				(A_txd_4),
                       .Btxd0				(B_txd_0),
                       .Btxd1				(B_txd_1),
                       .Btxd2				(B_txd_2),
                       .Btxd3				(B_txd_3),
                       .Btxd4				(B_txd_4),
                       .freqgen_p			(LDCLK),

                       .reset				(~iRESET),
                       .clkout1_p			(A_clkout_p),
                       .clkout1_n			(A_clkout_n),
                       .dataoutA0_p		(A_rx0_p),
                       .dataoutA0_n		(A_rx0_n),
                       .dataoutA1_p		(A_rx1_p),
                       .dataoutA1_n		(A_rx1_n),
                       .dataoutA2_p		(A_rx2_p),
                       .dataoutA2_n		(A_rx2_n),
                       .dataoutA3_p		(A_rx3_p),
                       .dataoutA3_n		(A_rx3_n),
                       .dataoutA4_p		(A_rx4_p),
                       .dataoutA4_n		(A_rx4_n),
                       .clkout2_p			(B_clkout_p),
                       .clkout2_n			(B_clkout_n),
                       .dataoutB0_p		(B_rx0_p),
                       .dataoutB0_n		(B_rx0_n),
                       .dataoutB1_p		(B_rx1_p),
                       .dataoutB1_n		(B_rx1_n),
                       .dataoutB2_p		(B_rx2_p),
                       .dataoutB2_n		(B_rx2_n),
                       .dataoutB3_p		(B_rx3_p),
                       .dataoutB3_n		(B_rx3_n),
                       .dataoutB4_p		(B_rx4_p),
                       .dataoutB4_n		(B_rx4_n),
                       .txclk				(txclk),
                       .pixel_clk			(pixel_clk),
                       .not_tx_mmcm_lckd	(not_tx_mmcm_lckd)
                   ) ;

top5x2_7to1_sdr_tx_WO_clkgen U0_1(
                                 .Atxd0				(A_txd_0),
                                 .Atxd1				(A_txd_1),
                                 .Atxd2				(A_txd_2),
                                 .Atxd3				(A_txd_3),
                                 .Atxd4				(A_txd_4),
                                 .Btxd0				(B_txd_0),
                                 .Btxd1				(B_txd_1),
                                 .Btxd2				(B_txd_2),
                                 .Btxd3				(B_txd_3),
                                 .Btxd4				(B_txd_4),
                                 //.freqgen_p			(LDCLK),

                                 .reset				(~iRESET),
                                 .clkout1_p			(A2_clkout_p),
                                 .clkout1_n			(A2_clkout_n),
                                 .dataoutA0_p		(A2_rx0_p),
                                 .dataoutA0_n		(A2_rx0_n),
                                 .dataoutA1_p		(A2_rx1_p),
                                 .dataoutA1_n		(A2_rx1_n),
                                 .dataoutA2_p		(A2_rx2_p),
                                 .dataoutA2_n		(A2_rx2_n),
                                 .dataoutA3_p		(A2_rx3_p),
                                 .dataoutA3_n		(A2_rx3_n),
                                 .dataoutA4_p		(A2_rx4_p),
                                 .dataoutA4_n		(A2_rx4_n),
                                 .clkout2_p			(B2_clkout_p),
                                 .clkout2_n			(B2_clkout_n),
                                 .dataoutB0_p		(B2_rx0_p),
                                 .dataoutB0_n		(B2_rx0_n),
                                 .dataoutB1_p		(B2_rx1_p),
                                 .dataoutB1_n		(B2_rx1_n),
                                 .dataoutB2_p		(B2_rx2_p),
                                 .dataoutB2_n		(B2_rx2_n),
                                 .dataoutB3_p		(B2_rx3_p),
                                 .dataoutB3_n		(B2_rx3_n),
                                 .dataoutB4_p		(B2_rx4_p),
                                 .dataoutB4_n		(B2_rx4_n),
                                 .txclk				(txclk),
                                 .pixel_clk			(pixel_clk),
                                 .not_tx_mmcm_lckd	(not_tx_mmcm_lckd)


                             ) ;


PANELCTRL	U1(	.iRESET(iRESET),.iOSC(iOSC),
              .iBUTTON_0(iBUTTON_0),.iBUTTON_1(iBUTTON_1),.iBUTTON_2(iBUTTON_2),
              .iSW0(iSW0),.iSW1(iSW1),.iSW2(iSW2),.iSW3(iSW3),

              .oDCLK(Tclk),.oFIN_PLL(),.oFBIN_PLL(),
              .oVSYNC(T_VS),.oHSYNC(T_HS),.oDE(T_DE),
              .oRDATA_86(oRDATA_86),.oGDATA_86(oGDATA_86),.oBDATA_86(oBDATA_86),
              .oSTB(oSTB),
              .spi_cs_l(spi_cs_l), .spi_data(spi_data), .spi_sclk(spi_sclk));


two_prt		U2( .iRESET(iRESET),.iclk(Tclk),
             .oclk(DCLK),.two_port_sel(`two_prt_sel),.iSW3(iSW3),
             .iRDATA_86(oRDATA_86),.iGDATA_86(oGDATA_86),.iBDATA_86(oBDATA_86),
             .iDE(T_DE),.iHS(T_HS),.iVS(T_VS),
             .R_data_a(R_data_a),
             .G_data_a(G_data_a),
             .B_data_a(B_data_a),
             .R_data_b(R_data_b),
             .G_data_b(G_data_b),
             .B_data_b(B_data_b),
             .oDE(DE),.oHS(H_SYNC),.oVS(V_SYNC));

BUFG			U3(.I(DCLK), .O(LDCLK));
endmodule
