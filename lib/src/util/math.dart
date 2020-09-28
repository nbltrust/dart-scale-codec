
///
/// Returns the number of trailing zeros in the binary representation of the given integer.
int trailing_zeros(int value) {
  int num_zeros = 0;
  while(value & 1 == 0) {
    num_zeros += 1;
    value >>= 1;
  }
  return num_zeros;
}