`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2021 13:53:58
// Design Name: 
// Module Name: fourDigitSSDController
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


module fourDigitSSDController(
    input wire [15:0] displayEncoding,
    input wire clk,
    input wire reset,
    output reg [3:0] ssdAnode,
    output wire [6:0] ssdCathode
    );
    
    wire beat;
    reg [1:0] activeDisplay;
    reg [3:0] ssdValue;
    
    // Refresh rate
    heartbeat #(.TOPCOUNT(100_000)) one_kHz_beat (.clk(clk),.reset(1'b0),.beat(beat));
    // Decoder
    sevenSegmentDecoder decoder(.bcd(ssdValue),.ssd(ssdCathode));
    
    
    // Each beat refresh the activeDisplay
    always @(posedge beat) begin
        activeDisplay = activeDisplay + 1'b1; // 2-bit overflow counter
    end
    
    always @(*) begin
        case(activeDisplay)
            2'd0 : begin
                ssdValue = displayEncoding[15:12]; //1st digit 
                ssdAnode = 4'b0111;
            end
            2'd1 : begin
                ssdValue = displayEncoding[11:8]; //2nd digit
                ssdAnode = 4'b1011;
            end            
            2'd2 : begin
                ssdValue = displayEncoding[7:4]; //3rd digit
                ssdAnode = 4'b1101;
            end            
            2'd3 : begin
                ssdValue = displayEncoding[3:0]; //4th digit
                ssdAnode = 4'b1110;
            end
            default : begin
                ssdValue = 4'd10; // undefined
                ssdAnode = 4'b1111;
            end
        endcase
    end
endmodule
