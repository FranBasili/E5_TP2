module reg_bank(
    input wire clk,
    input wire [5:0]selA,
    input wire [4:0]selB,
    input wire [31:0]inPC,
    input wire [4:0]rd,
    input wire [31:0]busC,
    input wire reset,		// Tiene sentido el reset aca??

    output wire [31:0]outA,
    output wire [31:0]outB
);

	reg [31:0]banco[31:0]; 
	
	initial begin
		integer i;
		for(i=0; i<32; i=i+1) begin
			banco[i]=0;
		end
	end

	always @(negedge clk, posedge reset) begin
		if(reset) begin
			integer i;
			for(i=0; i<32; i=i+1) begin
				 banco[i] <= 0;
			end
		end                     

		else begin
			if (rd != 0) banco[rd] <= busC;      // Update registers. x0 always 0
		end
	end

//assign banco[0] = 0;
assign outA = selA < 32 ? banco[selA] : inPC;      // Muxes de buses
assign outB = banco[selB];

endmodule