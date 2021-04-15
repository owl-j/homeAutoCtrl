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
    input wire reset,
    input wire masterEnable,
    input wire masterSwitch,
    input wire bathroomSwitch,
    input wire nightSensor,
    input wire bathroomSensor,
    input wire outdoorMotionSensor,
    output wire [2:0] led
    );
    
    reg bathroomLight, outdoorLight;
    reg modeOutput;
    
    assign led = {bathroomLight,outdoorLight,masterEnable};
    
    // Master Override Logic
    always @(*) begin
        if(masterEnable) begin
            bathroomLight = masterSwitch;
            outdoorLight = masterSwitch;
        end else begin
            bathroomLight = bathroomSensor; // NOTE: If the sensor stops detecting motion then it will immediately turn off.
            outdoorLight = modeOutput;
        end
    end
    
    //
    
    
    
endmodule
