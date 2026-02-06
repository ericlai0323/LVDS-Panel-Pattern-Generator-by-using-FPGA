`timescale 1ns / 1ns

module G7_TOP_TB();


reg iOSC = 0;
always #20 iOSC = ~iOSC;


reg iRESET = 0;
reg iSW0 = 0, iSW1 = 0, iSW2 = 0, iSW3 = 0;
reg iBUTTON_0 = 0, iBUTTON_1 = 0, iBUTTON_2 = 0;


G7_TOP uut (
           .iOSC(iOSC),
           .iRESET(iRESET),
           .iSW0(iSW0),
           .iSW1(iSW1),
           .iSW2(iSW2),
           .iSW3(iSW3),
           .iBUTTON_0(iBUTTON_0),
           .iBUTTON_1(iBUTTON_1),
           .iBUTTON_2(iBUTTON_2),

           .oSTB(),
           .A_rx0_p(), .A_rx0_n(), .A_rx1_p(), .A_rx1_n(), .A_rx2_p(), .A_rx2_n(), .A_rx3_p(), .A_rx3_n(), .A_rx4_p(), .A_rx4_n(),
           .A_clkout_p(), .A_clkout_n(),
           .B_rx0_p(), .B_rx0_n(), .B_rx1_p(), .B_rx1_n(), .B_rx2_p(), .B_rx2_n(), .B_rx3_p(), .B_rx3_n(), .B_rx4_p(), .B_rx4_n(),
           .B_clkout_p(), .B_clkout_n(),
           .A2_rx0_p(), .A2_rx0_n(), .A2_rx1_p(), .A2_rx1_n(), .A2_rx2_p(), .A2_rx2_n(), .A2_rx3_p(), .A2_rx3_n(), .A2_rx4_p(), .A2_rx4_n(),
           .A2_clkout_p(), .A2_clkout_n(),
           .B2_rx0_p(), .B2_rx0_n(), .B2_rx1_p(), .B2_rx1_n(), .B2_rx2_p(), .B2_rx2_n(), .B2_rx3_p(), .B2_rx3_n(), .B2_rx4_p(), .B2_rx4_n(),
           .B2_clkout_p(), .B2_clkout_n(),
           .spi_cs_l(),
           .spi_data(),
           .spi_sclk()
       );


initial begin
    #1;
    iRESET = 1;
end


endmodule
