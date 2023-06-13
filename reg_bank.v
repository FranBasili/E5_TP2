module reg_bank(
    input wire clk,
    input wire reset,			// Tiene sentido el reset aca??
    input wire [5:0] selA,
    input wire [4:0] selB,
    input wire [31:0] inPC,
    input wire [4:0] rd,
    input wire [31:0] busC,
	input wire [5:0] selJ,		// Selector de registro para unidad de JMP
	input wire [4:0] selM_in,		// Selectores de registro para unidad de LAM
	input wire [4:0] selM_out,
	input wire [31:0] busM,

    output wire [31:0] outA,
    output wire [31:0] outB,
	output wire [31:0] outJ,	// Bus con la unidad de JMP
	output wire [31:0] outM		// Bus con la unidad de JMP
    
);

	reg [31:0]banco[31:0];
	
	initial begin
		integer i;
		for(i=0; i<32; i=i+1) begin
			banco[i]=0;
		end
	end

	always @(negedge clk) begin
		if(reset) begin
			integer i;
			for(i=0; i<32; i=i+1) begin
				 banco[i] <= 0;
			end
		end                     

		else begin
			if (rd != 0) banco[rd] <= busC;      // Update registers. x0 always 0
			if (selM_out != 0) banco[selM_out] <= busM;      // Update registers from LAM. x0 always 0
		end
	end

assign outA = selA < 32 ? banco[selA] : inPC;      // Muxes de buses
assign outB = banco[selB];

assign outJ = selJ < 32 ? banco[selJ] : inPC;		// Bus de JMP

assign outM = banco[selM_in];						// Bus de LAM out

endmodule