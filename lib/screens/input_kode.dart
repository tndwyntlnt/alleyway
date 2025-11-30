import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../widgets/code_info_card.dart';

class InputCodeScreen extends StatefulWidget {
  final VoidCallback onBack;

  const InputCodeScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  State<InputCodeScreen> createState() => _InputCodeScreenState();
}

class _InputCodeScreenState extends State<InputCodeScreen> {
  final ApiService _apiService = ApiService();

  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _fullCode {
    String suffix = _controllers.map((c) => c.text).join();
    return "ALW-$suffix";
  }

  void _handleChanged(int index, String value) {
    setState(() {
      _errorMessage = '';
    });

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (value.isNotEmpty && index == 5) {
      FocusScope.of(context).unfocus();
    }
  }

  void _handleRedeem() async {
    String suffix = _controllers.map((c) => c.text).join();

    if (suffix.length != 6) {
      setState(() {
        _errorMessage = 'Please complete the code (6 characters)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _apiService.redeemCode(_fullCode);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      widget.onBack();
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildInputBox(int index) {
    return Expanded(
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            UpperCaseTextFormatter(),
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
          ],
          decoration: InputDecoration(
            counterText: '',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3C6E47), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3C6E47), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) => _handleChanged(index, value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled =
        _controllers.every((c) => c.text.isNotEmpty) && !_isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3932), Color(0xFF3C6E47)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Back',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Input Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter transaction code (ALW-...)',
                    style: TextStyle(color: Color(0xFF8FB996), fontSize: 16),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -64),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const CodeInfoCard(
                            message: 'Code found on your receipt (Ex: AESYLT)',
                          ),

                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(
                                  right: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E7E1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF3C6E47),
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  "ALW-",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3C6E47),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),

                              _buildInputBox(0),
                              _buildInputBox(1),
                              _buildInputBox(2),
                              _buildInputBox(3),
                              _buildInputBox(4),
                              _buildInputBox(5),
                            ],
                          ),

                          const SizedBox(height: 24),

                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Color(0xFFE47A7A),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isButtonEnabled ? _handleRedeem : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3C6E47),
                                disabledBackgroundColor: const Color(
                                  0xFF3C6E47,
                                ).withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Claim Points',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const CodeInfoCard(
                            message: 'Ensure all characters match the receipt.',
                            isTip: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
