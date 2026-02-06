`include "TIMING_SETTING.V"

module PATTERNSEL(
           input                   iOSC,
           input                   iclk,
           input                   mode,
           input                   irst,
           input                   ide_state, // 1 clock cycle ahead of the DE signal
           input [7:0]             ipat_num,
           input [7:0]             inv_pat_num,
           input [21:0]            ix_coord,
           input [21:0]            iy_coord,
           input                   ivs,
           input                   ihs,
           input                   ide,
           input                   iauto_run,
           input [7:0]             iauto_count,

           output reg              ode,
           output reg              ohs,
           output reg              ovs,
           output reg [21:0]       ox_coord,
           output reg [21:0]       oy_coord,

           output reg [7:0]        ordata,
           output reg [7:0]        ogdata,
           output reg [7:0]        obdata,

           output reg [1:0]        oframe_rate,
           output reg              oUD_RL
       );

// Pattern and count registers
reg [7:0]   h_pattern_reg;
reg [7:0]   pattern_count;
reg [7:0]   last_pat_num;
reg [7:0]   last_inv_pat_num;
reg [7:0]   last_auto_count;

// Response counters and flags
reg [8:0]   response_count;
reg         response_flag;

reg [9:0]   response_count_1s;
reg [9:0]   response_count_5s;
reg [9:0]   response_count_10s;

reg         response_flag_1s;
reg         response_flag_5s;
reg         response_flag_10s;

// Condition registers for various tests
reg            wCondition_CHESS;

reg            wCondition_BORDER;

reg            wCondition_WINDOW;
reg            wCondition_WINDOW2;

reg            wCondition_CROSSTALK1;
reg            wCondition_CROSSTALK2;

reg            wCondition_VBW;
reg            wCondition_HBW;

reg            wCondition_FLICKER_DOT;
reg            wCondition_FLICKER_1L2D;
reg            wCondition_FLICKER_2L1D;
reg            wCondition_FLICKER_2L2D;
reg            wCondition_FLICKER_COLUMN;

reg [7:0]     wCondition_FLICKER;

reg           wFLICKER_X;

reg [7:0]     wCondition_VGRAY;
reg [7:0]     wCondition_HGRAY;

// Font index
reg [3:0]     wFONTH_INDEX_X;
reg [3:0]     wFONTH_INDEX_Y;

// VSync shift register and flag
reg [1:0]     vsync_sr;
reg           vs_rising;

// Pressure and touch panel conditions
reg           wPressure_ConditionX;
reg           wPressure_ConditionY;
reg           wTP_ConditionP1;
reg           wTP_ConditionP2;
reg           wTP_ConditionP3;
reg           wTP_ConditionP4;

// Lock-related timers
reg [7:0]   LOCK_T0, LOCK_T1, LOCK_T2, LOCK_T3, LOCK_T4, LOCK_T5, LOCK_T6, LOCK_T7, LOCK_T8, LOCK_T9;
reg [7:0]   LOCK_T10, LOCK_T11, LOCK_T12, LOCK_T13, LOCK_T14, LOCK_T15, LOCK_T16, LOCK_T17, LOCK_T18, LOCK_T19;
reg [7:0]   LOCK_T20, LOCK_T21, LOCK_T22, LOCK_T23, LOCK_T24, LOCK_T25, LOCK_T26, LOCK_T27, LOCK_T28, LOCK_T29;

reg [7:0]   LOCK_TIME;
reg [7:0]   LOCK_COUNT;

reg         LOCK_RST;

// Timing counters and clocks
reg [24:0]  div_count;
reg         CLK_1HZ;
reg         CLK_2HZ;

// Additional pattern and gray level counters
reg [7:0]   wpattern_count;  // Zman add
reg [7:0]   gray_level_count; // Zman add

// Numeric position variables
reg [7:0]   Num_X2;
reg [7:0]   Num_Y2;
reg [7:0]   Num_X1;
reg [7:0]   Num_Y1;
reg [7:0]   Num_X;
reg [7:0]   Num_Y;

// Condition number counts
reg [9:0]   Num_Condition2;
reg [9:0]   Num_Condition1;
reg [9:0]   Num_Condition;

//--------------------------------------------
// HGRAY LUT
//--------------------------------------------
wire [7:0]hgray_data;
reg [22:0]hgray_x_coord;
GRAY_LUT #(
             .GRAY_RESOLUTION(`H_PIXEL))
         HGRAY_LUT
         (
             .clk(iclk),
             .rstn(irst),
             .coord(hgray_x_coord),
             .gray_data(hgray_data)
         );

