module latch32(
input wire clk, 
input wire en,
input wire reset,		// reeset sincronico con clk

input wire [31:0]in, 

output reg [31:0]out
);



always @(posedge clk) begin
    if (reset) begin
		out <= 0;
	 end
	 else if (en) begin
		out <= in;
    end
end

endmodule
