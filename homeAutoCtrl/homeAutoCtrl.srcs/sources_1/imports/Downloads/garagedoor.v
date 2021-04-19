`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Manas Prasad u6985131
// 
// Create Date: 15.04.2021 12:40:46
// Design Name: 
// Module Name: garagedoor
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


module garagedoor(
    input wire clk,
    input wire remote_btn,
    input wire enable,
    input wire reset,
    input wire col_sens,
    output reg [5:0] LEDs
    );
    
    parameter CLOSED = 3'd0, OPENING = 3'd1, OPEN = 3'd2, CLOSING = 3'd3, STOP = 3'd4, COL = 3'd5, IDLE =3'd6;
    
    reg [2:0] state, nextstate, prevstate;
        
    wire oneHzbeat;
    
    reg [3:0] oldCounter;
    reg [1:0] delay;
    
    reg [3:0] counter;
    reg [15:0] LED_count_display;
    
    heartbeat #(.TOPCOUNT(100000000))
        this_hearbeat(.clk(clk), .reset(reset), .beat(oneHzbeat));
    
    always @(posedge clk) begin
        if (~enable)
            state <= IDLE;
        else if (reset) 
            state <= CLOSED;
        else
            state <= nextstate;
    end
        
    // Input state transitions
    
    always @(*) begin
        case (state)
            STOP : begin
                if (remote_btn && prevstate == CLOSING) begin
                    nextstate = OPENING;
                end
                else if (remote_btn && prevstate == OPENING) begin
                    nextstate = CLOSING;
                end
                else
                    nextstate = STOP;
            end
            CLOSED : begin
                if (remote_btn)
                    nextstate = OPENING;
                else
                    nextstate = CLOSED;
            end
            
            OPENING : begin
                if (remote_btn) begin
                    nextstate = STOP;
                end else if (counter >= 10)
                    nextstate = OPEN;
                else
                    nextstate = OPENING;
            end
            
            OPEN : begin
                if (remote_btn)
                    nextstate = CLOSING;
                else
                    nextstate = OPEN;
            end
            
            CLOSING : begin
                if (remote_btn) begin
                    nextstate = STOP;
                end else if (col_sens) begin
                    nextstate = COL;
                end else if (counter >= 10)
                    nextstate = CLOSED;
                else
                    nextstate = CLOSING;
            end
            
            COL : begin
                if (delay == 2'b0)
                    nextstate = OPENING;
                else nextstate = COL;
            end
            
            IDLE : begin
                if (enable)
                    nextstate = CLOSED;
                else
                    nextstate = IDLE;
            end
            default : nextstate = IDLE;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        case (state)
            CLOSED : LEDs = 6'b111110;
            OPENING : LEDs = {LED_count_display,1'b1};
            CLOSING : LEDs = {LED_count_display,1'b1};
            STOP : LEDs = {LED_count_display,1'b0};
            OPEN : LEDs = 6'b100010;
            IDLE : LEDs = 6'd0;
            default : LEDs = 6'd0;
        endcase
   end
   
   always @(posedge clk) begin
    if (state == STOP)
        prevstate <= prevstate;
    else 
        prevstate <= state;
   end
   // Collision Delay logic
   always @(posedge clk) begin
    if (reset || state!=COL)
        delay <= 2'b11;
    else if (oneHzbeat)
        delay <= delay - 1;
    end
   
   // Counter logical logic
   
   always @(posedge clk) begin
        if (reset || state==CLOSED) 
            counter <= 0;
        else if (state == OPEN)
            counter <= 9;
        else if (state==STOP)
            counter <= counter;
        else if ((state == OPENING) & oneHzbeat==1)
            counter <= counter + 1;
        else if ((state == CLOSING) & oneHzbeat==1)
            counter <= counter - 1;
        
   end
   
   // Counter LED logic 
   always @(*) begin
      case (counter)
        4'd0 : LED_count_display = 5'b00000;
        4'd1 : LED_count_display = 5'b10000;
        4'd2 : LED_count_display = 5'b10000;
        4'd3 : LED_count_display = 5'b11000;
        4'd4 : LED_count_display = 5'b11000;
        4'd5 : LED_count_display = 5'b11100;
        4'd6 : LED_count_display = 5'b11100;
        4'd7 : LED_count_display = 5'b11110;
        4'd8 : LED_count_display = 5'b11110;
        4'd9 : LED_count_display = 5'b11111;
        default : LED_count_display = 5'b00000;
     endcase
   end
endmodule
