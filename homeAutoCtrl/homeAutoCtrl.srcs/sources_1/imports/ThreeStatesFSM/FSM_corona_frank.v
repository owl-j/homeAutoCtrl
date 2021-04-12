`timescale 1ns / 1ps

module FSM_corona_frank(
    input wire clk,
    input wire reset,
    input wire btn_N,
    input wire btn_S,
    input wire btn_E,
    input wire btn_W,
    output reg [15:0] LED
    );
    
    //Input encoding
    parameter N = 2'b10, S = 2'b01, W = 2'b00, E = 2'b11;
    
    //State encoding
    parameter START=2'd0, MOVE=2'd1, FINISH=2'd2;
    
    //Correct Steps
    wire [11:0] correct_steps;
    assign correct_steps= {N, W, W, S, E, S};
    
    //State registers
    reg [1:0] state, next_state;
    
    //Counter to count the number of inputs
    reg [2:0] counter;
    
    //Map counter value to LED pattern
    reg [15:0] LED_count;
    
    //Store input sequence
    reg [1:0] newInput; //store new input
    reg [11:0] storedInput = 12'd0;
    
    //Added countdown block
    /*wire beat; 
    reg [1:0] countDownCounter;
    reg countDownFlag;
    heartbeat #(.TOPCOUNT(100_000_000)) beatForCountdown (.clk(clk), .reset(reset), .beat(beat)); 
	always @ (posedge clk) begin 
		if (reset) begin
			countDownCounter <= 2'b11;
		end else if (state == FINISH && beat) begin 
			countDownCounter <= countDownCounter - 1'b1; 
		end
	end
    
    always @(posedge clk) begin
        if (reset) begin
            countDownFlag <= 0;
        end else if (!countDownCounter) begin
            countDownFlag <= 1;
        end
    end*/
    // State Memory
    always @(posedge clk) begin
        if (reset) begin
            state <= START;
        end else begin
            state <= next_state;
        end
    end
    
    // Next State Logic
    always @(*) begin
        case (state)
            START: begin
                if (btn_N | btn_S | btn_E | btn_W) begin //press any button to leave START state
                    next_state = MOVE;
                end else begin 
                    next_state = START;
                end
            end
            MOVE: begin
                if (counter == 6) begin
                    next_state = FINISH;               
                end else begin 
                    next_state = MOVE;
                end
            end
            FINISH: begin 
                next_state = FINISH;
            end
            
            default next_state = START; 
        endcase
    end
        
    // Output logic
    always @(*) begin
        case (state)
            START: begin 
                LED = 16'hf00f;
            end
            MOVE: begin 
                LED = LED_count;
            end
            FINISH: begin
                /*if (!countDownFlag) begin
                    LED = 16'd63; //six LEDs are on
                end else*/ if (storedInput == correct_steps) begin 
                    LED = 16'hffff; //all LEDs are on if input sequence is correct
                end else begin 
                    LED = 16'haaaa; //LED pattern when input is incorrect
                end
            end
            default: LED = 16'd0; 
        endcase
    end
    
    // Logic for updating counter
    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
        end else if ((btn_N|btn_S|btn_W|btn_E) & !(state == START)) begin
            counter <= counter + 1;
        end
    end
    
    always @(*) begin
        if (btn_N) begin
            newInput = N;
        end else if (btn_S) begin
            newInput = S;
        end else if (btn_E) begin
            newInput = E;
        end else if (btn_W) begin
            newInput = W;
        end else begin
            newInput = 2'd0; //to avoid inferred latch
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            storedInput <= 12'd0;
        end else if (btn_N|btn_S|btn_E|btn_W) begin
            storedInput <= {storedInput[9:0], newInput[1:0]};
        end else begin
            storedInput <= storedInput;
        end
    end
    
    //Map counter value to LED pattern
    always @(*) begin
        case(counter)
            3'd0: LED_count = 16'd0; 
            3'd1: LED_count = 16'd1; 
            3'd2: LED_count = 16'd3;
            3'd3: LED_count = 16'd7;
            3'd4: LED_count = 16'd15;
            3'd5: LED_count = 16'd31; 
            //no need to write the case for 3'd6
            default: LED_count = 16'd0;
        endcase
    end
   
endmodule
