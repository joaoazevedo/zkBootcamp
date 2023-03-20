// Perform and log output of simple arithmetic operations
func simple_math() {
   // adding 13 +  14
   let v = 13 + 14;
   %{ print(ids.v); %}

   // multiplying 3 * 6
   let v = 3 * 6;
   %{ print(ids.v); %}

   // dividing 6 by 2
   let v = 6 / 2;
   %{ print(ids.v); %}

   // dividing 70 by 2
   let v = 70 / 2;
   %{ print(ids.v); %}

   // dividing 7 by 2
   let v = 7 / 2;
   %{ print(ids.v); %}

    return ();
}
