module IS_CHECKER_LUT#
       (
           parameter H_RESOLUTION = 1920, V_RESOLUTION = 720,
           parameter LN0 = 8'd0,
           LN1 = 8'd1,
           LN2 = 8'd7,
           LN3 = 8'd15,
           LN4 = 8'd23,
           LN5 = 8'd63,
           LN6 = 8'd127,
           LN7 = 8'd191,
           LN8 = 8'd231,
           LN9 = 8'd239,
           LN10 = 8'd247,
           LN11 = 8'd254,
           LN12 = 8'd255
       )
       (
           input clk,
           input rstn,
           input [22:0]x_coord,
           input [22:0]y_coord,
           output reg [7:0]gray_data
       );

reg [7:0]rom_0[0: H_RESOLUTION-1];
reg [7:0]rom_1[0: H_RESOLUTION-1];
reg [7:0]rom_2[0: H_RESOLUTION-1];
reg [7:0]rom_3[0: H_RESOLUTION-1];
reg [7:0]rom_4[0: H_RESOLUTION-1];
reg [7:0]rom_5[0: H_RESOLUTION-1];
reg [7:0]rom_6[0: H_RESOLUTION-1];
reg [7:0]rom_7[0: H_RESOLUTION-1];
reg [7:0]rom_8[0: H_RESOLUTION-1];
reg [7:0]rom_9[0: H_RESOLUTION-1];
reg [7:0]rom_10[0: H_RESOLUTION-1];
reg [7:0]rom_11[0: H_RESOLUTION-1];
reg [7:0]rom_12[0: H_RESOLUTION-1];

integer i;

localparam [22:0]H_RESOLUTION_DIV_13 = H_RESOLUTION / 13;


