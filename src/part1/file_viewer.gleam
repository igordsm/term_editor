import gleam/int  
import gleam/io  
import gleam/result  
import shellout  
  
@external(erlang, "io", "get_chars")  
pub fn get_chars(prompt: String, count: int) -> String  
  
fn clear() {  
 io.print("\u{1b}[2J")  
}  
  
fn raw_mode_enter() {  
 shellout.command("stty", ["raw", "-echo"], ".", [])  
}  
  
fn raw_mode_end() {  
 shellout.command("stty", ["-raw", "echo"], ".", [])  
}  
  
fn move_cursor(row: Int, col: Int) {  
 io.print("\u{1b}[" <> int.to_string(row) <> ";" <> int.to_string(col) <> "H")  
}  
  
fn input_loop() {  
 let k = get_chars("", 1)  
 case k {  
   "q" -> Nil  
   _ -> input_loop()  
 }  
}  
  
pub fn main() {  
 clear()  
 raw_mode_enter()  
 move_cursor(3, 0)  
 input_loop()  
 raw_mode_end()  
}
