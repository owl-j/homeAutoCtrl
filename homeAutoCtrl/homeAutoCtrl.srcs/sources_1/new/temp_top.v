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
    input wire [2:0] sw,
    input wire reset,
    output wire [15:0] LED,
    output wire [3:0] ssdAnode,
    output wire [6:0] segment
    );
    wire [15:0] fourDigitBCD;
    wire de_btn_C, ps_btn_C;
    assign LED = fourDigitBCD;
    //Analog to Digital Conversion of "Confirm" Signal
    //debouncer de_Center (.switchIn(btn_C),.clk(clk),.reset(reset),.debounceout(de_btn_C));
    spot spot_Center (.clk(clk), .spot_in(btn_C), .spot_out(ps_btn_C));
    
    // Temperature Control Logic
    tempFSM FSM (
        .clk(sysclk),
        .reset(reset),
        .confirm(ps_btn_C),
        .targetSws(sw),
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