initial begin
    for(i = 0; i < H_RESOLUTION; i = i + 1) begin
        // Vertical Line 0
        if(i >= H_RESOLUTION_DIV_13 * 0 && i < H_RESOLUTION_DIV_13 * 1) begin
            rom_0[i]  = LN0;
            rom_1[i]  = LN6;
            rom_2[i]  = LN12;
            rom_3[i]  = LN5;
            rom_4[i]  = LN11;
            rom_5[i]  = LN4;
            rom_6[i]  = LN10;
            rom_7[i]  = LN3;
            rom_8[i]  = LN9;
            rom_9[i]  = LN2;
            rom_10[i]  = LN8;
            rom_11[i]  = LN1;
            rom_12[i]  = LN7;
        end
        // Vertical Line 1
        else if(i >= H_RESOLUTION_DIV_13 * 1 && i < H_RESOLUTION_DIV_13 * 2) begin
            rom_0[i]  = LN7;
            rom_1[i]  = LN0;
            rom_2[i]  = LN6;
            rom_3[i]  = LN12;
            rom_4[i]  = LN5;
            rom_5[i]  = LN11;
            rom_6[i]  = LN4;
            rom_7[i]  = LN10;
            rom_8[i]  = LN3;
            rom_9[i]  = LN9;
            rom_10[i]  = LN2;
            rom_11[i]  = LN8;
            rom_12[i]  = LN1;
        end
        // Vertical Line 2
        else if(i >= H_RESOLUTION_DIV_13 * 2 && i < H_RESOLUTION_DIV_13 * 3) begin
            rom_0[i]  = LN1;
            rom_1[i]  = LN7;
            rom_2[i]  = LN0;
            rom_3[i]  = LN6;
            rom_4[i]  = LN12;
            rom_5[i]  = LN5;
            rom_6[i]  = LN11;
            rom_7[i]  = LN4;
            rom_8[i]  = LN10;
            rom_9[i]  = LN3;
            rom_10[i]  = LN9;
            rom_11[i]  = LN2;
            rom_12[i]  = LN8;
        end
        // Vertical Line 3
        else if(i >= H_RESOLUTION_DIV_13 * 3 && i < H_RESOLUTION_DIV_13 * 4) begin
            rom_0[i]  = LN8;
            rom_1[i]  = LN1;
            rom_2[i]  = LN7;
            rom_3[i]  = LN0;
            rom_4[i]  = LN6;
            rom_5[i]  = LN12;
            rom_6[i]  = LN5;
            rom_7[i]  = LN11;
            rom_8[i]  = LN4;
            rom_9[i]  = LN10;
            rom_10[i]  = LN3;
            rom_11[i]  = LN9;
            rom_12[i]  = LN2;
        end
        // Vertical Line 4
        else if(i >= H_RESOLUTION_DIV_13 * 4 && i < H_RESOLUTION_DIV_13 * 5) begin
            rom_0[i]  = LN2;
            rom_1[i]  = LN8;
            rom_2[i]  = LN1;
            rom_3[i]  = LN7;
            rom_4[i]  = LN0;
            rom_5[i]  = LN6;
            rom_6[i]  = LN12;
            rom_7[i]  = LN5;
            rom_8[i]  = LN11;
            rom_9[i]  = LN4;
            rom_10[i]  = LN10;
            rom_11[i]  = LN3;
            rom_12[i]  = LN9;
        end
        // Vertical Line 5
        else if(i >= H_RESOLUTION_DIV_13 * 5 && i < H_RESOLUTION_DIV_13 * 6) begin
            rom_0[i]  = LN9;
            rom_1[i]  = LN2;
            rom_2[i]  = LN8;
            rom_3[i]  = LN1;
            rom_4[i]  = LN7;
            rom_5[i]  = LN0;
            rom_6[i]  = LN6;
            rom_7[i]  = LN12;
            rom_8[i]  = LN5;
            rom_9[i]  = LN11;
            rom_10[i]  = LN4;
            rom_11[i]  = LN10;
            rom_12[i]  = LN3;
        end
        // Vertical Line 6
        else if(i >= H_RESOLUTION_DIV_13 * 6 && i < H_RESOLUTION_DIV_13 * 7) begin
            rom_0[i]  = LN3;
            rom_1[i]  = LN9;
            rom_2[i]  = LN2;
            rom_3[i]  = LN8;
            rom_4[i]  = LN1;
            rom_5[i]  = LN7;
            rom_6[i]  = LN0;
            rom_7[i]  = LN6;
            rom_8[i]  = LN12;
            rom_9[i]  = LN5;
            rom_10[i]  = LN11;
            rom_11[i]  = LN4;
            rom_12[i]  = LN10;
        end
        // Vertical Line 7
        else if(i >= H_RESOLUTION_DIV_13 * 7 && i < H_RESOLUTION_DIV_13 * 8) begin
            rom_0[i]  = LN10;
            rom_1[i]  = LN3;
            rom_2[i]  = LN9;
            rom_3[i]  = LN2;
            rom_4[i]  = LN8;
            rom_5[i]  = LN1;
            rom_6[i]  = LN7;
            rom_7[i]  = LN0;
            rom_8[i]  = LN6;
            rom_9[i]  = LN12;
            rom_10[i]  = LN5;
            rom_11[i]  = LN11;
            rom_12[i]  = LN4;
        end
        // Vertical Line 8
        else if(i >= H_RESOLUTION_DIV_13 * 8 && i < H_RESOLUTION_DIV_13 * 9) begin
            rom_0[i]  = LN4;
            rom_1[i]  = LN10;
            rom_2[i]  = LN3;
            rom_3[i]  = LN9;
            rom_4[i]  = LN2;
            rom_5[i]  = LN8;
            rom_6[i]  = LN1;
            rom_7[i]  = LN7;
            rom_8[i]  = LN0;
            rom_9[i]  = LN6;
            rom_10[i]  = LN12;
            rom_11[i]  = LN5;
            rom_12[i]  = LN11;
        end
        // Vertical Line 9
        else if(i >= H_RESOLUTION_DIV_13 * 9 && i < H_RESOLUTION_DIV_13 * 10) begin
            rom_0[i] = LN11;
            rom_1[i]  = LN4;
            rom_2[i]  = LN10;
            rom_3[i]  = LN3;
            rom_4[i]  = LN9;
            rom_5[i]  = LN2;
            rom_6[i]  = LN8;
            rom_7[i]  = LN1;
            rom_8[i]  = LN7;
            rom_9[i]  = LN0;
            rom_10[i]  = LN6;
            rom_11[i]  = LN12;
            rom_12[i]  = LN5;
        end
        // Vertical Line 10
        else if(i >= H_RESOLUTION_DIV_13 * 10 && i < H_RESOLUTION_DIV_13 * 11) begin
            rom_0[i] = LN5;
            rom_1[i]  = LN11;
            rom_2[i]  = LN4;
            rom_3[i]  = LN10;
            rom_4[i]  = LN3;
            rom_5[i]  = LN9;
            rom_6[i]  = LN2;
            rom_7[i]  = LN8;
            rom_8[i]  = LN1;
            rom_9[i]  = LN7;
            rom_10[i]  = LN0;
            rom_11[i]  = LN6;
            rom_12[i]  = LN12;
        end
        // Vertical Line 11
        else if(i >= H_RESOLUTION_DIV_13 * 11 && i < H_RESOLUTION_DIV_13 * 12) begin
            rom_0[i] = LN12;
            rom_1[i]  = LN5;
            rom_2[i]  = LN11;
            rom_3[i]  = LN4;
            rom_4[i]  = LN10;
            rom_5[i]  = LN3;
            rom_6[i]  = LN9;
            rom_7[i]  = LN2;
            rom_8[i]  = LN8;
            rom_9[i]  = LN1;
            rom_10[i]  = LN7;
            rom_11[i]  = LN0;
            rom_12[i]  = LN6;
        end
        // Vertical Line 12
        else if(i >= H_RESOLUTION_DIV_13 * 12 && i < H_RESOLUTION) begin
            rom_0[i] = LN6;
            rom_1[i]  = LN12;
            rom_2[i]  = LN5;
            rom_3[i]  = LN11;
            rom_4[i]  = LN4;
            rom_5[i]  = LN10;
            rom_6[i]  = LN3;
            rom_7[i]  = LN9;
            rom_8[i]  = LN2;
            rom_9[i]  = LN8;
            rom_10[i]  = LN1;
            rom_11[i]  = LN7;
            rom_12[i]  = LN0;
        end
    end
