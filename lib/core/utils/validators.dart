//  String? validateEmail(String? value) {
//   Pattern pattern =
//       r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
//   RegExp regex = RegExp(pattern.toString());
//   if (!regex.hasMatch(value!.trim())) {
//     return "Enter Valid Email";
//   } else {
//     return null;
//   }
// }

 // String? validatePassword(String? value) {
 //   RegExp regex =
 //   RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
 //   if (value!.isEmpty) {
 //     return "Password must contain uppercase letters, lowercase letters, and numbers.";
 //   }
 //   else {
 //     // if (!regex.hasMatch(value)) {
 //     //   return 'Enter valid password';
 //     // }
 //     // else {
 //       return null;
 //     // }
 //   }
 // }

 String? validateNumber(String? value) {
   String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
   RegExp regExp = RegExp(pattern);
   if (value!.isEmpty) {
     return 'Enter mobile number';
   }
   else if (!regExp.hasMatch(value)) {
     return 'Enter a valid number';
   }
   return null;
 }


String? validateText(String? value) {
  if (value!.isEmpty) {
    return"Field can not be empty";
  } else {
    return null;
  }
}
