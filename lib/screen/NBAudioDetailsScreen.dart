import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:newsblog/model/news_model.dart';
import 'package:newsblog/utils/NBColors.dart';
import 'package:newsblog/utils/NBImages.dart';
import 'package:newsblog/utils/NBWidgets.dart';

class NBAudioDetailsScreen extends StatefulWidget {
  final NewsModel newsDetails;

  const NBAudioDetailsScreen({super.key, required this.newsDetails});

  @override
  _NBAudioDetailsScreenState createState() => _NBAudioDetailsScreenState();
}

class _NBAudioDetailsScreenState extends State<NBAudioDetailsScreen> {
  late FlutterTts _flutterTts;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _currentPosition = 0.0;
  double _totalDuration = 1.0;

  String _audioDescription = ''; // Audio generated from the description

  bool isFollowing = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _audioDescription = widget.newsDetails.description;

    // Initialize TTS
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setVolume(1.0);
    _flutterTts.setSpeechRate(0.5); // Adjust speech rate if necessary
    _flutterTts.setPitch(1.0); // Adjust pitch if necessary

    // Calculate the total duration based on the text length and speech rate
    _calculateTotalDuration();

    // Set handlers for play, pause, and completion
    _flutterTts.setStartHandler(() {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      _startTimer(); // Start the timer when TTS starts
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
      });
      _stopTimer(); // Stop the timer when TTS completes
    });

    // Set handlers for play, pause, and completion
    _flutterTts.setStartHandler(() {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
      _startTimer();
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
        _currentPosition = 0.0;
      });
      _stopTimer();
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
      });
      _stopTimer();
    });
  }

  // Estimate total duration of the speech based on text length and speech rate
  void _calculateTotalDuration() {
    double speechRate = 0.5; // Set your desired speech rate (words per minute)
    int textLength = _audioDescription.split(" ").length; // Count words
    double estimatedDurationInMinutes = textLength /
        (speechRate *
            200); // Average rate is around 200 words per minute at speechRate 1.0

    setState(() {
      _totalDuration =
          estimatedDurationInMinutes * 60; // Convert minutes to seconds
    });
  }

  // Start a timer to update progress
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentPosition = _currentPosition + 1.0; // Update the progress
        if (_currentPosition >= _totalDuration) {
          _stopTimer();
        }
      });
    });
  }

  // Stop the timer
  void _stopTimer() {
    _timer.cancel();
  }

  // Play/Pause button functionality
  void _togglePlayPause() async {
    if (_isPlaying) {
      await _flutterTts.pause();
      _stopTimer();
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    } else {
      await _flutterTts
          .speak(_audioDescription.substring(_currentPosition.toInt()));
      _startTimer();
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  // Skip to next track (not applicable here, can be extended later)
  void _skipNext() {
    Navigator.pop(context);
  }

  // Skip to previous track (not applicable here, can be extended later)
  void _skipPrevious() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Audio Article',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Text(widget.newsDetails.category,
                style: boldTextStyle(color: NBPrimaryColor)),
            Row(
              children: [
                // Title of the news
                Text(widget.newsDetails.title, style: boldTextStyle(size: 20))
                    .expand(flex: 3),
              ],
            ),
            16.height,
            // Image of the news
            commonCachedNetworkImage(
              widget.newsDetails.imageUrl,
              height: 200,
              width: context.width(),
              fit: BoxFit.cover,
            ).cornerRadiusWithClipRRect(16),
            16.height,
            // Published Date and Follow button
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: Text('Source: ${widget.newsDetails.sourceName}',
                  style: boldTextStyle()),
              subtitle: Text(widget.newsDetails.publishedAt,
                  style: secondaryTextStyle()),
              leading:
                  CircleAvatar(backgroundImage: AssetImage(NBProfileImage)),
              trailing: AppButton(
                elevation: 0,
                text: isFollowing ? 'Following' : 'Follow',
                onTap: () {
                  setState(() {
                    isFollowing = !isFollowing;
                  });
                },
                color: isFollowing ? grey.withAlpha(51) : black,
                textColor: isFollowing ? grey : white,
              ).cornerRadiusWithClipRRect(30),
            ),
            16.height,
            // Description of the news
            Text(widget.newsDetails.description,
                style: primaryTextStyle(), textAlign: TextAlign.justify),
            16.height,
            // Linear Progress Indicator and Timers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: _currentPosition / _totalDuration,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade300,
                    color: NBPrimaryColor,
                  ),
                ],
              ),
            ),
            16.height,

            // Audio Player Section (Play/Pause, Skip Previous, Skip Next)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _skipPrevious,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: _skipNext,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ).paddingOnly(left: 16, right: 16),
      ),
    );
  }

  // Helper function to format duration in minutes:seconds format
  String _formatDuration(double duration) {
    int minutes = (duration / 60).floor();
    int seconds = (duration % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
