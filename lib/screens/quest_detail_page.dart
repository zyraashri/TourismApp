import 'package:flutter/material.dart';
import '../global_widgets.dart';

class QuestDetailPage extends StatefulWidget {
  final String title;
  final String icon;
  final String region;
  final List<Map<String, String>> locationsData;
  final List<Map<String, dynamic>> quizQuestions;
  final List<bool> initialCheckedLocations;

  const QuestDetailPage({
    super.key, 
    required this.title,
    required this.icon,
    required this.region,
    required this.locationsData,
    required this.quizQuestions,
    required this.initialCheckedLocations,
  });

  @override
  State<QuestDetailPage> createState() => _QuestDetailPageState();
}

class _QuestDetailPageState extends State<QuestDetailPage> {
  late List<bool> _checkedInLocations;

  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  int _correctAnswersCount = 0;
  bool _isQuizFinished = false; 

  @override
  void initState() {
    super.initState();
    _checkedInLocations = List.from(widget.initialCheckedLocations);
  }

  int get _checkInCount => _checkedInLocations.where((item) => item == true).length;
  double get _progressPercent => _checkInCount / widget.locationsData.length;

  void _submitAnswer() {
    setState(() {
      _isAnswerSubmitted = true;
      if (_selectedAnswerIndex == widget.quizQuestions[_currentQuestionIndex]['correctIndex']) {
        _correctAnswersCount++;
      }
      
      if (_currentQuestionIndex == widget.quizQuestions.length - 1) {
        _isQuizFinished = true;
        _checkCompletionStatus();
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _isAnswerSubmitted = false;
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswerIndex = null;
      _isAnswerSubmitted = false;
      _correctAnswersCount = 0;
      _isQuizFinished = false;
    });
  }

  void _toggleCheckIn(int index) {
    setState(() {
      _checkedInLocations[index] = !_checkedInLocations[index];
      _checkCompletionStatus();
    });
  }

  void _checkCompletionStatus() {
    bool allLocationsChecked = _checkedInLocations.every((status) => status == true);
    bool allQuizCorrect = _correctAnswersCount == widget.quizQuestions.length;

    if (allLocationsChecked && _isQuizFinished && allQuizCorrect) {
      _showSuccessBadgeDialog();
    }
  }

  void _goBackWithState() {
    Navigator.of(context).pop({
      'isQuestCompleted': _checkInCount == widget.locationsData.length && _isQuizFinished && _correctAnswersCount == widget.quizQuestions.length,
      'checkInCount': _checkInCount,
    });
  }

  void _showSuccessBadgeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                const Text('🏅', style: TextStyle(fontSize: 45)),
                const SizedBox(height: 10),
                const Text(
                  'Congratulations!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D464C)),
                ),
                const SizedBox(height: 6),
                Text(
                  "You're now a ${widget.region} Explorer!!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); 
                      Navigator.of(context).pop({
                        'isQuestCompleted': true,
                        'checkInCount': _checkInCount,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D464C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Awesome!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuiz = widget.quizQuestions[_currentQuestionIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Detail Box
            Container(
              color: const Color(0xFF2D464C),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
                        onPressed: _goBackWithState,
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(widget.icon, style: const TextStyle(fontSize: 26)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HERITAGE QUEST',
                              style: TextStyle(
                                color: Color(0xFFE5C158),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_checkInCount/${widget.locationsData.length} check-ins', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('${(_progressPercent * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _progressPercent,
                    backgroundColor: Colors.white24,
                    color: const Color(0xFFE5C158),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      SizedBox(width: 6),
                      Text('Location Check-ins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...List.generate(widget.locationsData.length, (index) {
                    return _buildCheckInCard(
                      index,
                      widget.locationsData[index]['title']!,
                      widget.locationsData[index]['subtitle']!,
                      _checkedInLocations[index],
                    );
                  }),

                  const SizedBox(height: 24),

                  Row(
                    children: const [
                      Text('🧠', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 6),
                      Text('Heritage Quiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dynamic Quiz UI Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF5A757C),
                                child: Text(
                                  '${_currentQuestionIndex + 1}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  currentQuiz['question'],
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(),
                          ),
                          
                          ...List.generate(currentQuiz['options'].length, (index) {
                            Color itemBgColor = const Color(0xFFF2F2F2);
                            if (_isAnswerSubmitted) {
                              if (index == currentQuiz['correctIndex']) {
                                itemBgColor = const Color(0xC8C8E6C9); 
                              } else if (index == _selectedAnswerIndex) {
                                itemBgColor = const Color(0xC8FFCDD2); 
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: itemBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: RadioListTile<int>(
                                value: index,
                                groupValue: _selectedAnswerIndex,
                                activeColor: const Color(0xFF5A757C),
                                title: Text(currentQuiz['options'][index], style: const TextStyle(fontSize: 14)),
                                onChanged: _isAnswerSubmitted 
                                    ? null 
                                    : (val) {
                                        setState(() {
                                          _selectedAnswerIndex = val;
                                        });
                                      },
                              ),
                            );
                          }),
                          
                          const SizedBox(height: 10),

                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: _selectedAnswerIndex == null 
                                      ? null 
                                      : (_isAnswerSubmitted 
                                          ? (_currentQuestionIndex < widget.quizQuestions.length - 1 ? _nextQuestion : null) 
                                          : _submitAnswer),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2D464C),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.grey[600],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    !_isAnswerSubmitted 
                                        ? 'Submit Answer' 
                                        : (_currentQuestionIndex < widget.quizQuestions.length - 1 ? 'Next Question' : 'Quiz Completed'),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              if (_isQuizFinished) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    onPressed: _resetQuiz,
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text('Retry Quiz', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2D464C),
                                      side: const BorderSide(color: Color(0xFF2D464C), width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(activeQuestIndex: true),
    );
  }

  Widget _buildCheckInCard(int index, String title, String subtitle, bool isChecked) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isChecked ? const Color(0xFFE2E6E7) : Colors.white,
      elevation: isChecked ? 0 : 1,
      child: InkWell(
        onTap: () => _toggleCheckIn(index), 
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isChecked ? Icons.check_circle : Icons.check_circle_outline,
                color: isChecked ? const Color(0xFF5A757C) : Colors.black26,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isChecked ? Colors.black54 : Colors.black87,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}