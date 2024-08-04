module bif

import etf

pub fn apply(mfa etf.MFA, args []etf.Value) !etf.Value {
	return match mfa.str() {
		'erlang:+/2' { bif_erlang_plus_2(args[0], args[1])! }
		'erlang:-/2' { bif_erlang_sub_2(args[0], args[1])! }
		else { error('BIF ${mfa.str()} not found!') }
	}
}

fn bif_erlang_plus_2(a etf.Value, b etf.Value) !etf.Value {
	if a is etf.Integer {
		if b is etf.Integer {
			return etf.Integer(a + b)
		}
	}
	return error('badarg for erlang:+/2')
}

fn bif_erlang_sub_2(a etf.Value, b etf.Value) !etf.Value {
	if a is etf.Integer {
		if b is etf.Integer {
			return etf.Integer(a - b)
		}
	}
	return error('badarg for erlang:-/2')
}
