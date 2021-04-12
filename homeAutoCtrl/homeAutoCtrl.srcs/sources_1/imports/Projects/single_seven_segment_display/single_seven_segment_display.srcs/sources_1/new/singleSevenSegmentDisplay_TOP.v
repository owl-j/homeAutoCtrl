`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2021 12:20:56
// Design Name: 
// Module Name: singleSevenSegmentDisplay_TOP
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


module singleSevenSegmentDisplay_TOP(
    input wire clk,
    input wire reset,
    input wire enable,
    output wire [6:0] ssdCathode,
    output wire [3:0] ssdAnode
    );
    
    wire beat;
    reg [3:0] counter; // to count to 10 on the SSD
    assign ssdAnode = 4'b0111;
    
    heartbeat #(.TOPCOUNT(100_000_000))
        UUT (.clk(clk), .reset(reset), .beat(beat));
    
    sevenSegmentDecoder decoder(
        .bcd(counter),
        .ssd(ssdCathode)
    );
    

    
    always @(posedge clk) begin
        if (reset || counter >= 10) begin
            counter <= 4'b0;
        end else if (beat & enable) begin
            counter <= counter + 1'b1;
        end
    end
    
    
endmodule
