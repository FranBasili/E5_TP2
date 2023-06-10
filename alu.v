`define ALU_ADD		10'bx0xxxxx000		// Mismas operaciones con o sin inmediato
`define ALU_SUB		10'bx1xxxxx000
`define ALU_SLL		10'b0000000001      // Logic Shift Left
`define ALU_SRL		10'b0000000101      // Logic Shift Right
`define ALU_SRA		10'b0100000101      // Arithmetic shift right
`define ALU_XOR		10'b0000000100
`define ALU_OR			10'b0000000110
`define ALU_AND		10'b0000000111
`define ALU_SLT		10'b0000000010      // Set less than
`define ALU_SLTU		10'b0000000011      // Set less than unsigned


module alu
(
	input[31:0] busA,
	input[31:0] busB,
	input[31:0] imm,		// Immediate
	input imm_en,
	input[9:0] ctrl,
	output reg[31:0] out,
	//output wire C,			// CSR
	output wire N,
	output wire Z
 );

 
always @(busA, busB, imm, imm_en, ctrl)
begin
	if (!imm_en) begin
		casex (ctrl)
			`ALU_ADD:	out = busA + busB;
			`ALU_SUB:	out = busA - busB;
			`ALU_SLL:	out = busA << (busB[4:0]);
			`ALU_SRL:	out = busA >> (busB[4:0]);
			`ALU_SRA:	out = $signed(busA) >>> (busB[4:0]);
			`ALU_XOR:	out = busA ^ busB;
			`ALU_OR:	out = busA | busB;
			`ALU_AND:	out = busA & busB;
			`ALU_SLT:	out = ($signed(busA) < $signed(busB)) ? 1 : 0;
			`ALU_SLTU:	out = (busA < busB) ? 1 : 0;
			default: out=0;
		endcase
	end
	else begin
		casex (ctrl)
			`ALU_ADD:	out = busA + imm;
			`ALU_SUB:	out = busA + imm;		// Considero la resta como suma tambien
			`ALU_SLL:	out = busA << (imm[4:0]); 
			`ALU_SRL:	out = busA >> (imm[4:0]);
			`ALU_SRA:	out = $signed(busA) >>> (imm[4:0]);
			`ALU_XOR:	out = busA ^ imm;
			`ALU_OR:	out = busA | imm;
			`ALU_AND:	out = busA & imm;
			`ALU_SLT:	out = ($signed(busA) < $signed(imm)) ? 1 : 0;
			`ALU_SLTU:	out = (busA < imm) ? 1 : 0;
			default: out=0;
		endcase 
	end
end


assign N = out[31];
assign Z = (out == 0);
 
endmodule