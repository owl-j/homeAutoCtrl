module spot (
input wire clk,
input wire spot_in,
output wire spot_out
);

reg delayed_spot_in;
always @(posedge clk) begin
    delayed_spot_in <= spot_in;
end

assign spot_out = spot_in & (~delayed_spot_in);
endmodule