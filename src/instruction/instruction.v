module instruction

import etf
import bif
import errors

pub struct Instruction {
pub:
	op   bif.Opcode
	args []etf.Value
}

pub fn (i Instruction) get_literal(pos int) !u32 {
	if i.args.len > pos && i.args[pos] is etf.Literal {
		num := i.args[pos] as etf.Literal
		return u32(num)
	} else {
		return errors.new_error('Bad argument ${i.op}')
	}
}

pub fn (i Instruction) get_value(pos int) !etf.Value {
	if i.args.len > pos {
		return i.args[pos]
	} else {
		return errors.new_error('Bad argument ${i.op}')
	}
}
