module HALTCtrl(
	input wire clk,
	input wire reset,
	input wire [5:0] curr_rs1,
	input wire [4:0] curr_rs2,
	input wire [5:0] curr_rd,
	
	output reg halt = 0
);

	reg [5:0] prev_rd = 0;

	always @(posedge clk) begin
		halt <= 0;
		prev_rd <= curr_rd;
		
		if (reset) begin
			prev_rd <= 0;
		end
		else if (prev_rd != 0 && (curr_rs1 == prev_rd || curr_rs2 == prev_rd)) begin
			halt <= 1;
			prev_rd <= 0;	// Es necesario resetear, por si rs=rd
		end
	end
	
	
	
endmodule