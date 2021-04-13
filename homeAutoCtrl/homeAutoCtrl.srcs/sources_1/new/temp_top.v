`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2021 14:07:37
// Design Name: 
// Module Name: temp_top
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


module temp_top(
    input wire sysclk,
    input wire btn_C,
    input wire [3:0] sw, //sw [3] is the enable signal, sw[2:0] is the 8-bit input
    input wire reset,
    output wire [3:0] ssdAnode,
    output wire [6:0] segment
    );
    
    //Seven Segment Display Output Encoding
    wire [15:0] fourDigitBCD;
    
    //Analog to Digital Conversion of "Confirm" Signal
    wire de_btn_C, ps_btn_C;    
    debouncer de_Center (.switchIn(btn_C),.clk(sysclk),.reset(reset),.debounceout(de_btn_C));
    spot spot_Center (.clk(sysclk), .spot_in(btn_C), .spot_out(ps_btn_C));
    
    // Temperature Control Logic
    tempFSM FSM (
        .clk(sysclk),
        .reset(reset),
        .confirm(ps_btn_C),
        .targetSws(sw[2:0]),
        .enable(sw[3]),
        .ssdDisplay(fourDigitBCD)
        );
    
    // SSD Display Controller
    fourDigitSSDController displayCtrl(
        .displayEncoding(fourDigitBCD),
        .clk(sysclk),
        .reset(reset),
        .ssdAnode(ssdAnode),
        .ssdCathode(segment)
    );
endmodule
