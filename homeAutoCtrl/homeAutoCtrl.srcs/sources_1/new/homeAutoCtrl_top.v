`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2021 16:17:15
// Design Name: 
// Module Name: homeAutoCtrl_top
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


module homeAutoCtrl_top(
    input wire sysclk,
    input wire [15:0] sw,
    input wire btn_N,
    input wire btn_E,
    input wire btn_S,
    input wire btn_W,
    input wire btn_C,
    output wire [15:0] led,
    output wire [3:0] an,
    output wire [6:0] seg
    );  
    

    
    /*
    / INPUT CONTROL LOGIC
    /     1. Analog to Digital Conversion of Buttons
    /     
    */
    
    wire de_btn_C, ps_btn_C; // Reset Button
    wire de_btn_N, ps_btn_N; // Outdoor Light Mode Button
    wire de_btn_E, ps_btn_E; // Temperature Confirm Button
    wire de_btn_S, ps_btn_S;
    wire de_btn_W, ps_btn_W;
    
    wire reset = ps_btn_C;
    
    debouncer de_Center (.switchIn(btn_C),.clk(sysclk),.reset(reset),.debounceout(de_btn_C));
    debouncer de_North (.switchIn(btn_N),.clk(sysclk),.reset(reset),.debounceout(de_btn_N));
    debouncer de_South (.switchIn(btn_S),.clk(sysclk),.reset(reset),.debounceout(de_btn_S));
    debouncer de_East (.switchIn(btn_E),.clk(sysclk),.reset(reset),.debounceout(de_btn_E));
    debouncer de_West (.switchIn(btn_W),.clk(sysclk),.reset(reset),.debounceout(de_btn_W));
    spot spot_Center (.clk(sysclk), .spot_in(de_btn_C), .spot_out(ps_btn_C));
    spot spot_North (.clk(sysclk), .spot_in(de_btn_N), .spot_out(ps_btn_N));
    spot spot_South (.clk(sysclk), .spot_in(de_btn_S), .spot_out(ps_btn_S));
    spot spot_East (.clk(sysclk), .spot_in(de_btn_E), .spot_out(ps_btn_E));
    spot spot_West (.clk(sysclk), .spot_in(de_btn_W), .spot_out(ps_btn_W));
    
    
    /* 
    / OUTPUT CONTROL LOGIC
    /     1. SSD Display Controller
    /     2. LED Display Logic
    */
    // 1. SSD Display Controller: Maps Logic Encodings to 4-digit SSD output.
    reg [15:0] displayEncoding;
    wire [15:0] fourDigitBCD;     // Seven Segment Display Encodings
    
    fourDigitSSDController displayCtrl(
        .displayEncoding(displayEncoding),
        .clk(sysclk),
        .reset(reset),
        .ssdAnode(an),
        .ssdCathode(seg)
    );
    
    // 2. LED output concatenation.
    wire [2:0] lights;
    wire [5:0] garage;
    
    assign led = {lights,7'b0,garage};
    
    
    /* 
    / FUNCTION CONTROLLERS
    /     1. Override Controller
    /     2. Light Controller
    /     3. Temperature Controller
    /     4. Garage Door Controller
    */
    // 1. Override Controller
    parameter OFF=2'd0, START=2'd1, ON=2'd2;
    
    wire oneHzbeat;
    
    heartbeat #(.TOPCOUNT(100000000))
        this_hearbeat(.clk(sysclk), .reset(reset), .beat(oneHzbeat));
    
    reg [1:0] state, nextState;
    wire on_off_sw = sw[6];
    reg [1:0] delay = 2'b11;
    reg global_enable = 1'b0;
    
    // State Memory
    always @(posedge sysclk) begin
        if (~on_off_sw) state <= OFF;
        else if (reset) state <= START;
        else state <= nextState;
    end
    
    // State Transitions
    always @(*) begin
        case(state)
            OFF : begin
                if(on_off_sw)
                    nextState = START;
                else
                    nextState = OFF;
            end   
            START : begin
                if (delay == 2'b0)
                    nextState = ON;
                else
                    nextState = START;
            end
            ON : begin
                nextState = ON;
            end
            default : nextState = OFF;
        endcase
    end
    
    // Output Logic
    always @(*) begin
        case(state)
            OFF : begin
                global_enable = 1'b0;
                displayEncoding = 16'hA0FF;
            end
            START : begin
                global_enable = 1'b0;
                displayEncoding = {2'b00,delay,12'hA0E};
            end
            ON : begin
                global_enable = 1'b1;
                displayEncoding = fourDigitBCD;
            end
            default : begin
                global_enable = 1'b0;
                displayEncoding = 16'hAAAA;
            end
        endcase
    end
    
    always @(posedge sysclk) begin
        if(reset || state == OFF || state == ON)
            delay <= 2'b11;
        else if(oneHzbeat)
            delay <= delay - 1;
    end
    
    
    // 2. Light Controller
    lightsFSM lightController (
        .reset(reset),
        .clk(sysclk),
        .masterEnable(sw[15]),
        .enable(global_enable),
        .masterSwitch(sw[14]),
        .bathroomLightSwitch(sw[13]),
        .bathroomSensor(sw[12]),
        .nightSensor(sw[11]),
        .outdoorMotionSensor(sw[10]),
        .outdoorLightSwitch(sw[9]),
        .nextBtn(ps_btn_N),
        .led(lights)
    );
    
    // 3. Temperature Controller
    tempFSM temperatureController (
        .clk(sysclk),
        .reset(reset),
        .confirm(ps_btn_E),
        .targetSws(sw[2:0]),
        .enable(global_enable),
        .ssdDisplay(fourDigitBCD)
        );
    
    // 4. Garage Door Controller
    garagedoor garageController (
        .clk(sysclk),
        .reset(reset),
        .remote_btn(ps_btn_W),
        .col_sens(sw[5]),
        .LEDs(garage),
        .enable(global_enable)
        );
    
    
endmodule
