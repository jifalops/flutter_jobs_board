import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firebase.dart';

const appName = 'Flutter Jobs Board';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: JobList(),
    );
  }
}

class JobList extends StatefulWidget {
  @override
  _JobListState createState() => _JobListState();
}

class _JobListState extends State<JobList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: FutureBuilder<List<JobPost>>(
          future: fetchJobs(),
          builder: (context, snap) {
            if (snap.hasData) {
              return ListView(
                children: snap.data.map((job) => JobPostView(job)).toList(),
              );
            } else if (snap.hasError) {
              return Text('${snap.error}');
            } else
              return Center(
                child: CircularProgressIndicator(),
              );
          }),
    );
  }
}

Future<List<JobPost>> fetchJobs() async => (await fetchCollection('jobs'))
    .documents
    .map((snap) => JobPost(snap))
    .toList();

class JobPost {
  JobPost(DocumentSnapshot snap)
      : id = snap.documentID,
        title = snap.data['title'],
        company = snap.data['company'],
        location = snap.data['location'],
        description = snap.data['description'],
        created = DateTime.fromMillisecondsSinceEpoch(snap.data['created']),
        iconUrl = snap.data['imageUrl'];
  final String id, title, company, location, description, iconUrl;
  final DateTime created;
}

class JobPostView extends StatelessWidget {
  JobPostView(this.job);
  final JobPost job;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => JobDetailsView(job))),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.network(job.iconUrl, height: 56, width: 56),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(job.title),
                  Text(job.location),
                  Text(job.description,
                      maxLines: 1, overflow: TextOverflow.clip),
                ],
              ))
            ],
          ),
        ],
      ),
    );
  }
}

class JobDetailsView extends StatelessWidget {
  JobDetailsView(this.job);
  final JobPost job;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            SizedBox(height: 24),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Image.network(job.iconUrl, height: 64, width: 64),
                ),
                Text(job.company, style: Theme.of(context).textTheme.title)
              ],
            ),
            SizedBox(height: 24),
            Text(
              job.title,
              style: Theme.of(context).textTheme.headline,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),

            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(job.location, style: Theme.of(context).textTheme.subtitle),
                Text(DateFormat('MMM d').format(job.created)),
              ],
            ),
            SizedBox(height: 24),
            Text(job.description),
            Text(job.id),
          ],
        ),
      ),
    );
  }
}
