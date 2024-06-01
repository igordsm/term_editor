import gleam/io
import gleam/result
import gleam/otp/actor
import gleam/erlang/process
import argv

import terminal

pub type CursorDirection {
	UP
	DOWN
	LEFT
	RIGHT
}

pub type Key {
  Letter(char: String)
  CursorMovement(dir: CursorDirection)	
}

@external(erlang, "io", "get_chars")
pub fn get_chars(prompt: String, count: int) -> String

fn input_loop() {
  let k = get_chars("", 1)
  case k {
    "q" -> Nil
    _ -> input_loop()
  }
}

fn start_editor(filename) {
  terminal.clear()
  terminal.raw_mode_enter()
  terminal.move_cursor(3, 0)

  input_loop()
  terminal.raw_mode_end()	

  Nil
}

pub fn main() {
  case argv.load().arguments {
  	[filename] -> 
  	  start_editor(filename)
  	_ -> 
  	  io.println("sdfdslk")
  }
  
}
