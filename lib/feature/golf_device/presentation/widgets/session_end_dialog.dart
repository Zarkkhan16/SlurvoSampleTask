import 'package:flutter/material.dart';

/// Session End Confirmation Dialog
/// Shows a beautiful confirmation dialog before ending the session
class SessionEndDialog {

  /// Show the session end confirmation dialog
  /// Returns true if user confirms, false if cancelled
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: _SessionEndDialogContent(),
        );
      },
    );

    return result ?? false; // Return false if dismissed somehow
  }
}

class _SessionEndDialogContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1D1E33),
            const Color(0xFF0A0E21),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.orangeAccent.withOpacity(0.3),
                  Colors.deepOrangeAccent.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.orangeAccent.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.orangeAccent,
              size: 40,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          const Text(
            'End Session?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            'Are you sure you want to end this session?\nAll recorded shots will be saved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[400],
                    side: BorderSide(
                      color: Colors.grey[600]!,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Confirm Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'End Session',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// USAGE EXAMPLES
// ============================================

/// Example 1: Basic Usage
/// Use this in your disconnect button
class ExampleUsage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Show dialog and wait for user response
        final confirmed = await SessionEndDialog.show(context);

        if (confirmed) {
          // User confirmed - End session
          print('✅ User confirmed - Ending session...');
          // Add your disconnect logic here
          // context.read<GolfDeviceBloc>().add(DisconnectDeviceEvent());
        } else {
          // User cancelled
          print('❌ User cancelled - Session continues');
        }
      },
      child: const Text('End Session'),
    );
  }
}

/// Example 2: With Loading State
/// Shows loading indicator after confirmation
class ExampleUsage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final confirmed = await SessionEndDialog.show(context);

        if (confirmed) {
          // Show loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent),
            ),
          );

          // Simulate saving and disconnecting
          await Future.delayed(const Duration(seconds: 2));

          // Close loading
          Navigator.of(context).pop();

          // Navigate away or show success
          print('✅ Session ended successfully!');
        }
      },
      child: const Text('Disconnect'),
    );
  }
}

/// Example 3: With Back Button Override
/// Prevents accidental back press without confirmation
class ExampleUsage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When user presses back button
        final confirmed = await SessionEndDialog.show(context);
        return confirmed; // Only allow back if confirmed
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connected Session'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final confirmed = await SessionEndDialog.show(context);
              if (confirmed) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: const Center(
          child: Text('Your session content here'),
        ),
      ),
    );
  }
}

/// Example 4: Alternative Style - Simpler Version
class SessionEndDialogSimple {
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.orangeAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'End Session?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to end this session? All shots will be saved to your history.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text('End Session'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}

/// Example 5: Complete Integration with GolfDeviceBloc
class DisconnectButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        // Show confirmation dialog
        final confirmed = await SessionEndDialog.show(context);

        if (!confirmed) return; // User cancelled

        // Show loading overlay
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.tealAccent),
                  SizedBox(height: 16),
                  Text(
                    'Saving shots and disconnecting...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        // Trigger disconnect event
        // context.read<GolfDeviceBloc>().add(DisconnectDeviceEvent());

        // Wait a bit for saving
        await Future.delayed(const Duration(seconds: 2));

        // Close loading
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Text('Session ended successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.logout_rounded),
      label: const Text('End Session'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}