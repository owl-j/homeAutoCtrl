`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2021 16:30:17
// Design Name: 
// Module Name: overrideFSM
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


module overrideFSM(
    input wire clk,
    input wire reset,
    input wire on_off_sw,
    output wire global_enable,
    output wire [15:0] ssdEncoding
    );
    
    parameter OFF=2'd0, START=2'd1, ON=2'd2;
    
    reg [1:0] state, nextState;
    
    // State Memory
    always @(posedge clk) begin
        if (~on_off_sw) state <= OFF
        else if (reset) state <= START
        else state <= nextState
    end
    
    // State Transitions
    always @(*) begin
        case(state)
            OFF : begin
                if(on_off_sw)
                    nextState = START
                else
                    nextState = OFF
            end   
            START : begin
                if (delay == 2'b0)
                    nextState = ON;
                else
                    nextState = START;
            end
            ON : begin
                nextState = ON;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        case(state)
            OFF : begin
                global_enable = 1'b0
                ssdEncoding = 16'hA0FF;
            end
            START : begin
                global_enable = 1'b0;
                ssdEncoding = 16'hAA0E;
            end
            ON : begin
                global_enable = 1'b1;
                ssdEncoding
                    
            
endmodule
