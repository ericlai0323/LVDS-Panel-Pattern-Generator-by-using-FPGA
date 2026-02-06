`include "TIMING_SETTING.V"
module PANELCTRL(
           input iRESET,
           input iOSC,
           input iBUTTON_0,
           input iBUTTON_1,
           input iBUTTON_2,
           input iSW0,
           input iSW1,
           input iSW2,
           input iSW3,
           output oDCLK,
           output oFIN_PLL,
           output oFBIN_PLL,
           output reg oVSYNC,
           output reg oHSYNC,
           output reg oDE,
           output [7:0] oRDATA_86,
           output [7:0] oGDATA_86,
           output [7:0] oBDATA_86,
           output oTEST0,
           output oTEST1,
           output oTEST2,
           output oTEST3,
           output oTEST4,
           output oTEST5,
           output oTEST6,
           output oTEST7,
           output oTEST8,
           output oTEST9,
           output oSTB,
           output spi_cs_l,
           output spi_data,
           output spi_sclk
       );

// Register variables
reg [7:0]                       oRDATA;
reg [7:0]                       oGDATA;
reg [7:0]                       oBDATA;
reg                             OSC12MHz;                 // 12 MHz oscillator register
reg [3:0]                       conunter_1_5625_MHz;     // Counter for 1.5625 MHz frequency

// Wire (combinational signal) variables
wire                            wVSYNC;                   // Vertical sync signal
wire                            wHSYNC;                   // Horizontal sync signal
wire                            wDE;                      // Data Enable signal
wire                            wDE_STATE;                // Data Enable state
wire                            wGRAY_FLICKER_EN;         // Gray flicker enable

wire [21:0]                     wX_COORD;                 // X coordinate
wire [21:0]                     wY_COORD;                 // Y coordinate

wire [7:0]                      wPAT_RDATA;               // Pattern red data
wire [7:0]                      wPAT_GDATA;               // Pattern green data
wire [7:0]                      wPAT_BDATA;               // Pattern blue data
wire [7:0]                      wGRAY_RDATA;              // Gray scale red data
wire [7:0]                      wGRAY_GDATA;              // Gray scale green data
wire [7:0]                      wGRAY_BDATA;              // Gray scale blue data
wire [7:0]                      wIS_RDATA;                // Image signal red data
wire [7:0]                      wIS_GDATA;                // Image signal green data
wire [7:0]                      wIS_BDATA;                // Image signal blue data

wire [7:0]                      wBTN0_CNT;                // Button 0 count
wire [7:0]                      wBTN1_CNT;                // Button 1 count
wire [7:0]                      wBTN2_CNT;                // Button 2 count

wire [3:0]                      wDIPSW_STATE;             // DIP switch state

wire [7:0]                      wONEsec_COUNTS;           // 1 second counter
wire                            wAUTO_PAT_EN;             // Auto pattern enable
wire [1:0]                      wFRAME_RATE;              // Frame rate

wire                            UDLR;                     // Up/Down/Left/Right control
wire                            OSC_25;                   // 25 Hz oscillator signal




assign wDIPSW_STATE = {iSW3,iSW2,iSW1,iSW0};
assign oTEST0 = 1'bz;		// U/D, no function, UDLR replace
assign oTEST1 = 1'bz;		// L/R, no function, UDLR replace
assign oTEST2 = 1'bz;
assign oTEST3 = 1'bz;

assign oTEST4 = (UDLR==1'b1)? 1'bz : 1'bz; //control UDLR use one pin
assign oTEST5 = 1'bz;
assign oTEST6 = 1'bz;
assign oTEST7 = 1'bz;
assign oTEST8 = 1'bz;
assign oTEST9 = 1'bz;
assign oSTB = 1'b1; //for C123

assign wAUTO_PAT_EN = (wDIPSW_STATE[0] == 1) ? 1'b1 : 1'b0;
//assign wGRAY_FLICKER_EN = (wDIPSW_STATE == 4'b1000) ? 1'b1 : 1'b0;
assign wGRAY_FLICKER_EN = 0;

wire  iCLK_PLL;
wire  clk_out;
wire  iOSC_PCLK_60HZ, iOSC_PCLK_50HZ;


`ifdef BIT8
assign oRDATA_86 = oRDATA;
assign oGDATA_86 = oGDATA;
assign oBDATA_86 = oBDATA;
`endif

`ifdef BIT6
assign oRDATA_86 = {2'b00,oRDATA[7:2]};
assign oGDATA_86 = {2'b00,oGDATA[7:2]};
assign oBDATA_86 = {2'b00,oBDATA[7:2]};
`endif


//--------------------------------------------
// PLL Control Module
//--------------------------------------------
clk_wiz_0   	clk_wiz_0(.reset(~iRESET),.clk_in1(iOSC),.clk_out1(iOSC_PCLK_60HZ),.clk_out2(iOSC_PCLK_50HZ),.clk_out3(OSC_25));

always@(posedge OSC_25 or negedge iRESET) begin
    if(!iRESET) begin
        OSC12MHz<=1'b0;
        conunter_1_5625_MHz<= 1'b0;
    end
    else begin
        OSC12MHz<=~OSC12MHz; //12.5MHz
        conunter_1_5625_MHz <= conunter_1_5625_MHz + 4'd1;
    end
end

assign OSC_1_5625MHz = conunter_1_5625_MHz[3];

assign clk_out=(wFRAME_RATE==2'd1)?iOSC_PCLK_50HZ:iOSC_PCLK_60HZ;

//assign oDCLK = ~clk_out;

assign oDCLK = (wDIPSW_STATE[3] == 1'b1) ? clk_out : ~clk_out;

assign iCLK_PLL = clk_out;

//--------------------------------------------
// TIMING Control Module
//--------------------------------------------
TIMING uTIMING (
           .irst       (iRESET),
           .iclk       (iCLK_PLL),
           .ovsync     (wVSYNC),
           .ohsync     (wHSYNC),
           .ode        (wDE),
           .ox_coord   (wX_COORD),
           .oy_coord   (wY_COORD),
           .ode_state  (wDE_STATE)
       );

//--------------------------------------------
// Pattern selection
//--------------------------------------------

(* DONT_TOUCH = "TRUE" *) wire [21:0] wPAT_X_COORD,wPAT_Y_COORD; // For Debuging

PATTERNSEL uPATTERNSEL (
               .iOSC          (OSC12MHz),
               .iclk          (iCLK_PLL),
               .irst          (iRESET),
               .mode          (wDIPSW_STATE[2:1]),
               .ide_state     (wDE_STATE), // Pipeline Input
               .ipat_num      (wBTN0_CNT),
               .inv_pat_num  (wBTN1_CNT),
               .ix_coord     (wX_COORD), // Pipeline Input
               .iy_coord     (wY_COORD), // Pipeline Input
               .ivs          (wVSYNC), // Pipeline Input
               .ihs         (wHSYNC), // Pipeline Input
               .ide         (wDE), // Pipeline Input
               .iauto_run   (wAUTO_PAT_EN),
               .iauto_count (wONEsec_COUNTS),
               .ode         (wPAT_DE), // Pipeline Output
               .ohs         (wPAT_HS), // Pipeline Output
               .ovs         (wPAT_VS), // Pipeline Output
               .ox_coord    (wPAT_X_COORD), // Pipeline Output
               .oy_coord    (wPAT_Y_COORD), // Pipeline Output
               .ordata       (wPAT_RDATA),
               .ogdata       (wPAT_GDATA),
               .obdata       (wPAT_BDATA),
               .oframe_rate (wFRAME_RATE),
               .oUD_RL       (UDLR)
           );




//--------------------------------------------
// Pipeline: PATTERNSEL to Color Output
//--------------------------------------------

reg[21:0] pp_PAT_X_COORD, pp_PAT_Y_COORD;
reg pp_PAT_DE, pp_PAT_HS, pp_PAT_VS;
reg[7:0] pp_PAT_RDATA, pp_PAT_GDATA, pp_PAT_BDATA;

always @(posedge iCLK_PLL or negedge iRESET) begin
    if(!iRESET) begin
        pp_PAT_VS <= 0;
        pp_PAT_HS <= 0;
        pp_PAT_DE <= 0;
        pp_PAT_X_COORD <= 22'd0;
        pp_PAT_Y_COORD <= 22'd0;
        pp_PAT_RDATA <= 8'd0;
        pp_PAT_GDATA <= 8'd0;
        pp_PAT_BDATA <= 8'd0;

    end
    else begin
        pp_PAT_VS <= wPAT_VS;
        pp_PAT_HS <= wPAT_HS;
        pp_PAT_DE <= wPAT_DE;
        pp_PAT_X_COORD <= wPAT_X_COORD;
        pp_PAT_Y_COORD <= wPAT_Y_COORD;
        pp_PAT_RDATA <= wPAT_RDATA;
        pp_PAT_GDATA <= wPAT_GDATA;
        pp_PAT_BDATA <= wPAT_BDATA;
    end
end

//--------------------------------------------
// Button Module
//--------------------------------------------
BUTTON uBUTTON (
           .irst        (iRESET),
           .iclk        (iCLK_PLL),
           .ivsync      (wVSYNC),
           .ibtn_0     (iBUTTON_0),
           .ibtn_1     (iBUTTON_1),
           .ibtn_2     (iBUTTON_2),
           .obtn0_index(wBTN0_CNT),
           .obtn1_index(wBTN1_CNT),
           .obtn2_index(wBTN2_CNT)
       );

//--------------------------------------------
// counter tick
//--------------------------------------------
COUNTER	uCOUNTER(.irst(iRESET),.iclk(iCLK_PLL),.ivsync(wVSYNC),.oCount_1s(wONEsec_COUNTS));
//--------------------------------------------


//--------------------------------------------
// Conrtol color data output by DIP switch
//--------------------------------------------
always@(posedge iCLK_PLL or negedge iRESET) begin
    if(!iRESET) begin
        oRDATA <= 8'd0;
        oGDATA <= 8'd0;
        oBDATA <= 8'd0;
        oVSYNC <= 1'b0;
        oHSYNC <= 1'b0;
        oDE <= 1'b0;
    end
    else begin
        case(wDIPSW_STATE)
            4'b0000:	// default
            begin
                oRDATA <= pp_PAT_RDATA;
                oGDATA <= pp_PAT_GDATA;
                oBDATA <= pp_PAT_BDATA;
                oVSYNC <= pp_PAT_VS;
                oHSYNC <= pp_PAT_HS;
                oDE <= pp_PAT_DE;
            end

            4'b0001:	// AUTO PATTERN
            begin
                oRDATA <= pp_PAT_RDATA;
                oGDATA <= pp_PAT_GDATA;
                oBDATA <= pp_PAT_BDATA;
                oVSYNC <= pp_PAT_VS;
                oHSYNC <= pp_PAT_HS;
                oDE <= pp_PAT_DE;
            end

            default: begin
                oRDATA <= pp_PAT_RDATA;
                oGDATA <= pp_PAT_GDATA;
                oBDATA <= pp_PAT_BDATA;
                oVSYNC <= pp_PAT_VS;
                oHSYNC <= pp_PAT_HS;
                oDE <= pp_PAT_DE;
            end

        endcase
    end
end
endmodule
