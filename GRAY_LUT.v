module GRAY_LUT#
       (
           parameter GRAY_RESOLUTION = 1920
       )
       (
           input clk,
           input rstn,
           input [22:0]coord,
           output reg [7:0]gray_data
       );

reg [7:0]rom[0: GRAY_RESOLUTION-1];
integer i;

initial begin
    for(i = 0; i < GRAY_RESOLUTION; i = i + 1) begin
        rom[i] = (i * 255) / (GRAY_RESOLUTION - 1);
    end
end

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        gray_data <= 8'd0;
    end
    else begin
        gray_data <= rom[coord];
    end
end
endmodule
