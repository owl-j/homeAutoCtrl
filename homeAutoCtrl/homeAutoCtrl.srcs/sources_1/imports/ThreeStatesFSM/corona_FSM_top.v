`timescale 1ns / 1ps
module corona_FSM_top(
    input wire clk,
    input wire reset,
    input wire btn_N,
    input wire btn_S,
    input wire btn_E,
    input wire btn_W,
    output wire [15:0] led
);
wire de_btn_N, de_btn_S, de_btn_E, de_btn_W;
wire ps_btn_N, ps_btn_S, ps_btn_E, ps_btn_W;

// Button Debouncers
debouncer de_North (.switchIn(btn_N),.clk(clk),.reset(reset),.debounceout(de_btn_N));
debouncer de_South (.switchIn(btn_S),.clk(clk),.reset(reset),.debounceout(de_btn_S));
debouncer de_East (.switchIn(btn_E),.clk(clk),.reset(reset),.debounceout(de_btn_E));
debouncer de_West (.switchIn(btn_W),.clk(clk),.reset(reset),.debounceout(de_btn_W));

// Button SPOTs
spot spot_North (.clk(clk), .spot_in(de_btn_N), .spot_out(ps_btn_N));
spot spot_South (.clk(clk), .spot_in(de_btn_S), .spot_out(ps_btn_S));
spot spot_East (.clk(clk), .spot_in(de_btn_E), .spot_out(ps_btn_E));
spot spot_West (.clk(clk), .spot_in(de_btn_W), .spot_out(ps_btn_W));

// FSM
FSM_corona FSM(
    .clk(clk),
    .reset(reset),
    .btn_N(ps_btn_N),
    .btn_S(ps_btn_S),
    .btn_E(ps_btn_E),
    .btn_W(ps_btn_W),
    .LED(led)
);

endmodule
    