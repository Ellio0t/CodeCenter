import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/cashback_code.dart';
import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import 'package:provider/provider.dart';
import '../providers/prime_provider.dart';

class CodeCard extends StatefulWidget {
  final CashbackCode cashbackCode;

  const CodeCard({super.key, required this.cashbackCode});

  @override
  State<CodeCard> createState() => _CodeCardState();
}

class _CodeCardState extends State<CodeCard> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  bool _isExpired = false;
  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    var expiration = widget.cashbackCode.date; 

    // If expiration is exactly at midnight (start of day), 
    // treat it as valid until the end of that day.
    if (expiration.hour == 0 && expiration.minute == 0 && expiration.second == 0) {
      expiration = DateTime(
        expiration.year,
        expiration.month,
        expiration.day,
        23, 59, 59,
      );
    }
    
    if (expiration.isBefore(now)) {
      if (!_isExpired) {
        setState(() {
          _isExpired = true;
          _timeLeft = Duration.zero;
        });
      }
      _timer?.cancel();
    } else {
      if (_isExpired || expiration.difference(now).inSeconds != _timeLeft.inSeconds) {
        setState(() {
          _isExpired = false;
          _timeLeft = expiration.difference(now);
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inDays > 0) {
       return "${duration.inDays}d ${duration.inHours.remainder(24)}h ${twoDigitMinutes}m";
    }
    if (duration.inHours > 0) {
      return "${duration.inHours}h $twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy HH:mm').format(widget.cashbackCode.date.toLocal());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isDark ? 4 : 2, // Slightly higher elevation in dark mode
      shadowColor: isDark 
          ? Colors.white.withOpacity(0.12) // Subtle white glow for dark mode
          : Colors.black.withOpacity(0.2), 
      color: _isExpired 
          ? (isDark ? Colors.grey[800] : Colors.grey[200])
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isDark 
            ? const BorderSide(color: Colors.white12, width: 1) // Subtle border for definition
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.cashbackCode.siteName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isExpired ? Colors.grey : const Color(0xFF10D34E),
                      ),
                ),
                _isExpired
                    ? const Icon(Icons.discount, color: Colors.grey)
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black87 : Colors.white, // Black for Neon, White for Light
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isDark ? const Color(0xFF39FF14) : const Color(0xFF10D34E),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark 
                                  ? const Color(0xFF39FF14).withOpacity(0.5) 
                                  : const Color(0xFF10D34E).withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF39FF14) : const Color(0xFF10D34E),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            shadows: isDark ? [
                              const Shadow(
                                color: Color(0xFF39FF14),
                                blurRadius: 4,
                              ),
                            ] : [], // Clean text for light mode
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.cashbackCode.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _isExpired ? Colors.grey[600] : null,
                fontSize: 13, // Reduced by ~10%
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isExpired 
                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[300]) 
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100]),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[700]! 
                    : Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.cashbackCode.code,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: _isExpired 
                            ? Colors.grey[600] 
                            : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), // Adaptive color
                        decoration: _isExpired ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTapDown: _isExpired ? null : (_) => setState(() => _buttonScale = 0.92),
                    onTapUp: _isExpired ? null : (_) => setState(() => _buttonScale = 1.0),
                    onTapCancel: _isExpired ? null : () => setState(() => _buttonScale = 1.0),
                    onTap: _isExpired ? null : () {
                      void copyLogic() {
                        Clipboard.setData(ClipboardData(text: widget.cashbackCode.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied! You can now go claim it.'),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }

                      void failureLogic() {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code not copied'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }

                      if (!kIsWeb) {
                        final isPrime = Provider.of<PrimeProvider>(context, listen: false).isPrime;
                        if (isPrime) {
                           copyLogic(); // Skip ad for Prime members
                        } else {
                           AdService().showRewardedInterstitialAd(
                             onReward: copyLogic,
                             onFailure: failureLogic,
                           );
                        }
                      } else {
                        copyLogic();
                      }
                    },
                    child: AnimatedScale(
                      scale: _buttonScale,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: _isExpired 
                                ? null 
                                : const LinearGradient(
                                    colors: [Color(0xFF00E676), Color(0xFF10D34E)], // More vibrant green
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            color: _isExpired ? Colors.grey : null,
                            borderRadius: BorderRadius.circular(12), // Match card roundness style
                            boxShadow: _isExpired ? [] : [
                              BoxShadow(
                                color: const Color(0xFF10D34E).withOpacity(0.4),
                                blurRadius: 8, // Softer glow
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        child: Text(
                          _isExpired ? 'EXPIRED' : 'COPY',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: _isExpired ? [] : [
                              const Shadow(
                                offset: Offset(1.5, 1.5),
                                color: Color(0xFF00B0FF),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      if (!_isExpired)
                        Text(
                          "Ends in: ${_formatDuration(_timeLeft)}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 11, // Reduced from 12 (-10%)
                          ),
                        ),
                    ],
                  ),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
