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
    input wire clk, // Assumes a clk of 100MHz
    input wire enable // On/Off Switch for the function
    );
    
    
    // State Encodings
    parameter OFF=2'd0,SETTEMP=2'd1, MEETTEMP=2'd2, DONE=2'd3;
    // State Registers
    reg [1:0] state, nextState;
    // Variables
    reg [3:0] count; // Used to hold the needed delta room temperature.
    reg [3:0] outsideTemp = 4'd4; // Constant, can be replaced with any number 4'h 0 to 7.
    reg [3:0] roomTemp = 4'd4; // Register to hold room temperature
    wire [3:0] targetTemp; // Register to hold desired temperature
    wire oneHzbeat, halfHzbeat; // Assuming a clk of 100MHz
    
    heartbeat #(.TOPCOUNT(100_000_000)) one_Hz_hb (.clk(clk),.reset(1'b0),.beat(oneHzbeat));
    heartbeat #(.TOPCOUNT(200_000_000)) one_half_Hz_hb (.clk(clk),.reset(1'b0),.beat(halfHzbeat));
    
    assign targetTemp = targetSws;
    
  
    // State Memory
    always @(posedge clk) begin
        if (reset | ~enable) begin
            state <= OFF;
        end else begin
            state <= nextState;
        end
    end
    
    // Next State Logic
    always @(*) begin
        case(state)
            OFF: begin
                if(enable) begin
                    nextState = SETTEMP;
                end else begin
                    nextState = OFF;
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
                if(confirm) nextState = SETTEMP;
                else nextState = DONE;
            end    
            default : nextState = OFF;
        endcase
    end
        
    // Output Logic
    always @(*) begin
        case(state)
            OFF : ssdDisplay = {8'hB2,roomTemp,4'hC}; // "r<roomTemp>"
            SETTEMP : ssdDisplay = {8'hd2,targetTemp,4'hC}; // "d-<targetTemp>"
            //MEETTEMP : ssdDisplay = {4'h2,targetTemp,4'h2,roomTemp}; // "<targetTemp><setTemp>" Use for debugging
            MEETTEMP: ssdDisplay = {8'hB2,roomTemp,4'hC};
            DONE : ssdDisplay = {8'hB2,roomTemp,4'hC};
            default : ssdDisplay = 16'h0000;
        endcase
    end
    
    // CLIMATE CONTROL LOGIC
    // count logic
    always @(*) begin
        // If the system is off, calculate the temperature difference between room and outside
        if (state == OFF) begin
            if (roomTemp >= outsideTemp) begin
                count = roomTemp - outsideTemp;
            end else begin
                count = outsideTemp - roomTemp;
            end
        // System is On, calcualte the temperature difference between room and desired
        end else begin
            if (targetTemp >= roomTemp) begin
                count = targetTemp - roomTemp;
            end else begin
                count = roomTemp - targetTemp;
            end
        end
    end
    
    // Heating/Cooling Logic
    always @(posedge clk) begin
        if (count >= 1) begin
            // If OFF, simulate the room temperature changing to meet outside temperature
            if (state ==OFF) begin
                if(roomTemp < outsideTemp & halfHzbeat) begin
                    roomTemp <= roomTemp + 1;
                end else if (halfHzbeat) begin
                    roomTemp <= roomTemp - 1;
                end
            // If On, actively cool or heat room 
            end else if (state==MEETTEMP) begin
                if(roomTemp < targetTemp & oneHzbeat) begin
                    roomTemp <= roomTemp + 1;
                end else if (oneHzbeat) begin
                    roomTemp <= roomTemp - 1;
                end
            end
        end
    end
    
endmodule
