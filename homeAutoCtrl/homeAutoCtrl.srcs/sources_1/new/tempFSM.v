`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Oliver Johnson u6406755
// 
// Create Date: 11.04.2021 16:17:15
// Design Name: 
// Module Name: tempFSM
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


module tempFSM(
    output reg [15:0] ssdDisplay,
    input wire [2:0] targetSws,
    input wire reset,
    input wire confirm,
    input wire clk
    );
    
    
    // State Encodings
    parameter IDLE=2'd0,SETTEMP=2'd1, MEETTEMP=2'd2, DONE=2'd3;
    // State Registers
    reg [1:0] state, nextState;
    // Number of degrees until reached
    reg [3:0] count;
    reg [3:0] outsideTemp = 4'd0;
    wire [3:0] targetTemp;
    wire beat;
    
    heartbeat #(.TOPCOUNT(100_000_000)) one_Hz_hb (.clk(clk),.reset(1'b0),.beat(beat));
    
    assign targetTemp = targetSws;
    
  
    // State Memory
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= nextState;
        end
    end
    
    // Next State Logic
    always @(*) begin
        case(state)
            IDLE: begin
                if(confirm) begin
                    nextState = SETTEMP;
                end else begin
                    nextState = IDLE;
                end
            end
            SETTEMP: begin
                if(confirm) begin
                    nextState = MEETTEMP;
                end else begin
                    nextState = SETTEMP;
                end
            end
            MEETTEMP: begin
                if(count == 4'b0) begin
                    nextState = DONE;
                end else begin
                    nextState = MEETTEMP;
                end
            end
            DONE: begin
                if(confirm) begin
                    nextState = SETTEMP;
                end else begin
                    nextState = DONE;
                end
            end                    
            default : nextState = IDLE;
        endcase
    end
        
    // Output Logic
    always @(*) begin
        if (reset) ssdDisplay = 16'hAAAA;
        else if (confirm) ssdDisplay = 16'h0000;
        else if (state == IDLE) begin
            // Display only current Temp
            // 4'hA -> underscore signal for decoder
            ssdDisplay = {12'hAA2,outsideTemp};
        end else if (state == SETTEMP) begin
            ssdDisplay = {4'h2,targetTemp,8'hAA};
        end else begin
            // Display setTemp and currentTemp when MEETTEMP or DONE
            ssdDisplay = {4'h2,targetTemp,4'h2,outsideTemp};           
        end
    end
    
    // HEATING/COOLING LOGIC
    // count logic
    always @(*) begin
        if (targetTemp >= outsideTemp) begin
            count = targetTemp - outsideTemp;
        end else begin
            count = outsideTemp - targetTemp;
        end
    end
    
    // Temperature Change Logic
    always @(posedge clk) begin
        if (count >= 1 & state==MEETTEMP) begin
            if(targetTemp > outsideTemp & beat) begin
                outsideTemp <= outsideTemp + 1;
            end else if (beat) begin
                outsideTemp <= outsideTemp - 1;
            end
        end
    end
    
endmodule
