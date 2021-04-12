module debouncer (
input wire switchIn,
input wire clk,
input wire reset,
output wire debounceout);

wire beat;
heartbeat #(.TOPCOUNT(10_000_000)) beatEvent (.clk(clk), .reset(reset), .beat(beat));

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
