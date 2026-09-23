module CHESS_LUT#
       (
           parameter H_RESOLUTION = 1920,
           parameter V_RESOLUTION = 720,
           parameter H_DIV = 7,
           parameter V_DIV = 6,
           parameter CHESS_BLACK = 0,
           parameter CHESS_WHITE = 255
       )
       (
           input clk,
           input rstn,
           input [22:0] x_coord,
           input [22:0] y_coord,
           output reg [7:0] chess_data
       );

// ===== 基本參數 =====
localparam H_BASE = H_RESOLUTION / H_DIV;
localparam H_REM  = H_RESOLUTION % H_DIV;

localparam V_BASE = V_RESOLUTION / V_DIV;
localparam V_REM  = V_RESOLUTION % V_DIV;

// ===== boundary LUT =====
reg [22:0] h_bound [0:H_DIV-1];
reg [22:0] v_bound [0:V_DIV-1];

integer i;
integer acc;
integer size;

// ===== 初始化 boundary =====
initial begin
    // H
    acc = 0;
    for (i = 0; i < H_DIV; i = i + 1) begin
        if (i < H_REM)
            size = H_BASE + 1;
        else
            size = H_BASE;

        acc = acc + size;
        h_bound[i] = acc;
    end

    // V
    acc = 0;
    for (i = 0; i < V_DIV; i = i + 1) begin
        if (i < V_REM)
            size = V_BASE + 1;
        else
            size = V_BASE;

        acc = acc + size;
        v_bound[i] = acc;
    end
end

wire [H_DIV-1:0] x_hit;
wire [V_DIV-1:0] y_hit;

genvar k;
generate
    for (k = 0; k < H_DIV; k = k + 1) begin : GEN_X
        if (k == 0) begin
            assign x_hit[k] = (x_coord < h_bound[k]);
        end
        else begin
            assign x_hit[k] = (x_coord < h_bound[k]) &&
                   (x_coord >= h_bound[k-1]);
        end
    end
endgenerate

generate
    for (k = 0; k < V_DIV; k = k + 1) begin : GEN_Y
        if (k == 0) begin
            assign y_hit[k] = (y_coord < v_bound[k]);
        end
        else begin
            assign y_hit[k] = (y_coord < v_bound[k]) &&
                   (y_coord >= v_bound[k-1]);
        end
    end
endgenerate

wire bx_parity;
wire by_parity;

assign bx_parity = ^(x_hit & gen_parity_mask(H_DIV));
assign by_parity = ^(y_hit & gen_parity_mask(V_DIV));

// ===== chess =====
always @(posedge clk or negedge rstn) begin
    if (!rstn)
        chess_data <= 8'd0;
    else
        chess_data <= (bx_parity ^ by_parity) ? CHESS_WHITE : CHESS_BLACK;
end

// ===== parity mask function =====
function [63:0] gen_parity_mask;
    input integer div;
    integer j;
    begin
        gen_parity_mask = 0;
        for (j = 0; j < div; j = j + 1) begin
            gen_parity_mask[j] = j[0]; // 奇偶
        end
    end
endfunction

endmodule
