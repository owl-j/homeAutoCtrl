module debouncer #( 
    parameter TOPCOUNT = 2_000_000 // Sample rate =  ((100_000_000/TOPCOUNT) * 3)
    )(
    input wire switchIn,
    input wire clk,
    input wire reset,
    output wire debounceout
);

wire beat;
heartbeat #(.TOPCOUNT(TOPCOUNT)) beatEvent (.clk(clk), .reset(reset), .beat(beat));

reg [2:0] pipeline;

initial begin
    pipeline = 3'd0;
end

always @(posedge clk) begin
    if (beat) begin
        pipeline[0] <= switchIn;
        pipeline[1] <= pipeline[0];
        pipeline[2] <= pipeline[1];
    end
end

assign debounceout = &pipeline;
endmodule
