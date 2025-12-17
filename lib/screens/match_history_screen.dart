import 'package:demo/models/game_models.dart';
import 'package:demo/providers/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match History'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, _) {
          final matches = historyProvider.matches;

          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No matches yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Play a Game'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return _buildMatchCard(match);
            },
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final formattedDate = dateFormat.format(match.date);

    Color getWinnerColor() {
      if (match.winner == 'tie') return Colors.grey;
      if (match.winner == 'X') return Colors.blue;
      return Colors.red;
    }

    String getWinnerText() {
      if (match.winner == 'tie') return "Tie";
      if (match.winner == 'X') return "${match.player1Name} (X)";
      return "${match.player2Name} (O)";
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: getWinnerColor().withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ExpansionTile(
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${match.player1Name} vs ${match.player2Name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          match.winner == 'tie'
                              ? Icons.check_circle
                              : Icons.emoji_events,
                          size: 16,
                          color: getWinnerColor(),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Winner: ${getWinnerText()}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getWinnerColor(),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getWinnerColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: getWinnerColor(), width: 1.5),
                ),
                child: Text(
                  getWinnerText(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getWinnerColor(),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Final Board:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _buildBoardPreview(match.board),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            match.player1Name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '(X)',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            match.player2Name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '(O)',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardPreview(List<String> board) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final cell = board[index];
        return Container(
          decoration: BoxDecoration(
            color: cell == 'X'
                ? Colors.blue.withOpacity(0.2)
                : cell == 'O'
                ? Colors.red.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Center(
            child: Text(
              cell,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cell == 'X'
                    ? Colors.blue
                    : cell == 'O'
                    ? Colors.red
                    : Colors.transparent,
              ),
            ),
          ),
        );
      },
    );
  }
}
