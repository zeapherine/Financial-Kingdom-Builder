import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/theme/duolingo_theme.dart';

class EnhancedConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final bool requiresTyping;
  final String? requiredPhrase;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const EnhancedConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.requiresTyping = false,
    this.requiredPhrase,
    this.onConfirm,
    this.onCancel,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    bool requiresTyping = false,
    String? requiredPhrase,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EnhancedConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        requiresTyping: requiresTyping,
        requiredPhrase: requiredPhrase,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    ) ?? false;
  }

  @override
  State<EnhancedConfirmationDialog> createState() => _EnhancedConfirmationDialogState();
}

class _EnhancedConfirmationDialogState extends State<EnhancedConfirmationDialog>
    with TickerProviderStateMixin {
  
  final _textController = TextEditingController();
  bool _isTypingValid = false;
  bool _isProcessing = false;
  
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.requiresTyping) {
      _textController.addListener(_validateTyping);
      if (widget.isDestructive) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _isTypingValid = true;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _validateTyping() {
    if (widget.requiredPhrase != null) {
      setState(() {
        _isTypingValid = _textController.text.trim().toLowerCase() == 
                        widget.requiredPhrase!.toLowerCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.isDestructive ? _pulseAnimation : kAlwaysCompleteAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isDestructive ? _pulseAnimation.value : 1.0,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: widget.isDestructive ? DuolingoTheme.duoRed : DuolingoTheme.duoBlue,
                width: 2,
              ),
            ),
            title: _buildTitle(),
            content: _buildContent(),
            actions: _buildActions(),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isDestructive 
                ? DuolingoTheme.duoRed.withValues(alpha: 0.1)
                : DuolingoTheme.duoBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.isDestructive ? Icons.warning : Icons.help_outline,
            color: widget.isDestructive ? DuolingoTheme.duoRed : DuolingoTheme.duoBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.title,
            style: DuolingoTheme.headingMedium.copyWith(
              color: widget.isDestructive ? DuolingoTheme.duoRed : DuolingoTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          widget.message,
          style: DuolingoTheme.bodyMedium.copyWith(
            color: DuolingoTheme.textSecondary,
            height: 1.4,
          ),
        ),
        if (widget.isDestructive) ...[
          const SizedBox(height: 16),
          _buildRiskWarning(),
        ],
        if (widget.requiresTyping && widget.requiredPhrase != null) ...[
          const SizedBox(height: 20),
          _buildTypingConfirmation(),
        ],
      ],
    );
  }

  Widget _buildRiskWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DuolingoTheme.duoRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DuolingoTheme.duoRed),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: DuolingoTheme.duoRed,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This action involves financial risk and cannot be undone.',
              style: DuolingoTheme.bodySmall.copyWith(
                color: DuolingoTheme.duoRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type "${widget.requiredPhrase}" to confirm:',
          style: DuolingoTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isTypingValid ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _isTypingValid ? DuolingoTheme.duoGreen : DuolingoTheme.duoRed,
                      width: 2,
                    ),
                  ),
                  hintText: widget.requiredPhrase,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixIcon: _isTypingValid 
                      ? Icon(Icons.check, color: DuolingoTheme.duoGreen)
                      : null,
                ),
                style: DuolingoTheme.bodyMedium,
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: _isProcessing ? null : _handleCancel,
        style: TextButton.styleFrom(
          foregroundColor: DuolingoTheme.textSecondary,
        ),
        child: Text(widget.cancelText),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: (_isProcessing || !_isTypingValid) ? null : _handleConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isDestructive 
              ? DuolingoTheme.duoRed 
              : DuolingoTheme.duoGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.confirmText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    ];
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    widget.onCancel?.call();
  }

  Future<void> _handleConfirm() async {
    if (!_isTypingValid) {
      _shakeController.forward().then((_) => _shakeController.reverse());
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();
    
    // Simulate processing time for dramatic effect
    await Future.delayed(const Duration(milliseconds: 800));
    
    widget.onConfirm?.call();
  }
}