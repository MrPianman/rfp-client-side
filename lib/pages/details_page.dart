import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String id;
  const DetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Details • $id'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Behavior'),
              Tab(text: 'Trips'),
              Tab(text: 'Maintenance'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _Placeholder('Overview content'),
            _Placeholder('Behavior content'),
            _Placeholder('Trips list'),
            _Placeholder('Maintenance info'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('Message Driver'),
          icon: const Icon(Icons.chat),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String text;
  const _Placeholder(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}
