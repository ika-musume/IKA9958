module IKA9958_prim_srlatch (
    input   wire                i_CLK, i_CEN, i_S, i_R,
    output  logic               o_Q, o_Q_n
);

always_ff @(posedge i_CLK) if(i_CEN) begin
    case({i_S, i_R})
        2'b00: begin o_Q <= o_Q;  o_Q_n <= o_Q_n; end
        2'b01: begin o_Q <= 1'b0; o_Q_n <= 1'b1;  end
        2'b10: begin o_Q <= 1'b1; o_Q_n <= 1'b0;  end
        2'b11: begin o_Q <= 1'b0; o_Q_n <= 1'b0;  end //NOR type invalid output
    endcase
end

endmodule