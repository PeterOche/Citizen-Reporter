import 'package:flutter/material.dart';

import '../screens/add_incident_screen.dart';
import '../screens/incident_posted_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Citizen Report',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          ListTile(
            title: const Text(
              'Report an Incident',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddIncidentScreen(),
                ),
              );
            },
          ),
          const SizedBox(
            height: 8,
          ),
          ListTile(
            title: const Text(
              'View Reported Incident',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => IncidentPostedPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
