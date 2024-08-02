// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class TripInfoPanel extends StatefulWidget {
  final TextEditingController pickupLocationController;
  final TextEditingController destinationLocationController;
  final Function(LatLng, LatLng) onLocationsChanged;

  TripInfoPanel({
    required this.onLocationsChanged,
    required this.pickupLocationController,
    required this.destinationLocationController,
  });

  @override
  _TripInfoPanelState createState() => _TripInfoPanelState();
}

class _TripInfoPanelState extends State<TripInfoPanel> {
  List<String> _pickupSuggestions = [];
  List<String> _destinationSuggestions = [];
  LatLng? _currentLocation;

  Future<void> _fetchSuggestions(String query, bool isPickup) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        if (isPickup) {
          _pickupSuggestions =
              data.map((item) => item['display_name'] as String).toList();
        } else {
          _destinationSuggestions =
              data.map((item) => item['display_name'] as String).toList();
        }
      });
    }
  }

  Future<LatLng?> _fetchLatLng(String address) async {
    if (address == "Vị trí hiện tại" && _currentLocation != null) {
      return _currentLocation;
    }
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&addressdetails=1&limit=1');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  Future<void> _updateLocations() async {
    LatLng? pickupLatLng =
        await _fetchLatLng(widget.pickupLocationController.text);
    LatLng? destinationLatLng =
        await _fetchLatLng(widget.destinationLocationController.text);

    if (pickupLatLng != null && destinationLatLng != null) {
      widget.onLocationsChanged(pickupLatLng, destinationLatLng);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, bool isPickup) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.teal),
            suffixIcon: IconButton(
              icon: Icon(Icons.my_location, color: Colors.teal),
              onPressed: () {
                if (_currentLocation != null) {
                  controller.text = "Vị trí hiện tại";
                  _updateLocations();
                }
              },
            ),
            hintText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onChanged: (query) {
            if (query.isNotEmpty) {
              _fetchSuggestions(query, isPickup);
            } else {
              setState(() {
                if (isPickup) {
                  _pickupSuggestions.clear();
                } else {
                  _destinationSuggestions.clear();
                }
              });
            }
          },
        ),
        if ((isPickup ? _pickupSuggestions : _destinationSuggestions)
            .isNotEmpty)
          SizedBox(
            height: 150, // Đặt chiều cao cố định cho danh sách gợi ý
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: isPickup
                  ? _pickupSuggestions.length
                  : _destinationSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = isPickup
                    ? _pickupSuggestions[index]
                    : _destinationSuggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    setState(() {
                      controller.text = suggestion;
                      if (isPickup) {
                        _pickupSuggestions.clear();
                      } else {
                        _destinationSuggestions.clear();
                      }
                    });
                    _updateLocations();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHandle(),
            SizedBox(height: 16.0),
            Center(
              child: Text(
                "Thông tin chuyến đi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  fontFamily: "Roboto",
                ),
              ),
            ),
            SizedBox(height: 40.0),
            _buildTextField(
              "Điểm đón",
              widget.pickupLocationController,
              Icons.location_on,
              true,
            ),
            SizedBox(height: 16.0),
            _buildTextField(
              "Điểm đến",
              widget.destinationLocationController,
              Icons.flag,
              false,
            ),
            SizedBox(height: 10.0),
            Center(
              child: ElevatedButton(
                onPressed: _updateLocations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Chỉ đường'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
      ],
    );
  }
}
