import 'package:flutter/cupertino.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      fallbackHeight: 200,
      fallbackWidth: double.infinity,
      color: CupertinoColors.activeBlue,
      strokeWidth: 2,
      child:
      Center(child: Text('Company Profile Page - Under Construction')),
    );
  }
}
