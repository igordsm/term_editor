import argv
import gleam/io
import simplifile
import terminal
import gleam/string
import gleam/list

fn input_loop() {
  case terminal.get_key() {
    terminal.CursorMovement(terminal.UP) -> {
      io.print("\u{1b}[1T")
      input_loop()
    }
    terminal.CursorMovement(terminal.DOWN) -> {
      io.print("\u{1b}[1S")
      input_loop()
    }
    terminal.Letter("q") -> Nil
    _ -> {
      input_loop()
    }
  }
}

fn split_long_lines(line_list, max_length) {
  case line_list {
    [] -> []
    [current, ..rest] -> {
      let curr_length = string.length(current)
      case curr_length {
        l if l < max_length -> [current, ..split_long_lines(rest, max_length)]
        l -> {
          [string.slice(current, 0, max_length), ..split_long_lines([string.drop_left(current, max_length), ..rest], max_length)]
        }
      }
    }
  }
}

fn split_line_max_length(s, max_length) {
  let lines = string.split(s, "\n")
  split_long_lines(lines, max_length)
}

fn start_editor(filename) {
  let assert Ok(contents) = simplifile.read(filename)
  let #(nlines, ncols) = terminal.get_size()
  let contents_split_lines = split_line_max_length(contents, ncols)

  terminal.clear()
  io.print(string.join(list.take(contents_split_lines, nlines), "\n"))
  terminal.move_cursor(0, 0)

  terminal.raw_mode_enter()
  input_loop()
  terminal.raw_mode_end()
  Nil
}

pub fn main() {
  case argv.load().arguments {
    [filename] -> start_editor(filename)
    _ -> io.println("Usage: file_viewer filename")
  }
}
