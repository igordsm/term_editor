import gleam/list
import gleam/queue
import gleam/string

pub type TermState {
  TermState(
    fname: String,
    nlines: Int, 
    ncols: Int,
    before: queue.Queue(String),
    screen: queue.Queue(String),
    after: queue.Queue(String),
  )
}

fn split_long_lines(line_list, max_length) {
  case line_list {
    [] -> []
    [current, ..rest] -> {
      let curr_length = string.length(current)
      case curr_length {
        l if l < max_length -> [current, ..split_long_lines(rest, max_length)]
        _ -> {
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

pub fn new(fname: String, lines: String, nrows: Int, ncols: Int) -> TermState {
  let line_list = split_line_max_length(lines, ncols)
  TermState(
    fname, nrows, ncols,
    queue.new(),
    queue.from_list(list.take(line_list, nrows)),
    queue.from_list(list.drop(line_list, nrows)),
  )
}

pub fn scroll_down(st: TermState) {
  case queue.pop_front(st.after) {
    Ok(#(line_show, new_after)) -> {
      let assert Ok(#(line_hide, new_screen)) = queue.pop_front(st.screen)
      Ok(#(
        line_show,
        line_hide,
        TermState(
          ..st,
          before: queue.push_back(st.before, line_hide),
          screen: queue.push_back(new_screen, line_show),
          after: new_after,
        ),
      ))
    }
    _ -> {
      Error(st)
    }
  }
}

pub fn scroll_up(st: TermState) {
  case queue.pop_back(st.before) {
    Ok(#(line_show, new_before)) -> {
      let assert Ok(#(line_hide, new_screen)) = queue.pop_back(st.screen)
      Ok(#(
        line_show,
        line_hide,
        TermState(
          ..st,
          before: new_before,
          screen: queue.push_front(new_screen, line_show),
          after: queue.push_front(st.after, line_hide),
        ),
      ))
    }
    _ -> {
      Error(st)
    }
  }
}
