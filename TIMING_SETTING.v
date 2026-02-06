// // FOR DEBUG USING
// // Interface & Mode Selection
// `define VESA                // LVDS format: VESA or JEIDA
// `define LVDS_2port          // LVDS port mode: 2-port or 1-port
// `define BIT8                // Color depth: 8-bit or 6-bit
// `define UNLOCK_MODE         // Lock mode: LOCK_MODE or UNLOCK_MODE

// ////////////////////////////////////////////////////////////////////////////////
// // Panel Resolution & Timing
// `define H_PIXEL             22'd256       // Horizontal resolution
// `define V_PIXEL             22'd256       // Vertical resolution

// `define DE_MODE                            // Timing mode: DE_MODE or HV_MODE
// // DE_MODE
// // HS_PERIOD = H_PIXEL + HS_BLANK(Include HS_PULSE_WIDTH)
// // VS_PERIOD = V_PIXEL + VS_BLANK(Include VS_PULSE_WIDTH)

// // Horizontal timing
// `define HS_PULSE_WIDTH      22'd1
// `define HS_PERIOD           22'd264

// // Vertical timing
// `define VS_PULSE_WIDTH      22'd1
// `define VS_PERIOD           22'd258

// `ifdef HV_MODE
// `define HS_BACK_PORCH   22'd296
// `define VS_BACK_PORCH   22'd2
// `endif

// `ifdef DE_MODE
// `define HS_BLANK        22'd8
// `define VS_BLANK        22'd2
// `endif

// C103HAN09.0
////////////////////////////////////////////////////////////////////////////////
// Interface & Mode Selection
`define VESA                // LVDS format: VESA or JEIDA
`define LVDS_2port          // LVDS port mode: 2-port or 1-port
`define BIT8                // Color depth: 8-bit or 6-bit
`define UNLOCK_MODE         // Lock mode: LOCK_MODE or UNLOCK_MODE

////////////////////////////////////////////////////////////////////////////////
// Panel Resolution & Timing
`define H_PIXEL             22'd1920       // Horizontal resolution
`define V_PIXEL             22'd720       // Vertical resolution

`define DE_MODE                            // Timing mode: DE_MODE or HV_MODE
// DE_MODE
// HS_PERIOD = H_PIXEL + HS_BLANK(Include HS_PULSE_WIDTH)
// VS_PERIOD = V_PIXEL + VS_BLANK(Include VS_PULSE_WIDTH)

// Horizontal timing
`define HS_PULSE_WIDTH      22'd1
`define HS_PERIOD           22'd2512

// Vertical timing
`define VS_PULSE_WIDTH      22'd1
`define VS_PERIOD           22'd729

`ifdef HV_MODE
`define HS_BACK_PORCH   22'd296
`define VS_BACK_PORCH   22'd2
`endif

`ifdef DE_MODE
`define HS_BLANK        22'd592
`define VS_BLANK        22'd9
`endif

////////////////////////////////////////////////////////////////////////////////
// LVDS Port Select
`ifdef LVDS_2port
`define two_prt_sel     1'b1
`endif

`ifdef LVDS_1port
`define two_prt_sel     1'b0
`endif


////////////////////////////////////////////////////////////////////////////////
// Lock Pattern Timing
`define sLOCK_T0            8'd6
`define sLOCK_T1            8'd10
`define sLOCK_T2            8'd6
`define sLOCK_T3            8'd1
`define sLOCK_T4            8'd1
`define sLOCK_T5            8'd1
`define sLOCK_T6            8'd2
`define sLOCK_T7            8'd2
`define sLOCK_T8            8'd1
`define sLOCK_T9            8'd0
`define sLOCK_T10		8'd0
`define sLOCK_T11		8'd0
`define sLOCK_T12		8'd0
`define sLOCK_T13		8'd0
`define sLOCK_T14		8'd0
`define sLOCK_T15		8'd0
`define sLOCK_T16		8'd0
`define sLOCK_T17		8'd0
`define sLOCK_T18		8'd0
`define sLOCK_T19		8'd0

`define sLOCK_T20		8'd0
`define sLOCK_T21		8'd0
`define sLOCK_T22		8'd0
`define sLOCK_T23		8'd0
`define sLOCK_T24		8'd0
`define sLOCK_T25		8'd0
`define sLOCK_T26		8'd0
`define sLOCK_T27		8'd0
`define sLOCK_T28		8'd0
`define sLOCK_T29		8'd0


////////////////////////////////////////////////////////////////////////////////
// Gray Step
`define HORIZONTAL_STEP_UP      242
`define HORIZONTAL_STEP_DOWN    1024
`define VERTICAL_STEP_UP        68
`define VERTICAL_STEP_DOWN      512


////////////////////////////////////////////////////////////////////////////////
// Pattern & Luminance
`define PATTERN_NUMBER      8'd23
`define LUMIN_FIFTY         8'd186
`define LUMIN_TWENTY        8'd128
`define LEVEL_10            8'd10
`define LEVEL_16            8'd16
`define LEVEL_32            8'd32
`define LEVEL_48            8'd48
`define LEVEL_64            8'd64
`define LEVEL_80            8'd80
`define LEVEL_96            8'd96
`define LEVEL_112           8'd112
`define LEVEL_128           8'd128
`define LEVEL_144           8'd144
`define LEVEL_160           8'd160
`define LEVEL_176           8'd176
`define LEVEL_192           8'd192
`define LEVEL_208           8'd208
`define LEVEL_224           8'd224
`define LEVEL_240           8'd240


