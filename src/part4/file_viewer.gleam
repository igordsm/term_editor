import argv
import gleam/io
import gleam/queue
import gleam/string
import simplifile
import part4/terminal
import part4/term_state.{type TermState}

fn repaint_bottom_bar(state: TermState, fname) {
  terminal.move_cursor(state.nlines+1, 0)
  
  io.print("\u{1b}[48:5:2m")
  terminal.clear_line()
  io.print(" <gled> -- " <> fname <> " \u{1b}[0m")
}

fn input_loop(state: TermState) {
  case terminal.get_key() {
    terminal.CursorMovement(terminal.UP) -> {
      case term_state.scroll_up(state) {
        Ok(#(line_show, line_hide, new_state)) -> {
          io.print("\u{1b}[1T")
          terminal.move_cursor(0,0)
          terminal.clear_line()
          io.print(line_show)
          
          repaint_bottom_bar(new_state, new_state.fname)
          input_loop(new_state)
        }
        Error(st) -> {
          input_loop(st)
        }
      }
    }
    terminal.CursorMovement(terminal.DOWN) -> {
      case term_state.scroll_down(state) {
        Ok(#(line_show, line_hide, new_state)) -> {
          io.print("\u{1b}[1S")
          terminal.move_cursor(state.nlines,0)
          terminal.clear_line()
          io.print(line_show)

          repaint_bottom_bar(new_state, new_state.fname)
          
          input_loop(new_state)
        }
        Error(st) -> {
          input_loop(st)
        }
      }
      
    }
    terminal.Letter("q") -> Nil
    _ -> {
      input_loop(state)
    }
  }
}

fn start_editor(filename) {
  let assert Ok(contents) = simplifile.read(filename)
  let #(nlines, ncols) = terminal.get_size()

  terminal.clear()
  terminal.move_cursor(0, 0)
  let st =
    term_state.new(filename, contents, nlines-1, ncols)

  io.print(string.join(st.screen |> queue.to_list, "\n"))
  repaint_bottom_bar(st, filename)

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
