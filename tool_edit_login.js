const fs = require('fs');
const path = 'C:/Users/LENOVO/Documents/Project/sentra-mobile/lib/features/auth/views/login_screen.dart';
let s = fs.readFileSync(path, 'utf8');

const startMarker = '              bool phoneAlreadyExists = false;';
const endMarker = '\n            },\n          ),';

const si = s.indexOf(startMarker);
if (si < 0) throw new Error('start marker not found');
const ei = s.indexOf(endMarker, si);
if (ei < 0) throw new Error('end marker not found');

const replacement = `              if (isRegistering) return;

              setState(() {
                isRegistering = true;
              });

              final result = await repository.register(
                phone,
                regisnama.text.trim(),
                regispassword.text,
                selectedValue ?? '',
                regisanswer.text.trim(),
                selectedGender ?? 'Pria',
                regisalamat.text.trim(),
              );

              if (!mounted) return;

              setState(() {
                isRegistering = false;
              });

              if (!result.success) {
                CustomSnackbar.show(
                  result.message,
                  warna: Colors.red,
                  tinggi: 100,
                  icon: Icons.error_outline_rounded,
                );
                return;
              }

              CustomSnackbar.show(result.message, tinggi: 100);

              nomorController.text = phone;
              setState(() {
                selectedIndex = 0;
              });
            },
          ),`;

s = s.slice(0, si) + replacement + s.slice(ei + endMarker.length);
fs.writeFileSync(path, s, 'utf8');
console.log('done, removed', ei - si, 'chars, new length', s.length);
