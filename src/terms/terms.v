module terms

pub struct Nil {
	value u8
}

pub struct Integer {
	value int
}

pub struct Atom {
pub:
	value u32
	name  string
}

pub struct Catch {}

pub struct Pid {}

pub struct Port {}

pub struct Ref {}

pub struct Cons {
	x Term
	y Term
}

pub struct Float {
	value f32
}

pub struct Binary {}

pub struct Closure {}

type Term = Atom | Binary | Catch | Closure | Cons | Float | Integer | Nil | Pid | Port | Ref

pub fn (t Term) is_atom() bool {
	return match t {
		Atom { true }
		else { false }
	}
}
