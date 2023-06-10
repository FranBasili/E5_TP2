// `define JAL_BITS    3'b010
// `define JALR_BITS   3'b011

// `define BEQ  3'b000
// `define BNE  3'b001
// `define BLT  3'b100
// `define BGE  3'b101
// `define BLTU 3'b110
// `define BGEU 3'b111

// module JMP(
//     input new_jmp,
//     input [2:0] jmp_type,
//     input [2:0] alu_csr,
//     input [31:0] imm,
//     input [31:0] pc,
//     input clock,
//     output wire [31:0] newPC,
//     output wire ctrlFetch,
//     output wire global_reset
// );

// 	wire zero = alu_csr[0];
// 	wire carry = alu_csr[1];
// 	wire overflow = alu_csr[2];

// 	reg [2:0]   jmp_type1;
// 	reg [2:0]   jmp_type2;
// 	reg new_jmp1;
// 	reg new_jmp2;
// 	reg [31:0]  pc1;
// 	reg [31:0]  pc2;

// 	wire [31:0] newHipAdd;

//     always @(new_jmp) begin
//         if (new_jmp == 1 && (jmp_type != JAL_BITS && jmp_type != JALR_BITS)) begin
//             newHipAdd = imm + pc - 8;
//         end
//         else begin
//             newHipAdd = 0;
//         end
//     end

//     always @(posedge clock) begin
//         jmp_type1 <= jmp_type;
//         jmp_type2 <= jmp_type1;
//         pc1 <= newHipAdd;
//         pc2 <= pc1;
//         new_jmp1 <= new_jmp;
//         new_jmp2 <= new_jmp1;

//     end

//     always @(new_jmp2) begin
//         if(new_jmp2 == 1 && (jmp_type2 != JAL_BITS && jmp_type2 != JALR_BITS)) begin
//             case(jmp_type2)
//                 `BEQ:begin
//                     if(zero == 1) begin
//                         global_reset = 1;
//                         ctrlFetch = 1;

//                     end
//                     else begin
//                         global_reset = 0;
//                         start_fsm = 0;
//                     end
//                  end
//                 `BNE:begin
//                  end
//                 `BLT:begin
//                  end
//                 `BGE:begin
//                  end
//                 `BLTU:begin
//                  end
//                 `BGEU:begin
//                  end
//                  default: begin
// 					  end
//             endcase
//         end
//     end

// endmodule