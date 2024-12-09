import decode
import decode/zero
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/io
import gleam/result

pub type Person {
  Person(name: String, age: Int, address: Dict(Int, String))
}

pub fn main() {
  let data = do_get_data()
  io.debug(data)
  new_decode(data)
  |> io.debug
  old_decode(data)
  |> io.debug
}

pub fn old_decode(d: Dynamic) -> Result(Person, dynamic.DecodeErrors) {
  decode.into({
    use name <- decode.parameter
    use age <- decode.parameter
    use address <- decode.parameter
    Person(name:, age:, address:)
  })
  |> decode.field("name", decode.string)
  |> decode.field("age", decode.int)
  |> decode.field("address", decode.dict(decode_stringed_int(), decode.string))
  |> decode.from(d)
}

pub fn new_decode(d: Dynamic) -> Result(Person, dynamic.DecodeErrors) {
  let new_decoder = {
    use name <- zero.field("name", zero.string)
    use age <- zero.field("age", zero.int)
    use address <- zero.field(
      "address",
      zero.dict(zero_stringed_int(), zero.string),
    )
    zero.success(Person(name:, age:, address:))
  }
  zero.run(d, new_decoder)
}

@external(javascript, "./data.mjs", "do_get_data")
fn do_get_data() -> Dynamic

fn zero_stringed_int() -> zero.Decoder(Int) {
  zero.string |> zero.map(int.parse) |> zero.map(result.unwrap(_, 0))
}

fn decode_stringed_int() -> decode.Decoder(Int) {
  decode.string |> decode.map(int.parse) |> decode.map(result.unwrap(_, 0))
}
