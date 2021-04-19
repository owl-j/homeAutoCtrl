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
    input wire bathroomLightSwitch,
    input wire nightSensor,
    input wire bathroomSensor,
    input wire outdoorMotionSensor,
    input wire outdoorLightSwitch,
    input wire nextBtn,
    input wire clk,
    output wire [2:0] led
    );
    
    reg bathroomLight, outdoorLight;
    reg outdoorFSMoutput;
    reg [1:0] OMSDelay;
    reg [1:0] state, nextState;
    assign led = {bathroomLight,outdoorLight,masterEnable};
    heartbeat #(.TOPCOUNT(100_000_000)) one_Hz_hb (.clk(clk),.reset(1'b0),.beat(oneHzbeat));
    
    // Master Override Logic
    always @(*) begin
        if(masterEnable) begin
            bathroomLight = masterSwitch;
            outdoorLight = masterSwitch;
        end else begin
            bathroomLight = bathroomLightSwitch | bathroomSensor; // NOTE: If the sensor stops detecting motion then it will immediately turn off.
            outdoorLight = outdoorFSMoutput;
        end
    end
    
    // NLMODE -> Night-Light mode, control determined by daylight sensor
    // SECMODE -> Security Mode, control determined by movement sensor
    // DUMB -> Control determined by local switch
    parameter DUMB=2'd0, NLMODE=2'd1, SECMODE=2'd2;
    

    
    // State Memory
    always @(posedge clk) begin
        if (reset) begin
            state <= DUMB;
        end else begin
            state <= nextState;
        end
    end
    
    // Outdoor Lights State Transition Logic
    always @(*) begin
        case (state)
            DUMB : begin
                if (nextBtn) nextState = NLMODE;
                else nextState = DUMB;
            end
            NLMODE : begin
                if (nextBtn) nextState = SECMODE;
                else nextState = NLMODE;
            end
            SECMODE : begin
                if (nextBtn) nextState = DUMB;
                else nextState = SECMODE;
            end
            default : nextState = DUMB;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        case (state)
            DUMB : outdoorFSMoutput = outdoorLightSwitch;
            NLMODE : outdoorFSMoutput = nightSensor;
            SECMODE : outdoorFSMoutput = nightSensor && (outdoorMotionSensor || OMSDelay);
            default : outdoorFSMoutput = 0;
        endcase
    end
    
    //OMSDelay Logic -> When to start delay
    always @(posedge clk) begin
        if (reset) begin
            OMSDelay <= 2'b0;
        end 
        if (outdoorMotionSensor) OMSDelay <= 2'b11;
        else if (oneHzbeat) begin
            if (OMSDelay >= 1) OMSDelay <= OMSDelay - 1;
        end
    end
endmodule
