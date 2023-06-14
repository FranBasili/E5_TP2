module HALTCtrl(
	input wire clk,
	input wire [5:0] curr_rs1,
	input wire [4:0] curr_rs2,
	input wire [5:0] curr_rd,
	input wire [4:0] prev_rd,
	
	output reg halt = 0
);



	always @(posedge clk) begin
		halt <= 0;
		
		if (prev_rd != 0 && (curr_rs1 == prev_rd || curr_rs2 == prev_rd)) begin
			halt <= 1;
		end
	end
	
	
	
endmodule