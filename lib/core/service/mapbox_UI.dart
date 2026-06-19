
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'mapbox_initiate.dart';

class MapboxSearchResultsDropdown extends StatelessWidget {
  final List<MapboxPlace> results;
  final bool isLoading;
  final ValueChanged<MapboxPlace> onSelected;

  const MapboxSearchResultsDropdown({
    super.key,
    required this.results,
    this.isLoading = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && results.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Material(
        elevation: 6,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: isLoading ? _loader() : _list(),
        ),
      ),
    );
  }

  Widget _loader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: Color(0xFFC9A14A),
          ),
        ),
      ),
    );
  }

  Widget _list() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 6),
      shrinkWrap: true,
      itemCount: results.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, indent: 54, color: Colors.grey.shade200),
      itemBuilder: (_, i) {
        final place = results[i];
        
       
        String cityDisplay = place.name;
        String? zipcodeDisplay;
        
       
        if (place.dropdownName.contains('(') && 
            place.dropdownName.contains(')')) {
          final parts = place.dropdownName.split('(');
          if (parts.length > 1) {
            cityDisplay = parts[0].trim();
            final zipPart = parts[1].split(')')[0];
            if (zipPart != place.name) {
              zipcodeDisplay = zipPart;
            }
          }
        }

        return ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFC9A14A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFFC9A14A),
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  cityDisplay,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
             
              if (zipcodeDisplay != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    zipcodeDisplay,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
         
          subtitle: place.countryName.isNotEmpty
              ? Text(
                  place.countryName, 
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF6B7280),
                  ),
                )
              : null,
          trailing: const Icon(
            Icons.north_west,
            size: 16,
            color: Color(0xFF9CA3AF),
          ),
          onTap: () => onSelected(place),
        );
      },
    );
  }
}
Future<MapboxPlace?> showMapboxLocationPicker(
    BuildContext context) async {
 
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFC9A14A),
      ),
    ),
  );

 
  final position =
      await MapboxLocationService.currentPosition();

  if (!context.mounted) return null;
  Navigator.of(context).pop(); 

  if (position == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to get location. '
            'Please enable location services.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return null;
  }

  
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFC9A14A),
            ),
            SizedBox(height: 16),
            Text(
              'Finding your city...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  final place = await MapboxLocationService.currentPlaceByZipcode();

  if (!context.mounted) return null;
  Navigator.of(context).pop(); // dismiss loading

  final effectivePlace = place ??
      MapboxPlace(
        name: 'Current Location',
        countryName: '',
        countryCode: '',
        displayName: 'Current Location',
        dropdownName: 'Current Location',
        latitude: position.latitude,
        longitude: position.longitude,
      );

  if (!context.mounted) return null;

 
  return showModalBottomSheet<MapboxPlace>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LocationMapSheet(
      latitude: position.latitude,
      longitude: position.longitude,
      place: effectivePlace,
    ),
  );
}



class _LocationMapSheet extends StatelessWidget {
  final double latitude;
  final double longitude;
  final MapboxPlace place;

  const _LocationMapSheet({
    required this.latitude,
    required this.longitude,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return Container(
      height: MediaQuery.of(context).size.height * 0.68,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Your Current Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          if (place.postalCode != null &&
              place.postalCode!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Postal Code: ${place.postalCode}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
          
          const SizedBox(height: 14),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 15,
                    interactionOptions:
                        const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    
                    TileLayer(
                      urlTemplate: MapboxConfig.tileUrl,
                      userAgentPackageName:
                          'com.tapovana.app',
                      maxZoom: 19,
                    ),

                   
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 260,
                          height: 95,
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                          10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(
                                              alpha: 0.15),
                                      blurRadius: 10,
                                      offset:
                                          const Offset(
                                              0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(
                                          0xFFC9A14A),
                                      size: 16,
                                    ),
                                    const SizedBox(
                                        width: 4),
                                    Flexible(
                                      child: Text(
                                        
                                        place.displayName,
                                        style:
                                            const TextStyle(
                                          fontSize: 13,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          color: Color(
                                              0xFF111827),
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),

                            
                              const Icon(
                                Icons.location_on,
                                color:
                                    Color(0xFFC9A14A),
                                size: 42,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          
          const SizedBox(height: 16),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A14A)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFC9A14A),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                     
                      if (place.countryName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          place.countryName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    
                      if (place.postalCode != null &&
                          place.postalCode!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ZIP: ${place.postalCode}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          
          const SizedBox(height: 18),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(place),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFC9A14A),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Use This Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}