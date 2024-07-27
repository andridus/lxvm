module errors

pub struct InternalError {
	Error
	msg  string
	code int
	kind InternalErrorKind
}

pub enum InternalErrorKind {
	error
	info
	warn
	hide
}

pub fn (err InternalError) code() int {
	return match err.kind {
		.hide { 0 }
		.info { 1 }
		.warn { 2 }
		.error { 3 }
	}
}

pub fn (err InternalError) str() string {
	return err.msg()
}

pub fn (err InternalError) msg() string {
	return '${err.kind.str()}: ${err.msg}'
}

pub fn new(msg string) InternalError {
	return InternalError{
		msg: msg
		kind: .hide
	}
}

pub fn new_error(msg string) InternalError {
	return InternalError{
		msg: msg
		kind: .error
	}
}

pub fn new_info(msg string) InternalError {
	return InternalError{
		msg: msg
		kind: .info
	}
}

pub fn new_warn(msg string) InternalError {
	return InternalError{
		msg: msg
		kind: .warn
	}
}

pub fn hide(msg string) InternalError {
	return InternalError{
		msg: msg
		kind: .hide
	}
}

pub fn parse_error(error IError) {
	match error {
		InternalError {
			match error.kind {
				.hide {}
				.info {
					println(error)
				}
				.warn {
					println(error)
				}
				.error {
					println(error)
					exit(1)
				}
			}
		}
		else {}
	}
}
