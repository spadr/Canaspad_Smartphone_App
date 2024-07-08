import 'package:canaspad/features/image/models/image_model.dart';
import 'package:canaspad/features/image/views/image_detail_view.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ImageTileView extends ConsumerWidget {
  final ImageSensor sensor;

  const ImageTileView({Key? key, required this.sensor}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final groupedData = _groupImageDataByDate(sensor.data);

    return Scaffold(
      appBar: AppBar(title: Text('${sensor.group} - ${sensor.name}')),
      body: ListView.builder(
        itemCount: groupedData.length,
        itemBuilder: (context, index) {
          final date = groupedData.keys.elementAt(index);
          final images = groupedData[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DateFormat('yyyy-MM-dd').format(date),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                ),
                itemCount: images.length,
                itemBuilder: (context, imageIndex) {
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailView(
                          sensor: sensor,
                          initialIndex: sensor.data.indexOf(images[imageIndex]),
                        ),
                      ),
                    ),
                    child: _buildImageTile(images[imageIndex], flavor),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<ImageData>> _groupImageDataByDate(List<ImageData> data) {
    final groupedData = <DateTime, List<ImageData>>{};
    for (var image in data) {
      final date = DateTime(image.createdAt!.year, image.createdAt!.month, image.createdAt!.day);
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(image);
    }
    return Map.fromEntries(groupedData.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  Widget _buildImageTile(ImageData imageData, String flavor) {
    if (flavor == 'develop') {
      return RawImage(
        image: imageData.image,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        imageData.filePath ?? 'https://via.placeholder.com/300x200?text=No+Image',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: Text('Error')),
          );
        },
      );
    }
  }
}
