module machine

import etf

@[heap]
pub struct Stack {
mut:
	data []etf.Value
}

pub fn (mut s Stack) update(pos int, value etf.Value) {
	s.data[pos] = value
}

pub fn (mut s Stack) put(value etf.Value) {
	s.data << value
}

pub fn (mut s Stack) pop() etf.Value {
	return s.data.pop()
}

pub fn (mut s Stack) trim(len int) {
	s.data.trim(len)
}

pub fn (s &Stack) get(pos int) etf.Value {
	return s.data[pos]
}

pub fn (s &Stack) total() int {
	return s.data.len
}
