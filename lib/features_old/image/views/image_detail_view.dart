import 'package:canaspad/features_old/image/models/image_model.dart';
import 'package:flutter/material.dart';

class ImageDetailView extends StatefulWidget {
  final ImageSensor sensor;
  final int initialIndex;

  const ImageDetailView({super.key, required this.sensor, this.initialIndex = 0});

  @override
  State<ImageDetailView> createState() => ImageDetailViewState();
}

class ImageDetailViewState extends State<ImageDetailView> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.sensor.group} - ${widget.sensor.name}')),
      body: Column(
        children: [
          Text('Data Type: ${widget.sensor.dataType}'),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.sensor.data.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                final imageData = widget.sensor.data[index];
                return _buildPhotoView(imageData);
              },
            ),
          ),
          Slider(
            value: _currentPage.toDouble(),
            min: 0,
            max: (widget.sensor.data.length - 1).toDouble(),
            onChanged: (value) {
              setState(() => _currentPage = value.round());
              _pageController.jumpToPage(_currentPage);
            },
          ),
          Text('Image ${_currentPage + 1} of ${widget.sensor.data.length}'),
          Text('Timestamp: ${widget.sensor.data[_currentPage].createdAt}'),
        ],
      ),
    );
  }

  Widget _buildPhotoView(ImageData imageData) {
    if (imageData.image != null) {
      return RawImage(image: imageData.image);
    } else if (imageData.filePath != null) {
      return Image.network(
        imageData.filePath!,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text('Error loading image'));
        },
      );
    } else {
      return const Center(child: Text('No image data'));
    }
  }
}
