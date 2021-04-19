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
    wire [15:0] fourDigitBCD;     // Seven Segment Display Output Encoding
    
    fourDigitSSDController displayCtrl(
        .displayEncoding(fourDigitBCD),
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
    /     1. Light Controller
    /     2. Temperature Controller
    /     3. Garage Door Controller
    */
    // 1. Light Controller
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
        .nextBtn(ps_btn_N),
        .led(lights)
    );
    
    // 2. Temperature Controller
    tempFSM temperatureController (
        .clk(sysclk),
        .reset(reset),
        .confirm(ps_btn_E),
        .targetSws(sw[2:0]),
        .enable(sw[3]),
        .ssdDisplay(fourDigitBCD)
        );
    
    // 3. Garage Door Controller
    garagedoor garageController (
        .clk(sysclk),
        .reset(reset),
        .remote_btn(ps_btn_W),
        .col_sens(sw[5]),
        .LEDs(garage)
        );
    
    // 4. Overall Controller
    /*overrideFSM overrideController (
        .clk(sysclk),
        .reset(reset),
        .on_off_sw(sw[6])),
        .enable(global_enable)
    );*/
    
endmodule