////////////////////////////////////////////////////////////////////////////////
// Aging & Special Patterns
`define BLACK_PAT_3         8'd66
`define BLACK_PAT_4         8'd66
`define BLACK_PAT_5         8'd66
`define BLACK_PAT_6         8'd66
`define BLACK_PAT_7         8'd66
`define PRESSURE_PAT        8'd66
`define BLACK50Hz_PAT       8'd66
`define LUSTER50Hz_50P      8'd66
`define TP_5P_PAT           8'd66
`define CHAR_H_PAT          8'd66
`define CROSSTALK_PAT       8'd66
`define WAKU                8'd66
`define R2_PAT              8'd66
`define R_PAT_L64           8'd66
`define G_PAT_L64           8'd66
`define B_PAT_L64           8'd66
`define RGB_PATTERN_L64     8'd66
`define LUSTER_20P          8'd66
`define LUSTER_20P_1        8'd66
`define LUSTER_20P_2        8'd66
`define WINDOW_PAT2         8'd66
`define VGRAY_PAT_R         8'd66
`define VGRAY_PAT_G         8'd66
`define VGRAY_PAT_B         8'd66
`define HGRAY_PAT_R         8'd66
`define HGRAY_PAT_G         8'd66
`define HGRAY_PAT_B         8'd66
`define VBW1_PAT            8'd66
`define VBW_sub_PAT         8'd66
`define VBW_sub1_PAT        8'd66
`define FLICKER_PAT_1L2D    8'd66
`define FLICKER_PAT_2L1D    8'd66
`define FLICKER_PAT_2L2D    8'd66
`define FLICKER_PAT_COLUMN  8'd66
`define COLOR_8C            8'd66
`define RESPONSE_PAT        8'd66
`define LUSTER_L10          8'd66
`define LUSTER_L16          8'd66
`define LUSTER_L32          8'd66
`define LUSTER_L48          8'd66
`define LUSTER_L64          8'd66
`define LUSTER_L80          8'd66
`define LUSTER_L96          8'd66
`define LUSTER_L112         8'd66
`define LUSTER_L128         8'd66
`define LUSTER_L144         8'd66
`define LUSTER_L160         8'd66
`define LUSTER_L176         8'd66
`define LUSTER_L192         8'd66
`define LUSTER_L208         8'd66
`define LUSTER_L224         8'd66
`define LUSTER_L240         8'd66
`define R_PAT_L128          8'd66
`define G_PAT_L128          8'd66
`define B_PAT_L128          8'd66
`define GB_PAT              8'd66
`define RB_PAT              8'd66
`define RG_PAT              8'd66
`define B_PAT_L128          8'd66
`define B_PAT_L128          8'd66
`define B_PAT_L128          8'd66
`define HBW_PAT             8'd66
// ////////////////////////////////////////////////////////////////////////////////
// // RA Pattern
`define BORDER_PAT          8'd0
`define R_PAT               8'd1
`define G_PAT               8'd2
`define B_PAT               8'd3
`define WHITE_PAT           8'd4
`define BLACK_PAT           8'd5
`define FLICKER_PAT_DOT     8'd6
`define WINDOW_PAT          8'd7
`define LUSTER_50P          8'd8
`define COLOR_8G8C          8'd9
`define VGRAY_PAT           8'd10
`define HGRAY_PAT           8'd11
`define VBW_PAT             8'd12
`define RGB_PAT             8'd13
`define CHESS_PAT           8'd14  //10x10
`define LUSTER_50P_2        8'd15
`define GOMI_PAT1           8'd16
`define GOMI_PAT2           8'd17
`define LUSTER_50P_3        8'd18
`define RESPONSE_PAT_1s     8'd19
`define RESPONSE_PAT_5s     8'd20
`define RESPONSE_PAT_10s    8'd21
`define BLACK_PAT_2         8'd22


