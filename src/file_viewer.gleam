import terminal
import simplifile
import argv
import gleam/io

fn input_loop() {
  case terminal.get_key() {
     terminal.CursorMovement(terminal.UP) -> {
       io.print("\u{1b}[1T")
       input_loop()
      }
      terminal.CursorMovement(terminal.DOWN) -> {
             io.print("\u{1b}[1S")
             io.debug("DOWN!")
             input_loop()
            }
     terminal.Letter("q") -> Nil
    _ -> {
		io.debug("UNK")
    input_loop()
    }
  }
}


fn start_editor(filename) {
  let assert Ok(contents) = simplifile.read(filename)
  
  terminal.clear()
  io.println(contents)

  terminal.move_cursor(0,0)

  terminal.raw_mode_enter()
  input_loop()
  terminal.raw_mode_end()
  Nil
}

pub fn main() {
  case argv.load().arguments {
        [filename] -> 
          start_editor(filename)
        _ -> 
          io.println("Usage: file_viewer filename")
  }
  
}
