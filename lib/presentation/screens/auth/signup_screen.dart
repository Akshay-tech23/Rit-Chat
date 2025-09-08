import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rit_chat/core/constants/colors.dart';
import 'package:rit_chat/presentation/screens/auth/verify2.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  // controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rollController = TextEditingController();
  final _yearController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cadvisorController = TextEditingController();

  // visibility
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // role + department
  String _selectedRole = "Student";
  String _selectedDepartment = "AI & DS";

  final List<String> roles = ["Student", "Head of the Department", "Teacher","Non-Teaching Staff"];

  final List<String> departments = [
    "Artificial Intelligence and Data Science",
    "Computer Science and Engineering",
    "Electronics and Communication Engineering",
    "Mechanical Engineering",
    "Electrical and Electronics Engineering",
    "Civil Engineering",
    "Information Technology",
    "Computer Science and Business Systems"
  ];

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailScreens(
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              rollNumber: _selectedRole == "Student"
                  ? _rollController.text.trim()
                  : "",
              department: _selectedDepartment,
              year: _selectedRole == "Student"
                  ? _yearController.text.trim()
                  : "",
              phoneNumber: _phoneController.text.trim(),
              dob: _selectedRole == "Student" ? _dobController.text.trim() : "",
              role: _selectedRole, // 🔹 Added role field
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";
      if (e.code == "email-already-in-use") message = "Email already in use";
      if (e.code == "weak-password") message = "Password too weak";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Role dropdown with modern UI
                const Text(
                  "Register as",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: roles
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedRole = value!);
                  },
                  decoration: InputDecoration(
                    labelStyle: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.primary,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.white,
                    ),
                  ),
                  dropdownColor: AppColors.primary,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.white),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 16),

                // Full Name
                _buildField(_nameController, "Full Name"),
                const SizedBox(height: 16),

                // Email
                _buildField(
                  _emailController,
                  "College Email (@ritrjpm.ac.in)",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter email";
                    if (!value.endsWith("@ritrjpm.ac.in")) {
                      return "Use your @ritrjpm.ac.in email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Department dropdown (for all roles)
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  items: departments
                      .map(
                        (dept) =>
                            DropdownMenuItem(value: dept, child: Text(dept)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedDepartment = value!);
                  },
                  decoration: InputDecoration(
                    labelText: "Department",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Fields only for Student
                if (_selectedRole == "Student") ...[
                  _buildField(_rollController, "Roll Number / Student ID"),
                  const SizedBox(height: 16),
                  _buildField(_yearController, "Year (e.g. 3rd Year)"),
                  const SizedBox(height: 16),
                  //Class Advisor
                  TextFormField(
                    controller: _cadvisorController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Class Advisor Email id",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        _dobController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),

                

                // Phone Number (all roles)
                _buildField(
                  _phoneController,
                  "Phone Number",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Password (all roles)
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                  validator: (value) => value != null && value.length >= 6
                      ? null
                      : "Password must be at least 6 characters",
                ),
                const SizedBox(height: 24),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Register",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          validator ??
          (value) => value == null || value.isEmpty ? "Enter $label" : null,
    );
  }
}