end


localparam [22:0]V_COORD_DIV_13 = V_RESOLUTION / 13;

reg [12:0]vline_en; //One-hot State Machine
parameter V0 = 13'b0_0000_0000_0001,
          V1 = 13'b0_0000_0000_0010,
          V2 = 13'b0_0000_0000_0100,
          V3 = 13'b0_0000_0000_1000,
          V4 = 13'b0_0000_0001_0000,
          V5 = 13'b0_0000_0010_0000,
          V6 = 13'b0_0000_0100_0000,
          V7 = 13'b0_0000_1000_0000,
          V8 = 13'b0_0001_0000_0000,
          V9 = 13'b0_0010_0000_0000,
          V10 = 13'b0_0100_0000_0000,
          V11 = 13'b0_1000_0000_0000,
          V12 = 13'b1_0000_0000_0000;

always @(*) begin
    // Vertical Line 0
    if(y_coord >= V_COORD_DIV_13 * 0 && y_coord < V_COORD_DIV_13 * 1) begin
        vline_en = V0;
    end
    // Vertical Line 1
    else if(y_coord >= V_COORD_DIV_13 * 1 && y_coord < V_COORD_DIV_13 * 2) begin
        vline_en = V1;
    end
    // Vertical Line 2
    else if(y_coord >= V_COORD_DIV_13 * 2 && y_coord < V_COORD_DIV_13 * 3) begin
        vline_en = V2;
    end
    // Vertical Line 3
    else if(y_coord >= V_COORD_DIV_13 * 3 && y_coord < V_COORD_DIV_13 * 4) begin
        vline_en = V3;
    end
    // Vertical Line 4
    else if(y_coord >= V_COORD_DIV_13 * 4 && y_coord < V_COORD_DIV_13 * 5) begin
        vline_en = V4;
    end
    // Vertical Line 5
    else if(y_coord >= V_COORD_DIV_13 * 5 && y_coord < V_COORD_DIV_13 * 6) begin
        vline_en = V5;
    end
    // Vertical Line 6
    else if(y_coord >= V_COORD_DIV_13 * 6 && y_coord < V_COORD_DIV_13 * 7) begin
        vline_en = V6;
    end
    // Vertical Line 7
    else if(y_coord >= V_COORD_DIV_13 * 7 && y_coord < V_COORD_DIV_13 * 8) begin
        vline_en = V7;
    end
    // Vertical Line 8
    else if(y_coord >= V_COORD_DIV_13 * 8 && y_coord < V_COORD_DIV_13 * 9) begin
        vline_en = V8;
    end
    // Vertical Line 9
    else if(y_coord >= V_COORD_DIV_13 * 9 && y_coord < V_COORD_DIV_13 * 10) begin
        vline_en = V9;
    end
    // Vertical Line 10
    else if(y_coord >= V_COORD_DIV_13 * 10 && y_coord < V_COORD_DIV_13 * 11) begin
        vline_en = V10;
    end
    // Vertical Line 11
    else if(y_coord >= V_COORD_DIV_13 * 11 && y_coord < V_COORD_DIV_13 * 12) begin
        vline_en = V11;
    end
    // Vertical Line 12
    else if(y_coord >= V_COORD_DIV_13 * 12 && y_coord < V_RESOLUTION) begin
        vline_en = V12;
    end
    else begin
        vline_en = 13'd0;
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        gray_data <= 8'd0;
    end
    else begin
        // Vertical Line 0
        case (vline_en)
            V0:
                gray_data <= rom_0[x_coord];
            V1:
                gray_data <= rom_1[x_coord];
            V2:
                gray_data <= rom_2[x_coord];
            V3:
                gray_data <= rom_3[x_coord];
            V4:
                gray_data <= rom_4[x_coord];
            V5:
                gray_data <= rom_5[x_coord];
            V6:
                gray_data <= rom_6[x_coord];
            V7:
                gray_data <= rom_7[x_coord];
            V8:
                gray_data <= rom_8[x_coord];
            V9:
                gray_data <= rom_9[x_coord];
            V10:
                gray_data <= rom_10[x_coord];
            V11:
                gray_data <= rom_11[x_coord];
            V12:
                gray_data <= rom_12[x_coord];

            default:
                gray_data <= 8'd0;
        endcase

        // if(y_coord >= V_COORD_DIV_13 * 0 && y_coord < V_COORD_DIV_13 * 1) begin
        //     gray_data <= rom_0[x_coord];
        // end
        // // Vertical Line 1
        // else if(y_coord >= V_COORD_DIV_13 * 1 && y_coord < V_COORD_DIV_13 * 2) begin
        //     gray_data <= rom_1[x_coord];
        // end
        // // Vertical Line 2
        // else if(y_coord >= V_COORD_DIV_13 * 2 && y_coord < V_COORD_DIV_13 * 3) begin
        //     gray_data <= rom_2[x_coord];
        // end
        // // Vertical Line 3
        // else if(y_coord >= V_COORD_DIV_13 * 3 && y_coord < V_COORD_DIV_13 * 4) begin
        //     gray_data <= rom_3[x_coord];
        // end
        // // Vertical Line 4
        // else if(y_coord >= V_COORD_DIV_13 * 4 && y_coord < V_COORD_DIV_13 * 5) begin
        //     gray_data <= rom_4[x_coord];
        // end
        // // Vertical Line 5
        // else if(y_coord >= V_COORD_DIV_13 * 5 && y_coord < V_COORD_DIV_13 * 6) begin
        //     gray_data <= rom_5[x_coord];
        // end
        // // Vertical Line 6
        // else if(y_coord >= V_COORD_DIV_13 * 6 && y_coord < V_COORD_DIV_13 * 7) begin
        //     gray_data <= rom_6[x_coord];
        // end
        // // Vertical Line 7
        // else if(y_coord >= V_COORD_DIV_13 * 7 && y_coord < V_COORD_DIV_13 * 8) begin
        //     gray_data <= rom_7[x_coord];
        // end
        // // Vertical Line 8
        // else if(y_coord >= V_COORD_DIV_13 * 8 && y_coord < V_COORD_DIV_13 * 9) begin
        //     gray_data <= rom_8[x_coord];
        // end
        // // Vertical Line 9
        // else if(y_coord >= V_COORD_DIV_13 * 9 && y_coord < V_COORD_DIV_13 * 10) begin
        //     gray_data <= rom_9[x_coord];
        // end
        // // Vertical Line 10
        // else if(y_coord >= V_COORD_DIV_13 * 10 && y_coord < V_COORD_DIV_13 * 11) begin
        //     gray_data <= rom_10[x_coord];
        // end
        // // Vertical Line 11
        // else if(y_coord >= V_COORD_DIV_13 * 11 && y_coord < V_COORD_DIV_13 * 12) begin
        //     gray_data <= rom_11[x_coord];
        // end
        // // Vertical Line 12
        // else if(y_coord >= V_COORD_DIV_13 * 12 && y_coord < V_RESOLUTION) begin
        //     gray_data <= rom_12[x_coord];
        // end
        // else begin
        //     gray_data <= 8'd0;
        // end
    end
end
endmodule
