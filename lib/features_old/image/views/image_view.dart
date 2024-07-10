import 'package:canaspad/features_old/image/models/image_model.dart';
import 'package:canaspad/features_old/image/viewmodels/image_viewmodel.dart';
import 'package:canaspad/features_old/image/views/image_tile_view.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageView extends ConsumerStatefulWidget {
  const ImageView({super.key});

  @override
  ConsumerState<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends ConsumerState<ImageView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(imageViewModelProvider.notifier).loadImageSensors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(imageViewModelProvider);
    final flavor = ref.watch(flavorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Image Sensors')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : state.sensors.isEmpty
                  ? const Center(child: Text('No image sensors available'))
                  : ListView.builder(
                      itemCount: state.sensors.length,
                      itemBuilder: (context, index) {
                        final sensor = state.sensors[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageTileView(sensor: sensor),
                            ),
                          ),
                          child: Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text('${sensor.group} - ${sensor.name}'),
                                  subtitle: sensor.data.isNotEmpty ? Text('Last update: ${sensor.data.last.createdAt}') : null,
                                ),
                                if (sensor.data.isNotEmpty)
                                  Center(
                                    child: SizedBox(
                                      height: 200,
                                      child: _buildImage(sensor.data.last, flavor),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildImage(ImageData imageData, String flavor) {
    if (flavor == 'develop') {
      return RawImage(
        image: imageData.image,
      );
    } else {
      return Image.network(
        imageData.filePath ?? 'https://via.placeholder.com/300x200?text=No+Image',
        width: 300,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 300,
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text('Image not available')),
          );
        },
      );
    }
  }
}
