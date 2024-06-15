import argv
import gleam/io
import gleam/list
import gleam/queue
import gleam/string
import simplifile
import part3/terminal

type TermState {
  TermState(
    before: queue.Queue(String),
    screen: queue.Queue(String),
    after: queue.Queue(String),
  )
}

fn input_loop(state: TermState) {
  case terminal.get_key() {
    terminal.CursorMovement(terminal.UP) -> {
      case queue.pop_back(state.before) {
        Ok(#(line_show, new_before)) -> {
          io.print("\u{1b}[1T")
          terminal.move_cursor(0, 0)
          io.print(line_show)
          let assert Ok(#(line_hide, new_screen)) = queue.pop_back(state.screen)
          input_loop(TermState(
            new_before,
            queue.push_front(new_screen, line_show),
            queue.push_front(state.after, line_hide),
          ))
        }
        _ -> input_loop(state)
      }
    }
    terminal.CursorMovement(terminal.DOWN) -> {
      case queue.pop_front(state.after) {
        Ok(#(line_show, new_after)) -> {
          let assert Ok(#(line_hide, new_screen)) =
            queue.pop_front(state.screen)

          let #(nlines, _ncols) = terminal.get_size()
          terminal.move_cursor(nlines, 0)
          io.print(line_show)
          io.print("\u{1b}[1S")
          input_loop(TermState(
            queue.push_back(state.before, line_hide),
            queue.push_back(new_screen, line_show),
            new_after,
          ))
        }
        Error(Nil) -> input_loop(state)
      }
    }
    terminal.Letter("q") -> Nil
    _ -> {
      input_loop(state)
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
          [
            string.slice(current, 0, max_length),
            ..split_long_lines(
              [string.drop_left(current, max_length), ..rest],
              max_length,
            )
          ]
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
  terminal.move_cursor(0, 0)
  io.print(string.join(list.take(contents_split_lines, nlines), "\n"))
  let st =
    TermState(
      queue.new(),
      queue.from_list(list.take(contents_split_lines, nlines)),
      queue.from_list(list.drop(contents_split_lines, nlines)),
    )

  terminal.raw_mode_enter()
  input_loop(st)
  terminal.raw_mode_end()
  Nil
}

pub fn main() {
  case argv.load().arguments {
    [filename] -> start_editor(filename)
    _ -> io.println("Usage: file_viewer filename")
  }
}
