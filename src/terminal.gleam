import gleam/io
import shellout
import gleam/int


pub type CursorDirection {
  UP
  DOWN
  LEFT
  RIGHT
}

pub type Key {
  Letter(char: String)
  CursorMovement(dir: CursorDirection)
  UNKNOWN
}

@external(erlang, "io", "get_chars")
pub fn get_chars(prompt: String, count: int) -> String

fn read_escape_sequence() {
	get_chars("", 1) // read [
	case get_chars("", 1) {
		"A" -> CursorMovement(UP)
		"B" -> CursorMovement(DOWN)
		"C" -> CursorMovement(RIGHT)
		"D" -> CursorMovement(LEFT)
		_ -> UNKNOWN
	}
}

pub fn get_key() {
  case get_chars("", 1) {
    "\u{1b}" -> read_escape_sequence()
  	letter -> Letter(letter)
  }
}

pub fn clear() {
  io.print("\u{1b}[2J")
}

pub fn raw_mode_enter() {
  shellout.command("stty", ["raw", "-echo"], ".", [])
}

pub fn raw_mode_end() {
  shellout.command("stty", ["-raw", "echo"], ".", [])
}

pub fn move_cursor(row: Int, col: Int) {
  io.print("\u{1b}[" <> int.to_string(row) <> ";" <> int.to_string(col) <> "H")
}
