import gleam/io
import gleam/string
import terminal


pub fn main() {
  terminal.raw_mode_enter()
  terminal.clear()

  let k = terminal.get_key()
  io.debug( k )

  terminal.raw_mode_end()  
}
