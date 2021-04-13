`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2021 13:32:20
// Design Name: 
// Module Name: sevenSegmentDecoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sevenSegmentDecoder(
    input wire [3:0] bcd,
    output reg [6:0] ssd
    );
    
    always @(*) begin
        case(bcd)
            4'h0 : ssd = 7'b0000001;
            4'h1 : ssd = 7'b1001111;
            4'h2 : ssd = 7'b0010010;
            4'h3 : ssd = 7'b0000110;
            4'h4 : ssd = 7'b1001100;
            4'h5 : ssd = 7'b0100100;
            4'h6 : ssd = 7'b0100000;
            4'h7 : ssd = 7'b0001111;
            4'h8 : ssd = 7'b0000000;
            4'h9 : ssd = 7'b0001100;
            4'hA : ssd = 7'b1111111; // All Off
            4'hB : ssd = 7'b1111010; // Letter R
            4'hC : ssd = 7'b0111100; // Letter C
            4'hD : ssd = 7'b1000010; // Letter D
            default : ssd = 7'b1111111;
        endcase
    end
endmodule