//--------------------------------------------
// VGRAY LUT
//--------------------------------------------
wire [7:0]vgray_data;
reg [22:0]vgray_y_coord;
GRAY_LUT #(
             .GRAY_RESOLUTION(`V_PIXEL))
         VGRAY_LUT
         (
             .clk(iclk),
             .rstn(irst),
             .coord(vgray_y_coord),
             .gray_data(vgray_data)
         );




//--------------------------------------------
// Pipeline Stage 0: Input Buffer
//--------------------------------------------

reg [21:0] x_s0, y_s0;
reg de_s0, hs_s0, vs_s0;
reg de_state_s0;

always @(posedge iclk or negedge irst) begin
    if(!irst) begin
        x_s0 <= 22'd0;
        y_s0 <= 22'd0;
        de_s0 <= 1'd0;
        hs_s0 <= 1'd0;
        vs_s0 <= 1'd0;
        de_state_s0 <= 1'd0;
    end
    else begin
        x_s0 <= ix_coord;
        y_s0 <= iy_coord;
        de_s0 <= ide;
        hs_s0 <= ihs;
        vs_s0 <= ivs;
        de_state_s0 <= ide_state;
    end
end

//--------------------------------------------
// Pipeline Stage 1: Pre-processing
//--------------------------------------------
reg [21:0] x_s1, y_s1;
reg de_s1, hs_s1, vs_s1;
reg de_state_s1;

reg border1_s1, border2_s1;

localparam WINDOW_V_TH1 = `V_PIXEL / 3;
localparam WINDOW_V_TH2 = `V_PIXEL - (`V_PIXEL / 3);
localparam WINDOW_H_TH1 = `H_PIXEL / 3;
localparam WINDOW_H_TH2 = `H_PIXEL - (`H_PIXEL / 3);

reg window1_s1, window2_s1, window_s1;

reg ix_even_s1, ix_div4_s1;
reg iy_even_s1, iy_div4_s1;

reg [3:0]ix_rem_s1, iy_rem_s1;

always @(posedge iclk or negedge irst) begin
    if(!irst) begin
        x_s1 <= 22'd0;
        y_s1 <= 22'd0;
        de_s1 <= 1'd0;
        hs_s1 <= 1'd0;
        vs_s1 <= 1'd0;
        de_state_s1 <= 0;
        border1_s1 <= 0;
        border2_s1 <= 0;
        window1_s1 <= 0;
        window2_s1 <= 0;
        window_s1 <= 0;
        ix_even_s1 <= 1'b0;
        ix_div4_s1 <= 1'b0;
        iy_even_s1 <= 1'b0;
        iy_div4_s1 <= 1'b0;

        ix_rem_s1 <= 1'b0;
        iy_rem_s1 <= 1'b0;
    end
    else begin
        x_s1 <= x_s0;
        y_s1 <= y_s0;
        de_s1 <= de_s0;
        hs_s1 <= hs_s0;
        vs_s1 <= vs_s0;
        de_state_s1 <= de_state_s0;

        // Border Pattern
        border1_s1 <= (y_s0 == 0) || (x_s0 == 0);
        border2_s1 <= (y_s0 == (`V_PIXEL-1)) || (x_s0 == (`H_PIXEL-1));
        // border_s1 <= border1_s1 || border2_s1;

        // Window Pattern
        window1_s1 <= (y_s0 >= WINDOW_V_TH1) && (y_s0 < WINDOW_V_TH2);
        window2_s1 <= (x_s0 >= WINDOW_H_TH1) && (x_s0 < WINDOW_H_TH2);
        // window_s1  <= window1_s1 && window2_s1;

        // Replace %2 %4
        ix_even_s1 <= ~x_s0[0];                  // (ix % 2)==0 -> wCondition_VBW
        ix_div4_s1 <= (x_s0[1:0] == 2'b00);      // (ix % 4)==0 -> wCondition_VBW_2
        iy_even_s1 <= ~y_s0[0];                  // (iy % 2)==0 -> wCondition_HBW
        iy_div4_s1 <= (y_s0[1:0] == 2'b00);      // (iy % 4)==0 ->

        ix_rem_s1 <= x_s0 % 8;
        iy_rem_s1 <= y_s0 % 8;
    end
end

//--------------------------------------------
// Pipeline Stage 2: Complex Calculation
//--------------------------------------------
localparam HPIX_10   = `H_PIXEL/10;
localparam HPIX_16   = `H_PIXEL/16;
localparam VPIX_10   = `V_PIXEL/10;
localparam VPIX_16   = `V_PIXEL/16;

reg [21:0] x_s2, y_s2;
reg de_s2, hs_s2, vs_s2;
reg de_state_s2;

reg border_s2, window_s2;

reg ix_even_s2, ix_div4_s2;
reg iy_even_s2, iy_div4_s2;

reg chessx_s2, chessy_s2, chess_s2;

reg flicker_dot_s2;
reg flicker_1L2D_s2, flicker_2L1D_s2, flicker_2L2D_s2, flicker_column_s2;

reg crosstalk1_s2, crosstalk2_s2;

reg press_x_s2, press_y_s2;

reg tp_p1_s2, tp_p2_s2, tp_p3_s2, tp_p4_s2;

reg [3:0]ix_rem_s2, iy_rem_s2;
always @(posedge iclk or negedge irst) begin
    if(!irst) begin
        x_s2 <= 22'd0;
        y_s2 <= 22'd0;
        de_s2 <= 1'd0;
        hs_s2 <= 1'd0;
        vs_s2 <= 1'd0;
        de_state_s2 <= 0;

        border_s2 <= 0;
        window_s2 <= 0;
        ix_even_s2 <= 1'b0;
        ix_div4_s2 <= 1'b0;
        iy_even_s2 <= 1'b0;
        iy_div4_s2 <= 1'b0;

        chessx_s2 <= 0;
        chessy_s2 <= 0;
        chess_s2 <= 0;

        flicker_dot_s2 <= 0;
        flicker_1L2D_s2 <= 0;
        flicker_2L1D_s2 <= 0;
        flicker_2L2D_s2 <= 0;
        flicker_column_s2 <= 0;

        crosstalk1_s2 <= 0;
        crosstalk2_s2 <= 0;

        press_x_s2 <= 0;
        press_y_s2 <= 0;

        tp_p1_s2 <= 0;
        tp_p2_s2 <= 0;
        tp_p3_s2 <= 0;
        tp_p4_s2 <= 0;

        ix_rem_s2 <= 0;
        iy_rem_s2 <= 0;
    end
    else begin
        x_s2 <= x_s1;
        y_s2 <= y_s1;
        de_s2 <= de_s1;
        hs_s2 <= hs_s1;
        vs_s2 <= vs_s1;
        de_state_s2 <= de_state_s1;

        // From stage 1
        border_s2 <= border1_s1 || border2_s1;
        window_s2 <= window1_s1 && window2_s1;
        ix_even_s2 <= ix_even_s1;
        ix_div4_s2 <= ix_div4_s1;
        iy_even_s2 <= iy_even_s1;
        iy_div4_s2 <= iy_div4_s1;

        // CHESS Pattern
        chessx_s2 <= ((x_s1 < (1*HPIX_10))) ||
                  ((x_s1 >= (2*HPIX_10)) && (x_s1 < (3*HPIX_10))) ||
                  ((x_s1 >= (4*HPIX_10)) && (x_s1 < (5*HPIX_10))) ||
                  ((x_s1 >= (6*HPIX_10)) && (x_s1 < (7*HPIX_10))) ||
                  ((x_s1 >= (8*HPIX_10)) && (x_s1 < (9*HPIX_10)));

        chessy_s2 <= ((y_s1 < (1*VPIX_10))) ||
                  ((y_s1 >= (2*VPIX_10)) && (y_s1 < (3*VPIX_10))) ||
                  ((y_s1 >= (4*VPIX_10)) && (y_s1 < (5*VPIX_10))) ||
                  ((y_s1 >= (6*VPIX_10)) && (y_s1 < (7*VPIX_10))) ||
                  ((y_s1 >= (8*VPIX_10)) && (y_s1 < (9*VPIX_10)));

        chess_s2 <= chessx_s2 ^ chessy_s2;

        // Flicker Pattern
        flicker_dot_s2   <= ix_even_s1 ^ iy_even_s1;     // wCondition_FLICKER_DOT = wCondition_VBW ^ wCondition_HBW;
        flicker_1L2D_s2  <= ix_even_s1 ^ iy_even_s1;     // wCondition_FLICKER_1L2D = wCondition_VBW_1 ^ wCondition_HBW_1;
        flicker_2L1D_s2  <= ix_div4_s1 ^ iy_even_s1;     // wCondition_FLICKER_2L1D = wCondition_VBW_2 ^ wCondition_HBW_2;
        flicker_2L2D_s2  <= ix_div4_s1 ^ iy_even_s1;     // wCondition_FLICKER_2L2D = wCondition_VBW_3 ^ wCondition_HBW_3;
        flicker_column_s2 <= ix_even_s1 ^ 1'b1;          // wCondition_FLICKER_COLUMN = wCondition_VBW_4 ^ wCondition_HBW_4;

        // Crosstalk
        crosstalk1_s2 <= ix_even_s1;      // (ix % 2) == 0
        crosstalk2_s2 <= ~ix_even_s1;     // (ix % 2) == 1

        // Pressure
        press_x_s2 <= (x_s1 == (1*HPIX_16)) || (x_s1 == (2*HPIX_16)) || (x_s1 == (3*HPIX_16)) ||
                   (x_s1 == (4*HPIX_16)) || (x_s1 == (5*HPIX_16)) || (x_s1 == (6*HPIX_16)) ||
                   (x_s1 == (7*HPIX_16)) || (x_s1 == (8*HPIX_16)) || (x_s1 == (9*HPIX_16)) ||
                   (x_s1 == (10*HPIX_16))|| (x_s1 == (11*HPIX_16))|| (x_s1 == (12*HPIX_16))||
                   (x_s1 == (13*HPIX_16))|| (x_s1 == (14*HPIX_16))|| (x_s1 == (15*HPIX_16))||
                   (x_s1 == (16*HPIX_16));
        press_y_s2 <= (y_s1 == (1*VPIX_16)) || (y_s1 == (2*VPIX_16)) || (y_s1 == (3*VPIX_16)) ||
                   (y_s1 == (4*VPIX_16)) || (y_s1 == (5*VPIX_16)) || (y_s1 == (6*VPIX_16)) ||
                   (y_s1 == (7*VPIX_16)) || (y_s1 == (8*VPIX_16)) || (y_s1 == (9*VPIX_16)) ||
                   (y_s1 == (10*VPIX_16))|| (y_s1 == (11*VPIX_16))|| (y_s1 == (12*VPIX_16))||
                   (y_s1 == (13*VPIX_16))|| (y_s1 == (14*VPIX_16))|| (y_s1 == (15*VPIX_16))||
                   (y_s1 == (16*VPIX_16));

        // TP 四角
        tp_p1_s2 <= (x_s1 >= 0 && x_s1 < 192) && (y_s1 >= 0 && y_s1 < 72);
        tp_p2_s2 <= (x_s1 >= (`H_PIXEL-192) && x_s1 < (`H_PIXEL)) && (y_s1 >= 0 && y_s1 < 72);
        tp_p3_s2 <= (x_s1 >= 0 && x_s1 < 192) && (y_s1 >= (`V_PIXEL-72) && y_s1 < (`V_PIXEL));
        tp_p4_s2 <= (x_s1 >= (`H_PIXEL-192) && x_s1 < (`H_PIXEL)) && (y_s1 >= (`V_PIXEL-72) && y_s1 < (`V_PIXEL));

        ix_rem_s2 <= ix_rem_s1;
        iy_rem_s2 <= iy_rem_s1;
    end
end

//--------------------------------------------
// Pipeline Stage 3: Require Gray ROM Data
//--------------------------------------------
reg [21:0] x_s3, y_s3;
reg de_s3, hs_s3, vs_s3;
reg de_state_s3;

reg border_s3, window_s3;

reg ix_even_s3, ix_div4_s3;
reg iy_even_s3, iy_div4_s3;

reg chess_s3;

reg flicker_dot_s3;
reg flicker_1L2D_s3, flicker_2L1D_s3, flicker_2L2D_s3, flicker_column_s3;

reg crosstalk1_s3, crosstalk2_s3;

reg press_x_s3, press_y_s3;

reg tp_p1_s3, tp_p2_s3, tp_p3_s3, tp_p4_s3;

reg [7:0]hgray_s3, vgray_s3;

reg [3:0]ix_rem_s3, iy_rem_s3;
always @(posedge iclk or negedge irst) begin
    if(!irst) begin
        x_s3 <= 22'd0;
        y_s3 <= 22'd0;
        de_s3 <= 1'd0;
        hs_s3 <= 1'd0;
        vs_s3 <= 1'd0;
        de_state_s3 <= 0;

        border_s3 <= 0;
        window_s3 <= 0;
        ix_even_s3 <= 0;
        ix_div4_s3 <= 0;
        iy_even_s3 <= 0;
        iy_div4_s3 <= 0;
        chess_s3 <= 0;
        flicker_dot_s3 <= 0;
        flicker_1L2D_s3 <= 0;
        flicker_2L1D_s3 <= 0;
        flicker_2L2D_s3 <= 0;
        flicker_column_s3 <= 0;
        crosstalk1_s3 <= 0;
        crosstalk2_s3 <= 0;
        press_x_s3 <= 0;
        press_y_s3 <= 0;
        tp_p1_s3 <= 0;
        tp_p2_s3 <= 0;
        tp_p3_s3 <= 0;
        tp_p4_s3 <= 0;

        hgray_s3 <= 8'd0;
        vgray_s3 <= 8'd0;

        ix_rem_s3 <= 0;
        iy_rem_s3 <= 0;
    end
    else begin
        x_s3 <= x_s2;
        y_s3 <= y_s2;
        de_s3 <= de_s2;
        hs_s3 <= hs_s2;
        vs_s3 <= vs_s2;
        de_state_s3 <= de_state_s2;

        border_s3 <= border_s2;
        window_s3 <= window_s2;
        ix_even_s3 <= ix_even_s2;
        ix_div4_s3 <= ix_div4_s2;
        iy_even_s3 <= iy_even_s2;
        iy_div4_s3 <= iy_div4_s2;
        chess_s3 <= chess_s2;
        flicker_dot_s3 <= flicker_dot_s2;
        flicker_1L2D_s3 <= flicker_1L2D_s2;
        flicker_2L1D_s3 <= flicker_2L1D_s2;
        flicker_2L2D_s3 <= flicker_2L2D_s2;
        flicker_column_s3 <= flicker_column_s2;
        crosstalk1_s3 <= crosstalk1_s2;
        crosstalk2_s3 <= crosstalk2_s2;
        press_x_s3 <= press_x_s2;
        press_y_s3 <= press_y_s2;
        tp_p1_s3 <= tp_p1_s2;
        tp_p2_s3 <= tp_p2_s2;
        tp_p3_s3 <= tp_p3_s2;
        tp_p4_s3 <= tp_p4_s2;

        // --- HGRAY Logic ---
        hgray_x_coord <= x_s2;

        // --- VGRAY Logic ---
        vgray_y_coord <= y_s2;

        ix_rem_s3 <= ix_rem_s2;
        iy_rem_s3 <= iy_rem_s2;
    end
end

//--------------------------------------------
// Pipeline Stage 4: Final Alignment
//--------------------------------------------

reg [21:0] x_s4, y_s4;
reg de_s4, hs_s4, vs_s4;
reg de_state_s4;

reg border_s4, window_s4;

reg ix_even_s4, ix_div4_s4;
reg iy_even_s4, iy_div4_s4;

reg chess_s4;

reg flicker_dot_s4;
reg flicker_1L2D_s4, flicker_2L1D_s4, flicker_2L2D_s4, flicker_column_s4;

reg crosstalk1_s4, crosstalk2_s4;

reg press_x_s4, press_y_s4;

reg tp_p1_s4, tp_p2_s4, tp_p3_s4, tp_p4_s4;

reg [7:0]  vgray_s4, hgray_s4;

reg [3:0]ix_rem_s4, iy_rem_s4;
always @(posedge iclk or negedge irst) begin
    if(!irst) begin

        x_s4 <= 22'd0;
        y_s4 <= 22'd0;
        de_s4 <= 1'd0;
        hs_s4 <= 1'd0;
        vs_s4 <= 1'd0;
        de_state_s4 <= 0;

        border_s4 <= 0;
        window_s4 <= 0;
        ix_even_s4 <= 0;
        ix_div4_s4 <= 0;
        iy_even_s4 <= 0;
        iy_div4_s4 <= 0;
        chess_s4 <= 0;
        flicker_dot_s4 <= 0;
        flicker_1L2D_s4 <= 0;
        flicker_2L1D_s4 <= 0;
        flicker_2L2D_s4 <= 0;
        flicker_column_s4 <= 0;
        crosstalk1_s4 <= 0;
        crosstalk2_s4 <= 0;
        press_x_s4 <= 0;
        press_y_s4 <= 0;
        tp_p1_s4 <= 0;
        tp_p2_s4 <= 0;
        tp_p3_s4 <= 0;
        tp_p4_s4 <= 0;

        vgray_s4 <= 0;
        hgray_s4 <= 0;

        ix_rem_s4 <= 0;
        iy_rem_s4 <= 0;
    end
    else begin

        x_s4 <= x_s3;
        y_s4 <= y_s3;
        de_s4 <= de_s3;
        hs_s4 <= hs_s3;
        vs_s4 <= vs_s3;
        de_state_s4 <= de_state_s3;

        border_s4 <= border_s3;
        window_s4 <= window_s3;
        ix_even_s4 <= ix_even_s3;
        ix_div4_s4 <= ix_div4_s3;
        iy_even_s4 <= iy_even_s3;
        iy_div4_s4 <= iy_div4_s3;
        chess_s4 <= chess_s3;
        flicker_dot_s4 <= flicker_dot_s3;
        flicker_1L2D_s4 <= flicker_1L2D_s3;
        flicker_2L1D_s4 <= flicker_2L1D_s3;
        flicker_2L2D_s4 <= flicker_2L2D_s3;
        flicker_column_s4 <= flicker_column_s3;
        crosstalk1_s4 <= crosstalk1_s3;
        crosstalk2_s4 <= crosstalk2_s3;
        press_x_s4 <= press_x_s3;
        press_y_s4 <= press_y_s3;
        tp_p1_s4 <= tp_p1_s3;
        tp_p2_s4 <= tp_p2_s3;
        tp_p3_s4 <= tp_p3_s3;
        tp_p4_s4 <= tp_p4_s3;

        hgray_s4 <= hgray_data;
        vgray_s4 <= vgray_data;

        ix_rem_s4 <= ix_rem_s3;
        iy_rem_s4 <= iy_rem_s3;
    end
end

//--------------------------------------------
// For Output Coordinate Alignment
//--------------------------------------------
always @(posedge iclk or negedge irst) begin
    if(!irst) begin
        ox_coord <= 22'd0;
        oy_coord <= 22'd0;

    end
    else begin
        ox_coord <= x_s4;
        oy_coord <= y_s4;
    end
end



always @(*) begin
    ode = de_s4;
    ohs = hs_s4;
    ovs = vs_s4;

    wFONTH_INDEX_X = ix_rem_s4;
    wFONTH_INDEX_Y = iy_rem_s4;

    wCondition_BORDER   = border_s4;
    wCondition_WINDOW   = window_s4;
    wCondition_CHESS    = chess_s4;
    wCondition_VGRAY    = vgray_s4;
    wCondition_HGRAY    = hgray_s4;
    wCondition_CROSSTALK1 = crosstalk1_s4;
    wCondition_CROSSTALK2 = crosstalk2_s4;

    wCondition_VBW = ix_even_s4;
    wCondition_HBW = iy_even_s4;

    wCondition_FLICKER_DOT = flicker_dot_s4;
    wCondition_FLICKER_2L1D = flicker_2L1D_s4;
    wCondition_FLICKER_2L2D = flicker_2L2D_s4;
    wCondition_FLICKER_COLUMN = flicker_column_s4;

    wPressure_ConditionX = press_x_s4;
    wPressure_ConditionY = press_y_s4;

    wTP_ConditionP1 = tp_p1_s4;
    wTP_ConditionP2 = tp_p2_s4;
    wTP_ConditionP3 = tp_p3_s4;
    wTP_ConditionP4 = tp_p4_s4;
end



always@(pattern_count or mode) begin
    case(mode)
        2'b10:
            wpattern_count<=`COLOR_8G8C;
        2'b01:
            wpattern_count<=`FLICKER_PAT_DOT;
        default:
            wpattern_count<=pattern_count;
    endcase

end

// 1s
always@(posedge vs_s3 or negedge irst) begin
    if(!irst) begin
        response_flag_1s <= 1'b0;
        response_count_1s <= 10'd0;
    end
    else begin
        if(response_count_1s >= 10'd60) // 1*2 - 1
        begin
            response_count_1s <= 10'd0;
            response_flag_1s <= ~response_flag_1s;
        end
        else
            response_count_1s <= response_count_1s + 10'd1;

    end
end

// 5s
always@(posedge vs_s3 or negedge irst) begin
    if(!irst) begin
        response_flag_5s <= 1'b0;
        response_count_5s <= 10'd0;
    end
    else begin
        if(response_count_5s >= 10'd300) // 5*2-1
        begin
            response_count_5s <= 10'd0;
            response_flag_5s <= ~response_flag_5s;
        end
        else
            response_count_5s <= response_count_5s + 10'd1;
    end
end

// 10s
always@(posedge vs_s3 or negedge irst) begin
    if(!irst) begin
        response_flag_10s <= 1'b0;
        response_count_10s <= 10'd0;
    end
    else begin
        if(response_count_10s >= 10'd600) // 10*2-1
        begin
            response_count_10s <= 10'd0;
            response_flag_10s <= ~response_flag_10s;
        end
        else
            response_count_10s <= response_count_10s + 10'd1;
    end
end

//lock time
//12.5MHz to 2Hz
always@(posedge iOSC or negedge irst) begin
    if(!irst) begin
        div_count <= 25'd0;
        CLK_2HZ <= 1'b0;

    end
    else begin
        if(div_count==25'd3125000) begin
            div_count <= 8'd0;
            CLK_2HZ <= ~CLK_2HZ;
        end
        else
            div_count <= div_count+1;

    end
end

always@(posedge CLK_2HZ or negedge irst) begin
    if(!irst) begin
        CLK_1HZ <= 1'b0;

    end
    else begin
        CLK_1HZ <= ~CLK_1HZ;

    end
end

always@(posedge CLK_2HZ or negedge LOCK_RST) begin
    if(!irst || !LOCK_RST) begin
        LOCK_COUNT <= 8'd0;
    end
    else begin
        if(LOCK_COUNT == 8'd255)
            LOCK_COUNT <= 8'd0;
        else
            LOCK_COUNT <= LOCK_COUNT+1;
    end
end

always @(posedge iclk or negedge irst) begin
    if(!irst) begin
        LOCK_T0 <= `sLOCK_T0;
        LOCK_T1 <= `sLOCK_T1;
        LOCK_T2 <= `sLOCK_T2;
        LOCK_T3 <= `sLOCK_T3;
        LOCK_T4 <= `sLOCK_T4;
        LOCK_T5 <= `sLOCK_T5;
        LOCK_T6 <= `sLOCK_T6;
        LOCK_T7 <= `sLOCK_T7;
        LOCK_T8 <= `sLOCK_T8;
        LOCK_T9 <= `sLOCK_T9;

        LOCK_T10 <= `sLOCK_T10;
        LOCK_T11 <= `sLOCK_T11;
        LOCK_T12 <= `sLOCK_T12;
        LOCK_T13 <= `sLOCK_T13;
        LOCK_T14 <= `sLOCK_T14;
        LOCK_T15 <= `sLOCK_T15;
        LOCK_T16 <= `sLOCK_T16;
        LOCK_T17 <= `sLOCK_T17;
        LOCK_T18 <= `sLOCK_T18;
        LOCK_T19 <= `sLOCK_T19;

        LOCK_T20 <= `sLOCK_T20;
        LOCK_T21 <= `sLOCK_T21;
        LOCK_T22 <= `sLOCK_T22;
        LOCK_T23 <= `sLOCK_T23;
        LOCK_T24 <= `sLOCK_T24;
        LOCK_T25 <= `sLOCK_T25;
        LOCK_T26 <= `sLOCK_T26;
        LOCK_T27 <= `sLOCK_T27;
        LOCK_T28 <= `sLOCK_T28;
        LOCK_T29 <= `sLOCK_T29;
    end
    else
    case(pattern_count)
        8'd0:
            LOCK_TIME <= LOCK_T0;
        8'd1:
            LOCK_TIME <= LOCK_T1;
        8'd2:
            LOCK_TIME <= LOCK_T2;
        8'd3:
            LOCK_TIME <= LOCK_T3;
        8'd4:
            LOCK_TIME <= LOCK_T4;
        8'd5:
            LOCK_TIME <= LOCK_T5;
        8'd6:
            LOCK_TIME <= LOCK_T6;
        8'd7:
            LOCK_TIME <= LOCK_T7;
        8'd8:
            LOCK_TIME <= LOCK_T8;
        8'd9:
            LOCK_TIME <= LOCK_T9;

        8'd10:
            LOCK_TIME <= LOCK_T10;
        8'd11:
            LOCK_TIME <= LOCK_T11;
        8'd12:
            LOCK_TIME <= LOCK_T12;
        8'd13:
            LOCK_TIME <= LOCK_T13;
        8'd14:
            LOCK_TIME <= LOCK_T14;
        8'd15:
            LOCK_TIME <= LOCK_T15;
        8'd16:
            LOCK_TIME <= LOCK_T16;
        8'd17:
            LOCK_TIME <= LOCK_T17;
        8'd18:
            LOCK_TIME <= LOCK_T18;
        8'd19:
            LOCK_TIME <= LOCK_T19;

        8'd20:
            LOCK_TIME <= LOCK_T20;
        8'd21:
            LOCK_TIME <= LOCK_T21;
        8'd22:
            LOCK_TIME <= LOCK_T22;
        8'd23:
            LOCK_TIME <= LOCK_T23;
        8'd24:
            LOCK_TIME <= LOCK_T24;
        8'd25:
            LOCK_TIME <= LOCK_T25;
        8'd26:
            LOCK_TIME <= LOCK_T26;
        8'd27:
            LOCK_TIME <= LOCK_T27;
        8'd28:
            LOCK_TIME <= LOCK_T28;
        8'd29:
            LOCK_TIME <= LOCK_T29;


        default:
            LOCK_TIME <= 8'd0;
    endcase
end


// ----------------------------------
// PATTERN FORWARD and BACKFORWARD
// ----------------------------------
always@(posedge iclk or negedge irst) begin
    if(!irst) begin
        pattern_count <= 8'd0;
        gray_level_count <= 8'd0;
        last_auto_count <= 8'd0;
        last_pat_num <= 8'd0;
        last_inv_pat_num <= 8'd0;
        LOCK_RST <= 1'b1;
    end
    else begin
        if(iauto_run != 1'b1)	// Manuel Mode
        begin
            if(ipat_num != last_pat_num)
`ifdef LOCK_MODE
            begin
                if(pattern_count == (`PATTERN_NUMBER - 1))
                    pattern_count <= 8'd0;
                else begin
                    if(LOCK_COUNT>=LOCK_TIME) begin
                        if(mode==2'd0)
                            pattern_count <= pattern_count + 8'd1;

                        else if(mode==2'b01)
                            gray_level_count <= gray_level_count + 8'd1;
                        else
                            pattern_count <= pattern_count;
                        LOCK_RST <= 1'b0;
                    end
                end
                last_pat_num <= ipat_num;
            end
`endif

`ifdef UNLOCK_MODE
            begin
                if(pattern_count == (`PATTERN_NUMBER - 1))
                    pattern_count <= 8'd0;
                else begin
                    if(mode==2'd0)
                        pattern_count <= pattern_count + 8'd1;
                    else if(mode==2'b01)
                        gray_level_count <= gray_level_count + 8'd1;
                    else
                        pattern_count <= pattern_count;
                    //											pattern_count <= pattern_count + 8'd1;
                    //											gray_level_count <= gray_level_count + 8'd1;
                end
                last_pat_num <= ipat_num;
            end
`endif
            else if(inv_pat_num != last_inv_pat_num) begin
                if(pattern_count == 8'd0)
                    pattern_count <= (`PATTERN_NUMBER - 1);
                else begin
                    if(mode==2'd0)
                        pattern_count <= pattern_count - 8'd1;
                    else if(mode==2'b01)
                        gray_level_count <= gray_level_count - 8'd1;
                    else
                        pattern_count <= pattern_count;
                    //											pattern_count <= pattern_count - 8'd1;
                    //											gray_level_count <= gray_level_count -8'd1;
                end
                last_inv_pat_num <= inv_pat_num;
            end

        end
        else	// Auto Mode
        begin
            if(iauto_count != last_auto_count) begin
                if(pattern_count == (`PATTERN_NUMBER - 1))
                    pattern_count <= 8'd0;
                else begin
                    if(mode==2'd0)
                        pattern_count <= pattern_count + 8'd1;
                    else if(mode==2'b01)
                        gray_level_count <= gray_level_count + 8'd1;
                    else
                        pattern_count <= pattern_count;
                    //											pattern_count <= pattern_count + 8'd1;
                    //											gray_level_count <= gray_level_count + 8'd1;
                end
                last_auto_count <= iauto_count;
            end
        end
    end
end

// ----------------------------------
// PATTERN SELECTION
// ----------------------------------
always@(posedge iclk or negedge irst) begin
    if(!irst) begin
        ordata <= 8'd0;
        ogdata <= 8'd0;
        obdata <= 8'd0;
        oframe_rate <= 2'd0;
        oUD_RL<=1'b0;
    end
    else begin
        // if(de_state_s4) begin
        if(1'd1) begin
            case(wpattern_count)
                `CHAR_H_PAT: begin
                    case(wFONTH_INDEX_Y)
                        4'd0:
                            h_pattern_reg <= 8'b11101110;
                        4'd1:
                            h_pattern_reg <= 8'b01000100;
                        4'd2:
                            h_pattern_reg <= 8'b01000100;
                        4'd3:
                            h_pattern_reg <= 8'b01111100;
                        4'd4:
                            h_pattern_reg <= 8'b01000100;
                        4'd5:
                            h_pattern_reg <= 8'b01000100;
                        4'd6:
                            h_pattern_reg <= 8'b11101110;
                        4'd7:
                            h_pattern_reg <= 8'b00000000;
                        default:
                            h_pattern_reg <= 8'dz;
                    endcase
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    H_PATTERN(h_pattern_reg,wFONTH_INDEX_X,ordata,ogdata,obdata);
                end
                `R_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RED_PATTERN(ordata,ogdata,obdata);
                end
                `R_PAT_L64: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RED_PATTERN_L64(ordata,ogdata,obdata);
                end
                `R_PAT_L128: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RED_PATTERN_L128(ordata,ogdata,obdata);
                end
                `R2_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RED2_PATTERN(x_s4,y_s4,ordata,ogdata,obdata);//zman
                end
                `G_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    GREEN_PATTERN(ordata,ogdata,obdata);
                end
                `G_PAT_L64: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    GREEN_PATTERN_L64(ordata,ogdata,obdata);
                end
                `G_PAT_L128: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    GREEN_PATTERN_L128(ordata,ogdata,obdata);
                end
                `B_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLUE_PATTERN(ordata,ogdata,obdata);
                end
                `B_PAT_L64: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLUE_PATTERN_L64(ordata,ogdata,obdata);
                end
                `B_PAT_L128: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLUE_PATTERN_L128(ordata,ogdata,obdata);
                end
                `WHITE_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    WHITE_PATTERN(ordata,ogdata,obdata);
                end
                `RGB_PATTERN_L64: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RGB_PATTERN_L64(y_s4,ordata,ogdata,obdata);
                end
                `BLACK_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLACK_PATTERN(ordata,ogdata,obdata);
                end
                `BLACK_PAT_2: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLACK_PATTERN(ordata,ogdata,obdata);
                end
                `BLACK_PAT_3: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLACK_PATTERN(ordata,ogdata,obdata);
                end
                `BLACK_PAT_4: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLACK_PATTERN(ordata,ogdata,obdata);
                end
                `BLACK_PAT_5: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLACK_PATTERN(ordata,ogdata,obdata);
                end
                `BLACK_PAT_6: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLACK_PATTERN(ordata,ogdata,obdata);
                end
                `BLACK_PAT_7: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BLACK_PATTERN(ordata,ogdata,obdata);
                end
                `WAKU: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    WAKU_PATTERN(x_s4,y_s4,ordata,ogdata,obdata);//zman
                end
                `BLACK50Hz_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd1;
                    BLACK_PATTERN(ordata,ogdata,obdata);
                end
                `BORDER_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    BORDER_PATTERN(wCondition_BORDER,ordata,ogdata,obdata);
                end
                `RGB_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RGB_PATTERN(y_s4,ordata,ogdata,obdata);
                end
                `GOMI_PAT1: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    GOMI_PATTERN1(y_s4,ordata,ogdata,obdata);
                end
                `GOMI_PAT2: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    GOMI_PATTERN2(y_s4,ordata,ogdata,obdata);
                end
                `CHESS_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    CHESS_PATTERN(wCondition_CHESS,ordata,ogdata,obdata);
                end
                `LUSTER_50P: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LUMIN_FIFTY,ordata,ogdata,obdata);
                end
                `LUSTER_50P_2: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LUMIN_FIFTY,ordata,ogdata,obdata);
                end
                `LUSTER_50P_3: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LUMIN_FIFTY,ordata,ogdata,obdata);
                end

                `LUSTER50Hz_50P: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd1;
                    LUSTER_PATTERN(`LUMIN_FIFTY,ordata,ogdata,obdata);
                end
                `LUSTER_20P: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LUMIN_TWENTY,ordata,ogdata,obdata);
                end
                `LUSTER_20P_1: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LUMIN_TWENTY,ordata,ogdata,obdata);
                end
                `LUSTER_20P_2: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LUMIN_TWENTY,ordata,ogdata,obdata);
                end
                `LUSTER_L208: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_208,ordata,ogdata,obdata);
                end
                `LUSTER_L224: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_224,ordata,ogdata,obdata);
                end
                `LUSTER_L240: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_240,ordata,ogdata,obdata);
                end
                `LUSTER_L192: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_192,ordata,ogdata,obdata);
                end
                `LUSTER_L176: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_176,ordata,ogdata,obdata);
                end
                `LUSTER_L160: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_160,ordata,ogdata,obdata);
                end
                `LUSTER_L144: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_144,ordata,ogdata,obdata);
                end
                `LUSTER_L128: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_128,ordata,ogdata,obdata);
                end
                `LUSTER_L112: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_112,ordata,ogdata,obdata);
                end
                `LUSTER_L96: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_96,ordata,ogdata,obdata);
                end
                `LUSTER_L80: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_80,ordata,ogdata,obdata);
                end
                `LUSTER_L64: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_64,ordata,ogdata,obdata);
                end
                `LUSTER_L48: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_48,ordata,ogdata,obdata);
                end
                `LUSTER_L32: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_32,ordata,ogdata,obdata);
                end
                `LUSTER_L16: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_16,ordata,ogdata,obdata);
                end
                `LUSTER_L10: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    LUSTER_PATTERN(`LEVEL_10,ordata,ogdata,obdata);
                end
                `WINDOW_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    WINDOW_PATTERN(wCondition_WINDOW,ordata,ogdata,obdata);
                end
                `WINDOW_PAT2: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    WINDOW_PATTERN2(wCondition_WINDOW,ordata,ogdata,obdata);
                end
                `CROSSTALK_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    CROSSTALK_PATTERN(wCondition_WINDOW,wCondition_CROSSTALK1,
                                      wCondition_CROSSTALK2,ordata,ogdata,obdata);
                end
                `VGRAY_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    VGRAY_PATTERN(wCondition_VGRAY,ordata,ogdata,obdata);
                end
                `VGRAY_PAT_R: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    VGRAY_PATTERN_R(wCondition_VGRAY,ordata,ogdata,obdata);
                end
                `VGRAY_PAT_B: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    VGRAY_PATTERN_B(wCondition_VGRAY,ordata,ogdata,obdata);
                end
                `VGRAY_PAT_G: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    VGRAY_PATTERN_G(wCondition_VGRAY,ordata,ogdata,obdata);
                end
                `HGRAY_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    HGRAY_PATTERN(wCondition_HGRAY,ordata,ogdata,obdata);
                end
                `HGRAY_PAT_R: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    HGRAY_PATTERN_R(wCondition_HGRAY,ordata,ogdata,obdata);
                end
                `HGRAY_PAT_G: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    HGRAY_PATTERN_G(wCondition_HGRAY,ordata,ogdata,obdata);
                end
                `HGRAY_PAT_B: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    HGRAY_PATTERN_B(wCondition_HGRAY,ordata,ogdata,obdata);
                end
                `HBW_PAT: begin
                    oUD_RL<=1'b0;
                    HBW_PATTERN(wCondition_HBW,ordata,ogdata,obdata);
                end
                `VBW_PAT: begin
                    oUD_RL<=1'b0;
                    VBW_PATTERN(wCondition_VBW,ordata,ogdata,obdata);
                end

                `VBW1_PAT: begin
                    oUD_RL<=1'b0;
                    VBW1_PATTERN(wCondition_VBW,ordata,ogdata,obdata);
                end

                `VBW_sub_PAT: begin
                    oUD_RL<=1'b0;
                    VBW_SUB_PATTERN(wCondition_VBW,ordata,ogdata,obdata);
                end

                `VBW_sub1_PAT: begin
                    oUD_RL<=1'b0;
                    VBW_SUB1_PATTERN(wCondition_VBW,ordata,ogdata,obdata);
                end

                `FLICKER_PAT_DOT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    FLICKER_PATTERN(`LUMIN_FIFTY,wCondition_FLICKER_DOT,ordata,ogdata,obdata);
                end
                `FLICKER_PAT_1L2D: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    FLICKER_PATTERN(`LUMIN_FIFTY,wCondition_FLICKER_1L2D,ordata,ogdata,obdata);
                end
                `FLICKER_PAT_2L1D: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    FLICKER_PATTERN(`LUMIN_FIFTY,wCondition_FLICKER_2L1D,ordata,ogdata,obdata);
                end
                `FLICKER_PAT_2L2D: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    FLICKER_PATTERN(`LUMIN_FIFTY,wCondition_FLICKER_2L2D,ordata,ogdata,obdata);
                end
                `FLICKER_PAT_COLUMN: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    FLICKER_PATTERN(`LUMIN_FIFTY,wCondition_FLICKER_COLUMN,ordata,ogdata,obdata);
                end
                `COLOR_8G8C: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    COLOR_PATTERN(x_s4,y_s4,ordata,ogdata,obdata);
                end
                `COLOR_8C: begin
                    oUD_RL<=1'b1;
                    oframe_rate <= 2'd0;
                    COLOR_PATTERN_8color(x_s4,y_s4,ordata,ogdata,obdata);
                end
                `RESPONSE_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RESPONSE_PATTERN(response_flag,ordata,ogdata,obdata);
                end
                `RESPONSE_PAT_1s: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RESPONSE_PATTERN(response_flag_1s,ordata,ogdata,obdata);
                end
                `RESPONSE_PAT_5s: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RESPONSE_PATTERN(response_flag_5s,ordata,ogdata,obdata);
                end
                `RESPONSE_PAT_10s: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    RESPONSE_PATTERN(response_flag_10s,ordata,ogdata,obdata);
                end
                `PRESSURE_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    PRESSURE_PATTERN(wPressure_ConditionX,wPressure_ConditionY,ordata,ogdata,obdata);
                end
                `TP_5P_PAT: begin
                    oUD_RL<=1'b0;
                    oframe_rate <= 2'd0;
                    TP_PATTERN(wTP_ConditionP1,wTP_ConditionP2,wTP_ConditionP3,wTP_ConditionP4,ordata,ogdata,obdata);
                end
                default: begin
                    oUD_RL<=1'b0;
                    ordata <= 8'dz;
                    ogdata <= 8'dz;
                    obdata <= 8'dz;
                end
            endcase
        end
        else begin
            //oUD_RL<=1'b0;
            ordata <= 8'dz;
            ogdata <= 8'dz;
            obdata <= 8'dz;
        end
    end
end

//-----------------------------------------------------------------
// Task
//-----------------------------------------------------------------
// RED Pattern
task RED_PATTERN;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd255;
        gdata <= 8'd0;
        bdata <= 8'd0;
    end
endtask

task RED_PATTERN_L64;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd64;
        gdata <= 8'd0;
        bdata <= 8'd0;
    end
endtask

task RED_PATTERN_L128;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd128;
        gdata <= 8'd0;
        bdata <= 8'd0;
    end
endtask

// GREEN Pattern
task GREEN_PATTERN;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= 8'd255;
        bdata <= 8'd0;
    end
endtask

task GREEN_PATTERN_L64;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= 8'd64;
        bdata <= 8'd0;
    end
endtask

task GREEN_PATTERN_L128;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= 8'd128;
        bdata <= 8'd0;
    end
endtask

// BLUE Pattern
task BLUE_PATTERN;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= 8'd0;
        bdata <= 8'd255;
    end
endtask

task BLUE_PATTERN_L64;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= 8'd0;
        bdata <= 8'd64;
    end
endtask

task BLUE_PATTERN_L128;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= 8'd0;
        bdata <= 8'd128;
    end
endtask

// WHITE Pattern
task WHITE_PATTERN;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd255;
        gdata <= 8'd255;
        bdata <= 8'd255;
    end
endtask

// BLACK Pattern
task BLACK_PATTERN;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= 8'd0;
        bdata <= 8'd0;
    end
endtask

task WAKU_PATTERN;//zman
    input[19:0]		x_coord;
    input[19:0]		y_coord;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(y_coord == 0 || y_coord == (`V_PIXEL-1) || x_coord == 0 || x_coord == (`H_PIXEL-1)) begin
            rdata <= `LEVEL_64;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

task RED2_PATTERN;//zman
    input[19:0]		x_coord;
    input[19:0]		y_coord;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(y_coord == 0 || y_coord == (`V_PIXEL-1) || x_coord == 0 || x_coord == (`H_PIXEL-1)) begin
            rdata <= `LUMIN_TWENTY;
            gdata <= `LUMIN_TWENTY;
            bdata <= `LUMIN_TWENTY;
        end
        else begin
            rdata <= 8'd255;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

// BORDER Pattern
task BORDER_PATTERN;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

// RGB Pattern
task RGB_PATTERN;
    input[19:0]		y_coord;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(y_coord < (1*(`V_PIXEL/3))) begin
            rdata <= `LUMIN_FIFTY;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
        else if((y_coord >= (1*(`V_PIXEL/3))) && (y_coord < (2*(`V_PIXEL/3)))) begin
            rdata <= 8'd0;
            gdata <= `LUMIN_FIFTY;
            bdata <= 8'd0;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= `LUMIN_FIFTY;
        end
    end
endtask

// RGB Pattern_L64
task RGB_PATTERN_L64;
    input[19:0]		y_coord;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(y_coord < (1*(`V_PIXEL/3))) begin
            rdata <= 8'd64;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
        else if((y_coord >= (1*(`V_PIXEL/3))) && (y_coord < (2*(`V_PIXEL/3)))) begin
            rdata <= 8'd0;
            gdata <= 8'd64;
            bdata <= 8'd0;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd64;
        end
    end
endtask

task COLOR_PATTERN;
    input[19:0]		x_coord;
    input[19:0]		y_coord;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(y_coord < (`V_PIXEL >> 1)) begin
            if((x_coord >= 0) && (x_coord < (1*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd0;
                gdata <= 8'd0;
                bdata <= 8'd0;
            end
            else if((x_coord >= (1*(`H_PIXEL >> 3))) && (x_coord < (2*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd0;
                gdata <= 8'd0;
                bdata <= 8'd255;
            end
            else if((x_coord >= (2*(`H_PIXEL >> 3))) && (x_coord < (3*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd255;
                gdata <= 8'd0;
                bdata <= 8'd0;
            end
            else if((x_coord >= (3*(`H_PIXEL >> 3))) && (x_coord < (4*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd255;
                gdata <= 8'd0;
                bdata <= 8'd255;
            end
            else if((x_coord >= (4*(`H_PIXEL >> 3))) && (x_coord < (5*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd0;
                gdata <= 8'd255;
                bdata <= 8'd0;
            end
            else if((x_coord >= (5*(`H_PIXEL >> 3))) && (x_coord < (6*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd0;
                gdata <= 8'd255;
                bdata <= 8'd255;
            end
            else if((x_coord >= (6*(`H_PIXEL >> 3))) && (x_coord < (7*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd255;
                gdata <= 8'd255;
                bdata <= 8'd0;
            end
            else begin
                rdata <= 8'd255;
                gdata <= 8'd255;
                bdata <= 8'd255;
            end
        end
        else begin
            if((x_coord >= 0) && (x_coord < (1*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd255;
                gdata <= 8'd255;
                bdata <= 8'd255;
            end
            else if((x_coord >= (1*(`H_PIXEL >> 3))) && (x_coord < (2*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd191;
                gdata <= 8'd191;
                bdata <= 8'd191;
            end
            else if((x_coord >= (2*(`H_PIXEL >> 3))) && (x_coord < (3*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd159;
                gdata <= 8'd159;
                bdata <= 8'd159;
            end
            else if((x_coord >= (3*(`H_PIXEL >> 3))) && (x_coord < (4*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd127;
                gdata <= 8'd127;
                bdata <= 8'd127;
            end
            else if((x_coord >= (4*(`H_PIXEL >> 3))) && (x_coord < (5*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd95;
                gdata <= 8'd95;
                bdata <= 8'd95;
            end
            else if((x_coord >= (5*(`H_PIXEL >> 3))) && (x_coord < (6*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd63;
                gdata <= 8'd63;
                bdata <= 8'd63;
            end
            else if((x_coord >= (6*(`H_PIXEL >> 3))) && (x_coord < (7*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd31;
                gdata <= 8'd31;
                bdata <= 8'd31;
            end
            else begin
                rdata <= 8'd0;
                gdata <= 8'd0;
                bdata <= 8'd0;
            end
        end
    end
endtask


// COLOR Pattern
task COLOR_PATTERN_8color;
    input[19:0]		x_coord;
    input[19:0]		y_coord;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(y_coord < (1*(`V_PIXEL/1))) begin
            if((x_coord >= 0) && (x_coord < (1*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd0;
                gdata <= 8'd0;
                bdata <= 8'd0;
            end
            else if((x_coord >= (1*(`H_PIXEL >> 3))) && (x_coord < (2*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd0;
                gdata <= 8'd0;
                bdata <= 8'd255;
            end
            else if((x_coord >= (2*(`H_PIXEL >> 3))) && (x_coord < (3*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd255;
                gdata <= 8'd0;
                bdata <= 8'd0;
            end
            else if((x_coord >= (3*(`H_PIXEL >> 3))) && (x_coord < (4*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd255;
                gdata <= 8'd0;
                bdata <= 8'd255;
            end
            else if((x_coord >= (4*(`H_PIXEL >> 3))) && (x_coord < (5*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd0;
                gdata <= 8'd255;
                bdata <= 8'd0;
            end
            else if((x_coord >= (5*(`H_PIXEL >> 3))) && (x_coord < (6*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd0;
                gdata <= 8'd255;
                bdata <= 8'd255;
            end
            else if((x_coord >= (6*(`H_PIXEL >> 3))) && (x_coord < (7*(`H_PIXEL >> 3)))) begin
                rdata <= 8'd255;
                gdata <= 8'd255;
                bdata <= 8'd0;
            end
            else begin
                rdata <= 8'd255;
                gdata <= 8'd255;
                bdata <= 8'd255;
            end
        end

    end
endtask

// FLICKER Pattern Dot Inversion
task FLICKER_PATTERN;
    input[7:0]      LUMIN_PARAMETER;
    input			condition1;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition1) begin
            rdata <= 8'd0;
            gdata <= LUMIN_PARAMETER;
            bdata <= 8'd0;
        end
        else begin
            rdata <= LUMIN_PARAMETER;
            gdata <= 8'd0;
            bdata <= LUMIN_PARAMETER;
        end
    end
endtask

// FLICKER Pattern
task FLICKER_PATTERN_P;
    /*	input			condition1;
    	output[7:0]		rdata;
    	output[7:0]		gdata;
    	output[7:0]		bdata;
    	begin
    		if(condition1)
    			begin
    				rdata <= `LUMIN_TWENTY;
    				gdata <= `LUMIN_TWENTY;
    				bdata <= `LUMIN_TWENTY;
    			end
    		else
    			begin
    				rdata <=  8'd0;
    				gdata <=  8'd0;
    				bdata <=  8'd0;
    			end

    	end
    endtask*/



    input			condition1;
    input[7:0]		condition2;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition1) begin
            rdata <= (condition2 ^ 8'd0);
            gdata <= (condition2 ^ `LUMIN_TWENTY);
            bdata <= (condition2 ^ 8'd0);
        end
        else begin
            rdata <= (condition2 ^ `LUMIN_TWENTY);
            gdata <= (condition2 ^ 8'd0);
            bdata <= (condition2 ^ `LUMIN_TWENTY);
        end
    end
endtask

// HBW Pattern
task HBW_PATTERN;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

// VBW Pattern
task VBW_PATTERN;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

// VBW Pattern
task VBW1_PATTERN;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;

        end
        else begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
    end
endtask

// VBW Pattern
task VBW_SUB_PATTERN;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            rdata <= 8'd0;
            gdata <= 8'd255;
            bdata <= 8'd0;

        end
        else begin
            rdata <= 8'd255;
            gdata <= 8'd0;
            bdata <= 8'd255;
        end
    end
endtask
// VBW Pattern
task VBW_SUB1_PATTERN;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            rdata <= 8'd255;
            gdata <= 8'd0;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd255;
            bdata <= 8'd0;
        end
    end
endtask
// HGRAY Pattern
task HGRAY_PATTERN;
    input[7:0]		condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= condition;
        gdata <= condition;
        bdata <= condition;
    end
endtask


task HGRAY_PATTERN_R;
    input[7:0]		condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= condition;
        gdata <= 8'd0;
        bdata <= 8'd0;
    end
endtask

task HGRAY_PATTERN_G;
    input[7:0]		condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= condition;
        bdata <= 8'd0;
    end
endtask

task HGRAY_PATTERN_B;
    input[7:0]		condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= 8'd0;
        bdata <= condition;
    end
endtask
// VGRAY Pattern
task VGRAY_PATTERN;
    input[7:0]		condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= condition;
        gdata <= condition;
        bdata <= condition;
    end
endtask

// VGRAY Pattern_R
task VGRAY_PATTERN_R;
    input[7:0]		condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= condition;
        gdata <= 8'd0;
        bdata <= 8'd0;
    end
endtask

// VGRAY Pattern_B
task VGRAY_PATTERN_B;
    input[7:0]		condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= 8'd0;
        bdata <= condition;
    end
endtask

// VGRAY Pattern_G
task VGRAY_PATTERN_G;
    input[7:0]		condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= 8'd0;
        gdata <= condition;
        bdata <= 8'd0;
    end
endtask
// WINDOW Pattern
task WINDOW_PATTERN2;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            // Normal Black(VA type)
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
        else begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
    end
endtask
// WINDOW Pattern
task WINDOW_PATTERN3;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            // Normal Black(VA type)
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
        else begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
    end
endtask
// WINDOW Pattern
task WINDOW_PATTERN;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            // Normal Black(VA type)
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd186;
            gdata <= 8'd186;
            bdata <= 8'd186;
        end
    end
endtask
// CROSSTALK Pattern
task CROSSTALK_PATTERN;
    input			condition1;
    input			condition2;
    input			condition3;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition1) begin
            if(condition2) begin
                rdata <= 8'd255;
                gdata <= 8'd0;
                bdata <= 8'd255;
            end
            else if(condition3) begin
                rdata <= 8'd0;
                gdata <= 8'd255;
                bdata <= 8'd0;
            end
        end
        else begin
            rdata <= `LUMIN_FIFTY;
            gdata <= `LUMIN_FIFTY;
            bdata <= `LUMIN_FIFTY;
        end
    end
endtask

task LUSTER_PATTERN;
    input [7:0]      LUMIN_PARAMETER;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        rdata <= LUMIN_PARAMETER;
        gdata <= LUMIN_PARAMETER;
        bdata <= LUMIN_PARAMETER;
    end
endtask

// CHESS PATTERN
task CHESS_PATTERN;
    input			condition;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(condition) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

// H PAttern
task H_PATTERN;
    input[7:0]		h_reg;
    input[3:0]		index;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(h_reg[index]) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

// GOMI Pattern 1
task GOMI_PATTERN1;
    input[19:0]		y_coord;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(y_coord < (1*(`V_PIXEL/4))) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else if((y_coord >= (1*(`V_PIXEL/4))) && (y_coord < (2*(`V_PIXEL/4)))) begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
        else if((y_coord >= (2*(`V_PIXEL/4))) && (y_coord < (3*(`V_PIXEL/4)))) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

// GOMI Pattern 2
task GOMI_PATTERN2;
    input[19:0]		y_coord;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(y_coord < (1*(`V_PIXEL/4))) begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
        else if((y_coord >= (1*(`V_PIXEL/4))) && (y_coord < (2*(`V_PIXEL/4)))) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else if((y_coord >= (2*(`V_PIXEL/4))) && (y_coord < (3*(`V_PIXEL/4)))) begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
        else begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
    end
endtask

// Response Pattern
task RESPONSE_PATTERN;
    input			flag;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(flag) begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
        else begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
    end
endtask

// Pressure Pattern
task PRESSURE_PATTERN;
    input			range1;
    input			range2;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(range1 || range2) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

// TP Pattern
task TP_PATTERN;
    input			range1;
    input			range2;
    input			range3;
    input			range4;
    //			input			range5;
    output[7:0]		rdata;
    output[7:0]		gdata;
    output[7:0]		bdata;
    begin
        if(range1 || range2 || range3 || range4 ) begin
            rdata <= 8'd255;
            gdata <= 8'd255;
            bdata <= 8'd255;
        end
        else begin
            rdata <= 8'd0;
            gdata <= 8'd0;
            bdata <= 8'd0;
        end
    end
endtask

endmodule
