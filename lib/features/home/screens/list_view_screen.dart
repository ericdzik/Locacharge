// lib/features/home/screens/list_view_screen.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/features/home/widgets/commercant_list_item.dart';

class ListViewScreen extends StatelessWidget {
  final List<CommercantModel> commercants; // Sera passée depuis HomeScreen ou un état global

  const ListViewScreen({super.key, required this.commercants});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Points de Recharge'),
      ),
      body: commercants.isEmpty
          ? const Center(child: Text('Aucun point de recharge trouvé.'))
          : ListView.builder(
              itemCount: commercants.length,
              itemBuilder: (context, index) {
                return CommercantListItem(commercant: commercants[index]);
              },
            ),
    );
  }
}
