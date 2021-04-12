`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2021 14:42:20
// Design Name: 
// Module Name: multipleSevenSegmentDisplays_TOP
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


module multipleSevenSegmentDisplays_TOP(
    input wire clk,
    input wire reset,
    input wire enable,
    output reg [3:0] ssdAnode,
    output wire [6:0] ssdCathode
    );
    
    wire beat;
    reg [1:0] activeDisplay;
    reg [3:0] ssdValue;
    
    heartbeat #(.TOPCOUNT(100_000))
        one_kHz_beat (.clk(clk),.reset(1'b0),.beat(beat));
    
    sevenSegmentDecoder decoder(
        .bcd(ssdValue),
        .ssd(ssdCathode)
    );
    
    always @(posedge beat) begin
        activeDisplay = activeDisplay + 1'b1; // This should be a 2 bit overflow counter
    end
    
    always @(*) begin
        case(activeDisplay)
            2'd0 : begin
                ssdValue = 4'd2; //1st digit 
                ssdAnode = 4'b0111;
            end
            2'd1 : begin
                ssdValue = 4'd0; //2nd digit
                ssdAnode = 4'b1011;
            end            
            2'd2 : begin
                ssdValue = 4'd2; //3rd digit
                ssdAnode = 4'b1101;
            end            
            2'd3 : begin
                ssdValue = 4'd1; //4th digit
                ssdAnode = 4'b1110;
            end
            default : begin
                ssdValue = 4'd10; // undefined
                ssdAnode = 4'b1111;
            end
        endcase
    end
                
                
endmodule
