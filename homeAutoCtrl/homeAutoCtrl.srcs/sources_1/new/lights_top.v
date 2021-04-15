`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2021 14:18:17
// Design Name: 
// Module Name: lights_top
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


module lights_top(
    input wire [15:9] sw,
    input wire nextBtn,
    input wire sysclk,
    input wire reset,
    output wire [6:0] led
    );
    
    wire de_nextBtn, ps_nextBtn;    
    debouncer de_Center (.switchIn(nextBtn),.clk(sysclk),.reset(reset),.debounceout(de_nextBtn));
    spot spot_Center (.clk(sysclk), .spot_in(de_nextBtn), .spot_out(ps_nextBtn));
    
    lightsFSM lightController (
        .reset(reset),
        .clk(sysclk),
        .masterEnable(sw[15]),
        .masterSwitch(sw[14]),
        .bathroomLightSwitch(sw[13]),
        .bathroomSensor(sw[12]),
        .nightSensor(sw[11]),
        .outdoorMotionSensor(sw[10]),
        .outdoorLightSwitch(sw[9]),
        .nextBtn(nextBtn),
        .led(led)
    );
endmodule
