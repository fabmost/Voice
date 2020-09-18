import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/content_provider.dart';
import '../models/poll_model.dart';
import '../models/poll_answer_model.dart';
import '../screens/poll_gallery_screen.dart';

class PollAnswers extends StatelessWidget {
  final String id;
  final bool isMine;
  final Function setVote;

  PollAnswers(this.id, this.isMine, this.setVote);

  void _toGallery(context, id, image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PollGalleryScreen(
          reference: id,
          galleryItems: [image],
          initialIndex: 0,
        ),
      ),
    );
  }

  Widget _getOptions(
      context, votes, _hasVoted, List<PollAnswerModel> _answers) {
    int pos = -1;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _answers.map(
          (option) {
            pos++;
            if (option.url != null) {
              return Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _toGallery(context, option.id, option.url),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(option.url),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _hasVoted
                            ? _voted(
                                votes,
                                option.answer,
                                option.isVote,
                                option.count,
                              )
                            : _poll(
                                context,
                                option.answer,
                                option.id,
                                pos,
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              );
            }
            return Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: _hasVoted
                      ? _voted(
                          votes,
                          option.answer,
                          option.isVote,
                          option.count,
                        )
                      : _poll(
                          context,
                          option.answer,
                          option.id,
                          pos,
                        ),
                ),
                SizedBox(height: 8),
              ],
            );
          },
        ).toList());
  }

  Widget _poll(context, option, idAnswer, position) {
    return FlatButton(
      child: Text(option),
      onPressed: () => setVote(idAnswer, position),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Theme.of(context).primaryColor)),
    );
  }

  Widget _voted(votes, answer, isVote, amount) {
    var totalPercentage = (amount == 0.0) ? 0.0 : amount / votes;
    if (totalPercentage > 1) {
      totalPercentage = 1;
    }
    final format = NumberFormat('###.##');
    return Container(
      height: 42,
      child: Stack(
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: totalPercentage * 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xAA6767CB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  topRight:
                      totalPercentage == 1 ? Radius.circular(12) : Radius.zero,
                  bottomRight:
                      totalPercentage == 1 ? Radius.circular(12) : Radius.zero,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ListTile(
              dense: true,
              title: Row(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      answer,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isVote)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                ],
              ),
              trailing: Text(
                '${format.format(totalPercentage * 100)}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(builder: (context, value, child) {
      PollModel poll = value.getPolls[id];
      return _getOptions(
          context, poll.votes, isMine ? isMine : poll.hasVoted, poll.answers);
    });
  }
}
