module latch32(
input wire clk, 
input wire en,
input wire reset,

input wire [31:0]in, 

output reg [31:0]out
);



always @(posedge clk, posedge reset) begin
    if (reset) begin
		out <= 0;
	 end
	 else if (en) begin
		out <= in;
    end
end

endmodule
