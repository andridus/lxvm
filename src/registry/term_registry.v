module registry

import errors
import math.big

pub type Term = u64
pub type Literal = u32
pub type Integer = int
pub type Atom = u32
pub type Nil = u8
pub type RegX = u32
pub type RegY = u32
pub type Label = u32
pub type Character = u8
pub type BigInt = big.Integer
pub type String = []u8
pub type FloatReg = u32
pub type AllocList = []u32
pub type ExtendedLiteral = u32
pub type ExtendedList = []Value
pub type Value = AllocList
	| Atom
	| BigInt
	| Character
	| ExtendedList
	| ExtendedLiteral
	| FloatReg
	| Integer
	| Label
	| Literal
	| Nil
	| RegX
	| RegY
	| String
	| Term

pub fn (v Value) str() string {
	return match v {
		Literal {
			a := v as Literal
			'Literal(${a})'
		}
		Integer {
			a := v as Integer
			'Integer(${a})'
		}
		Atom {
			a := v as Atom
			'Atom(${a})'
		}
		RegX {
			a := v as RegX
			'RegX(${a})'
		}
		RegY {
			a := v as RegY
			'RegY(${a})'
		}
		Label {
			a := v as Label
			'Label(${a})'
		}
		Character {
			a := v as Character
			'Character(${a})'
		}
		BigInt {
			a := v as BigInt
			'BigInt(${a})'
		}
		String {
			a := v as String
			'String(${a})'
		}
		FloatReg {
			a := v as FloatReg
			'FloatReg(${a})'
		}
		AllocList {
			a := v as AllocList
			'AllocList(${a})'
		}
		ExtendedLiteral {
			a := v as ExtendedLiteral
			'ExtendedLiteral(${a})'
		}
		ExtendedList {
			a := v as ExtendedList
			'ExtendedList(${a})'
		}
		else {
			'-'
		}
	}
}

pub struct TermInternal {
pub:
	kind  Kind
	value Value
	size  int
}

pub enum Tag {
	u
	i
	a
	x
	y
	f
	h
	z
}

pub enum Kind {
	literal
	integer
	atom
	x
	y
	label
	character
	extended
	extended_float
	extended_list
	extended_float_reg
	extended_alloc_list
	extended_literal
}

pub fn kind_from_bit(bit u8) Kind {
	/*
	BEAM file uses a special encoding to store simple terms
	in BEAM file in a space-efficient way. It is different
	from memory term layout, used by BEAM VM.
		7 6 5 4 3 | 2 1 0
		----------+------
							| 0 0 0 — Literal
							| 0 0 1 — Integer
							| 0 1 0 — Atom
							| 0 1 1 — X Register
							| 1 0 0 — Y Register
							| 1 0 1 — Label
							| 1 1 0 — Character
		0 0 0 1 0 | 1 1 1 — Extended — Float
		0 0 1 0 0 | 1 1 1 — Extended — List
		0 0 1 1 0 | 1 1 1 — Extended — Floating point register
		0 1 0 0 0 | 1 1 1 — Extended — Allocation list
		0 1 0 1 0 | 1 1 1 — Extended — Literal
	*/
	return match bit {
		0b0 {
			Kind.literal
		}
		0b1 {
			Kind.integer
		}
		0b10 {
			Kind.atom
		}
		0b11 {
			Kind.x
		}
		0b100 {
			Kind.y
		}
		0b101 {
			Kind.label
		}
		0b110 {
			Kind.character
		}
		0b10111 {
			Kind.extended_float
		}
		0b100111 {
			Kind.extended_list
		}
		0b110111 {
			Kind.extended_float_reg
		}
		0b1000111 {
			Kind.extended_alloc_list
		}
		0b1010111 {
			Kind.extended_literal
		}
		else {
			errors.new_error('invalid kind from bit')
			exit(1)
		}
	}
}
