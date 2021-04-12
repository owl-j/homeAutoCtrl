`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2021 16:17:15
// Design Name: 
// Module Name: lightsFSM
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


module lightsFSM(
    input reset,
    input masterEnable,
    input masterSwitch,
    input bathroomSwitch,
    input nightSensor,
    input bathroomSensor,
    input outdoorMotionSensor,
    output [2:0] led
    );
endmodule
